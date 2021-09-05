# coding: utf-8
class ApplicationController < ActionController::API
  def dispatch_breakdown
    # TODO: rename to attribute? api_id => attribute_id
    attribute = params[:api]
    # TODO: rename to params[:node]
    node = params[:categoryIds]
    mode = params[:mode]
    table = select_table(attribute)
    render json: table.breakdown(node, mode)
  end

  # togokey_table_data
  def generate_dataframe
    __fill_test_data__

    # TODO: rename to target? subject? map_to? togokey?
    target = params[:togoKey]
    # TODO: rename to params[:filters]
    filters = JSON.parse(params[:properties])

    # TODO: implement a logic to generate JSON of togokey_table_data
    # Need to care filters without conditions for "Map attribute"
    render json: aggregate_identifiers(target, filters)
  end

  # togokey_filter
  def aggregate_identifiers(target, filters)
    idsets = filters.select{|x| x.has_key?("categoryIds")}.map do |hash|
      entries = []
      # TODO: rename to hash["attribute"]
      attribute = hash["propertyId"]
      # TODO: rename to hash["conditions"]
      conditions = hash["categoryIds"]
      source = Attribute.api_dataset(attribute)
      table = select_table(attribute)
      conditions.each do |condition|
        # OR (within a same attribute)
        entries += table.entries(condition)
      end
      if source != target
        entries = Relation.convert(source, target, entries)
      end
      entries.uniq
    end
    idsets.sort! {|a, b| a.size <=> b.size}
    idset = idsets.shift
    # AND (among different attributes)
    while idsets.size > 0
      other = idsets.shift
      idset = idset.intersection(other)
    end
    idset
  end

  # TODO: this fails to swith table between Classification instances
  # in aggregate_identifiers (works in dispatch_breakdown)...
  # Even though the table_name is set to 4, SQL queries table1, strange.
  #
  # *** select_table *** attribute: protein_cellular_component_uniprot, id: 4, datamodel: Classification, table: table4
  # Load (0.0ms)  SELECT "table1".* FROM "table1" WHERE "table1"."classification" = ? LIMIT ?  [["classification", "GO_1990351"], ["LIMIT", 1]]
  # ↳ app/models/classification.rb:23:in `entries'
  # Completed 404 Not Found in 62ms (ActiveRecord: 32.4ms | Allocations: 70007)
  # ActiveRecord::RecordNotFound (Couldn't find ):
  def select_table(attribute)
    id = Attribute.api_id(attribute)
    datamodel = Attribute.api_datamodel(attribute)
    case datamodel
    when "Classification"
      table = Classification.select_table(id)
    when "Distribution"
      table = Distribution.select_table(id)
    end
    $stderr.puts "*** select_table *** attribute: #{attribute}, id: #{id}, datamodel: #{datamodel}, table: #{table.class.table_name}"
    return table
  end

  def __fill_test_data__
    #params[:togoKey] = "ensembl_gene"
    params[:togoKey] = "ncbigene"
    # OK params[:properties] = '[{"propertyId":"protein_molecular_mass_uniprot","categoryIds":["10-20"]},{"propertyId":"gene_high_level_expression_refex"}]'
    params[:properties] = '[{"propertyId":"protein_cellular_component_uniprot","categoryIds":["GO_0000109"]},{"propertyId":"protein_molecular_mass_uniprot","categoryIds":["10-20"]},{"propertyId":"gene_high_level_expression_refex"}]'
    # NG params[:properties] = '[{"propertyId":"gene_chromosome_ensembl","categoryIds":["2"]},{"propertyId":"protein_cellular_component_uniprot","categoryIds":["GO_0000109"]},{"propertyId":"protein_molecular_mass_uniprot","categoryIds":["10-20"]},{"propertyId":"gene_high_level_expression_refex"}]'
    # NG params[:properties] = '[{"propertyId":"gene_chromosome_ensembl","categoryIds":["1","2","3"]},{"propertyId":"gene_high_level_expression_refex","categoryIds":["v34_40"]},{"propertyId":"protein_cellular_component_uniprot","categoryIds":["GO_1902494","GO_0043235"]},{"propertyId":"protein_molecular_mass_uniprot","categoryIds":["0-10","10-20"]},{"propertyId":"gene_high_level_expression_refex"}]'
  end
end
