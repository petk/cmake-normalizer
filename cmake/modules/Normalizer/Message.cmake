include_guard(GLOBAL)

#[=============================================================================[
Normalizer/Message

This module wraps the CMake's message() command and outputs the content based on
the quiet option. It can also optionally log messages to log files.
#]=============================================================================]

function(normalizer_message)
  if(NORMALIZER_LOG AND ARGV0 STREQUAL "STATUS")
    set(_arguments ${ARGV})
    list(POP_FRONT _arguments)

    list(JOIN _arguments "" _message)
    file(APPEND ${NORMALIZER_LOG} "-- ${CMAKE_MESSAGE_INDENT}${_message}\n")
  endif()

  if(NORMALIZER_QUIET)
    return()
  endif()

  message(${ARGV})
endfunction()
