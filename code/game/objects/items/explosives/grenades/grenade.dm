/obj/item/explosive/grenade
	name = "\improper M40 HEDP grenade"
	desc = "A small, but deceptively strong high explosive grenade that has been phasing out the M15 fragmentation grenades. Capable of being loaded in the any grenade launcher, or thrown by hand."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "grenade"
	item_state = "grenade"
	throw_speed = 3
	throw_range = 7
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	hitsound = 'sound/weapons/smash.ogg'
	icon_state_mini = "grenade_red"
	var/launched = FALSE //if launched from a UGL/grenade launcher
	var/launchforce = 10 //bonus impact damage if launched from a UGL/grenade launcher
	var/det_time =  40
	var/dangerous = TRUE 	//Does it make a danger overlay for humans? Can synths use it?
	var/arm_sound = 'sound/weapons/armbomb.ogg'
	var/hud_state = "grenade_he"
	var/hud_state_empty = "grenade_empty"
	///Light impact range when exploding
	var/light_impact_range = 4


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
		update_icon()
	addtimer(CALLBACK(src, .proc/prime), det_time)

/obj/item/explosive/grenade/update_overlays()
	. = ..()
	if(dangerous)
		overlays += new /obj/effect/overlay/danger


/obj/item/explosive/grenade/proc/prime()
	explosion(loc, light_impact_range = src.light_impact_range, small_animation = TRUE)
	qdel(src)

/obj/item/explosive/grenade/flamer_fire_act(burnlevel)
	activate()

/obj/item/explosive/grenade/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	walk(src, null, null)
	return


////RAD GRENADE - TOTALLY RAD MAN

/obj/item/explosive/grenade/rad
	name = "\improper V-40 rad grenade"
	desc = "Rad grenades release an extremely potent but short lived burst of radiation, debilitating organic life and frying electronics in a moderate radius. After the initial detonation, the radioactive effects linger for a time. Handle with extreme care."
	icon_state = "grenade_rad" //placeholder
	item_state = "grenade_rad" //placeholder
	icon_state_mini = "grenade_red" //placeholder
	det_time =  40 //default
	arm_sound = 'sound/weapons/armbomb.ogg' //placeholder
	hud_state = "grenade_he" //placeholder
	///The range for the grenade's full effect
	var/inner_range = 4
	///The range range for the grenade's weak effect
	var/outer_range = 7
	///The potency of the grenade
	var/rad_strength = 20
	///geiger counter sound loop
	//var/datum/looping_sound/geiger/geiger_counter

/obj/item/explosive/grenade/rad/prime()
	var/turf/impact_turf = get_turf(src)
	playsound(impact_turf, 'sound/effects/portal_opening.ogg', 50, 1)

	for(var/mob/living/victim in get_hear(outer_range, impact_turf))
		var/strength
		//geiger_counter = new(null, FALSE)
		if(get_dist(victim, impact_turf) <= inner_range)
			strength = rad_strength
			//geiger_counter.severity = 3
		else
			strength = rad_strength * 0.6
			//geiger_counter.severity = 2
		irradiate(victim, strength)
		//geiger_counter.start(victim)

	qdel(src)

///Applies the actual effects of the rad grenade
/obj/item/explosive/grenade/rad/proc/irradiate(mob/living/victim, strength)
	var/rad_penetration = (100 - victim.get_soft_armor(RAD)) / 100
	var/effective_strength = strength * rad_penetration //strength with rad armor taken into account
	victim.adjustCloneLoss(effective_strength)
	victim.adjustStaminaLoss(effective_strength * 7)
	victim.adjust_stagger(effective_strength / 2)
	victim.add_slowdown(effective_strength / 2)
	victim.blur_eyes(effective_strength) //adds a visual indicator that you've just been irradiated
	victim.adjust_radiation(effective_strength * 20) //Radiation status effect, duration is in deciseconds
	to_chat(victim, span_warning("Your body tingles as you suddenly feel the strength drain from your body!"))
