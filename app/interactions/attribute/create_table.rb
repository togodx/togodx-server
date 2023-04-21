# frozen_string_literal: true

class Attribute
  class CreateTable < ApplicationInteraction
    string :key

    def execute
      return if table.present?

      attribute = Attribute.from_key(key)
      schema = File.read(Rails.root.join('db', 'schema.rb'))

      template_table = attribute.datamodel.underscore.pluralize
      m = schema.match(/^\s*create_table "#{template_table}".*?end$/m)
      raise RuntimeError, 'Failed to obtain migration definition' unless m

      table = "table#{attribute.id}"
      disable_stdout do
        ActiveRecord::Migration.class_eval do
          eval m[0].gsub(template_table, table)
        end
      end

      attribute.table
    end

    private

    def table
      begin
        table = Attribute.from_key(key).table
        table.first
        logger.warn(self.class) { "Table for #{key} already exists. Drop the table by `#{$0} attribute drop #{key}`, first." }

        table
      rescue ActiveRecord::StatementInvalid
        nil
      end
    end
  end
end
