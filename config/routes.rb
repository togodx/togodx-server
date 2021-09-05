Rails.application.routes.draw do
  match '/breakdown/:api', to: 'application#dispatch_breakdown', via: [:get, :post]
#  match '/aggregate', to: 'application#aggregate_identifiers', via: [:get, :post]
  match '/dataframe', to: 'application#generate_dataframe', via: [:get, :post]

=begin
togoKey: hgnc
properties: [{"propertyId":"gene_chromosome_ensembl","categoryIds":["2"]},{"propertyId":"protein_cellular_component_uniprot","categoryIds":["GO_1990351"]},{"propertyId":"protein_molecular_mass_uniprot","categoryIds":["10-20"]},{"propertyId":"gene_high_level_expression_refex"}]
queryIds: ["47","1020","1404","1445","1965","3712","7684","7698","7707","10585","10588","10597","20823","37203"]

dataset: ncbigene
filters: [
  { "attribute": "gene_chromosome_ensembl",
    "filter": ["2", "3"] },
  { "attribute": "protein_cellular_component_uniprot",
    "filter": ["GO_0000109"] },
  { "attribute": "protein_molecular_mass_uniprot",
    "filter": ["10-20"] }
]
=end

end
