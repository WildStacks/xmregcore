#------------------------------------------------------------------------------
# CMake helper for the majority of the cpp-ethereum modules.
#
# This module defines
#     Wildstacks_XXX_LIBRARIES, the libraries needed to use ethereum.
#     Wildstacks_FOUND, If false, do not try to use ethereum.
#
# File addetped from cpp-ethereum
#
# The documentation for cpp-ethereum is hosted at http://cpp-ethereum.org
#
# ------------------------------------------------------------------------------
# This file is part of cpp-ethereum.
#
# cpp-ethereum is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# cpp-ethereum is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with cpp-ethereum.  If not, see <http://www.gnu.org/licenses/>
#
# (c) 2014-2016 cpp-ethereum contributors.
#------------------------------------------------------------------------------


if (NOT WILDSTACKS_DIR)
    set(WILDSTACKS_DIR ~/wildstacks)
endif()

message(STATUS WILDSTACKS_DIR ": ${WILDSTACKS_DIR}")

set(WILDSTACKS_SOURCE_DIR ${WILDSTACKS_DIR}
        CACHE PATH "Path to the root directory for WildStacks")

# set location of wildstacks build tree
set(WILDSTACKS_BUILD_DIR ${WILDSTACKS_SOURCE_DIR}/build/release/
        CACHE PATH "Path to the build directory for WildStacks")


if (NOT EXISTS ${WILDSTACKS_BUILD_DIR})
    # try different location
    message(STATUS "Trying different folder for wildstacks libraries")
    set(WILDSTACKS_BUILD_DIR ${WILDSTACKS_SOURCE_DIR}/build/Linux/master/release/
        CACHE PATH "Path to the build directory for WildStacks" FORCE)
endif()


if (NOT EXISTS ${WILDSTACKS_BUILD_DIR})   
  message(FATAL_ERROR "WildStacks libraries not found in: ${WILDSTACKS_BUILD_DIR}")
endif()

MESSAGE(STATUS "Looking for libunbound") # FindUnbound.cmake from wildstacks repo


set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} "${WILDSTACKS_BUILD_DIR}"
        CACHE PATH "Add WildStacks directory for library searching")


set(LIBS  cryptonote_core
          blockchain_db
          #cryptonote_protocol
          cryptonote_basic
          #daemonizer
          blocks
          lmdb
          wallet-crypto
          ringct
          ringct_basic
          common
          #mnemonics
          easylogging
          device
          epee
          checkpoints
          version
          cncrypto
          randomx
          hardforks
          miniupnpc)

set(Xmr_INCLUDE_DIRS "${CPP_WILDSTACKS_DIR}")

# if the project is a subset of main cpp-ethereum project
# use same pattern for variables as Boost uses

set(Wildstacks_LIBRARIES "")

foreach (l ${LIBS})

	string(TOUPPER ${l} L)

	find_library(Xmr_${L}_LIBRARY
			NAMES ${l}
			PATHS ${CMAKE_LIBRARY_PATH}
                        PATH_SUFFIXES "/src/${l}"
                                      "/src/"
                                      "/external/db_drivers/lib${l}"
                                      "/lib"
                                      "/src/crypto"
                                      "/src/crypto/wallet"
                                      "/contrib/epee/src"
                                      "/external/easylogging++/"
                                      "/src/ringct/"
                                      "/external/${l}"
                                      "external/miniupnp/miniupnpc"
			NO_DEFAULT_PATH
			)

	set(Xmr_${L}_LIBRARIES ${Xmr_${L}_LIBRARY})

	message(STATUS FindWildstacks " Xmr_${L}_LIBRARIES ${Xmr_${L}_LIBRARY}")

    add_library(${l} STATIC IMPORTED)
	set_property(TARGET ${l} PROPERTY IMPORTED_LOCATION ${Xmr_${L}_LIBRARIES})

    set(Wildstacks_LIBRARIES ${Wildstacks_LIBRARIES} ${l} CACHE INTERNAL "WildStacks LIBRARIES")

endforeach()


FIND_PATH(UNBOUND_INCLUDE_DIR
  NAMES unbound.h
  PATH_SUFFIXES include/ include/unbound/
  PATHS "${PROJECT_SOURCE_DIR}"
  ${UNBOUND_ROOT}
  $ENV{UNBOUND_ROOT}
  /usr/local/
  /usr/
)

find_library (UNBOUND_LIBRARY unbound)
if (WIN32 OR (${UNBOUND_LIBRARY} STREQUAL "UNBOUND_LIBRARY-NOTFOUND"))
    add_library(unbound STATIC IMPORTED)
    set_property(TARGET unbound PROPERTY IMPORTED_LOCATION ${WILDSTACKS_BUILD_DIR}/external/unbound/libunbound.a)
endif()

message("Xmr_WALLET-CRYPTO_LIBRARIES ${Xmr_WALLET-CRYPTO_LIBRARIES}")

if("${Xmr_WALLET-CRYPTO_LIBRARIES}" STREQUAL "Xmr_WALLET-CRYPTO_LIBRARY-NOTFOUND")
  set(WALLET_CRYPTO "")
else()
  set(WALLET_CRYPTO ${Xmr_WALLET-CRYPTO_LIBRARIES})
endif()



message("WALLET_CRYPTO ${WALLET_CRYPTO}")



message("FOUND Wildstacks_LIBRARIES: ${Wildstacks_LIBRARIES}")

message(STATUS ${WILDSTACKS_SOURCE_DIR}/build)

#macro(target_include_wildstacks_directories target_name)

    #target_include_directories(${target_name}
        #PRIVATE
        #${WILDSTACKS_SOURCE_DIR}/src
        #${WILDSTACKS_SOURCE_DIR}/external
        #${WILDSTACKS_SOURCE_DIR}/build
        #${WILDSTACKS_SOURCE_DIR}/external/easylogging++
        #${WILDSTACKS_SOURCE_DIR}/contrib/epee/include
        #${WILDSTACKS_SOURCE_DIR}/external/db_drivers/liblmdb)

#endmacro(target_include_wildstacks_directories)


add_library(Wildstacks::Wildstacks INTERFACE IMPORTED GLOBAL)

# Requires to new cmake
#target_include_directories(Wildstacks::Wildstacks INTERFACE        
    #${WILDSTACKS_SOURCE_DIR}/src
    #${WILDSTACKS_SOURCE_DIR}/external
    #${WILDSTACKS_SOURCE_DIR}/build
    #${WILDSTACKS_SOURCE_DIR}/external/easylogging++
    #${WILDSTACKS_SOURCE_DIR}/contrib/epee/include
    #${WILDSTACKS_SOURCE_DIR}/external/db_drivers/liblmdb)

set_target_properties(Wildstacks::Wildstacks PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES 
            "${WILDSTACKS_SOURCE_DIR}/src;${WILDSTACKS_SOURCE_DIR}/external;${WILDSTACKS_SOURCE_DIR}/src/crypto;${WILDSTACKS_SOURCE_DIR}/src/crypto/wallet;${WILDSTACKS_SOURCE_DIR}/build;${WILDSTACKS_SOURCE_DIR}/external/easylogging++;${WILDSTACKS_SOURCE_DIR}/contrib/epee/include;${WILDSTACKS_SOURCE_DIR}/external/db_drivers/liblmdb;${WILDSTACKS_BUILD_DIR}/generated_include/crypto/wallet")


target_link_libraries(Wildstacks::Wildstacks INTERFACE
    ${Wildstacks_LIBRARIES} ${WALLET_CRYPTO})
