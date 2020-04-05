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

	var/list/entries = SScodex.retrieve_entries_for_string(general_codex_key)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.mechanics_text)
		traits += general_entry.mechanics_text

	if(flags_gun_features & GUN_WIELDED_FIRING_ONLY)
		traits += "This can only be fired with a two-handed grip."
	else
		traits += "It's best fired with a two-handed grip."


	if(flags_gun_features & GUN_TRIGGER_SAFETY)
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
		an energy weapon by placing it in a wall-mounted or table-mounted charger such as those found in Medical or around the \
		place. In addition, energy weapons, if compatible, can be recharged via energy-fed battery cells acting as magazines, \
		which can also be recharged at chargers. Most energy weapons' projectiles can go straight through windows and hit whatever \
		is on the other side, and have very fast projectiles, making them accurate and useful against distant targets. \
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
