require 'ostruct'

class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr(" ", "_").
    tr("-", "_").
    downcase
  end
end

class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end

  def present?
    !blank?
  end
end

class DeepOpenStruct < OpenStruct
  def initialize hash = nil

    @table = {}
    @hash_table = {}

    hash = [hash] unless hash.is_a? Hash

    if hash
      hash.each do |k,v|

        if v.is_a? Array
          @table[k.to_sym] ||= []

          v.each { | entry |
            @table[k.to_sym] << entry
          }
        else
          @table[k.to_sym] = (v.is_a?(Hash) ? self.class.new(v) : v)
          @hash_table[k.to_sym] = v
          new_ostruct_member(k)
        end
      end
    end
  end

  def to_h
    @hash_table
  end
end

class Hash
  def to_deep_ostruct
    DeepOpenStruct.new self
  end
end
