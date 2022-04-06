/obj/item/weapon/shield
	name = "shield"

/obj/item/weapon/shield/Initialize()
	. = ..()
	set_shield()

/obj/item/weapon/shield/proc/set_shield()
	AddComponent(/datum/component/shield, SHIELD_PARENT_INTEGRITY)

/obj/item/weapon/shield/riot
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "riot"
	max_integrity = 200
	flags_item = IMPEDE_JETPACK
	flags_equip_slot = ITEM_SLOT_BACK
	force = 5
	throwforce = 5
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	materials = list(/datum/material/metal = 1000)
	attack_verb = list("shoved", "bashed")
	soft_armor = list("melee" = 40, "bullet" = 20, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 0, "acid" = 0)
	hard_armor = list("melee" = 5, "bullet" = 5, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	hit_sound = 'sound/effects/grillehit.ogg'
	destroy_sound = 'sound/effects/glassbr3.ogg'
	var/cooldown = 0 //shield bash cooldown. based on world.time

/obj/item/weapon/shield/riot/metal
	icon_state = "riot_metal"

/obj/item/weapon/shield/riot/examine(mob/user, distance, infix, suffix)
	. = ..()
	var/health_status = (obj_integrity * 100) / (max_integrity-integrity_failure)
	if(integrity_failure && obj_integrity <= integrity_failure)
		. += span_notice("It's broken, it won't protect anymore.")
		return
	switch(health_status)
		if(0 to 20)
			. += span_notice("It's falling appart, will not be able to withstand much further damage.")
		if(20 to 40)
			. += span_notice("It has cracked edges and dents.")
		if(40 to 60)
			. += span_notice("It appears damaged, but still sturdy.")
		if(60 to 80)
			. += span_notice("It appears in decent condition, with some damage marks.")
		if(80 to 100)
			. += span_notice("It appears in perfect condition.")

/obj/item/weapon/shield/riot/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/metal_sheets = I
		if(obj_integrity > (max_integrity - integrity_failure) * 0.2)
			return

		if(metal_sheets.get_amount() < 1)
			to_chat(user, span_warning("You need one metal sheet to repair the base of [src]."))
			return

		visible_message(span_notice("[user] begins to repair the base of [src]."))

		if(!do_after(user, 2 SECONDS, TRUE, src, BUSY_ICON_FRIENDLY) || obj_integrity >= max_integrity)
			return

		if(!metal_sheets.use(1))
			return

		repair_damage(max_integrity * 0.2)
		visible_message(span_notice("[user] repairs the base of [src]."))


/obj/item/weapon/shield/riot/welder_act(mob/living/user, obj/item/I)
	if(user.do_actions)
		return FALSE

	var/obj/item/tool/weldingtool/WT = I

	if(!WT.isOn())
		return FALSE

	if(current_acid)
		to_chat(user, "<span class='warning'>You can't get near that, it's melting!<span>")
		return TRUE

	if(obj_integrity <= (max_integrity - integrity_failure) * 0.2)
		to_chat(user, span_warning("[src] has sustained too much structural damage and needs more metal plates to be repaired."))
		return TRUE

	if(obj_integrity == max_integrity)
		to_chat(user, span_warning("[src] doesn't need repairs."))
		return TRUE

	if(user.skills.getRating("engineer") < SKILL_ENGINEER_METAL)
		user.visible_message(span_notice("[user] fumbles around figuring out how to repair [src]."),
		span_notice("You fumble around figuring out how to repair [src]."))
		var/fumbling_time = 3 SECONDS * ( SKILL_ENGINEER_METAL - user.skills.getRating("engineer") )
		if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_BUILD))
			return TRUE

	user.visible_message(span_notice("[user] begins repairing damage to [src]."),
	span_notice("You begin repairing the damage to [src]."))
	playsound(loc, 'sound/items/welder2.ogg', 25, TRUE)

	if(!do_after(user, 3 SECONDS, TRUE, src, BUSY_ICON_FRIENDLY))
		return TRUE

	if(obj_integrity <= (max_integrity - integrity_failure) * 0.2 || obj_integrity == max_integrity)
		return TRUE

	if(!WT.remove_fuel(2, user))
		to_chat(user, span_warning("Not enough fuel to finish the task."))
		return TRUE

	user.visible_message(span_notice("[user] repairs some damage on [src]."),
	span_notice("You repair [src]."))
	repair_damage(40)
	update_icon()
	playsound(loc, 'sound/items/welder2.ogg', 25, TRUE)
	return TRUE

/obj/item/weapon/shield/riot/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/baton) && world.time >= cooldown)
		user.visible_message(span_warning("[user] bashes [src] with [I]!"))
		playsound(user.loc, 'sound/effects/shieldbash.ogg', 25, 1)
		cooldown = world.time + 2.5 SECONDS
		return TRUE
	return ..()

/obj/item/weapon/shield/riot/marine
	name = "\improper TL-172 defensive shield"
	desc = "A heavy shield adept at blocking blunt or sharp objects from connecting with the shield wielder. Looks very robust. Alt click to tighten the strap."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "marine_shield"
	flags_equip_slot = ITEM_SLOT_BACK
	max_integrity = 400
	integrity_failure = 100
	soft_armor = list("melee" = 50, "bullet" = 50, "laser" = 0, "energy" = 100, "bomb" = 15, "bio" = 50, "rad" = 0, "fire" = 0, "acid" = 35)
	hard_armor = list("melee" = 0, "bullet" = 5, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	force = 20
	slowdown = 0.5


/obj/item/weapon/shield/riot/marine/update_icon_state()
	if(obj_integrity <= integrity_failure)
		icon_state = initial(icon_state) + "_broken"
	else
		icon_state = initial(icon_state)


	if(!isliving(loc))
		return
	var/mob/living/holder = loc
	if(holder.l_hand == src)
		holder.update_inv_l_hand()
		return
	if(holder.r_hand == src)
		holder.update_inv_r_hand()
		return
	holder.update_inv_back()

/obj/item/weapon/shield/riot/marine/AltClick(mob/user)
	if(!can_interact(user))
		return ..()
	if(!ishuman(user))
		return ..()
	if(!(user.l_hand == src || user.r_hand == src))
		return ..()
	TOGGLE_BITFIELD(flags_item, NODROP)
	if(CHECK_BITFIELD(flags_item, NODROP))
		to_chat(user, span_warning("You tighten the strap of [src] around your hand!"))
	else
		to_chat(user, span_notice("You loosen the strap of [src] around your hand!"))

/obj/item/weapon/shield/energy
	name = "energy combat shield"
	desc = "A shield capable of stopping most projectile and melee attacks. It can be retracted, expanded, and stored anywhere."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "eshield0" // eshield1 for expanded
	flags_atom = CONDUCT|NOBLOODY
	force = 3
	throwforce = 5.0
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("shoved", "bashed")
	var/on_force = 10

/obj/item/weapon/shield/energy/set_shield()
	AddComponent(/datum/component/shield, SHIELD_TOGGLE|SHIELD_PURE_BLOCKING)

/obj/item/weapon/shield/energy/attack_self(mob/living/user)
	toggle_active()
	icon_state = "eshield[active]"
	if(active)
		force = on_force
		w_class = WEIGHT_CLASS_BULKY
		playsound(user, 'sound/weapons/saberon.ogg', 25, TRUE)
		to_chat(user, span_notice("[src] is now active."))
	else
		force = initial(force)
		w_class = WEIGHT_CLASS_TINY
		playsound(user, 'sound/weapons/saberoff.ogg', 25, TRUE)
		to_chat(user, span_notice("[src] can now be concealed."))
	add_fingerprint(user, "turned [active ? "on" : "off"]")
