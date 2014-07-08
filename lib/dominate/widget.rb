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

      self.instance_variables.each do |n|
        app.instance_variable_set n, self.instance_variable_get(n)
      end
    end

    def method_missing method, *args, &block
      if app.respond_to? method
        app.send method, *args, &block
      else
        super
      end
    end

    def set_state state
      @widget_state = state
    end

    def reset_state
      @widget_state = false
    end

    def partial template, locals = {}
      locals[:partial] = template
      resp = render locals

      if resp.is_a? Dominate::Dom
        resp.html
      else
        resp
      end
    end

    def render_state options = {}
      state = widget_state || options.delete(:state)

      if method(state).parameters.length > 0
        resp = send(state, options.to_deep_ostruct)
      else
        resp = send(state)
      end

      if resp.is_a? Dominate::Dom
        html = "<div id='#{id_for(state)}'>#{resp.html}</div>"
        # resp.doc.inner_html = html
        # resp.reset_html
        # resp.html
        html
      elsif resp.is_a? String
        html = "<div id='#{id_for(state)}'>#{resp}</div>"
        html
      else
        resp
      end
    end

    def replace state, opts = {}
      if !state.is_a? String
        opts[:state] = state
        content = render_state opts
        selector = '#' + id_for(state)
      else
        if !opts.key?(:content) and !opts.key?(:with)
          opts[:state] = caller[0][/`.*'/][1..-2]
          content = render_state opts
        else
          content = opts[:content] || opts[:with]
        end
        selector = state
      end

      res.write '$("' + selector + '").replaceWith("' + escape(content) + '");'
      # scroll to the top of the page just as if we went to the url directly
      # if opts[:scroll_to_top]
      #   res.write 'window.scrollTo(0, 0);'
      # end
    end

    def id_for state
      w_name  = name.to_s.gsub(/_/, '-')
      w_state = state.to_s.gsub(/_/, '-')

      "#{w_name}-#{w_state}"
    end

    def escape js
      js.to_s.gsub(/(\\|<\/|\r\n|\\3342\\2200\\2250|[\n\r"'])/) {|match| JS_ESCAPE[match] }
    end

    def trigger widget_event, data = {}
      data        = data.to_h
      widget_name = data.has_key?(:for) ? data.delete(:for) : name

      event.trigger widget_name, widget_event, data.to_h
      # threads = []
      #
      # req.env[:loaded_widgets].each do |n, w|
      #   threads << Thread.new do
      #     ThreadUtility.with_connection do
      #       ap widget_name
      #       w.trigger_event widget_name, widget_event, data.to_deep_ostruct
      #     end
      #   end
      # end
      #
      # threads.map(&:join)
    end

    def trigger_event widget_name, widget_event, data = {}
      if class_events = self.class.events
        class_events.each do |class_event, opts|
          if class_event.to_s == widget_event.to_s && (
           (widget_name.to_s == name.to_s && !opts.has_key?(:for)) or
            opts[:for].to_s == widget_name.to_s
          )
            if not opts[:with]
              e = widget_event
            else
              e = opts[:with]
            end

            # begin
              if method(e) and method(e).parameters.length > 0
                resp = send(e, data)
              else
                resp = send(e)
              end

              if resp.is_a? Dominate::Dom
                html = "<div id='#{id_for(e)}'>#{resp.html}</div>"
                # resp.doc.inner_html = html
                # resp.reset_html
                # res.write resp.html
                res.write html
              elsif resp.is_a? String
                html = "<div id='#{id_for(e)}'>#{resp}</div>"
                res.write html
              else
                resp
              end
            # rescue NoMethodError
            #   raise "Please add ##{e} to your #{self.class}."
            # end
          end
        end
      end
    end

    def url_for_event event, options = {}
      widget_name = options.delete(:widget_name) || name
      "http#{req.env['SERVER_PORT'] == '443' ? 's' : ''}://#{req.env['HTTP_HOST']}#{Dominate.config.widget_url}?widget_event=#{event}&widget_name=#{widget_name}" + (options.any?? '&' + URI.encode_www_form(options) : '')
    end

    def render *args
      if args.first.kind_of? Hash
        locals = args.first
        # if it's a partial we add an underscore infront of it
        state = view = locals[:state] ||
          "#{locals.delete(:partial)}".gsub(PARTIAL_REGEX, '_\1')
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
      attr_accessor :events

      def load_all app, event, req, res
        if widget_event = req.params["widget_event"]
          widget_name = req.params["widget_name"]
        end

        unless req.env[:loaded_widgets]
          req.env[:loaded_widgets] ||= {}

          Dominate.config.widgets.each do |name, widget_class_name|
            widget = Object.const_get(widget_class_name).new(
              app, res, req, name, event
            )
            event.register_for_event(event: :trigger, listener: widget, callback: :trigger_event)

            req.env[:loaded_widgets][name] = widget
          end
        end

        [widget_name, widget_event, event]
      end

      def respond_to event, opts = {}
        @events ||= []
        @events << [event.to_s, opts]
      end

      def responds_to *events
        @events ||= []
        events.each do |event|
          @events << [event, {}]
        end
      end
    end
  end
end
