include(CheckCCompilerFlag)
include(CheckCXXCompilerFlag)

########################################################
# Table of contents
########################################################
# 1. uGelis-aware extensions
# 1.1. ugelis_*
# 1.2. ugelis_library_*
# 1.2.1 ugelis_interface_library_*
# 1.3. generate_inc_*
# 1.4. board_*
# 1.5. Misc.
# 2. Kconfig-aware extensions
# 2.1 *_if_kconfig
# 2.2 Misc
# 3. CMake-generic extensions
# 3.1. *_ifdef
# 3.2. *_ifndef
# 3.3. *_option compiler compatibility checks
# 3.4. Debugging CMake
# 3.5. File system management

########################################################
# 1. uGelis-aware extensions
########################################################
# 1.1. ugelis_*
#
# The following methods are for modifying the CMake library[0] called
# "ugelis". ugelis is a catchall CMake library for source files that
# can be built purely with the include paths, defines, and other
# compiler flags that all ugelis source files use.
# [0] https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html
#
# Example usage:
# ugelis_sources(
#   random_esp32.c
#   utils.c
#   )
#
# Is short for:
# target_sources(ugelis PRIVATE
#   ${CMAKE_CURRENT_SOURCE_DIR}/random_esp32.c
#   ${CMAKE_CURRENT_SOURCE_DIR}/utils.c
#  )

# https://cmake.org/cmake/help/latest/command/target_sources.html
function(ugelis_sources)
  foreach(arg ${ARGV})
    if(IS_ABSOLUTE ${arg})
      set(path ${arg})
    else()
      set(path ${CMAKE_CURRENT_SOURCE_DIR}/${arg})
    endif()

    if(IS_DIRECTORY ${path})
      message(FATAL_ERROR "ugelis_sources() was called on a directory")
    endif()

    target_sources(ugelis PRIVATE ${path})
  endforeach()
endfunction()

# https://cmake.org/cmake/help/latest/command/target_include_directories.html
function(ugelis_include_directories)
  foreach(arg ${ARGV})
    if(IS_ABSOLUTE ${arg})
      set(path ${arg})
    else()
      set(path ${CMAKE_CURRENT_SOURCE_DIR}/${arg})
    endif()
    target_include_directories(ugelis_interface INTERFACE ${path})
  endforeach()
endfunction()

# https://cmake.org/cmake/help/latest/command/target_include_directories.html
function(ugelis_system_include_directories)
  foreach(arg ${ARGV})
    if(IS_ABSOLUTE ${arg})
      set(path ${arg})
    else()
      set(path ${CMAKE_CURRENT_SOURCE_DIR}/${arg})
    endif()
    target_include_directories(ugelis_interface SYSTEM INTERFACE ${path})
  endforeach()
endfunction()

# https://cmake.org/cmake/help/latest/command/target_compile_definitions.html
function(ugelis_compile_definitions)
  target_compile_definitions(ugelis_interface INTERFACE ${ARGV})
endfunction()

# https://cmake.org/cmake/help/latest/command/target_compile_options.html
function(ugelis_compile_options)
  target_compile_options(ugelis_interface INTERFACE ${ARGV})
endfunction()

# https://cmake.org/cmake/help/latest/command/target_link_libraries.html
function(ugelis_link_libraries)
  target_link_libraries(ugelis_interface INTERFACE ${ARGV})
endfunction()

# See this file section 3.1. target_cc_option
function(ugelis_cc_option)
  foreach(arg ${ARGV})
    target_cc_option(ugelis_interface INTERFACE ${arg})
  endforeach()
endfunction()

function(ugelis_cc_option_fallback option1 option2)
    target_cc_option_fallback(ugelis_interface INTERFACE ${option1} ${option2})
endfunction()

function(ugelis_ld_options)
    target_ld_options(ugelis_interface INTERFACE ${ARGV})
endfunction()

# Getter functions for extracting build information from
# ugelis_interface. Returning lists, and strings is supported, as is
# requesting specific categories of build information (defines,
# includes, options).
#
# The naming convention follows:
# ugelis_get_${build_information}_for_lang${format}(lang x [SKIP_PREFIX])
# Where
#  the argument 'x' is written with the result
# and
#  ${build_information} can be one of
#   - include_directories           # -I directories
#   - system_include_directories    # -isystem directories
#   - compile_definitions           # -D'efines
#   - compile_options               # misc. compiler flags
# and
#  ${format} can be
#   - the empty string '', signifying that it should be returned as a list
#   - _as_string signifying that it should be returned as a string
# and
#  ${lang} can be one of
#   - C
#   - CXX
#   - ASM
#
# SKIP_PREFIX
#
# By default the result will be returned ready to be passed directly
# to a compiler, e.g. prefixed with -D, or -I, but it is possible to
# omit this prefix by specifying 'SKIP_PREFIX' . This option has no
# effect for 'compile_options'.
#
# e.g.
# ugelis_get_include_directories_for_lang(ASM x)
# writes "-Isome_dir;-Isome/other/dir" to x

function(ugelis_get_include_directories_for_lang_as_string lang i)
  ugelis_get_include_directories_for_lang(${lang} list_of_flags ${ARGN})

  convert_list_of_flags_to_string_of_flags(list_of_flags str_of_flags)

  set(${i} ${str_of_flags} PARENT_SCOPE)
endfunction()

function(ugelis_get_system_include_directories_for_lang_as_string lang i)
  ugelis_get_system_include_directories_for_lang(${lang} list_of_flags ${ARGN})

  convert_list_of_flags_to_string_of_flags(list_of_flags str_of_flags)

  set(${i} ${str_of_flags} PARENT_SCOPE)
endfunction()

function(ugelis_get_compile_definitions_for_lang_as_string lang i)
  ugelis_get_compile_definitions_for_lang(${lang} list_of_flags ${ARGN})

  convert_list_of_flags_to_string_of_flags(list_of_flags str_of_flags)

  set(${i} ${str_of_flags} PARENT_SCOPE)
endfunction()

function(ugelis_get_compile_options_for_lang_as_string lang i)
  ugelis_get_compile_options_for_lang(${lang} list_of_flags)

  convert_list_of_flags_to_string_of_flags(list_of_flags str_of_flags)

  set(${i} ${str_of_flags} PARENT_SCOPE)
endfunction()

function(ugelis_get_include_directories_for_lang lang i)
  get_property_and_add_prefix(flags ugelis_interface INTERFACE_INCLUDE_DIRECTORIES
    "-I"
    ${ARGN}
    )

  process_flags(${lang} flags output_list)

  set(${i} ${output_list} PARENT_SCOPE)
endfunction()

function(ugelis_get_system_include_directories_for_lang lang i)
  get_property_and_add_prefix(flags ugelis_interface INTERFACE_SYSTEM_INCLUDE_DIRECTORIES
    "-isystem"
    ${ARGN}
    )

  process_flags(${lang} flags output_list)

  set(${i} ${output_list} PARENT_SCOPE)
endfunction()

function(ugelis_get_compile_definitions_for_lang lang i)
  get_property_and_add_prefix(flags ugelis_interface INTERFACE_COMPILE_DEFINITIONS
    "-D"
    ${ARGN}
    )

  process_flags(${lang} flags output_list)

  set(${i} ${output_list} PARENT_SCOPE)
endfunction()

function(ugelis_get_compile_options_for_lang lang i)
  get_property(flags TARGET ugelis_interface PROPERTY INTERFACE_COMPILE_OPTIONS)

  process_flags(${lang} flags output_list)

  set(${i} ${output_list} PARENT_SCOPE)
endfunction()

# This function writes a dict to it's output parameter
# 'return_dict'. The dict has information about the parsed arguments,
#
# Usage:
#   ugelis_get_parse_args(foo ${ARGN})
#   print(foo_STRIP_PREFIX) # foo_STRIP_PREFIX might be set to 1
function(ugelis_get_parse_args return_dict)
  foreach(x ${ARGN})
    if(x STREQUAL STRIP_PREFIX)
      set(${return_dict}_STRIP_PREFIX 1 PARENT_SCOPE)
    endif()
  endforeach()
endfunction()

function(process_flags lang input output)
  # The flags might contains compile language generator expressions that
  # look like this:
  # $<$<COMPILE_LANGUAGE:CXX>:-fno-exceptions>
  #
  # Flags that don't specify a language like this apply to all
  # languages.
  #
  # See COMPILE_LANGUAGE in
  # https://cmake.org/cmake/help/v3.3/manual/cmake-generator-expressions.7.html
  #
  # To deal with this, we apply a regex to extract the flag and also
  # to find out if the language matches.
  #
  # If this doesn't work out we might need to ban the use of
  # COMPILE_LANGUAGE and instead partition C, CXX, and ASM into
  # different libraries
  set(languages C CXX ASM)

  set(tmp_list "")

  foreach(flag ${${input}})
    set(is_compile_lang_generator_expression 0)
    foreach(l ${languages})
      if(flag MATCHES "<COMPILE_LANGUAGE:${l}>:([^>]+)>")
        set(is_compile_lang_generator_expression 1)
        if(${l} STREQUAL ${lang})
          list(APPEND tmp_list ${CMAKE_MATCH_1})
          break()
        endif()
      endif()
    endforeach()

    if(NOT is_compile_lang_generator_expression)
      list(APPEND tmp_list ${flag})
    endif()
  endforeach()

  set(${output} ${tmp_list} PARENT_SCOPE)
endfunction()

function(convert_list_of_flags_to_string_of_flags ptr_list_of_flags string_of_flags)
  # Convert the list to a string so we can do string replace
  # operations on it and replace the ";" list separators with a
  # whitespace so the flags are spaced out
  string(REPLACE ";"  " "  locally_scoped_string_of_flags "${${ptr_list_of_flags}}")

  # Set the output variable in the parent scope
  set(${string_of_flags} ${locally_scoped_string_of_flags} PARENT_SCOPE)
endfunction()

macro(get_property_and_add_prefix result target property prefix)
  ugelis_get_parse_args(args ${ARGN})

  if(args_STRIP_PREFIX)
    set(maybe_prefix "")
  else()
    set(maybe_prefix ${prefix})
  endif()

  get_property(target_property TARGET ${target} PROPERTY ${property})
  foreach(x ${target_property})
    list(APPEND ${result} ${maybe_prefix}${x})
  endforeach()
endmacro()

# 1.3 generate_inc_*

# These functions are useful if there is a need to generate a file
# that can be included into the application at build time. The file
# can also be compressed automatically when embedding it.
#
# See tests/application_development/gen_inc_file for an example of
# usage.
function(generate_inc_file
    source_file    # The source file to be converted to hex
    generated_file # The generated file
    )
  add_custom_command(
    OUTPUT ${generated_file}
    COMMAND
    ${PYTHON_EXECUTABLE}
    ${UGELIS_BASE}/scripts/file2hex.py
    ${ARGN} # Extra arguments are passed to file2hex.py
    --file ${source_file}
    > ${generated_file} # Does pipe redirection work on Windows?
    DEPENDS ${source_file}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endfunction()

function(generate_inc_file_for_gen_target
    target          # The cmake target that depends on the generated file
    source_file     # The source file to be converted to hex
    generated_file  # The generated file
    gen_target      # The generated file target we depend on
                    # Any additional arguments are passed on to file2hex.py
    )
  generate_inc_file(${source_file} ${generated_file} ${ARGN})

  # Ensure 'generated_file' is generated before 'target' by creating a
  # dependency between the two targets

  add_dependencies(${target} ${gen_target})
endfunction()

function(generate_inc_file_for_target
    target          # The cmake target that depends on the generated file
    source_file     # The source file to be converted to hex
    generated_file  # The generated file
                    # Any additional arguments are passed on to file2hex.py
    )
  # Ensure 'generated_file' is generated before 'target' by creating a
  # 'custom_target' for it and setting up a dependency between the two
  # targets

  # But first create a unique name for the custom target
  string(
    RANDOM
    LENGTH 8
    random_chars
    )

  get_filename_component(basename ${generated_file} NAME)
  string(REPLACE "." "_" basename ${basename})
  string(REPLACE "@" "_" basename ${basename})

  set(generated_target_name "gen_${basename}_${random_chars}")

  add_custom_target(${generated_target_name} DEPENDS ${generated_file})
  generate_inc_file_for_gen_target(${target} ${source_file} ${generated_file} ${generated_target_name} ${ARGN})
endfunction()

# 1.2 ugelis_library_*
#
# uGelis libraries use CMake's library concept and a set of
# assumptions about how ugelis code is organized to cut down on
# boilerplate code.
#
# A uGelis library can be constructed by the function ugelis_library
# or ugelis_library_named. The constructors create a CMake library
# with a name accessible through the variable UGELIS_CURRENT_LIBRARY.
#
# The variable UGELIS_CURRENT_LIBRARY should seldomly be needed since
# the ugelis libraries have methods that modify the libraries. These
# methods have the signature: ugelis_library_<target-function>
#
# The methods are wrappers around the CMake target_* functions. See
# https://cmake.org/cmake/help/latest/manual/cmake-commands.7.html for
# documentation on the underlying target_* functions.
#
# The methods modify the CMake target_* API to reduce boilerplate;
#  PRIVATE is assumed
#  The target is assumed to be UGELIS_CURRENT_LIBRARY
#
# When a flag that is given through the ugelis_* API conflicts with
# the ugelis_library_* API then precedence will be given to the
# ugelis_library_* API. In other words, local configuration overrides
# global configuration.

# Constructor with a directory-inferred name
macro(ugelis_library)
  ugelis_library_get_current_dir_lib_name(lib_name)
  ugelis_library_named(${lib_name})
endmacro()

# Determines what the current directory's lib name would be and writes
# it to the argument "lib_name"
macro(ugelis_library_get_current_dir_lib_name lib_name)
  # Remove the prefix (/home/sebo/ugelis/driver/serial/CMakeLists.txt => driver/serial/CMakeLists.txt)
  file(RELATIVE_PATH name ${UGELIS_BASE} ${CMAKE_CURRENT_LIST_FILE})

  # Remove the filename (driver/serial/CMakeLists.txt => driver/serial)
  get_filename_component(name ${name} DIRECTORY)

  # Replace / with __ (driver/serial => driver__serial)
  string(REGEX REPLACE "/" "__" name ${name})

  set(${lib_name} ${name})
endmacro()

# Constructor with an explicitly given name.
macro(ugelis_library_named name)
  # This is a macro because we need add_library() to be executed
  # within the scope of the caller.
  set(UGELIS_CURRENT_LIBRARY ${name})
  add_library(${name} STATIC "")

  ugelis_append_cmake_library(${name})

  target_link_libraries(${name} ugelis_interface)
endmacro()


function(ugelis_link_interface interface)
  target_link_libraries(${interface} INTERFACE ugelis_interface)
endfunction()

#
# ugelis_library versions of normal CMake target_<func> functions
#
function(ugelis_library_sources source)
  target_sources(${UGELIS_CURRENT_LIBRARY} PRIVATE ${source} ${ARGN})
endfunction()

function(ugelis_library_include_directories)
  target_include_directories(${UGELIS_CURRENT_LIBRARY} PRIVATE ${ARGN})
endfunction()

function(ugelis_library_link_libraries item)
  target_link_libraries(${UGELIS_CURRENT_LIBRARY} ${item} ${ARGN})
endfunction()

function(ugelis_library_compile_definitions item)
  target_compile_definitions(${UGELIS_CURRENT_LIBRARY} PRIVATE ${item} ${ARGN})
endfunction()

function(ugelis_library_compile_options item)
  # The compiler is relied upon for sane behaviour when flags are in
  # conflict. Compilers generally give precedence to flags given late
  # on the command line. So to ensure that ugelis_library_* flags are
  # placed late on the command line we create a dummy interface
  # library and link with it to obtain the flags.
  #
  # Linking with a dummy interface library will place flags later on
  # the command line than the the flags from ugelis_interface because
  # ugelis_interface will be the first interface library that flags
  # are taken from.

  string(RANDOM random)
  set(lib_name options_interface_lib_${random})

  add_library(           ${lib_name} INTERFACE)
  target_compile_options(${lib_name} INTERFACE ${item} ${ARGN})

  target_link_libraries(${UGELIS_CURRENT_LIBRARY} ${lib_name})
endfunction()

function(ugelis_library_cc_option)
  foreach(option ${ARGV})
    string(MAKE_C_IDENTIFIER check${option} check)
    ugelis_check_compiler_flag(C ${option} ${check})

    if(${check})
      ugelis_library_compile_options(${option})
    endif()
  endforeach()
endfunction()

# Add the existing CMake library 'library' to the global list of
# uGelis CMake libraries. This is done automatically by the
# constructor but must called explicitly on CMake libraries that do
# not use a ugelis library constructor, but have source files that
# need to be included in the build.
function(ugelis_append_cmake_library library)
  set_property(GLOBAL APPEND PROPERTY UGELIS_LIBS ${library})
endfunction()

# 1.2.1 ugelis_interface_library_*
#
# A uGelis interface library is a thin wrapper over a CMake INTERFACE
# library. The most important responsibility of this abstraction is to
# ensure that when a user KConfig-enables a library then the header
# files of this library will be accessible to the 'app' library.
#
# This is done because when a user uses Kconfig to enable a library he
# expects to be able to include it's header files and call it's
# functions out-of-the box.
#
# A uGelis interface library should be used when there exists some
# build information (include directories, defines, compiler flags,
# etc.) that should be applied to a set of uGelis libraries and 'app'
# might be one of these libraries.
#
# uGelis libraries must explicitly call
# ugelis_library_link_libraries(<interface_library>) to use this build
# information. 'app' is treated as a special case for usability
# reasons; a Kconfig option (CONFIG_APP_LINK_WITH_<interface_library>)
# should exist for each interface_library and will determine if 'app'
# links with the interface_library.
#
# This API has a constructor like the ugelis_library API has, but it
# does not have wrappers over the other cmake target functions.
macro(ugelis_interface_library_named name)
  add_library(${name} INTERFACE)
  set_property(GLOBAL APPEND PROPERTY UGELIS_INTERFACE_LIBS ${name})
endmacro()

# 1.4. board_*
#
# This section is for extensions which control uGelis's board runners
# from the build system. The uGelis build system has targets for
# flashing and debugging supported boards. These are wrappers around a
# "runner" Python subpackage that is part of uGelis's "west" tool.
#
# This section provides glue between CMake and the Python code that
# manages the runners.

# This function is intended for board.cmake files and application
# CMakeLists.txt files.
#
# Usage from board.cmake files:
#   board_runner_args(runner "--some-arg=val1" "--another-arg=val2")
#
# The build system will then ensure the command line used to
# create the runner contains:
#   --some-arg=val1 --another-arg=val2
#
# Within application CMakeLists.txt files, ensure that all calls to
# board_runner_args() are part of a macro named app_set_runner_args(),
# like this, which is defined before including the boilerplate file:
#   macro(app_set_runner_args)
#     board_runner_args(runner "--some-app-setting=value")
#   endmacro()
#
# The build system tests for the existence of the macro and will
# invoke it at the appropriate time if it is defined.
#
# Any explicitly provided settings given by this function override
# defaults provided by the build system.
function(board_runner_args runner)
  string(MAKE_C_IDENTIFIER ${runner} runner_id)
  # Note the "_EXPLICIT_" here, and see below.
  set_property(GLOBAL APPEND PROPERTY BOARD_RUNNER_ARGS_EXPLICIT_${runner_id} ${ARGN})
endfunction()

# This function is intended for internal use by
# boards/common/runner.board.cmake files.
#
# Basic usage:
#   board_finalize_runner_args(runner)
#
# This ensures the build system captures all arguments added in any
# board_runner_args() calls, and otherwise finishes registering a
# runner for use.
#
# Extended usage:
#   board_runner_args(runner "--some-arg=default-value")
#
# This provides common or default values for arguments. These are
# placed before board_runner_args() calls, so they generally take
# precedence, except for arguments which can be given multiple times
# (use these with caution).
function(board_finalize_runner_args runner)
  # If the application provided a macro to add additional runner
  # arguments, handle them.
  if(COMMAND app_set_runner_args)
    app_set_runner_args()
  endif()

  # Retrieve the list of explicitly set arguments.
  string(MAKE_C_IDENTIFIER ${runner} runner_id)
  get_property(explicit GLOBAL PROPERTY "BOARD_RUNNER_ARGS_EXPLICIT_${runner_id}")

  # Note no _EXPLICIT_ here. This property contains the final list.
  set_property(GLOBAL APPEND PROPERTY BOARD_RUNNER_ARGS_${runner_id}
    # Default arguments from the common runner file come first.
    ${ARGN}
    # Arguments explicitly given with board_runner_args() come
    # last, so they take precedence.
    ${explicit}
    )

  # Add the finalized runner to the global property list.
  set_property(GLOBAL APPEND PROPERTY UGELIS_RUNNERS ${runner})
endfunction()

# 1.5. Misc.

# ugelis_check_compiler_flag is a part of uGelis's toolchain
# infrastructure. It should be used when testing toolchain
# capabilities and it should normally be used in place of the
# functions:
#
# check_compiler_flag
# check_c_compiler_flag
# check_cxx_compiler_flag
#
# See check_compiler_flag() for API documentation as it has the same
# API.
#
# It is implemented as a wrapper on top of check_compiler_flag, which
# again wraps the CMake-builtin's check_c_compiler_flag and
# check_cxx_compiler_flag.
#
# It takes time to check for compatibility of flags against toolchains
# so we cache the capability test results in USER_CACHE_DIR (This
# caching comes in addition to the caching that CMake does in the
# build folder's CMakeCache.txt)
function(ugelis_check_compiler_flag lang option check)
  # Locate the cache
  set_ifndef(
    UGELIS_TOOLCHAIN_CAPABILITY_CACHE
    ${USER_CACHE_DIR}/ToolchainCapabilityDatabase.cmake
    )

  # Read the cache
  include(${UGELIS_TOOLCHAIN_CAPABILITY_CACHE} OPTIONAL)

  # We need to create a unique key wrt. testing the toolchain
  # capability. This key must be a valid C identifier that includes
  # everything that can affect the toolchain test.

  # The 'cacheformat' must be bumped if a bug in the caching mechanism
  # is detected and all old keys must be invalidated.
  set(cacheformat 2)

  set(key_string "")
  set(key_string "${key_string}UGELIS_TOOLCHAIN_CAPABILITY_CACHE_")
  set(key_string "${key_string}cacheformat_")
  set(key_string "${key_string}${cacheformat}_")
  set(key_string "${key_string}${TOOLCHAIN_SIGNATURE}_")
  set(key_string "${key_string}${lang}_")
  set(key_string "${key_string}${option}_")
  set(key_string "${key_string}${CMAKE_REQUIRED_FLAGS}_")

  string(MAKE_C_IDENTIFIER ${key_string} key)

  # Check the cache
  if(DEFINED ${key})
    set(${check} ${${key}} PARENT_SCOPE)
    return()
  endif()

  # Test the flag
  check_compiler_flag(${lang} "${option}" inner_check)

  set(${check} ${inner_check} PARENT_SCOPE)

  # Populate the cache
  file(
    APPEND
    ${UGELIS_TOOLCHAIN_CAPABILITY_CACHE}
    "set(${key} ${inner_check})\n"
    )
endfunction()

########################################################
# 2. Kconfig-aware extensions
########################################################
#
# Kconfig is a configuration language developed for the Linux
# kernel. The below functions integrate CMake with Kconfig.
#
# 2.1 *_if_kconfig
#
# Functions for conditionally including directories and source files
# that have matching KConfig values.
#
# ugelis_library_sources_if_kconfig(fft.c)
# is the same as
# ugelis_library_sources_ifdef(CONFIG_FFT fft.c)
#
# add_subdirectory_if_kconfig(serial)
# is the same as
# add_subdirectory_ifdef(CONFIG_SERIAL serial)
function(add_subdirectory_if_kconfig dir)
  string(TOUPPER config_${dir} UPPER_CASE_CONFIG)
  add_subdirectory_ifdef(${UPPER_CASE_CONFIG} ${dir})
endfunction()

function(target_sources_if_kconfig target scope item)
  get_filename_component(item_basename ${item} NAME_WE)
  string(TOUPPER CONFIG_${item_basename} UPPER_CASE_CONFIG)
  target_sources_ifdef(${UPPER_CASE_CONFIG} ${target} ${scope} ${item})
endfunction()

function(ugelis_library_sources_if_kconfig item)
  get_filename_component(item_basename ${item} NAME_WE)
  string(TOUPPER CONFIG_${item_basename} UPPER_CASE_CONFIG)
  ugelis_library_sources_ifdef(${UPPER_CASE_CONFIG} ${item})
endfunction()

function(ugelis_sources_if_kconfig item)
  get_filename_component(item_basename ${item} NAME_WE)
  string(TOUPPER CONFIG_${item_basename} UPPER_CASE_CONFIG)
  ugelis_sources_ifdef(${UPPER_CASE_CONFIG} ${item})
endfunction()

# 2.2 Misc
#
# Parse a KConfig formatted file (typically named *.config) and
# introduce all the CONF_ variables into the CMake namespace
function(import_kconfig config_file)
  # Parse the lines prefixed with CONFIG_ in ${config_file}
  file(
    STRINGS
    ${config_file}
    DOT_CONFIG_LIST
    REGEX "^CONFIG_"
    ENCODING "UTF-8"
  )

  foreach (CONFIG ${DOT_CONFIG_LIST})
    # CONFIG looks like: CONFIG_NET_BUF=y

    # Match the first part, the variable name
    string(REGEX MATCH "[^=]+" CONF_VARIABLE_NAME ${CONFIG})

    # Match the second part, variable value
    string(REGEX MATCH "=(.+$)" CONF_VARIABLE_VALUE ${CONFIG})
    # The variable name match we just did included the '=' symbol. To just get the
    # part on the RHS we use match group 1
    set(CONF_VARIABLE_VALUE ${CMAKE_MATCH_1})

    if("${CONF_VARIABLE_VALUE}" MATCHES "^\"(.*)\"$") # Is surrounded by quotes
      set(CONF_VARIABLE_VALUE ${CMAKE_MATCH_1})
    endif()

    set("${CONF_VARIABLE_NAME}" "${CONF_VARIABLE_VALUE}" PARENT_SCOPE)
  endforeach()
endfunction()

########################################################
# 3. CMake-generic extensions
########################################################
#
# These functions extend the CMake API in a way that is not particular
# to uGelis. Primarily they work around limitations in the CMake
# language to allow cleaner build scripts.

# 3.1. *_ifdef
#
# Functions for conditionally executing CMake functions with oneliners
# e.g.
#
# if(CONFIG_FFT)
#   ugelis_library_source(
#     fft_32.c
#     fft_utils.c
#     )
# endif()
#
# Becomes
#
# ugelis_source_ifdef(
#   CONFIG_FFT
#   fft_32.c
#   fft_utils.c
#   )
#
# More Generally
# "<function-name>_ifdef(CONDITION args)"
# Becomes
# """
# if(CONDITION)
#   <function-name>(args)
# endif()
# """
#
# ifdef functions are added on an as-need basis. See
# https://cmake.org/cmake/help/latest/manual/cmake-commands.7.html for
# a list of available functions.
function(add_subdirectory_ifdef feature_toggle dir)
  if(${${feature_toggle}})
    add_subdirectory(${dir})
  endif()
endfunction()

function(target_sources_ifdef feature_toggle target scope item)
  if(${${feature_toggle}})
    target_sources(${target} ${scope} ${item} ${ARGN})
  endif()
endfunction()

function(target_compile_definitions_ifdef feature_toggle target scope item)
  if(${${feature_toggle}})
    target_compile_definitions(${target} ${scope} ${item} ${ARGN})
  endif()
endfunction()

function(target_include_directories_ifdef feature_toggle target scope item)
  if(${${feature_toggle}})
    target_include_directories(${target} ${scope} ${item} ${ARGN})
  endif()
endfunction()

function(target_link_libraries_ifdef feature_toggle target item)
  if(${${feature_toggle}})
    target_link_libraries(${target} ${item} ${ARGN})
  endif()
endfunction()

function(add_compile_option_ifdef feature_toggle option)
  if(${${feature_toggle}})
    add_compile_options(${option})
  endif()
endfunction()

function(target_compile_option_ifdef feature_toggle target scope option)
  if(${feature_toggle})
    target_compile_options(${target} ${scope} ${option})
  endif()
endfunction()

function(target_cc_option_ifdef feature_toggle target scope option)
  if(${feature_toggle})
    target_cc_option(${target} ${scope} ${option})
  endif()
endfunction()

function(ugelis_library_sources_ifdef feature_toggle source)
  if(${${feature_toggle}})
    ugelis_library_sources(${source} ${ARGN})
  endif()
endfunction()

function(ugelis_sources_ifdef feature_toggle)
  if(${${feature_toggle}})
    ugelis_sources(${ARGN})
  endif()
endfunction()

function(ugelis_sources_ifndef feature_toggle)
   if(NOT ${feature_toggle})
    ugelis_sources(${ARGN})
  endif()
endfunction()

function(ugelis_cc_option_ifdef feature_toggle)
  if(${${feature_toggle}})
    ugelis_cc_option(${ARGN})
  endif()
endfunction()

function(ugelis_ld_option_ifdef feature_toggle)
  if(${${feature_toggle}})
    ugelis_ld_options(${ARGN})
  endif()
endfunction()

function(ugelis_link_libraries_ifdef feature_toggle)
  if(${${feature_toggle}})
    ugelis_link_libraries(${ARGN})
  endif()
endfunction()

function(ugelis_compile_options_ifdef feature_toggle)
  if(${${feature_toggle}})
    ugelis_compile_options(${ARGN})
  endif()
endfunction()

function(ugelis_compile_definitions_ifdef feature_toggle)
  if(${${feature_toggle}})
    ugelis_compile_definitions(${ARGN})
  endif()
endfunction()

function(ugelis_include_directories_ifdef feature_toggle)
  if(${${feature_toggle}})
    ugelis_include_directories(${ARGN})
  endif()
endfunction()

function(ugelis_library_compile_definitions_ifdef feature_toggle item)
  if(${${feature_toggle}})
    ugelis_library_compile_definitions(${item} ${ARGN})
  endif()
endfunction()

function(ugelis_library_compile_options_ifdef feature_toggle item)
  if(${${feature_toggle}})
    ugelis_library_compile_options(${item} ${ARGN})
  endif()
endfunction()

function(ugelis_link_interface_ifdef feature_toggle interface)
  if(${${feature_toggle}})
    target_link_libraries(${interface} INTERFACE ugelis_interface)
  endif()
endfunction()

function(ugelis_library_link_libraries_ifdef feature_toggle item)
  if(${${feature_toggle}})
     ugelis_library_link_libraries(${item})
  endif()
endfunction()

macro(list_append_ifdef feature_toggle list)
  if(${${feature_toggle}})
    list(APPEND ${list} ${ARGN})
  endif()
endmacro()

# 3.2. *_ifndef
# See 3.1 *_ifdef
function(set_ifndef variable value)
  if(NOT ${variable})
    set(${variable} ${value} ${ARGN} PARENT_SCOPE)
  endif()
endfunction()

function(target_cc_option_ifndef feature_toggle target scope option)
  if(NOT ${feature_toggle})
    target_cc_option(${target} ${scope} ${option})
  endif()
endfunction()

function(ugelis_cc_option_ifndef feature_toggle)
  if(NOT ${feature_toggle})
    ugelis_cc_option(${ARGN})
  endif()
endfunction()

function(ugelis_compile_options_ifndef feature_toggle)
  if(NOT ${feature_toggle})
    ugelis_compile_options(${ARGN})
  endif()
endfunction()

# 3.2. *_option Compiler-compatibility checks
#
# Utility functions for silently omitting compiler flags when the
# compiler lacks support. *_cc_option was ported from KBuild, see
# cc-option in
# https://www.kernel.org/doc/Documentation/kbuild/makefiles.txt

# Writes 1 to the output variable 'ok' for the language 'lang' if
# the flag is supported, otherwise writes 0.
#
# lang must be C or CXX
#
# TODO: Support ASM
#
# Usage:
#
# check_compiler_flag(C "-Wall" my_check)
# print(my_check) # my_check is now 1
function(check_compiler_flag lang option ok)
  if(NOT DEFINED CMAKE_REQUIRED_QUIET)
    set(CMAKE_REQUIRED_QUIET 1)
  endif()

  string(MAKE_C_IDENTIFIER
    check${option}_${lang}_${CMAKE_REQUIRED_FLAGS}
    ${ok}
    )

  if(${lang} STREQUAL C)
    check_c_compiler_flag("${option}" ${${ok}})
  else()
    check_cxx_compiler_flag("${option}" ${${ok}})
  endif()

  if(${${${ok}}})
    set(ret 1)
  else()
    set(ret 0)
  endif()

  set(${ok} ${ret} PARENT_SCOPE)
endfunction()

function(target_cc_option target scope option)
  target_cc_option_fallback(${target} ${scope} ${option} "")
endfunction()

# Support an optional second option for when the first option is not
# supported.
function(target_cc_option_fallback target scope option1 option2)
  if(CONFIG_CPLUSPLUS)
    foreach(lang C CXX)
      # For now, we assume that all flags that apply to C/CXX also
      # apply to ASM.
      ugelis_check_compiler_flag(${lang} ${option1} check)
      if(${check})
        target_compile_options(${target} ${scope}
          $<$<COMPILE_LANGUAGE:${lang}>:${option1}>
          $<$<COMPILE_LANGUAGE:ASM>:${option1}>
          )
      elseif(option2)
        target_compile_options(${target} ${scope}
          $<$<COMPILE_LANGUAGE:${lang}>:${option2}>
          $<$<COMPILE_LANGUAGE:ASM>:${option2}>
          )
      endif()
    endforeach()
  else()
    ugelis_check_compiler_flag(C ${option1} check)
    if(${check})
      target_compile_options(${target} ${scope} ${option1})
    elseif(option2)
      target_compile_options(${target} ${scope} ${option2})
    endif()
  endif()
endfunction()

function(target_ld_options target scope)
  foreach(option ${ARGN})
    string(MAKE_C_IDENTIFIER check${option} check)

    set(SAVED_CMAKE_REQUIRED_FLAGS ${CMAKE_REQUIRED_FLAGS})
    set(CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS} ${option}")
    ugelis_check_compiler_flag(C "" ${check})
    set(CMAKE_REQUIRED_FLAGS ${SAVED_CMAKE_REQUIRED_FLAGS})

    target_link_libraries_ifdef(${check} ${target} ${scope} ${option})
  endforeach()
endfunction()

# 3.4. Debugging CMake

# Usage:
#   print(BOARD)
#
# will print: "BOARD: nrf52_pca10040"
function(print arg)
  message(STATUS "${arg}: ${${arg}}")
endfunction()

# Usage:
#   assert(UGELIS_TOOLCHAIN_VARIANT "UGELIS_TOOLCHAIN_VARIANT not set.")
#
# will cause a FATAL_ERROR and print an error message if the first
# expression is false
macro(assert test comment)
  if(NOT ${test})
    message(FATAL_ERROR "Assertion failed: ${comment}")
  endif()
endmacro()

# Usage:
#   assert_not(FLASH_SCRIPT "FLASH_SCRIPT has been removed; use BOARD_FLASH_RUNNER")
#
# will cause a FATAL_ERROR and print an errorm essage if the first
# espression is true
macro(assert_not test comment)
  if(${test})
    message(FATAL_ERROR "Assertion failed: ${comment}")
  endif()
endmacro()

# Usage:
#   assert_exists(CMAKE_READELF)
#
# will cause a FATAL_ERROR if there is no file or directory behind the
# variable
macro(assert_exists var)
  if(NOT EXISTS ${${var}})
    message(FATAL_ERROR "No such file or directory: ${var}: '${${var}}'")
  endif()
endmacro()

# Usage:
#   assert_with_usage(BOARD_DIR "No board named '${BOARD}' found")
#
# will print an error message, show usage, and then end executioon
# with a FATAL_ERROR if the test fails.
macro(assert_with_usage test comment)
  if(NOT ${test})
    message(${comment})
    message("see usage:")
    execute_process(
      COMMAND
      ${CMAKE_COMMAND}
      -DBOARD_ROOT=${BOARD_ROOT}
      -P ${UGELIS_BASE}/cmake/usage/usage.cmake
      )
    message(FATAL_ERROR "Invalid usage")
  endif()
endmacro()

# 3.5. File system management
function(check_if_directory_is_writeable dir ok)
  execute_process(
    COMMAND
    ${PYTHON_EXECUTABLE}
    ${UGELIS_BASE}/scripts/dir_is_writeable.py
    ${dir}
    RESULT_VARIABLE ret
    )

  if("${ret}" STREQUAL "0")
    # The directory is write-able
    set(${ok} 1 PARENT_SCOPE)
  else()
    set(${ok} 0 PARENT_SCOPE)
  endif()
endfunction()

function(find_appropriate_cache_directory dir)
  set(env_suffix_LOCALAPPDATA   .cache)

  if(CMAKE_HOST_APPLE)
    # On macOS, ~/Library/Caches is the preferred cache directory.
    set(env_suffix_HOME Library/Caches)
  else()
    set(env_suffix_HOME .cache)
  endif()

  # Determine which env vars should be checked
  if(CMAKE_HOST_APPLE)
    set(dirs HOME)
  elseif(CMAKE_HOST_WIN32)
    set(dirs LOCALAPPDATA)
  else()
    # Assume Linux when we did not detect 'mac' or 'win'
    #
    # On Linux, freedesktop.org recommends using $XDG_CACHE_HOME if
    # that is defined and defaulting to $HOME/.cache otherwise.
    set(dirs
      XDG_CACHE_HOME
      HOME
      )
  endif()

  foreach(env_var ${dirs})
    if(DEFINED ENV{${env_var}})
      set(env_dir $ENV{${env_var}})

      check_if_directory_is_writeable(${env_dir} ok)
      if(${ok})
        # The directory is write-able
        set(user_dir ${env_dir}/${env_suffix_${env_var}})
        break()
      else()
        # The directory was not writeable, keep looking for a suitable
        # directory
      endif()
    endif()
  endforeach()

  # Populate local_dir with a suitable directory for caching
  # files. Prefer a directory outside of the git repository because it
  # is good practice to have clean git repositories.
  if(DEFINED user_dir)
    # uGelis's cache files go in the "ugelis" subdirectory of the
    # user's cache directory.
    set(local_dir ${user_dir}/ugelis)
  else()
    set(local_dir ${UGELIS_BASE}/.cache)
  endif()

  set(${dir} ${local_dir} PARENT_SCOPE)
endfunction()
