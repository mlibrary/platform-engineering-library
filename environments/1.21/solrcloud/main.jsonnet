(import "1.21/mlibrary/solrcloud.libsonnet") +
{
  solrcloud: 
  // makes a solrcloud default values
  $.solrCloud.new("test-solr-cloud") 
 
  // put in your own image. takes image and tag
  + $.solrCloud.withSolrImage('ghcr.io/hathitrust/catalog-solr', 'solrcloud-8.11.2')

  //recommended tuning
  //+ $.solrCloud.withRecommendedGCTuning()
  
  //... all the rest of them

}

