#!/usr/bin/env -S cmake -P
#[=============================================================================[
tokenizer.cmake

Command-line script for printing CMake code tokens intended for development and
debugging.

SYNOPSIS

  cmake -P tokenizer.cmake -- <file> [<tokenizer-options>...] [--]
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...3.31)

if(NOT CMAKE_CURRENT_LIST_FILE PATH_EQUAL CMAKE_SCRIPT_MODE_FILE)
  message(FATAL_ERROR "This is a command-line script.")
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/../cmake/modules)

include(Normalizer/Cli)
include(Normalizer/Timer)
include(Tokenizer)

normalizer_timer_start()

normalizer_cli_add_argument(
  RESULT_VARIABLE TOKENIZER_FILE
  TYPE file
  IS_REQUIRED
  HELP_ARGUMENT_PLACEHOLDER "<file>"
  HELP "CMake file to tokenize."
)

normalizer_cli_add_option(
  "--help;-h"
  CALL normalizer_cli_print_usage 0
  HELP "Print tokenizer script usage"
)

normalizer_cli_parse()

set(exitCode 0)
block(PROPAGATE exitCode)
  message(STATUS "Parsing file ${TOKENIZER_FILE}")

  set(namespace "tokenizer")

  tokenizer_parse(
    FILE "${TOKENIZER_FILE}"
    NAMESPACE ${namespace}
    EXIT_CODE exitCode
    ERROR error
  )

  foreach(i IN LISTS ${namespace}_tokens)
    string(CONCAT text "${${namespace}_${i}_text}")

    string(LENGTH "${text}" length)

    if(length GREATER 500)
      string(SUBSTRING "${text}" 0 500 text)
      string(APPEND text "...")
    endif()

    string(REGEX REPLACE "\n" "\\\\n" text "${text}")

    message(STATUS "${${namespace}_${i}_id} (${i}) '${text}'")
  endforeach()

  list(LENGTH ${namespace}_tokens length)
  message(STATUS "Number of tokens: ${length}")
  message(STATUS "Last token index: ${${namespace}_end}")

  if(error)
    message(STATUS "${error}")
  endif()
endblock()

normalizer_timer_stop(time)
message(STATUS "Completed in ${time} sec")

cmake_language(EXIT ${exitCode})
