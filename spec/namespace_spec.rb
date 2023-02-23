RSpec.describe "namespace" do
  def input(config)
    "{ _config:: #{config.to_json} } + (import \"./lib/1.21/mlibrary/namespace.libsonnet\")"
  end

  before(:each) do
    @output = YAML.load_file("./spec/fixtures/namespace.yml") 
    @config = {
      namespace: {
        name: "my_namespace"
      }
    }
  end

  it "returns the expected results" do 
    check = Jsonnet.evaluate(input(@config))
    expect(check).to eq({"namespace" => @output})
  end
end
