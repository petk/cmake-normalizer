function(normalizer_test_cli)
  cmake_parse_arguments(
    PARSE_ARGV
    0
    parsed # prefix
    "" # options
    "WILL_FAIL" # one-value keywords
    "ARGS;REGEX" # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(parsed_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "Missing values for: ${parsed_KEYWORDS_MISSING_VALUES}")
  endif()

  get_property(id GLOBAL PROPERTY _NORMALIZER_TEST_CLI_ID)
  if(NOT id)
    set(id 1)
    set_property(GLOBAL PROPERTY _NORMALIZER_TEST_CLI_ID ${id})
  else()
    math(EXPR id "${id} + 1")
    set_property(GLOBAL PROPERTY _NORMALIZER_TEST_CLI_ID ${id})
  endif()

  set(willFailArgument "")
  if(DEFINED parsed_WILL_FAIL)
    if(parsed_WILL_FAIL)
      set(willFailArgument WILL_FAIL true)
    else()
      set(willFailArgument WILL_FAIL false)
    endif()
  endif()

  add_test(
    NAME NormalizerIntegration_${id}
    COMMAND Normalizer::Executable -- ${parsed_ARGS}
  )
  set_tests_properties(
    NormalizerIntegration_${id}
    PROPERTIES
      PASS_REGULAR_EXPRESSION "${parsed_REGEX}"
      ${willFailArgument}
  )
endfunction()

################################################################################
# Test command-line options.
################################################################################

normalizer_test_cli(
  ARGS -v
  REGEX "${PROJECT_VERSION}"
)

normalizer_test_cli(
  ARGS --version
  REGEX "normalizer\\.cmake ${PROJECT_VERSION}"
)

normalizer_test_cli(
  ARGS ${PROJECT_SOURCE_DIR}/tests/data/code/clean.cmake --asdf
  WILL_FAIL true
)

normalizer_test_cli(
  ARGS ${PROJECT_SOURCE_DIR}/tests/data/code/clean.cmake -- --asdf
)

normalizer_test_cli(
  ARGS --asdf --version
  WILL_FAIL true
)

normalizer_test_cli(
  ARGS --version --asdf
)

normalizer_test_cli(
  ARGS --version -- --asdf
)

normalizer_test_cli(
  ARGS
    ${PROJECT_SOURCE_DIR}/tests/data/code/clean.cmake
    --config ${PROJECT_SOURCE_DIR}/.cmake
)

normalizer_test_cli(
  ARGS
    ${PROJECT_SOURCE_DIR}/tests/data/code/clean.cmake
    --config=${PROJECT_SOURCE_DIR}/.cmake
)

normalizer_test_cli(
  ARGS ${PROJECT_SOURCE_DIR}/tests/data/code/clean.cmake --config
  WILL_FAIL true
)

normalizer_test_cli(
  ARGS ${PROJECT_SOURCE_DIR}/tests/data --not "*.cmake"
)

################################################################################
# Test --self-update option.
################################################################################

include(SelfUpdate.cmake)

################################################################################
# Test normalizations.
################################################################################

normalizer_test_cli(
  ARGS ${PROJECT_SOURCE_DIR}/tests/data/code/immediate_keyword.cmake
  REGEX
    "- configure_file\\(\\.\\.\\. IMMEDIATE\\) -> configure_file\\(\\.\\.\\.\\)"
)

normalizer_test_cli(
  ARGS ${PROJECT_SOURCE_DIR}/tests/data/code/obsolete_end_commands.cmake
  REGEX [[
--     - endif\(NOT EXISTS \${PROJECT_SOURCE_DIR}/build/gen_s...\) -> endif\(\)
--     - endif\(NOT FOOBAR MATCHES condition\) -> endif\(\)
--     - endif \(...\) -> endif\(...\)
--     - endif\(NOT FOO AND \(BAR STREQUAL "value_1"\\\n  OR BAZ...\) -> endif\(\)
--     - else\(foobar\) -> else\(\)
--     - endif\(foobar\) -> endif\(\)
--     - endforeach\(i\) -> endforeach\(\)
--     - endwhile\(counter LESS 5\) -> endwhile\(\)
--     - endfunction\(foo\) -> endfunction\(\)
--     - endmacro\(bar\) -> endmacro\(\)
]]
)

normalizer_test_cli(
  ARGS ${PROJECT_SOURCE_DIR}/tests/data/code/commands.cmake
  REGEX [[
--     - FUNCTION -> function
--     - SET -> set
--     - SET -> set
--     - GET_PROPERTY -> get_property
--     - FOREACH -> foreach
--     - STRING -> string
--     - ConTinuE -> continue
--     - EndIf -> endif
--     - endif \(...\) -> endif\(...\)
--     - IF -> if
--     - MESSAGE -> message
--     - SET -> set
--     - BREAK -> break
--     - EndIf -> endif
--     - CMAKE_LANGUAGE -> cmake_language
--     - SET -> set
--     - ENDFUNCTION -> endfunction
--     - FETCHCONTENT_DECLARE -> FetchContent_Declare
--     - fetchcontent_makeavailable -> FetchContent_MakeAvailable
]]
)

normalizer_test_cli(
  ARGS ${PROJECT_SOURCE_DIR}/tests/data/code/space_after_command.cmake
  REGEX
"--     - add_custom_target \\(...\\) -> add_custom_target\\(...\\)
--     - set \\(...\\) -> set\\(...\\)
--     - set [ ]+\\(...\\) -> set\\(...\\)
--     - set[ \t]+\\(...\\) -> set\\(...\\)
--     - set[ \t]+\\(...\\) -> set\\(...\\)
--     - set[ \t]+\\(...\\) -> set\\(...\\)
--     - set[ \t]+\\(...\\) -> set\\(...\\)
--     - set[ \t]+\\(...\\) -> set\\(...\\)
--     - if \\(...\\) -> if\\(...\\)
--     - while[ \t]+\\(...\\) -> while\\(...\\)
--     - endwhile[ \t]+\\(...\\) -> endwhile\\(...\\)
"
)

normalizer_test_cli(
  ARGS
    ${PROJECT_SOURCE_DIR}/tests/data/code/space_after_command.cmake
    --set normalize_space_after_command_control_flow=true
  REGEX
"--     - add_custom_target \\(...\\) -> add_custom_target\\(...\\)
--     - set \\(...\\) -> set\\(...\\)
--     - set [ ]+\\(...\\) -> set\\(...\\)
--     - set[ \t]+\\(...\\) -> set\\(...\\)
--     - set[ \t]+\\(...\\) -> set\\(...\\)
--     - set[ \t]+\\(...\\) -> set\\(...\\)
--     - set[ \t]+\\(...\\) -> set\\(...\\)
--     - set[ \t]+\\(...\\) -> set\\(...\\)
--     - while[ \t]+\\(...\\) -> while \\(...\\)
--     - else\\(...\\) -> else \\(...\\)
--     - endif\\(...\\) -> endif \\(...\\)
"
)

normalizer_test_cli(
  ARGS ${PROJECT_SOURCE_DIR}/tests/data/code/set.cmake
  REGEX [[
--     - set\(variable_2\) -> unset\(variable_2\)
--     - set\(variable_3\) -> unset\(variable_3\)
--     - set\(variable_4\) -> unset\(variable_4\)
--     - set\(variable_5 PARENT_SCOPE\) -> unset\(variable_5 PARENT_SCOPE\)
]]
)

normalizer_test_cli(
  ARGS ${PROJECT_SOURCE_DIR}/tests/data/code/trailing_whitespace.cmake
  REGEX [[
--     - trailing whitespace
--     - trailing whitespace
--     - trailing whitespace
--     - trailing whitespace
--     - trailing whitespace
--     - trailing whitespace
--     - trailing whitespace
--     - trailing whitespace
--     - trailing whitespace
--     - trailing whitespace
--     - trailing whitespace
--     - trailing whitespace
--     - trailing whitespace
--     - trailing whitespace
--     - trailing whitespace
--     - trailing whitespace
--     - indentation
--     - Redundant leading newlines
--     - Redundant middle newlines
--     - Redundant final newlines
]]
)

normalizer_test_cli(
  ARGS ${PROJECT_SOURCE_DIR}/tests/data/code/include.cmake
  REGEX [[
--     - check_include_file\(\) -> missing include\(CheckIncludeFile\)
--     - Redundant include\(CheckPrototypeDefinition\)
]]
)

normalizer_test_cli(
  ARGS
    ${PROJECT_SOURCE_DIR}/tests/data/code/cmake_minimum_required.cmake
    --set=normalize_cmake_minimum_required=3.25...3.31
  REGEX [[
--     - cmake_minimum_required\(VERSION 3.25\) -> cmake_minimum_required\(VERSION 3.25...3.31\)
--     - cmake_minimum_required\(VERSION 3.11...3.20\) -> cmake_minimum_required\(VERSION 3.25...3.31\)
--     - cmake_minimum_required\(VERSION ...\) -> cmake_minimum_required\(VERSION 3.25...3.31\)
--     - cmake_minimum_required\(VERSION ...\) -> cmake_minimum_required\(VERSION 3.25...3.31\)
]]
)
