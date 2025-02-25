include_guard(GLOBAL)

#[=============================================================================[
Normalizer/Progress

Calculates percentage when running in multiple steps. For example:

```cmake
include(Normalizer/Progress)

set(numOfFiles 260)
normalizer_progress_start(${numOfFiles})

foreach(i RANGE 1 ${numOfFiles})
  normalizer_progress(percentage)
  message(STATUS "[${percentage}%] Processing file_${i}.cmake")
  # ...
endforeach()
```
#]=============================================================================]

function(normalizer_progress_start)
  string(LENGTH "${ARGV0}" length)
  string(REPEAT 0 ${length} zeroes)

  if(ARGV0 MATCHES "^0[0]*$")
    set(step 0)
  else()
    math(EXPR step "1000${zeroes} / ${ARGV0}")
  endif()

  set_property(GLOBAL PROPERTY _NORMALIZER_PROGRESS_STEP ${step})
  set_property(GLOBAL PROPERTY _NORMALIZER_PROGRESS_LENGTH ${ARGV0})
  set_property(GLOBAL PROPERTY _NORMALIZER_PROGRESS_CURRENT 0)
  set_property(GLOBAL PROPERTY _NORMALIZER_PROGRESS_ZEROES ${zeroes})
endfunction()

function(normalizer_progress)
  get_property(
    _normalizerProgressStep
    GLOBAL PROPERTY _NORMALIZER_PROGRESS_STEP
  )
  get_property(
    _normalizerProgressCurrent
    GLOBAL PROPERTY _NORMALIZER_PROGRESS_CURRENT
  )
  get_property(
    _normalizerProgressLength
    GLOBAL PROPERTY _NORMALIZER_PROGRESS_LENGTH
  )
  get_property(
    _normalizerProgressZeroes
    GLOBAL PROPERTY _NORMALIZER_PROGRESS_ZEROES
  )

  math(EXPR _normalizerProgressCurrent "${_normalizerProgressCurrent} + 1")

  if(${_normalizerProgressCurrent} GREATER_EQUAL ${_normalizerProgressLength})
    set(_normalizerProgressCurrent ${_normalizerProgressLength})
    set(${ARGV0} 100)
  else()
    math(
      EXPR
      ${ARGV0}
      "(${_normalizerProgressStep} * ${_normalizerProgressCurrent}) / 10${_normalizerProgressZeroes}"
    )
  endif()

  set_property(
    GLOBAL
    PROPERTY
    _NORMALIZER_PROGRESS_CURRENT
    ${_normalizerProgressCurrent}
  )

  return(PROPAGATE ${ARGV0})
endfunction()
