cmake_minimum_required(VERSION 3.25 FATAL_ERROR)

cmake_minimum_required(
  VERSION 3.11...3.20
  # Comment
  FATAL_ERROR
  # Comment 2
)

project(TestingProject)

set(code [[
  cmake_minimum_required(VERSION 3.25)
]])

set(code "
  cmake_minimum_required(VERSION 3.11...3.20 FATAL_ERROR)
")

set(code [[
  cmake_minimum_required(VERSION ${version} FATAL_ERROR)
]])
