RSpec.describe "drupal" do
  def input(config)
    "(import \"./lib/1.21/mlibrary/drupal.libsonnet\") + { _config+:: { drupal+: #{config.to_json} } }"
  end

  before(:each) do
    @output = YAML.load_file("./spec/fixtures/drupal.yml") 
    @config = { 
      host: "cms.my-cluster.lib.umich.edu",
      image: "ghcr.io/mlibrary/my-drupal-image:1.0" 
    }
  end
  subject do
    Jsonnet.evaluate(input(@config))
  end

  it "returns the expected defaults" do 
    expect(Jsonnet.evaluate(input(@config))).to eq(@output)
  end
  it "returns different namespace" do
    @output["drupal"]["web"]["storage"]["metadata"]["namespace"] = "my_namespace"
    @output["drupal"]["web"]["service"]["metadata"]["namespace"] = "my_namespace"
    @output["drupal"]["web"]["deployment"]["metadata"]["namespace"] = "my_namespace"
    @output["drupal"]["web"]["ingress"]["metadata"]["namespace"] = "my_namespace"
    @config["namespace"] = "my_namespace"
    expect(subject).to eq(@output)
  end
  it "returns different files_storage" do
    @output["drupal"]["web"]["storage"]["spec"]["resources"]["requests"]["storage"] = "1M"
    @config["files_storage"] = "1M"
    expect(subject).to eq(@output)
  end
  it "can add other environment variables to the deployment" do
    @config["env"] = [{"name" => "name", "value" => "value"}]
    @output["drupal"]["web"]["deployment"]["spec"]["template"]["spec"]["containers"][0]["env"].push(
    "name" => "name", "value" => "value"
    )
    expect(subject).to eq(@output)
  end
  it "can add other secret environment variables to the deployment" do
    @config["secrets"] = [{"key" => "KEY", "name" => "name"}]
    @output["drupal"]["web"]["deployment"]["spec"]["template"]["spec"]["containers"][0]["env"].push(
      { "name" => "KEY", 
        "valueFrom" => 
        {"secretKeyRef" => 
          { "key" => "KEY", "name" => "name" } 
        } 
      }
    )
    expect(subject).to eq(@output)
  end

end
