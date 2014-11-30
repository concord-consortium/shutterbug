shared_examples "a request handler" do
  let(:rackapp) { mock }
  let(:req)     { mock }
  let(:env)     { mock }
  let(:handler) { described_class.new }
  let(:mock_storage) do
    mock({
      :new => mock({
        :get_content => "content",
        :filename => "file",
        :url => "url"
      })
    })
  end
  before(:each) do
    Shutterbug::Configuration.instance.stub!(:storage => mock_storage)
  end

  it "should respond to regex" do
    handler.class.should respond_to :regex
    handler.class.regex.should be_kind_of Regexp
  end

  it "should respond to handle" do
    handler.should respond_to :handle
    rackapp.should_receive :response
    handler.handle(rackapp, req, env)
  end
end
