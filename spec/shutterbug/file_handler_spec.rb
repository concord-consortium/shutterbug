require 'shared_examples_for_handlers'

describe Shutterbug::Handlers::FileHandler do
  it_behaves_like "a request handler" do
    let(:req) { mock(:path => "/shutterbug/get_file/foobar.png") }
  end
end
