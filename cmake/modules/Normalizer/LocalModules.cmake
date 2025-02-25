include(Tokenizer)

#[=============================================================================[
Normalizer/LocalModules

This module parses all local modules.

```cmake
include(Normalizer/LocalModules)

normalizer_execute()
```
#]=============================================================================]

function(normalizer_local_modules)
  string(MD5 localModulesId "${normalize_include_modules_local}")

  if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/.cmake-normalizer/${localModulesId}.txt)
    return()
  endif()

  set(namespace "normalizer_local_module")
  set(content "")
  foreach(path IN LISTS normalize_include_modules_local)
    if(NOT EXISTS ${path})
      continue()
    endif()

    if(IS_DIRECTORY ${path})
      set(baseDirectory ${path})
      file(GLOB_RECURSE foundFiles ${path}/*.cmake)
    else()
      set(baseDirectory "")
      set(foundFiles ${path})
    endif()

    foreach(module IN LISTS foundFiles)
      # Skip local Find* modules.
      cmake_path(GET module FILENAME filename)
      if(filename MATCHES "^Find.+")
        continue()
      endif()

      if(baseDirectory)
        file(
          RELATIVE_PATH
          moduleName
          ${baseDirectory}
          ${module}
        )
      else()
        set(moduleName ${module})
      endif()
      cmake_path(REMOVE_EXTENSION moduleName)

      string(APPEND content "${moduleName}\n")

      tokenizer_parse(FILE "${module}" NAMESPACE ${namespace})
      foreach(i IN LISTS ${namespace}_tokens)
        if(
          ${namespace}_${i}_id STREQUAL "T_COMMAND"
          AND ${namespace}_${i}_text MATCHES "^(function|macro)$"
        )
          list(GET ${namespace}_${i}_arguments 0 commandIndex)
          string(APPEND content "  ${${namespace}_${commandIndex}_text}\n")
        endif()
      endforeach()
    endforeach()
  endforeach()

  file(
    WRITE ${CMAKE_CURRENT_SOURCE_DIR}/.cmake-normalizer/${localModulesId}.txt
    "${content}"
  )
endfunction()

# normalizer_local_modules_parse(<result-variable>)
function(normalizer_local_modules_parse)
  string(MD5 localModulesId "${normalize_include_modules_local}")

  if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/.cmake-normalizer/${localModulesId}.txt)
    return()
  endif()

  file(
    STRINGS ${CMAKE_CURRENT_SOURCE_DIR}/.cmake-normalizer/${localModulesId}.txt
    lines
  )

  set(propagatedVariables "")
  foreach(line IN LISTS lines)
    if(line MATCHES "^  (.+)")
      list(APPEND module_${moduleId} ${CMAKE_MATCH_1})
      list(APPEND propagatedVariables module_${moduleId})
    else()
      string(MAKE_C_IDENTIFIER ${line} moduleId)
      list(APPEND ${ARGV0} ${line})
    endif()
  endforeach()

  return(PROPAGATE ${ARGV0} ${propagatedVariables})
endfunction()
