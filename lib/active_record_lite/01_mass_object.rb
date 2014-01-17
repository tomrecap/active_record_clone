require "debugger"
require_relative '00_attr_accessor_object.rb'

class MassObject < AttrAccessorObject
  def self.my_attr_accessible(*new_attributes)
    self.attributes.concat(new_attributes)
  end

  def self.attributes
    if self == MassObject
      raise "must not call #attributes on MassObject directly"
    else
      @attributes ||= []
    end
  end

  def initialize(params = {})
    params.each do |param, value|
      unless self.class.attributes.include?(param.to_sym)
        raise "mass assignment to unregistered attribute '#{param}'"
      end

      self.send("#{param}=", value)

    #   if @accessible_attributes.include?(param.key)
    #     self.send(param.key.to_sym, param.val)
    #   end
    end
    # # @attributes = params
  end
end
