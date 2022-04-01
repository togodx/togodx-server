require 'activerecord-import'

apis = Attribute.all.pluck(:api)
attributes = YAML.load_file(File.expand_path(File.join('..', 'seeds', 'attributes.yml'), __FILE__))
                 .reject { |x| apis.include? x['api'] }

Attribute.import attributes
