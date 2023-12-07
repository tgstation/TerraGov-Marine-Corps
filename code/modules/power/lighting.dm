// The lighting system
//
// consists of light fixtures (/obj/machinery/light) and light tube/bulb items (/obj/item/light)


// status values shared between lighting fixtures and items
/obj/machinery/light_construct
	name = "light fixture frame"
	desc = "A light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-stage1"
	anchored = TRUE
	layer = FLY_LAYER
	var/stage = 1
	var/fixture_type = "tube"
	var/sheets_refunded = 2
	var/obj/machinery/light/newlight = null

/obj/machinery/light_construct/Initialize(mapload)
	. = ..()
	if(fixture_type == "bulb")
		icon_state = "bulb-construct-stage1"

/obj/machinery/light_construct/examine(mob/user)
	. = ..()
	switch(stage)
		if(1)
			. += "It's an empty frame."
		if(2)
			. += "It's wired."
		if(3)
			. += "The casing is closed."


/obj/machinery/light_construct/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswrench(I))
		if(stage == 1)
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
			to_chat(user, "You begin deconstructing [src].")
			if(!do_after(usr, 30, NONE, src, BUSY_ICON_BUILD))
				return
			new /obj/item/stack/sheet/metal(get_turf(loc), sheets_refunded)
			user.visible_message("[user] deconstructs [src].", \
				"You deconstruct [src].", "You hear a noise.")
			playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
			qdel(src)
		else if(stage == 2)
			to_chat(user, "You have to remove the wires first.")
			return
		else if(stage == 3)
			to_chat(user, "You have to unscrew the case first.")
			return

	else if(iswirecutter(I))
		if(stage != 2)
			return
		stage = 1
		switch(fixture_type)
			if("tube")
				icon_state = "tube-construct-stage1"
			if("bulb")
				icon_state = "bulb-construct-stage1"
		new /obj/item/stack/cable_coil(get_turf(loc), 1, "red")
		user.visible_message("[user.name] removes the wiring from [src].", \
			"You remove the wiring from [src].", "You hear a noise.")
		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)

	else if(iscablecoil(I))
		var/obj/item/stack/cable_coil/coil = I

		if(stage != 1)
			return

		if(!coil.use(1))
			return

		switch(fixture_type)
			if("tube")
				icon_state = "tube-construct-stage2"
			if("bulb")
				icon_state = "bulb-construct-stage2"
		stage = 2
		user.visible_message("[user] adds wires to [src].", \
			"You add wires to [src].")

	else if(isscrewdriver(I))
		if(stage != 2)
			return

		switch(fixture_type)
			if("tube")
				icon_state = "tube-empty"
			if("bulb")
				icon_state = "bulb-empty"

		stage = 3
		user.visible_message("[user] closes [src]'s casing.", \
			"You close [src]'s casing.", "You hear a noise.")
		playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)

		switch(fixture_type)
			if("tube")
				newlight = new /obj/machinery/light/built(loc)
			if("bulb")
				newlight = new /obj/machinery/light/small/built(loc)

		newlight.setDir(dir)
		qdel(src)


/obj/machinery/light_construct/small
	name = "small light fixture frame"
	desc = "A small light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb-construct-stage1"
	anchored = TRUE
	stage = 1
	fixture_type = "bulb"
	sheets_refunded = 1

/// the standard tube light fixture
/obj/machinery/light
	name = "light fixture"
	icon = 'icons/obj/lighting.dmi'
	var/base_state = "tube"		// base description and icon_state
	icon_state = "tube1"
	desc = "A lighting fixture."
	anchored = TRUE
	layer = FLY_LAYER
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 20
	power_channel = LIGHT //Lights are calc'd via area so they dont need to be in the machine list
	light_system = STATIC_LIGHT //do not change this, byond and potato pcs no like
	obj_flags = CAN_BE_HIT
	var/brightness = 8			// power usage and light range when on
	var/bulb_power = 1			// basically the light_power of the emitted light source
	var/bulb_colour = COLOR_WHITE
	var/status = LIGHT_OK		// LIGHT_OK, _EMPTY, _BURNED or _BROKEN
	var/flickering = FALSE
	var/light_type = /obj/item/light_bulb/tube		// the type of light item
	var/fitting = "tube"
	///count of number of times switched on/off. this is used to calc the probability the light burns out
	var/switchcount = 0
	/// true if rigged to explode
	var/rigged = FALSE

/obj/machinery/light/mainship
	base_state = "tube"

/obj/machinery/light/mainship/Initialize(mapload)
	. = ..()
	GLOB.mainship_lights += src

/obj/machinery/light/mainship/Destroy()
	. = ..()
	GLOB.mainship_lights -= src

/obj/machinery/light/mainship/small
	icon_state = "bulb1"
	base_state = "bulb"
	fitting = "bulb"
	brightness = 4
	desc = "A small lighting fixture."
	light_type = /obj/item/light_bulb/bulb

/obj/machinery/light/red
	base_state = "tubered"
	icon_state = "tubered1"
	light_color = LIGHT_COLOR_FLARE
	brightness = 3
	bulb_power = 0.5
	bulb_colour = LIGHT_COLOR_FLARE

// the smaller bulb light fixture

/obj/machinery/light/small
	icon_state = "bulb1"
	base_state = "bulb"
	fitting = "bulb"
	brightness = 4
	desc = "A small lighting fixture."
	light_type = /obj/item/light_bulb/bulb

/obj/machinery/light/spot
	name = "spotlight"
	fitting = "large tube"
	light_type = /obj/item/light_bulb/tube/large
	brightness = 12

/obj/machinery/light/built/Initialize(mapload)
	. = ..()
	status = LIGHT_EMPTY
	update(FALSE)


/obj/machinery/light/small/built/Initialize(mapload)
	. = ..()
	status = LIGHT_EMPTY
	update(FALSE)

// create a new lighting fixture
/obj/machinery/light/Initialize(mapload, ...)
	switch(dir)
		if(NORTH)
			light_pixel_y = 15
		if(SOUTH)
			light_pixel_y = -15
		if(WEST)
			light_pixel_x = 15
		if(EAST)
			light_pixel_x = -15
	. = ..()

	GLOB.nightfall_toggleable_lights += src

	switch(fitting)
		if("tube")
			if(prob(2))
				broken(TRUE)
		if("bulb")
			if(prob(5))
				broken(TRUE)

	update(FALSE)

	switch(dir)
		if(NORTH)
			pixel_y = 20
		if(EAST)
			pixel_x = 10
		if(WEST)
			pixel_x = -10

	return INITIALIZE_HINT_LATELOAD


/obj/machinery/light/LateInitialize()
	var/area/A = get_area(src)
	turn_light(null, (A.lightswitch && A.power_light))

/obj/machinery/light/Destroy()
	GLOB.nightfall_toggleable_lights -= src
	return ..()

/obj/machinery/light/proc/is_broken()
	if(status == LIGHT_BROKEN)
		return TRUE
	return FALSE

/obj/machinery/light/update_icon()
	switch(status)		// set icon_states
		if(LIGHT_OK)
			icon_state = "[base_state][light_on]"
		if(LIGHT_EMPTY)
			icon_state = "[base_state]-empty"
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"

// update the icon_state and luminosity of the light depending on its state
/obj/machinery/light/proc/update(trigger = TRUE, toggle_on = TRUE)
	var/area/A = get_area(src)
	if(A.lightswitch && A.power_light && status == LIGHT_OK && toggle_on)
		var/BR = brightness
		var/PO = bulb_power
		var/CO = bulb_colour
		if(color)
			CO = color
		var/matching = light && BR == light.light_range && PO == light.light_power && CO == light.light_color
		if(!matching)
			switchcount++
			if(rigged)
				if(status == LIGHT_OK && trigger)
					explode()
			else if(prob(min(60, (switchcount ^ 2) * 0.01)))
				if(trigger)
					broken()
			else
				use_power = ACTIVE_POWER_USE
				set_light(BR, PO, CO)
	else
		use_power = IDLE_POWER_USE
		set_light(0)

	active_power_usage = (luminosity * 10)
	update_icon()

// attempt to set the light's on/off status
// will not switch on if broken/burned/empty
/obj/machinery/light/turn_light(mob/user, toggle_on)
	if (status != LIGHT_OK) //Can't turn a broken light
		return
	. = ..()
	light_on = toggle_on
	update(TRUE, toggle_on)

// examine verb
/obj/machinery/light/examine(mob/user)
	. = ..()
	switch(status)
		if(LIGHT_OK)
			. += "It is turned [light_on? "on" : "off"]."
		if(LIGHT_EMPTY)
			. += "The [fitting] has been removed."
		if(LIGHT_BURNED)
			. += "The [fitting] is burnt out."
		if(LIGHT_BROKEN)
			. += "The [fitting] has been smashed."



// attack with item - insert light (if right type), otherwise try to break the light

/obj/machinery/light/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/lightreplacer))
		var/obj/item/lightreplacer/LR = I
		if(!isliving(user))
			return

		var/mob/living/L = user
		LR.ReplaceLight(src, L)

	else if(istype(I, /obj/item/light_bulb))
		if(status != LIGHT_EMPTY)
			to_chat(user, "There is a [fitting] already inserted.")
			return

		var/obj/item/light_bulb/L = I
		if(!istype(L, light_type))
			to_chat(user, "This type of light requires a [fitting].")
			return

		status = L.status
		to_chat(user, "You insert \the [L].")
		switchcount = L.switchcount
		rigged = L.rigged
		brightness = L.brightness
		update()

		if(!user.temporarilyRemoveItemFromInventory(L))
			return

		qdel(L)

		if(light_on && rigged)
			explode()

	else if(status != LIGHT_BROKEN && status != LIGHT_EMPTY)
		if(!prob(1 + I.force * 5))
			to_chat(user, "You hit the light!")
			return

		visible_message("[user] smashed the light!", "You hit the light, and it smashes!")
		if(light_on && (I.flags_atom & CONDUCT) && prob(12))
			electrocute_mob(user, get_area(src), src, 0.3)
		broken()

	else if(status == LIGHT_EMPTY)
		if(isscrewdriver(I)) //If it's a screwdriver open it.
			playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
			user.visible_message("[user] opens [src]'s casing.", \
				"You open [src]'s casing.", "You hear a noise.")
			var/obj/machinery/light_construct/newlight
			switch(fitting)
				if("tube")
					newlight = new /obj/machinery/light_construct(loc)
					newlight.icon_state = "tube-construct-stage2"

				if("bulb")
					newlight = new /obj/machinery/light_construct/small(loc)
					newlight.icon_state = "bulb-construct-stage2"
			newlight.setDir(dir)
			newlight.stage = 2
			qdel(src)

		else if(has_power() && (I.flags_atom & CONDUCT))
			to_chat(user, "You stick \the [I] into the light socket!")
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			if(prob(75))
				electrocute_mob(user, get_area(src), src, rand(7, 10) * 0.1)


// returns whether this light has power
// true if area has power and lightswitch is on
/obj/machinery/light/proc/has_power()
	var/area/A = get_area(src)
	return A.lightswitch && A.power_light

/obj/machinery/light/proc/flicker(amount = rand(10, 20))
	if(flickering)
		return
	flickering = TRUE
	spawn(0)
		if(light_on && status == LIGHT_OK)
			for(var/i = 0; i < amount; i++)
				if(status != LIGHT_OK)
					break
				update(FALSE)
				sleep(rand(5, 15))
			update(FALSE)
		flickering = FALSE

// ai attack - make lights flicker, because why not

/obj/machinery/light/attack_ai(mob/user)
	flicker(1)


//Xenos smashing lights
/obj/machinery/light/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return
	if(status == 2) //Ignore if broken.
		return FALSE
	X.do_attack_animation(src, ATTACK_EFFECT_SMASH)
	X.visible_message(span_danger("\The [X] smashes [src]!"), \
	span_danger("We smash [src]!"), null, 5)
	broken() //Smashola!

// attack with hand - remove tube/bulb
// if hands aren't protected and the light is on, burn the player

/obj/machinery/light/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(status == LIGHT_EMPTY)
		to_chat(user, "There is no [fitting] in this light.")
		return

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.species.can_shred(H))
			visible_message(span_warning("[user] smashed the light!"), null, "You hear a tinkle of breaking glass")
			broken()
			return

	// make it burn hands if not wearing fire-insulated gloves
	if(light_on)
		var/prot = 0
		var/mob/living/carbon/human/H = user
		var/datum/limb/limb_check = H.get_limb(H.hand? "l_hand" : "r_hand")

		if(istype(H))

			if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves
				if(G.max_heat_protection_temperature)
					prot = (G.max_heat_protection_temperature > 360)
		else
			prot = 1

		if(prot > 0 || isrobot(H) || (limb_check.limb_status & LIMB_ROBOT))
			to_chat(user, "You remove the light [fitting].")
		else
			to_chat(user, "You try to remove the light [fitting], but it's too hot and you don't want to burn your hand.")
			return				// if burned, don't remove the light
	else
		to_chat(user, "You remove the light [fitting].")

	// create a light tube/bulb item and put it in the user's hand
	var/obj/item/light_bulb/L = new light_type()
	L.status = status
	L.rigged = rigged
	L.brightness = src.brightness

	// light item inherits the switchcount, then zero it
	L.switchcount = switchcount
	switchcount = 0

	L.update()

	if(!user.put_in_active_hand(L))	//succesfully puts it in our active hand
		L.forceMove(loc) //if not, put it on the ground
	status = LIGHT_EMPTY
	update()

// break the light and make sparks if was on

/obj/machinery/light/proc/broken(skip_sound_and_sparks = 0)
	if(status == LIGHT_EMPTY)
		return

	if(!skip_sound_and_sparks)
		if(status == LIGHT_OK || status == LIGHT_BURNED)
			playsound(src.loc, 'sound/effects/Glasshit.ogg', 25, 1)
//		if(on)
//			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
//			s.set_up(3, 1, src)
//			s.start()
	status = LIGHT_BROKEN
	update()

/obj/machinery/light/proc/fix()
	if(status == LIGHT_OK)
		return
	status = LIGHT_OK
	brightness = initial(brightness)
	update()

// explosion effect
// destroy the whole light fixture or just shatter it

/obj/machinery/light/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
			return
		if(EXPLODE_HEAVY)
			if (prob(75))
				broken()
		if(EXPLODE_LIGHT)
			if (prob(50))
				broken()
		if(EXPLODE_WEAK)
			if (prob(25))
				broken()


//timed process
//use power
#define LIGHTING_POWER_FACTOR 20		//20W per unit luminosity

/*
/obj/machinery/light/process()//TODO: remove/add this from machines to save on processing as needed ~Carn PRIORITY
	if(on)
		use_power(luminosity * LIGHTING_POWER_FACTOR, LIGHT)
*/

// called when area power state changes
/obj/machinery/light/power_change()
	var/area/A = get_area(src)
	turn_light(null, (A.lightswitch && A.power_light))

// called when on fire

/obj/machinery/light/fire_act(exposed_temperature, exposed_volume)
	if(prob(max(0, exposed_temperature - 673)))   //0% at <400C, 100% at >500C
		broken()

// explode the light

/obj/machinery/light/proc/explode()
	broken()	// break it first to give a warning
	addtimer(CALLBACK(src, PROC_REF(delayed_explosion)), 0.5 SECONDS)

/obj/machinery/light/proc/delayed_explosion()
	explosion(loc, 0, 1, 3, 0, 2)
	qdel(src)

// the light item
// can be tube or bulb subtypes
// will fit into empty /obj/machinery/light of the corresponding type

/obj/item/light_bulb
	icon = 'icons/obj/lighting.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/lights_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/lights_right.dmi',
	)
	force = 2
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	var/status = 0		// LIGHT_OK, LIGHT_BURNED or LIGHT_BROKEN
	var/base_state
	var/switchcount = 0	// number of times switched
	var/rigged = 0		// true if rigged to explode
	var/brightness = 2 //how much light it gives off

/obj/item/light_bulb/throw_impact(atom/hit_atom)
	. = ..()
	if(!.)
		return
	shatter()

/obj/item/light_bulb/tube
	name = "light tube"
	desc = "A replacement light tube."
	icon_state = "ltube"
	base_state = "ltube"
	item_state = "c_tube"
	brightness = 8

/obj/item/light_bulb/tube/large
	w_class = WEIGHT_CLASS_SMALL
	name = "large light tube"
	brightness = 15

/obj/item/light_bulb/bulb
	name = "light bulb"
	desc = "A replacement light bulb."
	icon_state = "lbulb"
	base_state = "lbulb"
	brightness = 5

/obj/item/light_bulb/bulb/attack_turf(turf/T, mob/living/user)
	var/turf/open/floor/light/light_tile = T
	if(!istype(light_tile))
		return
	if(status != LIGHT_OK)
		to_chat(user, span_notice("The replacement bulb is broken."))
		return
	var/obj/item/stack/tile/light/existing_bulb = light_tile.floor_tile
	if(existing_bulb.state == LIGHT_TILE_OK)
		to_chat(user, span_notice("The lightbulb seems fine, no need to replace it."))
		return

	user.drop_held_item(src)
	qdel(src)
	existing_bulb.state = 0
	light_tile.update_icon()
	to_chat(user, span_notice("You replace the light bulb."))

/obj/item/light_bulb/bulb/fire
	name = "fire bulb"
	desc = "A replacement fire bulb."
	icon_state = "fbulb"
	base_state = "fbulb"
	item_state = "egg4"
	brightness = 5

// update the icon state and description of the light

/obj/item/light_bulb/proc/update()
	switch(status)
		if(LIGHT_OK)
			icon_state = base_state
			desc = "A replacement [name]."
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
			desc = "A burnt-out [name]."
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
			desc = "A broken [name]."


/obj/item/light_bulb/Initialize(mapload)
	. = ..()
	switch(name)
		if("light tube")
			brightness = rand(6,9)
		if("light bulb")
			brightness = rand(4,6)
	update()


// attack bulb/tube with object
// if a syringe, can inject phoron to make it explode
/obj/item/light_bulb/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/reagent_containers/syringe))
		var/obj/item/reagent_containers/syringe/S = I

		to_chat(user, "You inject the solution into the [src].")

		if(S.reagents.has_reagent(/datum/reagent/toxin/phoron, 5))
			rigged = TRUE

		S.reagents.clear_reagents()

// called after an attack with a light item
// shatter light, unless it was an attempt to put it in a light socket
// now only shatter if the intent was harm

/obj/item/light_bulb/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target, /obj/machinery/light))
		return
	if(user.a_intent != INTENT_HARM)
		return

	shatter()

/obj/item/light_bulb/proc/shatter()
	if(status == LIGHT_OK || status == LIGHT_BURNED)
		src.visible_message(span_warning(" [name] shatters."),span_warning(" You hear a small glass object shatter."))
		status = LIGHT_BROKEN
		force = 5
		sharp = IS_SHARP_ITEM_SIMPLE
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 25, 1)
		update()

/obj/machinery/landinglight
	name = "landing light"
	icon = 'icons/obj/landinglights.dmi'
	icon_state = "landingstripe"
	desc = "A landing light, if it's flashing stay clear!"
	anchored = TRUE
	density = FALSE
	layer = BELOW_TABLE_LAYER
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 20
	resistance_flags = RESIST_ALL|DROPSHIP_IMMUNE
	///ID of dropship
	var/id
	///port its linked to
	var/obj/docking_port/stationary/marine_dropship/linked_port = null

/obj/machinery/landinglight/Initialize(mapload)
	. = ..()
	GLOB.landing_lights += src

/obj/machinery/landinglight/Destroy()
	GLOB.landing_lights -= src
	return ..()

/obj/machinery/landinglight/proc/turn_on()
	icon_state = "landingstripe1"
	set_light(2, 2, LIGHT_COLOR_RED)

/obj/machinery/landinglight/proc/turn_off()
	icon_state = "landingstripe"
	set_light(0)

/obj/machinery/landinglight/alamo
	id = SHUTTLE_ALAMO

/obj/machinery/landinglight/lz1
	id = "lz1"

/obj/machinery/landinglight/lz2
	id = "lz2"

/obj/machinery/landinglight/cas
	id = SHUTTLE_CAS_DOCK

/obj/machinery/landinglight/tadpole
	id = SHUTTLE_TADPOLE

/obj/machinery/floor_warn_light
	name = "alarm light"
	desc = "If this is on you should probably be running!"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "rotating_alarm"
	light_system = HYBRID_LIGHT
	light_color = LIGHT_COLOR_RED
	light_mask_type = /atom/movable/lighting_mask/rotating_conical
	light_power = 6
	light_range = 4

/obj/machinery/floor_warn_light/self_destruct
	name = "self destruct alarm light"
	icon_state = "rotating_alarm_off"
	light_power = 0
	light_range = 0

/obj/machinery/floor_warn_light/self_destruct/Initialize(mapload)
	. = ..()
	SSevacuation.alarm_lights += src

/obj/machinery/floor_warn_light/self_destruct/Destroy()
	. = ..()
	SSevacuation.alarm_lights -= src

///Enables the alarm lights and makes them start flashing
/obj/machinery/floor_warn_light/self_destruct/proc/enable()
	icon_state = "rotating_alarm"
	set_light(4,6)

///Disables the alarm lights and makes them stop flashing
/obj/machinery/floor_warn_light/self_destruct/proc/disable()
	icon_state = initial(icon_state)
	set_light(0,0)
