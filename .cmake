# Configuration template for normalizer.cmake.
#
# https://github.com/petk/cmake-normalizer

# Whether to sync all cmake_minimum_required() calls. Set to false to disable.
set(normalize_cmake_minimum_required "3.29...3.31")

# Whether to normalize commands to their expected and common style. For example,
# built-in CMake commands are 'lower_snake_case()'.
set(normalize_commands true)

# Whether to normalize 'some_command (...)' to 'some_command(...)'.
set(normalize_space_after_command true)

# Whether to add space before opening paren for control flow commands listed
# below.
set(normalize_space_after_command_control_flow false)

# A list of commands, for which to add space after command. Some projects might
# prefer having a space after so-called control flow commands (if, while,
# foreach...). This, normalizes all listed commands to have a space after
# command if 'normalize_space_after_command_control_flow' configuration is
# enabled.
set(
  normalize_space_after_command_disable
  if else endif while endwhile foreach endforeach
)

# Whether to check if all module commands have their accompanying
# include(<ModuleName>). Also checks for redundant/unused include(<ModuleName>).
set(normalize_include_modules true)

# Whether to check for local modules. This is a list of paths to local CMake
# modules in a project that define commands. Each module is scanned for the
# functions it defines.
#set(normalize_include_modules_local ${CMAKE_CURRENT_LIST_DIR}/cmake/modules)

# The number of indentation characters.
set(normalize_indent_size 2)

# The indentation style. Can be 'space', 'tab', or 'false' (disables indentation
# style normalization).
set(normalize_indent_style space)

# Whether to normalize obsolete CMake code that is known to normalizer.
set(normalize_obsolete_code true)

# Check for obsolete usages of end commands containing arguments:
#   else(<condition>),
#   endif(<condition>),
#   endforeach(<loop-var>),
#   endwhile(<condition>),
#   endfunction(<name>),
#   endmacro(<name>)
set(normalize_obsolete_end_commands true)

# Whether to normalize the set(<variable>) to unset(<variable>).
set(normalize_set true)

# Whether to trim horizontal trailing whitespace at the end of the lines.
set(normalize_trailing_whitespace true)

# Whether to trim horizontal trailing whitespace at the end of the lines also
# in multi-line quoted and bracket arguments: "<quoted-argument>",
# [[<bracket-argument>]].
set(normalize_trailing_whitespace_in_arguments true)

# Whether to trim horizontal trailing whitespace at the end of the lines also
# in multi-line comments #[[<bracket-comment>]] (comment character followed by a
# bracket argument).
set(normalize_trailing_whitespace_in_bracket_comments true)

# Whether to normalize newlines.
set(normalize_newlines true)

# Whether to remove redundant leading newlines.
set(normalize_newlines_leading true)

# Whether to normalize final newlines - redundant final newlines are trimmed
# to a single newline, when final newline is missing, newline is added at the
# end.
set(normalize_newlines_final true)

# Whether to normalize redundant middle newlines.
set(normalize_newlines_middle true)

# Whether the ProcessorCount module and ProcessorCount() command should be
# replaced with the more reliable CMake builtin cmake_host_system_information()
# command.
set(normalize_processorcount true)
