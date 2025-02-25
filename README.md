# CMake normalizer

> [!WARNING]
> This tool is still experimental and in development. It currently detects only
> a limited subset of CMake code style issues.

CMake normalizer helps maintain consistent CMake coding style by checking and
optionally fixing common formatting and syntax issues. It is written entirely in
CMake, making it easy to integrate into CMake-based projects without requiring
additional dependencies beyond CMake itself.

## Requirements

* CMake 3.29 or newer

## Installation

Download the latest release and run it with CMake:

```sh
wget https://github.com/petk/cmake-normalizer/releases/latest/download/normalizer.cmake
cmake -P normalizer.cmake -- CMakeLists.txt
```

## Features

Checks and fixes:

* CMake commands style
* `set(<variable>)` to `unset(<variable>)`
* trailing whitespace at the end of lines
* redundant newlines
* suggests to replace the `ProcessorCount` module with more reliable
  `cmake_host_system_information()`
* obsolete code:
  * obsolete `else(<argument>)` and `end*(<argument>)` commands
  * legacy `IMMEDIATE` keyword in `configure_file()`

## Usage

```sh
cmake -P normalizer.cmake -- [<paths>...] [<normalizer-options>] [--]
```

### Arguments

* `--`

  Marker indicating the end of command-line options. First one indicates to
  CMake the end of standard CMake command-line options, and the second one is
  for normalizer script to indicate that further options won't be parsed.

* `<paths>...`

  One or more space-separated CMake files or directories containing CMake files
  to check or fix. If omitted, it defaults to checking files in the current
  directory.

### Options

* `--config <file>` | `--config=<file>`

  Path to a configuration file `<file>` that defines normalization settings. If
  normalization settings are not specified, the tool applies sensible defaults.
  If not specified, it looks for a file `.cmake` in the working directory of
  files, or in a `cmake/` subdirectory (i.e. `cmake/.cmake`).

* `--fix`

  Checks and also fixes CMake files. Without this flag, the tool only reports
  issues without modifying files.

* `--not <skip>` | `--not=<skip>`

  Skip given path when checking files. Can be also passed as a glob expression.
  This option can be passed multiple times.

* `--set <config>=<value>` | `--set=<config>=<value>`

  Set configuration value on command-line. Each configuration from the `.cmake`
  configuration file, can be also adjusted using this `--set` option.

* `--quiet` | `-q`

  Do not output any message.

* `--parallel [<jobs>]` | `-j [<jobs>]`

  Normalize files in parallel with concurrent processes for better performance.
  Without this option only a single process is executed. When using this option
  without argument, the `<jobs>` number will be the number of logical cores
  available on the current machine.

* `--self-update`

  Update current `normalizer.cmake` file to the latest version from GitHub
  releases.

* `--version,-v`

  Outputs the `normalizer.cmake` version.

### Example usage

Check given file(s):

```sh
cmake -P normalizer.cmake -- cmake-project/CMakeLists.txt
# or multiple files
cmake -P normalizer.cmake -- cmake-project/CMakeLists.txt cmake-project/foo.cmake
# or search for CMake files recursively in the entire directory
cmake -P normalizer.cmake -- cmake-project
```

Pass configuration file located in custom location:

```sh
cmake -P normalizer.cmake -- cmake-project --config=cmake-project/normalizer-config.cmake
```

Fix given file(s):

```sh
cmake -P normalizer.cmake -- cmake-project --fix
```

Check all CMake files in current working directory and skip
`cmake/file.cmake` file, `tests` directory, and all CMake files that match the
glob `*foo.cmake` (for example, `somefoo.cmake`, `cmake/other-foo.cmake`):

```sh
cmake -P normalizer.cmake -- --not cmake/file.cmake --not tests --not "*foo.cmake"
```

Update current `normalizer.cmake` to the latest version:

```sh
cmake -P normalizer.cmake -- --self-update
```

Output `normalizer.cmake` version:

```sh
# Output long version string
cmake -P normalizer.cmake -- --version
# or output only short version string
cmake -P normalizer.cmake -- -v
```

## Configuration

### `normalize_cmake_minimum_required`

* Values: `FALSE|"major.minor[.patch[.tweak]]...major.minor[.patch[.tweak]]"`

Whether to normalize all `cmake_minimum_required()` calls to common versions.

### `normalize_include_modules`

* Values: `TRUE|FALSE`

Whether to report about redundant and missing CMake module `include()`
invocations. It follows the philosophy of *include what you use* - each CMake
file should include only those modules of which commands are used in it.
Transitive includes should be avoided. For example, transitive includes in terms
of where a CMake module is included in one CMake file and it is then
transitively used in other files via nested includes or similar.

### `normalize_include_modules_local`

* Values: list of paths to local CMake modules.

Whether to check for local modules. This is a list of paths to local CMake
modules in a project that define commands. Each module is scanned for the
functions it defines. By default it is empty and not checked.

### `normalize_set`

* Values: `TRUE|FALSE`

Whether to normalize the `set(<variable>)` to `unset(<variable>)`.

The following:

```cmake
set(variable)
```

is equivalent to:

```cmake
unset(variable)
```

Issue with setting variable to no value is ambiguous intention and it can expose
a cache variable. For example:

```cmake
set(variable "foo" CACHE INTERNAL "Some cache variable.")
set(variable)
message(STATUS "variable='${variable}'")
```

will output `foo` and not an empty string:

```
-- variable='foo'
```

Most usages of `set(<variable>)` are meant to be either `unset(<variable>)` or
`set(<variable> "")`.

### `normalize_space_after_command`

* Values: `TRUE|FALSE`

Whether to normalize space after command. For example:

```diff
-some_command ()
+some_command()
```

### `normalize_space_after_command_control_flow`

* Values: `TRUE|FALSE`

Whether to add space after commands listed in the
`normalize_space_after_command_disable` configuration.

For example:

```diff
-if(condition)
-endif()
+if (condition)
+endif ()
```
