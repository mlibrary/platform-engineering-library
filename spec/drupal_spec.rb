RSpec.describe "drupal" do
  def input(config)
    "(import \"./lib/1.21/mlibrary/drupal.libsonnet\") + { _config+:: { drupal+: #{config.to_json} } }"
  end

  before(:each) do
    @output = YAML.load_file("./spec/fixtures/drupal.yml") 
    @config = {}
  end
  subject do
    Jsonnet.evaluate(input(@config))
  end

  it "returns the expected defaults" do 
    expect(Jsonnet.evaluate(input(@config))).to eq(@output)
  end
  it "returns different namespace" do
    @output["drupal"]["web"]["storage"]["metadata"]["namespace"] = "my_namespace"
    @config["namespace"] = "my_namespace"
    expect(subject).to eq(@output)
  end
  it "returns different files_storage" do
    @output["drupal"]["web"]["storage"]["spec"]["resources"]["requests"]["storage"] = "1M"
    @config["files_storage"] = "1M"
    expect(subject).to eq(@output)
  end
end
