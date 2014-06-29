module Dominate
  class Widget
    module Helper
      class << self
        def setup app
          initialize
        end

        def initialize
          # Load the widgets
          Dir.glob("#{Dominate.config.widget_path}/**/*.rb").each do |w|
            require w
          end

          if defined?(Slim) && defined?(Slim::Engine)
            Slim::Engine.set_default_options \
              disable_escape: true,
              use_html_safe: false,
              disable_capture: false
          end
        end
      end

      def render_widget *args
        @dominate_widgets ||= Widget.load_all(self, Event.new, req, res)

        if args.first.kind_of? Hash
          opts = args.first
          name = req.env[:widget_name]
        else
          name = args.first
          opts = args.length > 1 ? args.last : {}
        end

        # set the current state (the method that will get called on render_widget)
        state = opts[:state] || 'display'

        widget = req.env[:loaded_widgets][name]

        # begin
          if widget.method(state).parameters.length > 0
            resp = widget.send state, opts.to_deep_ostruct
          else
            resp = widget.send state
          end

          # if resp.is_a? Dominate::Dom
          #   html = "<div id='#{widget.id_for(state)}'>#{resp.html}</div>"
          #   resp.reset_html
          #   resp.doc.inner_html = html
          #   resp.html
          if resp.is_a? String
            html = "<div id='#{widget.id_for(state)}'>#{resp}</div>"
            html
          else
            resp
          end
        # rescue NoMethodError
        #   raise "Please add ##{state} to #{widget.class}."
        # end
      end

      def url_for_event event, options = {}
        widget_name = options.delete(:widget_name)
        "http#{req.env['SERVER_PORT'] == '443' ? 's' : ''}://#{req.env['HTTP_HOST']}#{Dominate.config.widget_url}?widget_event=#{event}&widget_name=#{widget_name}" + (options.any?? '&' + URI.encode_www_form(options) : '')
      end
    end
  end
end
