#define NS(A) default_##A

#define font NS(font)
#define colorname NS(colorname)
#define defaultbg NS(defaultbg)
#define defaultfg NS(defaultfg)
#define defaultcs NS(defaultcs)
#define defaultrcs NS(defaultrcs)

#include "config.def.h"

#undef font 
#undef colorname
#undef defaultbg
#undef defaultfg
#undef defaultcs
#undef defaultrcs 

static char *font = "@font@";

static const char *colorname[] = {
    "@black@",
    "@red@",
    "@green@",
    "@yellow@",
    "@blue@",
    "@purple@",
    "@cyan@",
    "@white@",

    "@blackBr@",
    "@redBr@",
    "@greenBr@",
    "@yellowBr@",
    "@blueBr@",
    "@purpleBr@",
    "@cyanBr@",
    "@whiteBr@",

    [255] = 0,

    "@foreground@",
    "@background@",
};

unsigned int defaultfg = 256;
unsigned int defaultbg = 257;

static unsigned int defaultcs = 15;
static unsigned int defaultrcs = 8;

