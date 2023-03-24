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


## Setup

### Before installing gems

#### Use SQLite3

1. Comment out `gem 'pg'` in `Gemfile`.

#### Use PostgreSQL instead of SQLite3

1. Comment out `gem 'sqlite3'` in `Gemfile`.

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

### Install gems

```shell
$ bundle install
```

### Initialize application

```shell
$ ./bin/togodx init
```


## Database initialization

Run the following commands to create and setup the database.

```shell
$ bundle exec rake db:create
$ bundle exec rake db:migrate
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

This file should be prepared for each pair of dataset names

Execute `rails runner 'p Relation.datasets'` to get pair of dataset names.

| Name   |   Type   | Description          |
|--------|:--------:|----------------------|
| source | `String` | Identifier of source |
| target | `String` | Identifier of target |

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

Data whose structure is a DAG should be converted into a tree. Pass `--dag-to-tree` options to the command.
See also [directed acyclic graph (DAG)](https://en.wikipedia.org/wiki/Directed_acyclic_graph).

#### Distribution

```shell
$ ./bin/togodx distribution import --api protein_molecular_mass_uniprot example/protein_molecular_mass_uniprot.json
```

#### Relation

```shell
$ ./bin/togodx relation import --source ensembl_gene --target ncbigene example/relation_ensembl_gene_ncbigene.csv
$ ./bin/togodx relation import --source ensembl_gene --target uniprot example/relation_ensembl_gene_uniprot.csv
$ ./bin/togodx relation import --source ncbigene --target uniprot example/relation_ncbigene_uniprot.csv
```


## Use docker-compose

1. Make symbolic link

For development

```shell
$ ln -s docker/docker-compose.dev.yml docker-compose.yml
```

For production

```shell
$ ln -s docker/docker-compose.prod.yml docker-compose.yml
```

2. Create `.env` file

```
# Docker
NGINX_PORT=80 # for production
APP_PORT=3000 # for development

# Rails
TOGODX_SERVER_DATABASE_HOST=db
TOGODX_SERVER_DATABASE_USER=togodx
TOGODX_SERVER_DATABASE_PASSWORD=changeme

# PostgreSQL
POSTGRES_USER=togodx
POSTGRES_PASSWORD=changeme
```

3. Initialization and import data

```shell
$ docker-compose run --rm app bundle install
$ docker-compose run --rm app bin/togodx init
$ docker-compose run --rm app rails db:create
$ docker-compose run --rm app rails db:migrate
$ docker-compose run --rm app bin/togodx attribute import example/attributes.csv
$ docker-compose run --rm app bin/togodx classification import --api gene_chromosome_ensembl --dag-to-tree example/gene_chromosome_ensembl.json
$ docker-compose run --rm app bin/togodx classification import --api gene_high_level_expression_refex --dag-to-tree example/gene_high_level_expression_refex.json
$ docker-compose run --rm app bin/togodx classification import --api protein_cellular_component_uniprot --dag-to-tree example/protein_cellular_component_uniprot.json
$ docker-compose run --rm app bin/togodx classification import --api protein_disease_related_proteins_uniprot --dag-to-tree example/protein_disease_related_proteins_uniprot.json
$ docker-compose run --rm app bin/togodx distribution import --api protein_molecular_mass_uniprot example/protein_molecular_mass_uniprot.json
$ docker-compose run --rm app bin/togodx relation import --source ensembl_gene --target ncbigene example/relation_ensembl_gene_ncbigene.csv
$ docker-compose run --rm app bin/togodx relation import --source ensembl_gene --target uniprot example/relation_ensembl_gene_uniprot.csv
$ docker-compose run --rm app bin/togodx relation import --source ncbigene --target uniprot example/relation_ncbigene_uniprot.csv
```

4. Start server

```shell
$ docker-compose up -d
```

Then visit to `http://localhost:<APP_PORT>/breakdown/gene_chromosome_ensembl?pretty`

## API

### `GET` `POST` /breakdown/{attribute}

#### Path parameter

| parameter | type   | required | description    |
|-----------|--------|----------|----------------|
| attribute | String | Yes      | attribute name |

#### Query parameter `GET` / Request body `POST`

| parameter | type   | required | description                                                                                                         |
|-----------|--------|----------|---------------------------------------------------------------------------------------------------------------------|
| node      | String | No       | if not set, it is assumed to be the root node                                                                       |
| hierarchy | Flag   | No       | if set, return parents and children of the node                                                                     |
| order     | String | No       | `id_asc`&#124;`id_desc`&#124;`numerical_asc`&#124;`numerical_desc`&#124;`alphabetical_asc`&#124;`alphabetical_desc` |

<small>Remember to set request header `Content-Type: application/json` for `POST`</small>

#### Response

* hierarchy = `false`

  ```json
  [
    {
      "node": "node_1",
      "label": "label 1",
      "count": 10,
      "tip": true
    },
    {
      "node": "node_2",
      "label": "label 2",
      "count": 20,
      "tip": false
    },
    .
    .
    .
  ]
  ```

* hierarchy = `true`

  ```json
  {
    "self": {
      "node": "node_3",
      "label": "label 3",
      "count": 30,
      "tip": false
    },
    "parents": [
      {
        "node": "node_4",
        "label": "label 4",
        "count": 40,
        "tip": false
      },
      {
        "node": "node_5",
        "label": "label 5",
        "count": 50,
        "tip": false
      }
    ],
    "children": [
      {
        "node": "node_1",
        "label": "label 1",
        "count": 10,
        "tip": true
      },
      {
        "node": "node_2",
        "label": "label 2",
        "count": 20,
        "tip": false
      },
      .
      .
      .
    ]
  }
  ```

### Suggest

### `GET` `POST` /suggest/{attribute}

#### Path parameter

| parameter | type   | required | description    |
|-----------|--------|----------|----------------|
| attribute | String | Yes      | attribute name |

#### Query parameter `GET` / Request body `POST`

| parameter | type   | required | description                          |
|-----------|--------|----------|--------------------------------------|
| term      | String | Yes      | query string (at least 3 characters) |

<small>Remember to set request header `Content-Type: application/json` for `POST`</small>

#### Response

```json
{
  "results": [
    {
      "node": "ndoe_1",
      "label": "label 1"
    },
    {
      "node": "ndoe_2",
      "label": "label 2"
    },
    .
    .
    .
  ],
  "total": 100
}
```

### Locate

### `POST` /suggest/{attribute}

#### Path parameter

| parameter | type   | required | description    |
|-----------|--------|----------|----------------|
| attribute | String | Yes      | attribute name |

#### Request body

| parameter | type                | required | description                                   |
|-----------|---------------------|----------|-----------------------------------------------|
| dataset   | String              | Yes      | target dataset name                           |
| queries   | Array&lt;String&gt; | Yes      | list of nodes                                 |
| node      | String              | No       | if not set, it is assumed to be the root node |

<small>Remember to set request header `Content-Type: application/json`</small>

#### Response

```json
[
  {
    "node": "node_1",
    "label": "label 1",
    "count": 100,
    "mapped": 0,
    "pvalue": null
  },
  {
    "node": "node_2",
    "label": "label 2",
    "count": 200,
    "mapped": 1,
    "pvalue": 0.12345
  },
  .
  .
  .
]
```

### Aggregate

### `POST` /aggregate

#### Request body

| parameter | type                | required | description                 |
|-----------|---------------------|----------|-----------------------------|
| dataset   | String              | Yes      | target dataset name         |
| filters   | Array&lt;Object&gt; | Yes      | list of filters (see below) |

* Object structure of a `filter`

  ```json
  {
    "attribute": "attribute_1",
    "nodes": [
      "node_1",
      "node_1",
      .
      .
      .
    ]
  }
  ```

<small>Remember to set request header `Content-Type: application/json`</small>

#### Response

```json
[
  "id_1",
  "id_2",
  .
  .
  .
]
```

### Dataframe

### `POST` /dataframe

#### Request body

| parameter   | type                | required | description                     |
|-------------|---------------------|----------|---------------------------------|
| dataset     | String              | Yes      | target dataset name             |
| filters     | Array&lt;Object&gt; | Yes      | list of filters (see below)     |
| annotations | Array&lt;Object&gt; | No       | list of annotations (see below) |
| queries     | Array&lt;String&gt; | Yes      | list of queries                 |

* Object structure of a `filter`

  ```json
  {
    "attribute": "attribute_1",
    "nodes": [
      "node_1",
      "node_2",
      .
      .
      .
    ]
  }
  ```

* Object structure of a `annotation`

  ```json
  [
    {
      "attribute": "attribute_1"
    },
    {
      "attribute": "attribute_1"
    },
    .
    .
    .
  ]
  ```

<small>Remember to set request header `Content-Type: application/json`</small>

#### Response

```json
[
  {
    "index": {
      "dataset": "dataset_1",
      "entry": "node_1",
      "label": "label 1"
    },
    "attributes": [
      {
        "id": "attribute_1",
        "items": [
          {
            "dataset": "dataset_2",
            "entry": "node_1",
            "node": "node_2",
            "label": "label 2"
          }
        ]
      },
      .
      .
      .
    ]
  },
  .
  .
  .
]
```
