/obj/item/weapon/twohanded
	var/force_wielded = 0
	var/wieldsound
	var/unwieldsound
	flags_item = TWOHANDED

/obj/item/weapon/twohanded/mob_can_equip(mob/user)
	unwield(user)
	return ..()


/obj/item/weapon/twohanded/dropped(mob/user)
	. = ..()
	unwield(user)


/obj/item/weapon/twohanded/pickup(mob/user)
	unwield(user)


/obj/item/proc/wield(mob/user)
	if(!(flags_item & TWOHANDED) || flags_item & WIELDED)
		return FALSE

	var/obj/item/offhand = user.get_inactive_held_item()
	if(offhand)
		if(offhand == user.r_hand)
			user.drop_r_hand()
		else if(offhand == user.l_hand)
			user.drop_l_hand()
		if(user.get_inactive_held_item()) //Failsafe; if there's somehow still something in the off-hand (undroppable), bail.
			to_chat(user, span_warning("You need your other hand to be empty!"))
			return FALSE

	if(ishuman(user))
		var/check_hand = user.r_hand == src ? "l_hand" : "r_hand"
		var/mob/living/carbon/human/wielder = user
		var/datum/limb/hand = wielder.get_limb(check_hand)
		if(!istype(hand) || !hand.is_usable())
			to_chat(user, span_warning("Your other hand can't hold [src]!"))
			return FALSE

	toggle_wielded(user, TRUE)
	SEND_SIGNAL(src, COMSIG_ITEM_WIELD, user)
	name = "[name] (Wielded)"
	update_item_state()
	place_offhand(user, name)
	return TRUE


/obj/item/proc/unwield(mob/user)
	if(!CHECK_MULTIPLE_BITFIELDS(flags_item, TWOHANDED|WIELDED))
		return FALSE

	toggle_wielded(user, FALSE)
	SEND_SIGNAL(src, COMSIG_ITEM_UNWIELD, user)
	var/sf = findtext_char(name, " (Wielded)", -10) // 10 == length(" (Wielded)")
	if(sf)
		name = copytext_char(name, 1, sf)
	else
		name = "[initial(name)]"
	update_item_state()
	remove_offhand(user)
	return TRUE


/obj/item/proc/place_offhand(mob/user, item_name)
	to_chat(user, span_notice("You grab [item_name] with both hands."))
	var/obj/item/weapon/twohanded/offhand/offhand = new /obj/item/weapon/twohanded/offhand(user)
	offhand.name = "[item_name] - offhand"
	offhand.desc = "Your second grip on the [item_name]."
	user.put_in_inactive_hand(offhand)
	user.update_inv_l_hand()
	user.update_inv_r_hand()


/obj/item/proc/remove_offhand(mob/user)
	to_chat(user, span_notice("You are now carrying [name] with one hand."))
	var/obj/item/weapon/twohanded/offhand/offhand = user.get_inactive_held_item()
	if(istype(offhand) && !QDELETED(offhand))
		qdel(offhand)
	user.update_inv_l_hand()
	user.update_inv_r_hand()


/obj/item/proc/toggle_wielded(user, new_value)
	switch(new_value)
		if(null)
			flags_item ^= WIELDED
		if(FALSE)
			flags_item &= ~WIELDED
		if(TRUE)
			flags_item |= WIELDED


/obj/item/weapon/twohanded/wield(mob/user)
	. = ..()
	if(!.)
		return

	if(wieldsound)
		playsound(user, wieldsound, 15, 1)

	force = force_wielded


/obj/item/weapon/twohanded/unwield(mob/user)
	. = ..()
	if(!.)
		return

	if(unwieldsound)
		playsound(user, unwieldsound, 15, 1)

	force = initial(force)


/obj/item/weapon/twohanded/attack_self(mob/user)
	. = ..()
	if(ismonkey(user)) //TODO MAKE THIS A SPECIES FLAG
		to_chat(user, span_warning("It's too heavy for you to wield fully!"))
		return

	if(flags_item & WIELDED)
		unwield(user)
	else
		wield(user)


///////////OFFHAND///////////////
/obj/item/weapon/twohanded/offhand
	w_class = WEIGHT_CLASS_HUGE
	icon_state = "offhand"
	name = "offhand"
	flags_item = DELONDROP|TWOHANDED|WIELDED
	resistance_flags = RESIST_ALL


/obj/item/weapon/twohanded/offhand/Destroy()
	if(ismob(loc))
		var/mob/user = loc
		var/obj/item/main_hand = user.get_active_held_item()
		if(main_hand)
			main_hand.unwield(user)
	return ..()


/obj/item/weapon/twohanded/offhand/unwield(mob/user)
	return


/obj/item/weapon/twohanded/offhand/dropped(mob/user)
	return


/obj/item/weapon/twohanded/offhand/forceMove(atom/destination)
	if(!ismob(destination))
		qdel(src)
	return ..()



/*
* Fireaxe
*/
/obj/item/weapon/twohanded/fireaxe
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	icon_state = "fireaxe"
	item_state = "fireaxe"
	force = 20
	sharp = IS_SHARP_ITEM_BIG
	edge = 1
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BELT|ITEM_SLOT_BACK
	flags_atom = CONDUCT
	flags_item = TWOHANDED
	force_wielded = 75
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")


/obj/item/weapon/twohanded/fireaxe/wield(mob/user)
	. = ..()
	if(!.)
		return
	pry_capable = IS_PRY_CAPABLE_SIMPLE


/obj/item/weapon/twohanded/fireaxe/unwield(mob/user)
	. = ..()
	if(!.)
		return
	pry_capable = 0


/*
* Double-Bladed Energy Swords - Cheridan
*/
/obj/item/weapon/twohanded/dualsaber
	name = "double-bladed energy sword"
	desc = "Handle with care."
	icon_state = "dualsaber"
	item_state = "dualsaber"
	force = 3
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	force_wielded = 150
	wieldsound = 'sound/weapons/saberon.ogg'
	unwieldsound = 'sound/weapons/saberoff.ogg'
	flags_atom = NOBLOODY
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharp = IS_SHARP_ITEM_BIG
	edge = 1


/obj/item/weapon/twohanded/dualsaber/Initialize()
	. = ..()
	AddComponent(/datum/component/shield, SHIELD_TOGGLE|SHIELD_PURE_BLOCKING)

/obj/item/weapon/twohanded/dualsaber/wield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_active(TRUE)

/obj/item/weapon/twohanded/dualsaber/unwield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_active(FALSE)


/obj/item/weapon/twohanded/spear
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	icon_state = "spearglass"
	item_state = "spearglass"
	force = 40
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BACK
	force_wielded = 75
	throwforce = 75
	throw_speed = 3
	reach = 2
	edge = 1
	sharp = IS_SHARP_ITEM_SIMPLE
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "stabbed", "jabbed", "torn", "gored")

/obj/item/weapon/twohanded/spear/tactical
	name = "M-23 spear"
	desc = "A tactical spear. Used for 'tactical' combat."
	icon_state = "spear"
	item_state = "spear"

/obj/item/weapon/twohanded/spear/tactical/harvester
	name = "\improper HP-S Harvester spear"
	desc = "TerraGov Marine Corps' experimental High Point-Singularity 'Harvester' spear. An advanced weapon that trades sheer force for the ability to apply a variety of debilitating effects when loaded with certain reagents. Activate after loading to prime a single use of an effect. It also harvests substances from alien lifeforms it strikes when connected to the Vali system."
	icon_state = "vali_spear"
	item_state = "vali_spear"
	force = 32
	force_wielded = 60
	throwforce = 60
	flags_item = DRAINS_XENO | TWOHANDED

/obj/item/weapon/twohanded/spear/tactical/harvester/Initialize()
	. = ..()
	AddComponent(/datum/component/harvester)

/obj/item/weapon/twohanded/spear/tactical/tacticool
	name = "M-23 TACTICOOL spear"
	icon = 'icons/Marine/gun64.dmi'
	desc = "A TACTICOOL spear. Used for TACTICOOLNESS in combat."

/obj/item/weapon/twohanded/spear/tactical/tacticool/Initialize()
	. = ..()
	AddComponent(/datum/component/attachment_handler, \
	list(ATTACHMENT_SLOT_RAIL, ATTACHMENT_SLOT_UNDER, ATTACHMENT_SLOT_MUZZLE), \
	list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/stock/t12stock,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/compensator,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/angledgrip,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/attachable/motiondetector,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
	), \
	attachment_offsets = list("muzzle_x" = 59, "muzzle_y" = 16, "rail_x" = 26, "rail_y" = 18, "under_x" = 40, "under_y" = 12))

/obj/item/weapon/twohanded/glaive
	name = "war glaive"
	icon_state = "glaive"
	item_state = "glaive"
	desc = "A huge, powerful blade on a metallic pole. Mysterious writing is carved into the weapon."
	force = 28
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BACK
	force_wielded = 90
	throwforce = 65
	throw_speed = 3
	edge = 1
	sharp = IS_SHARP_ITEM_BIG
	flags_atom = CONDUCT
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("sliced", "slashed", "jabbed", "torn", "gored")
	resistance_flags = UNACIDABLE
	attack_speed = 12 //Default is 7.

/obj/item/weapon/twohanded/glaive/damaged
	name = "war glaive"
	desc = "A huge, powerful blade on a metallic pole. Mysterious writing is carved into the weapon. This one is ancient and has suffered serious acid damage, making it near-useless."
	force = 18
	force_wielded = 28

/obj/item/weapon/twohanded/rocketsledge
	name = "rocket sledge"
	desc = "Fitted with a rocket booster at the head, the rocket sledge would deliver a tremendously powerful impact, easily crushing your enemies. Uses fuel to power itself. AltClick to tighten your grip."
	icon_state = "rocketsledge"
	item_state = "rocketsledge"
	force = 30
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BACK
	force_wielded = 75
	throwforce = 50
	throw_speed = 2
	edge = 1
	sharp = IS_SHARP_ITEM_BIG
	flags_atom = CONDUCT | TWOHANDED
	attack_verb = list("smashed", "hammered")
	attack_speed = 20

	///amount of fuel stored inside
	var/max_fuel = 50
	///amount of fuel used per hit
	var/fuel_used = 5
	///additional damage when weapon is active
	var/additional_damage = 75
	///stun value
	var/stun = 1
	///weaken value
	var/weaken = 2
	///knockback value
	var/knockback = 0

/obj/item/weapon/twohanded/rocketsledge/Initialize()
	. = ..()
	create_reagents(max_fuel, null, list(/datum/reagent/fuel = max_fuel))

/obj/item/weapon/twohanded/rocketsledge/equipped(mob/user, slot)
	. = ..()
	toggle_item_bump_attack(user, TRUE)

/obj/item/weapon/twohanded/rocketsledge/dropped(mob/user)
	. = ..()
	toggle_item_bump_attack(user, FALSE)

/obj/item/weapon/twohanded/rocketsledge/examine(mob/user)
	. = ..()
	. += "It contains [reagents.get_reagent_amount(/datum/reagent/fuel)]/[max_fuel] units of fuel!"

/obj/item/weapon/twohanded/rocketsledge/wield(mob/user)
	. = ..()
	if((reagents.get_reagent_amount(/datum/reagent/fuel) < fuel_used))
		playsound(loc, 'sound/items/weldingtool_off.ogg', 25)
		return
	update_icon()

/obj/item/weapon/twohanded/rocketsledge/unwield(mob/user)
	. = ..()
	update_icon()

/obj/item/weapon/twohanded/rocketsledge/update_icon_state()
	if ((reagents.get_reagent_amount(/datum/reagent/fuel) > fuel_used) && (CHECK_BITFIELD(flags_item, WIELDED)))
		icon_state = "rocketsledge_w"
	else
		icon_state = "rocketsledge"

/obj/item/weapon/twohanded/rocketsledge/afterattack(obj/target, mob/user, flag)
	if(istype(target, /obj/structure/reagent_dispensers/fueltank) && get_dist(user,target) <= 1)
		var/obj/structure/reagent_dispensers/fueltank/RS = target
		if(RS.reagents.total_volume == 0)
			to_chat(user, span_warning("Out of fuel!"))
			return ..()

		var/fuel_transfer_amount = min(RS.reagents.total_volume, (max_fuel - reagents.get_reagent_amount(/datum/reagent/fuel)))
		RS.reagents.remove_reagent(/datum/reagent/fuel, fuel_transfer_amount)
		reagents.add_reagent(/datum/reagent/fuel, fuel_transfer_amount)
		playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
		to_chat(user, span_notice("You refill [src] with fuel."))
		update_icon()

	return ..()

/obj/item/weapon/twohanded/rocketsledge/AltClick(mob/user)
	if(!can_interact(user) || !ishuman(user) || !(user.l_hand == src || user.r_hand == src))
		return ..()
	TOGGLE_BITFIELD(flags_item, NODROP)
	if(CHECK_BITFIELD(flags_item, NODROP))
		to_chat(user, span_warning("You tighten the grip around [src]!"))
		return
	to_chat(user, span_notice("You loosen the grip around [src]!"))

/obj/item/weapon/twohanded/rocketsledge/unique_action(mob/user)
	. = ..()
	if (knockback)
		stun = 1
		weaken = 2
		knockback = 0
		balloon_alert(user, "Selected mode: CRUSH.")
		playsound(loc, 'sound/machines/switch.ogg', 25)
		return

	stun = 1
	weaken = 1
	knockback = 1
	balloon_alert(user, "Selected mode: KNOCKBACK.")
	playsound(loc, 'sound/machines/switch.ogg', 25)

/obj/item/weapon/twohanded/rocketsledge/attack(mob/living/carbon/M, mob/living/carbon/user as mob)
	if(!CHECK_BITFIELD(flags_item, WIELDED))
		to_chat(user, span_warning("You need a more secure grip to use [src]!"))
		return

	if(M.status_flags & INCORPOREAL || user.status_flags & INCORPOREAL)
		return

	if(reagents.get_reagent_amount(/datum/reagent/fuel) < fuel_used)
		to_chat(user, span_warning("\The [src] doesn't have enough fuel!"))
		return ..()

	M.apply_damage(max(0, additional_damage - additional_damage*M.hard_armor.getRating("melee")), BRUTE, user.zone_selected, M.get_soft_armor("melee", user.zone_selected))
	M.visible_message(span_danger("[user]'s rocket sledge hits [M.name], smashing them!"), span_userdanger("You [user]'s rocket sledge smashes you!"))

	if(reagents.get_reagent_amount(/datum/reagent/fuel) < fuel_used * 2)
		playsound(loc, 'sound/items/weldingtool_off.ogg', 50)
		to_chat(user, span_warning("\The [src] shuts off, using last bits of fuel!"))
		update_icon()
	else
		playsound(loc, 'sound/weapons/rocket_sledge.ogg', 50, TRUE)

	reagents.remove_reagent(/datum/reagent/fuel, fuel_used)

	if(knockback)
		var/atom/throw_target = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
		var/throw_distance = knockback * LERP(5 , 2, M.mob_size / MOB_SIZE_BIG)
		M.throw_at(throw_target, throw_distance, 0.5 + (knockback * 0.5))

	if(isxeno(M))
		var/mob/living/carbon/xenomorph/xeno_victim = M
		if(xeno_victim.fortify || xeno_victim.endure) //If we're fortified or use endure we don't give a shit about staggerstun.
			return

		if(xeno_victim.crest_defense) //Crest defense protects us from the stun.
			stun = 0
		else
			stun = 1

	if(!M.IsStun() && !M.IsParalyzed() && !isxenoqueen(M)) //Prevent chain stunning. Queen is protected.
		M.apply_effects(stun,weaken)

	return ..()
