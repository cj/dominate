module Dominate
  class Widget
    class Middleware

      def initialize(app)
        @app = app
      end

      def call env
        dup.call! env
      end

      def call! env
        @env = env

        if widget_path
          widget_name, widget_event, event = Widget.load_all @app, req, res

          event.trigger widget_name, widget_event, req.params
          # res.write "$('head > meta[name=csrf-token]').attr('content', '#{csrf_token}');"
          res.write '$(document).trigger("page:change");'
          res.finish
        else
          res
        end
      end

      private

      def res
        @res ||= begin
          if not widget_path
            @app.call(req.env)
          else
            Cuba::Response.new
          end
        end
      end

      def req
        @req ||= Rack::Request.new(@env)
      end

      def widget_path
        path[Regexp.new("^#{Dominate.config.widget_url}($|\\?.*)")]
      end

      def path
        @env['PATH_INFO']
      end
    end
  end
end
