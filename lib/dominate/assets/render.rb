module Dominate
  module Assets
    module Render
      PARTIAL_REGEX = Regexp.new '([a-zA-Z_]+)$'

      def self.setup app
        app.settings[:render] ||= {}
        app.use Middleware

        load_engines
      end

      def render file, options = {}
        options[:layout] ||= (
          settings[:render][:layout] || Dominate.config.layout_path
        )
        path    = "#{settings[:render][:views] || Dominate.config.view_path}"
        layout  = "#{options[:layout]}"
        content = Dominate::Tilt.load_file "#{path}/#{file}", options, self
        options[:content] = content
        Dominate::Tilt.load_file layout, options, self
      end

      def partial file, options = {}
        file.gsub! PARTIAL_REGEX, '_\1'
        path = "#{settings[:render][:views] || Dominate.config.view_path}"
        Dominate::Tilt.load_file "#{path}/#{file}", options, self
      end

      private

      def load_engines
        if defined? Slim
          Slim::Engine.set_default_options \
            disable_escape: true,
            use_html_safe: true,
            disable_capture: false

          if RACK_ENV == 'development'
            Slim::Engine.set_default_options pretty: true
          end
        end
      end
    end
  end
end
