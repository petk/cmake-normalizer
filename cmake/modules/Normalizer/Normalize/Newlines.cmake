include_guard(GLOBAL)

#[=============================================================================[
Normalizer/Normalize/Newlines

Normalizes everything related to newlines.
#]=============================================================================]

include(Tokenizer)

# normalizer_normalize_newlines(<content> <log>)
function(normalizer_normalize_newlines)
  set(_buffer "${${ARGV0}}")

  if(normalize_newlines_leading)
    string(REGEX REPLACE "^[\n]+" "" ${ARGV0} "${${ARGV0}}")

    if(NOT _buffer STREQUAL ${ARGV0})
      list(APPEND ${ARGV1} "Redundant leading newlines")
    endif()
  endif()

  set(_buffer "${${ARGV0}}")
  set(_logsAtTheEnd "")

  if(normalize_newlines_final)
    string(REGEX REPLACE "[\n]+$" "\n" ${ARGV0} "${${ARGV0}}")

    if(NOT _buffer STREQUAL ${ARGV0})
      list(APPEND _logsAtTheEnd "Redundant final newlines")
    endif()

    if(NOT ${ARGV0} STREQUAL "" AND NOT ${ARGV0} MATCHES "\n$")
      string(APPEND ${ARGV0} "\n")
      list(APPEND _logsAtTheEnd "Missing final newline")
    endif()
  endif()

  set(_buffer "${${ARGV0}}")

  if(normalize_newlines_middle)
    string(REGEX REPLACE "\n\n[\n]+" "\n\n" ${ARGV0} "${${ARGV0}}")

    if(NOT _buffer STREQUAL ${ARGV0})
      list(APPEND ${ARGV1} "Redundant middle newlines")
    endif()
  endif()

  list(APPEND ${ARGV1} ${_logsAtTheEnd})

  return(PROPAGATE ${ARGV0} ${ARGV1})
endfunction()

#[==[
# normalizer_normalize_newlines(<tokens> <log>)
macro(normalizer_normalize_newlines_1)
  # tokens: ARGV0
  # messages output variable: ARGV1

  set(${ARGV1} "")

  set(_beginning true)

  foreach(i IN LISTS ${ARGV0})
    if(
      _beginning
      AND normalize_newlines_leading
      AND ${namespace}_${i}_id STREQUAL "T_NEWLINE"
    )
      tokenizer_remove_token(${namespace} ${i})
      list(
        APPEND
        ${ARGV1}
        "Redundant leading newlines"
      )
    elseif(_beginning)
      set(_beginning false)
    endif()

    if(
      NOT _beginning
      AND ${namespace}_${i}_id STREQUAL "T_NEWLINE"
      AND normalize_newlines_middle
    )
      set(next ${${namespace}_${i}_next})

      if(${namespace}_${next}_id STREQUAL "T_NEWLINE")
        tokenizer_remove_token(${namespace} ${i})

        list(
          APPEND
          ${ARGV1}
          "Redundant middle newlines"
        )
      elseif(${namespace}_${i}_text MATCHES "^\n\n[\n]+")
        set(${namespace}_${i}_text "\n\n")

        list(
          APPEND
          ${ARGV1}
          "Redundant middle newlines"
        )
      endif()
    elseif(
      NOT _beginning
      AND ${namespace}_${i}_id STREQUAL "T_EOF"
      AND normalize_newlines_final
    )
      set(previous ${${namespace}_${i}_previous})

      if(
        ${namespace}_${previous}_id STREQUAL "T_NEWLINE"
        AND ${namespace}_${previous}_text MATCHES "\n[\n]+"
      )
        list(
          APPEND
          ${ARGV1}
          "Redundant final newlines"
        )
        set(${namespace}_${previous}_text "\n")
      elseif(
        ${namespace}_${previous}_id
        AND NOT ${namespace}_${previous}_id STREQUAL "T_NEWLINE"
      )
        list(
          APPEND
          ${ARGV1}
          "Missing final newline"
        )
        set(${namespace}_${i}_text "\n")
      endif()
    endif()
  endforeach()
endmacro()
#]==]
