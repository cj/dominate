module Dominate
  class Dom
    attr_accessor :raw_html, :instance, :doc

    PARTIAL_REGEX = /<!--(?:\s*|)@partial(?:\s*|)([a-zA-Z0-9\-_]*)(?:\s*|)-->/
    PARTIAL_REGEX_WITHIN =/<!--(?:\s*|)@partial(?:\s*|)([a-zA-Z0-9\-_]*)(?:\s*|)-->(.*?)<!--(?:\s*|)\/partial(?:\s*|)([a-zA-Z0-9\-_]*)(?:\s*|)-->/m
    VIEW_TYPES    = %w(html slim haml erb md markdown mkd mab)

    def initialize raw_html, instance = false
      @raw_html = raw_html
      @instance = instance

      if raw_html.match(/<html.*>/)
        @doc = Nokogiri::HTML::Document.parse raw_html
      else
        # need to wrap it in a div to make sure it has a root
        @doc = Nokogiri::HTML.fragment "<div>#{raw_html}</div>"
      end

      load_partials if Dominate.config.view_path
    end

    def load_partials
      updated_html = doc.inner_html.gsub(PARTIAL_REGEX_WITHIN) do |m|
        match   = m.strip.match(PARTIAL_REGEX)
        partial = match[1]
        load_view "#{view_path}/#{partial}"
      end

      doc.inner_html = updated_html if updated_html

      doc.traverse do |e|
        if match = e.to_html.strip.match(PARTIAL_REGEX)
          partial = match[1]
          e.swap Nokogiri::HTML.fragment(
            load_view "#{view_path}/#{partial}"
          )
        end
      end
    end

    def scope name
      reset_html
      Scope.new instance, doc.search("[data-scope='#{name}']")
    end

    def html
      @html ||= begin
        apply_instance if instance
        "#{doc}"
      end
    end

    def apply_instance
      reset_html
      Scope.new(instance, doc).apply_instance
    end

    private

    def reset_html
      @html = false
    end

    def view_path
      Dominate.config.view_path
    end

    def load_view path
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
