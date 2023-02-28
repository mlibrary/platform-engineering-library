RSpec.describe "solrcloud" do
  def input(config)
    <<~EOT
      (import "./lib/1.21/mlibrary/solrcloud.libsonnet") + 
        { solrcloud: $.solrCloud.new("test-solr-cloud") }
    EOT
  end

  before(:each) do
    @output = YAML.load_file("./spec/fixtures/solrcloud.yml") 
    @config = {}
  end
  
  subject do
    Jsonnet.evaluate(input(@config))
  end

  it "returns the expected defaults" do 
    expect(Jsonnet.evaluate(input(@config))).to eq(@output)
  end
end
