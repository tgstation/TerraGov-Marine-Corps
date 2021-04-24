/obj/item/binoculars

	name = "binoculars"
	desc = "A pair of binoculars."
	icon_state = "binoculars"

	flags_atom = CONDUCT
	force = 5.0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3


/obj/item/binoculars/attack_self(mob/user)
	zoom(user, 11, 12)

#define MODE_CAS 0
#define MODE_RAILGUN 1
#define MODE_ORBITAL 2
#define MODE_RANGE_FINDER 3

/obj/item/binoculars/tactical
	name = "tactical binoculars"
	desc = "A pair of binoculars, with a laser targeting function. Alt+Click or unique action to toggle mode. Ctrl+Click when using to target something. Shift+Click to get coordinates. Ctrl+Shift+Click to fire OB when lasing in OB mode"
	var/laser_cooldown = 0
	var/cooldown_duration = 200 //20 seconds
	var/obj/effect/overlay/temp/laser_target/laser
	var/target_acquisition_delay = 100 //10 seconds
	var/mode = 0  //Able to be switched between modes, 0 for cas laser, 1 for finding coordinates, 2 for directing railgun, 3 for orbital bombardment, 4 for range finding and mortar targeting.
	var/changable = TRUE //If set to FALSE, you can't toggle the mode between CAS and coordinate finding
	var/ob_fired = FALSE // If the user has fired the OB
	var/turf/current_turf // The target turf, used for OBs
	///Last stored turf targetted by rangefinders
	var/turf/targetturf
	///Linked mortar for remote targeting.
	var/obj/structure/mortar/linked_mortar

/obj/item/binoculars/tactical/Initialize()
	. = ..()
	update_icon()

/obj/item/binoculars/tactical/unique_action(mob/user)
	toggle_mode(user)

/obj/item/binoculars/tactical/examine(mob/user)
	..()
	switch(mode)
		if(MODE_CAS)
			to_chat(user, "<span class='notice'>They are currently set to CAS marking mode.</span>")
		if(MODE_RANGE_FINDER)
			to_chat(user, "<span class='notice'>They are currently set to range finding mode.</span>")
		if(MODE_RAILGUN)
			to_chat(user, "<span class='notice'>They are currently set to railgun targeting mode.</span>")
		if(MODE_ORBITAL)
			to_chat(user, "<span class='notice'>They are currently set to orbital bombardment mode.</span>")
	to_chat(user, "<span class='notice'>Use on a mortar to link it for remote targeting.</span>")
	if(linked_mortar)
		to_chat(user, "<span class='notice'>They are currently linked to a mortar.</span>")
		return
	to_chat(user, "<span class='notice'>They are not linked to a mortar.</span>")

/obj/item/binoculars/tactical/Destroy()
	if(laser)
		QDEL_NULL(laser)
	. = ..()


/obj/item/binoculars/tactical/InterceptClickOn(mob/user, params, atom/object)
	var/list/pa = params2list(params)
	if(!pa.Find("ctrl") && pa.Find("shift"))
		acquire_coordinates(object, user)
		return TRUE

	if(pa.Find("ctrl") && !pa.Find("shift"))
		acquire_target(object, user)
		return TRUE

	if(pa.Find("ctrl") && pa.Find("shift"))
		try_fire_ob(object, user)
		return TRUE

	return FALSE

/obj/item/binoculars/tactical/dropped(mob/user)
	. = ..()
	if(user.interactee != src)
		return
	user.unset_interaction()


/obj/item/binoculars/tactical/on_set_interaction(mob/user)
	. = ..()
	user.reset_perspective(src)
	user.update_sight()
	user.client.click_intercept = src


/obj/item/binoculars/tactical/update_remote_sight(mob/living/user)
	user.see_in_dark = 32 // Should include the offset from zoom and client viewport
	user.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	user.sync_lighting_plane_alpha()
	return TRUE


/obj/item/binoculars/tactical/on_unset_interaction(mob/user)
	. = ..()

	if(!user?.client)
		return

	user.client.click_intercept = null
	user.reset_perspective(user)
	user.update_sight()

	if(zoom)
		return
	if(laser)
		QDEL_NULL(laser)


/obj/item/binoculars/tactical/update_overlays()
	. = ..()
	if(mode)
		. += "binoculars_range"
	else
		. += "binoculars_laser"

/obj/item/binoculars/tactical/AltClick(mob/user)
	. = ..()
	toggle_mode(user)

/obj/item/binoculars/tactical/verb/toggle_mode(mob/user)
	set category = "Object"
	set name = "Toggle Laser Mode"
	if(!user && isliving(loc))
		user = loc
	if (laser)
		to_chat(user, "<span class='warning'>You can't switch mode while targeting")
		return
	if(!changable)
		to_chat(user, "These binoculars only have one mode.")
		return
	mode += 1
	if(mode > MODE_RANGE_FINDER)
		mode = MODE_CAS
	switch(mode)
		if(MODE_CAS)
			to_chat(user, "<span class='notice'>You switch [src] to CAS marking mode.</span>")
		if(MODE_RAILGUN)
			to_chat(user, "<span class='notice'>You switch [src] to railgun targeting mode.</span>")
		if(MODE_ORBITAL)
			to_chat(user, "<span class='notice'>You switch [src] to orbital bombardment targeting mode.</span>")
		if(MODE_RANGE_FINDER)
			to_chat(user, "<span class='notice'>You switch [src] to range finding mode.</span>")
	update_icon()
	playsound(user, 'sound/items/binoculars.ogg', 15, 1)

/obj/item/binoculars/tactical/proc/acquire_coordinates(atom/A, mob/living/carbon/human/user)
	var/turf/TU = get_turf(A)
	targetturf = TU
	to_chat(user, "<span class='notice'>COORDINATES: LONGITUDE [targetturf.x]. LATITUDE [targetturf.y].</span>")
	playsound(src, 'sound/effects/binoctarget.ogg', 35)

/obj/item/binoculars/tactical/proc/acquire_target(atom/A, mob/living/carbon/human/user)
	set waitfor = 0

	if(laser)
		to_chat(user, "<span class='warning'>You're already targeting something.</span>")
		return

	if(world.time < laser_cooldown)
		to_chat(user, "<span class='warning'>[src]'s laser battery is recharging.</span>")
		return

	if(user.client.eye != src)
		to_chat(user, "<span class='warning'>You can't focus properly through \the [src] while looking through something else.</span>")
		return


	if(!user.mind)
		return
	var/datum/squad/S = user.assigned_squad

	var/laz_name = ""
	laz_name += user.get_paygrade()
	laz_name += user.name
	if(S)
		laz_name += " ([S.name])"


	var/turf/TU = get_turf(A)
	var/area/targ_area = get_area(A)
	if(!istype(TU))
		return
	var/is_outside = FALSE
	if(is_ground_level(TU.z))
		switch(targ_area.ceiling)
			if(CEILING_NONE)
				is_outside = TRUE
			if(CEILING_GLASS)
				is_outside = TRUE
			if(CEILING_METAL)
				is_outside = TRUE
	if(!is_outside)
		to_chat(user, "<span class='warning'>DEPTH WARNING: Target too deep for ordnance.</span>")
		return
	if(user.do_actions)
		return
	playsound(src, 'sound/effects/nightvision.ogg', 35)
	if(mode != MODE_RANGE_FINDER)
		to_chat(user, "<span class='notice'>INITIATING LASER TARGETING. Stand still.</span>")
		if(!do_after(user, max(1.5 SECONDS, target_acquisition_delay - (2.5 SECONDS * user.skills.getRating("leadership"))), TRUE, TU, BUSY_ICON_GENERIC) || world.time < laser_cooldown || laser)
			return
	switch(mode)
		if(MODE_CAS)
			to_chat(user, "<span class='notice'>TARGET ACQUIRED. LASER TARGETING IS ONLINE. DON'T MOVE.</span>")
			var/obj/effect/overlay/temp/laser_target/cas/CS = new (TU, laz_name, S)
			laser = CS
			playsound(src, 'sound/effects/binoctarget.ogg', 35)
			while(laser)
				if(!do_after(user, 5 SECONDS, TRUE, laser, BUSY_ICON_GENERIC))
					QDEL_NULL(laser)
					break
		if(MODE_RANGE_FINDER)
			if(!linked_mortar)
				to_chat(user, "<span class='notice'>No linked mortar found.</span>")
				return
			targetturf = TU
			to_chat(user, "<span class='notice'>COORDINATES TARGETED: LONGITUDE [targetturf.x]. LATITUDE [targetturf.y].</span>")
			playsound(src, 'sound/effects/binoctarget.ogg', 35)
			linked_mortar.recieve_target(TU,src,user)
			return
		if(MODE_RAILGUN)
			to_chat(user, "<span class='notice'>ACQUIRING TARGET. RAILGUN TRIANGULATING. DON'T MOVE.</span>")
			if((GLOB.marine_main_ship?.rail_gun?.last_firing + 120 SECONDS) > world.time)
				to_chat(user, "[icon2html(src, user)] <span class='warning'>The Rail Gun hasn't cooled down yet!</span>")
			else if(!targ_area)
				to_chat(user, "[icon2html(src, user)] <span class='warning'>No target detected!</span>")
			else
				var/obj/effect/overlay/temp/laser_target/RGL = new (TU, laz_name, S)
				laser = RGL
				playsound(src, 'sound/effects/binoctarget.ogg', 35)
				if(!do_after(user, 2 SECONDS, TRUE, user, BUSY_ICON_GENERIC))
					QDEL_NULL(laser)
					return
				to_chat(user, "<span class='notice'>TARGET ACQUIRED. RAILGUN IS FIRING. DON'T MOVE.</span>")
				while(laser)
					GLOB.marine_main_ship?.rail_gun?.fire_rail_gun(TU,user)
					if(!do_after(user, 5 SECONDS, TRUE, laser, BUSY_ICON_GENERIC))
						QDEL_NULL(laser)
						break
		if(MODE_ORBITAL)
			to_chat(user, "<span class='notice'>ACQUIRING TARGET. ORBITAL CANNON TRIANGULATING. DON'T MOVE.</span>")
			if(!targ_area)
				to_chat(user, "[icon2html(src, user)] <span class='warning'>No target detected!</span>")
			else
				var/obj/effect/overlay/temp/laser_target/OB/OBL = new (TU, laz_name, S)
				laser = OBL
				playsound(src, 'sound/effects/binoctarget.ogg', 35)
				if(!do_after(user, 15 SECONDS, TRUE, user, BUSY_ICON_GENERIC))
					QDEL_NULL(laser)
					return
				to_chat(user, "<span class='notice'>TARGET ACQUIRED. ORBITAL CANNON IS READY TO FIRE.</span>")
				// Wait for that ALT click to fire
				current_turf = TU
				ob_fired = FALSE // Reset the fired state
				while(laser && !ob_fired)
					if(!do_after(user, 5 SECONDS, TRUE, laser, BUSY_ICON_GENERIC))
						QDEL_NULL(laser)
						break
				current_turf = null

/obj/item/binoculars/tactical/proc/try_fire_ob(atom/A, mob/living/carbon/human/user)
	if(mode != MODE_ORBITAL)
		return
	if(A != laser || !current_turf)
		return // Gotta click on a laser target
	ob_fired = TRUE
	var/x_offset = rand(-2,2) //Little bit of randomness.
	var/y_offset = rand(-2,2)
	var/turf/target = locate(current_turf.x + x_offset,current_turf.y + y_offset,current_turf.z)
	GLOB.marine_main_ship?.orbital_cannon?.fire_ob_cannon(target, user)
	to_chat(user, "<span class='notice'>FIRING REQUEST RECIEVED. CLEAR TARGET AREA</span>")
	log_attack("[key_name(user)] fired an orbital bombardment in [AREACOORD(current_turf)].")
	message_admins("[ADMIN_TPMONTY(user)] fired an orbital bombardment in [ADMIN_VERBOSEJMP(current_turf)].")
	QDEL_NULL(laser)

///Sets or unsets the binocs linked mortar.
/obj/item/binoculars/tactical/proc/set_mortar(mortar)
	if(linked_mortar)
		UnregisterSignal(linked_mortar, COMSIG_PARENT_QDELETING)
	if(linked_mortar == mortar)
		linked_mortar = null
		return FALSE
	linked_mortar = mortar
	RegisterSignal(linked_mortar, COMSIG_PARENT_QDELETING, .proc/clean_refs)
	return TRUE

///Proc called when linked_mortar is deleted.
/obj/item/binoculars/tactical/proc/clean_refs()
	SIGNAL_HANDLER
	linked_mortar = null
	say("NOTICE: connection lost with linked mortar.")

/obj/item/binoculars/tactical/scout
	name = "scout tactical binoculars"
	desc = "A modified version of tactical binoculars with an advanced laser targeting function. Ctrl+Click to target something."
	cooldown_duration = 80
	target_acquisition_delay = 30

//For events
/obj/item/binoculars/tactical/range
	name = "range-finder"
	desc = "A pair of binoculars designed to find coordinates. Shift+Click or Ctrl+Click to get coordinates when using."
	changable = 0
	mode = MODE_RANGE_FINDER

#undef MODE_CAS
#undef MODE_RANGE_FINDER
#undef MODE_RAILGUN
#undef MODE_ORBITAL
