require 'spec_helper'

describe HealthDataCatalog do
  describe "::download_dataset_array" do
    before do
      @list = HealthDataCatalog.download_dataset_array
    end
    it "should return an array" do
      @list.should be_instance_of(Array)
    end
  end
end

