require 'shared_examples_for_handlers'

describe Shutterbug::Handlers::ConvertHandler do
  let(:mock_post) do
    mock(:POST => {},
      :referrer => nil,
      :scheme => nil,
      :host_with_port => nil)
  end
  let(:req) { mock_post }

  it_behaves_like "a request handler" do
    let(:req) { mock_post }
  end

  describe "calling phantom" do
    let(:mock_results) { mock }
    let(:rackapp) { mock(:response => true )}
    let(:env)     { mock }
    let(:fake_file)   { mock(:filename => "blub", :url => "glub")}
    let(:mock_fantom) { mock(:cache_key => "1", :html_file => fake_file, :png_file => fake_file) }
    before(:each) do
      Shutterbug::PhantomJob.stub!(:new => mock_fantom)
    end
    it "should invoke phantom" do
      mock_fantom.should_receive(:rasterize).and_return(mock_results)
      subject.handle(rackapp, req, env)
    end
  end
end
