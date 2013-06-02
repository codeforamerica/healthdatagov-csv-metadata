require 'httparty'
require './lib/sparsify'
require 'vcr'

module HealthDataCatalog

  VCR.configure do |c|
    c.cassette_library_dir = 'vcr_cassettes'
    c.hook_into :webmock
  end

  def self.download_list_of_datasets
    VCR.use_cassette("dataset-list") do
      list = HTTParty.get("http://hub.healthdata.gov/api/2/rest/dataset")
    end
  end

  def self.get_metadata_for_dataset(id)
    VCR.use_cassette("metadata-for-#{id}") do
      metadata = HTTParty.get("http://hub.healthdata.gov/api/2/rest/dataset/#{id}")
    end
  end

  def self.compress_tags(tags_array)
    tags_array.join(', ')
  end

  def self.convert_nested_result_to_row_hash(input_hash)
    row_hash = input_hash.sparse(:separator => " - ")
    (0..2).each do |index|
      if row_hash["resources"][index] != nil
        row_hash["resources_#{index}_url"] = row_hash["resources"][index]["url"]
        row_hash["resources_#{index}_name"] = row_hash["resources"][index]["name"]
      else
        row_hash["resources_#{index}_url"] = "" 
        row_hash["resources_#{index}_name"] = "" 
      end
    end
    row_hash.delete("resources")
    row_hash.each_pair do |key,value|
      row_hash[key] = row_hash[key].join(", ") if value.class == Array
    end
    row_hash
  end

  def self.all_metadata_array
    list = download_list_of_datasets
    all_metadata = Array.new
    list.each { |id| all_metadata << convert_nested_result_to_row_hash(get_metadata_for_dataset(id).to_hash) }
    all_metadata
  end

  def self.combine_hash_keys(array_of_hashes)
    all_keys = Array.new
    array_of_hashes.reduce([]) { |all_array, hash| all_array + hash.keys }.uniq
  end

end

