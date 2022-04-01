require 'activerecord-import'
require 'thor'
require 'tempfile'
require 'tmpdir'
require_relative '../dag'
require_relative '../util/record_reader'

class ClassificationTask < Thor
  include Thor::Actions

  namespace 'togodx:classification'

  class << self
    def exit_on_failure?
      true
    end
  end

  desc 'drop', 'Drop a classification'
  option :api, aliases: '-a', type: :string, required: true, desc: 'API name for the attribute'

  def drop
    require_relative '../../config/environment'

    ActiveRecord::Base.connection.execute <<~SQL
      DROP TABLE IF EXISTS table#{Attribute.from_api(options[:api]).id};
    SQL
  end

  desc 'import <FILE>', 'Import a classification'
  option :api, aliases: '-a', type: :string, required: true, desc: 'API name for the attribute'
  option :dag_to_tree, type: :boolean, desc: 'Convert DAG(directed acyclic graph) to tree'
  option :format, aliases: '-f', type: :string, desc: 'File format', enum: %w[csv tsv json]

  def import(file = '-')
    require_relative '../../config/environment'

    check_table

    tmpdir = Dir.mktmpdir

    format = options[:format] || File.extname(file)[1..] || raise("No value provided for options '--format'")
    file = File.absolute_path(file)

    inside tmpdir, verbose: true do
      # TODO: implement dag2tree in nested set indexer
      if options[:dag_to_tree]
        say "Converting dag to tree"
        data = RecordReader.open(file, format: format).records.map(&:to_h)

        file = Tempfile.open('', tmpdir) do |f|
          tree = Dag.new(data).to_tree
          f << tree.to_json
          f.path || 'tree.json'
        end

        format = 'json'
      end

      say "Indexing for nested set"
      output = Tempfile.new('', tmpdir).path || 'index.json'
      time = Benchmark.realtime do
        cmd = []
        cmd << Rails.root.join('vendor/bin/nested_set_indexer')
        cmd << "--format #{format}"
        cmd << "--output #{output}"
        cmd << file

        run cmd.join(' ')
      end
      say "  -> #{'%.3f' % time} sec"

      total = 0
      ActiveRecord::Base.transaction do
        table = create_table

        say "Importing classification"
        time = Benchmark.realtime do
          RecordReader.open(output, format: format).records.each_slice(1000) do |g|
            records = g.map do |hash|
              {
                classification: hash[:id],
                classification_label: hash[:label],
                classification_parent: hash[:parent],
                leaf: hash[:leaf],
                lft: hash[:lft],
                rgt: hash[:rgt],
                count: hash[:count],
              }
            end
            table.import records
            total += records.size
          end
        end
        say "  -> #{'%.3f' % time} sec"

        say "Updating parent ID"
        time = Benchmark.realtime do
          update_parent_id
        end
        say "  -> #{'%.3f' % time} sec"
      end

      say "Imported #{total} #{'classification'.pluralize(total)}"
    end
  ensure
    FileUtils.remove_entry tmpdir if tmpdir && Dir.exist?(tmpdir)
  end

  private

  no_commands do
    def check_table
      begin
        table = Attribute.from_api(options[:api]).table
        table.first
        warn "Table for #{options[:api]} already exists. Drop the table by `#{$0} classification drop --api #{options[:api]}`, first."
        exit(false)
      rescue ActiveRecord::StatementInvalid
        # Table does not exist
      end
    end

    def create_table
      attribute = Attribute.from_api(options[:api])
      schema = File.read(Rails.root.join('db', 'schema.rb'))

      template_table = attribute.datamodel.underscore.pluralize
      m = schema.match(/^\s*create_table "#{template_table}".*?end$/m)
      raise RuntimeError, 'Failed to obtain migration definition' unless m

      table = "table#{attribute.id}"
      ActiveRecord::Migration.class_eval do
        eval m[0].gsub(template_table, table)
      end

      Class.new(attribute.datamodel.classify.constantize) do |klass|
        klass.table_name = table

        def klass.model_name
          ActiveModel::Name.new(self, nil, "temp")
        end
      end
    end

    def update_parent_id
      attribute = Attribute.from_api(options[:api])
      table = "table#{attribute.id}"

      ActiveRecord::Base.connection.execute <<~SQL
        UPDATE #{table}
        SET parent_id = (
          SELECT parent.id
          FROM #{table} parent
          WHERE #{table}.classification_parent = parent.classification
          ORDER BY parent.id
          LIMIT 1
        )
        WHERE EXISTS(
          SELECT 1
          FROM #{table} parent
          WHERE #{table}.classification_parent = parent.classification
          AND #{table}.classification_parent IS NOT NULL
        );
      SQL
    end
  end
end
