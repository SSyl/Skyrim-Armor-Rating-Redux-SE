#include "main.h"

static PluginHandle					g_pluginHandle = kPluginHandle_Invalid;
static SKSEPapyrusInterface         * g_papyrus = NULL;


///// Duplicating old ARR functionality here


// variables. cache here for easy access

const SInt32 LINEAR = 0;
const SInt32 HYPERBOLIC = 1;
const SInt32 EXPONENTIAL = 2;

SInt32 CurrentMode = HYPERBOLIC;

float (*convertDamageResist)(float) = &convertDamageResistToHyperbolic;

float LinearMult = 1.0;
float LinearCeil = 0.8000;
float HyperDenomShift = 0.2;
float ExpBase = 0.1337;

bool UseCeilExpHyp = false;
bool UseMultExpHyp = false;

float CeilExpHyp = 1.0;
float MultExpHyp = 1.00;

const float kVanillaArmorScalingFactor = 0.0012;

// float setter functions
void setLinearMult(StaticFunctionTag *base, float arg) {
	_MESSAGE("Called %s with value %f.", "setLinearMult", arg);
	LinearMult = arg / kVanillaArmorScalingFactor;
}

void setLinearFloor(StaticFunctionTag *base, float arg) {
	_MESSAGE("Called %s with value %f.", "setLinearFloor", arg);
	LinearCeil = 1.0 - arg;
}

void setLinearCeil(StaticFunctionTag *base, float arg) {
	_MESSAGE("Called %s with value %f.", "setLinearCeil", arg);
	LinearCeil = arg;
}

void setHyperDiv(StaticFunctionTag *base, float arg) {
	_MESSAGE("Called %s with value %f.", "setHyperDiv", arg);
	HyperDenomShift = kVanillaArmorScalingFactor / arg;
}

/*
void setHyperSurviveSlope(StaticFunctionTag *base, float arg) {
	_MESSAGE("Called %s with value %f.", "setHyperSurviveSlope", arg);
	HyperDenomShift = kVanillaArmorScalingFactor / arg;
}
*/

void setExpBase(StaticFunctionTag *base, float arg) {
	_MESSAGE("Called %s with value %f.", "setExpBase", arg);
	ExpBase = pow(arg, 1/kVanillaArmorScalingFactor);
}

void setFloorExpHyp(StaticFunctionTag *base, float arg) {
	_MESSAGE("Called %s with value %f.", "setFloorExpHyp", arg);
	CeilExpHyp = 1.0 - arg;
}

/*
void setCeilExpHyp(StaticFunctionTag *base, float arg) {
	_MESSAGE("Called %s with value %f.", "setCeilExpHyp", arg);
	CeilExpHyp = arg;
}
*/

void setMultExpHyp(StaticFunctionTag *base, float arg) {
	_MESSAGE("Called %s with value %f.", "setMultExpHyp", arg);
	MultExpHyp = arg;
}


// bool setter functions

void setUseFloorExpHyp(StaticFunctionTag *base, bool arg) {
	_MESSAGE("Called %s with value %s.", "setUseFloorExpHyp", arg ? "true" : "false");
	UseCeilExpHyp = arg;
}

/*
void setUseCeilExpHyp(StaticFunctionTag *base, bool arg) {
	_MESSAGE("Called %s with value %s.", "setUseCeilExpHyp", arg ? "true" : "false");
	UseCeilExpHyp = arg;
}
*/

void setUseMultExpHyp(StaticFunctionTag *base, bool arg) {
	_MESSAGE("Called %s with value %s.", "setUseMultExpHyp", arg ? "true" : "false");
	UseMultExpHyp = arg;
}

// int setter functions
void setMode(StaticFunctionTag *base, SInt32 arg) {
	_MESSAGE("Called %s with value %s.", "setMode",
		arg == LINEAR ? "linear" :
		arg == HYPERBOLIC ? "hyperbolic" :
		arg == EXPONENTIAL ? "exponential" :
			"UNKNOWN"
	);
	switch (arg) {
		case LINEAR: {
			convertDamageResist = convertDamageResistToLinear;
			break;
		}
		case HYPERBOLIC: {
			convertDamageResist = convertDamageResistToHyperbolic;
			break;
		}
		case EXPONENTIAL: {
			convertDamageResist = convertDamageResistToExponential;
			break;
		}
	}
}

float convertDamageResistToHyperbolic(float vanillaResist) {
	float newResist = vanillaResist > 0 ? vanillaResist / (vanillaResist + HyperDenomShift) : vanillaResist / HyperDenomShift;
	if (UseMultExpHyp) {
		newResist *= MultExpHyp;
	}
	if (UseCeilExpHyp && newResist > CeilExpHyp) {
		newResist = CeilExpHyp;
	}
#ifdef _DEBUG
	_DMESSAGE("Converting from vanilla resist of %f to hyperbolic resist of %f.", vanillaResist, newResist);
#endif
	return newResist;
}

float convertDamageResistToExponential(float vanillaResist) {
	float newResist = 1.0 - pow(ExpBase, vanillaResist);
	if (UseMultExpHyp) {
		newResist *= MultExpHyp;
	}
	if (UseCeilExpHyp && newResist > CeilExpHyp) {
		newResist = CeilExpHyp;
	}
#ifdef _DEBUG
	_DMESSAGE("Converting from vanilla resist of %f to exponential resist of %f.", vanillaResist, newResist);
#endif
	return newResist;
}

float convertDamageResistToLinear(float vanillaResist) {
	float newResist = vanillaResist * LinearMult;
	if (newResist > LinearCeil) {
		newResist = LinearCeil;
	}
#ifdef _DEBUG
	_DMESSAGE("Converting from vanilla resist of %f to linear resist of %f.", vanillaResist, newResist);
#endif
	return newResist;
}

// function registry handling
bool RegisterFuncs(VMClassRegistry* registry) {
	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, void, float>("setLinearMult", "J42_ARR_SKSE_Bridge", setLinearMult, registry));
	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, void, float>("setLinearFloor", "J42_ARR_SKSE_Bridge", setLinearFloor, registry));
	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, void, float>("setHyperDiv", "J42_ARR_SKSE_Bridge", setHyperDiv, registry));
	//registry->RegisterFunction(
	//	new NativeFunction1<StaticFunctionTag, void, float>("setHyperSurviveSlope", "J42_ARR_SKSE_Bridge", setHyperSurviveSlope, registry));
	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, void, float>("setExpBase", "J42_ARR_SKSE_Bridge", setExpBase, registry));
	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, void, float>("setFloorExpHyp", "J42_ARR_SKSE_Bridge", setFloorExpHyp, registry));
	//registry->RegisterFunction(
	//	new NativeFunction1<StaticFunctionTag, void, float>("setCeilExpHyp", "J42_ARR_SKSE_Bridge", setCeilExpHyp, registry));
	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, void, float>("setMultExpHyp", "J42_ARR_SKSE_Bridge", setMultExpHyp, registry));
	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, void, bool>("setUseFloorExpHyp", "J42_ARR_SKSE_Bridge", setUseFloorExpHyp, registry));
	//registry->RegisterFunction(
	//	new NativeFunction1<StaticFunctionTag, void, bool>("setUseCeilExpHyp", "J42_ARR_SKSE_Bridge", setUseCeilExpHyp, registry));
	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, void, bool>("setUseMultExpHyp", "J42_ARR_SKSE_Bridge", setUseMultExpHyp, registry));
	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, void, SInt32>("setMode", "J42_ARR_SKSE_Bridge", setMode, registry));

	return true;
}

// code injection handling
//const RelocAddr<uintptr_t>  kDamageResistInject1Address(0x00743ac7);
//const RelocAddr<uintptr_t>  kDamageResistInject1Address(0x00743807);
const RelocAddr<uintptr_t>  kDamageResistInject1Address(0x00743617);
const UInt8 kDamageResistInject1Bytes[] = {
	0xf3, 0x0f, 0x10, 0x4d, 0x77, 0xf3, 0x0f, 0x58, 0xc8, 0xf3, 0x0f, 0x11, 0x4d, 0x77
};
const size_t kDamageResist1NeededBytes = 34;


//const RelocAddr<uintptr_t> kDamageResistInject2Address(0x00625452);
//const UInt8 kDamageResistInject2Bytes[] = {
//	0xf3, 0x0f, 0x10, 0x0d, 0xc2, 0x6b, 0xf3, 0x00, 0xf3, 0x44, 0x0f, 0x58,
//	0xc0, 0x44, 0x0f, 0x2f, 0xc1, 0x72, 0x04, 0x44, 0x0f, 0x28, 0xc1
//};
/*
const RelocAddr<uintptr_t> kDamageResistInject2Address(0x00625192);
const UInt8 kDamageResistInject2Bytes[] = {
	0xf3, 0x0f, 0x10, 0x0d, 0x92, 0x6e, 0xf3, 0x00, 0xf3, 0x44, 0x0f, 0x58,
	0xc0, 0x44, 0x0f, 0x2f, 0xc1, 0x72, 0x04, 0x44, 0x0f, 0x28, 0xc1
};
*/
/* Version 1.5.80
const RelocAddr<uintptr_t> kDamageResistInject2Address(0x00624FA2);
const UInt8 kDamageResistInject2Bytes[] = {
	0xf3, 0x0f, 0x10, 0x0d, 0x32, 0xd0, 0xf1, 0x00, 0xf3, 0x44, 0x0f, 0x58,
	0xc0, 0x44, 0x0f, 0x2f, 0xc1, 0x72, 0x04, 0x44, 0x0f, 0x28, 0xc1
};
*/
const RelocAddr<uintptr_t> kDamageResistInject2Address(0x00624FA2);
const UInt8 kDamageResistInject2Bytes[] = {
	0xf3, 0x0f, 0x10, 0x0d, 0x22, 0xd0, 0xf1, 0x00, 0xf3, 0x44, 0x0f, 0x58,
	0xc0, 0x44, 0x0f, 0x2f, 0xc1, 0x72, 0x04, 0x44, 0x0f, 0x28, 0xc1
};

const UInt8 kAsm8Nop = 0x90;
const UInt16 kAsm16Nop = 0x9090;
const UInt32 kAsm32Nop = 0x90909090;
const UInt64 kAsm64Nop = 0x9090909090909090;

const size_t kNumBranchTrampolines = 0;
const size_t kSizeOfTrampolineCode = 14;
const size_t kSizeOfCodeGen = kDamageResist1NeededBytes;

// following code from https://stackoverflow.com/questions/1065774/initialization-of-a-normal-array-with-one-default-value
// we use it to initialize arrays with Nops
template<std::size_t size, typename T, std::size_t... indexes>
constexpr std::array<std::decay_t<T>, size> make_array_impl(T && value, std::index_sequence<indexes...>) {
	return std::array<std::decay_t<T>, size>{ (static_cast<void>(indexes), value)..., std::forward<T>(value) };
}

template<typename T>
constexpr std::array<std::decay_t<T>, 0> make_array(std::integral_constant<std::size_t, 0>, T &&) {
	return std::array<std::decay_t<T>, 0>{};
}

template<std::size_t size, typename T>
constexpr std::array<std::decay_t<T>, size> make_array(std::integral_constant<std::size_t, size>, T && value) {
	return make_array_impl<size>(std::forward<T>(value), std::make_index_sequence<size - 1>{});
}

template<std::size_t size, typename T>
constexpr std::array<std::decay_t<T>, size> make_array(T && value) {
	return make_array(std::integral_constant<std::size_t, size>{}, std::forward<T>(value));
}


#pragma pack(push, 1)
struct LongJump {
	UInt8 mov_prefix;    // 0x48 -- 64 bit instruction
	UInt8 mov_opcode;    // 0xb8 -- mov rax,
	UInt64 dst;
	UInt8 jmp_opcode;    // 0xff
	UInt8 jmp_fieldmode; // 0xe0 -- 64 bit mode + use register rax

	LongJump(uintptr_t _dst): mov_prefix(0x48), mov_opcode(0xb8), dst(_dst), jmp_opcode(0xff), jmp_fieldmode(0xe0) {}
};
#pragma pack(pop)

void WriteLongJump(uintptr_t src, uintptr_t dst)
{
	STATIC_ASSERT(sizeof(uintptr_t) == sizeof(UInt64));


	LongJump jumpCode(dst);

	SafeWriteBuf(src, &jumpCode, sizeof(jumpCode));
}

void Hooks_FixDamageResist_Commit() {
	{
		struct DamageResistInjection1 : Xbyak::CodeGenerator {
			DamageResistInjection1(void * buf) : Xbyak::CodeGenerator(kDamageResist1NeededBytes, buf)
			{
				// xmm0: hiddenResist
				// rbp+0x77: vanillaResist

				// setup call to our function
				movss(xmm0, ptr[rbp + 0x77]);
				mov(rax, ptr[(uintptr_t)&convertDamageResist]);
				call(rax);

				// store the resulting resist
				movss(ptr[rbp + 0x77], xmm0);
				
				// return to original code
				mov(rax, kDamageResistInject1Address.GetUIntPtr() + sizeof(kDamageResistInject1Bytes));
				jmp(rax);
			}
		};

		void * codeBuf = g_localTrampoline.StartAlloc();
		DamageResistInjection1 code(codeBuf);
		g_localTrampoline.EndAlloc(code.getCurr());
		
		// overwrite the three instructions:
		// movss xmm1, ptr [rbp+0x77]
		// addss xmm1, xmm0
		// movss ptr [rbp+0x77], xmm1
		WriteLongJump(kDamageResistInject1Address.GetUIntPtr(), uintptr_t(code.getCode()));
		SafeWrite16(kDamageResistInject1Address.GetUIntPtr() + sizeof(LongJump), kAsm16Nop);
		STATIC_ASSERT(sizeof(kDamageResistInject1Bytes) == sizeof(LongJump) + sizeof(UInt16));
	}

	{
		struct DamageResistInjection2 : Xbyak::CodeGenerator {
			DamageResistInjection2(void * buf) : Xbyak::CodeGenerator(sizeof(kDamageResistInject2Bytes), buf)
			{
				// xmm0: hiddenResist
				// xmm8: vanillaResist

				// setup call to our function
				movss(xmm0, xmm8);
				mov(rax, ptr[(uintptr_t)&convertDamageResist]);
				call(rax);

				// store the resulting resist
				movss(xmm8, xmm0);
			}
		};

		std::array<UInt8, sizeof(kDamageResistInject2Bytes)> codeBuf = make_array<sizeof(kDamageResistInject2Bytes)>(kAsm8Nop);
		DamageResistInjection2 code(&codeBuf.front());

		// overwrite the five instructions:
		// movss xmm1, ptr [...]    ;address is that of max damage resist
		// addss xmm8, xmm0
		// comiss xmm8, xmm0
		// jb 0x04                  ;short jb past the next instruction
		// movaps xmm8, xmm1
		SafeWriteBuf(kDamageResistInject2Address.GetUIntPtr(), &codeBuf.front(), sizeof(kDamageResistInject2Bytes));
	}
}

template <typename T>
bool TestMemoryData(uintptr_t address, T expectedValue) {
	T memoryValue = *reinterpret_cast<T *>(address);
	if (memoryValue == expectedValue) {
		return true;
	}
	_MESSAGE("Unexpected memory value at %016I64X: 0x%02x, expected: 0x%02x", address, memoryValue, expectedValue);
	return false;
};

bool IsBinaryCompatible() {
	bool ok = true;
	uintptr_t address = kDamageResistInject1Address.GetUIntPtr();
	for (const UInt8 entry : kDamageResistInject1Bytes) {
		ok &= TestMemoryData(address, entry);
		address += 1;
	}
	address = kDamageResistInject2Address.GetUIntPtr();
	for (const UInt8 entry : kDamageResistInject2Bytes) {
		ok &= TestMemoryData(address, entry);
		address += 1;
	}
	return ok;
}


/// Standard SKSE Stuff

extern "C"	{

	bool SKSEPlugin_Query(const SKSEInterface * skse, PluginInfo * info)	{	// Called by SKSE to learn about this plugin and check that it's safe to load it
		gLog.OpenRelative(CSIDL_MYDOCUMENTS, "\\My Games\\Skyrim Special Edition\\SKSE\\J42_ARR_plugin.log");

		_MESSAGE("J42_ARR_plugin");
		_MESSAGE("Base Address is: %016I64X", RelocationManager::s_baseAddr);
		// populate info structure
		info->infoVersion =	PluginInfo::kInfoVersion;
		info->name =		"J42_ARR_plugin";
		info->version =		20008;

		// store plugin handle so we can identify ourselves later
		g_pluginHandle = skse->GetPluginHandle();

		if(skse->isEditor)
		{
			_MESSAGE("Loaded in editor, marking as incompatible.");

			return false;
		}
		//else if(skse->runtimeVersion != RUNTIME_VERSION_1_5_39)
		//else if (skse->runtimeVersion != RUNTIME_VERSION_1_5_50)
		//else if (skse->runtimeVersion != RUNTIME_VERSION_1_5_53)
		//else if (skse->runtimeVersion != RUNTIME_VERSION_1_5_62)
		//else if (skse->runtimeVersion != RUNTIME_VERSION_1_5_73)
		//else if (skse->runtimeVersion != RUNTIME_VERSION_1_5_80)
		else if (skse->runtimeVersion != RUNTIME_VERSION_1_5_97)
		{
			_ERROR("Unsupported runtime version %08X.", skse->runtimeVersion);

			return false;
		}

		// ### do not do anything else in this callback
		// ### only fill out PluginInfo and return true/false

		// supported runtime version
		return true;
	}

	bool SKSEPlugin_Load(const SKSEInterface * skse)	{	// Called by SKSE to load this plugin
		if (!IsBinaryCompatible()) {
			_ERROR("Incompatible SKSE plugin loaded. Skipping remainder of init process.");

			return false;
		}

		if (kNumBranchTrampolines > 0) {
			if (!g_branchTrampoline.Create(kSizeOfTrampolineCode * kNumBranchTrampolines))
			{
				_ERROR("Couldn't create branch trampoline. This is fatal. Skipping remainder of init process.");
				return false;
			}
		}

		if (kSizeOfCodeGen > 0) {
			if (!g_localTrampoline.Create(kSizeOfCodeGen, nullptr))
			{
				_ERROR("Couldn't create codegen buffer. This is fatal. Skipping remainder of init process.");
				return false;
			}
		}

		_MESSAGE("Preparing injection.");

		Hooks_FixDamageResist_Commit();

		_MESSAGE("Injection completed.");

		// Do Papyrus stuff
		g_papyrus = (SKSEPapyrusInterface *)skse->QueryInterface(kInterface_Papyrus);

		// Check if the function registration was a success...
		bool btest = g_papyrus->Register(RegisterFuncs);

		if (btest) {
			_MESSAGE("Papyrus registration complete.");
		}

		return true;
	}

};