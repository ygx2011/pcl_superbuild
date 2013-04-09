
#
# force build macro
#
macro(force_build proj)
  ExternalProject_Add_Step(${proj} forcebuild
    COMMAND ${CMAKE_COMMAND} -E remove ${base}/Stamp/${proj}/${proj}-build
    DEPENDEES configure
    DEPENDERS build
    ALWAYS 1
  )
endmacro()

macro(get_toolchain_file tag)
  string(REPLACE "-" "_" tag_with_underscore ${tag})
  set(toolchain_file ${toolchain_${tag_with_underscore}})
endmacro()

macro(get_try_run_results_file tag)
  string(REPLACE "-" "_" tag_with_underscore ${tag})
  set(try_run_results_file ${try_run_results_${tag_with_underscore}})
endmacro()

#
# Eigen fetch and install
#
macro(install_eigen)
  set(eigen_url http://bitbucket.org/eigen/eigen/get/3.2-beta1.tar.gz)
  set(eigen_md5 cb34c447d1fac839d988141c90acc3de)
  ExternalProject_Add(
    eigen
    SOURCE_DIR ${source_prefix}/eigen
    URL ${eigen_url}
    URL_MD5 ${eigen_md5}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory "${source_prefix}/eigen/Eigen" "${install_prefix}/eigen/Eigen" && ${CMAKE_COMMAND} -E copy_directory "${source_prefix}/eigen/unsupported" "${install_prefix}/eigen/unsupported"
  )
endmacro()

#
# VTK fetch
#
macro(fetch_vtk)
  ExternalProject_Add(
    vtk-fetch
    SOURCE_DIR ${source_prefix}/vtk
    GIT_REPOSITORY git://github.com/Bastl34/VTK.git
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
  )
endmacro()

#
# VTK compile
#
macro(compile_vtk)
  set(proj vtk-host)
  ExternalProject_Add(
    ${proj}
    SOURCE_DIR ${source_prefix}/vtk
    DOWNLOAD_COMMAND ""
    INSTALL_COMMAND ""
    DEPENDS vtk-fetch
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}/${proj}
      -DCMAKE_BUILD_TYPE:STRING=${build_type}
      -DBUILD_SHARED_LIBS:BOOL=ON
      -DBUILD_TESTING:BOOL=OFF
      ${vtk_module_defaults}
  )
endmacro()

#
# VTK crosscompile
#
macro(crosscompile_vtk tag ANDROID_ABI ANDROID_NATIVE_API_LEVEL ANDROID_TOOLCHAIN_NAME)
  set(proj vtk-${tag})
  get_toolchain_file(${tag})
  get_try_run_results_file(${proj})
  ExternalProject_Add(
    ${proj}
    SOURCE_DIR ${source_prefix}/vtk
    DOWNLOAD_COMMAND ""
    DEPENDS vtk-host
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}/${proj}
      -DCMAKE_BUILD_TYPE:STRING=${build_type}
      -DBUILD_SHARED_LIBS:BOOL=OFF
      -DBUILD_TESTING:BOOL=OFF
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${toolchain_file}
      -DVTKCompileTools_DIR:PATH=${build_prefix}/vtk-host
      -DANDROID_ABI=${ANDROID_ABI}
      -DANDROID_NATIVE_API_LEVEL=${ANDROID_NATIVE_API_LEVEL}
      -DANDROID_TOOLCHAIN_NAME=${ANDROID_TOOLCHAIN_NAME}
      ${vtk_module_defaults}
      -C ${try_run_results_file}
  )
endmacro()


#
# VES fetch
#
macro(fetch_ves)
  ExternalProject_Add(
    ves-fetch
    SOURCE_DIR ${source_prefix}/ves
    GIT_REPOSITORY git://vtk.org/VES.git
    GIT_TAG 77c0a4a
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
  )
endmacro()

#
# VES crosscompile
#
macro(crosscompile_ves tag ANDROID_ABI ANDROID_NATIVE_API_LEVEL ANDROID_TOOLCHAIN_NAME)
  set(proj ves-${tag})
  get_toolchain_file(${tag})
  ExternalProject_Add(
    ${proj}
    SOURCE_DIR ${source_prefix}/ves
    DOWNLOAD_COMMAND ""
    DEPENDS ves-fetch vtk-${tag} eigen
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}/${proj}
      -DCMAKE_BUILD_TYPE:STRING=${build_type}
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${toolchain_file}
      -DCMAKE_CXX_FLAGS:STRING=${VES_CXX_FLAGS}
      -DBUILD_SHARED_LIBS:BOOL=OFF
      -DVES_USE_VTK:BOOL=ON
      -DVES_NO_SUPERBUILD:BOOL=ON
      -DVTK_DIR:PATH=${build_prefix}/vtk-${tag}
      -DEIGEN_INCLUDE_DIR:PATH=${install_prefix}/eigen
      -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON_EXECUTABLE}
      -DANDROID_ABI=${ANDROID_ABI}
      -DANDROID_NATIVE_API_LEVEL=${ANDROID_NATIVE_API_LEVEL}
      -DANDROID_TOOLCHAIN_NAME=${ANDROID_TOOLCHAIN_NAME}      
  )

  force_build(${proj})
endmacro()


#
# FLANN fetch
#
macro(fetch_flann)
  ExternalProject_Add(
    flann-fetch
    SOURCE_DIR ${source_prefix}/flann
    GIT_REPOSITORY git://github.com/Bastl34/flann.git
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
  )
endmacro()

#
# FLANN crosscompile
#
macro(crosscompile_flann tag ANDROID_ABI ANDROID_NATIVE_API_LEVEL ANDROID_TOOLCHAIN_NAME)
  set(proj flann-${tag})
  get_toolchain_file(${tag})
  ExternalProject_Add(
    ${proj}
    SOURCE_DIR ${source_prefix}/flann
    DOWNLOAD_COMMAND ""
    DEPENDS flann-fetch
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}/${proj}
      -DCMAKE_BUILD_TYPE:STRING=${build_type}
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${toolchain_file}
     # -DBUILD_SHARED_LIBS:BOOL=OFF
      -DBUILD_TESTING:BOOL=OFF
      -DBUILD_PYTHON_BINDINGS:BOOL=OFF
      -DBUILD_MATLAB_BINDINGS:BOOL=OFF
      -DANDROID_ABI=${ANDROID_ABI}
      -DANDROID_NATIVE_API_LEVEL=${ANDROID_NATIVE_API_LEVEL}
      -DANDROID_TOOLCHAIN_NAME=${ANDROID_TOOLCHAIN_NAME}      
  )

  force_build(${proj})
endmacro()


#
# Boost fetch
#
macro(fetch_boost)
  ExternalProject_Add(
    boost-fetch
    SOURCE_DIR ${source_prefix}/boost
    GIT_REPOSITORY git://github.com/Bastl34/boost-build
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
  )
endmacro()

#
# Boost crosscompile
#
macro(crosscompile_boost tag ANDROID_ABI ANDROID_NATIVE_API_LEVEL ANDROID_TOOLCHAIN_NAME)


  set(proj boost-${tag})
  get_toolchain_file(${tag})
  ExternalProject_Add(
    ${proj}
    SOURCE_DIR ${source_prefix}/boost
    DOWNLOAD_COMMAND ""
    DEPENDS boost-fetch
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}/${proj}
      -DCMAKE_BUILD_TYPE:STRING=${build_type}
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${toolchain_file}
      -DBUILD_SHARED_LIBS:BOOL=OFF
      -DANDROID_ABI=${ANDROID_ABI}
      -DANDROID_NATIVE_API_LEVEL=${ANDROID_NATIVE_API_LEVEL}
      -DANDROID_TOOLCHAIN_NAME=${ANDROID_TOOLCHAIN_NAME}      
  )

  force_build(${proj})
endmacro()


#
# PCL fetch
#
macro(fetch_pcl)
  ExternalProject_Add(
    pcl-fetch
    SOURCE_DIR ${source_prefix}/pcl
    GIT_REPOSITORY git://github.com/Bastl34/PCL.git
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
  )
endmacro()

#
# PCL crosscompile
#
macro(crosscompile_pcl tag ANDROID_ABI ANDROID_NATIVE_API_LEVEL ANDROID_TOOLCHAIN_NAME)
  set(proj pcl-${tag})
  get_toolchain_file(${tag})
  get_try_run_results_file(${proj})

  # copy the toolchain file and append the boost install dir to CMAKE_FIND_ROOT_PATH
  set(original_toolchain_file ${toolchain_file})
  get_filename_component(toolchain_file ${original_toolchain_file} NAME)
  set(toolchain_file ${build_prefix}/${proj}/${toolchain_file})
  configure_file(${original_toolchain_file} ${toolchain_file} COPYONLY)
  file(APPEND ${toolchain_file}
    "\nlist(APPEND CMAKE_FIND_ROOT_PATH ${install_prefix}/boost-${tag})\n")

  ExternalProject_Add(
    ${proj}
    SOURCE_DIR ${source_prefix}/pcl
    DOWNLOAD_COMMAND ""
    DEPENDS pcl-fetch boost-${tag} flann-${tag} eigen
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}/${proj}
      -DCMAKE_BUILD_TYPE:STRING=${build_type}
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${toolchain_file}
      -DBUILD_SHARED_LIBS:BOOL=OFF
      -DPCL_SHARED_LIBS:BOOL=OFF
      -DBUILD_visualization:BOOL=OFF
      -DBUILD_examples:BOOL=OFF
      -DEIGEN_INCLUDE_DIR=${install_prefix}/eigen
      -DFLANN_INCLUDE_DIR=${install_prefix}/flann-${tag}/include
      -DFLANN_LIBRARY=${install_prefix}/flann-${tag}/lib/libflann_cpp_s.a
      -DBOOST_ROOT=${install_prefix}/boost-${tag}
      -DANDROID_ABI=${ANDROID_ABI}
      -DANDROID_NATIVE_API_LEVEL=${ANDROID_NATIVE_API_LEVEL}
      -DANDROID_TOOLCHAIN_NAME=${ANDROID_TOOLCHAIN_NAME}      
      -C ${try_run_results_file}
  )

  force_build(${proj})
endmacro()


macro(create_pcl_framework)
    add_custom_target(pclFramework ALL
      COMMAND ${CMAKE_SOURCE_DIR}/makeFramework.sh pcl
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      DEPENDS pcl-ios-device
      COMMENT "Creating pcl.framework")
endmacro()
