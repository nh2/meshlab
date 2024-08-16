#############################################################################
# MeshLab                                                           o o     #
# A versatile mesh processing toolbox                             o     o   #
#                                                                _   O  _   #
# Copyright(C) 2023 - 2024                                         \/)\/    #
# Visual Computing Lab                                            /\/|      #
# ISTI - Italian National Research Council                           |      #
#                                                                    \      #
# All rights reserved.                                                      #
#                                                                           #
# This program is free software; you can redistribute it and/or modify      #
# it under the terms of the GNU General Public License as published by      #
# the Free Software Foundation; either version 2 of the License, or         #
# (at your option) any later version.                                       #
#                                                                           #
# This program is distributed in the hope that it will be useful,           #
# but WITHOUT ANY WARRANTY; without even the implied warranty of            #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             #
# GNU General Public License (http://www.gnu.org/licenses/gpl.txt)          #
# for more details.                                                         #
#                                                                           #
#############################################################################

option(MESHLAB_ALLOW_DOWNLOAD_SOURCE_LIB3MF "Allow download and use of lib3MF source" ON)

if(MESHLAB_ALLOW_DOWNLOAD_SOURCE_LIB3MF)
  set(LIB3MF_DIR ${MESHLAB_EXTERNAL_DOWNLOAD_DIR}/lib3mf-2.2.0)
  set(LIB3MF_CHECK ${LIB3MF_DIR}/CMakeLists.txt) 

  if(NOT EXISTS ${LIB3MF_CHECK})
    set(LIB3MF_LINK https://github.com/3MFConsortium/lib3mf/archive/refs/tags/v2.2.0.zip)
    set(LIB3MF_MD5 31c6dd3e2599f6f32c0784d8f46480bb)
    download_and_unzip(
      NAME "Lib3MF"
      MD5  ${LIB3MF_MD5}
      LINK ${LIB3MF_LINK}
      DIR  ${MESHLAB_EXTERNAL_DOWNLOAD_DIR})
    if(NOT download_and_unzip_SUCCESS)
      message(STATUS "- Lib3MF - download failed")
    endif()
  endif()

  if(EXISTS ${LIB3MF_CHECK})
    message(STATUS "- Lib3MF - Using downloaded Lib3MF sources")
    set(MESSAGE_QUIET ON)
    set(LIB3MF_TESTS OFF)
    add_subdirectory(${LIB3MF_DIR} EXCLUDE_FROM_ALL)

    # Well, this is extremely ugly
    # But due to some bug in lib3mf CMake function `generate_product_version`,
    # it is not possible to build lib3mf with ninja on Windows, because the following
    # error message will appear when processing VersionResource.rc
    #
    # fatal error RC1106: invalid option: -3
    #
    # I don't know what causes the bug. A workaround is to just simply exclude VersionResource.rc from the list
    # of sources associated to the lib3mf target.
    if( WIN32 AND CMAKE_GENERATOR STREQUAL "Ninja" )
      get_target_property(LIB3MF_SRCS lib3mf SOURCES)
      LIST(FILTER LIB3MF_SRCS EXCLUDE REGEX "VersionResource.rc")
      SET_TARGET_PROPERTIES(lib3mf PROPERTIES SOURCES "${LIB3MF_SRCS}")
    endif()
    unset(MESSAGE_QUIET)
  else()
    message(FATAL " - Lib3MF - Could not add lib3mf to source tree ")
  endif()

  add_library(external-lib3mf INTERFACE)
  target_link_libraries(external-lib3mf INTERFACE lib3mf)
  target_include_directories(external-lib3mf INTERFACE ${LIB3MF_DIR}/Autogenerated/Bindings/Cpp)
  install(TARGETS lib3mf DESTINATION ${MESHLAB_LIB_INSTALL_DIR})

endif()
