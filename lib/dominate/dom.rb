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

      inner_html = doc.inner_html

      updated_html = inner_html.gsub(PARTIAL_REGEX_WITHIN) do |m|
        match   = m.strip.match(PARTIAL_REGEX)
        partial = match[1]
        HTML.load_file "#{view_path}/#{partial}", config, instance
      end

      updated_html = updated_html.gsub(PARTIAL_REGEX) do |m|
        partial = $~.captures.first
        HTML.load_file "#{view_path}/#{partial}", config, instance
      end

      set_doc updated_html

      # doc.traverse do |e|
      #   if match = e.to_html.strip.match(PARTIAL_REGEX)
      #     partial = match[1]
      #     e.swap Nokogiri::HTML.fragment(
      #       HTML.load_file "#{view_path}/#{partial}", config, instance
      #     )
      #   end
      # end
    end

    def load_layout
      path       = "#{config.view_path}/#{config.layout}"
      html       = HTML.load_file path, config, instance
      inner_html = doc.inner_html
      doc.inner_html = html.gsub YIELD_REGEX, inner_html
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

    def reset_html
      @html = false
    end

    private

    def set_doc html
      @doc = Nokogiri::HTML html
    end

    def view_path
      config.view_path
    end
  end
end
