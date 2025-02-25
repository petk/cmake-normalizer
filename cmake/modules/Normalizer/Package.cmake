include_guard(GLOBAL)

#[=============================================================================[
Normalizer/Package

This module provides functions to help package CMake files into all-in-one
script/module for easier usage in the projects.
#]=============================================================================]

include(Tokenizer)

# Package normalizer script into a single all-in-one CMake file.
function(normalizer_package file output version)
  if(NOT EXISTS "${file}")
    message(FATAL_ERROR "File not found: ${file}")
  endif()

  file(READ "${file}" content)

  string(
    REPLACE
    [[include(${CMAKE_CURRENT_LIST_DIR}/../cmake/development.cmake)]]
    ""
    content
    "${content}"
  )

  # Add normalizer configuration.
  include(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../../../.cmake)

  normalizer_package_include_modules(content "init")

  set(namespace "normalizer_tokens")
  message(STATUS "Removing comments and include_guard() calls")
  tokenizer_parse(CONTENT "${content}" NAMESPACE ${namespace})
  foreach(i IN LISTS ${namespace}_tokens)
    normalizer_package_cleanup(${namespace} ${i})
  endforeach()

  set(content "")
  foreach(i IN LISTS ${namespace}_tokens)
    string(APPEND content "${${namespace}_${i}_text}")
  endforeach()

  # Assemble together header with shebang and some basic description.
  block(PROPAGATE content)
    file(READ ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../../../LICENSE license)
    string(STRIP "${license}" license)

    string(CONFIGURE [[
#!/usr/bin/env -S cmake -P
set(NORMALIZER_VERSION "@version@")
#[=============================================================================[
normalizer.cmake

Checks and fixes CMake code style.

https://github.com/petk/cmake-normalizer

SYNOPSIS

  cmake -P normalizer.cmake -- [<paths>...] [<normalizer-options>] [--]

See help for more info:
  cmake -P normalizer.cmake -- --help

LICENSE

@license@
#]=============================================================================]
]] header @ONLY)

    string(PREPEND content "${header}")
  endblock()

  # Trim trailing whitespace and redundant newlines.
  string(REGEX REPLACE "[ \t]+\n" "\n" content "${content}")
  string(REGEX REPLACE "\n\n[\n]+" "\n\n" content "${content}")

  file(WRITE "${output}" "${content}")
endfunction()

# Remove single, multi line comments and include_guard() calls.
macro(normalizer_package_cleanup _namespace _index)
  if(${_namespace}_${_index}_id MATCHES "T_(LINE|BRACKET)_COMMENT$")
    tokenizer_remove_token(${_namespace} ${_index})
    set(previous ${${_namespace}_${_index}_previous})
    set(previousPrevious ${${_namespace}_${previous}_previous})
    if(
      ${_namespace}_${previous}_id STREQUAL "T_SPACE"
      AND ${_namespace}_${previousPrevious}_id STREQUAL "T_NEWLINE"
    )
      tokenizer_remove_token(${_namespace} ${previous})
      set(next ${${_namespace}_${_index}_next})
      tokenizer_remove_token(${_namespace} ${next})
    elseif(${_namespace}_${previous}_id STREQUAL "T_NEWLINE")
      set(next ${${_namespace}_${_index}_next})
      tokenizer_remove_token(${_namespace} ${next})
    endif()
  elseif(
    ${_namespace}_${_index}_id STREQUAL "T_COMMAND"
    AND ${_namespace}_${_index}_text STREQUAL "include_guard"
  )
    tokenizer_remove_token(${_namespace} ${_index})
  endif()
endmacro()

# Add all local included modules as inline content.
function(normalizer_package_include_modules)
  set(content "${${ARGV0}}")
  set(namespace ${ARGV1})

  tokenizer_parse(CONTENT "${content}" NAMESPACE ${namespace})

  set(content "")

  set(wip FALSE)
  foreach(i IN LISTS ${namespace}_tokens)
    if(
      ${namespace}_${i}_id STREQUAL "T_COMMAND"
      AND ${namespace}_${i}_text STREQUAL "include"
    )
      list(GET ${namespace}_${i}_arguments 0 moduleIndex)
      set(module "${${namespace}_${moduleIndex}_text}")

      if(
        NOT module MATCHES "\\.cmake$"
        AND EXISTS ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../${module}.cmake
      )
        set(wip TRUE)

        string(APPEND module ".cmake")
        set(moduleRelativePath "${module}")

        cmake_path(
          ABSOLUTE_PATH
          module
          BASE_DIRECTORY ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/..
          NORMALIZE
        )

        get_property(
          includedModules
          GLOBAL
          PROPERTY _NORMALIZER_INCLUDED_MODULES
        )

        if(module IN_LIST includedModules)
          continue()
        endif()

        file(READ ${module} includedContent)

        message(STATUS "Adding cmake/modules/${moduleRelativePath}")

        file(MD5 ${module} newNamespace)
        cmake_language(
          CALL ${CMAKE_CURRENT_FUNCTION} includedContent ${newNamespace}
        )

        string(APPEND content "${includedContent}\n")

        set_property(
          GLOBAL
          APPEND
          PROPERTY _NORMALIZER_INCLUDED_MODULES ${module}
        )
      endif()
    elseif(wip AND ${namespace}_${i}_id STREQUAL "T_PAREN_OPEN")
      continue()
    elseif(wip AND ${namespace}_${i}_id MATCHES "^T_(UN)?QUOTED_ARGUMENT$")
      continue()
    elseif(wip AND ${namespace}_${i}_id STREQUAL "T_PAREN_CLOSE")
      set(wip FALSE)
      continue()
    endif()

    if(NOT wip)
      string(APPEND content "${${namespace}_${i}_text}")
    endif()
  endforeach()

  set(${ARGV0} "${content}" PARENT_SCOPE)
endfunction()
