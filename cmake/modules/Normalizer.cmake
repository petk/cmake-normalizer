include_guard(GLOBAL)

#[=============================================================================[
Normalizer

This module provides commands to run all configured normalizations.

```cmake
include(Normalizer)

normalizer_execute()
```
#]=============================================================================]

include(Normalizer/Cli)
include(Normalizer/Config)
include(Normalizer/LocalModules)
include(Normalizer/Message)
include(Normalizer/Normalize)
include(Normalizer/Progress)

function(normalizer_execute)
  cmake_parse_arguments(
    PARSE_ARGV
    0
    parsed # prefix
    "" # options
    "EXIT_CODE_VARIABLE;CONFIG;FIX" # one-value keywords
    "PATHS;SKIP" # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  # If no values are given, bypass the some missing keyword values error.
  foreach(item IN ITEMS CONFIG FIX SKIP)
    if(NOT parsed_${item})
      list(REMOVE_ITEM parsed_KEYWORDS_MISSING_VALUES "${item}")
    endif()
  endforeach()

  if(parsed_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "Missing values for: ${parsed_KEYWORDS_MISSING_VALUES}")
  endif()

  normalizer_validate_config(parsed_CONFIG)
  normalizer_config(${parsed_CONFIG})
  normalizer_validate_paths(parsed_PATHS parsed_SKIP files)

  # Add local modules to the list of commands and includes to check.
  if(normalize_include_modules_local AND NOT DEFINED NORMALIZER_PARALLEL)
    normalizer_local_modules()
  endif()

  # Print configuration:
  block()
    cmake_language(GET_MESSAGE_LOG_LEVEL logLevel)
    if(logLevel MATCHES "^(DEBUG|TRACE)$")
      message(DEBUG "Configuration:")
      message(DEBUG "  NORMALIZER_CONFIG=${NORMALIZER_CONFIG}")
      message(DEBUG "  NORMALIZER_FIX=${NORMALIZER_FIX}")
      message(DEBUG "  NORMALIZER_PATH=${NORMALIZER_PATH}")
      message(DEBUG "  NORMALIZER_SKIP=${NORMALIZER_SKIP}")
      message(DEBUG "  NORMALIZER_PARALLEL=${NORMALIZER_PARALLEL}")

      normalizer_config_default(KEYS keys)

      foreach(key IN LISTS keys)
        message(DEBUG "  ${key}=${${key}}")
      endforeach()
    endif()
  endblock()

  string(JOIN "\n   " paths ${parsed_PATHS})

  list(LENGTH files length)

  set(info "")
  foreach(path IN LISTS parsed_PATHS)
    if(IS_DIRECTORY "${path}")
      string(APPEND info "   Found ${length} CMake-related")
      if(length EQUAL 1)
        string(APPEND info " file\n")
      else()
        string(APPEND info " files\n")
      endif()
      break()
    endif()
  endforeach()

  if(parsed_FIX)
    normalizer_message(STATUS "FIXING:\n   ${paths}\n${info}")

    normalizer_cli_prompt(
      "Files in given path(s) will be overwritten. Do you want to continue? [N/y]"
      response
    )
    if(NOT response)
      normalizer_message(STATUS "Exiting without fixing files.")
      cmake_language(EXIT 1)
    endif()
  else()
    normalizer_message(STATUS "CHECKING:\n   ${paths}\n${info}")
  endif()

  set(${parsed_EXIT_CODE_VARIABLE} 0)

  set(status 0)
  set(filesCount 0)

  normalizer_progress_start(${length})

  if(DEFINED NORMALIZER_PARALLEL)
    set(filesPool ${files})

    set(options "")

    if(NORMALIZER_CONFIG)
      list(APPEND options "--config=${NORMALIZER_CONFIG}")
    endif()

    foreach(config IN LISTS NORMALIZER_CONFIGURATIONS)
      list(APPEND options "--set=${config}")
    endforeach()

    while(filesPool)
      set(arguments "")
      set(processedFiles "")

      foreach(i RANGE 1 ${NORMALIZER_PARALLEL})
        list(POP_FRONT filesPool file)

        if(NOT file)
          break()
        endif()

        list(
          APPEND
          arguments
          COMMAND
            ${CMAKE_COMMAND}
            -P ${CMAKE_CURRENT_LIST_FILE}
            --
            ${file}
            -q
            ${options}
        )

        list(APPEND processedFiles ${file})
      endforeach()

      if(arguments)
        execute_process(${arguments})
      endif()

      foreach(file IN LISTS processedFiles)
        file(MD5 ${file} fileId)
        if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/.cmake-normalizer/${fileId}.txt)
          file(READ ${CMAKE_CURRENT_SOURCE_DIR}/.cmake-normalizer/${fileId}.txt content)
          string(REGEX REPLACE "^-- " "" content "${content}")
          message(STATUS "${content}")
          file(REMOVE ${CMAKE_CURRENT_SOURCE_DIR}/.cmake-normalizer/${fileId}.txt)
        endif()
      endforeach()
    endwhile()
  else()
    if(parsed_FIX)
      set(operation "fix")
    else()
      set(operation "check")
    endif()
    foreach(file IN LISTS files)
      normalizer_normalize_file(${file} newStatus ${operation})
      if(NOT newStatus EQUAL 0)
        set(status ${newStatus})
        math(EXPR filesCount "${filesCount} + 1")
      endif()
    endforeach()
  endif()

  set(arguments "")

  if(parsed_EXIT_CODE_VARIABLE)
    set(${parsed_EXIT_CODE_VARIABLE} ${status})
    list(APPEND arguments ${parsed_EXIT_CODE_VARIABLE})
  endif()

  if(filesCount EQUAL 1)
    if(parsed_FIX)
      set(output "Fixed 1 of ${length} files")
    else()
      set(output "1 of ${length} files found to fix")
    endif()
  elseif(filesCount EQUAL 0)
    set(output "Checked ${length} files")
  else()
    if(parsed_FIX)
      set(output "Fixed ${filesCount} of ${length} files")
    else()
      set(output "${filesCount} of ${length} files found to fix")
    endif()
  endif()

  if(arguments)
    list(PREPEND arguments PROPAGATE)
  endif()

  normalizer_message(STATUS "${output}")

  return(${arguments})
endfunction()

################################################################################
# Validate configuration path.
# TODO: Configuration is for now taken only from the first item in
# NORMALIZER_PATH.
################################################################################
# normalizer_validate_config(<config-path-variable>)
function(normalizer_validate_config)
  if(NOT ${ARGV0})
    list(GET NORMALIZER_PATH 0 ${ARGV0})
    if(NOT IS_DIRECTORY "${${ARGV0}}")
      cmake_path(GET ${ARGV0} PARENT_PATH ${ARGV0})
    endif()
  else()
    cmake_path(
      ABSOLUTE_PATH
      ${ARGV0}
      BASE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      NORMALIZE
    )
    if(IS_DIRECTORY "${${ARGV0}}")
      message(
        WARNING
        "The configuration option argument should be a path to a configuration "
        "file."
      )
      set(${ARGV0} "")
    elseif(NOT EXISTS "${${ARGV0}}")
      message(
        WARNING
        "${${ARGV0}} not found. Configuration will be searched in default paths."
      )
      set(${ARGV0} "")
    endif()
  endif()

  return(PROPAGATE ${ARGV0})
endfunction()

################################################################################
# Check files.
################################################################################
function(normalizer_validate_paths)
  set(${ARGV2} "")
  foreach(path IN LISTS ${ARGV0})
    if(IS_DIRECTORY "${path}")
      file(
        GLOB_RECURSE
        foundFiles
        ${path}/CMakeLists.txt
        ${path}/*.cmake
      )

      # Check if some files should be skipped.
      if(${ARGV1})
        set(filteredFiles "")
        foreach(file IN LISTS foundFiles)
          set(skip false)
          foreach(item IN LISTS ${ARGV1})
            # If item is glob expression.
            if(item MATCHES "\\*")
              string(REPLACE "*" ".*" regex "${item}")

              cmake_path(
                RELATIVE_PATH
                file
                BASE_DIRECTORY ${path}
                OUTPUT_VARIABLE fileRelative
              )

              if(fileRelative MATCHES "${regex}")
                set(skip true)
                break()
              endif()
            else()
              cmake_path(
                ABSOLUTE_PATH
                item
                BASE_DIRECTORY ${path}
                NORMALIZE
              )

              cmake_path(IS_PREFIX item "${file}" NORMALIZE skip)

              if(skip)
                break()
              endif()
            endif()
          endforeach()

          if(skip)
            continue()
          endif()

          list(APPEND filteredFiles "${file}")
        endforeach()
        set(foundFiles "${filteredFiles}")
      endif()

      list(APPEND ${ARGV2} ${foundFiles})
    elseif(EXISTS "${path}")
      list(APPEND ${ARGV2} ${path})
    endif()
  endforeach()

  cmake_path(NORMAL_PATH ${ARGV2})
  return(PROPAGATE ${ARGV2})
endfunction()

# normalizer_normalize_file(<file> <exit-code-variable> <operation>)
function(normalizer_normalize_file)
  set(${ARGV1} 0)

  normalizer_progress(percentage)
  message(DEBUG "[${percentage}%] Processing ${ARGV0}")

  file(READ ${ARGV0} content)
  set(buffer "${content}")

  set(messages "")

  # Run normalizations.
  normalizer_normalize(
    "${buffer}"
    newContent
    newMessages
    ${ARGV0}
  )
  if(newMessages)
    set(buffer "${newContent}")
    set(${ARGV1} 1)
    list(APPEND messages ${newMessages})
  endif()

  list(LENGTH NORMALIZER_PATH length)
  if(length EQUAL 1 AND IS_DIRECTORY "${NORMALIZER_PATH}")
    cmake_path(
      RELATIVE_PATH
      ARGV0
      BASE_DIRECTORY ${NORMALIZER_PATH}
      OUTPUT_VARIABLE relative
    )
  else()
    set(relative "${ARGV0}")
  endif()

  if(NORMALIZER_QUIET)
    file(MD5 ${ARGV0} fileId)
    set(NORMALIZER_LOG ${CMAKE_CURRENT_SOURCE_DIR}/.cmake-normalizer/${fileId}.txt)
  endif()

  if(NOT content STREQUAL buffer OR ${ARGV1} EQUAL 1)
    if(ARGV2 STREQUAL "fix")
      normalizer_message(STATUS "> ${relative} fixed")
      file(WRITE ${ARGV0} "${buffer}")
    else()
      normalizer_message(STATUS "✘ ${relative}")
    endif()

    list(APPEND CMAKE_MESSAGE_INDENT "    - ")
    foreach(message IN LISTS messages)
      normalizer_message(STATUS "${message}")
    endforeach()
    list(POP_BACK CMAKE_MESSAGE_INDENT)
  else()
    message(VERBOSE "✔ ${relative}")
  endif()

  return(PROPAGATE ${ARGV1})
endfunction()
