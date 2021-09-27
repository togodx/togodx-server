namespace :relation do
  require 'faraday'

  desc 'Load ID mapping to database'
  task load: :environment do
    Rails.logger = Logger.new(STDERR)
    ActiveRecord::Base.logger = nil

    #Relation.truncate_table

    connection = Faraday.new(url: 'https://integbio.jp') do |builder|
      builder.adapter :net_http_persistent do |http| # yields Net::HTTP::Persistent
        http.idle_timeout = 300
        http.read_timeout = 1.hour
      end
    end

    pair = Attribute.select(:dataset).distinct.pluck(:dataset).permutation(2).to_a -
      Relation.select(:db1, :db2).distinct.pluck(:db1, :db2)

    pair.each do |src, dst|
      Rails.logger.info('Rake') { "Retrieving ID mapping for `#{src}` to `#{dst}`" }

      time = Benchmark.realtime do
        ids = Attribute.datasets(src).classifications.flat_map do |attribute|
          attribute.table.select(:classification).distinct.where(leaf: true).map(&:classification)
        end.uniq
        Rails.logger.info('Rake') { "  unique identifiers: #{ids.count}" }

        ActiveRecord::Base.transaction do
          ids.each_slice(100) do |g|
            response = connection.post('/togosite/sparqlist/api/togoid_route_sparql') do |conn|
              conn.headers['Content-Type'] = 'application/x-www-form-urlencoded'
              conn.body = URI.encode_www_form({ source: src, target: dst, ids: g.join(',') })
            end

            Relation.import %i[db1 entry1 db2 entry2], JSON.parse(response.body).map { |hash| [src, hash['source_id'], dst, hash['target_id']] }
          end
        end
      end

      Rails.logger.info('Rake') { "  import ID mapping: #{'%.3f' % time} sec" }
    end
  end
end
