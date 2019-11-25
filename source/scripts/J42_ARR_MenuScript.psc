ScriptName J42_ARR_MenuScript extends SKI_ConfigBase


J42_ARR_QuestScript Property J42_ARR_MainQuest Auto

int oidMode
int oidDebugging
int oidNotify
int oidUseSpell

int oidLinearMult
int oidLinearFloor
int oidHyperDiv
int oidexpBase

int oidUseFloorExpHyp
int oidUseMultExpHyp
int oidFloorExpHyp
int oidMultExpHyp


string version
string[] modes
string[] formulas

; Supported SKSE64 Version.
Int ARRSKSE64Version = 20017

Int Function GetVersion()
	;99999 == 9.99.99
	return 20007
EndFunction

Event OnInit() ; This event will run once, when the script is initialized
	OnGameReload()
EndEvent
 
Event OnGameReload()			
	if (SKSE.GetVersionRelease() == 0)
		debug.Notification(ModName+": SKSE64 is not running. Mod will not work!")
		debug.Trace(self+": SKSE not detected")
		return

	elseIf (SKSE.GetVersion() * 10000 + SKSE.GetVersionMinor() * 100 + SKSE.GetVersionBeta() != ARRSKSE64Version)
		debug.Notification(ModName+": Mod will not work correctly!")
		debug.MessageBox("Armor Rating Redux will not work correctly!\nWrong SKSE64 version:" \
		 +"\nRequired version: " + ARRSKSE64Version/10000+"."+(ARRSKSE64Version/100)%100+"."+ARRSKSE64Version%100 \
		 +"\nDetected version: "+SKSE.GetVersion()+"."+SKSE.GetVersionMinor()+"."+SKSE.GetVersionBeta())
		debug.Trace(self+": Wrong SKSE64 version. Armor Rating Redux will not work correctly! Required version: 2.0.17 Detected version:"  + SKSE.GetVersion() + "." + SKSE.GetVersionMinor() + "." + SKSE.GetVersionBeta())
		
		return
	endif

EndEvent

Event OnVersionUpdate(Int ver)
	version = ver/10000+"."+(ver/100)%100+"."+ver%100
	debug.Notification(ModName+": Version "+version)
	debug.Trace(self+": Version "+version)
	
	J42_ARR_MainQuest.stop()
	
	Utility.Wait(1)
	
	J42_ARR_MainQuest.start()
	
EndEvent


Event OnConfigInit()
	debug.Notification(ModName+": LOADING...")
	debug.Trace(self+": LOADING...")
EndEvent

Event OnConfigRegister()

	debug.Notification(ModName+": OK!")
	debug.Trace(self+": OK!")
	
	pages = new string[1]
	pages[0] = "$J42_ARR_Title_General"
	
	modes = new string[3]
	modes[0] = "$J42_ARR_Name_Linear"
	modes[1] = "$J42_ARR_Name_Hyperbolic"
	modes[2] = "$J42_ARR_Name_Exponential"
	
	formulas = new string[3]
	formulas[0] ="$J42_ARR_Formula_Linear"
	formulas[1] ="$J42_ARR_Formula_Hyperbolic"
	formulas[2] ="$J42_ARR_Formula_Exponential"
EndEvent


Event OnConfigOpen()
	pages = new string[1]
	pages[0] = "$J42_ARR_Title_General"
	
	
	modes = new string[3]
	modes[0] = "$J42_ARR_Name_Linear"
	modes[1] = "$J42_ARR_Name_Hyperbolic"
	modes[2] = "$J42_ARR_Name_Exponential"
	
	formulas = new string[3]
	formulas[0] ="$J42_ARR_Formula_Linear"
	formulas[1] ="$J42_ARR_Formula_Hyperbolic"
	formulas[2] ="$J42_ARR_Formula_Exponential"
EndEvent

Event OnConfigClose()
	;Utility.Wait(0.1)
	J42_ARR_MainQuest.ResetCache()
	J42_ARR_MainQuest.RegisterForSingleUpdate(J42_ARR_MainQuest.timer)
EndEvent


Event OnPageReset(string page)
	
	SetTitleText(ModName)
	SetCursorFillMode(TOP_TO_BOTTOM)
	
	If page == pages[0]
		;left side
		AddHeaderOption("$J42_ARR_Title_Settings")
		oidMode = AddTextOption("$J42_ARR_Title_Formula", modes[J42_ARR_MainQuest.Mode])
		AddTextOption("", formulas[J42_ARR_MainQuest.Mode], OPTION_FLAG_DISABLED)
		
		AddEmptyOption()
		oidLinearMult = AddSliderOption("$J42_ARR_Param_LinearMult",J42_ARR_MainQuest.LinearMult ,"{4}")
		oidLinearFloor = AddSliderOption("$J42_ARR_Param_LinearFloor",J42_ARR_MainQuest.LinearFloor ,"{4}")
		oidHyperDiv = AddSliderOption("$J42_ARR_Param_HyperDiv",J42_ARR_MainQuest.HyperDiv ,"{4}")
		oidExpBase = AddSliderOption("$J42_ARR_Param_ExpBase",J42_ARR_MainQuest.ExpBase ,"{4}")
		
		AddHeaderOption("")
		oidNotify = AddToggleOption("$J42_ARR_Option_Notify", J42_ARR_MainQuest.Notify)
		oidUseSpell = AddToggleOption("$J42_ARR_Option_UseSpell", J42_ARR_MainQuest.UseSpell)
		oidDebugging = AddToggleOption("$J42_ARR_Option_Log_Debug", J42_ARR_MainQuest.Debugging)
		
		AddHeaderOption("$J42_ARR_Title_Advanced")
		oidUseFloorExpHyp = AddToggleOption("$J42_ARR_Option_UseFloorExpHyp", J42_ARR_MainQuest.UseFloorExpHyp)
		oidFloorExpHyp = AddSliderOption("$J42_ARR_Param_FloorExpHyp",J42_ARR_MainQuest.FloorExpHyp ,"{2}")
		oidUseMultExpHyp = AddToggleOption("$J42_ARR_Option_UseMultExpHyp", J42_ARR_MainQuest.UseMultExpHyp)
		oidMultExpHyp = AddSliderOption("$J42_ARR_Param_MultExpHyp",J42_ARR_MainQuest.MultExpHyp ,"{2}")
		
		;right side
		SetCursorPosition(1)
		AddHeaderOption("$J42_ARR_Title_DamageTaken")
		AddSliderOption("$J42_ARR_Info_At_X_AR{"+50+"}",J42_ARR_MainQuest.Calculate(50)*100, "{2}%", OPTION_FLAG_DISABLED)
		AddSliderOption("$J42_ARR_Info_At_X_AR{"+100+"}",J42_ARR_MainQuest.Calculate(100)*100, "{2}%", OPTION_FLAG_DISABLED)
		AddSliderOption("$J42_ARR_Info_At_X_AR{"+200+"}",J42_ARR_MainQuest.Calculate(200)*100, "{2}%", OPTION_FLAG_DISABLED)
		AddSliderOption("$J42_ARR_Info_At_X_AR{"+300+"}",J42_ARR_MainQuest.Calculate(300)*100, "{2}%", OPTION_FLAG_DISABLED)
		AddSliderOption("$J42_ARR_Info_At_X_AR{"+400+"}",J42_ARR_MainQuest.Calculate(400)*100, "{2}%", OPTION_FLAG_DISABLED)
		AddSliderOption("$J42_ARR_Info_At_X_AR{"+500+"}",J42_ARR_MainQuest.Calculate(500)*100, "{2}%", OPTION_FLAG_DISABLED)
		AddSliderOption("$J42_ARR_Info_At_X_AR{"+667+"}",J42_ARR_MainQuest.Calculate(667)*100, "{2}%", OPTION_FLAG_DISABLED)
		AddSliderOption("$J42_ARR_Info_At_X_AR{"+800+"}",J42_ARR_MainQuest.Calculate(800)*100, "{2}%", OPTION_FLAG_DISABLED)
		AddSliderOption("$J42_ARR_Info_At_X_AR{"+1000+"}",J42_ARR_MainQuest.Calculate(1000)*100, "{2}%", OPTION_FLAG_DISABLED)
		AddSliderOption("$J42_ARR_Info_At_X_AR{"+1500+"}",J42_ARR_MainQuest.Calculate(1500)*100, "{2}%", OPTION_FLAG_DISABLED)
		AddSliderOption("$J42_ARR_Info_At_X_AR{"+2000+"}",J42_ARR_MainQuest.Calculate(2000)*100, "{2}%", OPTION_FLAG_DISABLED)
		AddSliderOption("$J42_ARR_Info_At_X_AR{"+5000+"}",J42_ARR_MainQuest.Calculate(5000)*100, "{2}%", OPTION_FLAG_DISABLED)
	Endif
	
EndEvent

Event OnOptionSelect(int option)
	If option == oidDebugging
		J42_ARR_MainQuest.debugging = !J42_ARR_MainQuest.debugging
		SetToggleOptionValue(option,J42_ARR_MainQuest.debugging)
		
	ElseIf option == oidNotify
		J42_ARR_MainQuest.Notify = !J42_ARR_MainQuest.Notify
		SetToggleOptionValue(option,J42_ARR_MainQuest.Notify)
		
	ElseIf option == oidUseSpell
		J42_ARR_MainQuest.UseSpell = !J42_ARR_MainQuest.UseSpell
		SetToggleOptionValue(option,J42_ARR_MainQuest.UseSpell)
		
	ElseIf option == oidUseFloorExpHyp
		J42_ARR_MainQuest.useFloorExpHyp = !J42_ARR_MainQuest.useFloorExpHyp
		SetToggleOptionValue(option,J42_ARR_MainQuest.useFloorExpHyp)
		
	ElseIf option == oidUseMultExpHyp
		J42_ARR_MainQuest.UseMultExpHyp = !J42_ARR_MainQuest.UseMultExpHyp
		SetToggleOptionValue(option,J42_ARR_MainQuest.UseMultExpHyp)
		
	ElseIf option == oidMode
		J42_ARR_MainQuest.Mode = (J42_ARR_MainQuest.Mode+1)%3
		SetTextOptionValue(option,modes[J42_ARR_MainQuest.Mode])
	EndIf
	ForcePageReset()
EndEvent


Event OnOptionDefault(int option)
	If option == oidDebugging
		J42_ARR_MainQuest.debugging = false
		SetToggleOptionValue(option,J42_ARR_MainQuest.debugging)
		
	ElseIf option == oidNotify
		J42_ARR_MainQuest.notify = false
		SetToggleOptionValue(option,J42_ARR_MainQuest.notify)
		
	ElseIf option == oidUseSpell
		J42_ARR_MainQuest.UseSpell = false
		SetToggleOptionValue(option,J42_ARR_MainQuest.UseSpell)
		
	ElseIf option == oidUseFloorExpHyp
		J42_ARR_MainQuest.UseFloorExpHyp = false
		SetToggleOptionValue(option,J42_ARR_MainQuest.UseFloorExpHyp)
		
	ElseIf option == oidUseMultExpHyp
		J42_ARR_MainQuest.UseMultExpHyp = false
		SetToggleOptionValue(option,J42_ARR_MainQuest.UseMultExpHyp)
		
	ElseIf option == oidMode
		J42_ARR_MainQuest.Mode = 1
		SetTextOptionValue(option,modes[J42_ARR_MainQuest.Mode])
		
	ElseIf option == oidLinearMult
		J42_ARR_MainQuest.linearMult = 0.0012
		SetSliderOptionValue(option,J42_ARR_MainQuest.linearMult,"{4}")
		
	ElseIf option == oidLinearFloor
		J42_ARR_MainQuest.linearFloor = 0.2000
		SetSliderOptionValue(option,J42_ARR_MainQuest.linearFloor,"{4}")
		
	ElseIf option == oidHyperDiv
		J42_ARR_MainQuest.hyperDiv = 0.0060
		SetSliderOptionValue(option,J42_ARR_MainQuest.hyperDiv,"{4}")
		
	ElseIf option == oidExpBase
		J42_ARR_MainQuest.expBase = 0.9976
		SetSliderOptionValue(option,J42_ARR_MainQuest.expBase,"{4}")
		
	ElseIf option == oidFloorExpHyp
		J42_ARR_MainQuest.FloorExpHyp = 0.00
		SetSliderOptionValue(option,J42_ARR_MainQuest.FloorExpHyp,"{2}")
		
	ElseIf option == oidMultExpHyp
		J42_ARR_MainQuest.MultExpHyp = 1.00
		SetSliderOptionValue(option,J42_ARR_MainQuest.MultExpHyp,"{2}")
		
	EndIf
	ForcePageReset()
endEvent

Event OnOptionSliderOpen(Int option)

	SetSliderDialogInterval(0.0001)
	
	If option == oidLinearMult
		SetSliderDialogStartValue(J42_ARR_MainQuest.linearMult)
		SetSliderDialogDefaultValue(0.0012)
		SetSliderDialogRange(0.0001, 0.0100)
		
	ElseIf option == oidLinearFloor
		SetSliderDialogStartValue(J42_ARR_MainQuest.linearFloor)
		SetSliderDialogDefaultValue(0.2000)
		SetSliderDialogRange(0.0, 1.0)
		
	ElseIf option == oidHyperDiv
		SetSliderDialogStartValue(J42_ARR_MainQuest.hyperDiv)
		SetSliderDialogDefaultValue(0.0067)
		SetSliderDialogRange(0.0001, 0.01)
		
		
	ElseIf option == oidExpBase
		SetSliderDialogStartValue(J42_ARR_MainQuest.expBase)
		SetSliderDialogDefaultValue(0.9975)
		SetSliderDialogRange(0.9900, 0.9999)
		
	ElseIf option == oidFloorExpHyp
		SetSliderDialogInterval(0.01)
		SetSliderDialogStartValue(J42_ARR_MainQuest.FloorExpHyp)
		SetSliderDialogDefaultValue(0.00)
		SetSliderDialogRange(0.00, 1.00)
		
	ElseIf option == oidMultExpHyp
		SetSliderDialogInterval(0.01)
		SetSliderDialogStartValue(J42_ARR_MainQuest.MultExpHyp)
		SetSliderDialogDefaultValue(1.00)
		SetSliderDialogRange(0.00, 1.00)
		
	EndIf
	
EndEvent

Event OnOptionSliderAccept(Int option, Float value)

	If option == oidLinearMult
		J42_ARR_MainQuest.linearMult = value
		SetSliderOptionValue(option, J42_ARR_MainQuest.linearMult, "{4}")
		
	ElseIf option == oidLinearFloor
		J42_ARR_MainQuest.linearFloor = value
		SetSliderOptionValue(option, J42_ARR_MainQuest.linearFloor, "{4}")
		
	ElseIf option == oidHyperDiv
		J42_ARR_MainQuest.hyperDiv = value
		SetSliderOptionValue(option,J42_ARR_MainQuest.hyperDiv,"{4}")
		
	ElseIf option == oidExpBase
		J42_ARR_MainQuest.expBase = value
		SetSliderOptionValue(option,J42_ARR_MainQuest.expBase,"{4}")
		
	ElseIf option == oidFloorExpHyp
		J42_ARR_MainQuest.FloorExpHyp = value
		SetSliderOptionValue(option,J42_ARR_MainQuest.FloorExpHyp,"{2}")
		
	ElseIf option == oidMultExpHyp
		J42_ARR_MainQuest.MultExpHyp = value
		SetSliderOptionValue(option,J42_ARR_MainQuest.MultExpHyp,"{2}")
		
	Endif
	
	ForcePageReset()
EndEvent

Event OnOptionHighlight(Int option)
	If option == oidMode
		SetInfoText("$J42_ARR_Hint_Mode")
		
	ElseIf option == oidDebugging
		SetInfoText("$J42_ARR_Hint_Debug")
		
	ElseIf option == oidNotify
		SetInfoText("$J42_ARR_Hint_Notify")
		
	ElseIf option == oidUseSpell
		SetInfoText("$J42_ARR_Hint_UseSpell")
		
	ElseIf option == oidUseFloorExpHyp
		SetInfoText("$J42_ARR_Hint_UseFloorExpHyp")
		
	ElseIf option == oidUseMultExpHyp
		SetInfoText("$J42_ARR_Hint_UseMultExpHyp")
		
	Else
		SetInfoText("$J42_ARR_Hint_Default{"+ModName+"}{"+version+"}")
	EndIf
EndEvent
