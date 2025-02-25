include_guard(GLOBAL)

#[=============================================================================[
Normalizer/Normalize

This module provides a common function to run multiple normalizations.
#]=============================================================================]

include(Normalizer/Normalize/CMakeMinimumRequired)
include(Normalizer/Normalize/Commands)
include(Normalizer/Normalize/Include)
include(Normalizer/Normalize/Indentation)
include(Normalizer/Normalize/Newlines)
include(Normalizer/Normalize/ObsoleteEndCommands)
include(Normalizer/Normalize/ObsoleteImmediateKeyword)
include(Normalizer/Normalize/ProcessorCountModule)
include(Normalizer/Normalize/Set)
include(Normalizer/Normalize/SpaceAfterCommand)
include(Normalizer/Normalize/Whitespace)

# Run multiple normalizations at once.
# normalizer_normalize(<content> <new-content-var> <new-messages-var> <file>)
function(normalizer_normalize)
  set(normalizations "")
  set(NORMALIZER_CURRENT_FILE ${ARGV3})

  if(normalize_commands)
    list(APPEND normalizations normalizer_normalize_commands)
  endif()

  if(normalize_obsolete_end_commands)
    list(APPEND normalizations normalizer_normalize_obsolete_end_commands)
  endif()

  if(normalize_obsolete_code)
    list(APPEND normalizations normalizer_normalize_obsolete_immediate_keyword)
  endif()

  if(normalize_set)
    list(APPEND normalizations normalizer_normalize_set)
  endif()

  if(normalize_space_after_command)
    list(APPEND normalizations normalizer_normalize_space_after_command)
  endif()

  if(normalize_processorcount)
    list(APPEND normalizations normalizer_normalize_processorcount)
  endif()

  if(normalize_cmake_minimum_required)
    list(APPEND normalizations normalizer_normalize_cmake_minimum_required)
  endif()

  foreach(normalization IN LISTS normalizations)
    if(COMMAND ${normalization}_init)
      cmake_language(CALL ${normalization}_init)
    endif()
  endforeach()

  set(${ARGV2} "")

  set(namespace "normalizer_tokens")
  tokenizer_parse(CONTENT "${ARGV0}" NAMESPACE ${namespace})

  foreach(i IN LISTS ${namespace}_tokens)
    foreach(normalization IN LISTS normalizations)
      cmake_language(CALL ${normalization} ${namespace} ${i} _newMessages)
      if(_newMessages)
        list(APPEND ${ARGV2} "${_newMessages}")
      endif()
    endforeach()
  endforeach()

  # Run normalizations with the current parsed tokens.

  # Normalize include calls.
  if(normalize_include_modules)
    normalizer_normalize_include(${namespace}_tokens _newMessages)
    if(_newMessages)
      list(APPEND ${ARGV2} "${_newMessages}")
    endif()
  endif()

  # Normalize trailing whitespace.
  if(
    normalize_trailing_whitespace
    OR normalize_trailing_whitespace_in_arguments
    OR normalize_trailing_whitespace_in_bracket_comments
  )
    normalizer_normalize_whitespace(${namespace}_tokens _newMessages)
    if(_newMessages)
      list(APPEND ${ARGV2} "${_newMessages}")
    endif()
  endif()

  # Normalize indent style.
  if(normalize_indent_style)
    normalizer_normalize_indentation(${namespace}_tokens _newMessages)
    if(_newMessages)
      list(APPEND ${ARGV2} "${_newMessages}")
    endif()
  endif()

  # Assemble normalized content string.
  set(${ARGV1} "")
  foreach(i IN LISTS ${namespace}_tokens)
    string(APPEND ${ARGV1} "${${namespace}_${i}_text}")
  endforeach()

  # Work on content directly.
  if(
    normalize_newlines
    OR normalize_newlines_leading
    OR normalize_newlines_middle
    OR normalize_newlines_final
  )
    normalizer_normalize_newlines(${ARGV1} ${ARGV2})
  endif()

  return(PROPAGATE ${ARGV1} ${ARGV2})
endfunction()
