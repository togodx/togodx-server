# frozen_string_literal: true

class Relation
  class DropTable < ApplicationInteraction
    string :source
    string :target

    def execute
      pair = [source, target].sort
      pair_rev = pair.reverse

      execute_sql <<~SQL
        DROP VIEW IF EXISTS relation#{Relation.from_pair(*pair_rev).id};
      SQL
      execute_sql <<~SQL
        DROP TABLE IF EXISTS relation#{Relation.from_pair(*pair).id};
      SQL
    end

    private

    def execute_sql(sql)
      STDERR.puts sql
      ActiveRecord::Base.connection.execute sql
    end
  end
end
