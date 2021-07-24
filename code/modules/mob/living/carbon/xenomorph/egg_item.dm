
/obj/item/xeno_egg
	name = "egg"
	desc = "Some sort of egg."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "egg_item"
	w_class = WEIGHT_CLASS_GIGANTIC
	flags_atom = CRITICAL_ATOM
	flags_item = NOBLUDGEON
	throw_range = 1
	layer = MOB_LAYER
	var/hivenumber = XENO_HIVE_NORMAL

/obj/item/xeno_egg/Initialize(mapload, hivenumber)
	. = ..()
	pixel_x = rand(-3,3)
	pixel_y = rand(-3,3)
	if(hivenumber)
		src.hivenumber = hivenumber


/obj/item/xeno_egg/examine(mob/user)
	..()
	if(isxeno(user))
		to_chat(user, "A queen egg, it needs to be planted on weeds to start growing.")
		if(hivenumber == XENO_HIVE_CORRUPTED)
			to_chat(user, "This one appears to have been laid by a corrupted Queen.")

/obj/item/xeno_egg/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(isxeno(user))
		plant_egg(user, get_turf(target))
	if(ishuman(user))
		plant_egg_in_containment(user, get_turf(target))

/obj/item/xeno_egg/proc/plant_egg_in_containment(mob/living/carbon/human/user, turf/T)
	if(!istype(T, /turf/open/floor/mainship/research/containment))
		to_chat(user, span_warning("Best not to plant this thing outside of a containment cell."))
		return
	for (var/obj/O in T)
		if (!istype(O,/obj/machinery/light/small))
			to_chat(user, span_warning("The floor needs to be clear to plant this!"))
			return
	user.visible_message(span_notice("[user] starts planting [src]."), \
					span_notice("You start planting [src]."), null, 5)
	if(!do_after(user, 5 SECONDS, TRUE, T, BUSY_ICON_BUILD))
		return
	for (var/obj/O in T)
		if (!istype(O,/obj/machinery/light/small))
			return
	var/obj/effect/alien/egg/newegg = new(T)
	newegg.transfer_to_hive(hivenumber)
	playsound(T, 'sound/effects/alien_egg_move.ogg', 15, TRUE)
	qdel(src)

/obj/item/xeno_egg/proc/plant_egg(mob/living/carbon/xenomorph/user, turf/T)
	if(!T.check_alien_construction(user))
		return
	if(!user.check_plasma(30))
		return
	if(!(locate(/obj/effect/alien/weeds) in T))
		to_chat(user, span_xenowarning("[src] can only be planted on weeds."))
		return
	user.visible_message(span_xenonotice("[user] starts planting [src]."), \
					span_xenonotice("We start planting [src]."), null, 5)
	var/plant_time = 3.5 SECONDS
	if(!isxenodrone(user))
		plant_time = 2.5 SECONDS
	if(!do_after(user, plant_time, TRUE, T, BUSY_ICON_BUILD, extra_checks = CALLBACK(T, /turf/proc/check_alien_construction, user)))
		return
	if(!user.check_plasma(30))
		return
	if(!locate(/obj/effect/alien/weeds) in T)
		return
	user.use_plasma(30)
	var/obj/effect/alien/egg/newegg = new(T)
	newegg.transfer_to_hive(hivenumber)
	playsound(T, 'sound/effects/splat.ogg', 15, 1)
	qdel(src)


/obj/item/xeno_egg/attack_self(mob/user)
	if(!isxeno(user))
		return
	var/mob/living/carbon/xenomorph/X = user
	if(isxenocarrier(X))
		var/mob/living/carbon/xenomorph/carrier/C = X
		C.store_egg(src)
		return
	plant_egg(user, get_turf(user))



//Deal with picking up facehuggers. "attack_alien" is the universal 'xenos click something while unarmed' proc.
/obj/item/xeno_egg/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return

	switch(X.xeno_caste.can_hold_eggs)
		if(CAN_HOLD_ONE_HAND)
			attack_hand(X)
		if(CAN_HOLD_TWO_HANDS)
			if(X.r_hand || X.l_hand)
				to_chat(X, span_xenowarning("We need two hands to hold [src]."))
			else
				attack_hand(X)

/obj/item/xeno_egg/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		qdel(src)

/obj/item/xeno_egg/flamer_fire_act()
	qdel(src)
