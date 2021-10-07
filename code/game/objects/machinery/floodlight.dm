/obj/machinery/floodlight
	name = "Emergency Floodlight"
	icon = 'icons/obj/machines/floodlight.dmi'
	icon_state = "flood00"
	anchored = TRUE
	density = TRUE
	light_system = HYBRID_LIGHT
	light_power = 5
	///The brightness of the floodlight
	var/brightness_on = 7

/obj/machinery/floodlight/Initialize()
	. = ..()
	GLOB.nightfall_toggleable_lights += src

/obj/machinery/floodlight/Destroy()
	GLOB.nightfall_toggleable_lights -= src
	return ..()

/obj/machinery/floodlight/attack_hand(mob/living/user)
	return

/obj/machinery/floodlight/attackby()
	return

/obj/machinery/floodlight/turn_light(mob/user, toggle_on)
	. = ..()
	if(. != CHECKS_PASSED)
		return
	if(toggle_on)
		if(user)
			to_chat(user, span_notice("You turn on the light."))
		set_light(brightness_on)
		DISABLE_BITFIELD(resistance_flags, UNACIDABLE)
		return
	if(user)
		to_chat(user, span_notice("You turn off the light."))
	set_light(0)
	ENABLE_BITFIELD(resistance_flags, UNACIDABLE)

/obj/machinery/floodlight/landing
	name = "Landing Light"
	desc = "A powerful light stationed near landing zones to provide better visibility."
	icon_state = "flood01"
	use_power = 0
	brightness_on = 5

/obj/machinery/floodlight/landing/Initialize()
	. = ..()
	set_light(brightness_on)

/obj/machinery/floodlight/outpost
	name = "Outpost Light"
	icon_state = "flood01"
	use_power = FALSE
	brightness_on = 10

/obj/machinery/floodlight/outpost/Initialize()
	. = ..()
	set_light(brightness_on)

/obj/machinery/floodlight/landing/hq
	name = "Installation Light"
	desc = "A powerful light stationed on the base to provide better visibility."

/obj/machinery/floodlight/landing/Initialize()
	. = ..()
	set_light(brightness_on)

/obj/machinery/floodlight/landing/testroom
	name = "Ambience Light"
	desc = "A powerful light placed concealed on the base to provide better visibility."
	density = 0
	alpha = 0
	resistance_flags = RESIST_ALL
	brightness_on = 25

/obj/machinery/floodlight/landing/testroom/Initialize()
	. = ..()
	set_light(brightness_on)

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
	light_power = 5
	light_system = HYBRID_LIGHT
	/// Determines how much light does the floodlight make , every light tube adds 4 tiles distance.
	var/brightness = 0
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
		use_power(light_on ? active_power_usage : idle_power_usage, LIGHT)
		machine_stat &= ~NOPOWER
		return
	machine_stat |= NOPOWER
	set_light(0, 5, COLOR_SILVER)
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
	set_light(brightness, 5, COLOR_SILVER)
	update_icon()

/obj/machinery/floodlightcombat/attackby(obj/item/I, mob/user, params)
	if(!ishuman(user))
		return FALSE
	if(istype(I, /obj/item/light_bulb/tube))
		if(light_on)
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
		if(light_on)
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
	if(light_on && brightness > 0)
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
/obj/machinery/floodlightcombat/proc/switch_light(mob/user)
	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, "<span class='notice'>You flip the switch , but nothing happens , perhaps its not powered?.")
		return FALSE
	if(!anchored || tipped)
		to_chat(user, "<span class='danger'>The floodlight flashes a warning led.It is not bolted to the ground.")
		return FALSE
	turn_light(null, !light_on)
	playsound( loc, 'sound/machines/switch.ogg', 60 , FALSE)

/obj/machinery/floodlightcombat/turn_light(mob/user, toggle_on)
	. = ..()
	if(. != CHECKS_PASSED)
		return
	if(toggle_on)
		set_light(brightness, 5, COLOR_WHITE)
	else
		set_light(0, 5, COLOR_WHITE)
	update_icon()

/obj/machinery/floodlightcombat/attack_hand(mob/living/user)
	if(!ishuman(user))
		return FALSE
	if(user.a_intent != INTENT_GRAB)
		switch_light(user)
		return TRUE
	if(!density)
		to_chat(user, "You begin flipping back the floodlight")
		if(do_after(user , 60 SECONDS, TRUE, src))
			flip_back()
			to_chat(user, "You flip back the floodlight!")
			return TRUE
	if(light_on)
		to_chat (user, "<span class='danger'>You burn the tip of your finger as you try to take off the light tube!")
		return FALSE
	if(contents.len > 0)
		to_chat(user, "You take out one of the lights")
		visible_message("[user] takes out one of the lights tubes!")
		playsound(loc, 'sound/items/screwdriver.ogg', 60 , FALSE)
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

#define FLOODLIGHT_TICK_CONSUMPTION 800

/obj/machinery/floodlight/colony
	name = "Colony Floodlight"
	icon_state = "floodoff"
	brightness_on = 7
	var/obj/machinery/colony_floodlight_switch/fswitch = null //Reverse lookup for power grabbing in area

/obj/machinery/floodlight/colony/Initialize()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_FLOODLIGHT_SWITCH, .proc/floodswitch_powered)

/obj/machinery/floodlight/colony/Destroy()
	turn_light(null, FALSE)
	UnregisterSignal(SSdcs, COMSIG_GLOB_FLOODLIGHT_SWITCH)
	return ..()

///Make the link between the floodlight and the switch
/obj/machinery/floodlight/colony/proc/floodswitch_powered(datum/source, floodswitch, toggle_on)
	SIGNAL_HANDLER
	fswitch = floodswitch
	turn_light(null, toggle_on)

/obj/machinery/floodlight/colony/reset_light()
	if(fswitch?.turned_on)
		turn_light(null, TRUE)

/obj/machinery/floodlight/colony/turn_light(mob/user, toggle_on)
	. = ..()
	if(toggle_on)
		fswitch?.active_power_usage += FLOODLIGHT_TICK_CONSUMPTION
	else
		fswitch?.active_power_usage -= FLOODLIGHT_TICK_CONSUMPTION
	update_icon()


/obj/machinery/floodlight/colony/update_icon()
	. = ..()
	if(light_on)
		icon_state = "floodon"
	else
		icon_state = "floodoff"

#undef FLOODLIGHT_TICK_CONSUMPTION

/obj/machinery/colony_floodlight_switch
	name = "Colony Floodlight Switch"
	icon = 'icons/obj/machines/floodlight.dmi'
	icon_state = "panelnopower"
	desc = "This switch controls the floodlights surrounding the archaeology complex. It only functions when there is power."
	density = FALSE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 0
	resistance_flags = RESIST_ALL
	var/turned_on = FALSE //has to be toggled in engineering

/obj/machinery/colony_floodlight_switch/update_icon()
	. = ..()
	if(machine_stat & NOPOWER)
		icon_state = "panelnopower"
	else if(turned_on)
		icon_state = "panelon"
	else
		icon_state = "paneloff"

/obj/machinery/colony_floodlight_switch/power_change()
	. = ..()
	if(machine_stat && NOPOWER)
		if(turned_on)
			toggle_lights(FALSE)
			turned_on = FALSE
	update_icon()

/obj/machinery/colony_floodlight_switch/proc/toggle_lights(switch_on)
	turned_on = switch_on
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_FLOODLIGHT_SWITCH, src, switch_on)

/obj/machinery/colony_floodlight_switch/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		to_chat(user, span_notice("Nice try."))
		return FALSE
	if(machine_stat & NOPOWER)
		to_chat(user, span_notice("Nothing happens."))
		return FALSE
	playsound(src,'sound/machines/click.ogg', 15, 1)
	toggle_lights(turned_on ? FALSE : TRUE)
	update_icon()
	return TRUE
