add_custom_target (
  # comment
  some_target
  COMMAND ${CMAKE_COMMAND} -E echo "testing"
)

set(variable_1 "ok")
set (variable_2 "with space before paren")
set   (variable_3 "with spaces before paren")
set	(variable_4 "with tab before paren")
set			(variable_5 "with tabs before paren")
set  	  	 (variable_6 "with spaces and tabs before paren")
set	  	  	 	(variable_7 "with tabs and spaces before paren")

set (index 0)

if (condition)
  while 	(index LESS 10)
    math(EXPR index "${index} + 1")
  endwhile ()
else()
  set(foobar "ok")
endif()
