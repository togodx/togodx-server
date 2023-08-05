# frozen_string_literal: true

class Attribute
  class FetchData < ApplicationInteraction
    string :key
    hash :import do
      string :url
      string :method, default: 'get'
      hash :headers, default: {}, strip: false
      string :body, default: nil
      string :data_type, default: 'auto'
    end
    hash :metadata, default: {}, strip: false

    def execute
      if (cache = cache_file).present? && cache.exist?
        logger.info(self.class) { "Cached data found: #{cache.relative_path_from(Rails.root)}" }
        return cache
      end

      return if response.blank?

      unless response.success?
        message = format "%{uri} returned status %{status} %{reason_phrase}: %<time>.3f sec\n%{body}",
                         uri:,
                         status: response.status || '`nil`',
                         reason_phrase: response.reason_phrase,
                         time: @time || 0,
                         body: response.body || 'Empty body'

        errors.add(:base, message) and return
      end

      return unless save_response

      logger.info(self.class) { "  succeeded: #{'%.3f' % @time || 0} sec" }

      cache_file
    end

    private

    def cache_file
      dir = (cache_dir / 'attributes').tap { |dir| FileUtils.mkdir_p dir unless dir.exist? }

      (path = Dir.glob(dir / "#{key}.*").first) or return

      Pathname.new(path)
    end

    def connection
      logger.info(self.class) { "Retrieving from #{uri}" }

      Faraday.new(
        url: uri.merge('/'),
        headers: import[:headers]
      )
    end

    def metadata
      inputs[:metadata].symbolize_keys.merge(key:)
    end

    def uri
      @uri ||= URI.parse(format(import[:url], metadata))
    end

    def response
      @response ||= begin
                      res = nil

                      case import[:method]
                      when /get/i
                        @time = Benchmark.realtime do
                          res = connection.get(uri.request_uri) do |req|
                            req.options.timeout = 1.hour
                          end
                        end

                        res
                      when /post/i
                        @time = Benchmark.realtime do
                          res = connection.post(uri.request_uri) do |req|
                            req.options.timeout = 1.hour
                            req.body = format(import[:body], metadata) if import[:body].present?
                          end
                        end

                        res
                      else
                        errors.add('import.method', 'is invalid') and return
                      end
                    end
    end

    def extension
      return import[:data_type] if %w[json srj csv tsv].include?(import[:data_type])

      if (content_type = response.headers['content-type']).blank?
        raise ArgumentError, 'Response content type is empty, specify import.data_type in config/attributes.yml'
      end

      case content_type
      when %r[application/json]
        'json'
      when %r[application/sparql-results+json]
        'srj'
      when %r[text/csv]
        'csv'
      when %r[text/tab-separated-values], %r[text/plain]
        'tsv'
      else
        raise ArgumentError, "Unsupported content type: #{content_type}, specify import.data_type in config/attributes.yml"
      end
    end

    def save_response
      file_name = cache_dir / 'attributes' / "#{key}.#{extension}"

      begin
        File.open(file_name, 'w') do |f|
          response.body.split("\n")&.each do |x|
            begin
              f.puts x
            rescue Encoding::UndefinedConversionError => e
              f.puts((safe = x.force_encoding('UTF-8')))
              logger.warn(self.class) { "  #{e.message}" }
              logger.warn(self.class) { "    error_char: #{e.error_char}" }
              logger.warn(self.class) { "        source: #{x}" }
              logger.warn(self.class) { "     converted: #{safe}" }
            end
          end
        end
      rescue => e
        FileUtils.rm(cache_file) if File.exist?(cache_file)
        errors.add(:base, e.message) and return false
      end

      true
    end
  end
end
