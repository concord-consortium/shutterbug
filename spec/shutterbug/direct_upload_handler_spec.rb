require 'shared_examples_for_handlers'

describe Shutterbug::Handlers::DirectUploadHandler do
  it_behaves_like "a request handler" do
    let(:req) { mock(:GET => {}) }
  end
end
