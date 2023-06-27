# frozen_string_literal: true

class Relation
  class CreateTable < ApplicationInteraction
    string :source
    string :target

    def execute
      pair = [source, target].sort
      table_name = "relation#{relation(*pair).id}"

      ret = unless table(*pair).present?
        schema = File.read(Rails.root.join('db', 'schema.rb'))
        m = schema.match(/^\s*create_table "relation".*?end$/m)
        raise RuntimeError, 'Failed to obtain migration definition' unless m

        disable_stdout do
          ActiveRecord::Migration.class_eval do
            eval m[0].gsub('relation', table_name)
          end
        end

        true
      end

      unless table(*pair.reverse).present?
        case ActiveRecord::Base.connection.adapter_name
        when 'PostgreSQL'
          ActiveRecord::Base.connection.execute <<~SQL
            CREATE OR REPLACE VIEW "relation#{relation(*pair.reverse).id}" AS
            SELECT "id", "target" AS "source", "source" AS "target"
            FROM "#{table_name}";
          SQL
        when 'SQLite'
          ActiveRecord::Base.connection.execute <<~SQL
            CREATE VIEW IF NOT EXISTS "relation#{relation(*pair.reverse).id}" AS
            SELECT "id", "target" AS "source", "source" AS "target"
            FROM "#{table_name}";
          SQL
        else
          raise RuntimeError, 'Unsupported database adapter.'
        end
      end

      ret
    end

    private

    def relation(source, target)
      Relation.from_pair(source, target)
    end

    def table(source, target)
      begin
        table = relation(source, target).table
        table.first
        logger.warn(self.class) { "Relation for #{source} and #{target} already exists. Drop the table by `#{$0} relation drop --source=#{source} --target=#{target}`, first." }

        table
      rescue ActiveRecord::StatementInvalid
        nil
      end
    end
  end
end
