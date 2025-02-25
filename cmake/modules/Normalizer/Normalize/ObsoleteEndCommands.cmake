include_guard(GLOBAL)

#[=============================================================================[
Normalizer/Normalize/ObsoleteEndCommands

This module provides command to normalize obsolete usages of else(<condition>)
and end*(<argument>) commands.
#]=============================================================================]

include(Tokenizer)

# normalizer_normalize_obsolete_end_commands(<namespace> <token-index> <log>)
macro(normalizer_normalize_obsolete_end_commands)
  set(${ARGV2} "")

  if(
    ${ARGV0}_${ARGV1}_id STREQUAL "T_COMMAND"
    AND
      ${ARGV0}_${ARGV1}_text
      MATCHES
      "^(else|endif|endforeach|endwhile|endfunction|endmacro)$"
  )
    list(LENGTH ${ARGV0}_${ARGV1}_all_arguments length)

    if(length GREATER 2)
      set(message "${${ARGV0}_${ARGV1}_text}")
      foreach(index IN LISTS ${ARGV0}_${ARGV1}_all_arguments)
        string(APPEND message "${${ARGV0}_${index}_text}")
        tokenizer_remove_token(${ARGV0} ${index})
      endforeach()

      string(LENGTH "${message}" length)
      if(length GREATER 50)
        string(SUBSTRING "${message}" 0 50 message)
        string(APPEND message "...)")
      endif()

      string(REGEX REPLACE "\n" "\\\\n" message "${message}")

      string(APPEND message " -> ${${ARGV0}_${ARGV1}_text}()")
      set(${ARGV2} "${message}")
    endif()
  endif()
endmacro()
