include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://gitlab.com
    REPO plastimatch/plastimatch
    HEAD_REF master
    PATCHES
        fftw3_dependency.patch
        itk_targets.patch
)

file(REMOVE_RECURSE ${SOURCE_PATH}/libs/itk-3.20.0)
file(REMOVE_RECURSE ${SOURCE_PATH}/libs/dlib-19.1)
file(REMOVE_RECURSE ${SOURCE_PATH}/libs/sqlite-3.6.21)

if("cuda" IN_LIST FEATURES)
  set(WITH_CUDA ON)
else()
  set(WITH_CUDA OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPLM_SYSTEM_DCMTK=YES
        -DPLM_SYSTEM_ITK=YES
        -DPLM_ENABLE_OPENCL=ON
        -DPLM_ENABLE_OPENMP=ON
        -DPLM_CONFIG_ENABLE_CUDA=${WITH_CUDA}
        -DPLM_PREFER_SYSTEM_DLIB=ON
    OPTIONS_DEBUG
        -DDLIB_ENABLE_ASSERTS=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/plastimatch)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(COPY ${CURRENT_PACKAGES_DIR}/share/doc/plastimatch/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/plastimatch/license)
file(COPY ${CURRENT_PACKAGES_DIR}/share/doc/plastimatch/COPYRIGHT.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/plastimatch/copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/doc)
