# Command-line script that is executed when running unit tests. See its
# accompanying CMakeLists.txt file.
#
# Synpsis:
#
#   cmake \
#     -D NORMALIZER_TEST_MODULE=<ModuleName> \
#     -D NORMALIZER_TEST_COMMAND=<command_name> \
#     [-D ...] \
#     -P RunCMake.cmake

cmake_minimum_required(VERSION 3.29...3.31)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/../../cmake/modules)

include(${CMAKE_CURRENT_LIST_DIR}/Normalizer/${NORMALIZER_TEST_MODULE}.cmake)

if(NOT COMMAND ${NORMALIZER_TEST_COMMAND})
  message(
    FATAL_ERROR
    "Command name not found ${NORMALIZER_TEST_COMMAND}\n"
    "Set NORMALIZER_TEST_COMMAND to a function name from the given "
    "${NORMALIZER_TEST_MODULE}.cmake test module."
  )
endif()

cmake_language(CALL ${NORMALIZER_TEST_COMMAND})
