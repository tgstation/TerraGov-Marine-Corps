/obj/item/weapon/twohanded
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/twohanded_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/twohanded_right.dmi',
	)
	var/force_wielded = 0
	var/wieldsound
	var/unwieldsound
	flags_item = TWOHANDED

/obj/item/weapon/twohanded/mob_can_equip(mob/user, slot, warning = TRUE, override_nodrop = FALSE, bitslot = FALSE)
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

	if(!place_offhand(user))
		to_chat(user, span_warning("You cannot wield [src] right now."))
		return FALSE

	toggle_wielded(user, TRUE)
	SEND_SIGNAL(src, COMSIG_ITEM_WIELD, user)
	name = "[name] (Wielded)"
	update_item_state()
	user.update_inv_l_hand()
	user.update_inv_r_hand()
	return TRUE


/obj/item/proc/unwield(mob/user)
	if(!CHECK_MULTIPLE_BITFIELDS(flags_item, TWOHANDED|WIELDED))
		return FALSE

	toggle_wielded(user, FALSE)
	SEND_SIGNAL(src, COMSIG_ITEM_UNWIELD, user)
	var/sf = findtext(name, " (Wielded)", -10) // 10 == length(" (Wielded)")
	if(sf)
		name = copytext(name, 1, sf)
	else
		name = "[initial(name)]"
	update_item_state()
	remove_offhand(user)
	return TRUE


/obj/item/proc/place_offhand(mob/user)
	var/obj/item/weapon/twohanded/offhand/offhand = new /obj/item/weapon/twohanded/offhand(user)
	if(!user.put_in_inactive_hand(offhand))
		qdel(offhand)
		return FALSE
	to_chat(user, span_notice("You grab [src] with both hands."))
	offhand.name = "[name] - offhand"
	offhand.desc = "Your second grip on [src]."
	return TRUE

/obj/item/proc/remove_offhand(mob/user)
	to_chat(user, span_notice("You are now carrying [src] with one hand."))
	var/obj/item/weapon/twohanded/offhand/offhand = user.get_inactive_held_item()
	if(istype(offhand) && !QDELETED(offhand))
		qdel(offhand)
	user.update_inv_l_hand()
	user.update_inv_r_hand()


/obj/item/proc/toggle_wielded(user, wielded)
	if(wielded)
		flags_item |= WIELDED
	else
		flags_item &= ~WIELDED

/obj/item/weapon/twohanded/wield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_active(TRUE)

	if(wieldsound)
		playsound(user, wieldsound, 15, 1)

	force = force_wielded


/obj/item/weapon/twohanded/unwield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_active(FALSE)

	if(unwieldsound)
		playsound(user, unwieldsound, 15, 1)

	force = initial(force)

// TODO port tg wielding component
/obj/item/weapon/twohanded/attack_self(mob/user)
	. = ..()

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
	. = ..()
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
	edge = TRUE
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

/obj/item/weapon/twohanded/fireaxe/som
	name = "boarding axe"
	desc = "A SOM boarding axe, effective at breaching doors as well as skulls. When wielded it can be used to block as well as attack."
	icon = 'icons/obj/items/weapons64.dmi'
	icon_state = "som_axe"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/weapon64_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/weapon64_right.dmi',
	)
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	item_state = "som_axe"
	force = 40
	force_wielded = 80
	penetration = 35
	flags_equip_slot = ITEM_SLOT_BACK
	attack_speed = 15

/obj/item/weapon/twohanded/fireaxe/som/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shield, SHIELD_TOGGLE|SHIELD_PURE_BLOCKING, shield_cover = list(MELEE = 45, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0))
	AddComponent(/datum/component/stun_mitigation, SHIELD_TOGGLE, shield_cover = list(MELEE = 60, BULLET = 60, LASER = 60, ENERGY = 60, BOMB = 60, BIO = 60, FIRE = 60, ACID = 60))
	AddElement(/datum/element/strappable)

/obj/item/weapon/twohanded/fireaxe/som/wield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_item_bump_attack(user, TRUE)

/obj/item/weapon/twohanded/fireaxe/som/unwield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_item_bump_attack(user, FALSE)

/*
* Double-Bladed Energy Swords - Cheridan
*/
/obj/item/weapon/twohanded/dualsaber
	name = "double-bladed energy sword"
	desc = "Handle with care."
	icon_state = "dualsaber"
	item_state = "dualsaber"
	force = 3
	throwforce = 5
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


/obj/item/weapon/twohanded/dualsaber/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shield, SHIELD_TOGGLE|SHIELD_PURE_BLOCKING)

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
	///Based on what direction the tip of the spear is pointed at in the sprite; maybe someone makes a spear that points northwest
	var/current_angle = 45

/obj/item/weapon/twohanded/spear/throw_at(atom/target, range, speed, thrower, spin, flying = FALSE, targetted_throw = TRUE)
	spin = FALSE
	//Find the angle the spear is to be thrown at, then rotate it based on that angle
	var/rotation_value = Get_Angle(thrower, get_turf(target)) - current_angle
	current_angle += rotation_value
	var/matrix/rotate_me = matrix()
	rotate_me.Turn(rotation_value)
	transform = rotate_me
	return ..()

/obj/item/weapon/twohanded/spear/pickup(mob/user)
	. = ..()
	if(initial(current_angle) == current_angle)
		return
	//Reset the angle of the spear when picked up off the ground so it doesn't stay lopsided
	var/matrix/rotate_me = matrix()
	rotate_me.Turn(initial(current_angle) - current_angle)
	//Rotate the object in the opposite direction because for some unfathomable reason, the above Turn() is applied twice; it just works
	rotate_me.Turn(-(initial(current_angle) - current_angle))
	transform = rotate_me
	current_angle = initial(current_angle)	//Reset the angle

/obj/item/weapon/twohanded/spear/tactical
	name = "M-23 spear"
	desc = "A tactical spear. Used for 'tactical' combat."
	icon_state = "spear"
	item_state = "spear"

/obj/item/weapon/twohanded/spear/tactical/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/strappable)

/obj/item/weapon/twohanded/spear/tactical/tacticool
	name = "M-23 TACTICOOL spear"
	icon = 'icons/Marine/gun64.dmi'
	desc = "A TACTICOOL spear. Used for TACTICOOLNESS in combat."

/obj/item/weapon/twohanded/spear/tactical/tacticool/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/attachment_handler, \
	list(ATTACHMENT_SLOT_RAIL, ATTACHMENT_SLOT_UNDER, ATTACHMENT_SLOT_MUZZLE), \
	list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
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
	desc = "Fitted with a rocket booster at the head, the rocket sledge would deliver a tremendously powerful impact, easily crushing your enemies. Uses fuel to power itself. Press AltClick to tighten your grip. Press Spacebar to change modes."
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
	///stun value in crush mode
	var/crush_stun_amount = 2 SECONDS
	///weaken value in crush mode
	var/crush_weaken_amount = 4 SECONDS
	///stun value in knockback mode
	var/knockback_stun_amount = 2 SECONDS
	///weaken value in knockback mode
	var/knockback_weaken_amount = 2 SECONDS
	///stun value
	var/stun
	///weaken value
	var/weaken
	///knockback value; 0 = crush mode, 1 = knockback mode
	var/knockback

/obj/item/weapon/twohanded/rocketsledge/Initialize(mapload)
	. = ..()
	stun = crush_stun_amount
	weaken = crush_weaken_amount
	knockback = 0
	create_reagents(max_fuel, null, list(/datum/reagent/fuel = max_fuel))
	AddElement(/datum/element/strappable)

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

/obj/item/weapon/twohanded/rocketsledge/unique_action(mob/user)
	. = ..()
	if (knockback)
		stun = crush_stun_amount
		weaken = crush_weaken_amount
		knockback = 0
		balloon_alert(user, "Selected mode: CRUSH.")
		playsound(loc, 'sound/machines/switch.ogg', 25)
		return

	stun = knockback_stun_amount
	weaken = knockback_weaken_amount
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

	M.apply_damage(additional_damage, BRUTE, user.zone_selected, updating_health = TRUE)
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
		if(xeno_victim.fortify || xeno_victim.endure || HAS_TRAIT_FROM(xeno_victim, TRAIT_IMMOBILE, BOILER_ROOTED_TRAIT)) //If we're fortified or use endure we don't give a shit about staggerstun.
			return

		if(xeno_victim.crest_defense) //Crest defense protects us from the stun.
			stun = 0
		else
			stun = knockback ? knockback_stun_amount : crush_stun_amount

	if(!M.IsStun() && !M.IsParalyzed() && !isxenoqueen(M)) //Prevent chain stunning. Queen is protected.
		M.apply_effects(stun,weaken)

	return ..()
