/obj/item/weapon/gun/get_antag_info()
	var/list/entries = SScodex.retrieve_entries_for_string(general_codex_key)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry?.antag_text)
		return general_entry.antag_text

/obj/item/weapon/gun/get_lore_info()
	var/list/entries = SScodex.retrieve_entries_for_string(general_codex_key)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry?.lore_text)
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
		traits += "Scatter angle: [scatter]"
	if(burst_scatter_mult)
		traits += "Burst scatter angle multiplier: x[burst_scatter_mult]"
	if(accuracy_mult_unwielded)
		traits += "Accuracy unwielded modifier: [((accuracy_mult_unwielded - 1) * 100) > 0 ? "+[(accuracy_mult_unwielded - 1) * 100]" : "[(accuracy_mult_unwielded - 1) * 100]"]%"
	if(recoil_unwielded)
		traits += "Recoil Unwielded: [recoil_unwielded]"
	if(scatter_unwielded)
		traits += "Unwielded Scatter angle: [scatter_unwielded > 0 ? "+[scatter_unwielded]" : "[scatter_unwielded]"]"
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
	if(general_entry?.mechanics_text)
		traits += general_entry.mechanics_text

	. += jointext(traits, "<br>")

/obj/item/weapon/gun/energy/get_mechanics_info()
	. = ..()
	var/list/traits = list()

	if(self_recharge)
		traits += "It recharges itself over time."

	. += jointext(traits, "<br>")

/obj/item/weapon/gun/energy/lasgun/lasrifle/get_mechanics_info()
	. = ..()
	if(!mode_list)
		return

	var/list/fire_modes = list()
	fire_modes += "<br><U>Fire modes</U>:<br>"

	for(var/num AS in mode_list)
		var/datum/lasrifle/mode = mode_list[num]
		fire_modes += "<U>[num]</U>: [initial(mode.description)]"

	. += jointext(fire_modes, "<br>")

/obj/item/weapon/gun/shotgun/pump/get_mechanics_info()
	. = ..()
	if(gun_skill_category == SKILL_RIFLES)
		. += "<br><br>To work the weapon press spacebar.<br>"
	else
		. += "<br><br>To pump it press spacebar.<br>"

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

/datum/codex_entry/plasma_weapons
	display_name = "plasma weapons"
	mechanics_text = "This weapon is a plasma weapon; it fires bursts of superheated gas that have been ionized and electrically charged. You can \
		unload it by holding it and clicking it with an empty hand, and reload it by clicking it with a power cell or a plasma cartridge, depending on the model of \
		the weapon. \
		<br>"
	lore_text = "Plasma weapons are rare and powerful due to the high cost and difficulty of producing and controlling plasma \
		pulses. They have a devastating effect on most targets, as the plasma can melt, burn, or vaporize them. Using a plasma weapon in a confined space is very risky, \
		as the plasma can damage the surroundings or harm friendly units with its intense heat and radiation."

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
	Though high unit cost didn't allow it to be more widely adopted it was eventually decided that it would meet limited adoption for Marksmen and be designated the SR-26."

/datum/codex_entry/battle_rifle
	associated_paths = list(/obj/item/weapon/gun/rifle/tx8)
	lore_text = "The M45A was born from a commission order from the TGMC to the company which made the M42A and M56 smartgun systems. <br><br>\
	The reason for this commission order resulted from complaints from light infantry and scout units about the poor accuracy of the new SR-26 \
	carbine at longer ranges and the large size of the SG-29 making close combat uncomfortable eventually reached the higher ups, who kept getting \
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
	After field-testing good reports from troops eventually, leading to its full adoption with the naming of \"RL-152\". <br><br>\
	It's a rather rare sight due to the current doctrine adopted by the TGMC not using heavy explosives often, so it's a rather \
	rare sight outside of specialized users. and the rising prevalence of shipside combat making it dangerous to fire inside those \
	spaces makes it even used less. Not that it makes it any less dangerous on an open field."

/datum/codex_entry/standard_shotgun
	associated_paths = list(/obj/item/weapon/gun/shotgun/pump/t35)
	lore_text = "The K23 itself was designed at first for military use as 12 gauge pump-action shotguns were starting to pick up steam \
	again due to advancements in ammunition made them much more effective at breaking doors and simple masterkey shotguns were starting \
	to fall out of favor due to the preference of grenade launchers or other grips started to phase them out. <br><br>\
	Eventually trials were made for a new shotgun and the K23 eventually won them out and was adopted as the SH-35. It was \
	officially adopted as a door breaching tool but was incredibly effective at close quarters and shipside combat because \
	advancements in  ammunition allowed shotguns to punch through common ballistic armor, making it a popular option for close quarters situations."

/datum/codex_entry/standard_revolver
	associated_paths = list(/obj/item/weapon/gun/revolver/standard_revolver)
	lore_text = "The original RN-44 used to be the only standard issue sidearm of the TGMC. Though it was once going to \
	be fully replaced by the MG-27 once that was adopted, it was eventually decided to be kept due to complaints from \
	troops of the power and accuracy of the new 9mm pistol to the old .44 so it was decided to keep both handguns and \
	allow a choice between both. Then soon after a modernization came to the old RN-44 design. Eventually being updated to the R-44.<br><br>\
	The original RN-44 design that was adopted quite some time ago by the Marine Corps as part of a new program asking for \
	a new sidearm that could be reliable on long voyages without much maintenance and the RN-44 eventually won out it's peers \
	due to its good accuracy and ability to stay in good condition for long periods of time. Eventually ending up as the original R-44."

/datum/codex_entry/standard_pistol
	associated_paths = list(/obj/item/weapon/gun/pistol/standard_pistol)
	lore_text = "The RL-9's design was created to require as little maintenance for a Pistol in a long period of time in-order \
	to compete during the new trials to be put up by the Marine Corps once they decided the R-44 Revolver was too cumbersome for normal use. <br><br>\
	Eventually the RL-9 won the trials due to showing good use after passing the 300 round test in the final rounds of the trial with only a \
	single misfire during the entire 1000 round firing.<br><br>\
	After the trials the gun was slated to fully replace the R-44 as the TP-19 Pistol.<br><br>\
	But certain troops complained that the MG-27 couldn't be as accurate out to further ranges and the power of the .44 round was more worthwhile \
	to them than the 9mm round. Eventually it was decided that the TP019 would be adopted as the second sidearm of the TGMC instead of fully \
	replacing the R-44 which would later eventually be modernized."

/datum/codex_entry/standard_assaultrifle
	associated_paths = list(/obj/item/weapon/gun/rifle/standard_assaultrifle)
	lore_text = "The Keckler and Hoch M-12 was created out of an order for a robust rifle using a caseless round, after the ergonomic and costly disaster of the 'Rifle of the future' Project. \
	Ironically, the M-12 submitted by the very group that made the national disaster that the AR-11 (originally designated the M-11) ended up winning out all the tests. \
	It was designed to be simple to use, disassemble and basically survive every condition, however due to reports of barrel melting from the high use of polymers. It ended up being heavier than its ilk to compensate.\
	After wining all the tests, it was accepted and christened the 'AR-12' in service. Aside from issues with barrel overheating, which later models fixed. It is known for reliability across the Marine Corps and the wider galaxy.\
	Most would say the simple blend of a good magazine size, ergonomics and adaptablitty elevate this weapon above the rest."

/datum/codex_entry/standard_carbine
	associated_paths = list(/obj/item/weapon/gun/rifle/standard_carbine)
	lore_text = "The Kauser ALF series of firearms was born out of a desire to create a modular weapon design that could ergonomically use a similar manual of arms to appeal to simplify familiarity and attract large scale buyers.\
	The Carbine variant, known as the 'ALF-51' focused on creating a small, compact package that could fire a rifle-sized round while still retaining good accuracy and shot placement.\
	Originally, it was meant to fire in burst-fire only, future production variants turned to feature full-auto after it showed that in testing, it would improve troop morale and confidence in the versatility in the rifle.\
	The entire ALF-series ended up being panic bought in mass by specialized troops in the Marine Corps, generally Peacekeeper sections or Air Assault sections, it eventually spread by osmosis in popularity.\
	Eventually, they ended up becoming standard issue and a formal contract was signed, the Carbine was christened the 'AR-18'.\
	Most would say its particularly compact appreance and performance, combined with good burst-fire capablity are its edge in combat. Watch your ammo, though."

/datum/codex_entry/standard_lmg
	associated_paths = list(/obj/item/weapon/gun/rifle/standard_lmg)
	lore_text = "The Kauser ALF series of firearms was born out of a desire to create a modular weapon design that could ergonomically use a similar manual of arms to appeal to simplify familiarity and attract large scale buyers.\
	The Machinegun variant, known as the 'ALF-22' focused on creating a versatile package consisting of a light squad support weapon, with a focus on mobility and accurate fire over pure magazine size.\
	It ended up with a drum magazine, elongated heavy barrel for sustained firing, its overall shape being of a common rifle generally assists it in being easy to pickup and use, and can mount more underbarrel attachments compared to its peers in its class.\
	The entire ALF-series ended up being panic bought in mass by specialized troops in the Marine Corps, generally Peacekeeper sections or Air Assault sections, it eventually spread by osmosis in popularity.\
	Eventually, they ended up becoming standard issue and a formal contract was signed, the Machinegun was christened the 'MG-42'.\
	Most would say the large magazine capacity combined with ease of use and ability to lay down fire with good frontline potential is the main advantage of this weapon. You will still be one the slower people in your group, however."

/datum/codex_entry/standard_skirmishrifle
	associated_paths = list(/obj/item/weapon/gun/rifle/standard_skirmishrifle)
	lore_text = "The Kauser ALF series of firearms was born out of a desire to create a modular weapon design that could ergonomically use a similar manual of arms to appeal to simplify familiarity and attract large scale buyers.\
	The 'Skirmish' Rifle variant, known as the 'ALF-6' focused on creating a fullpower rifle, light and with a good blend of mobility, firerate and firepower.\
	The rifle ended up being the rifle to truly kick off the ALF series, becoming famous for being a great blend of firepower, mobility and ease of use, however the system was known for tearing rounds like it was nothing.\
	The entire ALF-series ended up being panic bought in mass by specialized troops in the Marine Corps, generally Peacekeeper sections or Air Assault sections, it eventually spread by osmosis in popularity.\
	Eventually, they ended up becoming standard issue and a formal contract was signed, the Rifle was christened the 'AR-21'.\
	Most would say it earned its term of a 'Skirmish' rifle due to use in constant skirmishes by frontline troops, due to a low magazine size, but good overall mobility combined with firepower. Watch your magazine count and put the hurt downrange."

/datum/codex_entry/standard_tx11
	associated_paths = list(/obj/item/weapon/gun/rifle/tx11)
	lore_text = "The Keckler and Hoch 'M-11' was created out of a infamous bid called the 'Rifle of the future' project, created out of a need to replace aging weapon stocks in the TerraGov arsenal. \
	The M-11 was created to be the ultimate weapon, being able to lay down fire like an MG with a high capacity, amazing burst fire capability, specialized scope for long range damage, it was tested and destroyed the competition.\
	It did amazing in field tests, and was effectively the best rifle overall. Most concerns were ergonomical, however it was pushed aside for a need of a new rifle, and money was already spent in making the entire thing, so getting a new competition would be too bothersome.\
	Eventually however, these ergonomic failures lead to constant troop complaints due to the unergonomic nature of the rifle, troops who swore by it loved it, troops who hated it called it a useless brick.\
	Eventually pushback got so large that a new bid was quickly placed within less than a decade, and the M-11, by now christened the 'AR-11', was considered a failure and mothballed.\
	However, some have been pulled out of long term storage, and recent spottings have shown modernizations such as removal of the side magazines, an overall more ergonomic shape with less brick-like features, and a larger magazine.\
	Most would say that the unusually large magazine capacity, amazing burst fire capability allows for an interesting use of a support weapon. But its bulky and unusual shape leading a low amount of attachments can hamper it in combat."

/datum/codex_entry/standard_autosniper
	associated_paths = list(/obj/item/weapon/gun/rifle/standard_autosniper)
	lore_text = "The Kauser ALF series of firearms was born out of a desire to create a modular weapon design that could ergonomically use a similar manual of arms to appeal to simplify familiarity and attract large scale buyers.\
	The Sniper variant, known as the 'ALF-1' focused on creating a long range marksman rifle, focused on combining both mobility and rate of fire with good overall firepower.\
	This particular version of the rifle is modernized with a KTLD gun computer and vision scope to allow for quick IFF in hectic engagements, and corrections for the user to stop FF, unlike older variants, it requires no specialized training to use.\
	The ALF-1 is basically a rifle with a heavier and longer barrel and a irremoveable scope, which sacrifices many of the traditional sniper elements for the normal familiarity of a normal everyday rifle, it is far less common than its peers in its family.\
	The entire ALF-series ended up being panic bought in mass by specialized troops in the Marine Corps, generally Peacekeeper sections or Air Assault sections, it eventually spread by osmosis in popularity.\
	Eventually, they ended up becoming standard issue and a formal contract was signed, the Sniper was christened the 'GL-81'.\
	Most would say that this rifle blends a feature of a normal rifle and sniper rifle, and has the ups and downs of both. Watch out in close quarters, and use the IFF and NVG features of the scope to your advantage..."

/datum/codex_entry/standard_smartmachinegun
	associated_paths = list(/obj/item/weapon/gun/rifle/standard_smartmachinegun)
	lore_text = "The Raummetall 'M-29' was made out of the heavy and unruly corpse of the 'M-28', an attempt to modernize and integrate a KTLD into the M-27 model machinegun. It ended in failure due to the overcomplexity of the system, and cost eventually made the project die.\
	The 'M-29' is effectively a continuation in spirit of the previous project, focusing on simplifying the IFF computer systems. It only bears a outer resemblance to the M-27, outside of having the same basic systems.\
	It has specialized systems to self-stabilize, and is made to be shoulder mounted and fired, as well as fired from lower positions, and uses its integral KTLD computer to self correct user errors, it however requires specialized training to use.\
	The 'M-29' is effectively a incredibly accurate machinegun, it ended up being offered to the Marine Corps after the previous attempt to just modernize the older machineguns failed. It ended up being christened the 'MG-28' and entered service.\
	Most would say that this machinegun makes you a walking turret, you'll be slow and unwieldy with no match when it comes to fire suppression on the move."

/datum/codex_entry/standard_smartmmg
	associated_paths = list(/obj/item/weapon/gun/rifle/standard_gpmg)
	lore_text = "The Raummetall 'M-60' was designed out of a bid for a cheap and available machinegun that could move to several roles, be it fire support, vehicle mounted or sentry duties.\
	It is basically a General Purpose Machinegun (GPMG), meant to be used in about every scenario, usually not as well as a specialized gun, however it ended up being well known for its lightness and mobility within its class.\
	Eventually, it won the bid due to its light weight, and low cost for mass production. Despite arguably being worse than most of the competition everywhere else outside of firerate. It was christened the 'MG-28' and entered service.\
	Most would say that this machinegun makes you a walking dispenser of lead, you'll be slow and unwieldy with no match when it come to emptying a rain of lead on foe... or friend."


/datum/codex_entry/standard_smg
	associated_paths = list(/obj/item/weapon/gun/smg/standard_smg)
	lore_text = "The MD-65 is a rather compact gun, designed for use by specialized troops who don't have the space to carry a bigger \
	firearm and don't want to be stuck with a handgun. <br><br>\
	It's generally used inside it's belt holster or slung on your back as a secondary firearm for use in situations where you have a \
	larger gun and would prefer a more CQC able weapon. It also has a rather large magazine capacity due to the small caliber size and caseless ammunition. <br><br>\
	The MD-65 was adopted as a program to allow specialized units like medics and engineers to carry a smaller firearm to maximize \
	weight and storage capacity. However it slowly spread in popularity to light infantry and scout units. It was named SMG-90 upon adoption."
