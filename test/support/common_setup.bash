#!/usr/bin/env bash
_common_setup() {
  load "../node_modules/bats-support/load"
  load "../node_modules/bats-assert/load"
  touch test.yml
}

tk_show(){
  tk show --dangerous-allow-redirect $1 > test.yml
}

equal_to="dyff between -s -b test.yml"

_common_teardown() {
  rm test.yml
}
