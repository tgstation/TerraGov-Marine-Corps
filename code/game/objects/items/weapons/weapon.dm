//items designed as weapon
/obj/item/weapon
	name = "weapon"
	icon = 'icons/obj/items/weapons/misc.dmi'
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/melee_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/melee_right.dmi',
	)
	hitsound = SFX_SWING_HIT
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
	if(!(item_flags & TWOHANDED))
		trait_list += "This is a <U>one handed</U> weapon.<br>"

	trait_list += "<U>Force:</U> [force]"
	trait_list += "<U>Armour Penetration:</U> [penetration]"
	trait_list += "<U>Attack Delay:</U> [attack_speed]"
	trait_list += "<U>Throw Force:</U> [throwforce]"

	if(item_flags & TWOHANDED)
		trait_list += "<br>This is a <U>two handed</U> weapon.<br>"
		get_wielded_mechanic_info(trait_list)
	if(item_flags & ITEM_ACTIVATABLE)
		trait_list += "<br>This weapon requires <U>activation</U> for proper use.<br>"
		get_activated_codex_mechanic_info(trait_list)

	if(sharp && edge)
		trait_list += "<br>This is a <U>sharp</U> and <U>edged</U> weapon."
	else if(sharp)
		trait_list += "<br>This is a <U>sharp</U> weapon."
	else if(edge)
		trait_list += "<br>This is an <U>edged</U> weapon."
	else
		trait_list += "<br>This is a blunt weapon."

	var/list/slot_options = list("Suit storage")
	if(equip_slot_flags & ITEM_SLOT_BELT)
		slot_options += "Belt slot"
	if(equip_slot_flags & ITEM_SLOT_BACK)
		slot_options += "Back slot"
	if(w_class <= WEIGHT_CLASS_SMALL)
		slot_options += "Pocket slots"
	trait_list += "<U>Equip slots:</U> [english_list(slot_options)]<br>"

///adds codex info for wielded state
/obj/item/weapon/proc/get_wielded_mechanic_info(list/trait_list)
	trait_list += "<U>Wielded Force:</U> [force_activated]"

///Adds codex info for activated state
/obj/item/weapon/proc/get_activated_codex_mechanic_info(list/trait_list)
	trait_list += "<U>Activated Force:</U> [force_activated]"
