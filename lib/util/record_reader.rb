require 'active_support/core_ext/hash/keys'
require 'csv'
require 'forwardable'
require 'json'

class RecordReader
  ACCEPTABLE_FORMATS = %w[csv tsv json]

  class << self
    # @param [String] path if "-" is given, use STDIN
    # @param [Hash] options the options for the reader
    # @option options [String] :format input format
    # @return [RecordReader]
    def open(path, **options)
      return from_stdin(**options) if path == '-'

      options[:format] ||= begin
                             ext = File.extname(path)[1..]
                             raise ArgumentError, "Unknown extension: #{ext}" unless ACCEPTABLE_FORMATS.include?(ext)
                             ext
                           end

      f = File.open(path)

      begin
        reader = new(f, **options)
      rescue => e
        f.close
        raise e
      end

      if block_given?
        begin
          yield reader
        ensure
          reader.close
        end
      else
        reader
      end
    end

    # @param [Hash] options the options for the reader
    # @option options [String] :format input format
    # @return [RecordReader]
    def from_stdin(**options)
      raise ArgumentError, 'options[:format] is required.' unless options[:format]

      reader = new(STDIN, **options)

      if block_given?
        yield reader
      else
        reader
      end
    end
  end

  extend Forwardable

  # @param [Object#read, String] data
  # @param [Hash] options the options for the reader
  # @option options [String] :format input format
  def initialize(data, **options)
    @io = if data.is_a?(String)
            StringIO.new(data)
          else
            data
          end

    @format = options[:format]

    raise ArgumentError, "Unknown format: #{@format}" unless ACCEPTABLE_FORMATS.include?(@format)
  end

  def_delegators :@io, :close

  # @return [Enumerator]
  def records
    send(@format)
  end

  private

  def json
    JSON.parse(@io.read)
        .map(&:symbolize_keys)
        .to_enum(:each)
  end

  def csv
    options = {
      headers: true,
      header_converters: :symbol,
      col_sep: @format == 'csv' ? ',' : "\t"
    }

    CSV.new(@io, **options)
  end

  alias tsv csv
end
