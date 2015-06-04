require 'shared_examples_for_storage'
require 'fog'

describe Shutterbug::Storage::S3Storage do
  let(:s3_bin)  { nil }
  let(:storage) { Shutterbug::Storage::S3Storage}
  let(:mock_write_result) { double(:public_url => "http://amazon.cloud/url.png")}
  before(:each) do
    storage.stub(:write => mock_write_result)
  end

  it_behaves_like "a storage provider" do
  end
 
  describe "some class methods" do
    before(:each) do
      Fog.mock!
    end
    describe "s3_bin" do
      subject do
        storage
      end
      describe "when the bin is already configured" do
        let(:fake_bin) { "xyzzy" }
        it "should not call #lookup_bin or #create_bin" do
          subject.instance_variable_set(:@s3_bin, fake_bin)
          subject.should_not_receive(:lookup_bin)
          subject.should_not_receive(:create_bin)
          subject.s3_bin.should eq fake_bin
          # reset
          subject.instance_variable_set(:@s3_bin,nil)
        end
      end
      describe "when the bin can't be found" do
        let(:fake_bin) { "xyzzy" }
        it "should call #create_bin" do
          subject.stub_chain(:connection,:directories,:get).and_return(nil)
          subject.should_receive(:create_bin).and_return(fake_bin)
          subject.s3_bin.should eq fake_bin
        end
      end
      describe "when the bin exists" do
        let(:fake_bin) { "xyzzy" }
        it "should not call #create_bin" do
          subject.stub_chain(:connection,:directories,:get).and_return(fake_bin)
          subject.s3_bin.should eq fake_bin
        end
      end
    end
  end
end

