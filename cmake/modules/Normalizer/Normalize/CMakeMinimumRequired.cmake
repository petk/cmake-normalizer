include_guard(GLOBAL)

#[=============================================================================[
Normalizer/Normalize/CMakeMinimumRequired

Normalizes the cmake_minimum_required(...) calls and usages.
#]=============================================================================]

include(Tokenizer)

# normalizer_normalize_cmake_minimum_required(<namespace> <token-index> <log>)
macro(normalizer_normalize_cmake_minimum_required)
  set(${ARGV2} "")

  if(
    ${ARGV0}_${ARGV1}_id STREQUAL "T_COMMAND"
    AND ${ARGV0}_${ARGV1}_text STREQUAL "cmake_minimum_required"
  )
    set(check false)

    foreach(argument IN LISTS ${ARGV0}_${ARGV1}_arguments)
      if(${ARGV0}_${argument}_text STREQUAL "VERSION")
        set(check true)
      elseif(
        check
        AND NOT ${ARGV0}_${argument}_text STREQUAL "${normalize_cmake_minimum_required}"
      )
        string(
          APPEND
          ${ARGV2}
          "cmake_minimum_required(VERSION ${${ARGV0}_${argument}_text}) -> cmake_minimum_required(VERSION ${normalize_cmake_minimum_required})"
        )
        set(${ARGV0}_${argument}_text "${normalize_cmake_minimum_required}")
        set(check FALSE)
      endif()
    endforeach()
  elseif(
    ${ARGV0}_${ARGV1}_id MATCHES "^T_(QUOTED|BRACKET)_ARGUMENT$"
    AND ${ARGV0}_${ARGV1}_text MATCHES "cmake_minimum_required\\(VERSION [0-9][0-9.]+.*\\)"
  )
    string(
      REGEX REPLACE
      "(cmake_minimum_required\\(VERSION )[0-9.]+(.*\\))"
      "\\1${normalize_cmake_minimum_required}\\2"
      buffer
      "${${ARGV0}_${ARGV1}_text}"
    )
    if(NOT buffer STREQUAL ${ARGV0}_${ARGV1}_text)
      set(${ARGV0}_${ARGV1}_text "${buffer}")
      string(
        APPEND
        ${ARGV2}
        "cmake_minimum_required(VERSION ...) -> cmake_minimum_required(VERSION ${normalize_cmake_minimum_required})"
      )
    endif()
  endif()
endmacro()
