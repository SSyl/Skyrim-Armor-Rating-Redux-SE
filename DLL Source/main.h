#include "skse64/PluginAPI.h"               // super
#include "skse64/PapyrusNativeFunctions.h"  // for exporting to Papyrus
#include "skse64_common/skse_version.h"     // What version of SKSE is running?
#include "skse64_common/Relocation.h"
#include "skse64_common/SafeWrite.h"        // for binary injections
#include "skse64_common/BranchTrampoline.h"
#include "xbyak/xbyak.h"                    // for CodeGenerator
#include <shlobj.h>                         // CSIDL_MYCODUMENTS
#include <array>

// float setter functions
void setLinearMult(StaticFunctionTag *base, float arg);
void setLinearFloor(StaticFunctionTag *base, float arg);
void setHyperDiv(StaticFunctionTag *base, float arg);
//void setHyperSurviveSlope(StaticFunctionTag *base, float arg);
void setExpBase(StaticFunctionTag *base, float arg);
void setFloorExpHyp(StaticFunctionTag *base, float arg);
//void setCeilExpHyp(StaticFunctionTag *base, float arg);
void setMultExpHyp(StaticFunctionTag *base, float arg);

// bool setter functions
void setUseFloorExpHyp(StaticFunctionTag *base, bool arg);
//void setUseCeilExpHyp(StaticFunctionTag *base, bool arg);
void setUseMultExpHyp(StaticFunctionTag *base, bool arg);

// int setter functions
void setMode(StaticFunctionTag *base, SInt32 arg);

// function registry handling
bool RegisterFuncs(VMClassRegistry* registry);

// conversion functions
float convertDamageResistToHyperbolic(float vanillaResist);
float convertDamageResistToExponential(float vanillaResist);
float convertDamageResistToLinear(float vanillaResist);

//float calcDamageTaken(float armorRating);

//float RescaleArmor(float vanillaResist);

template <typename T>
bool TestMemoryData(uintptr_t adress, T expectedValue);

bool IsBinaryCompatible();