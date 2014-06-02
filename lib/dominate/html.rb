module Dominate
  module HTML
    extend self

    VIEW_TYPES = %w(html slim haml erb md markdown mkd mab)

    def file file, instance = false, config = {}
      c    = (Dominate.config.to_h.merge config).to_deep_ostruct
      html = load "#{c.view_path}/#{file}"
      Dom.new html, instance, config
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
