describe Shutterbug::S3File do

  let(:bug_file) { mock('filename' => 'filename') }
  let(:use_s3?)  { false                          }
  let(:s3_key)   { 'xxx'                          }
  let(:s3_secret){ 'yyy'                          }

  let(:config)   do mock({
      :use_s3?   => use_s3?,
      :s3_key    => s3_key,
      :s3_secret => s3_secret
    })
  end

  subject        { Shutterbug::S3File             }

  before(:each) do
    Shutterbug::Configuration.stub(:instance => config)
  end

  describe "wrap" do
    describe "when configured not to use s3" do
      it "it should return the original bug_file" do
        subject.wrap(bug_file).should == bug_file
      end
    end
    describe "when configured to use S3" do
      let(:use_s3?) { true }

      describe "when the file exists already in S3" do
        it "should return an S3 wrapped file" do
          subject.should_receive(:exists?).and_return(true)
          result = subject.wrap(bug_file)
          result.should_not == bug_file
          result.should be_kind_of Shutterbug::S3File
        end
      end

      describe "when the file doesn't yet exist in S3"  do
        it "should return an S3 wrapped file" do
          subject.should_receive(:exists?).and_return(false)
          subject.should_receive(:fs_path_exists?).and_return(true)
          subject.should_receive(:write).and_return(true)
          result = subject.wrap(bug_file)
          result.should_not == bug_file
          result.should be_kind_of Shutterbug::S3File
        end
      end

    end
  end
end