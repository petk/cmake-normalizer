include_guard(GLOBAL)

#[=============================================================================[
Normalizer/Timer

Calculates script execution time. For example:

```cmake
include(Normalizer/Timer)

normalizer_timer_start()

# ...

normalizer_timer_end(time)
message(STATUS "Completed in ${time} sec")
```

Measuring time in laps:

```cmake
include(Normalizer/Timer)

normalizer_timer_start()

# ...

normalizer_timer_lap(time)
message(STATUS "Current lap time: ${time} sec")

# ...

normalizer_timer_lap(time)
message(STATUS "Current lap time: ${time} sec")

# ...

normalizer_timer_end(time)
message(STATUS "Completed in ${time} sec")
```
#]=============================================================================]

function(normalizer_timer_start)
  string(TIMESTAMP _normalizerTimerStart "%s%f")
  set_property(
    GLOBAL
    PROPERTY _NORMALIZER_TIMER_START "${_normalizerTimerStart}"
  )
  set_property(
    GLOBAL
    PROPERTY _NORMALIZER_TIMER_LAP "${_normalizerTimerStart}"
  )
endfunction()

function(normalizer_timer_lap)
  if(NOT DEFINED ARGV0)
    message(FATAL_ERROR "Missing argument normalizer_timer_lap(<result>)")
  endif()

  get_property(_normalizerTimerLap GLOBAL PROPERTY _NORMALIZER_TIMER_LAP)

  string(TIMESTAMP ${ARGV0} "%s%f")

  set_property(GLOBAL PROPERTY _NORMALIZER_TIMER_LAP "${${ARGV0}}")

  math(EXPR ${ARGV0} "${${ARGV0}} - ${_normalizerTimerLap}")

  string(LENGTH "${${ARGV0}}" length)
  if(length LESS 7)
    set(${ARGV0} "0.${${ARGV0}}")
  else()
    math(EXPR length "${length} - 6")
    string(SUBSTRING "${${ARGV0}}" 0 ${length} seconds)

    string(SUBSTRING "${${ARGV0}}" ${length} -1 microSeconds)
    set(${ARGV0} "${seconds}.${microSeconds}")
  endif()

  return(PROPAGATE ${ARGV0})
endfunction()

function(normalizer_timer_stop)
  if(NOT DEFINED ARGV0)
    message(FATAL_ERROR "Missing argument normalizer_timer_stop(<result>)")
  endif()

  get_property(
    _normalizerTimerStart
    GLOBAL PROPERTY _NORMALIZER_TIMER_START
  )
  string(TIMESTAMP ${ARGV0} "%s%f")
  math(EXPR ${ARGV0} "${${ARGV0}} - ${_normalizerTimerStart}")

  string(LENGTH "${${ARGV0}}" length)

  if(length LESS 7)
    math(EXPR zeroes "6 - ${length}")
    string(REPEAT "0" ${zeroes} zeroes)
    string(PREPEND ${ARGV0} "${zeroes}")
    set(${ARGV0} "0.${${ARGV0}}")
  else()
    math(EXPR length "${length} - 6")
    string(SUBSTRING "${${ARGV0}}" 0 ${length} seconds)
    string(SUBSTRING "${${ARGV0}}" ${length} -1 microSeconds)
    set(${ARGV0} "${seconds}.${microSeconds}")
  endif()

  set_property(GLOBAL PROPERTY _NORMALIZER_TIMER_START "0")
  set_property(GLOBAL PROPERTY _NORMALIZER_TIMER_LAP "0")

  return(PROPAGATE ${ARGV0})
endfunction()
