# Lorem ipsum dolor sit amet.
FUNCTION(foo_bar)
  SET(result ${ARGV0})
  SET(extensions ${${ARGV0}})

  GET_PROPERTY(bar GLOBAL PROPERTY FOO_BAR)

  FOREACH(extension IN LISTS extensions)
    STRING(TOUPPER "${extension}" extensionUpper)

    if(NOT FOO_EXT_${extensionUpper})
      ConTinuE()
    EndIf ()

    if(DEFINED FOO_EXT_${extensionUpper}_SHARED)
      mark_as_advanced(FOO_EXT_${extensionUpper}_SHARED)
    endif()

    # Lorem ipsum dolor sit amet.
    foreach(dependency IN LISTS dependencies)
      string(TOUPPER "${dependency}" dependencyUpper)

      IF(
        FOO_EXT_${dependencyUpper}_SHARED
        AND NOT FOO_EXT_${extensionUpper}_SHARED
      )
        MESSAGE(
          WARNING
          "Lorem ipsum '${extension}' extension must be built as a shared "
          "its dependency '${dependency}' extension is configured as shared. "
          "The 'FOO_EXT_${extensionUpper}_SHARED' option has been "
          "automatically set to 'ON'."
        )

        SET(
          FOO_EXT_${extensionUpper}_SHARED
          ON
          CACHE BOOL
          "Build the ${extension} extension as a shared library"
          FORCE
        )

        BREAK()
      EndIf()
    endforeach()
  endforeach()

  # Validate extensions and their dependencies after extensions are configured.
  CMAKE_LANGUAGE(DEFER CALL _foo_extensions_validate)

  SET(${result} ${${result}} PARENT_SCOPE)
ENDFUNCTION()

include(FetchContent)
FETCHCONTENT_DECLARE(
  foobar
  URL https://example.com

  PATCH_COMMAND
    ${CMAKE_COMMAND}
    -P
    ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/Foo/patch.cmake
)

fetchcontent_makeavailable(foobar)
