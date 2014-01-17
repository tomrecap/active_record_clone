require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
  )


  def model_class
    ActiveSupport::Inflector.inflections do |inflect|
      inflect.plural 'human', 'humans'
    end

    self.class_name.constantize
  end

  def table_name
    self.class_name.tableize
  end
end

class BelongsToOptions < AssocOptions
  attr_reader :name, :class_name, :foreign_key, :primary_key

  def initialize(name, options = {})
    @name = name
    @class_name =   options[:class_name] ||
                    name.to_s.camelcase.singularize
    @foreign_key =  options[:foreign_key] ||
                    "#{name}_id".to_sym
    @primary_key =  options[:primary_key] ||
                    :id
  end
end

class HasManyOptions < AssocOptions
  attr_accessor :name, :class_name, :foreign_key, :primary_key

  def initialize(name, self_class_name, options = {})
    @name = name
    @class_name =   options[:class_name] ||
                    name.to_s.camelcase.singularize
    @foreign_key =  options[:foreign_key] ||
                    self_class_name.foreign_key.to_sym
    @primary_key =  options[:primary_key] ||
                    :id
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    foreign_key_name = options.send(:foreign_key)

    define_method(options.send(:name)) do
      options.model_class
        .where(:id => self.send(foreign_key_name))
        .first
    end

  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, name.constantize.to_s, options)
    foreign_key_name = options.send(:foreign_key)

    define_method(options.send(:name)) do
      options.model_class
        .where(:id => self.send(foreign_key_name))
      end


    # class House < SQLObject
    #   my_attr_accessible :id, :address, :house_id
    #   my_attr_accessor :id, :address, :house_id
    #
    #   has_many :humans
    # end
  end

  def assoc_options
    # Wait to implement this in Phase V. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
