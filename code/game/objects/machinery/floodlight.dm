//these are probably broken

/obj/machinery/floodlight
	name = "Emergency Floodlight"
	icon = 'icons/obj/machines/floodlight.dmi'
	icon_state = "flood00"
	anchored = TRUE
	density = TRUE
	var/on = 0
	var/obj/item/cell/cell = null
	var/use = 0
	var/unlocked = 0
	var/open = 0
	var/brightness_on = 7		//can't remember what the maxed out value is
	resistance_flags = UNACIDABLE

/obj/machinery/floodlight/Initialize()
	. = ..()
	cell = new /obj/item/cell(src)


/obj/machinery/floodlight/proc/updateicon()
	icon_state = "flood[open ? "o" : ""][open && cell ? "b" : ""]0[on]"
/*
/obj/machinery/floodlight/process()
	if(on && cell)
		if(cell.charge >= use)
			cell.use(use)
		else
			on = 0
			updateicon()
			SetLuminosity(0)
			src.visible_message("<span class='warning'>[src] shuts down due to lack of power!</span>")
			return
*/
//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/machinery/floodlight/attack_hand(mob/living/user)
	. = ..()
	if(open && cell)
		if(ishuman(user))
			if(!user.get_active_held_item())
				user.put_in_hands(cell)
				cell.loc = user.loc
		else
			cell.loc = loc

		cell.update_icon()

		src.cell = null
		to_chat(user, "You remove the power cell.")
		updateicon()
		return

	if(on)
		on = 0
		to_chat(user, "<span class='notice'>You turn off the light.</span>")
		set_light(0)
		ENABLE_BITFIELD(resistance_flags, UNACIDABLE)
	else
		if(!cell)
			return
		if(cell.charge <= 0)
			return
		on = 1
		to_chat(user, "<span class='notice'>You turn on the light.</span>")
		set_light(brightness_on)
		DISABLE_BITFIELD(resistance_flags, UNACIDABLE)

	updateicon()


/obj/machinery/floodlight/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!ishuman(user))
		return

	if(iswrench(I))
		anchored = !anchored
		if(anchored)
			to_chat(user, "You anchor the [src] in place.")
		else
			to_chat(user, "You remove the bolts from the [src].")

	else if(isscrewdriver(I))
		if(open)
			return
		unlocked = !unlocked
		if(unlocked)
			to_chat(user, "You unscrew the battery panel.")
		else
			to_chat(user, "You screw the battery panel in place.")

	else if(iscrowbar(I))
		if(!unlocked)
			return
		open = !open
		if(open)
			to_chat(user, "You remove the battery panel.")
		else if(unlocked)
			overlays.Cut()
			to_chat(user, "You crowbar the battery panel in place.")

	else if(istype(I, /obj/item/cell))
		if(!open)
			return

		if(cell)
			to_chat(user, "There is a power cell already installed.")
			return

		if(user.transferItemToLoc(I, src))
			cell = I
			to_chat(user, "You insert the power cell.")

	updateicon()

//Magical floodlight that cannot be destroyed or interacted with.
/obj/machinery/floodlight/landing
	name = "Landing Light"
	desc = "A powerful light stationed near landing zones to provide better visibility."
	icon_state = "flood01"
	on = 1
	use_power = 0


/obj/machinery/floodlight/landing/Initialize(mapload, ...)
	. = ..()
	set_light(5)


/obj/machinery/floodlight/landing/attack_hand(mob/living/user)
	return


/obj/machinery/floodlight/landing/attackby()
	return

/obj/machinery/floodlightcombat
	name = "Armoured floodlight"
	icon = 'icons/obj/machines/floodlight.dmi'
	icon_state = "floodlightcombat_off"
	anchored = FALSE
	density = TRUE
	resistance_flags = UNACIDABLE
	appearance_flags = KEEP_TOGETHER || TILE_BOUND
	idle_power_usage = 50
	active_power_usage = 2500
	wrenchable = TRUE
	/// Determines how much light does the floodlight make , every light tube adds 4 tiles distance.
	var/brightness = 0
	/// Turned ON or OFF? Used for the overlays and power usage.
	var/on = FALSE
	/// Used to show if the object is tipped
	var/tipped = FALSE

/// Handles the wrench act .
/obj/machinery/floodlightcombat/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	to_chat(user , "<span class='notice'>You begin wrenching [src]'s bolts")
	playsound( loc, 'sound/items/ratchet.ogg', 60, FALSE)
	if(!do_after(user, 2 SECONDS, TRUE, src))
		return FALSE
	if(anchored)
		to_chat(user , "<span class='notice'>You unwrench [src]'s bolts")
		anchored = FALSE
	else
		to_chat(user , "<span class='notice'>You wrench down [src]'s bolts")
		anchored = TRUE
	set_light(0, 5, "#C5E3E132")
	on = FALSE

/// Visually shows that the floodlight has been tipped and breaks all the lights in it.
/obj/machinery/floodlightcombat/proc/tip_over()
	for(var/obj/item/light_bulb/tube/T in contents)
		T.status = LIGHT_BROKEN
	update_icon()
	calculate_brightness()
	var/matrix/A = matrix()
	A.Turn(90)
	transform = A
	density = FALSE
	tipped = TRUE
	on = FALSE

/// Untip the floodlight
/obj/machinery/floodlightcombat/proc/flip_back()
	icon_state = initial(icon_state)
	density = TRUE
	var/matrix/A = matrix()
	transform = A
	tipped = FALSE

/obj/machinery/floodlightcombat/Initialize()
	..()
	start_processing()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/floodlightcombat/LateInitialize()
	. = ..()
	power_change()

/obj/machinery/floodlightcombat/process()
	if(powered(LIGHT))
		use_power(on ? active_power_usage : idle_power_usage, LIGHT)
		machine_stat &= ~NOPOWER
		return
	machine_stat |= NOPOWER
	if(on)
		on = !on
		set_light(0, 5, "#C5E3E132")
		update_icon()

/// Loops between the light tubes until it finds a light to break.
/obj/machinery/floodlightcombat/proc/break_a_light()
	var/obj/item/light_bulb/tube/T = pick(contents)
	if(T.status == LIGHT_OK)
		T.status = LIGHT_BROKEN
		calculate_brightness()
		return TRUE
	break_a_light()

/obj/machinery/floodlightcombat/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.a_intent == INTENT_DISARM)
		to_chat(X, "<span class='xenodanger'>You begin tipping the [src]")
		if(!density)
			to_chat(X, "<span class='xenonotice'>The [src] is already tipped over!")
			return FALSE
		var/fliptime = 10 SECONDS
		if(X.mob_size == MOB_SIZE_BIG)
			fliptime = 5 SECONDS
		if(isxenocrusher(X))
			fliptime = 3 SECONDS
		if(!do_after(X, fliptime, FALSE, src))
			return FALSE
		visible_message("<span class='danger'>[X] Flips the [src] , shaterring all the lights!")
		playsound( loc, 'sound/effects/glasshit.ogg', 60 , FALSE)
		tip_over()
		update_icon()
		return TRUE
	if(brightness == 0)
		to_chat(X, "<span class='xenonotice'>There are no lights to slash!")
		return FALSE
	playsound( loc, 'sound/weapons/alien_claw_metal1.ogg', 60, FALSE)
	to_chat(X, "<span class='xenonotice'>You slash one of the lights!")
	break_a_light()
	set_light(brightness, 5, "#C5E3E132")
	update_icon()

/obj/machinery/floodlightcombat/attackby(obj/item/I, mob/user, params)
	if(!ishuman(user))
		return FALSE
	if(istype(I, /obj/item/light_bulb/tube))
		if(on)
			to_chat(user, "<span class='notice'>The [src]'s safety systems won't let you open the light hatch! You should turn it off first.")
			return FALSE
		if(contents.len > 3)
			to_chat(user, "<span class='notice'>All the light sockets are occupied!")
			return FALSE
		to_chat(user, "You insert the [I] into the [src]")
		visible_message("[user] inserts the [I] into the [src]")
		user.drop_held_item()
		I.forceMove(src)
	if(istype(I, /obj/item/lightreplacer))
		if(on)
			to_chat(user, "<span class='notice'>The [I] cannot dispense lights into functioning machinery!")
			return FALSE
		if(contents.len > 3)
			to_chat(user, "<span class='notice'>All the light sockets are occupied!")
			return FALSE
		var/obj/item/lightreplacer/A = I
		if(A.CanUse())
			A.Use(user)
		else
			return FALSE
		var/obj/E = new /obj/item/light_bulb/tube
		E.forceMove(src)
	calculate_brightness()
	update_icon()

/// Checks each light if its working and then adds it to the total brightness amount.
/obj/machinery/floodlightcombat/proc/calculate_brightness()
	brightness = 0
	for(var/obj/item/light_bulb/tube/T in contents)
		if(T.status == LIGHT_OK)
			brightness += 4

/// Updates each light
/obj/machinery/floodlightcombat/update_overlays()
	. = ..()
	var/offsetX
	var/offsetY
	/// Used to define which slot is targeted on the sprite and then adjust the overlay.
	var/target_slot = 1
	if(on && brightness > 0)
		. += image('icons/obj/machines/floodlight.dmi', src, "floodlightcombat_lighting_glow", layer + 0.01, NORTH, 0, 5)
	for(var/obj/item/light_bulb/tube/target in contents)
		switch(target_slot)
			if(1)
				offsetX = 0
				offsetY = 0
			if(2)
				offsetX = 6
				offsetY = 0
			if(3)
				offsetX = 0
				offsetY = 5
			if(4)
				offsetX = 6
				offsetY = 5
		. += image('icons/obj/machines/floodlight.dmi', src, "floodlightcombat_[target.status ? "brokenlight" : "workinglight"]", layer, NORTH, offsetX, offsetY)
		target_slot++

/// Called whenever someone tries to turn the floodlight on/off
/obj/machinery/floodlightcombat/proc/switch_light()
	if(machine_stat & (NOPOWER|BROKEN))
		visible_message("<span class='notice'>You flip the switch , but nothing happens , perhaps its not powered?.")
		return FALSE
	if(!anchored || tipped)
		visible_message("<span class='danger'>The floodlight flashes a warning led.It is not bolted to the ground.")
		return FALSE
	if(on)
		on = !on
		set_light(0, 5, "#C5E3E132")
	else
		on = TRUE
		set_light(brightness, 5, "#C5E3E132")
	update_icon()
	playsound( loc, 'sound/machines/switch.ogg', 60 , FALSE)

/obj/machinery/floodlightcombat/attack_hand(mob/living/user)
	if(!ishuman(user))
		return FALSE
	if(user.a_intent != INTENT_GRAB)
		switch_light()
		return TRUE
	if(!density)
		to_chat(user, "You begin flipping back the floodlight")
		if(do_after(user , 60 SECONDS, TRUE, src))
			flip_back()
			to_chat(user, "You flip back the floodlight!")
			return TRUE
	if(on)
		to_chat (user, "<span class='danger'>You burn the tip of your finger as you try to take off the light tube!")
		return FALSE
	if(contents.len > 0)
		to_chat(user, "You take out one of the lights")
		visible_message("[user] takes out one of the lights tubes!")
		playsound( loc,'sound/items/screwdriver.ogg', 60 , FALSE)
		var/obj/item/light_bulb/item = pick(contents)
		item.forceMove(user.loc)
		item.update()
		user.put_in_hands(item)
		update_icon()
	else
		to_chat(user, "There are no lights to pull out")
		return FALSE
	calculate_brightness()
	return TRUE

/obj/machinery/floodlight/outpost
	name = "Outpost Light"
	icon_state = "flood01"
	on = TRUE
	use_power = FALSE

/obj/machinery/floodlight/landing/hq
	name = "Installation Light"
	desc = "A powerful light stationed on the base to provide better visibility."

/obj/machinery/floodlight/landing/Initialize(mapload, ...)
	. = ..()
	set_light(10)

/obj/machinery/floodlight/landing/testroom
	name = "Ambience Light"
	desc = "A powerful light placed concealed on the base to provide better visibility."
	density = 0
	alpha = 0
	resistance_flags = RESIST_ALL

/obj/machinery/floodlight/landing/testroom/Initialize(mapload, ...)
	. = ..()
	set_light(25)
