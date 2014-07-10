require 'dominate/mab'

module Dominate
  module Assets
    autoload :Middleware, 'dominate/assets/middleware'
    autoload :Render,     'dominate/assets/render'

    def self.setup app
      app.use Middleware
      app.plugin Render
    end

    def css_assets options = {}
      options = {
        'data-turbolinks-track' => 'true',
        rel: 'stylesheet',
        type: 'text/css',
        media: 'all'
      }.merge options

      url = Dominate.config.asset_url

      if Dominate.config.assets_compiled
        options[:href] = "#{url}/css/all-#{sha}.css"
      else
        options[:href] = "#{url}/css/all.css"
      end

      mab { link options }
    end

    def js_assets options = {}
      options = {
        'data-turbolinks-track' => 'true',
      }.merge options

      url = Dominate.config.asset_url

      if Dominate.config.assets_compiled
        options[:src] = "#{url}/js/all-#{sha}.js"
      else
        options[:src] = "#{url}/js/all.js"
      end

      mab { script options }
    end

    def self.compile
      Dominate.config.assets.to_h.each do |type, assets|
        content = ''

        if assets.length > 0
          type_path = "#{Dominate.config.asset_path}/#{Dominate.config[:"asset_#{type}_folder"]}"
          assets.each do |file|
            path = "#{type_path}/#{file}"
            content += Dominate::HTML.load_file path
          end
          tmp_path = "#{type_path}/tmp.dominate-compiled.#{type}"
          File.write tmp_path, content
          system "minify #{tmp_path} > #{type_path}/dominate-compiled.#{type}"
          File.delete tmp_path
        end
      end
    end

    private

    def sha
      Thread.current[:_sha] ||= (Dominate.config.sha || `git rev-parse HEAD`.strip)
    end
  end
end
