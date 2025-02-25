math(EXPR newVersion "${PROJECT_VERSION_PATCH} + 1")
set(newVersion "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${newVersion}")
set(normalizerSelfUpdateSourceFile "${CMAKE_CURRENT_BINARY_DIR}/normalizer-${newVersion}.cmake")
set(normalizerSelfUpdateFile "${CMAKE_CURRENT_BINARY_DIR}/normalizer-fixture.cmake")

file(
  CONFIGURE
  OUTPUT CMakeFiles/Normalizer/self-update-fixtures.cmake.in
  CONTENT [[
    cmake_minimum_required(VERSION 3.29...3.31)

    file(
      COPY_FILE
      "$<TARGET_FILE:Normalizer::Executable>"
      "@normalizerSelfUpdateFile@"
    )

    file(
      COPY_FILE
      "$<TARGET_FILE:Normalizer::Executable>"
      "@normalizerSelfUpdateSourceFile@"
    )
    file(READ "@normalizerSelfUpdateSourceFile@" content)
    string(
      REGEX REPLACE
      "(set\\(NORMALIZER_VERSION \")[0-9.]+(\"\\)\n)"
      "\\1@newVersion@\\2"
      content
      "${content}"
    )
    file(WRITE "@normalizerSelfUpdateSourceFile@" "${content}")
  ]]
  @ONLY
)
file(
  GENERATE
  OUTPUT CMakeFiles/Normalizer/self-update-fixtures.cmake
  INPUT ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/Normalizer/self-update-fixtures.cmake.in
)

add_test(
  NAME NormalizerIntegrationSelfUpdateFixturesInit
  COMMAND ${CMAKE_COMMAND} -P CMakeFiles/Normalizer/self-update-fixtures.cmake
)
set_tests_properties(
  NormalizerIntegrationSelfUpdateFixturesInit
  PROPERTIES
    FIXTURES_SETUP SelfUpdateFixtures
)

add_test(
  NAME NormalizerIntegrationSelfUpdateFixturesClean
  COMMAND ${CMAKE_COMMAND} -E remove
    ${normalizerSelfUpdateFile}
    ${normalizerSelfUpdateSourceFile}
)
set_tests_properties(
  NormalizerIntegrationSelfUpdateFixturesClean
  PROPERTIES
    FIXTURES_CLEANUP SelfUpdateFixtures
)

add_test(
  NAME NormalizerIntegrationSelfUpdate
  COMMAND ${CMAKE_COMMAND}
    -D "NORMALIZER_SELF_UPDATE_URL=file://${normalizerSelfUpdateSourceFile}"
    -P ${normalizerSelfUpdateFile}
    --
    --self-update
)
set_tests_properties(
  NormalizerIntegrationSelfUpdate
  PROPERTIES
    FIXTURES_REQUIRED SelfUpdateFixtures
    PASS_REGULAR_EXPRESSION
      "normalizer-fixture.cmake has been updated from version ${PROJECT_VERSION} to ${newVersion}"
)

set_tests_properties(
  NormalizerIntegrationSelfUpdate
  NormalizerIntegrationSelfUpdateFixturesInit
  NormalizerIntegrationSelfUpdateFixturesClean
  PROPERTIES RESOURCE_LOCK SelfUpdateFixturesLock
)

add_test(
  NAME NormalizerIntegrationSelfUpdateCheckVersion
  COMMAND ${CMAKE_COMMAND} -P ${normalizerSelfUpdateFile} -- -v
)
set_tests_properties(
  NormalizerIntegrationSelfUpdateCheckVersion
  PROPERTIES
    DEPENDS NormalizerIntegrationSelfUpdate
    FIXTURES_REQUIRED SelfUpdateFixtures
    PASS_REGULAR_EXPRESSION "${newVersion}"
)
