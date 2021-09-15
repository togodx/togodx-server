class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def truncate_table
      sql = case ActiveRecord::Base.connection.adapter_name
            when 'SQLite'
              "DELETE FROM #{table_name}; DELETE FROM sqlite_sequence WHERE name = '#{table_name}'; VACUUM;"
            else
              "TRUNCATE TABLE #{table_name};"
            end

      ActiveRecord::Base.connection.execute sql
    end
  end
end
