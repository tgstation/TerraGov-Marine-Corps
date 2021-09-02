/obj/item/explosive/grenade
	name = "grenade"
	desc = "A hand held grenade, with an adjustable timer."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "grenade"
	item_state = "flashbang"
	throw_speed = 3
	throw_range = 7
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	hitsound = 'sound/weapons/smash.ogg'
	icon_state_mini = "grenade"
	var/launched = FALSE //if launched from a UGL/grenade launcher
	var/launchforce = 10 //bonus impact damage if launched from a UGL/grenade launcher
	var/det_time = 50
	var/dangerous = TRUE 	//Does it make a danger overlay for humans? Can synths use it?
	var/arm_sound = 'sound/weapons/armbomb.ogg'
	var/underslug_launchable = FALSE
	var/hud_state = "grenade_he"
	var/hud_state_empty = "grenade_empty"


/obj/item/explosive/grenade/Initialize()
	. = ..()
	det_time = rand(det_time - 10, det_time + 10)

/obj/item/explosive/grenade/attack_self(mob/user)
	if(active)
		return

	if(!user.dextrous)
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return

	if(issynth(user) && dangerous && !CONFIG_GET(flag/allow_synthetic_gun_use))
		to_chat(user, span_warning("Your programming prevents you from operating this device!"))
		return

	activate(user)

	user.visible_message(span_warning("[user] primes \a [name]!"), \
	span_warning("You prime \a [name]!"))
	if(initial(dangerous) && ishumanbasic(user))
		var/nade_sound = user.gender == FEMALE ? get_sfx("female_fragout") : get_sfx("male_fragout")

		for(var/mob/living/carbon/human/H in hearers(6,user))
			H.playsound_local(user, nade_sound, 35)

		var/image/grenade = image('icons/mob/talk.dmi', user, "grenade")
		user.add_emote_overlay(grenade)

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.throw_mode_on()


/obj/item/explosive/grenade/proc/activate(mob/user)
	if(active)
		return

	if(user)
		log_explosion("[key_name(user)] primed [src] at [AREACOORD(user.loc)].")
		log_combat(user, src, "primed")

	icon_state = initial(icon_state) + "_active"
	active = TRUE
	playsound(loc, arm_sound, 25, 1, 6)
	if(dangerous)
		GLOB.round_statistics.grenades_thrown++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "grenades_thrown")
		updateicon()
	addtimer(CALLBACK(src, .proc/prime), det_time)

/obj/item/explosive/grenade/proc/updateicon()
	if(dangerous)
		overlays+=new/obj/effect/overlay/danger
		dangerous = 0


/obj/item/explosive/grenade/proc/prime()


/obj/item/explosive/grenade/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isscrewdriver(I))
		switch(det_time)
			if(1)
				det_time = 10
				to_chat(user, span_notice("You set the [name] for 1 second detonation time."))
			if(10)
				det_time = 30
				to_chat(user, span_notice("You set the [name] for 3 second detonation time."))
			if(30)
				det_time = 50
				to_chat(user, span_notice("You set the [name] for 5 second detonation time."))
			if(50)
				det_time = 1
				to_chat(user, span_notice("You set the [name] for instant detonation."))

/obj/item/explosive/grenade/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	walk(src, null, null)
	return
