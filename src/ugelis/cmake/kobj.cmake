function(gen_kobj gen_dir_out)
  if (PROJECT_BINARY_DIR)
    set(gen_dir ${PROJECT_BINARY_DIR}/include/generated)
  else ()
    set(gen_dir ${CMAKE_BINARY_DIR}/include/generated)
  endif ()

  set(KOBJ_TYPES ${gen_dir}/kobj-types-enum.h)
  set(KOBJ_OTYPE ${gen_dir}/otype-to-str.h)
  set(KOBJ_SIZE ${gen_dir}/otype-to-size.h)

  file(MAKE_DIRECTORY ${gen_dir})

  add_custom_command(
    OUTPUT ${KOBJ_TYPES} ${KOBJ_OTYPE}
    COMMAND
    ${PYTHON_EXECUTABLE}
    $ENV{UGELIS_BASE}/scripts/gen_kobject_list.py
    --kobj-types-output ${KOBJ_TYPES}
    --kobj-otype-output ${KOBJ_OTYPE}
    --kobj-size-output ${KOBJ_SIZE}
    $<$<BOOL:${CMAKE_VERBOSE_MAKEFILE}>:--verbose>
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )
  add_custom_target(kobj_types_h_target DEPENDS ${KOBJ_TYPES} ${KOBJ_OTYPE})

  set(${gen_dir_out} ${gen_dir} PARENT_SCOPE)

endfunction ()
