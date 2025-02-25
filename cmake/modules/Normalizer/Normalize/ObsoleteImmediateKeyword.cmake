include_guard(GLOBAL)

#[=============================================================================[
Normalizer/Normalize/ObsoleteImmediateKeyword

Checks for obsolete IMMEDIATE keyword in configure_file() command. This keyword
was once supported in CMake 2.x and in 3.x versions is ignored.
#]=============================================================================]

include(Tokenizer)

# normalizer_normalize_obsolete_immediate_keyword(<namespace> <token-index> <log>)
macro(normalizer_normalize_obsolete_immediate_keyword)
  set(${ARGV2} "")

  if(
    ${ARGV0}_${ARGV1}_id STREQUAL "T_COMMAND"
    AND ${ARGV0}_${ARGV1}_text STREQUAL "configure_file"
  )
    foreach(index IN LISTS ${ARGV0}_${ARGV1}_arguments)
      if(${ARGV0}_${index}_text STREQUAL "IMMEDIATE")
        string(APPEND ${ARGV2} "configure_file(... IMMEDIATE) -> configure_file(...)")
        tokenizer_remove_token(${ARGV0} ${index})
      endif()
    endforeach()
  endif()
endmacro()
