include(CheckPrototypeDefinition)
include(CheckSourceCompiles)
include(GNUInstallDirs)
include(Foobar)
include(cmake/some-local-file.cmake)

check_source_compiles(C [[int main(void) { return 0; }]] HAVE_WORKING_PROGRAM)

check_include_file(unistd.h HAVE_UNISTD_H)

include(CPackComponent)

cpack_add_component(foobar)
