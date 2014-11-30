shared_examples "a storage provider" do
  let(:file_class) { Shutterbug::Handlers::FileHandlers::HtmlFile }
  let(:filename) { "somefilename.html" }
  let(:provider) { described_class.new(filename, file_class) }

  it "should respond to filename" do
    provider.should respond_to :filename
  end

  it "should respond to url" do
    provider.should respond_to :url
  end

  it "should respond to get_content" do
    provider.should respond_to :get_content
  end
end
