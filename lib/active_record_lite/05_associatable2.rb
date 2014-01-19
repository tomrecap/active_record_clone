require "debugger"
require_relative '04_associatable'

# Phase V
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)

    through_options = self.assoc_options[through_name]

    define_method(name) do
      source_options = through_options.model_class.assoc_options[source_name]

       sql =  "SELECT
                #{source_options.table_name}.*
              FROM
                #{through_options.table_name}
              JOIN
                #{source_options.table_name} ON #{through_options.table_name}.#{source_options.send(:foreign_key)} = #{source_options.table_name}.#{source_options.send(:primary_key)}
              WHERE
                #{through_options.table_name}.id = #{self.send(through_options.send(:foreign_key))}"

      matching_rows = DBConnection.execute(sql)
      target_object = source_options.model_class.new(matching_rows.first)
    end
  end
end
