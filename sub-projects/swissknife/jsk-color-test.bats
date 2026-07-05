#!/usr/bin/env bats

@test "jsk-color.sh runs without arguments" {
  run ./jsk-color.sh
  [ "$status" -eq 0 ]
}

@test "jsk-color.sh -b (basic colors) runs" {
  run ./jsk-color.sh -b
  [ "$status" -eq 0 ]
  [[ "$output" == *"Basic Colors"* ]]
}

@test "jsk-color.sh -e (extended colors) runs" {
  run ./jsk-color.sh -e
  [ "$status" -eq 0 ]
  [[ "$output" == *"Extended ANSI Colors"* ]]
}

@test "jsk-color.sh -a (all colors) runs" {
  run ./jsk-color.sh -a
  [ "$status" -eq 0 ]
  [[ "$output" == *"Basic Colors"* ]]
  [[ "$output" == *"Extended ANSI Colors"* ]]
}

@test "jsk-color.sh -h (help) displays usage" {
  run ./jsk-color.sh -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}
