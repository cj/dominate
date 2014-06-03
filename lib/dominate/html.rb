module Dominate
  module HTML
    extend self

    VIEW_TYPES = %w(html slim haml erb md markdown mkd mab)

    def file file, instance = false, config = {}
      c    = (Dominate.config.to_h.merge config).to_deep_ostruct
      path = "#{c.view_path}/#{file}"
      html = load path
      dom  = Dom.new html, instance, config

      if File.file? path + '.dom'
        dom = Instance.new(instance, c).instance_eval File.read(path + '.dom')
      end

      dom
    end

    def load path
      html = false

      VIEW_TYPES.each do |type|
        file = "#{path}.#{type}"

        if File.file? file
          template = Tilt.new file
          html = template.render
          break
        end
      end

      html
    end
  end
end
