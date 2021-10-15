/obj/item/weapon/gun/get_antag_info()
	var/list/entries = SScodex.retrieve_entries_for_string(general_codex_key)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.antag_text)
		return general_entry.antag_text

/obj/item/weapon/gun/get_lore_info()
	var/list/entries = SScodex.retrieve_entries_for_string(general_codex_key)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.lore_text)
		return general_entry.lore_text

/obj/item/weapon/gun/get_mechanics_info()
	. = ..()
	var/list/traits = list()

	if(flags_gun_features & GUN_WIELDED_FIRING_ONLY)
		traits += "This can only be fired with a two-handed grip."
	else
		traits += "It's best fired with a two-handed grip."


	if(HAS_TRAIT(src, TRAIT_GUN_SAFETY))
		traits += "It has a safety switch. Alt-Click it to toggle safety."

	if(scope_zoom) //flawed, unless you check the codex for the first time when the scope is attached, this won't show. works for sniper rifles though.
		traits += "It has a magnifying optical scope. It can be toggled with Use Scope verb."

	if(burst_amount > 2)
		traits += "It has multiple firemodes. Click the Toggle Burst Fire button to change it."


	traits += "<br>Caliber: [caliber]"

	if(max_shells)
		traits += "It can normally hold [max_shells] rounds."

	if(max_shots)
		traits += "Its maximum capacity is normally [max_shots] shots worth of power."

	var/list/loading_ways = list()
	if(load_method & SINGLE_CASING)
		loading_ways += "loose [caliber] rounds."
	if(load_method & SPEEDLOADER)
		loading_ways += "speedloaders."
	if(load_method & MAGAZINE)
		loading_ways += "magazines."
	if(load_method & CELL)
		loading_ways += "cells."
	if(load_method & POWERPACK)
		loading_ways += "it's powerpack."
	traits += "Can be loaded using [english_list(loading_ways)]"

	if(attachable_allowed)
		traits += "<br><U>You can attach</U>:"
		for(var/X in attachable_allowed)
			var/obj/item/attachable/A = X
			traits += "[initial(A.name)]"

	traits += "<br><U>Basic Statistics for this weapon are as follows</U>:"
	if(w_class)
		traits += "Size: [w_class]"
	if(force)
		traits += "Base melee damage: [force]"
	if(accuracy_mult)
		traits += "Accuracy: [((accuracy_mult - 1) * 100) > 0 ? "+[(accuracy_mult - 1) * 100]" : "[(accuracy_mult - 1) * 100]"]%"
	if(damage_mult)
		traits += "Damage modifier: [((damage_mult - 1) * 100) > 0 ? "+[(damage_mult - 1) * 100]" : "[(damage_mult - 1) * 100]"]%"
	if(damage_falloff_mult)
		traits += "Damage falloff: -[damage_falloff_mult] per tile travelled."
	if(recoil)
		traits += "Recoil: [recoil]"
	if(scatter)
		traits += "Scatter chance modifier: [scatter]%"
	if(burst_scatter_mult)
		traits += "Burst scatter chance multiplier: x[burst_scatter_mult]"
	if(accuracy_mod)
		traits += "Accuracy modifier: [accuracy_mod * 100]%"
	if(accuracy_mult_unwielded)
		traits += "Accuracy unwielded modifier: [((accuracy_mult_unwielded - 1) * 100) > 0 ? "+[(accuracy_mult_unwielded - 1) * 100]" : "[(accuracy_mult_unwielded - 1) * 100]"]%"
	if(recoil_unwielded)
		traits += "Recoil Unwielded: [recoil_unwielded]"
	if(scatter_unwielded)
		traits += "Unwielded Scatter chance modifier: [scatter_unwielded > 0 ? "+[scatter_unwielded]" : "[scatter_unwielded]"]%"
	if(movement_acc_penalty_mult)
		traits += "Movement unwielded penalty modifier: -[(movement_acc_penalty_mult * 0.15) * 100]%"
	if(fire_delay)
		traits += "Time between single-fire: [fire_delay / 10] seconds"
	if(wield_delay)
		traits += "Wield delay: [wield_delay / 10] seconds"
	if(burst_amount > 1)
		traits += "Shots fired on burst mode: [burst_amount]"
		traits += "Time between burst-fire: [(min((burst_delay * 2), (fire_delay * 3))) / 10] seconds"
	if(/datum/action/item_action/aim_mode in actions_types)
		traits += "Can be aimed with to shoot past allies."
		traits += "Time between aimed shots: [(fire_delay + aim_fire_delay) / 10] seconds"

	traits += "<br>"
	var/list/entries = SScodex.retrieve_entries_for_string(general_codex_key)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.mechanics_text)
		traits += general_entry.mechanics_text

	. += jointext(traits, "<br>")

/obj/item/weapon/gun/energy/get_mechanics_info()
	. = ..()
	var/list/traits = list()

	if(self_recharge)
		traits += "It recharges itself over time."

	. += jointext(traits, "<br>")

/obj/item/weapon/gun/shotgun/pump/get_mechanics_info()
	. = ..()
	if(gun_skill_category == GUN_SKILL_RIFLES)
		. += "<br><br>To work the weapon press spacebar.<br>"
	else
		. += "<br><br>To pump it press spacebar.<br>"

/obj/item/weapon/gun/energy/crossbow/get_antag_info()
	. = ..()
	. += "This is a stealthy weapon which fires poisoned bolts at your target. When it hits someone, they will suffer a stun effect, in \
	addition to toxins. The energy crossbow recharges itself slowly, and can be concealed in your pocket or bag.<br>"

/obj/item/weapon/gun/energy/chameleon/get_antag_info()
	. = ..()
	. += "This gun is actually a hologram projector that can alter its appearance to mimick other weapons. To change the appearance, use \
	the appropriate verb in the chameleon items tab. Any beams or projectiles fired from this gun are actually holograms and useless for actual combat. \
	Projecting these holograms over distance uses a little bit of charge.<br>"

/datum/codex_entry/energy_weapons
	display_name = "energy weapons"
	mechanics_text = "This weapon is an energy weapon; they run on battery charge rather than traditional ammunition. You can recharge \
		an energy weapon by placing it in a table-mounted or field-deployed charger such as those found in Medical or around the \
		area. In addition, energy weapons, if compatible, can be recharged via energy-fed battery cells acting as magazines, \
		which can also be recharged at chargers. Most energy weapons' projectiles can go straight through windows and hit whatever \
		is on the other side, and have very fast projectiles, making them accurate and useful against distant targets. \
		Some (like the TE series of weapons) have hitscan properties, allowing the weapon to hit the target instantly. \
		<br>"
	lore_text = "\"OPERATOR\", the tagline and marketing tactic of energy weapons (usually lasguns) in the 25th century, \
		especially made popular with the rise of the xenomorph threat in 2414. Energy weapons are usually famed by private security firms \
		thanks to their ability to disable human targets easily and even on the military thanks to their ability to recharge using \
		traditional chargers and their capability to switch their lens, allowing more flexibility, something that a ballistic weapon \
		aren't capable of."

/datum/codex_entry/ballistic_weapons
	display_name = "ballistic weapons"
	mechanics_text = "This weapon is a ballistic weapon; it fires solid shots using a magazine or loaded rounds of ammunition. You can \
		unload it by holding it and clicking it with an empty hand, and reload it by clicking it with a magazine, speedloader and loose rounds, or in the case of \
		shotguns or some rifles, by opening the breech and clicking it with individual rounds. \
		<br>"
	lore_text = "Ballistic weapons are still used even now due to the relative expense of decent laser \
		weapons, difficulties in maintaining them, and the sheer stopping and wounding power of solid slugs or \
		composite shot. Using a ballistic weapon on a spacebound habitat is usually considered a serious undertaking, \
		as a missed shot or careless use of automatic fire could rip open the hull or injure bystanders with ease."

/datum/codex_entry/flame_weapons
	display_name = "flame weapons"
	mechanics_text = "This is a flame weapon; it unleashes a stream of fire using a incinerator tank. You can \
		refill liquid fuel by either using specialized fueltank backpacks made for the weapon or other fueltanks \
		used by welders, although they're not as effective. Unlike energy or ballistic weapons, flame weapons can \
		pierce through entities, people or not. Depending on the flame type, the flames' longevity, range and spray \
		shape varies from type to type. \
		<br>"
	lore_text = "Traditional flamethrowers were developed in the 1st century and saw frequent use in the 20th century \
		in the first two world wars on Terra. Thanks to their questionable purpose of burning people alive, rebel \
		armies, militia groups and terrorist organizations make use of the weapon for centuries to come. It wasn't issued \
		to inventory for the TerraGov Marine Corps along with lasguns until 2414, due to the xenomorph threat and its vulnerability to intense heat."

/datum/codex_entry/explosive_weapons
	display_name = "explosive weapons"
	mechanics_text = "This is an explosive weapon; it fires a projectile capable of detonating once it reaches its target. You can \
		reload it by clicking the weapon with either rockets or grenades, depending on its type. Explosive \
		weapons are usually unwieldly to use during combat situations and they usually cause massive collateral damage \
		if misused. \
		<br>"
	lore_text = "Handheld explosive weapons still remain a use in situations where an anti-armor or anti-air weapon is needed on the field. \
		Since the advent of space ships and shuttles, explosive weapons in conventional forces had its payloads reduced \
		in conjuction with stronger hulls, to avoid breaches and to avoid accidental equipment loss or even casualties. \
		It should be noted that the user will need to be aware and at the ready before discharging them."

/datum/codex_entry/sniper_rifle
	associated_paths = list(/obj/item/weapon/gun/rifle/sniper/antimaterial)
	lore_text = "A rather strange gun in the TGMC's arsenal. The M42A \"Express\" originally was born out of it's younger brother the M42. Made by the same \
	company who eventually went on to design the M56 smartgun system. Which the M42As specialized scope eventually adopted a modified IFF system similar to it's cousin the smartgun. <br><br>\
	It was at first marketed to PMCs and civilians as an expensive accurate long range rifle but it failed due to the lack of need for such a thing for PMCs and the wide variety of options \
	already available for civilians in a more affordable package. The company after the failure went onto design the M56 smartgun and succeeded there however. Which kept them afloat after the failure of the M42.<br><br>\
	Later however an announcement by the Marine Corps who decided to replace the aging supply of the current adopted Sniper Rifle after complaints that the frames were starting to wear out due to long-term use and thus trials would be announced to replace them.<br><br>\
	Eventually, the board of directors decided to give that reviving the M42 design was a worthwhile possibility. And thus the design was decided to be modernized and equipped with an IFF-capable scope, after that it was named as the M42A and submitted to go the trials.<br><br>\
	Though high unit cost didn't allow it to be more widely adopted it was eventually decided that it would meet limited adoption for Marksmen and be designated the T-26."

/datum/codex_entry/battle_rifle
	associated_paths = list(/obj/item/weapon/gun/rifle/tx8)
	lore_text = "The M45A was born from a commission order from the TGMC to the company which made the M42A and M56 smartgun systems. <br><br>\
	The reason for this commission order resulted from complaints from light infantry and scout units about the poor accuracy of the new T-26 \
	carbine at longer ranges and the large size of the T-29 making close combat uncomfortable eventually reached the higher ups, who kept getting \
	the same complaints over and over. So they eventually reached out to a trusted company to do it.<br><br>\
	The commission order requested a versatile rifle that can do combat at all ranges but can be compact. <br><br>\
	Eventually, the designers decided to use the same 10x28 round the M42A used with different pressure specifications \
	the ammo used for the M45A was pretty much purpose-built to use.<br><br>\
	It was also decided to use a bullpup configuration to keep the size compact and to allow for a longer barrel \
	while keeping the size small. This resulted in a gun created for specialized troops to use at longer than usual \
	ranges and at close range quite effectively.<br><br>\
	After tests by the troops it was meant to be supplied to (light infantry and scout troops) it was rather well-liked \
	and was met with limited adoption for light infantry and scout troops.<br><br>\
	The TGMC gave it the designation of T-45 after adoption."

/datum/codex_entry/rocket_launcher
	associated_paths = list(/obj/item/weapon/gun/launcher/rocket)
	lore_text = "Nicknamed the \"SADAR\", which refers to the previous rocket launcher the SU-185 eventually replaced. <br><br>\
	The SU-185 was designed with low weight to be easy to carry on one's back and still be able to carry rockets on the person who \
	is carrying the weapon without making them weighed down too far. It's also created with short range application of rockets rather than long ranged.<br><br>\
	It was designed after a possible announcement for the replacement to the heavy and aging T-151 SADAR (Non-TGMC name PF-1.), \
	after the actual announcement of the trial participants to show their designs to the Corps where eventually the SU-185 won out \
	the trials after a close last part on the trials with its competitors in the final round, winning out due to showing lower weight and better short-range accuracy than its peers. <br><br>\
	After field-testing good reports from troops eventually, leading to its full adoption with the naming of \"T-152\". <br><br>\
	It's a rather rare sight due to the current doctrine adopted by the TGMC not using heavy explosives often, so it's a rather \
	rare sight outside of specialized users. and the rising prevalence of shipside combat making it dangerous to fire inside those \
	spaces makes it even used less. Not that it makes it any less dangerous on an open field."

/datum/codex_entry/standard_shotgun
	associated_paths = list(/obj/item/weapon/gun/shotgun/pump/t35)
	lore_text = "The K23 itself was designed at first for military use as 12 gauge pump-action shotguns were starting to pick up steam \
	again due to advancements in ammunition made them much more effective at breaking doors and simple masterkey shotguns were starting \
	to fall out of favor due to the preference of grenade launchers or other grips started to phase them out. <br><br>\
	Eventually trials were made for a new shotgun and the K23 eventually won them out and was adopted as the T-35. It was \
	officially adopted as a door breaching tool but was incredibly effective at close quarters and shipside combat because \
	advancements in  ammunition allowed shotguns to punch through common ballistic armor, making it a popular option for close quarters situations."

/datum/codex_entry/standard_revolver
	associated_paths = list(/obj/item/weapon/gun/revolver/standard_revolver)
	lore_text = "The original RN-44 used to be the only standard issue sidearm of the TGMC. Though it was once going to \
	be fully replaced by the T-27 once that was adopted, it was eventually decided to be kept due to complaints from \
	troops of the power and accuracy of the new 9mm pistol to the old .44 so it was decided to keep both handguns and \
	allow a choice between both. Then soon after a modernization came to the old RN-44 design. Eventually being updated to the TP-44.<br><br>\
	The original RN-44 design that was adopted quite some time ago by the Marine Corps as part of a new program asking for \
	a new sidearm that could be reliable on long voyages without much maintenance and the RN-44 eventually won out it's peers \
	due to its good accuracy and ability to stay in good condition for long periods of time. Eventually ending up as the original TP-44."

/datum/codex_entry/standard_pistol
	associated_paths = list(/obj/item/weapon/gun/pistol/standard_pistol)
	lore_text = "The RL-9's design was created to require as little maintenance for a Pistol in a long period of time in-order \
	to compete during the new trials to be put up by the Marine Corps once they decided the TP-44 Revolver was too cumbersome for normal use. <br><br>\
	Eventually the RL-9 won the trials due to showing good use after passing the 300 round test in the final rounds of the trial with only a \
	single misfire during the entire 1000 round firing.<br><br>\
	After the trials the gun was slated to fully replace the TP-44 as the TP-19 Pistol.<br><br>\
	But certain troops complained that the T-27 couldn't be as accurate out to further ranges and the power of the .44 round was more worthwhile \
	to them than the 9mm round. Eventually it was decided that the TP019 would be adopted as the second sidearm of the TGMC instead of fully \
	replacing the TP-44 which would later eventually be modernized."

/datum/codex_entry/standard_assaultrifle
	associated_paths = list(/obj/item/weapon/gun/rifle/standard_assaultrifle)
	lore_text = "The RM-51 used to be the Marine Corps standard issue Rifle. It was known for it's rather heavy and large \
	size but good accuracy at range. But it was eventually replaced by the T-18 because of it's relatively poor performance at close range situations.<br><br>\
	The RM-51 (Corps designation T-12) is still widely used by the Corps because of the sheer amount in surplus and because it's still a rather reliable weapon in the field.<br><br>\
	The original RM-51 was designed once news of a trial for the adoption of a caseless assault rifle to replace the current aging \
	rifle were made public to all gun manufacturers, and eventually the RM-51s design won out its competitors due to its ability to stay reliable in harsh conditions."

/datum/codex_entry/standard_carbine
	associated_paths = list(/obj/item/weapon/gun/rifle/standard_carbine)
	lore_text = "The reason for the adoption of the ALF-4 carbine surfaced after repeated complaints of the unwieldiness of the T-12 \
	Rifle surfaced inside tight spaces, this then prompted the higher command of the TGMC to decide to adopt a new rifle within new barrel \
	length designations due to the rising prevalence of fighting in close quarters situations inside spaceships and some colonies.<br><br>\
	Eventually a selection process was made and the ALF-4 eventually won the trials and field testing soon ensured. Which eventually lead \
	to great feedback from the troops supplied with it. This soon lead to it replacing the T-12 Rifle as the standard issue firearm. \
	With the designation T-18. Though the T-12 itself is still used widely due to availability."

/datum/codex_entry/standard_lmg
	associated_paths = list(/obj/item/weapon/gun/rifle/standard_lmg)
	lore_text = "The ALF-8 LMG is pretty much an upsized version of the ALF-4 Carbine, the ALF-8 was created to put down heavy suppressive \
	fire in a light and compact package. It was created when the ALF-8 package was seen to be unable to perform suppressive fire roles very \
	effectively due to it’s small stature and lighter than usual barrel. So eventually the ALF-8 was created to do that role when the T-12 \
	Rifle (non-marine designation RM-51) also began to suffer under prolonged combat due to overheating and low ammo count.<br><br>\
	The ALF-8 itself is based off the ALF-4’s design. The only major differences are a heavier and longer barrel created to have a \
	large amount of rounds go threw it in short periods of time and different mag wells to accept bigger magazines than it’s little brother. \
	It was eventually adopted and designated the T-42.<br><br>\
	However these days it's been mostly replaced by the M56 smartgun system due to the M56s ability to use IFF and also self-load due to it’s \
	autoloading systems. Removing the need of an assistant to carry the bulky ammo.<br><br>\
	However, the T-42 is still used since it's much easier to use than the special training required for the smartgun system. These days it's \
	usually used when IFF isn't needed such as high visibility environments and defensive positions."

/datum/codex_entry/standard_smg
	associated_paths = list(/obj/item/weapon/gun/smg/standard_smg)
	lore_text = "The MD-65 is a rather compact gun, designed for use by specialized troops who don't have the space to carry a bigger \
	firearm and don't want to be stuck with a handgun. <br><br>\
	It's generally used inside it's belt holster or slung on your back as a secondary firearm for use in situations where you have a \
	larger gun and would prefer a more CQC able weapon. It also has a rather large magazine capacity due to the small caliber size and caseless ammunition. <br><br>\
	The MD-65 was adopted as a program to allow specialized units like medics and engineers to carry a smaller firearm to maximize \
	weight and storage capacity. However it slowly spread in popularity to light infantry and scout units. It was named T-90 upon adoption."
