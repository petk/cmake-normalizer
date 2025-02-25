include_guard(GLOBAL)

#[=============================================================================[
Normalizer/SelfUpdate

This module provides functions to self update the normalizer.cmake script from
command-line.
#]=============================================================================]

#
# Update current running normalizer script to the latest version.
#
# normalizer_self_update([<url>])
#
#   <url> - The URL where to find the file to download.
#
function(normalizer_self_update)
  if(NOT CMAKE_CURRENT_FUNCTION_LIST_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
    message(
      NOTICE
      "Error: Self updating is not enabled in development mode. It can\n"
      "       be performed only when running the packaged all-in-one\n"
      "       normalizer.cmake script."
    )
    cmake_language(EXIT 1)
  endif()

  set(url "${ARGV0}")
  if(NOT url)
    set(url "https://github.com/petk/cmake-normalizer/releases/latest/download/normalizer.cmake")
  endif()

  string(TIMESTAMP timestamp %s)
  set(file ${CMAKE_CURRENT_BINARY_DIR}/.normalizer-${timestamp}.cmake)

  file(DOWNLOAD "${url}" ${file})

  file(MD5 ${CMAKE_CURRENT_LIST_FILE} currentHash)
  file(MD5 ${file} newHash)

  cmake_path(
    RELATIVE_PATH
    CMAKE_CURRENT_LIST_FILE
    BASE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    OUTPUT_VARIABLE currentFilename
  )

  if(currentHash STREQUAL newHash)
    message(
      NOTICE
      "${currentFilename} is already at the latest version "
      "${NORMALIZER_VERSION}"
    )

    file(REMOVE ${file})

    cmake_language(EXIT 0)
  endif()

  normalizer_self_update_get_new_version("${file}" newVersion)

  if(NOT newVersion)
    message(
      NOTICE
      "Error: ${currentFilename} could not be updated to latest version\n"
      "       because the version could not be found in the downloaded file.\n"
      "       Try updating ${currentFilename} manually from GitHub:\n\n"
      "       https://github.com/petk/cmake-normalizer/releases"
    )

    file(REMOVE ${file})

    cmake_language(EXIT 1)
  endif()

  if(newVersion VERSION_LESS NORMALIZER_VERSION)
    message(
      NOTICE
      "Error: ${currentFilename} could not be updated because the latest\n"
      "       found version ${newVersion} is earlier than current ${NORMALIZER_VERSION}.\n"
      "       If this is a bug, please try updating ${currentFilename}\n"
      "       manually from GitHub:\n\n"
      "       https://github.com/petk/cmake-normalizer/releases"
    )

    file(REMOVE "${file}")

    cmake_language(EXIT 1)
  endif()

  file(READ ${file} newContent)
  file(REMOVE ${file})
  file(WRITE ${CMAKE_CURRENT_LIST_FILE} "${newContent}")

  message(
    NOTICE
    "${currentFilename} has been updated from version ${NORMALIZER_VERSION} "
    "to ${newVersion}"
  )

  cmake_language(EXIT 0)
endfunction()

# Read normalizer version from given <file> and store it to <result-variable>.
# normalizer_self_update_get_new_version(<file> <result-variable>)
function(normalizer_self_update_get_new_version)
  set(regex "^set\\(NORMALIZER_VERSION \"([0-9.]+)\"\\)$")

  file(STRINGS ${ARGV0} _ REGEX "${regex}" LIMIT_COUNT 1 LIMIT_INPUT 500)

  set(${ARGV1} "${CMAKE_MATCH_1}")

  return(PROPAGATE ${ARGV1})
endfunction()
