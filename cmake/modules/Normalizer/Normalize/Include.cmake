include_guard(GLOBAL)

#[=============================================================================[
Normalizer/Normalize/Include

Normalizes modules usages. Each module command should have its accompanying
include() call somewhere in the current file. It also checks if there are
redundant/unused include() calls.
#]=============================================================================]

include(Normalizer/Data)
include(Tokenizer)

# Check included modules and called commands.
# normalizer_normalize_include(<tokens> <log>)
function(normalizer_normalize_include)
  # A list of CMake modules that shouldn't be reported as redundant includes
  # because they also provide functionality as they are included.
  set(
    modulesWithoutRedundancy
    CPack
    GNUInstallDirs
  )

  set(${ARGV1} "")

  string(REGEX REPLACE "_tokens$" "" _namespace "${ARGV0}")

  normalizer_data_modules(_modules _commands "")
  set(_includedModules "")
  set(_usedModules "")

  foreach(i IN LISTS ${ARGV0})
    if(
      ${_namespace}_${i}_id STREQUAL "T_COMMAND"
      AND ${_namespace}_${i}_text MATCHES "^[iI][nN][cC][lL][uU][dD][eE]$"
    )
      list(GET ${_namespace}_${i}_arguments 0 _moduleIndex)
      set(_module "${${_namespace}_${_moduleIndex}_text}")
      if(_module IN_LIST _modules)
        list(APPEND _includedModules ${_module})
      endif()
    endif()

    if(
      ${_namespace}_${i}_id STREQUAL "T_COMMAND"
      AND ${_namespace}_${i}_text IN_LIST _commands
    )
      normalizer_data_modules(_modulesByCommand _ ${${_namespace}_${i}_text})

      if(_modulesByCommand)
        list(APPEND _usedModules ${_modulesByCommand})
      endif()

      set(ok false)

      foreach(_module IN LISTS _modulesByCommand)
        if(
          _module IN_LIST _includedModules
          # If the current file is the local module itself it doesn't need to be
          # included:
          OR "${NORMALIZER_CURRENT_FILE}" MATCHES "${_module}.cmake$"
        )
          set(ok true)
        endif()
      endforeach()
      if(NOT ok)
        list(TRANSFORM _modulesByCommand REPLACE "(.+)" "include\(\\1\)")
        list(JOIN _modulesByCommand " or " _modulesByCommand)

        list(
          APPEND
          ${ARGV1}
          "${${_namespace}_${i}_text}() -> missing ${_modulesByCommand}"
        )
      endif()
    endif()
  endforeach()

  list(REMOVE_DUPLICATES _usedModules)

  set(_redundantModules "")
  foreach(module IN LISTS _includedModules)
    if(module IN_LIST _usedModules)
      list(REMOVE_ITEM _usedModules ${module})
      continue()
    elseif(module IN_LIST modulesWithoutRedundancy)
      continue()
    else()
      list(
        APPEND
        ${ARGV1}
        "Redundant include(${module})"
      )
    endif()
  endforeach()

  return(PROPAGATE ${ARGV1})
endfunction()
