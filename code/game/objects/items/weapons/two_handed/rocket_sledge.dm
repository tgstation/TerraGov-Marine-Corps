/obj/item/weapon/twohanded/rocketsledge
	name = "rocket sledge"
	desc = "Fitted with a rocket booster at the head, the rocket sledge would deliver a tremendously powerful impact, easily crushing your enemies. Uses fuel to power itself. Press AltClick to tighten your grip. Press Unique Action to change modes."
	icon_state = "rocketsledge"
	worn_icon_state = "rocketsledge"
	force = 30
	equip_slot_flags = ITEM_SLOT_BACK
	force_activated = 75
	throwforce = 50
	throw_speed = 2
	edge = 1
	sharp = IS_SHARP_ITEM_BIG
	atom_flags = CONDUCT | TWOHANDED
	attack_verb = list("smashes", "hammers")
	attack_speed = 20
	///amount of fuel stored inside
	var/max_fuel = 50
	///amount of fuel used per hit
	var/fuel_used = 5
	///additional damage when weapon is active
	var/additional_damage = 75
	///stun value in crush mode
	var/crush_stun_amount = 2 SECONDS
	///paralyze value in crush mode
	var/crush_paralyze_amount = 4 SECONDS
	///stun value in knockback mode
	var/knockback_stun_amount = 2 SECONDS
	///paralyze value in knockback mode
	var/knockback_paralyze_amount = 2 SECONDS
	///stun value
	var/stun
	///paralyze value
	var/paralyze
	///knockback value; 0 = crush mode, 1 = knockback mode
	var/knockback
	slowdown = 0.2

/obj/item/weapon/twohanded/rocketsledge/equipped(mob/user, slot)
	if(!user.has_movespeed_modifier(type))
		user.add_movespeed_modifier(type, TRUE, 0, (item_flags & IMPEDE_JETPACK) ? SLOWDOWN_IMPEDE_JETPACK : NONE, TRUE, 0.4)
	. = ..()

/obj/item/weapon/twohanded/rocketsledge/unequipped(mob/unequipper, slot)
	if(unequipper.has_movespeed_modifier(type))
		unequipper.remove_movespeed_modifier(type)
	. = ..()

/obj/item/weapon/twohanded/rocketsledge/Initialize(mapload)
	. = ..()
	stun = crush_stun_amount
	paralyze = crush_paralyze_amount
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
	. = ..()
	if ((reagents.get_reagent_amount(/datum/reagent/fuel) > fuel_used) && (CHECK_BITFIELD(item_flags, WIELDED)))
		icon_state = "rocketsledge_w"
	else
		icon_state = "rocketsledge"

/obj/item/weapon/twohanded/rocketsledge/unique_action(mob/user)
	. = ..()
	if(knockback)
		stun = crush_stun_amount
		paralyze = crush_paralyze_amount
		knockback = 0
		balloon_alert(user, "mode: CRUSH")
		playsound(loc, 'sound/machines/switch.ogg', 25)
		return

	stun = knockback_stun_amount
	paralyze = knockback_paralyze_amount
	knockback = 1
	balloon_alert(user, "mode: KNOCKBACK")
	playsound(loc, 'sound/machines/switch.ogg', 25)

/obj/item/weapon/twohanded/rocketsledge/attack(mob/living/carbon/M, mob/living/carbon/user as mob)
	if(!CHECK_BITFIELD(item_flags, WIELDED))
		to_chat(user, span_warning("You need a more secure grip to use [src]!"))
		return

	if(M.status_flags & INCORPOREAL || user.status_flags & INCORPOREAL)
		return

	if(reagents.get_reagent_amount(/datum/reagent/fuel) < fuel_used)
		to_chat(user, span_warning("\The [src] doesn't have enough fuel!"))
		return ..()

	M.apply_damage(additional_damage, BRUTE, user.zone_selected, updating_health = TRUE, attacker = user)
	M.visible_message(span_danger("[user]'s rocket sledge hits [M.name], smashing them!"), span_userdanger("[user]'s rocket sledge smashes you!"))

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
		if(xeno_victim.fortify || xeno_victim.endure || xeno_victim.endurance_active || HAS_TRAIT_FROM(xeno_victim, TRAIT_IMMOBILE, BOILER_ROOTED_TRAIT)) //If we're fortified or use endure we don't give a shit about staggerstun.
			return

		if(xeno_victim.crest_defense) //Crest defense protects us from the stun.
			stun = 0
		else
			stun = knockback ? knockback_stun_amount : crush_stun_amount

	if(!M.IsStun() && !M.IsParalyzed() && !isxenoqueen(M) && !isxenoking(M)) //Prevent chain stunning. Queen and King are protected.
		M.apply_effects(stun,paralyze)

	return ..()
