# - Find SECDA_TOOLS
# Find the native SECDA_TOOLS includes and library
#
# SECDA_TOOLS_INCLUDES    - where to find SECDA_TOOLS includes
# SECDA_TOOLS_LIBRARIES   - List of libraries when using SECDA_TOOLS.
# SECDA_TOOLS_FOUND       - True if SECDA_TOOLS found.

# message
message(STATUS "=====SECDA_TOOLS=====")

if(SECDA_TOOLS_INCLUDES)
  # Already in cache, be silent
  set(SECDA_TOOLS_FIND_QUIETLY TRUE)
endif(SECDA_TOOLS_INCLUDES)

set(SECDA_TOOLS_SEARCH_ROOTS "")

if (DEFINED SECDA_LLM_SECDA_TOOLS_DIR)
  list(APPEND SECDA_TOOLS_SEARCH_ROOTS "${SECDA_LLM_SECDA_TOOLS_DIR}")
endif()

if (DEFINED SECDA_TOOLS_HOME)
  list(APPEND SECDA_TOOLS_SEARCH_ROOTS "${SECDA_TOOLS_HOME}")
endif()

if (DEFINED ENV{SECDA_TOOLS_HOME})
  list(APPEND SECDA_TOOLS_SEARCH_ROOTS "$ENV{SECDA_TOOLS_HOME}")
endif()

list(REMOVE_DUPLICATES SECDA_TOOLS_SEARCH_ROOTS)
message(STATUS "Looking for SECDA_TOOLS in: ${SECDA_TOOLS_SEARCH_ROOTS}")

find_path(
  SECDA_TOOLS_INCLUDES
  NAMES secda_toolsv5.h
  PATHS ${SECDA_TOOLS_SEARCH_ROOTS}
)
message(STATUS "SECDA_TOOLS_INCLUDES: ${SECDA_TOOLS_INCLUDES}")

# if(BUILD_ARM)
if(BUILD_KRIA)
  find_library(
    SECDA_TOOLS_LIBRARIES
    NAMES secda_tools_kria
    PATHS ${SECDA_TOOLS_SEARCH_ROOTS}
    PATH_SUFFIXES build out/build secda_tools build/secda_tools out/build/secda_tools
  )
  message(STATUS "SECDA_TOOLS_LIBRARIES: ${SECDA_TOOLS_LIBRARIES}")
else()
  find_library(
    SECDA_TOOLS_LIBRARIES
    NAMES secda_tools
    PATHS ${SECDA_TOOLS_SEARCH_ROOTS}
    PATH_SUFFIXES build out/build secda_tools build/secda_tools out/build/secda_tools
  )
endif()
# endif()
find_library(
  SECDA_TOOLS_SIM_LIBRARIES
  NAMES secda_tools_sim
  PATHS ${SECDA_TOOLS_SEARCH_ROOTS}
  PATH_SUFFIXES build out/build secda_tools build/secda_tools out/build/secda_tools
)

# add_definitions(-DACC_PROFILE -DDMA_PROFILE)
# add_definitions(-DDMA_PROFILE -DDEF_UDMA -DDMA_PRINT)


# add_definitions(-DACC_PROFILE -DDISABLE_SIM)
# add_definitions(-DACC_PROFILE -DDISABLE_DMA)
if(BUILD_ARM)
  if (SECDA_TOOLS_INCLUDES)
    set(SECDA_TOOLS_AXI_SUPPORT_DIR "${SECDA_TOOLS_INCLUDES}/secda_tools/axi_support")
  endif()

  if(BUILD_KRIA)
    set(CMAKE_SYSTEM_PROCESSOR aarch64)
    find_library(CMALIB NAMES libcma.so PATHS "${SECDA_TOOLS_AXI_SUPPORT_DIR}/arch64")
    message(STATUS "libcma: ${CMALIB}")
  else()
    set(CMAKE_SYSTEM_PROCESSOR armv7)
    find_library(CMALIB NAMES libcma.so PATHS "${SECDA_TOOLS_AXI_SUPPORT_DIR}/arm32")
  endif()
  set(GGML_LLAMAFILE ON)
endif()

# handle the QUIETLY and REQUIRED arguments and set SECDA_TOOLS_FOUND to TRUE if
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SECDA_TOOLS DEFAULT_MSG SECDA_TOOLS_LIBRARIES SECDA_TOOLS_SIM_LIBRARIES SECDA_TOOLS_INCLUDES)


mark_as_advanced(SECDA_TOOLS_LIBRARIES SECDA_TOOLS_SIM_LIBRARIES SECDA_TOOLS_INCLUDES)
message(STATUS "Found SECDA_TOOLS: ${SECDA_TOOLS_LIBRARIES}")
message(STATUS "Found SECDA_TOOLS_SIM: ${SECDA_TOOLS_SIM_LIBRARIES}")
message(STATUS "Found CMALIB: ${CMALIB}")
message(STATUS "=====SECDA_TOOLS=====")

