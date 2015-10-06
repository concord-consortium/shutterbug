require 'shared_examples_for_handlers'

describe Shutterbug::Handlers::ErrorTrigger do
  let(:handler) { described_class.new }
  let(:rackapp) {}
  let(:req)     {}
  let(:env)     {}

  it "thorws an excpetion" do
      described_class.regex.should match "/shutterbug/error/foo"
      handler.should respond_to :handle
      expect { handler.handle(rackapp, req, env) }.to raise_error
  end

end
