Armor Rating Redux 2.0.6 SE
by DaJay42 on NexusMods.com

===============================================================================

Armor Rating Redux - No Cap, Better Formula, Morrowind-like

Fixes the ridiculously broken armor rating system in Skyrim by implementing a 
formula closer to what Morrowind had. Fully configurable!
Now for SE!

===============================================================================

------------
The Problem:
------------
The vanilla armor system is utterly, utterly broken.
Having an armor rating of 0 - 300 is pretty much pointless, as you still take 
almost full damage. 
Having an armor rating of 300 - 600 suddenly means every point is valuable, 
as your survivability increases hyperbolically.
Having an armor rating of over 667 (567 if in full armor) means any further 
increase is pointless, as your damage resistance simply goes flat.

For a more detailed discussion, see this six years old(!) forum thread:
http://forums.nexusmods.com/index.php?/topic/481577-skyrims-armor-system-is-broken/

===============================================================================

-------------
The Solution:
-------------
Replace the broken system with one like in Morrowind, where every point of 
armor counts.
This mod attempts to do just that.

It replaces Skyrim's Damage Resistance calculation with one of 3 formulas, 
as described below. All of them can be fine-tuned in the mod's MCM, which 
also has some advanced options for that really specific armor formula you 
never knew you needed.
All changes apply to both the player and any NPCs.
Additionally, the mod provides two (optional) ways of informing the player of 
their current resistance: by notification or with a (fake) magic effect.

===============================================================================

-----------
Definitions:
-----------
To make sure we're talking about the same thing, let's first define some terms:

Armor Rating: The current armor value displayed in your inventory, as 
	modified by your skills, perks, etc.

Hidden Armor Rating: On top of its visible armor rating, every piece of 
	armor you wear grants an additional 25 points of fixed, invisible armor 
	rating. This seems to be the result of a halfhearted attempt by Bethesda 
	to balance their broken system. This completely messes up the balance when 
	using armors with more than the standard amount of pieces.

Damage Resist(ance): The fraction of incoming damage that is negated by your 
	armor.

Damage Taken: The fraction of incoming damage that passes through your armor.

Survivability: By how much your armor increases your ability to survive damage.
	e.g. with +400% survivability and 100 health, you could take 500 damage 
	before dying.

Level-Adjusted Survivability: By how much your armor increases your ability 
	to survive damage, relative to how much damage your enemies of the same 
	level can deal. In Skyrim, weapon damage increases linearly with skill, 
	so you need to have at least a linear increase in survivability to stay 
	ahead of the curve.

===============================================================================

---------
Formulas:
---------
The mod currently supports 3 computation modes:

-----------
Hyperbolic:
-----------
Morrowind-like. Every point of armor rating increases your survivability by a 
fixed percentage. This means every point of armor is worth the same. Compared 
to vanilla, your early armor will protect you a lot more, while armor past 
the cap will still be useful, but it is difficult to reach crazy high 
protection values.
HypDiv controls the increase per point. The default is 0.6%, which means you 
will reach 80% protection (+400% survivability) at 667 armor rating, just like 
vanilla.

Your survivability will increase linearly, damage taken decrease hyperbolically.
Twice the armor rating means twice the survivability.
Damage Taken = Input damage / (Armor Rating * HypDiv + 1)


------------
Exponential:
------------
A compromise between Morrowind-style survivability and vanilla "balancing". 
Every point of armor will reduce damage taken by a fixed multiplier. 
Your early armor will be worth less than with "Hyperbolic", but your late game 
armor will let you come closer to 100% resistance.
ExpBase controls the damage multiplier per point. The default is 99.76%, which 
means you will reach 80% protection (+400% survivability) at approximately 667 
armor rating, just like vanilla.

Your survivability will increase exponentially, damage taken decrease 
exponentially. Every 'x' points of Armor Rating, your survivability doubles.
Damage Taken = Input damage * ExpBase^Armor Rating


-------
Linear:
-------
Vanilla-like, but without the hidden armor rating. Just because.
Every point of armor reduces damage taken by subtracting a fixed value.
Results as described above.
LinearMult controls the reduction per point. The default is 0.12%.
LinearFloor controls the lowest possible multiplier. The default is 0.2
The default values let you reach 80% protection (+400% survivability) at 
667 armor rating, just like vanilla.

Your survivability will increase hyperbolically, damage taken decrease 
linearly.
Damage Taken = Input damage * max(LinearFloor, 1 - LinearMult * Armor Rating)



===============================================================================

-----------------
Advanced Options:
-----------------

As of 1.1.0, these advanced options are available:

FloorExpHyp: If activated, imposes a hard limit on your resistance in Hyperbolic 
or Exponential modes, equivalent to what linearFloor does in Linear mode. 

MultExpHyp: If enabled, reduces your resistance in Hyperbolic or Exponential 
modes by a multiplier, acting as a soft ceiling. 
Thanks Neker07 for the ideas!


===============================================================================

------------
Compability:
------------
	- Should be loaded after other mods that change Game Settings related to 
		Armor.
	- Not compatible with any mod that attempts to do the same thing (duh).
	
	Compatible with everything else.
	...probably.


===============================================================================

--------
Caveats:
--------
	- The magic effect description will round resistance to the next integer 
		value. To know your precise resistance, use the "notify" option.

===============================================================================

Requirements:
	- SKSE 2.0.16
	- SkyUI SE

===============================================================================

--------
Changes:
--------
2.0.6 (SE only)
	- Updated for SKSE 2.0.16 / Runtime 1.5.80
	- Thanks to SSyl for the assistance!

2.0.5 (SE only)
	- Updated for SKSE 2.0.15 / Runtime 1.5.73
	- Thanks to SSyl for the assistance!
		
2.0.4 (SE only)
	- Updated for SKSE 2.0.11 / Runtime 1.5.62
		
2.0.3 (SE only)
	- Updated for SKSE 2.0.9
		
2.0.2 (SE only)
	- Updated for SKSE 2.0.8
		
2.0.1 (SE only)
	- Fixed an oversight in the SE plugin that could cause actors with negative 
		armor rating to take infinite or negative damage if hyperbolic mode is 
		active.

2.0.0
	- Complete overhaul of the mod's internals. Now does its computation in a 
		SKSE plugin, rather than Papyrus code. (A HUGE thank you to 
		underthesky for letting me make use of his SKSE code!)
		Due to this being a huge change to the mods workings, a clean save 
		is absolutely recommended.
		This change has some neat effects:
	- Significantly increased performance.
	- Player Only version no longer required, as calculations for NPCs are no 
		longer a potential performance drain.
	- Changes in armor rating always have immediate effect.
	- No more ActorValue or AVI Skill Mult caused incompatibilities.
	- High Damage Resist values no longer cause weird stamina consumption 
		on blocking NPCs.
	- NPC Damage Resist is no longer hard capped.
	- On a different note, made the mod translation-friendly. Note that all 
		included translation files are dummy files and contain English text.
	- Added a German translation to serve as an example. Translators for other 
		languages welcome!

1.2.1
	- Fixed an issue that could cause the player to take excessive amounts of 
		damage when exceeding vanilla resistance limits.

1.2.0
	- Changed the used actor value from "Fame" to "Variable07". This should 
		hopefully create less conflicts.
	- Changed the way NPCs are treated. The new method has a hard cap at 99% 
		resistance, and might be slightly slower to update, but should be a lot
		more reliable and cause less "spikes" in script activity.
	- Added a "player only" version, for those who value performance over 
		fairness. A clean save is recommended when switching between 
		"Everyone" and "Player Only" versions.

1.1.0
	- Added advanced options: If activated, FloorExpHyp imposes a hard limit on 
		your resistance in Hyperbolic or Exponential modes, equivalent to what 
		linearFloor does in Linear mode. MultExpHyp, if enabled, reduces your 
		resistance by a multiplier, and acts as a soft ceiling. 
		Thanks Neker07 for the ideas!

1.0.1
	- Fixed minor issue that caused incorrect debug output.

1.0.0
	- Initial release.


===============================================================================

----------------------------
Permissions/License/Credits:
----------------------------
The SE version of the mod contains code by locerra, without whom this port 
would not have been possible. Many thanks!
Additional assistance was provided by hotemup. Thanks to you, too!
Update 1.0.5 was done in part by SSyl. Thanks!

The original mod contains code from Armor Rating Rescaled by underthesky:
http://www.nexusmods.com/skyrim/mods/85358/
Used under permission as stated on that mod's page.
(Once again, a huge thank you for that!)

Written by DaJay42, nexusmods.com, 2016-2019.
Software provided as-is, with no warranty.
For personal use only.
Re-uploads, uploads to other sites or uploads of derivative works are allowed 
only after advance written permission by the author, or failure of the author 
to respond within an month of a written request for such permission.

