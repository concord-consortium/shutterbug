require 'shared_examples_for_storage'
require 'fog'

describe Shutterbug::Storage::S3Storage do
  let(:mock_write_result) { mock(:public_url => "http://amazon.cloud/url.png")}
  before(:each) do
    Shutterbug::Storage::S3Storage.stub!(:write => mock_write_result)
  end

  it_behaves_like "a storage provider" do
  end
end