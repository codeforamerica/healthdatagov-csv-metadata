require 'httparty'
require 'sparsify'

module HealthDataCatalog
  def self.download_list_of_datasets
    list = HTTParty.get("http://hub.healthdata.gov/api/2/rest/dataset")
  end
  def self.get_metadata_for_dataset(id)
    metadata = HTTParty.get("http://hub.healthdata.gov/api/2/rest/dataset/#{id}")
  end
  def self.compress_tags(tags_array)
    tags_array.join(', ')
  end
  def self.convert_nested_result_to_row_hash(input_hash)
    row_hash = input_hash.sparse
    row_hash.delete("resources")
    #row_hash["tags"] = compress_tags([row_hash["tags"]])
    #row_hash["tags"] = row_hash["tags"].join(', ')
    row_hash.each_pair do |key,value|
      row_hash[key] = row_hash[key].join(", ") if value.class == Array
    end
    row_hash
  end
end

