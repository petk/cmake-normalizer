list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/../cmake/modules)

# Set version from the root CMakeLists.txt file.
block(PROPAGATE NORMALIZER_VERSION)
  file(
    STRINGS
    ${CMAKE_CURRENT_LIST_DIR}/../CMakeLists.txt
    _
    REGEX "^ [ ]+VERSION ([0-9.]+)$"
    LIMIT_COUNT 1
  )

  set(NORMALIZER_VERSION "${CMAKE_MATCH_1}")
endblock()
