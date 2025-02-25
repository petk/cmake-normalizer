include_guard(GLOBAL)

#[=============================================================================[
# Tokenizer

This module provides commands to turn CMake code into tokens.

## tokenizer_parse()

```cmake
  tokenizer_parse(
    <FILE <file> | CONTENT <content>>
    NAMESPACE <namespace>
    [EXIT_CODE <exit-code-variable>]
    [ERROR <error-variable>]
  )
```

The options are:

* `FILE <file>`

  If this option is given, the `<file>` contents will be parsed and tokenized.
  Relative `<file>` path is interpreted as being relative to the current source
  directory (`CMAKE_CURRENT_SOURCE_DIR`).

* `CONTENT <content>`

  Instead of parsing content from file `<file>`, given `<content>` will be
  parsed. If both `FILE` and `CONTENT` are given, `FILE <file>` will be ignored
  and used in result messages.

* `EXIT_CODE <exit-code-variable>`

  The exit result status number will be stored to a local variable named
  `<exit-code-variable>`. If entire parsed content was successfully tokenized,
  result status exit code will be `0`. If some error occurred, exit code will be
  `1`.

* `ERROR <error-variable>`

  When some error occurs during tokenization, the error message will be stored
  in a variable named `<error-output-variable>` if given.

Variables set by this function:

* `<namespace>_tokens`

  A list of all token index numbers for simpler usage when running `foreach()`:

  ```cmake
  include(Tokenizer)
  tokenizer_parse(CONTENT "${content}" NAMESPACE some_namespace)

  foreach(i IN LISTS some_namespace_tokens)
    # ...
  endforeach()
  ```

## tokenizer_get_command_arguments()

Get command arguments.

```cmake
tokenizer_get_command_arguments(<namespace> <token-index> <result-variable)
```

Arguments:

* `<namespace>` - Tokens namespace.
* `<token-index>` - The index number of the parsed command token.
* `<result-variable>` - A list of all command arguments without tokenized
  spaces, newlines, and command parens.

## Tokens

Supported token IDs:

* `T_COMMAND` - Represents a function or macro name.

* `T_PAREN_CLOSE` - Represents a single opening paren in commands.

* `T_PAREN_OPEN` - Represents a single closing paren in commands.

* `T_BRACKET_ARGUMENT` - Represents argument in command with `[[` and `]]`,
  `[=[` and `]=]`... syntax.

* `T_QUOTED_ARGUMENT` - Represents command argument wrapped in double quotes
  `"`.

* `T_UNQUOTED_ARGUMENT` - Represents command argument without double quotes.

* `T_LINE_COMMENT` - Represents a single line comment.

* `T_BRACKET_COMMENT` - Represents comment wrapped in bracket argument (single
  and multi-line) `#[[` and `]]`, `#[=[` and `]=]`, etc.

* `T_SPACE` - Represents space and tab characters " \t".

* `T_NEWLINE` - Represents vertical whitespace characters "\n".

* `T_EOF` - Represents the end of file. Empty string.

* `T_UNPARSED` - Represents the content that was not tokenized. In case of
  syntax errors in CMake the rest of the content is not parsed and it stored
  to this token.
#]=============================================================================]

# Parse given content or file into tokens.
function(tokenizer_parse)
  cmake_parse_arguments(
    PARSE_ARGV
    0
    parsed # prefix
    "" # options
    "CONTENT;ERROR;FILE;NAMESPACE;EXIT_CODE" # one-value keywords
    "" # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(parsed_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "Missing values for: ${parsed_KEYWORDS_MISSING_VALUES}")
  endif()

  if(NOT DEFINED parsed_FILE AND NOT DEFINED parsed_CONTENT)
    message(
      FATAL_ERROR
      "${CMAKE_CURRENT_FUNCTION}: CONTENT or FILE argument is required"
    )
  endif()

  if(NOT DEFINED parsed_NAMESPACE OR parsed_NAMESPACE STREQUAL "")
    message(
      FATAL_ERROR
      "${CMAKE_CURRENT_FUNCTION}: NAMESPACE argument is required"
    )
  endif()

  if(
    NOT DEFINED parsed_CONTENT
    AND DEFINED parsed_FILE
    AND NOT parsed_FILE STREQUAL ""
  )
    cmake_path(
      ABSOLUTE_PATH
      parsed_FILE
      BASE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      NORMALIZE
    )

    if(NOT EXISTS "${parsed_FILE}")
      message(
        FATAL_ERROR
        "${CMAKE_CURRENT_FUNCTION}: FILE ${parsed_FILE} does not exist."
      )
    endif()

    file(READ "${parsed_FILE}" parsed_CONTENT)
  endif()

  # As this project is reading CMake code with CMake code itself, usual 'set()'
  # command would fail when given content is one of the keywords of 'CACHE' or
  # 'PARENT_SCOPE'. Here, bypass with 'string(CONCAT)' is used.
  string(CONCAT content "${parsed_CONTENT}")

  set(namespace "${parsed_NAMESPACE}")
  set(${namespace}_tokens "")
  set(tokenIndex -1)
  set(_TOKENIZER_EXIT_CODE 0)
  set(_TOKENIZER_ERROR "")
  unset(previousTokenIndex)

  while(true)
    # Horizontal whitespace.
    if(content MATCHES "^[ \t]+")
      tokenizer_token_space(content CMAKE_MATCH_0)

    # Vertical whitespace.
    elseif(content MATCHES "^[\n]+")
      tokenizer_token_newline(content CMAKE_MATCH_0)

    # Command.
    elseif(content MATCHES "^[A-Za-z_][A-Za-z0-9_]*")
      tokenizer_token_command(content CMAKE_MATCH_0)

    # Multiline comment.
    elseif(content MATCHES "^#(\\[=*\\[)")
      tokenizer_token_bracket_comment(content CMAKE_MATCH_1)

    # Line comment.
    elseif(content MATCHES "^#[^\n]*")
      tokenizer_token_comment(content CMAKE_MATCH_0)

    # End parsing.
    elseif(NOT content STREQUAL "")
      tokenizer_token_unparsed(content)
      break()
    else()
      break()
    endif()
  endwhile()

  if(content STREQUAL "")
    tokenizer_token_end_of_file(content content)
  endif()

  if(parsed_EXIT_CODE)
    set(${parsed_EXIT_CODE} "${_TOKENIZER_EXIT_CODE}")
  else()
    set(parsed_EXIT_CODE _TOKENIZER_EXIT_CODE)
  endif()

  if(parsed_ERROR)
    set(${parsed_ERROR} "${_TOKENIZER_ERROR}")
  else()
    set(parsed_ERROR _TOKENIZER_ERROR)
  endif()

  set(${namespace}_end "${tokenIndex}")

  return(
    PROPAGATE
      ${parsed_EXIT_CODE}
      ${parsed_ERROR}
      ${namespace}_end
      ${namespace}_tokens
  )
endfunction()

# tokenizer_tokenize(<token-id> <content-variable> <match-variable>)
macro(tokenizer_tokenize)
  math(EXPR tokenIndex "${tokenIndex} + 1")

  set(${namespace}_${tokenIndex}_id "${ARGV0}" PARENT_SCOPE)
  set(${namespace}_${tokenIndex}_text "${${ARGV2}}" PARENT_SCOPE)

  if(DEFINED previousTokenIndex)
    set(${namespace}_${tokenIndex}_previous ${previousTokenIndex} PARENT_SCOPE)
    set(${namespace}_${previousTokenIndex}_next ${tokenIndex} PARENT_SCOPE)
  endif()

  set(previousTokenIndex ${tokenIndex})

  string(LENGTH "${${ARGV2}}" length)
  string(SUBSTRING "${${ARGV1}}" ${length} -1 ${ARGV1})

  list(APPEND ${namespace}_tokens ${tokenIndex})
endmacro()

# tokenizer_token_space(<content-variable> <match-variable>)
macro(tokenizer_token_space)
  tokenizer_tokenize(T_SPACE ${ARGV0} ${ARGV1})
endmacro()

# tokenizer_token_newline(<content-variable> <match-variable>)
macro(tokenizer_token_newline)
  tokenizer_tokenize(T_NEWLINE ${ARGV0} ${ARGV1})
endmacro()

# tokenizer_token_command(<content-variable> <match-variable>)
macro(tokenizer_token_command)
  tokenizer_tokenize(T_COMMAND ${ARGV0} ${ARGV1})
  set(lastCommandIndex ${tokenIndex})

  if(${ARGV0} MATCHES "^[ \t]+")
    tokenizer_token_space(${ARGV0} CMAKE_MATCH_0)
  endif()

  if(${ARGV0} MATCHES "^\\(")
    tokenizer_token_paren_open(${ARGV0} CMAKE_MATCH_0)
    tokenizer_add_argument(${namespace}_${lastCommandIndex}_all_arguments)

    tokenizer_parse_arguments(${ARGV0})

    if(${ARGV0} MATCHES "^\\)")
      tokenizer_token_paren_close(${ARGV0} CMAKE_MATCH_0)
      tokenizer_add_argument(${namespace}_${lastCommandIndex}_all_arguments)

      if(${namespace}_${lastCommandIndex}_all_arguments)
        set(
          ${namespace}_${lastCommandIndex}_all_arguments
          ${${namespace}_${lastCommandIndex}_all_arguments}
          PARENT_SCOPE
        )
        set(
          ${namespace}_${lastCommandIndex}_arguments
          ${${namespace}_${lastCommandIndex}_arguments}
          PARENT_SCOPE
        )
      else()
        set(_TOKENIZER_EXIT_CODE 1)
        string(APPEND _TOKENIZER_ERROR "Missing closing paren ')'. ")
      endif()
    endif()
  else()
    set(_TOKENIZER_EXIT_CODE 1)
    string(APPEND _TOKENIZER_ERROR "Missing opening paren '('. ")
  endif()
endmacro()

macro(tokenizer_parse_arguments)
  while(true)
    if(${ARGV0} MATCHES "^\\)")
      break()
    elseif(${ARGV0} MATCHES "^\\(")
      tokenizer_token_paren_open(${ARGV0} CMAKE_MATCH_0)
      tokenizer_add_argument(${namespace}_${lastCommandIndex}_all_arguments)

      tokenizer_parse_arguments(${ARGV0})

      if(${ARGV0} MATCHES "^\\)")
        tokenizer_token_paren_close(${ARGV0} CMAKE_MATCH_0)
        tokenizer_add_argument(${namespace}_${lastCommandIndex}_all_arguments)
      else()
        # Error: missing closing paren.
      endif()

    # Vertical whitespace.
    elseif(${ARGV0} MATCHES "^[\n]+")
      tokenizer_token_newline(${ARGV0} CMAKE_MATCH_0)
      tokenizer_add_argument(${namespace}_${lastCommandIndex}_all_arguments)

    # Horizontal whitespace.
    elseif(${ARGV0} MATCHES "^[ \t]+")
      tokenizer_token_space(${ARGV0} CMAKE_MATCH_0)
      tokenizer_add_argument(${namespace}_${lastCommandIndex}_all_arguments)

    # Multiline comment.
    elseif(${ARGV0} MATCHES "^#(\\[=*\\[)")
      tokenizer_token_bracket_comment(${ARGV0} CMAKE_MATCH_1)
      tokenizer_add_argument(${namespace}_${lastCommandIndex}_all_arguments)

    # Bracket argument.
    elseif(${ARGV0} MATCHES "^\\[=*\\[")
      tokenizer_token_bracket_argument(${ARGV0} CMAKE_MATCH_0)
      tokenizer_add_argument(${namespace}_${lastCommandIndex}_all_arguments)
      tokenizer_add_argument(${namespace}_${lastCommandIndex}_arguments)

    # Line comment.
    elseif(${ARGV0} MATCHES "^#[^\n]*")
      tokenizer_token_comment(${ARGV0} CMAKE_MATCH_0)
      tokenizer_add_argument(${namespace}_${lastCommandIndex}_all_arguments)

    # Quoted argument.
    elseif(${ARGV0} MATCHES "^\"")
      if(${ARGV0} MATCHES "^\"([\\].|[^\"\\])*\"")
        tokenizer_token_quoted_argument(${ARGV0} CMAKE_MATCH_0)
        tokenizer_add_argument(${namespace}_${lastCommandIndex}_all_arguments)
        tokenizer_add_argument(${namespace}_${lastCommandIndex}_arguments)
      endif()

    # Unquoted argument.
    elseif(${ARGV0} MATCHES "^[^\n \t#()]")
      string(CONCAT buffer "${${ARGV0}}")
      set(argument "")
      while(true)
        if(buffer MATCHES "^[^\n \t#()$\\\\]+")
          string(APPEND argument "${CMAKE_MATCH_0}")
          string(LENGTH "${CMAKE_MATCH_0}" length)
          string(SUBSTRING "${buffer}" ${length} -1 buffer)
        elseif(buffer MATCHES "^\\\\.")
          string(APPEND argument "${CMAKE_MATCH_0}")
          string(SUBSTRING "${buffer}" 2 -1 buffer)
        elseif(buffer STREQUAL "" OR buffer MATCHES "^[\n \t#()]")
          break()
        elseif(buffer MATCHES "^\\$\\([A-Za-z0-9_]+\\)")
          string(APPEND argument "${CMAKE_MATCH_0}")
          string(LENGTH "${CMAKE_MATCH_0}" length)
          string(SUBSTRING "${buffer}" ${length} -1 buffer)
        else()
          string(SUBSTRING "${buffer}" 0 1 char)
          string(APPEND argument "${char}")
          string(SUBSTRING "${buffer}" 1 -1 buffer)
        endif()
      endwhile()

      tokenizer_token_unquoted_argument(${ARGV0} argument)
      tokenizer_add_argument(${namespace}_${lastCommandIndex}_all_arguments)
      tokenizer_add_argument(${namespace}_${lastCommandIndex}_arguments)
    else()
      break()
    endif()
  endwhile()
endmacro()

macro(tokenizer_add_argument)
  list(APPEND ${ARGV0} ${tokenIndex})
endmacro()

macro(tokenizer_token_bracket_comment contentVariable matchVariable)
  set(openingBracket "${${matchVariable}}")
  string(REGEX REPLACE "\\[" "]" closingBracket "${openingBracket}")

  string(LENGTH "#${openingBracket}" length)

  string(SUBSTRING "${${contentVariable}}" ${length} -1 remainingContent)

  string(FIND "${remainingContent}" "${closingBracket}" position)

  if(position EQUAL -1)
    message(FATAL_ERROR "Unterminated bracket argument.")
  endif()

  string(SUBSTRING "${remainingContent}" 0 ${position} argument)

  set(match "#${openingBracket}${argument}${closingBracket}")

  tokenizer_tokenize(T_BRACKET_COMMENT ${contentVariable} match)
endmacro()

# tokenizer_token_comment(<content-variable> <match-variable>)
macro(tokenizer_token_comment)
  tokenizer_tokenize(T_LINE_COMMENT ${ARGV0} ${ARGV1})
endmacro()

# tokenizer_token_paren_open(<content-variable> <match-variable>)
macro(tokenizer_token_paren_open)
  tokenizer_tokenize(T_PAREN_OPEN ${ARGV0} ${ARGV1})
endmacro()

# tokenizer_token_paren_close(<content-variable> <match-variable>)
macro(tokenizer_token_paren_close)
  tokenizer_tokenize(T_PAREN_CLOSE ${ARGV0} ${ARGV1})
endmacro()

macro(tokenizer_token_bracket_argument contentVariable matchVariable)
  set(openingBracket "${${matchVariable}}")
  string(REGEX REPLACE "\\[" "]" closingBracket "${openingBracket}")

  string(LENGTH "${openingBracket}" length)
  string(SUBSTRING "${${contentVariable}}" ${length} -1 remainingContent)

  string(FIND "${remainingContent}" "${closingBracket}" position)

  if(position EQUAL -1)
    message(FATAL_ERROR "Unterminated bracket argument.")
  endif()

  string(SUBSTRING "${remainingContent}" 0 ${position} argument)

  set(match "${openingBracket}${argument}${closingBracket}")

  tokenizer_tokenize(T_BRACKET_ARGUMENT ${contentVariable} match)
endmacro()

macro(tokenizer_token_unquoted_argument)
  tokenizer_tokenize(T_UNQUOTED_ARGUMENT ${ARGV0} ${ARGV1})
endmacro()

macro(tokenizer_token_quoted_argument)
  tokenizer_tokenize(T_QUOTED_ARGUMENT ${ARGV0} ${ARGV1})
endmacro()

macro(tokenizer_token_end_of_file)
  tokenizer_tokenize(T_EOF ${ARGV0} ${ARGV1})
endmacro()

macro(tokenizer_token_unparsed)
  string(SUBSTRING "${${ARGV0}}" 0 500 unparsed)
  string(REGEX REPLACE "\n" "\n  " unparsed "${unparsed}")
  string(STRIP "${unparsed}" unparsed)
  set(unparsed "  ${unparsed} ...")

  tokenizer_tokenize(T_UNPARSED ${ARGV0} ${ARGV0})

  message(
    WARNING
    "Unparsed content ${parsed_FILE}: \n${unparsed}"
  )

  unset(unparsed)
endmacro()

# Get command arguments without spaces, comments and parens.
# tokenizer_get_command_arguments(<namespace> <index> <result-variable>)
function(tokenizer_get_command_arguments)
  # namespace ARGV0
  # index: ARGV1
  # resultVariable: ARGV2
  set(${ARGV2} "")

  foreach(i IN LISTS ${ARGV0}_${ARGV1}_arguments)
    if(${ARGV0}_${i}_id MATCHES "^T_(BRACKET_COMMENT|LINE_COMMENT|PAREN_OPEN|PAREN_CLOSE|NEWLINE|SPACE)$")
      continue()
    endif()
    list(APPEND ${ARGV2} "${${ARGV0}_${i}_text}")
  endforeach()

  return(PROPAGATE ${ARGV2})
endfunction()

# tokenizer_remove_token(<namespace> <index>)
function(tokenizer_remove_token)
  list(REMOVE_ITEM ${ARGV0}_tokens ${ARGV1})

  # Adjust next and previous tokens.
  if(NOT "${${ARGV0}_${ARGV1}_previous}" STREQUAL "")
    set(previous ${${ARGV0}_${ARGV1}_previous})
  else()
    set(previous "")
  endif()

  if(NOT "${${ARGV0}_${ARGV1}_next}" STREQUAL "")
    set(next ${${ARGV0}_${ARGV1}_next})
  else()
    set(next "")
  endif()

  if(NOT previous STREQUAL "")
    set(${ARGV0}_${previous}_next "${next}" PARENT_SCOPE)
  endif()

  if(NOT next STREQUAL "")
    set(${ARGV0}_${next}_previous "${previous}" PARENT_SCOPE)
  endif()

  # If token being removed is a command, remove also all its arguments.
  foreach(argument IN LISTS ${ARGV0}_${ARGV1}_all_arguments)
    list(REMOVE_ITEM ${ARGV0}_tokens ${argument})
  endforeach()

  return(PROPAGATE ${ARGV0}_tokens)
endfunction()

# tokenizer_insert_token(<namespace> <index> <token-id> <text>)
macro(tokenizer_insert_token)
  math(EXPR ${ARGV0}_end "${${ARGV0}_end} + 1")
  set(newIndex ${${ARGV0}_end})

  list(FIND ${ARGV0}_tokens ${ARGV1} position)
  math(EXPR position "${position} + 1")
  list(INSERT ${ARGV0}_tokens ${position} ${newIndex})

  # Set next and previous token for the newly inserted token.
  set(${ARGV0}_${newIndex}_next "${${ARGV0}_${ARGV1}_next}")
  set(${ARGV0}_${newIndex}_previous "${ARGV1}")

  # Update previous token for the token on the right.
  set(${ARGV0}_${${ARGV0}_${ARGV1}_next}_previous ${newIndex})

  # Adjust next for the token on the left.
  set(${ARGV0}_${ARGV1}_next "${newIndex}")

  # Set all other token attributes for the newly inserted token.
  set(${ARGV0}_${newIndex}_id "${ARGV2}")
  set(${ARGV0}_${newIndex}_text "${ARGV3}")
  set(${ARGV0}_${newIndex}_all_arguments "")
  set(${ARGV0}_${newIndex}_arguments "")
endmacro()

function(tokenizer_get_next _namespace _index _result)
  list(FIND ${_namespace}_tokens ${_index} ${_result})
  math(EXPR ${_result} "${${_result}} + 1")
  list(GET ${_namespace}_tokens ${${_result}} ${_result})

  return(PROPAGATE ${_result})
endfunction()

function(tokenizer_get_previous _namespace _index _result)
  list(FIND ${_namespace}_tokens ${_index} ${_result})
  math(EXPR ${_result} "${${_result}} - 1")
  list(GET ${_namespace}_tokens ${${_result}} ${_result})

  return(PROPAGATE ${_result})
endfunction()
