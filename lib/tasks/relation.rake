# @deprecated
# TODO: migrate to togodx-human
namespace :relation do
  require 'faraday'

  desc 'Load ID mapping to database'
  task retrieve_cache: :environment do
    Rails.logger = Logger.new(STDERR)
    ActiveRecord::Base.logger = nil

    Relation.datasets.each do |src, dst|
      Rails.logger.info('Rake') { "Retrieving ID mapping for `#{src}` to `#{dst}`" }

      time = Benchmark.realtime do
        ids = Attribute.datasets(src)
                       .classifications
                       .flat_map { |attr| attr.table.distinct.where(leaf: true).pluck(:classification) }.uniq
        Rails.logger.info('Rake') { "  unique identifiers: #{ids.count}" }

        CSV.open("relation_#{src}_#{dst}.csv", 'w') do |csv|
          csv << %w[source target]

          n = 100
          ids.each_slice(n).with_index do |g, i|
            begin
              response = connection.post('/togosite/sparqlist/api/togoid_route_sparql') do |conn|
                conn.headers['Content-Type'] = 'application/x-www-form-urlencoded'
                conn.body = URI.encode_www_form({ source: src, target: dst, ids: g.join(',') })
              end

              JSON.parse(response.body).each do |hash|
                csv << [hash['source_id'], hash['target_id']]
              end

              Rails.logger.info('Rake') { "  #{n * i + g.count}/#{ids.count}" }
            rescue => e
              Rails.logger.error('Rake') { "Requested identifiers: #{g.join(',')}" }
              Rails.logger.error('Rake') { "Error: #{e.respond_to?(:inspect) ? e.inspect : e}" }
              raise e
            end
          end
        end
      end

      Rails.logger.info('Rake') { "  retrieve ID mapping: #{'%.3f' % time} sec" }
    end
  end

  def connection
    @connection ||= Faraday.new(url: 'https://integbio.jp') do |builder|
      builder.adapter :net_http_persistent do |http|
        http.idle_timeout = 300
        http.read_timeout = 1.hour
      end

      builder.request :retry, {
        methods: [],
        exceptions: [
          Errno::ETIMEDOUT,
          'Timeout::Error',
          Faraday::ClientError, # 4xx
          Faraday::ServerError, # 5xx
          Faraday::RetriableResponse,
          Faraday::ConnectionFailed,
        ],
        retry_if: -> (env, _exception) {
          env.status == 404 || !(400..499).include?(env.status)
        },
        retry_block: -> (env, _options, retries, e) {
          Rails.logger.debug('Rake') { "  retry request - status: #{env.status}, message: #{e.message}, remain: #{retries}" }
        },
        interval: 2,
        backoff_factor: 2,
        max: 5,
      }

      builder.response :raise_error
    end
  end
end
