# TogoDX server

TogoDX server is the backend server for [TogoDX](https://github.com/togodx/togodx-app).

TogoDX (Togo Data eXplorer) is a framework to explore various databases integrated using a knowledge graph in the life
sciences. It integrates many datasets originating from different databases based on the compatibility of IDs that
indicate the same thing and ID relationships that organize the connections between different data. TogoDX aims to
provide a new mechanism for flexibly extracting data useful for data science by narrowing down the data by various
attributes of each data set.

## Prerequisites

* Ruby 3.0.2
* Ruby on Rails 6.1.3
* Either of the following
  * SQLite 3.8+
  * PostgreSQL 14+

## System dependencies

* [TogoDX](https://github.com/togodx/togodx-app)

### Use PostgreSQL instead of SQLite3 

1. Comment out `gem 'sqlite3'` and uncomment `gem 'pg'` lines

2. Create `.env` and fill values

   ```
   TOGODX_SERVER_DATABASE_HOST=
   TOGODX_SERVER_DATABASE_PORT=
   TOGODX_SERVER_DATABASE_USER=
   TOGODX_SERVER_DATABASE_PASSWORD=
   ```

| Variable                    | Default   |
|-----------------------------|-----------|
| TOGODX_SERVER_DATABASE_HOST | localhost |
| TOGODX_SERVER_DATABASE_PORT | 5432      |
| TOGODX_SERVER_DATABASE_USER | togodx    |

   Note: The `TOGODX_SERVER_DATABASE_USER` must have `CREATEDB` privilege

## Setup

```shell
$ bundle install
```

```shell
$ ./bin/togodx init
```

## Database initialization

Run the following commands to create and setup the database.

```shell
$ bundle exec rake db:create
$ bundle exec rake db:setup
```

## Dataset preparation

The supported formats of the data import script are JSON, TSV or CSV.
For JSON, the data must be an array of objects.
For TSV or CSV, the header line is required.

### Data structure

#### Attribute

| Name      |   Type   | Description                                                    |
|-----------|:--------:|----------------------------------------------------------------|
| api       | `String` | This value is used for constructing API URL, must be unique.   |
| dataset   | `String` | This value is a key to convert IDs between different datasets. |
| datamodel | `String` | `classfication` &#124; `distribution`                          |

See example in [attributes.csv](/example/attributes.csv)

#### Classification

| Name   |   Type    | Description                                                         |
|--------|:---------:|---------------------------------------------------------------------|
| id     | `String`  | An identifier of the attribute value                                |
| label  | `String`  | A readable label for the identifier                                 |
| parent | `String`  | An identifier of the parent node                                    |
| leaf   | `Boolean` | Set `true` if this node is ID, or `false` if this node is category. |

See example in [gene_chromosome_ensembl.json](/example/gene_chromosome_ensembl.json)

#### Distribution

| Name     |   Type   | Description                          |
|----------|:--------:|--------------------------------------|
| id       | `String` | An identifier of the attribute value |
| label    | `String` | A readable label for the identifier  |
| value    | `Number` | A value for the identifier           |
| binId    | `Number` | An identifier of the bin             |
| binLabel | `String` | A readable label for the bin         |

See example in [protein_molecular_mass_uniprot.json](/example/protein_molecular_mass_uniprot.json)

#### Relation

| Name   | Description               |
|--------|---------------------------|
| db1    | Dataset of source         |
| entry1 | Identifier of source      |
| db2    | Dataset of destination    |
| entry2 | Identifier of destination |

### Import datasets

#### Attribute

```shell
$ ./bin/togodx attribute import example/attributes.csv
```

#### Classification

```shell
$ ./bin/togodx classification import --api gene_chromosome_ensembl --dag-to-tree example/gene_chromosome_ensembl.json
$ ./bin/togodx classification import --api gene_high_level_expression_refex --dag-to-tree example/gene_high_level_expression_refex.json
$ ./bin/togodx classification import --api protein_cellular_component_uniprot --dag-to-tree example/protein_cellular_component_uniprot.json
$ ./bin/togodx classification import --api protein_disease_related_proteins_uniprot --dag-to-tree example/protein_disease_related_proteins_uniprot.json
```

Data with the structure of a DAG is forced to be converted into a tree.
See also [directed acyclic graph (DAG)](https://en.wikipedia.org/wiki/Directed_acyclic_graph).

#### Distribution

```shell
$ ./bin/togodx distribution import --api protein_molecular_mass_uniprot example/protein_molecular_mass_uniprot.json
```

#### Relation

```shell
$ ./bin/togodx relation import example/relation.csv
```
