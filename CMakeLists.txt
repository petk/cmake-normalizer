cmake_minimum_required(VERSION 3.29...3.31)

if(CMAKE_BINARY_DIR PATH_EQUAL CMAKE_CURRENT_LIST_DIR)
  message(
    FATAL_ERROR
    "In-source builds are disabled. Please, set the build directory.\n"
    "For example:\n"
    "  cmake -B out\n"
    "  cmake --build out -j"
  )
endif()

project(
  Normalizer
  VERSION 0.0.1
  DESCRIPTION "Normalizer for CMake code"
  HOMEPAGE_URL "https://github.com/petk/cmake-normalizer"
  LANGUAGES NONE
)

################################################################################
# Configuration.
################################################################################

# Most recent CMake version used when updating CMake commands collection.
set(NORMALIZER_CMAKE_VERSION 3.31)

# Add paths where include() and find_package() look for modules.
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake/modules)

################################################################################
# Update collection of CMake commands.
################################################################################

block()
  if(CMAKE_VERSION VERSION_GREATER_EQUAL ${NORMALIZER_CMAKE_VERSION})
    set(script ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/Normalizer/commands.cmake)

    file(
      CONFIGURE
      OUTPUT ${script}
      CONTENT [[
        cmake_minimum_required(VERSION @NORMALIZER_CMAKE_VERSION@)
        execute_process(
          COMMAND ${CMAKE_COMMAND} --help-command-list
          OUTPUT_VARIABLE commands
        )

        separate_arguments(commands NATIVE_COMMAND "${commands}")

        set(
          file
          "@CMAKE_CURRENT_SOURCE_DIR@/cmake/modules/Normalizer/Data.cmake"
        )
        file(READ ${file} content)

        string(
          REGEX REPLACE
          "# Commands([^#]+)# Commands"
          "# Commands\n    ${commands}\n    # Commands"
          newContent
          "${content}"
        )

        cmake_path(
          RELATIVE_PATH file
          BASE_DIRECTORY "@CMAKE_CURRENT_SOURCE_DIR@"
          OUTPUT_VARIABLE relativePath
        )

        if(NOT newContent STREQUAL content)
          file(WRITE ${file} "${newContent}")
          message(
            STATUS
            "Updated ${relativePath} for CMake "
            "${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}"
          )
        endif()
      ]]
      @ONLY
    )

    add_custom_target(
      normalizer_update_commands
      COMMAND ${CMAKE_COMMAND} -P ${script}
    )
  endif()
endblock()

################################################################################
# Generate normalizer-X.Y.Z.cmake.
################################################################################

block()
  set(script ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/Normalizer/package.cmake)
  set(output ${CMAKE_CURRENT_BINARY_DIR}/normalizer-${PROJECT_VERSION}.cmake)

  file(
    CONFIGURE
    OUTPUT ${script}
    CONTENT [[
      cmake_minimum_required(VERSION 3.29...3.31)
      list(APPEND CMAKE_MODULE_PATH "@CMAKE_CURRENT_SOURCE_DIR@/cmake/modules")
      include(Normalizer/Package)
      normalizer_package(
        "@CMAKE_CURRENT_SOURCE_DIR@/bin/normalizer.cmake"
        "@output@"
        "@PROJECT_VERSION@"
      )
    ]]
    @ONLY
  )

  cmake_path(
    RELATIVE_PATH output
    BASE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    OUTPUT_VARIABLE outputRelative
  )

  add_custom_target(
    normalizer
    ALL
    DEPENDS
      $<TARGET_NAME_IF_EXISTS:normalizer_update_commands>
    COMMAND ${CMAKE_COMMAND} -P ${script}
    COMMENT "Generating ${outputRelative}"
  )

  set_property(
    DIRECTORY
    APPEND
    PROPERTY CMAKE_CONFIGURE_DEPENDS
      LICENSE
      README.md
  )

  # Imported target for using generated normalizer-X.Y.Z.cmake script in tests.
  add_executable(Normalizer::Executable IMPORTED GLOBAL)
  set_target_properties(
    Normalizer::Executable
    PROPERTIES
      IMPORTED_LOCATION "${output}"
      TEST_LAUNCHER "${CMAKE_COMMAND};-P"
  )
endblock()

################################################################################
# Tests.
################################################################################

enable_testing()
add_subdirectory(tests)
