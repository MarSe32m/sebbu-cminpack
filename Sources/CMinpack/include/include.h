#ifndef SEBBU_CMINPACK_UMBRELLA_H
#define SEBBU_CMINPACK_UMBRELLA_H

#if defined(_WIN32)
#  ifndef CMINPACK_NO_DLL
#    define CMINPACK_NO_DLL 1
#  endif
#endif

#include "cminpack.h"

#endif