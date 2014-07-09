require 'rack/mime'

module Dominate
  module Assets
    class Middleware
      STATIC_TYPES = %w(js css)

      attr_reader :app, :env, :res

      def initialize(app)
        @app = app
      end

      def call env
        dup.call! env
      end

      def call! env
        @env = env

        if assets_path
          render_assets
        else
          res
        end
      end

      private

      def res
        @res ||= begin
          if not assets_path
            app.call(req.env)
          else
            Cuba::Response.new
          end
        end
      end

      def req
        @req ||= Rack::Request.new env
      end

      def assets_path
        path[Regexp.new("^#{Dominate.config.asset_url}($|.*)")]
      end

      def path
        env['PATH_INFO']
      end

      def type
        if matched = path.match(/(?<=#{Dominate.config.asset_url}\/).*(?=\/)/)
          matched[0]
        else
          ''
        end
      end

      def name
        cleaned = path.gsub(/\.#{ext}$/, '')
        cleaned = cleaned.gsub(/^#{Dominate.config.asset_url}\//, '')
        cleaned = cleaned.gsub(/^#{type}\//, '')
        cleaned
      end

      def ext
        if matched = path.match(/(?<=\.).*$/)
          matched[0]
        else
          false
        end
      end

      def render_assets
        if name == 'all'
          res.write render_all_files
        else
          res.write render_single_file
        end

        case type
        when 'css', 'stylesheet', 'stylesheets'
          content_type = 'text/css'
        when 'js', 'javascript', 'javascripts'
          content_type = 'text/javascript'
        else
          content_type = Rack::Mime.mime_type ext
        end

        res.headers["Content-Type"] = content_type

        res.finish
      end

      def render_all_files
        content = ''
        files   = Dominate.config.assets[ext]
        path    = "#{Dominate.config.asset_path}/#{type}"

        files.each do |file|
          content += load_file "#{path}/#{file}"
        end

        content
      end

      def render_single_file
        path  = "#{Dominate.config.asset_path}/#{type}"
        load_file "#{path}/#{name}.#{ext}"
      end

      def load_file path
        ext = path[/\.[^.]*$/][1..-1]

        if STATIC_TYPES.include? ext
          File.read path
        else
          Dominate::HTML.load_file path
        end
      end
    end
  end
end
