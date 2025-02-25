function(normalizer_tests_unit module testCommand testNameResultVariable)
  cmake_parse_arguments(
    PARSE_ARGV
    3
    parsed # prefix
    "" # options
    "" # one-value keywords
    "ARGS" # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(parsed_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "Missing values for: ${parsed_KEYWORDS_MISSING_VALUES}")
  endif()

  get_property(id GLOBAL PROPERTY _NORMALIZER_TEST_UNIT_ID)
  if(NOT id)
    set(id 1)
    set_property(GLOBAL PROPERTY _NORMALIZER_TEST_UNIT_ID ${id})
  else()
    math(EXPR id "${id} + 1")
    set_property(GLOBAL PROPERTY _NORMALIZER_TEST_UNIT_ID ${id})
  endif()

  set(${testNameResultVariable} UnitNormalizerUnit${module}_${id})

  string(TOLOWER ${module} prefix)
  add_test(
    NAME ${${testNameResultVariable}}
    COMMAND
      ${CMAKE_COMMAND}
      -D NORMALIZER_TEST_MODULE=${module}
      -D NORMALIZER_TEST_COMMAND=normalizer_tests_unit_${prefix}_${testCommand}
      ${parsed_ARGS}
      -P ${CMAKE_CURRENT_SOURCE_DIR}/RunCMake.cmake
  )

  return(PROPAGATE ${testNameResultVariable})
endfunction()

# Test Normalizer/Config module. This runs:
# cmake \
#   -D NORMALIZER_TEST_MODULE=Config \
#   -D NORMALIZER_TEST_COMMAND=normalizer_tests_unit_config_default \
#   -P tests/Unit/RunCMake.cmake
normalizer_tests_unit(Config default testName)

set_tests_properties(
  ${testName}
  PROPERTIES PASS_REGULAR_EXPRESSION [[
^-- normalize_cmake_minimum_required=false
-- normalize_space_after_command=true
-- normalize_space_after_command_control_flow=false
-- normalize_space_after_command_disable=if;else;endif;while;endwhile;foreach;endforeach
-- normalize_commands=true
-- normalize_include_modules=true
-- normalize_include_modules_local=
-- normalize_indent_size=2
-- normalize_indent_style=space
-- normalize_newlines_final=true
-- normalize_newlines_leading=true
-- normalize_newlines_middle=true
-- normalize_newlines=true
-- normalize_obsolete_code=true
-- normalize_obsolete_end_commands=true
-- normalize_processorcount=true
-- normalize_set=true
-- normalize_trailing_whitespace_in_arguments=true
-- normalize_trailing_whitespace_in_bracket_comments=true
-- normalize_trailing_whitespace=true
$]]
)

# Test Normalizer/SelfUpdate module.
normalizer_tests_unit(
  SelfUpdate
  get_new_version
  testName
  ARGS -D NORMALIZER_TEST_FILE=${PROJECT_BINARY_DIR}/normalizer-${PROJECT_VERSION}.cmake
)

set_tests_properties(
  ${testName}
  PROPERTIES PASS_REGULAR_EXPRESSION "-- ${PROJECT_VERSION}"
)

# Test Tokenizer module.
normalizer_tests_unit(Tokenizer content _)
normalizer_tests_unit(Tokenizer unquoted_arguments_1 _)
normalizer_tests_unit(Tokenizer unquoted_arguments_2 _)
normalizer_tests_unit(Tokenizer non_cmake_content _)
normalizer_tests_unit(Tokenizer remove_tokens_1 _)
normalizer_tests_unit(Tokenizer remove_tokens_2 _)
normalizer_tests_unit(Tokenizer remove_tokens_3 _)
normalizer_tests_unit(Tokenizer remove_tokens_4 _)

# Test Normalizer/Timer module.
normalizer_tests_unit(Timer default _)
