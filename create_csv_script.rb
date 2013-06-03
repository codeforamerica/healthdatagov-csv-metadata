require 'pry'
require './lib/health_data_catalog'

HealthDataCatalog.create_metadata_file("./healthdatagov_metadata_catalog.csv")

binding.pry
