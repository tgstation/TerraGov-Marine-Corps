/obj/item/explosive/grenade
	name = "grenade"
	desc = "A hand held grenade, with an adjustable timer."
	w_class = 2.0
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "grenade"
	item_state = "flashbang"
	throw_speed = 3
	throw_range = 7
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	hitsound = 'sound/weapons/smash.ogg'
	var/launched = FALSE //if launched from a UGL/grenade launcher
	var/launchforce = 10 //bonus impact damage if launched from a UGL/grenade launcher
	var/active = 0
	var/det_time = 50
	var/dangerous = TRUE 	//Does it make a danger overlay for humans? Can synths use it?
	var/arm_sound = 'sound/weapons/armbomb.ogg'
	var/underslug_launchable = FALSE
	var/hud_state = "grenade_he"
	var/hud_state_empty = "grenade_empty"


/obj/item/explosive/grenade/New()
	. = ..()
	det_time = rand(det_time - 10, det_time + 10)

/obj/item/explosive/grenade/attack_self(mob/user)
	if(active)
		return

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if(issynth(user) && dangerous && !CONFIG_GET(flag/allow_synthetic_gun_use))
		to_chat(user, "<span class='warning'>Your programming prevents you from operating this device!</span>")
		return

	activate(user)

	user.visible_message("<span class='warning'>[user] primes \a [name]!</span>", \
	"<span class='warning'>You prime \a [name]!</span>")
	if(initial(dangerous) && ishumanbasic(user))
		var/nade_sound = user.gender == FEMALE ? get_sfx("female_fragout") : get_sfx("male_fragout")

		for(var/mob/living/carbon/human/H in hearers(6,user))
			H.playsound_local(user, nade_sound, 35)

		var/image/grenade = image('icons/mob/talk.dmi', user, "grenade")
		user.add_emote_overlay(grenade)

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.throw_mode_on()


/obj/item/explosive/grenade/proc/activate(mob/user as mob)
	if(active)
		return

	if(user)
		log_explosion("[key_name(user)] primed [src] at [AREACOORD(user.loc)].")
		log_combat(user, src, "primed")

	icon_state = initial(icon_state) + "_active"
	active = TRUE
	playsound(loc, arm_sound, 25, 1, 6)
	if(dangerous)
		round_statistics.grenades_thrown++
		updateicon()
	spawn(det_time)
		prime()
		return

/obj/item/explosive/grenade/proc/updateicon()
	if(dangerous)
		overlays+=new/obj/effect/overlay/danger
		dangerous = 0
	return


/obj/item/explosive/grenade/proc/prime()


/obj/item/explosive/grenade/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isscrewdriver(I))
		switch(det_time)
			if(1)
				det_time = 10
				to_chat(user, "<span class='notice'>You set the [name] for 1 second detonation time.</span>")
			if(10)
				det_time = 30
				to_chat(user, "<span class='notice'>You set the [name] for 3 second detonation time.</span>")
			if(30)
				det_time = 50
				to_chat(user, "<span class='notice'>You set the [name] for 5 second detonation time.</span>")
			if(50)
				det_time = 1
				to_chat(user, "<span class='notice'>You set the [name] for instant detonation.</span>")

/obj/item/explosive/grenade/attack_hand()
	walk(src, null, null)
	..()
	return

/obj/item/explosive/grenade/attack_paw(mob/user as mob)
	return attack_hand(user)
