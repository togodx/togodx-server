class ApplicationInteraction < ActiveInteraction::Base
  def disable_stdout
    $stdout = File.new( '/dev/null', 'w' )
    yield
  ensure
    $stdout = STDOUT
  end

  def logger
    @logger ||= Logger.new(STDERR)
  end

  def cache_dir
    @cache_dir ||= Rails.root.join('tmp', 'cache').tap { |dir| FileUtils.mkdir_p dir }
  end
end
