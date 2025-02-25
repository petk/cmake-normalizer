# Test default configuration.

include(Normalizer/Config)

function(normalizer_tests_unit_config_default)
  normalizer_config_default(ALL KEYS keys)
  foreach(key IN LISTS keys)
    message(STATUS "${key}=${${key}}")
  endforeach()
endfunction()
