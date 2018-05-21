/obj/item/explosive/grenade
	name = "grenade"
	desc = "A hand held grenade, with an adjustable timer."
	w_class = 2.0
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "grenade"
	item_state = "flashbang"
	throw_speed = 3
	throw_range = 7
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_WAIST
	hitsound = 'sound/weapons/smash.ogg'
	var/active = 0
	var/det_time = 50
	var/dangerous = 0		//Make an danger overlay for humans?
	var/arm_sound = 'sound/weapons/armbomb.ogg'
	var/underslug_launchable = FALSE

/obj/item/explosive/grenade/New()

	..()

	det_time = rand(det_time - 10, det_time + 10)

/obj/item/explosive/grenade/attack_self(mob/user)
	if(!active)

		if(!user.IsAdvancedToolUser())
			user << "<span class='warning'>You don't have the dexterity to do this!</span>"
			return

		add_fingerprint(user)
		activate(user)
		if((CLUMSY in user.mutations) && prob(50))
			user << "<span class='warning'>Huh? How does this thing work?</span>"
			spawn(5) prime()

		else
			user.visible_message("<span class='warning'>[user] primes \a [name]!</span>", \
			"<span class='warning'>You prime \a [name]!</span>")
			if(initial(dangerous) && has_species(user, "Human"))
				var/nade_sound = user.gender == FEMALE ? get_sfx("female_fragout") : get_sfx("male_fragout")

				for(var/mob/living/carbon/human/H in hearers(6,user))
					H.playsound_local(user, nade_sound, 35)
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()


/obj/item/explosive/grenade/proc/activate(mob/user as mob)
	if(active)
		return

	if(user)
		msg_admin_attack("[user.name] ([user.ckey]) primed \a [src] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

	icon_state = initial(icon_state) + "_active"
	active = 1
	playsound(loc, arm_sound, 25, 1, 6)
	if(dangerous)
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
//	playsound(loc, 'sound/items/Welder2.ogg', 25, 1)



/obj/item/explosive/grenade/attackby(obj/item/W as obj, mob/user as mob)
	if(isscrewdriver(W))
		switch(det_time)
			if ("1")
				det_time = 10
				user << "<span class='notice'>You set the [name] for 1 second detonation time.</span>"
			if ("10")
				det_time = 30
				user << "<span class='notice'>You set the [name] for 3 second detonation time.</span>"
			if ("30")
				det_time = 50
				user << "<span class='notice'>You set the [name] for 5 second detonation time.</span>"
			if ("50")
				det_time = 1
				user << "<span class='notice'>You set the [name] for instant detonation.</span>"
		add_fingerprint(user)
	..()
	return

/obj/item/explosive/grenade/attack_hand()
	walk(src, null, null)
	..()
	return

/obj/item/explosive/grenade/attack_paw(mob/user as mob)
	return attack_hand(user)
