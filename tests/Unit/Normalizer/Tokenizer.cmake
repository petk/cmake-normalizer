# Test tokenizer commands.

include(Tokenizer)

# Test that content before and after tokenization is the same.
function(normalizer_tests_unit_tokenizer_content)
  set(content_1 [[
# Lorem ipsum;
# Dolor sit amet
]])
  set(content_2 [[]])
  set(content_3 [[
set(fileTypes txt;png;zip;cmake;)
]])

  set(index 1)
  while(DEFINED content_${index})
    set(content "${content_${index}}")
    set(namespace "test_${index}")
    set(newContent "")

    tokenizer_parse(CONTENT "${content}" NAMESPACE ${namespace})
    foreach(i IN LISTS ${namespace}_tokens)
      string(APPEND newContent "${${namespace}_${i}_text}")
    endforeach()

    if(NOT content STREQUAL newContent)
      message(NOTICE "Content:\n'${content}'")
      message(NOTICE "New content:\n'${newContent}'")
      message(SEND_ERROR "New content doesn't match original.")
    endif()

    math(EXPR index "${index} + 1")
  endwhile()
endfunction()

# Test unquoted command arguments 1.
function(normalizer_tests_unit_tokenizer_unquoted_arguments_1)
  set(content_1 [[
    find_program(FIND_COMMAND find)
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E echo argument\ with\ space
      COMMAND
        ${FIND_COMMAND}
        ${CMAKE_CURRENT_SOURCE_DIR}
        -type f \( -perm -0100 -o -perm -0010 -o -perm -0001 \)
      OUTPUT_VARIABLE files
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  ]])
  set(content_2 [[]])

  set(index 1)
  while(DEFINED content_${index})
    set(content "${content_${index}}")
    set(namespace "test_${index}")
    set(newContent "")

    tokenizer_parse(CONTENT "${content}" NAMESPACE ${namespace})
    foreach(i IN LISTS ${namespace}_tokens)
      message(STATUS "ID: ${${namespace}_${i}_id}")
      message(STATUS "Text: ${${namespace}_${i}_text}")
    endforeach()

    math(EXPR index "${index} + 1")
  endwhile()
endfunction()

# Test unquoted command arguments 2.
function(normalizer_tests_unit_tokenizer_unquoted_arguments_2)
  # \n breaks the unquoted argument
  set(content_1 [[
    set(arg a
    b)
  ]])
  set(argument_index_1 5)
  set(argument_1 [[a]])

  # space breaks the unquoted argument unless it is escaped:
  set(content_2 [[set(arg a b)]])
  set(argument_index_2 4)
  set(argument_2 [[a]])

  set(content_3 [[set(arg a\ b)]])
  set(argument_index_3 4)
  set(argument_3 [[a\ b]])

  set(content_4 [[set(arg a(b))]])
  set(argument_index_4 4)
  set(argument_4 [[a]])

  set(content_5 [[set(arg a\#)]])
  set(argument_index_5 4)
  set(argument_5 [[a\#]])

  set(content_6 [[set(arg a"a")]])
  set(argument_index_6 4)
  set(argument_6 [[a"a"]])

  set(content_7 [[set(arg ${asdf})]])
  set(argument_index_7 4)
  set(argument_7 [[${asdf}]])

  set(content_8 [[set(arg $(asdf))]])
  set(argument_index_8 4)
  set(argument_8 [[$(asdf)]])

  set(content_9 [[set(arg $(as$(asdf)df))]])
  set(argument_index_9 4)
  set(argument_9 [[$]])

  set(content_10 [[set(arg asdf${asdf}${asdf})]])
  set(argument_index_10 4)
  set(argument_10 [[asdf${asdf}${asdf}]])

  set(i 1)
  while(DEFINED content_${i})
    set(namespace "test_${i}")

    tokenizer_parse(CONTENT "${content_${i}}" NAMESPACE ${namespace})
    if(NOT ${namespace}_${argument_index_${i}}_text STREQUAL "${argument_${i}}")
      message(
        NOTICE
        "Tokenized argument: '${${namespace}_${argument_index_${i}}_text}'\n"
        "Expected argument: '${argument_${i}}'"
      )
      message(SEND_ERROR "Arguments don't match.")
    endif()
    math(EXPR i "${i} + 1")
  endwhile()
endfunction()

# Test non-CMake content.
function(normalizer_tests_unit_tokenizer_non_cmake_content)
  set(content_1 [[
    Some non-CMake content: .*/cmake -E \[command\] \[arguments \.\.\.\]
    Lorem ipsum:
  ]])

  set(index 1)
  while(DEFINED content_${index})
    set(content "${content_${index}}")
    set(namespace "test_${index}")
    set(newContent "")

    tokenizer_parse(CONTENT "${content}" NAMESPACE ${namespace})
    foreach(i IN LISTS ${namespace}_tokens)
      message(STATUS "ID: ${${namespace}_${i}_id}")
      message(STATUS "Text: ${${namespace}_${i}_text}")
    endforeach()

    math(EXPR index "${index} + 1")
  endwhile()
endfunction()

# Test removing tokens 1.
function(normalizer_tests_unit_tokenizer_remove_tokens_1)
  set(content [[
    set(foo true)
    # this is comment
    set(bar false)
  ]])

  set(namespace "test_1")
  tokenizer_parse(CONTENT "${content}" NAMESPACE ${namespace})

  # Remove space and comment tokens.
  tokenizer_remove_token(${namespace} 8)
  tokenizer_remove_token(${namespace} 9)

  set(expectedContent [[
    set(foo true)

    set(bar false)
  ]])

  set(newContent "")
  foreach(i IN LISTS ${namespace}_tokens)
    string(APPEND newContent "${${namespace}_${i}_text}")
  endforeach()

  if(NOT newContent STREQUAL expectedContent)
    message(NOTICE "New content:\n'${newContent}'")
    message(NOTICE "Expected content:\n'${expectedContent}'")
    message(SEND_ERROR "New content doesn't match expected.")
  endif()

  if(NOT ${namespace}_7_next EQUAL 10)
    message(NOTICE "${namespace}_7_next=${${namespace}_7_next}")
    message(SEND_ERROR "Next token doesn't equal the expected 10.")
  endif()

  if(NOT ${namespace}_10_previous EQUAL 7)
    message(NOTICE "${namespace}_10_previous=${${namespace}_10_previous}")
    message(SEND_ERROR "Previous token doesn't equal the expected 7.")
  endif()
endfunction()

# Test removing tokens 2.
function(normalizer_tests_unit_tokenizer_remove_tokens_2)
  set(content [[
    # this is comment
    set(foo true)
    set(bar false)
  ]])

  set(namespace "test_2")
  tokenizer_parse(CONTENT "${content}" NAMESPACE ${namespace})

  # Remove space, comment, and newline tokens.
  tokenizer_remove_token(${namespace} 0)
  tokenizer_remove_token(${namespace} 1)
  tokenizer_remove_token(${namespace} 2)

  set(expectedContent [[
    set(foo true)
    set(bar false)
  ]])

  set(newContent "")
  foreach(i IN LISTS ${namespace}_tokens)
    string(APPEND newContent "${${namespace}_${i}_text}")
  endforeach()

  if(NOT newContent STREQUAL expectedContent)
    message(NOTICE "New content:\n'${newContent}'")
    message(NOTICE "Expected content:\n'${expectedContent}'")
    message(SEND_ERROR "New content doesn't match expected.")
  endif()

  if(NOT "${${namespace}_3_previous}" STREQUAL "")
    message(NOTICE "${namespace}_3_previous='${${namespace}_3_previous}'")
    message(SEND_ERROR "Previous token doesn't equal the expected empty string.")
  endif()
endfunction()

# Test removing tokens 3.
function(normalizer_tests_unit_tokenizer_remove_tokens_3)
  set(content [[
    set(foo true)
    set(bar false)
    # this is comment
  ]])

  set(namespace "test_3")
  tokenizer_parse(CONTENT "${content}" NAMESPACE ${namespace})

  # Remove space, comment, and newline tokens.
  tokenizer_remove_token(${namespace} 16)
  tokenizer_remove_token(${namespace} 17)
  tokenizer_remove_token(${namespace} 18)

  set(expectedContent [[
    set(foo true)
    set(bar false)
  ]])

  set(newContent "")
  foreach(i IN LISTS ${namespace}_tokens)
    string(APPEND newContent "${${namespace}_${i}_text}")
  endforeach()

  if(NOT newContent STREQUAL expectedContent)
    message(NOTICE "New content:\n'${newContent}'")
    message(NOTICE "Expected content:\n'${expectedContent}'")
    message(SEND_ERROR "New content doesn't match expected.")
  endif()

  if(NOT "${${namespace}_19_previous}" EQUAL 15)
    message(NOTICE "${namespace}_19_previous='${${namespace}_19_previous}'")
    message(SEND_ERROR "Previous token doesn't equal the expected 15.")
  endif()

  if(NOT ${namespace}_15_next EQUAL 19)
    message(NOTICE "${namespace}_15_next=${${namespace}_15_next}")
    message(SEND_ERROR "Next token doesn't equal the expected 19.")
  endif()
endfunction()

# Test removing tokens 4.
function(normalizer_tests_unit_tokenizer_remove_tokens_4)
  set(content [[
    set(foo true)
    set(bar false)
    # this is comment]])

  set(namespace "test_4")
  tokenizer_parse(CONTENT "${content}" NAMESPACE ${namespace})

  # Remove space, comment, and EOF tokens.
  tokenizer_remove_token(${namespace} 16)
  tokenizer_remove_token(${namespace} 17)
  tokenizer_remove_token(${namespace} 18)

  set(expectedContent [[
    set(foo true)
    set(bar false)
]])

  set(newContent "")
  foreach(i IN LISTS ${namespace}_tokens)
    string(APPEND newContent "${${namespace}_${i}_text}")
  endforeach()

  if(NOT newContent STREQUAL expectedContent)
    message(NOTICE "New content:\n'${newContent}'")
    message(NOTICE "Expected content:\n'${expectedContent}'")
    message(SEND_ERROR "New content doesn't match expected.")
  endif()

  if(NOT "${${namespace}_15_next}" STREQUAL "")
    message(NOTICE "${namespace}_15_next=${${namespace}_15_next}")
    message(SEND_ERROR "Next token doesn't equal the expected empty string.")
  endif()
endfunction()
