require 'httparty'
require './lib/sparsify'
require 'vcr'
require 'csv'

module HealthDataCatalog

  ### VCR configuration (to cache results locally; probably not wanted in production) ###

  VCR.configure do |c|
    c.cassette_library_dir = 'vcr_cassettes'
    c.hook_into :webmock
  end


  ### Major workhorse methods ###

  # Gets data, processes it, and writes to a file.
  # This is the core interface of the library.
  def self.create_metadata_file(output_path_and_name)
    all_metadata = all_metadata_array
    standardized_metadata = standardize_hashes(all_metadata)
    output_matrix = Array.new
    output_matrix[0] = standardized_metadata[0].keys
    standardized_metadata.each do |metadata_hash|
      output_matrix << metadata_hash.values
    end
    CSV.open(output_path_and_name, "w") do |csv|
      output_matrix.each do |data_row|
        csv << data_row
      end
    end
  end

  # Returns an array of hashes containing metadata for all HealthCare.gov data sets
  def self.all_metadata_array
    list = download_list_of_datasets
    all_metadata = Array.new
    list.each { |id| all_metadata << convert_nested_result_to_row_hash(get_metadata_for_dataset(id).to_hash) }
    all_metadata
  end


  ### API call methods ###

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


  ### Misc helper methods ###

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

  def self.combine_hash_keys(array_of_hashes)
    array_of_hashes.reduce([]) { |all_array, hash| all_array + hash.keys }.uniq
  end

  # Takes an array of hashes with overlapping (but not identical) keys and 
  # returns an array of hashes with the same values, but where each hash 
  # has every key in the set and each hash is ordered the same way
  def self.standardize_hashes(array_of_hashes)
    all_keys_array = combine_hash_keys(array_of_hashes)
    standardized_hash_array = Array.new
    array_of_hashes.each do |orig_hash|
      standardized_hash = Hash.new
      all_keys_array.each do |key|
        if orig_hash.has_key?(key)
          standardized_hash[key] = orig_hash[key]
        else
          standardized_hash[key] = ""
        end
      end
      standardized_hash_array << standardized_hash
    end
    standardized_hash_array
  end

end

