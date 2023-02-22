#!/usr/bin/env bash
_common_setup() {
  load "../node_modules/bats-support/load"
  load "../node_modules/bats-assert/load"
}

tk_show="tk show --dangerous-allow-redirect"
