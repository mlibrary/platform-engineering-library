setup(){
  load "support/common_setup"
  _common_setup
}
@test "namespace has expected output" {
  tk_show environments/1.21/namespace
  $equal_to ./test/fixtures/namespace.yml
}
teardown() {
  _common_teardown
}
