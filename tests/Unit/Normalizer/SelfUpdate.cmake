# Test self update commands.

include(Normalizer/SelfUpdate)

function(normalizer_tests_unit_selfupdate_get_new_version)
  cmake_path(
    ABSOLUTE_PATH
    NORMALIZER_TEST_FILE
    BASE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    NORMALIZE
  )

  normalizer_self_update_get_new_version("${NORMALIZER_TEST_FILE}" version)

  message(STATUS "${version}")
endfunction()
