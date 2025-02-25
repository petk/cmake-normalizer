include_guard(GLOBAL)

#[=============================================================================[
Normalizer/Data

Contains data-alike content, such as commands, modules, etc.
#]=============================================================================]

include(Normalizer/LocalModules)

# normalizer_data_modules(
#   <modules-result-var>
#   <commands-result-var>
#   <CommandNameForFindingModuleName>
# )
function(normalizer_data_modules)
  set(${ARGV0} "")
  set(${ARGV1} "")

  set(_normalizerModules "")

  # BundleUtilities
  set(
    module_BundleUtilities
      clear_bundle_keys
      copy_and_fixup_bundle
      copy_resolved_framework_into_bundle
      copy_resolved_item_into_bundle
      fixup_bundle
      fixup_bundle_item
      get_bundle_all_executables
      get_bundle_and_executable
      get_bundle_keys
      get_bundle_main_executable
      get_dotapp_dir
      get_item_key
      get_item_rpaths
      set_bundle_key_values
      verify_app
      verify_bundle_prerequisites
      verify_bundle_symlinks
  )
  list(APPEND _normalizerModules BundleUtilities)

  # CheckCCompilerFlag
  set(
    module_CheckCCompilerFlag
      check_c_compiler_flag
  )
  list(APPEND _normalizerModules CheckCCompilerFlag)

  # CheckCompilerFlag
  set(
    module_CheckCompilerFlag
      check_compiler_flag
  )
  list(APPEND _normalizerModules CheckCompilerFlag)

  # CheckCSourceCompiles
  set(
    module_CheckCSourceCompiles
      check_c_source_compiles
  )
  list(APPEND _normalizerModules CheckCSourceCompiles)

  # CheckCSourceRuns
  set(
    module_CheckCSourceRuns
      check_c_source_runs
  )
  list(APPEND _normalizerModules CheckCSourceRuns)

  # CheckCXXCompilerFlag
  set(
    module_CheckCXXCompilerFlag
      check_cxx_compiler_flag
  )
  list(APPEND _normalizerModules CheckCXXCompilerFlag)

  # CheckCXXSourceCompiles
  set(
    module_CheckCXXSourceCompiles
      check_cxx_source_compiles
  )
  list(APPEND _normalizerModules CheckCXXSourceCompiles)

  # CheckCXXSourceRuns
  set(
    module_CheckCXXSourceRuns
      check_cxx_source_runs
  )
  list(APPEND _normalizerModules CheckCXXSourceRuns)

  # CheckCXXSymbolExists
  set(
    module_CheckCXXSymbolExists
      check_cxx_symbol_exists
  )
  list(APPEND _normalizerModules CheckCXXSymbolExists)

  # CheckFortranCompilerFlag
  set(
    module_CheckFortranCompilerFlag
      check_fortran_compiler_flag
  )
  list(APPEND _normalizerModules CheckFortranCompilerFlag)

  # CheckFortranFunctionExists
  set(
    module_CheckFortranFunctionExists
      check_fortran_function_exists
  )
  list(APPEND _normalizerModules CheckFortranFunctionExists)

  # CheckFortranSourceCompiles
  set(
    module_CheckFortranSourceCompiles
      check_fortran_source_compiles
  )
  list(APPEND _normalizerModules CheckFortranSourceCompiles)

  # CheckFortranSourceRuns
  set(
    module_CheckFortranSourceRuns
      check_fortran_source_runs
  )
  list(APPEND _normalizerModules CheckFortranSourceRuns)

  # CheckFunctionExists
  set(
    module_CheckFunctionExists
      check_function_exists
  )
  list(APPEND _normalizerModules CheckFunctionExists)

  # CheckIncludeFile
  set(
    module_CheckIncludeFile
      check_include_file
  )
  list(APPEND _normalizerModules CheckIncludeFile)

  # CheckIncludeFileCXX
  set(
    module_CheckIncludeFileCXX
      check_include_file_cxx
  )
  list(APPEND _normalizerModules CheckIncludeFileCXX)

  # CheckIncludeFiles
  set(
    module_CheckIncludeFiles
      check_include_files
  )
  list(APPEND _normalizerModules CheckIncludeFiles)

  # CheckIPOSupported
  set(
    module_CheckIPOSupported
      check_ipo_supported
  )
  list(APPEND _normalizerModules CheckIPOSupported)

  # CheckLanguage
  set(
    module_CheckLanguage
      check_language
  )
  list(APPEND _normalizerModules CheckLanguage)

  # CheckLibraryExists
  set(
    module_CheckLibraryExists
      check_library_exists
  )
  list(APPEND _normalizerModules CheckLibraryExists)

  # CheckLinkerFlag
  set(
    module_CheckLinkerFlag
      check_linker_flag
  )
  list(APPEND _normalizerModules CheckLinkerFlag)

  # CheckOBJCCompilerFlag
  set(
    module_CheckOBJCCompilerFlag
      check_objc_compiler_flag
  )
  list(APPEND _normalizerModules CheckOBJCCompilerFlag)

  # CheckOBJCSourceCompiles
  set(
    module_CheckOBJCSourceCompiles
      check_objc_source_compiles
  )
  list(APPEND _normalizerModules CheckOBJCSourceCompiles)

  # CheckOBJCSourceRuns
  set(
    module_CheckOBJCSourceRuns
      check_objc_source_runs
  )
  list(APPEND _normalizerModules CheckOBJCSourceRuns)

  # CheckOBJCXXCompilerFlag
  set(
    module_CheckOBJCXXCompilerFlag
      check_objcxx_compiler_flag
  )
  list(APPEND _normalizerModules CheckOBJCXXCompilerFlag)

  # CheckOBJCXXSourceCompiles
  set(
    module_CheckOBJCXXSourceCompiles
      check_objcxx_source_compiles
  )
  list(APPEND _normalizerModules CheckOBJCXXSourceCompiles)

  # CheckOBJCXXSourceRuns
  set(
    module_CheckOBJCXXSourceRuns
      check_objcxx_source_runs
  )
  list(APPEND _normalizerModules CheckOBJCXXSourceRuns)

  # CheckPIESupported
  set(
    module_CheckPIESupported
      check_pie_supported
  )
  list(APPEND _normalizerModules CheckPIESupported)

  # CheckPrototypeDefinition
  set(
    module_CheckPrototypeDefinition
      check_prototype_definition
  )
  list(APPEND _normalizerModules CheckPrototypeDefinition)

  # CheckSourceCompiles
  set(
    module_CheckSourceCompiles
      check_source_compiles
  )
  list(APPEND _normalizerModules CheckSourceCompiles)

  # CheckSourceRuns
  set(
    module_CheckSourceRuns
      check_source_runs
  )
  list(APPEND _normalizerModules CheckSourceRuns)

  # CheckStructHasMember
  set(
    module_CheckStructHasMember
      check_struct_has_member
  )
  list(APPEND _normalizerModules CheckStructHasMember)

  # CheckSymbolExists
  set(
    module_CheckSymbolExists
      check_symbol_exists
  )
  list(APPEND _normalizerModules CheckSymbolExists)

  # CheckTypeSize
  set(
    module_CheckTypeSize
      check_type_size
  )
  list(APPEND _normalizerModules CheckTypeSize)

  # CheckVariableExists
  set(
    module_CheckVariableExists
      check_variable_exists
  )
  list(APPEND _normalizerModules CheckVariableExists)

  # CMakeAddFortranSubdirectory
  set(
    module_CMakeAddFortranSubdirectory
      cmake_add_fortran_subdirectory
  )
  list(APPEND _normalizerModules CMakeAddFortranSubdirectory)

  # CMakeDependentOption
  set(
    module_CMakeDependentOption
      cmake_dependent_option
  )
  list(APPEND _normalizerModules CMakeDependentOption)

  # CMakeFindDependencyMacro
  set(
    module_CMakeFindDependencyMacro
      find_dependency
  )
  list(APPEND _normalizerModules CMakeFindDependencyMacro)

  # CMakePackageConfigHelpers
  set(
    module_CMakePackageConfigHelpers
      configure_package_config_file
      generate_apple_architecture_selection_file
      generate_apple_platform_selection_file
      write_basic_package_version_file
  )
  list(APPEND _normalizerModules CMakePackageConfigHelpers)

  # CMakePrintHelpers
  set(
    module_CMakePrintHelpers
      cmake_print_properties
      cmake_print_variables
  )
  list(APPEND _normalizerModules CMakePrintHelpers)

  # CMakePushCheckState
  set(
    module_CMakePushCheckState
      cmake_pop_check_state
      cmake_push_check_state
      cmake_reset_check_state
  )
  list(APPEND _normalizerModules CMakePushCheckState)

  # CPack
  set(
    module_CPack
      cpack_add_component
      cpack_add_component_group
      cpack_add_install_type
      cpack_configure_downloads
  )
  list(APPEND _normalizerModules CPack)
  # CPackComponent
  set(
    module_CPackComponent
      cpack_add_component
      cpack_add_component_group
      cpack_add_install_type
      cpack_configure_downloads
  )
  list(APPEND _normalizerModules CPackComponent)

  # CPackIFWConfigureFile
  set(
    module_CPackIFWConfigureFile
      cpack_ifw_configure_file
  )
  list(APPEND _normalizerModules CPackIFWConfigureFile)

  # CPackIFW
  set(
    module_CPackIFW
      cpack_ifw_add_package_resources
      cpack_ifw_add_repository
      cpack_ifw_configure_component
      cpack_ifw_configure_component_group
      cpack_ifw_update_repository
  )
  list(APPEND _normalizerModules CPackIFW)

  # CSharpUtilities
  set(
    module_CSharpUtilities
      csharp_get_dependentupon_name
      csharp_get_filename_key_base
      csharp_get_filename_keys
      csharp_set_designer_cs_properties
      csharp_set_windows_forms_properties
      csharp_set_xaml_cs_properties
  )
  list(APPEND _normalizerModules CSharpUtilities)

  # CTestCoverageCollectGCOV
  set(
    module_CTestCoverageCollectGCOV
      ctest_coverage_collect_gcov
  )
  list(APPEND _normalizerModules CTestCoverageCollectGCOV)

  # ExternalData
  set(
    module_ExternalData
      ExternalData_Add_Target
      ExternalData_Add_Test
      ExternalData_Expand_Arguments
  )
  list(APPEND _normalizerModules ExternalData)

  # ExternalProject
  set(
    module_ExternalProject
      ExternalProject_Add
      ExternalProject_Add_Step
      ExternalProject_Add_StepDependencies
      ExternalProject_Add_StepTargets
      ExternalProject_Get_Property
  )
  list(APPEND _normalizerModules ExternalProject)

  # FeatureSummary
  set(
    module_FeatureSummary
      add_feature_info
      feature_summary
      set_package_properties
      # TODO: Obsolete commands set_package_info, set_feature_info, print_enabled_features, print_disabled_features
  )
  list(APPEND _normalizerModules FeatureSummary)

  # FetchContent
  set(
    module_FetchContent
      FetchContent_Declare
      FetchContent_GetProperties
      FetchContent_MakeAvailable
      FetchContent_Populate
      FetchContent_SetPopulated
  )
  list(APPEND _normalizerModules FetchContent)

  # FindPackageHandleStandardArgs
  set(
    module_FindPackageHandleStandardArgs
      find_package_check_version
      find_package_handle_standard_args
  )
  list(APPEND _normalizerModules FindPackageHandleStandardArgs)

  # FindPackageMessage
  set(
    module_FindPackageMessage
      find_package_message
  )
  list(APPEND _normalizerModules FindPackageMessage)

  # GenerateExportHeader
  set(
    module_GenerateExportHeader
      generate_export_header
      # TODO: add_compiler_export_flags is deprecated.
  )
  list(APPEND _normalizerModules GenerateExportHeader)

  # GNUInstallDirs
  set(
    module_GNUInstallDirs
      GNUInstallDirs_get_absolute_install_dir
  )
  list(APPEND _normalizerModules GNUInstallDirs)

  # GoogleTest
  set(
    module_GoogleTest
      gtest_add_tests
      gtest_discover_tests
  )
  list(APPEND _normalizerModules GoogleTest)

  # ProcessorCount
  set(
    module_ProcessorCount
      ProcessorCount
  )
  list(APPEND _normalizerModules ProcessorCount)

  # SelectLibraryConfigurations
  set(
    module_SelectLibraryConfigurations
      select_library_configurations
  )
  list(APPEND _normalizerModules SelectLibraryConfigurations)

  # UseEcos
  set(
    module_UseEcos
      ecos_add_executable
      ecos_add_include_directories
      ecos_add_target_lib
      ecos_adjust_directory
      ecos_use_arm_elf_tools
      ecos_use_i386_elf_tools
      ecos_use_ppc_eabi_tools
  )
  list(APPEND _normalizerModules UseEcos)

  # UseJava
  set(
    module_UseJava
      add_jar
      create_javadoc
      create_javah
      export_jars
      find_jar
      install_jar
      install_jar_exports
      install_jni_symlink
  )
  list(APPEND _normalizerModules UseJava)

  # UseSWIG
  set(
    module_UseSWIG
      swig_add_library
  )
  list(APPEND _normalizerModules UseSWIG)

  # Append local modules.
  if(normalize_include_modules_local)
    normalizer_local_modules_parse(_normalizerModules)
  endif()

  if(ARGV2)
    foreach(_moduleName IN LISTS _normalizerModules)
      string(MAKE_C_IDENTIFIER ${_moduleName} moduleId)

      if(${ARGV2} IN_LIST module_${moduleId})
        list(APPEND ${ARGV0} ${_moduleName})
      endif()
    endforeach()
    return(PROPAGATE ${ARGV0})
  endif()

  set(${ARGV0} ${_normalizerModules})

  foreach(_moduleName IN LISTS _normalizerModules)
    string(MAKE_C_IDENTIFIER ${_moduleName} moduleId)
    list(APPEND ${ARGV1} ${module_${moduleId}})
  endforeach()

  return(PROPAGATE ${ARGV0} ${ARGV1})
endfunction()

function(normalizer_data_commands)
  # Add commands from CMake modules.
  normalizer_data_modules(_ ${ARGV0} "")

  list(
    APPEND
    ${ARGV0}
    # Commands
    add_compile_definitions;add_compile_options;add_custom_command;add_custom_target;add_definitions;add_dependencies;add_executable;add_library;add_link_options;add_subdirectory;add_test;aux_source_directory;block;break;build_command;build_name;cmake_file_api;cmake_host_system_information;cmake_language;cmake_minimum_required;cmake_parse_arguments;cmake_path;cmake_pkg_config;cmake_policy;configure_file;continue;create_test_sourcelist;ctest_build;ctest_configure;ctest_coverage;ctest_empty_binary_directory;ctest_memcheck;ctest_read_custom_files;ctest_run_script;ctest_sleep;ctest_start;ctest_submit;ctest_test;ctest_update;ctest_upload;define_property;else;elseif;enable_language;enable_testing;endblock;endforeach;endfunction;endif;endmacro;endwhile;exec_program;execute_process;export;export_library_dependencies;file;find_file;find_library;find_package;find_path;find_program;fltk_wrap_ui;foreach;function;get_cmake_property;get_directory_property;get_filename_component;get_property;get_source_file_property;get_target_property;get_test_property;if;include;include_directories;include_external_msproject;include_guard;include_regular_expression;install;install_files;install_programs;install_targets;link_directories;link_libraries;list;load_cache;load_command;macro;make_directory;mark_as_advanced;math;message;option;output_required_files;project;qt_wrap_cpp;qt_wrap_ui;remove;remove_definitions;return;separate_arguments;set;set_directory_properties;set_property;set_source_files_properties;set_target_properties;set_tests_properties;site_name;source_group;string;subdir_depends;subdirs;target_compile_definitions;target_compile_features;target_compile_options;target_include_directories;target_link_directories;target_link_libraries;target_link_options;target_precompile_headers;target_sources;try_compile;try_run;unset;use_mangled_mesa;utility_source;variable_requires;variable_watch;while;write_file
    # Commands
  )

  return(PROPAGATE ${ARGV0})
endfunction()
