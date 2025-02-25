include_guard(GLOBAL)

#[=============================================================================[
Normalizer/Normalize/ProcessorCountModule

Checks for include(ProcessorCount) usage and suggests to replace it with more
reliable cmake_host_system_information().
#]=============================================================================]

# normalizer_normalize_processorcount(<namespace> <token-index> <log>)
macro(normalizer_normalize_processorcount)
  set(${ARGV2} "")

  if(
    ${ARGV0}_${ARGV1}_id STREQUAL "T_COMMAND"
    AND ${ARGV0}_${ARGV1}_text STREQUAL "ProcessorCount"
  )
    string(
      APPEND
      ${ARGV2}
      "ProcessorCount(<result>) -> cmake_host_system_information(RESULT <result> QUERY NUMBER_OF_LOGICAL_CORES)"
    )
  endif()
endmacro()
