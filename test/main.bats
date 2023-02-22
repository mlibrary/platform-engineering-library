setup(){
  load "support/common_setup"
  _common_setup
}
@test "namespace has expected output" {
  run $tk_show environments/1.21/namespace
  cat ./test/fixtures/namespace.yml | assert_output -
}
