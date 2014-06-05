module Dominate
  class Instance
    def initialize instance, config
      @__config__   = config
      @__instance__ = instance

      instance.instance_variables.each do |name|
        instance_variable_set name, instance.instance_variable_get(name)
      end

      instance
    end

    def method_missing method, *args, &block
      if @__config__.respond_to? method
        @__config__.send method, *args, &block
      elsif @__instance__.respond_to? method, *args, &block
        @__instance__.send method, *args, &block
      else
        @__instance__.send 'method_missing', method, *args, &block
      end
    end
  end
end
