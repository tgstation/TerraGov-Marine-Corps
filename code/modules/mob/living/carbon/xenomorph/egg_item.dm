
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
		var/turf/T = get_turf(target)
		plant_egg(user, T)
	if(ishuman(user))
		var/turf/T = get_turf(target)
		plant_egg_in_containment(user, T)

/obj/item/xeno_egg/proc/plant_egg_in_containment(mob/living/carbon/human/user, turf/T)
	if(!istype(T, /turf/open/floor/mainship/research/containment))
		to_chat(user, "<span class='warning'>Best not to plant this thing outside of a containment cell.</span>")
		return
	for (var/obj/O in T)
		if (!istype(O,/obj/machinery/light/small))
			to_chat(user, "<span class='warning'>The floor needs to be clear to plant this!</span>")
			return
	user.visible_message("<span class='notice'>[user] starts planting [src].</span>", \
					"<span class='notice'>You start planting [src].</span>", null, 5)
	if(!do_after(user, 50, TRUE, T, BUSY_ICON_BUILD))
		return
	for (var/obj/O in T)
		if (!istype(O,/obj/machinery/light/small))
			return
	var/obj/effect/alien/egg/newegg = new /obj/effect/alien/egg(T)
	newegg.transfer_to_hive(hivenumber)
	playsound(T, 'sound/effects/alien_egg_move.ogg', 15, TRUE)
	qdel(src)

/obj/item/xeno_egg/proc/plant_egg(mob/living/carbon/xenomorph/user, turf/T)
	if(!T.check_alien_construction(user))
		return
	if(!user.check_plasma(30))
		return
	if(!(locate(/obj/effect/alien/weeds) in T))
		to_chat(user, "<span class='xenowarning'>[src] can only be planted on weeds.</span>")
		return
	user.visible_message("<span class='xenonotice'>[user] starts planting [src].</span>", \
					"<span class='xenonotice'>We start planting [src].</span>", null, 5)
	var/plant_time = 35
	if(!isxenodrone(user))
		plant_time = 25
	if(!do_after(user, plant_time, TRUE, T, BUSY_ICON_BUILD, extra_checks = CALLBACK(T, /turf/proc/check_alien_construction, user)))
		return
	if(!user.check_plasma(30))
		return
	if(locate(/obj/effect/alien/weeds) in T)
		user.use_plasma(30)
		var/obj/effect/alien/egg/newegg = new /obj/effect/alien/egg(T)
		newegg.transfer_to_hive(hivenumber)
		playsound(T, 'sound/effects/splat.ogg', 15, 1)
		qdel(src)


/obj/item/xeno_egg/attack_self(mob/user)
	if(isxeno(user))
		var/mob/living/carbon/xenomorph/X = user
		if(isxenocarrier(X))
			var/mob/living/carbon/xenomorph/carrier/C = X
			C.store_egg(src)
		else
			var/turf/T = get_turf(user)
			plant_egg(user, T)



//Deal with picking up facehuggers. "attack_alien" is the universal 'xenos click something while unarmed' proc.
/obj/item/xeno_egg/attack_alien(mob/living/carbon/xenomorph/user)
	switch(user.xeno_caste.can_hold_eggs)
		if(CAN_HOLD_ONE_HAND)
			attack_hand(user)
		if(CAN_HOLD_TWO_HANDS)
			if(user.r_hand || user.l_hand)
				to_chat(user, "<span class='xenowarning'>We need two hands to hold [src].</span>")
			else
				attack_hand(user)

/obj/item/xeno_egg/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		qdel(src)

/obj/item/xeno_egg/flamer_fire_act()
	qdel(src)
