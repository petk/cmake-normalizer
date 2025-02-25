include_guard(GLOBAL)

#[=============================================================================[
Normalizer/Normalize/Indentation
#]=============================================================================]

# normalizer_normalize_indentation(<tokens> <log>)
macro(normalizer_normalize_indentation)
  # tokens: ARGV0
  # messages output variable: ARGV1

  set(${ARGV1} "")
  string(REGEX REPLACE "_tokens$" "" _namespace "${ARGV0}")

  if(normalize_indent_style STREQUAL "space")
    set(indent " ")
  elseif(normalize_indent_style STREQUAL "tab")
    set(indent "\t")
  endif()

  string(REPEAT "${indent}" ${normalize_indent_size} indent)

  set(
    indentIncreasingCommands
      if
      function
      macro
      while
      foreach
      block
      cmake_push_check_state
  )

  set(indentMiddleCommands elseif else cmake_reset_check_state)

  set(
    indentDecreasingCommands
      endif
      endfunction
      endmacro
      endwhile
      endforeach
      endblock
      cmake_pop_check_state
  )

  # Determine if each cmake_push_check_state() has its matching
  # cmake_pop_check_state().
  set(pairs_1 "")
  set(pairs_2 "")
  foreach(i IN LISTS ${ARGV0})
    if(${_namespace}_${i}_id STREQUAL "T_COMMAND")
      if(${_namespace}_${previous}_text STREQUAL "cmake_push_check_state")
        list(APPEND pairs_1 true)
      elseif(${_namespace}_${previous}_text STREQUAL "cmake_pop_check_state")
        list(APPEND pairs_2 true)
      endif()
    endif()
  endforeach()
  if(NOT pairs_1 STREQUAL pairs_2)
    set(indentCMakePushCheckState false)
  else()
    set(indentCMakePushCheckState true)
  endif()

  set(indentationLevel 0)
  foreach(i IN LISTS ${ARGV0})
    set(previous ${${_namespace}_${i}_previous})
    set(next ${${_namespace}_${i}_next})

    if(
      ${_namespace}_${previous}_id STREQUAL "T_COMMAND"
      AND ${_namespace}_${previous}_text IN_LIST indentIncreasingCommands
    )
      math(EXPR indentationLevel "${indentationLevel} + 1")
    elseif(
      ${_namespace}_${previous}_id STREQUAL "T_NEWLINE"
      AND (
        (
          ${_namespace}_${i}_id STREQUAL "T_SPACE"
          AND ${_namespace}_${next}_id STREQUAL "T_COMMAND"
          AND ${_namespace}_${next}_text IN_LIST indentDecreasingCommands
        ) OR (
          ${_namespace}_${i}_id STREQUAL "T_COMMAND"
          AND ${_namespace}_${i}_text IN_LIST indentDecreasingCommands
        )
      )
    )
      if(indentationLevel GREATER 0)
        math(EXPR indentationLevel "${indentationLevel} - 1")
      endif()
    elseif(
      ${_namespace}_${previous}_id STREQUAL "T_NEWLINE"
      AND (
        (
          ${_namespace}_${i}_id STREQUAL "T_SPACE"
          AND ${_namespace}_${next}_id STREQUAL "T_COMMAND"
          AND ${_namespace}_${next}_text IN_LIST indentMiddleCommands
        ) OR (
          ${_namespace}_${i}_id STREQUAL "T_COMMAND"
          AND ${_namespace}_${i}_text IN_LIST indentMiddleCommands
        )
      )
    )
      if(indentationLevel GREATER 0)
        math(EXPR indentationLevel "${indentationLevel} - 1")
      endif()
    elseif(
      ${_namespace}_${previous}_id STREQUAL "T_COMMAND"
      AND ${_namespace}_${previous}_text IN_LIST indentMiddleCommands
    )
      math(EXPR indentationLevel "${indentationLevel} + 1")
    endif()

    string(REPEAT "${indent}" ${indentationLevel} indentation)

    #message(STATUS "${indentation}${${_namespace}_${i}_text}")
    #continue()

    if(${_namespace}_${i}_id STREQUAL "T_COMMAND")
      set(lastCommandArguments ${${_namespace}_${i}_all_arguments})
    endif()

    if(
      ${_namespace}_${${_namespace}_${i}_previous}_id STREQUAL "T_NEWLINE"
      AND ${_namespace}_${i}_id MATCHES "^T_(COMMAND|(BRACKET|LINE)_COMMENT|SPACE)$"
      AND NOT i IN_LIST lastCommandArguments
    )
      if(
        indentationLevel EQUAL 0
        AND NOT ${_namespace}_${i}_id STREQUAL "T_SPACE"
      )
        continue()
      elseif(NOT ${_namespace}_${i}_text STREQUAL indentation)
        if(${_namespace}_${i}_id STREQUAL "T_SPACE")
          set(${_namespace}_${i}_text "${indentation}")
          list(
            APPEND
            ${ARGV1}
            "indentation"
          )
        elseif(
          indentationLevel GREATER 0
          AND ${_namespace}_${i}_id STREQUAL "T_COMMAND"
          AND ${_namespace}_${i}_text IN_LIST indentMiddleCommands
        )
          continue()
        elseif(
          indentationLevel GREATER 0
          AND NOT ${_namespace}_${i}_id STREQUAL "T_NEWLINE"
        )
          tokenizer_insert_token(
            ${_namespace}
            ${${_namespace}_${i}_previous}
            "T_SPACE"
            "${indentation}"
          )
          list(
            APPEND
            ${ARGV1}
            "indentation"
          )
        endif()
      endif()
    endif()
  endforeach()
endmacro()
