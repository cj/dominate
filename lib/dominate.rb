require "nokogiri"
require "dominate/version"

module Dominate
  class << self
    def HTML html, data = {}
      Dom.new html, data
    end
  end

  class Dom
    attr_accessor :raw_html, :instance, :doc

    def initialize raw_html, instance = false
      @raw_html = raw_html
      @instance = instance
      @doc      = Nokogiri::HTML raw_html
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
  end

  class Scope < Struct.new :instance, :root_doc

    def apply data, &block
      @data = data

      root_doc.each do |doc|
        if data.is_a? Array
          doc = apply_list doc, data
        else
          doc = apply_data doc, data
        end

        block.call doc if block
      end

      root_doc
    end

    def apply_instance
      root_doc.traverse do |x|
        if defined?(x.attributes) && x.attributes.keys.include?('data-instance')
          method  = x.attr('data-instance')
          begin
            x.inner_html = instance.instance_eval method
          rescue
            x.inner_html = ''
          end
        end
      end

      root_doc
    end

    private

    def apply_data doc, data
      doc.traverse do |x|
        if x.attributes.keys.include? 'data-prop'
        end
      end
    end

    def apply_list doc, data_list
      # child placement
      placement = 'after'
      # clean the html, removing spaces and returns
      doc.inner_html = doc.inner_html.strip
      # grab the first element before we remove the rest
      first_elem = doc.children.first
      # remove all the children
      doc.children.each_with_index do |node, index|
        if "#{node}"['data-scope']
          placement = (index == 0 ? 'after' : 'before')
        else
          node.remove
        end
      end

      # loop through the data list and create and element for each
      data_list.each do |data|
        # dup the element
        elem = first_elem.dup

        # lets look for data-prop elements
        elem.traverse do |x|
          if x.attributes.keys.include? 'data-prop'
            value = data[x.attr('data-prop').to_s.to_sym]

            if value.is_a? Proc
              x.inner_html = if value.parameters.length > 0
                instance.instance_exec(data, &value).to_s
              else
                instance.instance_exec(&value).to_s
              end
            else
              x.inner_html = value.to_s
            end
          end
        end

        # add the element back to the doc
        doc.children.public_send(placement, elem)
      end

      doc
    end
  end
end
