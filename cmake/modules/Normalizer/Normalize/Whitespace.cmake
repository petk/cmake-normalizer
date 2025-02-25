include_guard(GLOBAL)

#[=============================================================================[
Normalizer/Normalize/Whitespace

Normalizes everything related to horizontal whitespace.
#]=============================================================================]

include(Tokenizer)

# normalizer_normalize_whitespace(<tokens> <log>)
macro(normalizer_normalize_whitespace)
  set(${ARGV1} "")
  string(REGEX REPLACE "_tokens$" "" _namespace "${ARGV0}")

  foreach(i IN LISTS ${ARGV0})
    if(
      ${_namespace}_${i}_id STREQUAL "T_SPACE"
      AND normalize_trailing_whitespace
    )
      set(next ${${_namespace}_${i}_next})

      # If next is newline or end of file.
      if(${_namespace}_${next}_id MATCHES "^T_(NEWLINE|EOF)$")
        list(APPEND ${ARGV1} "trailing whitespace")
        tokenizer_remove_token(${_namespace} ${i})
      endif()
    elseif(
      ${_namespace}_${i}_id STREQUAL "T_LINE_COMMENT"
      AND normalize_trailing_whitespace
      AND ${_namespace}_${i}_text MATCHES "[ \t]+$"
    )
      string(STRIP "${${_namespace}_${i}_text}" ${_namespace}_${i}_text)
      list(APPEND ${ARGV1} "trailing whitespace")
    elseif(
      (
        ${_namespace}_${i}_id MATCHES "^T_(BRACKET|QUOTED)_ARGUMENT$"
        AND normalize_trailing_whitespace_in_arguments
      ) OR (
        ${_namespace}_${i}_id MATCHES "^T_BRACKET_COMMENT$"
        AND normalize_trailing_whitespace_in_bracket_comments
      )
    )
      string(
        REGEX REPLACE
        "[ \t]+\n"
        "\n"
        ${_namespace}_${i}_text
        "${${_namespace}_${i}_text}"
      )
    endif()
  endforeach()
endmacro()
