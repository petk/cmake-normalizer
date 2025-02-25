if(NOT EXISTS ${PROJECT_SOURCE_DIR}/build/gen_stub.php)
  return()
endif(NOT EXISTS ${PROJECT_SOURCE_DIR}/build/gen_stub.php)

if(NOT FOOBAR MATCHES condition)
  return()
endif (NOT FOOBAR MATCHES condition)

if(NOT FOO AND (BAR STREQUAL "value_1"
  OR BAZ STREQUAL "value_2"
) AND FOOBAR)
  return()
endif(NOT FOO AND (BAR STREQUAL "value_1"
  OR BAZ STREQUAL "value_2"
) AND FOOBAR)

foreach(i IN ITEMS a b c d)
  message(STATUS "asdf")

  if(foobar)
    message(STATUS "test")
  else(foobar)
    message(STATUS "test")
  endif(foobar)
endforeach(i)

set(counter 0)
while(counter LESS 5)
  message(STATUS "${counter}")
  math(EXPR counter "${counter} + 1")
endwhile(counter LESS 5)

function(foo)
  message(STATUS "foo")
endfunction(foo)

macro(bar)
  message(STATUS "bar")
endmacro(bar)
