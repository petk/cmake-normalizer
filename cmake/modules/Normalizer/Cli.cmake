include_guard(GLOBAL)

#[=============================================================================[
Normalizer/Cli

This module provides functions to parse command-line arguments when the
CMake command-line script is invoked:

  cmake ... -P <script-file> ... -- <script-file-options-and-arguments>...

## Functions

### normalizer_cli_add_argument()

Adds command-line argument.

```cmake
normalizer_cli_add_argument(
  RESULT_VARIABLE <result-variable>
  TYPE <type>
  [IS_ARRAY]
  [IS_REQUIRED]
  [DEFAULT <default-value>]
  HELP_ARGUMENT_PLACEHOLDER <placeholder>
  HELP <string>...
)
```

* `TYPE <type>` - The expected type of the argument. Supported types: `file`,
  `path`. If given command-line argument doesn't match this type and argument is
  required, execution is stopped and usage is printed.
#]=============================================================================]

# Get usage help text.
# normalizer_cli_get_usage(<result-variable>)
function(normalizer_cli_get_usage)
  cmake_path(GET CMAKE_CURRENT_LIST_FILE FILENAME _normalizerCliScript)
  cmake_path(GET CMAKE_CURRENT_LIST_FILE STEM _normalizerCliPrefix)
  string(TOLOWER "${_normalizerCliPrefix}" _normalizerCliPrefix)

  get_property(
    _normalizerCliSynopsis
    GLOBAL
    PROPERTY _NORMALIZER_CLI_USAGE_SYNOPSIS
  )

  if(DEFINED _normalizerCliSynopsis)
    string(PREPEND _normalizerCliSynopsis " --")
    string(
      APPEND
      _normalizerCliSynopsis
      " [<${_normalizerCliPrefix}-options>...] [--]"
    )
  endif()

  string(PREPEND _normalizerCliSynopsis "cmake -P ${_normalizerCliScript}")

  get_property(
    _normalizerCliUsageArguments
    GLOBAL
    PROPERTY _NORMALIZER_CLI_USAGE_ARGUMENTS
  )
  if(DEFINED _normalizerCliUsageArguments)
    string(PREPEND _normalizerCliUsageArguments "\nArguments:\n")
  endif()

  string(CONFIGURE [[
SYNOPSIS

  @_normalizerCliSynopsis@
  @_normalizerCliUsageArguments@
Options:

  --
    Marker indicating the end of command-line options. First one indicates to
    CMake the end of standard CMake command-line options, and the second one is
    for @_normalizerCliScript@ script to indicate that further options won't be
    parsed.
]] _normalizerCliDefaultUsage @ONLY)

  get_property(${ARGV0} GLOBAL PROPERTY _NORMALIZER_CLI_USAGE_OPTIONS)

  string(PREPEND ${ARGV0} "${_normalizerCliDefaultUsage}")

  return(PROPAGATE ${ARGV0})
endfunction()

# Get short usage help text.
# normalizer_cli_get_short_usage(<result-variable>)
function(normalizer_cli_get_short_usage)
  cmake_path(GET CMAKE_CURRENT_LIST_FILE FILENAME _normalizerCliScript)
  cmake_path(GET CMAKE_CURRENT_LIST_FILE STEM _normalizerCliPrefix)
  string(TOLOWER "${_normalizerCliPrefix}" _normalizerCliPrefix)

  get_property(
    _normalizerCliSynopsis
    GLOBAL
    PROPERTY _NORMALIZER_CLI_USAGE_SYNOPSIS
  )

  if(DEFINED _normalizerCliSynopsis)
    string(PREPEND _normalizerCliSynopsis " --")
    string(
      APPEND
      _normalizerCliSynopsis
      " [<${_normalizerCliPrefix}-options>...] [--]"
    )
  endif()

  string(PREPEND _normalizerCliSynopsis "cmake -P ${_normalizerCliScript}")

  string(CONFIGURE [[
SYNOPSIS
  @_normalizerCliSynopsis@

For more info see:
  cmake -P @_normalizerCliScript@ -- --help
]] ${ARGV0} @ONLY)

  return(PROPAGATE ${ARGV0})
endfunction()

# Print usage help text.
function(normalizer_cli_print_usage)
  normalizer_cli_get_usage(usage)

  message(STATUS "${usage}")

  if(DEFINED ARGV0)
    cmake_language(EXIT ${ARGV0})
  endif()
endfunction()

function(normalizer_cli_print_and_exit)
  cmake_parse_arguments(
    PARSE_ARGV
    0
    parsed # prefix
    "" # options
    "EXIT_CODE" # one-value keywords
    "MESSAGE" # multi-value keywords
  )

  if(NOT DEFINED parsed_EXIT_CODE)
    set(parsed_EXIT_CODE 0)
  endif()

  if(NOT DEFINED parsed_MESSAGE)
    set(parsed_MESSAGE "")
  endif()

  execute_process(COMMAND ${CMAKE_COMMAND} -E echo ${parsed_MESSAGE})
  cmake_language(EXIT ${parsed_EXIT_CODE})
endfunction()

function(normalizer_cli_add_argument)
  cmake_parse_arguments(
    PARSE_ARGV
    0
    parsed # prefix
    "IS_ARRAY;IS_REQUIRED" # options
    "HELP_ARGUMENT_PLACEHOLDER;RESULT_VARIABLE;TYPE;DEFAULT" # one-value keywords
    "HELP" # multi-value keywords
  )

  set(_normalizerCliHelp "")
  if(parsed_HELP)
    foreach(item IN LISTS parsed_HELP)
      string(APPEND _normalizerCliHelp "${item}")
    endforeach()
  endif()

  if(parsed_HELP_ARGUMENT_PLACEHOLDER)
    set(placeholder "${parsed_HELP_ARGUMENT_PLACEHOLDER}")
  elseif(parsed_IS_ARRAY)
    set(placeholder "<arguments...>")
  else()
    set(placeholder "<argument>")
  endif()

  if(parsed_IS_REQUIRED)
    set(synopsisPlaceholder "${placeholder}")
  else()
    set(synopsisPlaceholder "[${placeholder}]")
  endif()

  set_property(
    GLOBAL
    APPEND_STRING
    PROPERTY _NORMALIZER_CLI_USAGE_SYNOPSIS
    " ${synopsisPlaceholder}"
  )

  set_property(
    GLOBAL
    APPEND_STRING
    PROPERTY _NORMALIZER_CLI_USAGE_ARGUMENTS
    "\n  ${placeholder}\n    ${_normalizerCliHelp}\n"
  )

  get_property(counter GLOBAL PROPERTY _NORMALIZER_CLI_ARGUMENT_COUNTER)
  if(counter OR counter EQUAL 0)
    math(EXPR counter "${counter} + 1")
  else()
    set(counter 0)
  endif()
  set_property(GLOBAL PROPERTY _NORMALIZER_CLI_ARGUMENT_COUNTER "${counter}")

  set_property(
    GLOBAL
    PROPERTY
    _NORMALIZER_CLI_ARGUMENT_${counter}_IS_ARRAY
    ${parsed_IS_ARRAY}
  )

  set_property(
    GLOBAL
    PROPERTY
    _NORMALIZER_CLI_ARGUMENT_${counter}_IS_REQUIRED
    ${parsed_IS_REQUIRED}
  )

  if(parsed_RESULT_VARIABLE)
    set_property(
      GLOBAL
      PROPERTY
      _NORMALIZER_CLI_ARGUMENT_${counter}_RESULT_VARIABLE
      ${parsed_RESULT_VARIABLE}
    )
  endif()

  if(parsed_TYPE)
    set_property(
      GLOBAL
      PROPERTY _NORMALIZER_CLI_ARGUMENT_${counter}_TYPE ${parsed_TYPE}
    )
  endif()

  if(parsed_DEFAULT)
    set_property(
      GLOBAL
      PROPERTY _NORMALIZER_CLI_ARGUMENT_${counter}_DEFAULT ${parsed_DEFAULT}
    )
  endif()
endfunction()

function(normalizer_cli_parse_argument)
  cmake_parse_arguments(
    PARSE_ARGV
    0
    parsed # prefix
    "" # options
    "RESULT_VARIABLE" # one-value keywords
    "" # multi-value keywords
  )

  get_property(counter GLOBAL PROPERTY _NORMALIZER_CLI_ARGUMENT_COUNTER)

  if(counter GREATER_EQUAL 0 AND parsed_RESULT_VARIABLE)
    set(currentArgument 0)

    get_property(
      isArray
      GLOBAL PROPERTY _NORMALIZER_CLI_ARGUMENT_${currentArgument}_IS_ARRAY
    )

    get_property(
      _normalizerCliResultVariable
      GLOBAL PROPERTY _NORMALIZER_CLI_ARGUMENT_${currentArgument}_RESULT_VARIABLE
    )

    get_property(
      _normalizerCliType
      GLOBAL PROPERTY _NORMALIZER_CLI_ARGUMENT_${currentArgument}_TYPE
    )

    get_property(
      _normalizerCliDefault
      GLOBAL
      PROPERTY _NORMALIZER_CLI_ARGUMENT_${currentArgument}_DEFAULT
    )

    set(_normalizerCliPath ${ARGV0})
    set(_normalizerCliResetDefault false)
    if(_normalizerCliType STREQUAL "path")
      cmake_path(
        ABSOLUTE_PATH
        _normalizerCliPath
        BASE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        NORMALIZE
      )

      if(NOT EXISTS "${_normalizerCliPath}")
        message(NOTICE "Not found: ${_normalizerCliPath}")
        set(_normalizerCliResetDefault true)
        set(_normalizerCliPath "")
      endif()
    elseif(_normalizerCliType STREQUAL "file")
      cmake_path(
        ABSOLUTE_PATH
        _normalizerCliPath
        BASE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        NORMALIZE
      )

      if(NOT EXISTS "${_normalizerCliPath}")
        message(NOTICE "Not found: ${_normalizerCliPath}")
        set(_normalizerCliPath "")
        set(_normalizerCliResetDefault true)
      elseif(IS_DIRECTORY "${_normalizerCliPath}")
        message(
          NOTICE
          "Directory given but expected is file: ${_normalizerCliPath}"
        )
        set(_normalizerCliPath "")
        set(_normalizerCliResetDefault true)
      endif()
    endif()

    if(_normalizerCliResetDefault AND _normalizerCliDefault)
      set_property(
        GLOBAL
        PROPERTY _NORMALIZER_CLI_ARGUMENT_${currentArgument}_DEFAULT ""
      )
    endif()

    if(isArray)
      if(NOT _normalizerCliPath STREQUAL "")
        list(APPEND ${_normalizerCliResultVariable} "${_normalizerCliPath}")
      endif()
    else()
      set(${_normalizerCliResultVariable} "${_normalizerCliPath}")
    endif()
    set(${parsed_RESULT_VARIABLE} ${_normalizerCliResultVariable})
  endif()

  return(PROPAGATE ${parsed_RESULT_VARIABLE} ${_normalizerCliResultVariable})
endfunction()

function(normalizer_cli_add_option)
  cmake_parse_arguments(
    PARSE_ARGV
    0
    parsed # prefix
    "REPEATABLE;HAS_ARGUMENT;IS_INTEGER" # options
    "HELP_ARGUMENT_PLACEHOLDER;RESULT_VARIABLE;DEFAULT" # one-value keywords
    "CALL;HELP" # multi-value keywords
  )

  set(_normalizerCliHelp "")
  if(parsed_HELP)
    foreach(item IN LISTS parsed_HELP)
      string(APPEND _normalizerCliHelp "${item}")
    endforeach()
  endif()

  if(parsed_HELP_ARGUMENT_PLACEHOLDER)
    list(
      TRANSFORM
      ARGV0
      REPLACE
      "(.+)"
      "\\1 ${parsed_HELP_ARGUMENT_PLACEHOLDER},\\1=${parsed_HELP_ARGUMENT_PLACEHOLDER}"
      OUTPUT_VARIABLE options
    )
    string(REPLACE ";" "," option "${options}")
  else()
    string(REPLACE ";" "," option "${ARGV0}")
  endif()
  set_property(
    GLOBAL
    APPEND_STRING
    PROPERTY _NORMALIZER_CLI_USAGE_OPTIONS
    "\n  ${option}\n    ${_normalizerCliHelp}\n"
  )

  foreach(option IN LISTS ARGV0)
    string(MAKE_C_IDENTIFIER "${option}" optionId)
    set_property(GLOBAL PROPERTY _NORMALIZER_CLI_OPTION_${optionId} "${option}")

    if(parsed_HAS_ARGUMENT)
      set(_hasArgument true)
    else()
      set(_hasArgument false)
    endif()
    set_property(
      GLOBAL
      PROPERTY _NORMALIZER_CLI_OPTION_HAS_ARGUMENT_${optionId} ${_hasArgument}
    )

    if(DEFINED parsed_DEFAULT)
      set_property(
        GLOBAL
        PROPERTY _NORMALIZER_CLI_OPTION_${optionId}_DEFAULT "${parsed_DEFAULT}"
      )
    endif()

    if(parsed_IS_INTEGER)
      set_property(
        GLOBAL
        PROPERTY _NORMALIZER_CLI_OPTION_${optionId}_IS_INTEGER true
      )
    endif()

    if(parsed_RESULT_VARIABLE)
      set_property(
        GLOBAL
        PROPERTY _NORMALIZER_CLI_RESULT_VARIABLE_${optionId} ${parsed_RESULT_VARIABLE}
      )
    endif()

    if(parsed_REPEATABLE)
      set(_isRepeatable true)
    else()
      set(_isRepeatable false)
    endif()
    set_property(
      GLOBAL
      PROPERTY _NORMALIZER_CLI_OPTION_REPEATABLE_${optionId} ${_isRepeatable}
    )

    if(_normalizerCliHelp)
      set_property(
        GLOBAL
        PROPERTY _NORMALIZER_CLI_OPTION_HELP_${optionId} "${_normalizerCliHelp}"
      )
    endif()

    if(parsed_CALL)
      set_property(
        GLOBAL
        PROPERTY _NORMALIZER_CLI_OPTION_CALL_${optionId} "${parsed_CALL}"
      )
    endif()
  endforeach()
endfunction()

function(normalizer_cli_parse_option)
  cmake_parse_arguments(
    PARSE_ARGV
    0
    parsed # prefix
    "" # options
    "RESULT_VARIABLE" # one-value keywords
    "ARGUMENT" # multi-value keywords
  )

  set(option "${ARGV0}")

  if(option MATCHES "^(-[-]*[^=]+)=(.+)$")
    set(option "${CMAKE_MATCH_1}")
    set(parsed_ARGUMENT "${CMAKE_MATCH_2}")
  endif()

  string(MAKE_C_IDENTIFIER "${option}" optionId)

  if(NOT DEFINED parsed_ARGUMENT)
    get_property(
      _normalizerCliDefaultArgument
      GLOBAL
      PROPERTY _NORMALIZER_CLI_OPTION_${optionId}_DEFAULT
    )
    if(DEFINED _normalizerCliDefaultArgument)
      set(parsed_ARGUMENT "${_normalizerCliDefaultArgument}")
    endif()
  endif()

  # Validate argument
  get_property(
    _normalizerCliHasArgument
    GLOBAL
    PROPERTY _NORMALIZER_CLI_OPTION_HAS_ARGUMENT_${optionId}
  )

  if(_normalizerCliHasArgument AND NOT DEFINED parsed_ARGUMENT)
    normalizer_cli_get_short_usage(usage)
    normalizer_cli_print_and_exit(
      MESSAGE "\nError: ${option} option requires argument.\n\n${usage}"
      EXIT_CODE 1
    )
  elseif(_normalizerCliHasArgument)
    get_property(
      _normalizerCliArgumentIsInteger
      GLOBAL
      PROPERTY _NORMALIZER_CLI_OPTION_${optionId}_IS_INTEGER
    )

    if(_normalizerCliArgumentIsInteger AND NOT parsed_ARGUMENT MATCHES "[0-9]+")
      normalizer_cli_get_short_usage(usage)
      normalizer_cli_print_and_exit(
        MESSAGE "\nError: ${option} option accepts only integer numbers.\n\n${usage}"
        EXIT_CODE 1
      )
    endif()
  endif()

  set(propagatedVariables "")

  if(parsed_RESULT_VARIABLE)
    get_property(
      _normalizerCliResult
      GLOBAL
      PROPERTY _NORMALIZER_CLI_RESULT_VARIABLE_${optionId}
    )

    if(_normalizerCliResult)
      get_property(
        _isRepeatable
        GLOBAL
        PROPERTY _NORMALIZER_CLI_OPTION_REPEATABLE_${optionId}
      )

      if(_normalizerCliHasArgument AND DEFINED parsed_ARGUMENT)
        string(REPLACE ";" "\;" parsed_ARGUMENT "${parsed_ARGUMENT}")
        set(_value "${parsed_ARGUMENT}")
      else()
        set(_value true)
      endif()

      if(_isRepeatable)
        list(APPEND ${_normalizerCliResult} "${_value}")
      else()
        set(${_normalizerCliResult} "${_value}")
      endif()

      set(${parsed_RESULT_VARIABLE} ${_normalizerCliResult})

      list(
        APPEND
        propagatedVariables
        ${parsed_RESULT_VARIABLE}
        ${_normalizerCliResult}
      )
    endif()
  endif()

  get_property(
    _normalizerCliArguments
    GLOBAL
    PROPERTY _NORMALIZER_CLI_OPTION_CALL_${optionId}
  )

  if(_normalizerCliArguments)
    list(POP_FRONT _normalizerCliArguments _normalizerCliCommand)
    cmake_language(CALL ${_normalizerCliCommand} ${_normalizerCliArguments})
  endif()

  return(PROPAGATE ${propagatedVariables})
endfunction()

# Parse command-line arguments.
function(normalizer_cli_parse)
  cmake_parse_arguments(
    PARSE_ARGV
    0
    parsed # prefix
    "" # options
    "" # one-value keywords
    "" # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(parsed_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "Missing values for: ${parsed_KEYWORDS_MISSING_VALUES}")
  endif()

  message(DEBUG "Command-line arguments:")

  # Internal markers for the command-line arguments position.
  set(hasProcessOption FALSE)
  set(hasProcessOptionArgument FALSE)
  set(hasEndCommandsMarker FALSE)
  set(hasScriptArguments FALSE)
  set(isOptionArgument FALSE)
  set(_normalizerCliPropagatedVariables "")

  foreach(index RANGE ${CMAKE_ARGC})
    if(NOT DEFINED CMAKE_ARGV${index})
      continue()
    endif()

    message(DEBUG "  ${index}: ${CMAKE_ARGV${index}}")

    if(isOptionArgument)
      set(isOptionArgument FALSE)
      continue()
    endif()

    # Parse script-related command-line arguments:
    #   'cmake ... -P <cmake-script> ... -- [<cmake-script-arguments]
    if(NOT hasProcessOption AND CMAKE_ARGV${index} STREQUAL "-P")
      set(hasProcessOption TRUE)
      continue()
    endif()

    # Current argument is CMAKE_CURRENT_LIST_FILE.
    if(hasProcessOption AND NOT hasProcessOptionArgument)
      set(hasProcessOptionArgument TRUE)
      continue()
    endif()

    # If the '--' marker argument is given.
    if(
      hasProcessOption
      AND NOT hasEndCommandsMarker
      AND CMAKE_ARGV${index} STREQUAL "--"
    )
      set(hasEndCommandsMarker TRUE)
      continue()
    endif()

    # Skip any other possible CMake command-line options passed after the:
    # '-P <CMAKE_CURRENT_LIST_FILE>'.
    if(
      hasProcessOption
      AND NOT hasScriptArguments
      AND NOT hasEndCommandsMarker
      AND CMAKE_ARGV${index} MATCHES "^-.+"
    )
      normalizer_cli_validate_option("${CMAKE_ARGV${index}}" isSupported)
      if(NOT isSupported)
        continue()
      endif()
    endif()

    # Parse space-separated list of arguments.
    if(hasProcessOptionArgument AND NOT hasScriptArguments)
      # The next script arguments should be zero or more arguments.
      foreach(unparsedIndex RANGE ${index} ${CMAKE_ARGC})
        if(NOT DEFINED CMAKE_ARGV${unparsedIndex})
          continue()
        endif()

        if(CMAKE_ARGV${unparsedIndex} MATCHES "^-.+")
          break()
        endif()

        if(CMAKE_ARGV${unparsedIndex})
          normalizer_cli_parse_argument(
            ${CMAKE_ARGV${unparsedIndex}}
            RESULT_VARIABLE result
          )

          list(APPEND _normalizerCliPropagatedVariables ${result})
        endif()
      endforeach()

      set(hasScriptArguments TRUE)
    endif()

    # Parse script-related command-line options.
    if(hasScriptArguments)
      # Check options for known patterns.
      if(CMAKE_ARGV${index} STREQUAL "--")
        break()
      elseif(CMAKE_ARGV${index} MATCHES "^-")
        normalizer_cli_validate_option("${CMAKE_ARGV${index}}" isSupported)

        if(NOT isSupported AND hasEndCommandsMarker)
          normalizer_cli_get_short_usage(usage)
          normalizer_cli_print_and_exit(
            MESSAGE "\nError: Unrecognized option '${CMAKE_ARGV${index}}'\n\n${usage}"
            EXIT_CODE 1
          )
        elseif(isSupported)
          # Check if next is argument-alike item.
          set(argument "")
          math(EXPR next "${index} + 1")
          if(DEFINED CMAKE_ARGV${next} AND NOT CMAKE_ARGV${next} MATCHES "^-.*")
            set(argument ARGUMENT "${CMAKE_ARGV${next}}")
          endif()
          normalizer_cli_parse_option(
            "${CMAKE_ARGV${index}}"
            ${argument}
            RESULT_VARIABLE result
          )
          list(APPEND _normalizerCliPropagatedVariables ${result})
        endif()
      endif()
    endif()
  endforeach()

  normalizer_cli_validate_arguments(result)
  list(APPEND _normalizerCliPropagatedVariables ${result})

  list(REMOVE_DUPLICATES _normalizerCliPropagatedVariables)
  return(PROPAGATE ${_normalizerCliPropagatedVariables})
endfunction()

# Check if given command-line option is supported by the script.
# normalizer_cli_validate_option(
#   <command-line-option>
#   <is-supported-result-variable>
# )
function(normalizer_cli_validate_option)
  set(${ARGV1} false)

  if(ARGV0 MATCHES "^(-[-]*[^=]+)=(.+)$")
    set(option "${CMAKE_MATCH_1}")
    set(argument "${CMAKE_MATCH_2}")
  else()
    set(option "${ARGV0}")
  endif()

  string(MAKE_C_IDENTIFIER "${option}" optionId)

  get_property(
    _normalizerCliOption
    GLOBAL
    PROPERTY _NORMALIZER_CLI_OPTION_${optionId}
  )

  if(DEFINED _normalizerCliOption)
    set(${ARGV1} true)
  endif()

  return(PROPAGATE ${ARGV1})
endfunction()

# Output a given <question> and prompt for user input.
# normalizer_cli_prompt(<question> <answer-result-variable>)
function(normalizer_cli_prompt)
  find_program(
    BASH
    NAMES bash bash.exe
    PATHS "c:/msys64/usr/bin" "$ENV{PROGRAMFILES}/Git/bin"
  )

  string(CONFIGURE [[
    >&2 echo -n "@ARGV0@ "
    read answer
    echo "${answer}"
    >&2 echo ""
  ]] _normalizerCliScript @ONLY)

  execute_process(
    COMMAND ${BASH} "-c" "${_normalizerCliScript}"
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
    OUTPUT_VARIABLE ${ARGV1}
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_STRIP_TRAILING_WHITESPACE
  )

  return(PROPAGATE ${ARGV1})
endfunction()

function(normalizer_cli_validate_arguments)
  get_property(counter GLOBAL PROPERTY _NORMALIZER_CLI_ARGUMENT_COUNTER)

  if(counter GREATER_EQUAL 0)
    set(currentArgument 0)

    get_property(
      _normalizerCliIsRequired
      GLOBAL
      PROPERTY _NORMALIZER_CLI_ARGUMENT_${currentArgument}_IS_REQUIRED
    )

    if(_normalizerCliIsRequired)
      get_property(
        _normalizerCliResultVariable
        GLOBAL
        PROPERTY _NORMALIZER_CLI_ARGUMENT_${currentArgument}_RESULT_VARIABLE
      )
    endif()
  endif()

  if("${${_normalizerCliResultVariable}}" STREQUAL "")
    get_property(
      _normalizerCliDefault
      GLOBAL
      PROPERTY _NORMALIZER_CLI_ARGUMENT_${currentArgument}_DEFAULT
    )

    if(_normalizerCliDefault)
      set(${_normalizerCliResultVariable} "${_normalizerCliDefault}")
    endif()
  endif()

  if(
    _normalizerCliIsRequired
    AND "${${_normalizerCliResultVariable}}" STREQUAL ""
  )
    normalizer_cli_get_short_usage(usage)
    normalizer_cli_print_and_exit(
      MESSAGE "\nError: Missing arguments.\n\n${usage}"
      EXIT_CODE 1
    )
  endif()

  set(${ARGV0} ${_normalizerCliResultVariable})
  return(PROPAGATE ${ARGV0} ${_normalizerCliResultVariable})
endfunction()
