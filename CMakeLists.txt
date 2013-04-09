cmake_minimum_required(VERSION 2.8.6)
project(superbuild NONE)

include(setup-superbuild.cmake)

include(setup-project-variables.cmake)

include(external-project-macros.cmake)


install_eigen()
fetch_vtk()
fetch_ves()
fetch_pcl()
fetch_boost()
fetch_flann()

compile_vtk()

set(tags)

if(BUILD_ANDROID)
 list(APPEND tags android)
endif()
if(BUILD_IOS_DEVICE)
 list(APPEND tags ios-device)
endif()
if(BUILD_IOS_SIMULATOR)
 list(APPEND tags ios-simulator)
endif()

if (!ANDROID_ABI)
  set(ANDROID_ABI "armeabi")
endif()

if (!ANDROID_NATIVE_API_LEVEL)
  set(ANDROID_ABI 9)
endif()

if (!ANDROID_ABI)
  set(ANDROID_TOOLCHAIN_NAME "arm-linux-androideabi-4.6")
endif()

message(STATUS "Android ABI: ${ANDROID_ABI}")
message(STATUS "Android API Level: ${ANDROID_NATIVE_API_LEVEL}")
message(STATUS "Android Toolchain: ${ANDROID_TOOLCHAIN_NAME}")

foreach(tag ${tags})
  crosscompile_vtk(${tag} ${ANDROID_ABI} ${ANDROID_NATIVE_API_LEVEL} ${ANDROID_TOOLCHAIN_NAME})
  crosscompile_boost(${tag} ${ANDROID_ABI} ${ANDROID_NATIVE_API_LEVEL} ${ANDROID_TOOLCHAIN_NAME})
  crosscompile_flann(${tag} ${ANDROID_ABI} ${ANDROID_NATIVE_API_LEVEL} ${ANDROID_TOOLCHAIN_NAME})
  crosscompile_pcl(${tag} ${ANDROID_ABI} ${ANDROID_NATIVE_API_LEVEL} ${ANDROID_TOOLCHAIN_NAME})
  crosscompile_ves(${tag} ${ANDROID_ABI} ${ANDROID_NATIVE_API_LEVEL} ${ANDROID_TOOLCHAIN_NAME})
endforeach()

if (BUILD_IOS_DEVICE)
  create_pcl_framework()
endif()
