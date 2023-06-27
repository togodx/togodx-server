require 'activerecord-import'
require 'thor'

class RelationTask < Thor
  include Thor::Actions

  namespace 'togodx:relation'

  class << self
    def exit_on_failure?
      true
    end
  end

  desc 'import <FILE>', 'Import relations with csv, tsv or json'
  option :source, aliases: '-s', type: :string, required: true, desc: 'Source dataset'
  option :target, aliases: '-t', type: :string, required: true, desc: 'Target dataset'

  def import(file)
    require_relative '../../config/environment'

    Relation::EntryPoint.run!(source: options[:source], target: options[:target], file:)
  end

  desc 'drop', 'Drop a relation'
  option :source, aliases: '-s', type: :string, required: true, desc: 'Source dataset'
  option :target, aliases: '-t', type: :string, required: true, desc: 'Target dataset'

  def drop
    require_relative '../../config/environment'

    Relation::DropTable.run!(source: options[:source], target: options[:target])
  end

  desc 'drop_all', 'Drop all attributes'

  def drop_all
    require_relative '../../config/environment'

    Rails.configuration.togodx.dataset_pairs.each do |source, target|
      Relation::DropTable.run!(source:, target:)
    end
  end

  desc 'clear_cache', 'Clear cache'

  def clear_cache
    require_relative '../../config/environment'

    FileUtils.rm_rf ApplicationInteraction.new.cache_dir / 'relations'
  end
end
