class GenerateTable < ApplicationInteraction
  string :target

  array :filters, default: [] do
    hash do
      string :attribute
      array :nodes, default: nil do
        string
      end
    end
  end

  array :annotations, default: [] do
    hash do
      string :attribute
      string :node, default: nil
    end
  end

  array :queries do
    string
  end

  def execute
    # replace with child categories
    annotations = self.annotations.map do |annotation|
      table = Attribute.from_api(annotation[:attribute]).table
      node = annotation.delete(:node)
      annotation.tap { |x| x[:nodes] = node ? table.sub_categories(node) : table.default_categories }
    end

    DataFrame.new(target, queries, filters + annotations)
  end
end
