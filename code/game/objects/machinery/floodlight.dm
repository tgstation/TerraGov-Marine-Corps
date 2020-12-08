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
	anchored = TRUE
	density = TRUE
	/// Determines how much light does the floodlight make , every light tube adds 4 tiles distance.
	var/Brightness = 0
	var/On = 0
	resistance_flags = UNACIDABLE
	idle_power_usage = 50
	active_power_usage = 2500
	wrenchable = TRUE

/obj/machinery/floodlightcombat/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	to_chat(user , "You begin wrenching [src]'s bolts'")
	if(!do_after(user, 2 SECONDS, TRUE, src))
		return FALSE
	if(anchored)
		anchored = 0
	else
		anchored = 1
	set_light(0)
	On = 0


/obj/machinery/floodlightcombat/proc/tip_over()
	var/matrix/A = matrix()
	density = FALSE
	A.Turn(90)
	transform = A
	var/obj/item/light_bulb/tube/T = /obj/item/light_bulb/tube
	for(T in src.contents)
		T.status = 2
	CalculateBrightness()

/obj/machinery/floodlightcombat/Initialize()
	. = ..()
	start_processing()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/floodlightcombat/LateInitialize()
	. = ..()
	power_change()

/obj/machinery/floodlightcombat/process()
	if(On)
		use_power(active_power_usage, EQUIP)
	else
		use_power(idle_power_usage, EQUIP)

/obj/machinery/floodlightcombat/proc/break_a_light()
	var/obj/item/light_bulb/tube/T = pick(contents)
	if(T.status == 0)
		T.status = 2
		return TRUE
	if(Brightness == 0)
		return FALSE
	break_a_light()


/obj/machinery/floodlightcombat/attack_alien(mob/living/carbon/xenomorph/M)
	if(M.a_intent == INTENT_DISARM)
		to_chat(M, "You begin tipping the [src]")
		if(!(src.density))
			to_chat(M, "The [src] is already tipped over!")
			return FALSE
		var/fliptime = 10 SECONDS
		if(M.mob_size == MOB_SIZE_BIG)
			fliptime = 5 SECONDS
		if(isxenocrusher(M))
			fliptime = 3 SECONDS
		if(!do_after(M, fliptime, FALSE, src))
			return FALSE
		visible_message("[M] Flips the [src] , shaterring all the lights!")
		tip_over()
		update_icon()
		return TRUE
	if(contents.len == 0)
		to_chat(M, "There are no lights to slash!")
		return FALSE
	else
		to_chat(M, "You slash one of the lights!")
		break_a_light()
		CalculateBrightness()
		update_icon()

/obj/machinery/floodlightcombat/attackby(obj/item/I, mob/user, params)
	var/list/lights = src.contents
	if(!(ishuman(user)))
		return FALSE
	if(istype(I, /obj/item/light_bulb/tube))
		if(lights.len > 3)
			to_chat(user, "all the light sockets are occupied!")
			return FALSE
		to_chat(user, "you insert the [I] into the [src]")
		visible_message("[user] inserts the [I] into the [src]")
		user.drop_held_item()
		I.forceMove(src)
		CalculateBrightness()
		update_icon()
	if(istype(I, /obj/item/lightreplacer))
		if(lights.len > 3)
			to_chat(user, "all the light sockets are occupied!")
			return FALSE
		var/obj/item/lightreplacer/A = I
		if(A.CanUse())
			A.Use(user)
		var/obj/E = new /obj/item/light_bulb/tube
		E.forceMove(src)
		CalculateBrightness()
		update_icon()


/obj/machinery/floodlightcombat/proc/CalculateBrightness()
	Brightness = 0
	for(var/obj/item/light_bulb/tube/T as() in src.contents)
		if(T.status == 0)
			Brightness += 4

/obj/machinery/floodlightcombat/update_overlays()
	. = ..()
	var/offsetX
	var/offsetY
	var/target_slot = 0
	var/list/lights = src.contents
	for(var/obj/item/light_bulb/tube/target as() in lights)
		switch(target_slot)
			if(1)
				offsetX = 1
				offsetY = 10
			if(2)
				offsetX = 10
				offsetY = 5
			if(3)
				offsetX = 20
				offsetY = -10
			else
				offsetX = 25
				offsetY = 25
		floodlight_[target.status ? "working" : "broken"]
		if(target.status > 0)
			. += image('icons/obj/machines/floodlight.dmi', src, "floodlightcombat_workinglight", ABOVE_OBJ_LAYER, NORTH, offsetX, offsetY)
		else
			. += image('icons/obj/machines/floodlight.dmi', src, "floodlightcombat_brokenlight", ABOVE_OBJ_LAYER, NORTH, offsetX, offsetY)
		target_slot++




/obj/machinery/floodlightcombat/proc/SwitchLight()
	if(!(src.anchored))
		visible_message("the floodlight flashes a warning led.It is not bolted to the ground.")
		return FALSE
	if(On)
		On = 0
		set_light(0)
	else
		On = 1
		set_light(Brightness)
	update_icon()

/obj/machinery/floodlightcombat/attack_hand(mob/living/user)
	var/list/obj/item/light_bulb/tube/T = src.contents
	if(!ishuman(user))
		return FALSE
	if(user.a_intent == INTENT_GRAB)
		if(On)
			to_chat (user, "You burn the tip of your finger as you try to take off the light tube!")
			return FALSE
		if(T.len > 0)
			to_chat(user, "You take out one of the lights")
			visible_message("[user] takes out one of the lights tubes!")
			var/obj/item/item = pick(src.contents)
			item.forceMove(user.loc)
		else
			to_chat(user, "There are no lights to pull out")
			return FALSE
		CalculateBrightness()
		return TRUE
	SwitchLight()

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

/obj/machinery/floodlight/landing/testroom/Initialize(mapload, ...)
	. = ..()
	set_light(25)
