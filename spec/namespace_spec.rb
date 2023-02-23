RSpec.describe "namespace" do
  def input(config)
    "(import \"./lib/1.21/mlibrary/namespace.libsonnet\") + { _config+:: { namespace+: #{config.to_json} } }"
  end

  before(:each) do
    @output = YAML.load_file("./spec/fixtures/namespace.yml") 
    @config = {
      name: "my_namespace"
    }
  end

  subject do
    Jsonnet.evaluate(input(@config))
  end

  it "returns the expected results" do 
    expect(subject).to eq(@output)
  end

  it "errors out without a name for the namespace" do
    @config = {}
    expect { subject }.to raise_error(Jsonnet::EvaluationError)
  end
end
