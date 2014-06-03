module Dominate
  class Scope < Struct.new :instance, :config, :root_doc

    def apply data, &block
      root_doc.each do |doc|
        if data.is_a? Array
          doc = apply_list doc, data, &block
        else
          doc = apply_data doc, data, &block
        end
      end

      root_doc
    end

    def apply_instance
      root_doc.traverse do |x|
        if defined?(x.attributes) && x.attributes.keys.include?('data-instance')
          method  = x.attr 'data-instance'

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

    def apply_data doc, data, &block
      data = data.to_deep_ostruct

      doc.traverse do |x|
        if x.attributes.keys.include? 'data-prop'
          prop_val = x.attr('data-prop').to_s

          x.inner_html = value_for(
            data.instance_eval(prop_val), data, doc
          )
        end
      end
    end

    def apply_list doc, data_list, &block
      # child placement
      placement = 'add_child'
      # clean the html, removing spaces and returns
      doc.inner_html = doc.inner_html.strip
      # grab the first element before we remove the rest
      first_elem = doc.children.first
      # remove all the children
      doc.children.each_with_index do |node, index|
        if "#{node}"['data-scope']
          placement = (index == 0 ? 'add_child' : 'before')
        else
          node.remove
        end
      end

      # loop through the data list and create and element for each
      data_list.each do |data|
        # dup the element
        elem = first_elem.dup

        data = data.to_deep_ostruct if data.is_a? Hash

        # lets look for data-prop elements
        elem.traverse do |x|
          if x.attributes.keys.include? 'data-prop'
            prop_val = x.attr('data-prop').to_s

            if prop_val.length > 0
              value = value_for data.instance_eval(prop_val), data, elem
            else
              value = value_for data, data, elem
            end
            x.inner_html = value
          end
        end

        block.call elem, data if block

        # add the element back to the doc
        if placement == 'add_child'
          doc.add_child elem
        elsif placement == 'before'
          doc.children.before elem
        end
      end

      doc
    end

    private

    def value_for value, data, elem
      if value.is_a? Proc
        if value.parameters.length == 0
          Instance.new(instance, config).instance_exec(&value).to_s
        elsif value.parameters.length == 1
          Instance.new(instance, config).instance_exec(data, &value).to_s
        elsif value.parameters.length == 2
          Instance.new(instance, config).instance_exec(data, elem, &value).to_s
        end
      else
        value.to_s
      end
    end
  end
end
