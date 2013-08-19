
describe Shutterbug::Configuration do

  let(:uri_prefix)       { "http://blah.com/" }
  let(:path_prefix)      { "/shutterbug" }
  let(:resource_dir)     { "resource_dir"}
  let(:phantom_bin_path) { "phantom_bin_path"}
  let(:s3_bin)           { nil }
  let(:s3_key)           { nil }
  let(:s3_secret)        { nil }

  let(:opts) do
    { :uri_prefix       => uri_prefix,
      :path_prefix      => path_prefix,
      :resource_dir     => resource_dir,
      :phantom_bin_path => phantom_bin_path,
      :s3_key           => s3_key,
      :s3_bin           => s3_bin,
      :s3_secret        => s3_secret
    }
  end


    # def js_file


  subject { Shutterbug::Configuration.new(opts) }

  describe "base_url" do
    let(:post)    { {}  }
    let(:referrer){ nil }
    let(:req)     { mock(:POST => post, :referrer => referrer, :scheme => "http", :host_with_port => "fake.com:80")}

    describe "without explict base_url or a referrer" do
      it "should use defaults" do
        subject.base_url(req).should == "http://fake.com:80"
      end
    end
    describe "with a referrer" do
      let(:referrer) { "http://referrer.com/scuba.html"}
      it "should use the referrer" do
        subject.base_url(req).should == "http://referrer.com/scuba.html"
      end
    end
    describe "with a POST param" do
      let(:post)  { {'base_url' => "http://base_url.used.com/"} }
      it "should use the POST param" do
        subject.base_url(req).should == "http://base_url.used.com/"
      end
    end
  end


  describe "file paths" do
    it "should have a valid js_path pointing to shutterbug" do
      subject.js_path.should == "http://blah.com//shutterbug/shutterbug.js"
    end

    it "should have a valid convert_path" do
      subject.convert_path.should == "http://blah.com//shutterbug/make_snapshot"
    end

    it "should resolve requests for pngs" do
      subject.png_path('xxx').should == "http://blah.com//shutterbug/get_png/xxx"
    end

    it "should resolve requests for html" do
      subject.html_path('xxx').should == "http://blah.com//shutterbug/get_html/xxx"
    end
  end

  describe "regular expressions" do
    # def js_regex
    # def convert_regex
    # def png_regex
    # def html_regex
    pending "do we want to test the regexp patterns?"
  end

  describe "use_s3?" do
    describe "with no S3 information" do
      its(:use_s3?) { should be_false }
    end

    describe "when s3_bin is specified" do
      let(:s3_bin)  { "bin" }
      its(:use_s3?) { should be_false}

      describe "when s3_key is specified" do
        let(:s3_key)  { "key" }
        its(:use_s3?) { should be_false}

        describe "when s3_secret is specig" do
          let(:s3_secret) { "secret" }
          its(:use_s3?)   { should be_true}
        end
      end
    end
  end


end