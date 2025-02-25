include_guard(GLOBAL)

#[=============================================================================[
Normalizer/Config

This module provides function(s) to manage normalizer configuration.
#]=============================================================================]

#[=============================================================================[
Set default configuration.

normalizer_config_default(
  [ALL | VARIABLE <configuration-variable>]
  [KEYS <keys-variable>]
)

  ALL
    When this option is used, all configuration values are set to default values
    in the parent scope.

  VARIABLE <configuration-variable>
    When this option is used, only the provided <configuration-variable> is set
    to its default value in the parent scope.

  KEYS <keys-variable>
    When this option is used the <keys-variable> is populated to all supported
    configuration keys. And keys are set to default configuration in the parent
    scope.
#]=============================================================================]
function(normalizer_config_default)
  # Default configuration.
  set(
    _keys
      normalize_cmake_minimum_required
      normalize_space_after_command
      normalize_space_after_command_control_flow
      normalize_space_after_command_disable
      normalize_commands
      normalize_include_modules
      normalize_include_modules_local
      normalize_indent_size
      normalize_indent_style
      normalize_newlines_final
      normalize_newlines_leading
      normalize_newlines_middle
      normalize_newlines
      normalize_obsolete_code
      normalize_obsolete_end_commands
      normalize_processorcount
      normalize_set
      normalize_trailing_whitespace_in_arguments
      normalize_trailing_whitespace_in_bracket_comments
      normalize_trailing_whitespace
  )

  set(normalize_cmake_minimum_required false)
  set(normalize_space_after_command true)
  set(normalize_space_after_command_control_flow false)
  set(
    normalize_space_after_command_disable
    if else endif while endwhile foreach endforeach
  )
  set(normalize_commands true)
  set(normalize_include_modules true)
  set(normalize_include_modules_local "")
  set(normalize_indent_size 2)
  set(normalize_indent_style space)
  set(normalize_newlines_final true)
  set(normalize_newlines_leading true)
  set(normalize_newlines_middle true)
  set(normalize_newlines true)
  set(normalize_obsolete_code true)
  set(normalize_obsolete_end_commands true)
  set(normalize_processorcount true)
  set(normalize_set true)
  set(normalize_trailing_whitespace_in_arguments true)
  set(normalize_trailing_whitespace_in_bracket_comments true)
  set(normalize_trailing_whitespace true)

  cmake_parse_arguments(
    PARSE_ARGV
    0
    parsed # prefix
    "ALL" # options
    "KEYS;VARIABLE" # one-value keywords
    "" # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(parsed_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "Missing values for: ${parsed_KEYWORDS_MISSING_VALUES}")
  endif()

  if(parsed_ALL AND parsed_VARIABLE)
    message(
      FATAL_ERROR
      "${CMAKE_CURRENT_FUNCTION}: Use either the ALL option or set a specific "
      "VARIABLE <configuration-variable>"
    )
  endif()

  set(propagatedVariables "")

  if(parsed_KEYS)
    set(${parsed_KEYS} ${_keys})
    list(APPEND propagatedVariables ${parsed_KEYS})
  endif()

  if(parsed_VARIABLE)
    list(FIND _keys ${parsed_VARIABLE} _default)

    if(_default EQUAL -1)
      message(
        WARNING
        "${CMAKE_CURRENT_FUNCTION}: requested variable ${parsed_VARIABLE} "
        "could not be found in the default configuration list."
      )
      return()
    endif()

    list(APPEND propagatedVariables ${parsed_VARIABLE})
  endif()

  # Set all configuration variables to their default values.
  if(parsed_ALL)
    list(APPEND propagatedVariables ${_keys})
  endif()

  return(PROPAGATE ${propagatedVariables})
endfunction()

# Set configuration.
# normalizer_config([<path-to-configuration>])
function(normalizer_config)
  set(path "${ARGV0}")

  # Default configuration.
  normalizer_config_default(ALL KEYS keys)

  # If local configuration file exists, overwrite the configuration values.
  if(path AND EXISTS "${path}" AND NOT IS_DIRECTORY "${path}")
    include(${path})
  elseif(path AND EXISTS "${path}/.cmake")
    include(${path}/.cmake)
  elseif(path AND EXISTS "${path}/cmake/.cmake")
    include(${path}/cmake/.cmake)
  endif()

  # If configuration was also set by the --set command-line options.
  foreach(config IN LISTS NORMALIZER_CONFIGURATIONS)
    string(FIND "${config}" "=" position)
    string(SUBSTRING "${config}" 0 "${position}" variable)

    if(NOT variable IN_LIST keys)
      continue()
    endif()

    math(EXPR position "${position} + 1")
    string(SUBSTRING "${config}" "${position}" -1 value)
    set("${variable}" "${value}")
  endforeach()

  # Validate configuration.
  foreach(key IN LISTS keys)
    string(REPLACE "normalize_" "" subkey "${key}")
    if(COMMAND "normalizer_config_validate_${subkey}")
      cmake_language(CALL "normalizer_config_validate_${subkey}")
    else()
      # Assume all other configurations are booleans.
      normalizer_config_validate_boolean(${key})
    endif()
  endforeach()

  return(PROPAGATE ${keys})
endfunction()

# Validate boolean configuration variables.
function(normalizer_config_validate_boolean)
  set(variable "${ARGV0}")

  normalizer_config_is_boolean(${variable} isBoolean)

  if(NOT isBoolean)
    set(currentValue "${${variable}}")
    normalizer_config_default(VARIABLE ${variable})
    message(
      AUTHOR_WARNING
      "Configuration '${variable}' has unrecognized value '${currentValue}'. "
      "Setting to default '${${variable}}'."
    )
  endif()

  return(PROPAGATE ${variable})
endfunction()

# Validate normalize_indent_size configuration variable.
function(normalizer_config_validate_indent_size)
  set(key "normalize_indent_size")

  if(NOT ${key} MATCHES "^[0-9]$")
    set(currentValue "${${key}}")
    normalizer_config_default(VARIABLE ${key})
    message(
      AUTHOR_WARNING
      "Configuration '${key}' has unrecognized value '${currentValue}'. "
      "Setting to default '${${key}}'."
    )
  endif()

  return(PROPAGATE ${key})
endfunction()

# Validate normalize_indent_style configuration variable.
function(normalizer_config_validate_indent_style)
  set(key "normalize_indent_style")

  normalizer_config_is_boolean(${key} isBoolean)

  if(NOT ${key} MATCHES "^(space|tab)$" AND NOT isBoolean)
    set(currentValue "${${key}}")
    normalizer_config_default(VARIABLE ${key})
    message(
      AUTHOR_WARNING
      "Configuration '${key}' has unrecognized value '${currentValue}'. "
      "Setting to default '${${key}}'."
    )
  endif()

  # If set to truthy value, set it to default 'space'.
  if(isBoolean AND ${key})
    normalizer_config_default(VARIABLE ${key})
  endif()

  return(PROPAGATE ${key})
endfunction()

# Check if given variable <variable> is boolean and store the result in the
# variable named <result>.
# normalizer_config_is_boolean(<variable> <result>)
function(normalizer_config_is_boolean)
  string(TOLOWER "${${ARGV0}}" variableLowerCase)
  set(${ARGV1} FALSE)

  if(
    variableLowerCase MATCHES "^(on|off|yes|no|y|n|true|false|ignore|0|1|)$"
    OR ${ARGV0} MATCHES "(^|-)NOTFOUND$"
  )
    set(${ARGV1} TRUE)
  endif()

  return(PROPAGATE ${ARGV1})
endfunction()

# Check if given variable <variable> is false boolean and store the result in
# the variable named <result>.
# normalizer_config_is_false_boolean(<variable> <result>)
function(normalizer_config_is_false_boolean)
  string(TOLOWER "${${ARGV0}}" variableLowerCase)
  set(${ARGV1} FALSE)

  if(
    variableLowerCase MATCHES "^(off|no|n|false|ignore|0)$"
    OR ${ARGV0} MATCHES "(^|-)NOTFOUND$"
  )
    set(${ARGV1} TRUE)
  endif()

  return(PROPAGATE ${ARGV1})
endfunction()

function(normalizer_config_validate_space_after_command_disable)
  return(PROPAGATE normalize_space_after_command_disable)
endfunction()

function(normalizer_config_validate_include_modules_local)
  return(PROPAGATE normalize_include_modules_local)
endfunction()

function(normalizer_config_validate_cmake_minimum_required)
  set(key "normalize_cmake_minimum_required")

  normalizer_config_is_false_boolean(${key} isFalseBoolean)

  if(NOT isFalseBoolean AND NOT ${key} MATCHES "^[0-9][0-9.]*[0-9]$")
    set(currentValue "${${key}}")
    normalizer_config_default(VARIABLE ${key})
    message(
      AUTHOR_WARNING
      "Configuration '${key}' has unrecognized value '${currentValue}'. "
      "Setting to default '${${key}}'."
    )
  endif()

  return(PROPAGATE ${key})
endfunction()
