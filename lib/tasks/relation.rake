namespace :relation do
  require 'faraday'

  desc 'Load ID mapping to database'
  task load: :environment do
    Rails.logger = Logger.new(STDERR)
    ActiveRecord::Base.logger = nil

    Relation.truncate_table

    %w[ensembl_gene ncbigene uniprot chebi].permutation(2).each do |src, dst|
      Rails.logger.info('Rake') { "Retrieving ID mapping for `#{src}` to `#{dst}`" }

      time = Benchmark.realtime do
        ids = Attribute.datasets(src).classifications.flat_map do |attribute|
          attribute.table.select(:classification).distinct.where(leaf: true).map(&:classification)
        end.uniq

        ids.each_slice(1000) do |g|
          response = Faraday.new(url: 'https://integbio.jp').post('/togosite/sparqlist/api/togoid_route_sparql') do |req|
            req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
            req.body = URI.encode_www_form({ source: src, target: dst, ids: g.join(',') })
          end

          Relation.import %i[db1 entry1 db2 entry2], JSON.parse(response.body).map { |hash| [src, hash['source_id'], dst, hash['target_id']] }
        end
      end

      Rails.logger.info('Rake') { "  import ID mapping: #{'%.3f' % time} sec" }
    end
  end
end
