require 'spec_helper'
require 'pry'

describe HealthDataCatalog do
  describe "::download_list_of_datasets" do
    before do
      VCR.use_cassette('data-set-list') do
        @list = HealthDataCatalog.download_list_of_datasets
      end
    end
    it "returns an array" do
      @list.should be_instance_of(Array)
    end
    it "contains one known dataset" do
      @list.include?("05457387-7ab6-4c1a-9dba-b1e5bdd5f2ad").should be_true
    end
  end

  describe "get_metadata_for_dataset" do
    before do
      VCR.use_cassette('data-set-list') do
        @list = HealthDataCatalog.download_list_of_datasets
      end
      VCR.use_cassette('single-dataset-metadata') do
        @metadata_entry = HealthDataCatalog.get_metadata_for_dataset("00aada73-a456-4547-ac5a-e5ffdc6b4847")
      end
    end
    it "returns a hash" do
      @metadata_entry.should be_instance_of(Hash)
    end
    it "blah" do
      #binding.pry
    end
  end

  describe "::compress_tags" do
    it "should return a string given an array" do
      tag_string = HealthDataCatalog.compress_tags(['as','sdsd','dsd'])
      tag_string.should be_instance_of(String)
    end
  end

  describe "::convert_nested_result_to_row_hash" do
    before do
      VCR.use_cassette('single-dataset-metadata') do
        @metadata_entry = HealthDataCatalog.get_metadata_for_dataset("00aada73-a456-4547-ac5a-e5ffdc6b4847")
      end
      @row_hash = HealthDataCatalog.convert_nested_result_to_row_hash(@metadata_entry.to_hash)
    end
    it "deletes the 'resources' data" do
      @row_hash["resources"].should be_nil
    end
    it "flattens the tags to a string" do
      @row_hash["tags"].should be_instance_of(String)
    end
    it "leaves the array without any enumerable entries" do
      @row_hash.select { |key,value| value.respond_to?(:each) }.should be_empty
    end
    it "leaves the array without any array entries" do
      @row_hash.select { |key,value| value.class == Array }.should be_empty 
    end
    it "pry" do
      #binding.pry
    end
  end

end

