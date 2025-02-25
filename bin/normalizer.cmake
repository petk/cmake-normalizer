#!/usr/bin/env -S cmake -P

cmake_minimum_required(VERSION 3.29...3.31)

if(NOT CMAKE_CURRENT_LIST_FILE PATH_EQUAL CMAKE_SCRIPT_MODE_FILE)
  message(FATAL_ERROR "This is a command-line script.")
endif()

include(${CMAKE_CURRENT_LIST_DIR}/../cmake/development.cmake)

include(Normalizer/Timer)
normalizer_timer_start()

include(Normalizer)
include(Normalizer/Cli)
include(Normalizer/Message)
include(Normalizer/SelfUpdate)

normalizer_cli_add_argument(
  RESULT_VARIABLE NORMALIZER_PATH
  IS_ARRAY
  IS_REQUIRED
  TYPE path
  DEFAULT ${CMAKE_CURRENT_SOURCE_DIR}
  HELP_ARGUMENT_PLACEHOLDER "<paths...>"
  HELP
    "One or more space-separated CMake files or directories containing CMake "
    "files to check or fix. If omitted, it defaults to checking files in the "
    "current directory."
)

normalizer_cli_add_option(
  "--help;-h"
  CALL normalizer_cli_print_usage 0
  HELP "Print normalizer script usage"
)

normalizer_cli_add_option(
  "-v"
  CALL normalizer_cli_print_and_exit
    MESSAGE ${NORMALIZER_VERSION}
    EXIT_CODE 0
  HELP "Print normalizer version"
)

normalizer_cli_add_option(
  "--version"
  CALL normalizer_cli_print_and_exit
    MESSAGE normalizer.cmake ${NORMALIZER_VERSION}
    EXIT_CODE 0
  HELP "Print script info and version"
)

normalizer_cli_add_option(
  "--config"
  HAS_ARGUMENT
  RESULT_VARIABLE NORMALIZER_CONFIG
  HELP_ARGUMENT_PLACEHOLDER "<file>"
  HELP "Path to a configuration file."
)

normalizer_cli_add_option(
  "--set"
  HAS_ARGUMENT
  REPEATABLE
  RESULT_VARIABLE NORMALIZER_CONFIGURATIONS
  HELP_ARGUMENT_PLACEHOLDER "<config>=<value>"
  HELP
    "Set configuration value on command-line. Each configuration from the "
    "'.cmake' configuration file, can be also adjusted using this option."
)

normalizer_cli_add_option(
  "--not"
  HAS_ARGUMENT
  REPEATABLE
  RESULT_VARIABLE NORMALIZER_SKIP
  HELP_ARGUMENT_PLACEHOLDER "<path>"
  HELP
    "Skip given path when checking files. Can be also passed as a glob "
    "expression. This option can be passed multiple times."
)

normalizer_cli_add_option(
  "--fix"
  RESULT_VARIABLE NORMALIZER_FIX
  HELP
    "Checks and also fixes CMake files. Without this flag, the tool only "
    "reports issues without modifying files."
)

normalizer_cli_add_option(
  "--quiet;-q"
  RESULT_VARIABLE NORMALIZER_QUIET
  HELP
    "Do not output any message."
)

cmake_host_system_information(RESULT processors QUERY NUMBER_OF_LOGICAL_CORES)

normalizer_cli_add_option(
  "--parallel;-j"
  HAS_ARGUMENT
  DEFAULT ${processors}
  IS_INTEGER
  RESULT_VARIABLE NORMALIZER_PARALLEL
  HELP_ARGUMENT_PLACEHOLDER "<jobs>"
  HELP
    "Normalize files in parallel with concurrent processes for better "
    "performance. Without this option only a single process is executed. When "
    "using this option without argument, the <jobs> number will be the number "
    "of logical cores available on the current machine."
)

normalizer_cli_add_option(
  "--self-update"
  CALL normalizer_self_update ${NORMALIZER_SELF_UPDATE_URL}
  HELP
    "Update current normalizer.cmake file to the latest version from GitHub "
    "releases."
)

normalizer_cli_parse()

normalizer_execute(
  PATHS ${NORMALIZER_PATH}
  SKIP ${NORMALIZER_SKIP}
  CONFIG ${NORMALIZER_CONFIG}
  EXIT_CODE_VARIABLE exitCode
  FIX ${NORMALIZER_FIX}
)

normalizer_timer_stop(time)
normalizer_message(STATUS "Completed in ${time} sec")

cmake_language(EXIT ${exitCode})
