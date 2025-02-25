include_guard(GLOBAL)

#[=============================================================================[
Normalizer/Normalize/Commands

Normalizes known commands to their common style. For example, builtin CMake
commands have style of 'lowercase_snake_case()'.

A list of commands in this file is automatically updated with cmake invocation
when generating final normalizer.cmake script.
#]=============================================================================]

include(Normalizer/Data)

function(normalizer_normalize_commands_init)
  normalizer_data_commands(_NORMALIZER_NORMALIZE_COMMANDS)
  list(
    TRANSFORM
    _NORMALIZER_NORMALIZE_COMMANDS
    TOLOWER
    OUTPUT_VARIABLE _NORMALIZER_NORMALIZE_COMMANDS_LOWERCASE
  )

  return(
    PROPAGATE
      _NORMALIZER_NORMALIZE_COMMANDS
      _NORMALIZER_NORMALIZE_COMMANDS_LOWERCASE
  )
endfunction()

# normalizer_normalize_commands(<namespace> <token-index> <log>)
macro(normalizer_normalize_commands)
  set(${ARGV2} "")

  if(${ARGV0}_${ARGV1}_id STREQUAL "T_COMMAND")
    string(TOLOWER "${${ARGV0}_${ARGV1}_text}" currentCommandLowerCase)
    if(
      currentCommandLowerCase IN_LIST _NORMALIZER_NORMALIZE_COMMANDS_LOWERCASE
      AND NOT ${ARGV0}_${ARGV1}_text IN_LIST _NORMALIZER_NORMALIZE_COMMANDS
    )
      list(
        FIND
        _NORMALIZER_NORMALIZE_COMMANDS_LOWERCASE
        "${currentCommandLowerCase}"
        index
      )
      list(GET _NORMALIZER_NORMALIZE_COMMANDS ${index} normalizedCommand)
      list(APPEND ${ARGV2} "${${ARGV0}_${ARGV1}_text} -> ${normalizedCommand}")
      set(${ARGV0}_${ARGV1}_text "${normalizedCommand}")
    endif()
  endif()

  unset(currentCommandLowerCase)
  unset(index)
  unset(normalizedCommand)
endmacro()
