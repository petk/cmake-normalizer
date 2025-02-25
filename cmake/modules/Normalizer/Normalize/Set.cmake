include_guard(GLOBAL)

#[=============================================================================[
Normalizer/Normalize/Set

This module provides command to normalize the set(<variable>) usage without
value to unset(<variable>).
#]=============================================================================]

include(Tokenizer)

# normalizer_normalize_set(<namespace> <token-index> <log>)
macro(normalizer_normalize_set)
  set(${ARGV2} "")

  if(
    ${ARGV0}_${ARGV1}_id STREQUAL "T_COMMAND"
    AND ${ARGV0}_${ARGV1}_text MATCHES "^[sS][eE][tT]$"
  )
    list(LENGTH ${ARGV0}_${ARGV1}_arguments length)

    set(secondArgument "")
    if(length EQUAL 2)
      list(GET ${ARGV0}_${ARGV1}_arguments 1 secondArgument)
    endif()

    if(length EQUAL 1 OR ${ARGV0}_${secondArgument}_text STREQUAL "PARENT_SCOPE")
      tokenizer_get_command_arguments(${ARGV0} ${ARGV1} arguments)
      list(JOIN arguments " " arguments)
      string(
        APPEND
        ${ARGV2}
        "${${ARGV0}_${ARGV1}_text}(${arguments}) -> unset(${arguments})"
      )
      set(${ARGV0}_${ARGV1}_text "unset")
    endif()
  endif()
endmacro()
