# Contributing guide

Contributions are most welcome. Below is described procedure for contributing to
this repository.

* Fork this repository over GitHub.
* Create a separate branch, for instance `patch-1` so you will not need to
  rebase your fork if your main branch is merged.

  ```sh
  git clone git@github.com:your_username/cmake-normalizer
  cd cmake-normalizer
  git checkout -b patch-1
  ```
* Make changes, commit them and push to your fork

  ```sh
  git add .
  git commit -m "Fix bug"
  git push origin patch-1
  ```
* Open a pull request

## Style guide

* This repository uses [Markdown](https://daringfireball.net/projects/markdown/)
  syntax and follows
  [cirosantilli/markdown-style-guide](http://www.cirosantilli.com/markdown-style-guide/)
  style guide.

## GitHub issues labels

Labels are used to organize issues and pull requests into manageable categories.
The following labels are used:

* **bug** - Attached when bug is reported.
* **duplicate** - Attached when the same issue or pull request already exists.
* **enhancement** - Attached when creating a new feature.
* **invalid** - Attached when the issue or pull request does not correspond with
  scope of the repository or because of some inconsistency.
* **question** - Attached for questions or discussions.
* **wontfix** - Attached when decided that issue will not be fixed.

## Repository directory structure

This is a monolithic repository consisting of the following files:

```sh
📂 <cmake-normalizer>
└─📂 .github             # GitHub directory
  └─📂 workflows         # Workflows for GitHub actions
    └─📄 ...
└─📂 bin                 # Command-line scripts
  ├─📄 normalizer.cmake  # Main command-line script used during development
  └─📄 tokenizer.cmake   # Command-line helper script for tokenizing CMake code
└─📂 cmake               # CMake-based source files
  ├─📂 modules           # CMake modules
  └─📄 development.cmake # CMake helper for running development normalizer.cmake
└─📂 docs                # Repository documentation files
  └─📄 ...
├─📂 out                 # Generated files
├─📂 tests               # Tests
├─📄 .codespellrc        # See https://github.com/codespell-project/codespell
├─📄 .editorconfig       # See https://editorconfig.org
└─ ...
```

## Packaging

1. Update version in `CMakeLists.txt`:

  ```diff
   project(
     Normalizer
  -  VERSION X.Y.1
  +  VERSION X.Y.2
     DESCRIPTION "Normalizer for CMake code"
     HOMEPAGE_URL "https://github.com/petk/cmake-normalizer"
     LANGUAGES NONE
   )
  ```

2. Build and run tests:

  ```sh
  cmake -B out
  cmake --build out -j
  ctest --test-dir out -j
  ```

  The all-in-one CMake generated file is located at `out/normalizer-X.Y.Z.cmake`

3. Create a new GitHub release and Git tag at
   https://github.com/petk/cmake-normalizer/releases

4. Upload `out/normalizer-X.Y.Z.cmake` to release files as `normalizer.cmake`
