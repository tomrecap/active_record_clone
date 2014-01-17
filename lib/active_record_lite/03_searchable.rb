require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    where_line = []
    params.each { |key, value| where_line << "#{key} = '#{value}'" }

    sql = "
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line.join(" AND ")}
    "

    parse_all(DBConnection.execute(sql))
  end
end

class SQLObject
  extend Searchable
end
