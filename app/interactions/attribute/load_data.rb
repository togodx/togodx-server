# frozen_string_literal: true

require 'open3'

class Attribute
  class LoadData < ApplicationInteraction
    string :key
    hash :import do
      string :url
      string :method, default: 'get'
      hash :headers, default: {}, strip: false
      string :body, default: nil
      string :data_type, default: 'auto'
    end
    boolean :ontology, default: false
    hash :metadata, default: {}, strip: false
    interface :table, methods: %i[import]
    interface :file, methods: %i[to_s]

    def execute
      attribute = Attribute.from_key(key)

      send("load_#{attribute.datamodel}")

      if attribute.datamodel == Attribute::DataModel::CLASSIFICATION
        attribute.update!(hierarchy: attribute.table.is_hierarchy)
      end
    end

    private

    def load_classification
      tmpdir = Dir.mktmpdir

      format = File.extname(file)[1..] || raise('Failed to obtain file extension')

      FileUtils.cd tmpdir do
        logger.info(self.class) { 'Indexing for nested set' }

        output = Tempfile.new('', tmpdir).path || 'index.tsv'
        time = Benchmark.realtime do
          cmd = []
          cmd << Rails.root.join('vendor/bin/nested_set_indexer')
          cmd << '--complement-leaf' if ontology
          cmd << "--from #{format}"
          cmd << '--to tsv'
          cmd << "--output #{output}"
          cmd << File.absolute_path(file)

          exec_external_command(*cmd)
        end
        logger.info(self.class) { "  -> #{'%.3f' % time} sec" }

        logger.info(self.class) { 'Loading classification' }

        format = 'tsv'
        total = 0
        time = Benchmark.realtime do
          ActiveRecord::Base.transaction do
            RecordReader.open(output, format: format).records.each_slice(1000) do |g|
              records = g.map do |hash|
                {
                  id: hash[:pid],
                  classification: hash[:classification],
                  classification_label: hash[:classification_label],
                  classification_parent: hash[:classification_parent],
                  leaf: hash[:leaf],
                  parent_id: hash[:parent_id],
                  lft: hash[:lft],
                  rgt: hash[:rgt],
                  count: hash[:count],
                }
              end
              table.import records
              total += records.size
            end
          end

        end

        logger.info(self.class) { "  -> #{'%.3f' % time} sec" }
        logger.info(self.class) { "Loaded #{total} #{'row'.pluralize(total)}" }
      end
    ensure
      FileUtils.remove_entry tmpdir if tmpdir && Dir.exist?(tmpdir)
    end

    def load_distribution
      format = File.extname(file)[1..] || raise('Failed to obtain file extension')

      logger.info(self.class) { 'Loading distribution' }

      total = 0
      time = Benchmark.realtime do

        ActiveRecord::Base.transaction do
          RecordReader.open(file, format: format).records.each_slice(1000) do |g|
            records = g.map do |hash|
              {
                distribution: hash[:id],
                distribution_label: hash[:label],
                distribution_value: hash[:value],
                bin_id: hash[:binId],
                bin_label: hash[:binLabel]
              }
            end
            table.import records
            total += records.size
          end
        end

      end

      logger.info(self.class) { "  -> #{'%.3f' % time} sec" }
      logger.info(self.class) { "Loaded #{total} #{'row'.pluralize(total)}" }
    end

    def exec_external_command(*cmd)
      Open3.popen3(cmd.join(' ')) do |stdin, stdout, stderr, wait_thr|
        stdin.close_write

        begin
          loop do
            IO.select([stdout, stderr]).flatten.compact.each do |io|
              io.each do |line|
                next if line.nil? || line.empty?
                logger.info(self.class) { line }
              end
            end

            break if stdout.eof? && stderr.eof?
          end
        rescue EOFError
          # Ignored
        end
      end
    end
  end
end
