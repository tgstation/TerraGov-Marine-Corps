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

/obj/item/weapon/twohanded/industrial_saw/toggle_active(new_state)
	. = ..()
	if(!.)
		return
	toggle_motor()

/obj/item/weapon/twohanded/industrial_saw/equipped(mob/user, slot)
	. = ..()
	toggle_item_bump_attack(user, TRUE)

/obj/item/weapon/twohanded/industrial_saw/dropped(mob/user)
	. = ..()
	toggle_item_bump_attack(user, FALSE)
	toggle_active(FALSE)

/obj/item/weapon/twohanded/industrial_saw/wield(mob/user)
	. = ..()
	if(!.)
		return
	playsound(loc, 'sound/weapons/chainsawstart.ogg', 100, 1)
	toggle_active(FALSE)
	if(!do_after(user, SKILL_TASK_TRIVIAL, NONE, src, BUSY_ICON_DANGER, null,PROGRESS_BRASS))
		return
	toggle_active(TRUE)

/obj/item/weapon/twohanded/industrial_saw/unwield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_active(FALSE)

///Toggles the saw on or off
/obj/item/weapon/twohanded/industrial_saw/proc/toggle_motor()
	update_appearance(UPDATE_ICON)
	if(!active)
		attack_speed = initial(attack_speed)
		penetration = initial(penetration)
		hitsound = initial(hitsound)
		return

	attack_speed = 3
	penetration = 20
	playsound(loc, 'sound/weapons/chainsawhit.ogg', 100, 1)
	hitsound = 'sound/weapons/chainsawhit.ogg'
