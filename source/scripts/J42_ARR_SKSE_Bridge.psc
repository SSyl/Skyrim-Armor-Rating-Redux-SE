Scriptname J42_ARR_SKSE_Bridge

;calling any of these without argument resets to default values

Function setMode(int aInt = 1) Global Native
{	0 := linear
	1 := hyperbolic
	2 := exponential}

Function setLinearMult(float aFloat = 0.0012) Global Native
Function setLinearFloor(float aFloat = 0.2000) Global Native
Function setHyperDiv(float aFloat = 0.0060) Global Native
Function setExpBase(float aFloat = 0.9976) Global Native

Function setUseFloorExpHyp(bool aBool = false) Global Native
Function setUseMultExpHyp(bool aBool = false) Global Native

Function setFloorExpHyp(float aFloat = 0.00) Global Native
Function setMultExpHyp(float aFloat = 1.00) Global Native
