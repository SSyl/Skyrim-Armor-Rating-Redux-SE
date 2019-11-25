Scriptname J42_ARR_QuestScript extends Quest  


Spell Property J42_ARR_ARDisplaySpell Auto
MagicEffect Property J42_ARR_ARDisplayEffect Auto
Message Property J42_ARR_ErrorBox Auto
Actor Property PlayerRef Auto

bool Property Debugging  = false Auto Hidden
bool Property Notify  = false Auto Hidden
bool Property UseSpell = false Auto Hidden

int Mode_var = 1
int Property Mode Hidden
{	0 := linear
	1 := hyperbolic
	2 := exponential}
	Function Set(int arg)
		Mode_var = arg
		J42_ARR_SKSE_Bridge.setMode(Mode_var)
	EndFunction
	int Function Get()
		return Mode_var
	EndFunction
EndProperty

float LinearMult_var = 0.0012
float Property LinearMult Hidden
	Function Set(float arg)
		LinearMult_var = arg
		J42_ARR_SKSE_Bridge.setLinearMult(LinearMult_var)
	EndFunction
	float Function Get()
		return LinearMult_var
	EndFunction
EndProperty

float LinearFloor_var = 0.2000
float Property LinearFloor Hidden
	Function Set(float arg)
		LinearFloor_var = arg
		J42_ARR_SKSE_Bridge.setLinearFloor(LinearFloor_var)
	EndFunction
	float Function Get()
		return LinearFloor_var
	EndFunction
EndProperty

float HyperDiv_var = 0.0060
float Property HyperDiv Hidden
	Function Set(float arg)
		HyperDiv_var = arg
		J42_ARR_SKSE_Bridge.setHyperDiv(HyperDiv_var)
	EndFunction
	float Function Get()
		return HyperDiv_var
	EndFunction
EndProperty

float ExpBase_var = 0.9976
float Property ExpBase Hidden
	Function Set(float arg)
		ExpBase_var = arg
		J42_ARR_SKSE_Bridge.setExpBase(ExpBase_var)
	EndFunction
	float Function Get()
		return ExpBase_var
	EndFunction
EndProperty

bool UseFloorExpHyp_var = false
bool Property UseFloorExpHyp Hidden
	Function Set(bool arg)
		UseFloorExpHyp_var = arg
		J42_ARR_SKSE_Bridge.setUseFloorExpHyp(UseFloorExpHyp_var)
	EndFunction
	bool Function Get()
		return UseFloorExpHyp_var
	EndFunction
EndProperty

bool UseMultExpHyp_var = false
bool Property UseMultExpHyp Hidden
	Function Set(bool arg)
		UseMultExpHyp_var = arg
		J42_ARR_SKSE_Bridge.setUseMultExpHyp(UseMultExpHyp_var)
	EndFunction
	bool Function Get()
		return UseMultExpHyp_var
	EndFunction
EndProperty

float FloorExpHyp_var = 0.00
float Property FloorExpHyp  Hidden
	Function Set(float arg)
		FloorExpHyp_var = arg
		J42_ARR_SKSE_Bridge.setFloorExpHyp(FloorExpHyp_var)
	EndFunction
	float Function Get()
		return FloorExpHyp_var
	EndFunction
EndProperty

float MultExpHyp_var = 1.00
float Property MultExpHyp Hidden
	Function Set(float arg)
		MultExpHyp_var = arg
		J42_ARR_SKSE_Bridge.setMultExpHyp(MultExpHyp_var)
	EndFunction
	float Function Get()
		return MultExpHyp_var
	EndFunction
EndProperty

float Property timer = 1.0 AutoReadOnly Hidden

String Property dmgMult = "fArmorScalingFactor" AutoReadOnly Hidden
String Property dmgFloor = "fMaxArmorRating" AutoReadOnly Hidden

String Property hiddenRating = "fArmorBaseFactor" AutoReadOnly Hidden

float Property defaultMult = 0.0012 AutoReadOnly Hidden
float Property defaultFloor = 0.0000 AutoReadOnly Hidden

String Property strArmorRating = "My Armor Rating" Auto Hidden
String Property strDamageResist = "My Damage Resistance" Auto Hidden

float cachedValue = -1.0
Function ResetCache()
	cachedValue = -1.0
EndFunction

Event OnInit()
	Maintenance()
EndEvent

Int Function GetSupportedSkseReleaseVersion()
	{This must match the #define SKSE_VERSION_RELEASEIDX
	in "...\src\skse64\skse64_common\skse_version.h"}
	return 64
EndFunction

Function Maintenance()
	UnregisterForUpdate()
	
	PlayerRef.removeSpell(J42_ARR_ARDisplaySpell)
	
	If SKSE.GetScriptVersionRelease() == GetSupportedSkseReleaseVersion()
		Game.SetGameSettingFloat(hiddenRating, 0.0)
		Game.SetGameSettingFloat(dmgMult, defaultMult*100.0)
		Game.SetGameSettingFloat(dmgFloor, 9223372013568.0)
		Game.SetGameSettingFloat("fArmorRatingMax", 2.5)
		
		strArmorRating = J42_ARR_ARDisplaySpell.getName()
		strDamageResist = J42_ARR_ARDisplayEffect.getName()
		
		ResetCache()
		
		J42_ARR_SKSE_Bridge.setMode(Mode_var)
		J42_ARR_SKSE_Bridge.setLinearMult(LinearMult_var)
		J42_ARR_SKSE_Bridge.setLinearFloor(LinearFloor_var)
		J42_ARR_SKSE_Bridge.setHyperDiv(HyperDiv_var)
		J42_ARR_SKSE_Bridge.setExpBase(ExpBase_var)
		J42_ARR_SKSE_Bridge.setFloorExpHyp(FloorExpHyp_var)
		J42_ARR_SKSE_Bridge.setMultExpHyp(MultExpHyp_var)
		J42_ARR_SKSE_Bridge.setUseFloorExpHyp(UseFloorExpHyp_var)
		J42_ARR_SKSE_Bridge.setUseMultExpHyp(UseMultExpHyp_var)
		
		If Debugging
			StatusReport()
		EndIf
		
		If Notify || UseSpell
			RegisterForSingleUpdate(timer)
		EndIf
	Else
		printf("FATAL ERROR - Unsupported SKSE Version!", true)
		J42_ARR_ErrorBox.show()
	EndIf
EndFunction

Event OnUpdate()
	If Notify || UseSpell
		float armorRating
		float damageTaken
		float damageMult
		float damageResist
		
		armorRating = PlayerRef.getActorValue("DamageResist")
		If armorRating != cachedValue
			cachedValue = armorRating
			PlayerRef.removeSpell(J42_ARR_ARDisplaySpell)
			
			If armorRating > 0.0
				damageTaken = Calculate(armorRating)
			Else
				damageTaken = 1.0
			EndIf
			
			damageResist = 100.0 - damageTaken*100.0
			
			If UseSpell
				UpdateDisplaySpell(damageResist)
			EndIf
			
			If Debugging
				printf("ArmorRating: "+armorRating)
				Debug.Notification(strArmorRating +": "+armorRating)
				printf("DamageResist: "+damageResist+"%")
			EndIf
			If Notify || Debugging
				Debug.Notification(strDamageResist+": "+damageResist+"%")
			EndIf
		EndIf
		
		RegisterForSingleUpdate(timer)
	Else
		PlayerRef.removeSpell(J42_ARR_ARDisplaySpell)
	EndIf
EndEvent

Function UpdateDisplaySpell(float z)
	J42_ARR_ARDisplaySpell.SetNthEffectMagnitude(0, z)
	Utility.WaitMenuMode(0.1)
	PlayerRef.addSpell(J42_ARR_ARDisplaySpell, false)
EndFunction

float Function Calculate(float armorRating)
	float damageTaken = 1.0
	
	If Mode_var == 0
		damageTaken = 1.0 - (armorRating * linearMult_var)
		If damageTaken < linearFloor_var
			damageTaken = linearFloor_var
		EndIf
	ElseIf Mode_var == 1
		damageTaken = 1.0/(hyperDiv_var * armorRating + 1.0)
		If UseMultExpHyp_var
			damageTaken = 1.0-((1.0-damageTaken) * MultExpHyp_var)
		EndIf
		If UseFloorExpHyp_var && damageTaken < FloorExpHyp_var
			damageTaken = FloorExpHyp_var
		EndIf
	ElseIf Mode_var == 2
		damageTaken = Math.pow(expBase_var, armorRating)
		If UseMultExpHyp_var
			damageTaken = 1.0-((1.0-damageTaken) * MultExpHyp_var)
		EndIf
		If UseFloorExpHyp_var && damageTaken < FloorExpHyp_var
			damageTaken = FloorExpHyp_var
		EndIf
	EndIf
	return damageTaken
EndFunction

Function printf(string asMsg, bool abNotif = false)
	If abNotif
		Debug.Notification("Armor Rating Redux: " + asMsg)
	EndIf
	Debug.Trace(self +": "+ asMsg)
EndFunction

Function StatusReport()
	printf("=== STATUS REPORT START ===")
	printf("Debugging: "+ Debugging)
	printf("Notify: "+ Notify)
	printf("UseSpell: "+ UseSpell)
	printf("Mode: "+ Mode)
	printf("linearMult: "+ linearMult)
	printf("linearFloor: "+ linearFloor)
	printf("hyperDiv: "+ hyperDiv)
	printf("expBase: "+ expBase)
	printf("UseFloorExpHyp: "+ UseFloorExpHyp)
	printf("UseMultExpHyp: "+ UseMultExpHyp)
	printf("FloorExpHyp: "+ FloorExpHyp)
	printf("MultExpHyp: "+ MultExpHyp)
	printf("timer: "+ timer)
	printf("cachedValue: "+ cachedValue)
	printf("strArmorRating: "+ strArmorRating)
	printf("strDamageResist: "+ strDamageResist)
	printf("J42_ARR_ARDisplaySpell: "+ J42_ARR_ARDisplaySpell)
	printf("J42_ARR_ErrorBox: "+ J42_ARR_ErrorBox)
	printf("PlayerRef: "+ PlayerRef)
	printf("GS hiddenRating: "+ Game.GetGameSettingFloat(hiddenRating))
	printf("GS dmgMult: "+ Game.GetGameSettingFloat(dmgMult))
	printf("GS dmgFloor: "+ Game.GetGameSettingFloat(dmgFloor))
	printf("=== STATUS REPORT END ===")
EndFunction
