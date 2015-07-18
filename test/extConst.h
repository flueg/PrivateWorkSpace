#ifndef __EXT_CONST_H_
#define __EXT_CONST_H_

#include <string>

#ifndef CONST_STRING
#define CONST_STRING(name, value) extern const std::string name
#endif

CONST_STRING(FLUEG, "FluegLau");
#endif
