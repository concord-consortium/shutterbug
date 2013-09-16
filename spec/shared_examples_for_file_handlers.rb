require 'shared_examples_for_handlers'
shared_examples "a file handler" do
  let(:config)  { Shutterbug::Configuration.instance}
  let(:rackapp) { mock }
  let(:req)     { mock }
  let(:env)     { mock }
  let(:handler) { described_class.new(config) }


  it "should have a file extension" do
    handler.should respond_to :file_extension
  end
  it "should have a mime type" do
    handler.should respond_to :mime_type
  end
end