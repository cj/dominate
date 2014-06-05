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
        Widget.load_all(self, req, res)

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

          if resp.is_a? Dominate::Dom
            resp.html
          else
            resp
          end
        # rescue NoMethodError
        #   raise "Please add ##{state} to #{widget.class}."
        # end
      end
    end
  end
end
