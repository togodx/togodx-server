require 'activerecord-import'

attributes = YAML.load_file(File.expand_path(File.join('..', 'seeds', 'attributes.yml'), __FILE__))

Attribute.import attributes
