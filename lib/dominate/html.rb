module Dominate
  module HTML
    extend self

    VIEW_TYPES = %w(html slim haml erb md markdown mkd mab)

    def file file, instance = false, config = {}
      c    = (Dominate.config.to_h.merge config).to_deep_ostruct
      path = "#{c.view_path}/#{file}"
      html = load path, c, instance
      dom  = Dom.new html, instance, config

      if File.file? path + '.dom'
        dom = Instance.new(instance, c).instance_eval File.read(path + '.dom')
      end

      dom
    end

    def load path, config, instance
      html = false

      VIEW_TYPES.each do |type|
        f = "#{path}.#{type}"

        if File.file? f
          template = Tilt.new f
          html     = template.render instance, config.to_h
          break
        end
      end

      unless html
        raise Dominate::NoFileFound,
          "Could't find file: #{path} with any of these extensions: #{VIEW_TYPES.join(', ')}."
      end

      html
    end
  end
end
