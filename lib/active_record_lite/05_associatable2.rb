require "debugger"
require_relative '04_associatable'

# Phase V
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)

    through_options = self.assoc_options[through_name]

    define_method(name) do
      source_options = through_options.model_class.assoc_options[source_name]

      # debugger

      # parse_all(
        # through_options.model_class
        #   .select("#{source_options.table_name}.*")
        #   .joins("#{source_options.table_name} ON ")
        #   .first

        # .joins(source_options.send(:name))
       sql =  "SELECT
                #{through_options.table_name}.*
              FROM
                #{through_options.table_name}
              JOIN
                #{source_options.table_name} ON #{through_options.table_name}.#{source_options.send(:foreign_key)} = #{source_options.table_name}.#{source_options.send(:primary_key)}
              WHERE
                #{through_options.table_name}.id = #{self.id}"

      parse_all(DBConnection.execute(sql))

    end

    # define_method(options.send(:name)) do
    #   options
    #     .model_class
    #     .where(primary_key_name => self.send(foreign_key_name))
    #     .first

    # class Cat < SQLObject
    #   my_attr_accessible :id, :name, :owner_id
    #   my_attr_accessor :id, :name, :owner_id
    #
    #   belongs_to :human, :foreign_key => :owner_id
    #   has_one_through :home, :human, :house
    # end

    # class Human < SQLObject
    #   self.table_name = "humans"
    #
    #   my_attr_accessible :id, :fname, :lname, :house_id
    #   my_attr_accessor :id, :fname, :lname, :house_id
    #
    #   has_many :cats, :foreign_key => :owner_id
    #   belongs_to :house
    # end
    #
    # class House < SQLObject
    #   my_attr_accessible :id, :address, :house_id
    #   my_attr_accessor :id, :address, :house_id
    #
    #   has_many :humans
    # end


  end
end
