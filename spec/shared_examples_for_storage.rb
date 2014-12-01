shared_examples "a storage provider" do
  let(:filename) { "somefilename.html" }

  describe "class" do
    it "should respond to get_url(name)" do
      described_class.should respond_to :get_url
    end
  end

  describe "instance" do
    let(:instance) { described_class.new(filename) }

    it "should respond to filename" do
      instance.should respond_to :filename
    end

    it "should respond to url" do
      instance.should respond_to :url
    end
  end
end
