# coding: utf-8
class ApplicationController < ActionController::API
  def dispatch_breakdown
    attribute = params[:api]     # rename to attribute? api_id => attribute_id
    node = params[:categoryIds]  # params[:node]
    mode = params[:mode]
    table = select_table(attribute)
    render json: table.breakdown(node, mode)
  end

  # togokey_table_data
  def generate_dataframe
    aggregate_identifiers
  end

  # togokey_filter
  def aggregate_identifiers
    params[:togoKey] = "ncbigene"
    params[:properties] = '[{"propertyId":"gene_chromosome_ensembl","categoryIds":["2"]},{"propertyId":"protein_cellular_component_uniprot","categoryIds":["GO_1990351"]},{"propertyId":"protein_molecular_mass_uniprot","categoryIds":["10-20"]},{"propertyId":"gene_high_level_expression_refex"}]'

    target = params[:togoKey]     # params[:dataset] primarykey? subject? target?
    filters = JSON.parse(params[:properties])  # params[:filters]
    idsets = filters.select{|x| x.has_key?("categoryIds")}.map do |hash|
      entries = []
      attribute = hash["propertyId"] # hash["attribute"]
      filter = hash["categoryIds"]   # hash["filter"]
      source = Attribute.api_dataset(attribute)
      # TODO: this doesn't seem to swith table...
      # >> select_table: attribute] protein_cellular_component_uniprot, id: 4, datamodel: Classification
      # >> condition: "GO_1990351"
      # Load (0.0ms)  SELECT "table1".* FROM "table1" WHERE "table1"."classification" = ? LIMIT ?  [["classification", "GO_1990351"], ["LIMIT", 1]]
      # ↳ app/models/classification.rb:23:in `entries'
      # Completed 404 Not Found in 62ms (ActiveRecord: 32.4ms | Allocations: 70007)
      # ActiveRecord::RecordNotFound (Couldn't find ):
      table = select_table(attribute)
      filter.each do |condition|
        # OR (within a same attribute)
        entries += table.entries(condition)
      end
      if source != target
        entries = Relation.convert(source, target, entries)
      end
      entries.uniq
    end
    # AND (among different attributes)
    idsets.sort! {|a, b| a.size <=> b.size}
    idset = idsets.shift
    while idset.size > 0
      other = idset.shift
      idset = idset.intersection(other)
    end
    idset
  end

  def select_table(attribute)
    id = Attribute.api_id(attribute)
    datamodel = Attribute.api_datamodel(attribute)
    $stderr.puts ">> select_table: attribute] #{attribute}, id: #{id}, datamodel: #{datamodel}"
    case datamodel
    when "Classification"
      table = Classification.select_table(id)
    when "Distribution"
      table = Distribution.select_table(id)
    end
    return table
  end
end
