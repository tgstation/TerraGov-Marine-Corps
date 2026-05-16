//items designed as weapon
/obj/item/weapon
	name = "weapon"
	icon = 'icons/obj/items/weapons/misc.dmi'
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/melee_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/melee_right.dmi',
	)
	hitsound = SFX_SWING_HIT
	var/caliber = "missing from codex" //codex
	var/load_method = null //codex, defines are below.
	var/max_shells = 0 //codex, bullets, shotgun shells TODO: KILL THESE TWO VARS
	var/max_shots = 0 //codex, energy weapons
	var/scope_zoom = FALSE//codex
	var/self_recharge = FALSE //codex
	///force level if two handed, activated etc
	var/force_activated = 0

/obj/item/weapon/melee_attack_chain(mob/user, atom/target, params, rightclick)
	if(target == user && !user.do_self_harm)
		return
	return ..()

/obj/item/weapon/get_mechanics_info()
	. = ..()
	var/list/traits = list()
	get_weapon_codex_mechanic_info(traits)

	. += jointext(traits, "<br>")

///Returns a list of codex info
///A separate proc so it can be overridden safely
/obj/item/weapon/proc/get_weapon_codex_mechanic_info(list/trait_list)
	trait_list += "This is a [(item_flags & TWOHANDED) ? "<U>two handed</U>" : "<U>one handed</U>"] weapon.<br>"
	if(force_activated > force)
		trait_list += "This weapon requires <U>activation</U> for proper use.<br>"

	trait_list += "<U>Force:</U> [force] <br>"
	if(item_flags & TWOHANDED)
		trait_list += "<U>Wielded Force:</U> [force_activated] <br>"
	else if(force_activated > force)
		trait_list += "<U>Activated Force:</U> [force_activated] <br>" //won't work for toggl, need to add a proc

	trait_list += "<U>Armour Pentetration:</U> [penetration] <br>"
	trait_list += "<U>Attack Delay:</U> [attack_speed] <br>"

	trait_list += "<U>Throw Force:</U> [throwforce] <br>"

	if(sharp && edge)
		trait_list += "This is a <U>sharp</U> and <U>edged</U> weapon.<br>"
	else if(sharp)
		trait_list += "This is a <U>sharp</U> weapon.<br>"
	else if(edge)
		trait_list += "This is an <U>edged</U> weapon.<br>"
	else
		trait_list += "This is a blunt weapon.<br>"

	trait_list += "<U>Equip slots:</U> Suit storage[equip_slot_flags & ITEM_SLOT_BELT ? ", belt slot" : ""][equip_slot_flags & ITEM_SLOT_BACK ? ", back slot" : ""].<br>"
