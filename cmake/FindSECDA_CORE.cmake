# - Find SECDA_CORE
# Find the SECDA-Core includes and libraries.
#
# This is the fallback for building ggml-secda against a SECDA-Core that was
# built out of tree. When SECDA-LLM's wrapper build add_subdirectory()s the
# third_party/secda_core submodule, the secda_core* targets already exist and
# ggml-secda uses those directly without ever calling this module.
#
# SECDA_CORE_INCLUDES        - the SECDA-Core repo root (headers are secda-core/...)
# SECDA_CORE_LIBRARIES       - hardware library for the selected target
# SECDA_CORE_SIM_LIBRARIES   - SystemC simulation library (host builds)
# SECDA_CORE_FOUND           - True if SECDA-Core was found.

message(STATUS "=====SECDA_CORE=====")

if(SECDA_CORE_INCLUDES)
  # Already in cache, be silent
  set(SECDA_CORE_FIND_QUIETLY TRUE)
endif(SECDA_CORE_INCLUDES)

set(SECDA_CORE_SEARCH_ROOTS "")

if (DEFINED SECDA_LLM_SECDA_CORE_DIR)
  list(APPEND SECDA_CORE_SEARCH_ROOTS "${SECDA_LLM_SECDA_CORE_DIR}")
endif()

if (DEFINED SECDA_CORE_HOME)
  list(APPEND SECDA_CORE_SEARCH_ROOTS "${SECDA_CORE_HOME}")
endif()

if (DEFINED ENV{SECDA_CORE_HOME})
  list(APPEND SECDA_CORE_SEARCH_ROOTS "$ENV{SECDA_CORE_HOME}")
endif()

list(REMOVE_DUPLICATES SECDA_CORE_SEARCH_ROOTS)
message(STATUS "Looking for SECDA_CORE in: ${SECDA_CORE_SEARCH_ROOTS}")

find_path(
  SECDA_CORE_INCLUDES
  NAMES secda_corev5.h
  PATHS ${SECDA_CORE_SEARCH_ROOTS}
)
message(STATUS "SECDA_CORE_INCLUDES: ${SECDA_CORE_INCLUDES}")

# SECDA-Core's own CMake layout puts build trees at build/host, build/pynq and
# build/kria, with the libraries under <build>/secda-core/.
set(SECDA_CORE_LIB_SUFFIXES
  build/host/secda-core build/pynq/secda-core build/kria/secda-core
  build/secda-core out/build/secda-core build out/build)

if(BUILD_KRIA)
  find_library(
    SECDA_CORE_LIBRARIES
    NAMES secda_core_kria
    PATHS ${SECDA_CORE_SEARCH_ROOTS}
    PATH_SUFFIXES ${SECDA_CORE_LIB_SUFFIXES}
  )
else()
  find_library(
    SECDA_CORE_LIBRARIES
    NAMES secda_core
    PATHS ${SECDA_CORE_SEARCH_ROOTS}
    PATH_SUFFIXES ${SECDA_CORE_LIB_SUFFIXES}
  )
endif()
find_library(
  SECDA_CORE_SIM_LIBRARIES
  NAMES secda_core_simv5
  PATHS ${SECDA_CORE_SEARCH_ROOTS}
  PATH_SUFFIXES ${SECDA_CORE_LIB_SUFFIXES}
)

# SECDA-Core v5 allocates DMA buffers through u-dma-buf (DEF_BUF/USE_BUF); the
# libcma.so lookup that secda_tools needed is gone with the CMA path.
if(BUILD_ARM)
  if(BUILD_KRIA)
    set(CMAKE_SYSTEM_PROCESSOR aarch64)
  else()
    set(CMAKE_SYSTEM_PROCESSOR armv7)
  endif()
  set(GGML_LLAMAFILE ON)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SECDA_CORE DEFAULT_MSG SECDA_CORE_LIBRARIES SECDA_CORE_SIM_LIBRARIES SECDA_CORE_INCLUDES)

mark_as_advanced(SECDA_CORE_LIBRARIES SECDA_CORE_SIM_LIBRARIES SECDA_CORE_INCLUDES)
message(STATUS "Found SECDA_CORE: ${SECDA_CORE_LIBRARIES}")
message(STATUS "Found SECDA_CORE_SIM: ${SECDA_CORE_SIM_LIBRARIES}")
message(STATUS "=====SECDA_CORE=====")
