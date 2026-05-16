/obj/item/weapon/twohanded/industrial_saw
	name = "concrete saw"
	desc = "A massive two handed industrial cutting tool. It can cut through pretty much anything."
	icon_state = "auto_axe_off"
	worn_icon_state = "auto_axe_off"
	base_icon_state = "auto_axe"
	attack_verb = list("gores", "tears", "rips", "shreds", "slashes", "cuts")
	force = 20
	force_activated = 40
	penetration = 0
	throwforce = 40
	attack_speed = 18
	equip_slot_flags = ITEM_SLOT_BACK
	item_flags = parent_type::item_flags|ITEM_ACTIVATABLE
	///Attack speed when active
	var/active_attack_speed = 3
	///Penetration when active
	var/active_penetration = 20

/obj/item/weapon/twohanded/industrial_saw/update_icon(updates)
	. = ..()
	update_item_state()

/obj/item/weapon/twohanded/industrial_saw/update_icon_state()
	if(active)
		icon_state = "[base_icon_state]_on"
	else
		icon_state = "[base_icon_state]_off"

/obj/item/weapon/twohanded/industrial_saw/update_item_state(mob/user)
	if(active)
		worn_icon_state = "[base_icon_state]_on"
	else
		worn_icon_state = "[base_icon_state]_off"

/obj/item/weapon/twohanded/industrial_saw/equipped(mob/user, slot)
	. = ..()
	toggle_item_bump_attack(user, TRUE)

/obj/item/weapon/twohanded/industrial_saw/dropped(mob/user)
	. = ..()
	toggle_item_bump_attack(user, FALSE)
	toggle_active(FALSE)

/obj/item/weapon/twohanded/industrial_saw/toggle_wielded(mob/user, wielded)
	. = ..()
	if(wielded) //being activatable means attack_self already triggers it
		return
	toggle_active(wielded, user)

/obj/item/weapon/twohanded/industrial_saw/unique_action(mob/user)
	toggle_active(TRUE, user)

/obj/item/weapon/twohanded/industrial_saw/toggle_active(new_state, mob/user) //update all instances of this
	. = ..()
	if(!.)
		return
	if(!active)
		toggle_motor(user)
		return
	try_start(user)

///Ttries to start the engine
/obj/item/weapon/twohanded/industrial_saw/proc/try_start(mob/user)
	if(!(item_flags & WIELDED))
		toggle_active(FALSE, user)
		return
	playsound(loc, 'sound/weapons/chainsawstart.ogg', 100, 1)
	if(!do_after(user, SKILL_TASK_TRIVIAL, NONE, src, BUSY_ICON_DANGER, null,PROGRESS_BRASS) || !(item_flags & WIELDED))
		toggle_active(FALSE, user)
		return
	toggle_motor(user)

///Actually turns the motor on or off
/obj/item/weapon/twohanded/industrial_saw/proc/toggle_motor(mob/user)
	if(active)
		attack_speed = active_attack_speed
		penetration = active_penetration
		playsound(loc, 'sound/weapons/chainsawhit.ogg', 100, 1)
		hitsound = 'sound/weapons/chainsawhit.ogg'
	else
		attack_speed = initial(attack_speed)
		penetration = initial(penetration)
		hitsound = initial(hitsound)

	update_appearance(UPDATE_ICON)
	user.update_inv_l_hand()
	user.update_inv_r_hand()

/obj/item/weapon/twohanded/industrial_saw/get_activated_codex_mechanic_info(list/trait_list)
	trait_list += "<U>Activated Attack speed:</U> [active_attack_speed] <br>"
	trait_list += "<U>Activated Penetration:</U> [active_penetration] <br>"
