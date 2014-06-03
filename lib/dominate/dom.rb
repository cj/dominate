module Dominate
  class Dom
    attr_accessor :raw_html, :instance, :options, :config, :doc

    YIELD_REGEX          = /<!--(?:\s*|)@yield(?:\s*|)-->/
    PARTIAL_REGEX        = /<!--(?:\s*|)@partial(?:\s*|)([a-zA-Z0-9\-_]*)(?:\s*|)-->/
    PARTIAL_REGEX_WITHIN = /<!--(?:\s*|)@partial(?:\s*|)([a-zA-Z0-9\-_]*)(?:\s*|)-->(.*?)<!--(?:\s*|)\/partial(?:\s*|)([a-zA-Z0-9\-_]*)(?:\s*|)-->/m

    def initialize raw_html, instance = false, config = {}
      @raw_html = raw_html
      @instance = instance
      @config   = (Dominate.config.to_h.merge config).to_deep_ostruct

      set_doc raw_html
      load_html if Dominate.config.view_path
    end

    def load_html
      load_layout if config.layout

      updated_html = doc.inner_html.gsub(PARTIAL_REGEX_WITHIN) do |m|
        match   = m.strip.match(PARTIAL_REGEX)
        partial = match[1]
        HTML.load "#{view_path}/#{partial}"
      end

      set_doc updated_html if updated_html

      doc.traverse do |e|
        if match = e.to_html.strip.match(PARTIAL_REGEX)
          partial = match[1]
          e.swap Nokogiri::HTML.fragment(
            HTML.load "#{view_path}/#{partial}"
          )
        end
      end
    end

    def load_layout
      html       = HTML.load config.layout
      inner_html = doc.inner_html
      set_doc html.gsub YIELD_REGEX, inner_html
    end

    def scope name, &block
      root_doc = doc.search("[data-scope='#{name}']")
      @scope   = Scope.new instance, config, root_doc

      Instance.new(instance, config).instance_exec(root_doc, &block) if block

      self
    end

    def html
      @html ||= begin
        apply_instance if instance
        "#{doc}"
      end
    end

    def apply data, &block
      @scope.apply data, &block

      self
    end

    def apply_instance
      reset_html
      Scope.new(instance, config, doc).apply_instance
    end

    private

    def set_doc html
      @doc = Nokogiri::HTML.parse html
    end

    def reset_html
      @html = false
    end

    def view_path
      config.view_path
    end
  end
end
