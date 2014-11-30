require 'shared_examples_for_file_handlers'
require 'shared_examples_for_handlers'

describe Shutterbug::Handlers::FileHandlers::PngFile do
  it_behaves_like "a file handler" do
    let(:req) { mock(:path => "/shutterbug/get_png/foobar.png") }
  end

  it_behaves_like "a request handler" do
    let(:req) { mock(:path => "/shutterbug/get_png/foobar.png") }
  end
end