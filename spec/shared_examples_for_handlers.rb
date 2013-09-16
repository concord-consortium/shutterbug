shared_examples "a request handler" do
  let(:config)  { Shutterbug::Configuration.new()}
  let(:rackapp) { mock }
  let(:req)     { mock }
  let(:env)     { mock }
  let(:handler) { described_class.new(config) }
  let(:mock_storage) do
    mock({
      :new => mock({
        :get_content => "content"
      })
    })
  end
  before(:each) do
    config.stub!(:storage => mock_storage)
  end
  it "should respond to regex" do
    handler.should respond_to :regex
    handler.regex.should be_kind_of Regexp
  end
  it "should respond to handle" do
    handler.should respond_to :handle
    rackapp.should_receive :good_response
    handler.handle(rackapp,req,env)
  end
end