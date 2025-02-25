# Test Timer module.

include(Normalizer/Timer)

function(normalizer_tests_unit_timer_default)
  normalizer_timer_start()

  execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 0.1)

  normalizer_timer_lap(lap)

  if(lap LESS 0.1)
    message(SEND_ERROR "lap 1 should be larger than ${lap} sec")
  else()
    message(STATUS "lap: ${lap} sec")
  endif()

  execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 0.1)

  normalizer_timer_lap(lap)

  if(lap LESS 0.1)
    message(SEND_ERROR "lap 2 should be larger than ${lap} sec")
  else()
    message(STATUS "lap: ${lap} sec")
  endif()

  execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 0.1)

  normalizer_timer_stop(end)

  if(end LESS 0.3)
    message(SEND_ERROR "end should be larger than ${end} sec")
  else()
    message(STATUS "end: ${end} sec")
  endif()
endfunction()
