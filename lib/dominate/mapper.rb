require 'ox'

module Dominate
  module Mapper
    autoload :Handler, 'dominate/mapper/handler'
    autoload :Parser,  'dominate/mapper/parser'
    autoload :Element, 'dominate/mapper/element'

    def self.new
      Parser.new
    end
  end
end
