shared_examples "a file handler" do
  it "should have a file extension" do
    described_class.should respond_to :file_extension
  end

  it "should have a mime type" do
    described_class.should respond_to :mime_type
  end
end
