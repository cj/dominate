module Dominate
  class Widget
    JS_ESCAPE     = { '\\' => '\\\\', '</' => '<\/', "\r\n" => '\n', "\n" => '\n', "\r" => '\n', '"' => '\\"', "'" => "\\'" }
    PARTIAL_REGEX = Regexp.new '([a-zA-Z_]+)$'

    autoload :Event,      "dominate/widget/event"
    autoload :Middleware, "dominate/widget/middleware"
    autoload :Helper,     "dominate/widget/helper"

    attr_accessor :app, :res, :req, :name, :event, :widget_state

    def initialize app, res, req, name, event
      @app          = app
      @res          = res
      @req          = req
      @name         = name.to_s
      @event        = event
      @widget_state = false

      event.add_observer self, :trigger_event
    end

    def trigger_event widget_name, widget_event, data = {}
      if class_events = self.class.events
        class_events.each do |class_event, opts|
          if class_event.to_s == widget_event.to_s && (
            widget_name.to_s == name or
            opts[:for].to_s == widget_name.to_s
          )
            if not opts[:with]
              e = widget_event
            else
              e = opts[:with]
            end

            begin
              if method(e) and method(e).parameters.length > 0
                send(e, data)
              else
                send(e)
              end
            rescue NoMethodError
              raise "Please add ##{e} to your #{self.class}."
            end
          end
        end
      end
    end

    def render *args
      if args.first.kind_of? Hash
        locals = args.first
        # if it's a partial we add an underscore infront of it
        state = view = locals[:state] ||
          "#{locals[:partial]}".gsub(PARTIAL_REGEX, '_\1')
      else
        state = view = args.first
        locals = args.length > 1 ? args.last : {}
      end

      # set the state and view if it's blank
      if view.blank?
        state = view = caller[0][/`.*'/][1..-2]
      # override state if widget_state set
      elsif !locals[:state] && widget_state
        state = widget_state
      end

      req.env[:widget_name]  = name
      req.env[:widget_state] = state

      view_folder = self.class.to_s.gsub(
        /\w+::Widgets::/, ''
      ).split('::').map(&:underscore).join('/')

      # set the view path to the widget path
      locals[:view_path] = view_path
      # we also don't want a layout
      locals[:layout] = false unless locals.key? :layout
      file = "#{view_folder}/#{view}"

      Dominate::HTML.file(file, self, locals)
    end

    def view_path
      Dominate.config.widget_path
    end

    class << self
      def load_all app, req, res
        event = Event.new res, req

        if widget_event = req.params["widget_event"]
          widget_name = req.params["widget_name"]
        end

        unless req.env[:loaded_widgets]
          req.env[:loaded_widgets] ||= {}

          Dominate.config.widgets.each do |name, widget|
            req.env[:loaded_widgets][name] = Object.const_get(widget).new(
              app, res, req, name, event
            )
          end
        end

        [widget_name, widget_event, event]
      end
    end
  end
end
