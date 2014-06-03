module Dominate
  class Instance < Struct.new(:instance, :config)
    def method_missing method, *args, &block
      if config.respond_to? method
        config.send method
      elsif instance.respond_to? method
        instance.send method
      else
        super
      end
    end
  end
end
