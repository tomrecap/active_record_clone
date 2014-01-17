require "debugger"
require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    results.map do |object_hash|
      new_object = self.new

      object_hash.each do |attribute, value|
        new_object.send("#{attribute}=", value)
      end

      new_object
    end

  end
end

class SQLObject < MassObject
  def self.table_name=(table_name)
    @table_name = table_name
    # @table_name ||= self.class.to_s.pluralize.underscore
  end

  def self.table_name
    @table_name || self.to_s.pluralize.underscore
  end

  def self.all
    sql = " SELECT
              *
            FROM
              #{self.table_name}  "

    parse_all(DBConnection.execute(sql))
  end

  def self.find(id)
    sql = " SELECT
              *
            FROM
              #{self.table_name} t
            WHERE
              t.id = ?  "

    parse_all(DBConnection.execute(sql, id)).first
  end

  def insert
    col_names = self.class
                    .attributes
                    .sort
                    .reject { |attribute| attribute == :id }
                    .join(", ")
    question_marks = ["?"] * (self.class.attributes.count - 1)

    sql = " INSERT INTO
              #{self.class.table_name} (#{col_names})
            VALUES
              (#{question_marks.join(', ')}) "

    DBConnection.execute(sql, self.attribute_values.compact)
    @id = DBConnection.instance.last_insert_row_id
  end

  def attribute_values
    self.class.attributes.sort.map do |attribute|
      # next if attribute == :id
      self.send(attribute.to_sym)
    end
  end

  def save

    !!self.id ? update : insert

  end

  def update
    col_names_and_question_marks = self.class
                    .attributes
                    .sort
                    .reject { |attribute| attribute == :id }
                    .map { |col| "#{col} = ?" }
                    .join(", ")


    sql = " UPDATE
              #{self.class.table_name}
            SET
              #{col_names_and_question_marks}
            WHERE
              id = ? "

              # debugger
    DBConnection.execute(sql, self.attribute_values_without_id, self.id)
  end

  def attribute_values_without_id
    self.class.attributes.sort.map do |attribute|
      next if attribute == :id
      self.send("#{attribute}")
    end.compact
  end

end
