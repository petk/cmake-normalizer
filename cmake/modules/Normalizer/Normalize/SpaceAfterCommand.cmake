include_guard(GLOBAL)

#[=============================================================================[
Normalizer/Normalize/SpaceAfterCommand

This module provides command to normalize whitespace after command. For example:
set  () -> set()
#]=============================================================================]

include(Tokenizer)

# normalizer_normalize_space_after_command(<namespace> <token-index> <log>)
macro(normalizer_normalize_space_after_command)
  set(${ARGV2} "")

  if(${ARGV0}_${ARGV1}_id STREQUAL "T_COMMAND")
    set(next ${${ARGV0}_${ARGV1}_next})

    if(
      normalize_space_after_command_control_flow
      AND ${ARGV0}_${ARGV1}_text IN_LIST normalize_space_after_command_disable
    )
      if(NOT ${ARGV0}_${next}_id STREQUAL "T_SPACE")
        string(
          APPEND
          ${ARGV2}
          "${${ARGV0}_${ARGV1}_text}(...) -> ${${ARGV0}_${ARGV1}_text} (...)"
        )
        tokenizer_insert_token(${ARGV0} ${ARGV1} T_SPACE " ")
      elseif(NOT ${ARGV0}_${next}_text STREQUAL " ")
        string(
          APPEND
          ${ARGV2}
          "${${ARGV0}_${ARGV1}_text}${${ARGV0}_${next}_text}(...) -> ${${ARGV0}_${ARGV1}_text} (...)"
        )
        set(${ARGV0}_${next}_text " ")
      endif()
    elseif(${ARGV0}_${next}_id STREQUAL "T_SPACE")
      string(
        APPEND
        ${ARGV2}
        "${${ARGV0}_${ARGV1}_text}${${ARGV0}_${next}_text}(...) -> ${${ARGV0}_${ARGV1}_text}(...)"
      )
      tokenizer_remove_token(${ARGV0} ${next})
    endif()
  endif()
endmacro()
