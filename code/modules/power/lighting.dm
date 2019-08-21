// The lighting system
//
// consists of light fixtures (/obj/machinery/light) and light tube/bulb items (/obj/item/light)


// status values shared between lighting fixtures and items
#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3



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

/obj/machinery/light_construct/New()
	..()
	if (fixture_type == "bulb")
		icon_state = "bulb-construct-stage1"

/obj/machinery/light_construct/examine(mob/user)
	..()
	switch(stage)
		if(1)
			to_chat(user, "It's an empty frame.")
		if(2)
			to_chat(user, "It's wired.")
		if(3)
			to_chat(user, "The casing is closed.")


/obj/machinery/light_construct/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswrench(I))
		if(stage == 1)
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
			to_chat(user, "You begin deconstructing [src].")
			if(!do_after(usr, 30, TRUE, src, BUSY_ICON_BUILD))
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

// the standard tube light fixture
/obj/machinery/light
	name = "light fixture"
	icon = 'icons/obj/lighting.dmi'
	var/base_state = "tube"		// base description and icon_state
	icon_state = "tube1"
	desc = "A lighting fixture."
	anchored = TRUE
	layer = FLY_LAYER
	use_power = 2
	idle_power_usage = 2
	active_power_usage = 20
	power_channel = LIGHT //Lights are calc'd via area so they dont need to be in the machine list
	var/on = FALSE
	var/on_gs = FALSE
	var/brightness = 8			// luminosity when on, also used in power calculation
	var/bulb_power = 1			// basically the alpha of the emitted light source
	var/bulb_colour = LIGHT_COLOR_WHITE
	var/status = LIGHT_OK		// LIGHT_OK, _EMPTY, _BURNED or _BROKEN
	var/flickering = FALSE
	var/light_type = /obj/item/light_bulb/tube		// the type of light item
	var/fitting = "tube"
	var/switchcount = 0			// count of number of times switched on/off
								// this is used to calc the probability the light burns out

	var/rigged = FALSE				// true if rigged to explode

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

/obj/machinery/light/built/Initialize()
	. = ..()
	status = LIGHT_EMPTY
	update(FALSE)


/obj/machinery/light/small/built/Initialize()
	. = ..()
	status = LIGHT_EMPTY
	update(FALSE)

// create a new lighting fixture
/obj/machinery/light/Initialize(mapload, ...)
	. = ..()

	switch(fitting)
		if("tube")
			brightness = 8
			if(prob(2))
				broken(TRUE)
		if("bulb")
			brightness = 4
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
	seton(A.lightswitch && A.power_light)
	

/obj/machinery/light/Destroy()
	var/area/A = get_area(src)
	if(A)
		on = FALSE
	return ..()

/obj/machinery/light/proc/is_broken()
	if(status == LIGHT_BROKEN)
		return TRUE
	return FALSE

/obj/machinery/light/update_icon()

	switch(status)		// set icon_states
		if(LIGHT_OK)
			icon_state = "[base_state][on]"
		if(LIGHT_EMPTY)
			icon_state = "[base_state]-empty"
			on = FALSE
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
			on = FALSE
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
			on = FALSE
	return

// update the icon_state and luminosity of the light depending on its state
/obj/machinery/light/proc/update(trigger = TRUE)
	switch(status)
		if(LIGHT_BROKEN, LIGHT_BURNED, LIGHT_EMPTY)
			on = FALSE
	if(on)
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
	if(on != on_gs)
		on_gs = on
	update_icon()


// attempt to set the light's on/off status
// will not switch on if broken/burned/empty
/obj/machinery/light/proc/seton(s)
	on = (s && status == LIGHT_OK)
	update()

// examine verb
/obj/machinery/light/examine(mob/user)
	..()
	switch(status)
		if(LIGHT_OK)
			to_chat(user, "It is turned [on? "on" : "off"].")
		if(LIGHT_EMPTY)
			to_chat(user, "The [fitting] has been removed.")
		if(LIGHT_BURNED)
			to_chat(user, "The [fitting] is burnt out.")
		if(LIGHT_BROKEN)
			to_chat(user, "The [fitting] has been smashed.")



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
		on = has_power()
		update()

		if(!user.temporarilyRemoveItemFromInventory(L))
			return

		qdel(L)

		if(on && rigged)
			explode()

	else if(status != LIGHT_BROKEN && status != LIGHT_EMPTY)
		if(!prob(1 + I.force * 5))
			to_chat(user, "You hit the light!")
			return

		visible_message("[user] smashed the light!", "You hit the light, and it smashes!")
		if(on && (I.flags_atom & CONDUCT) && prob(12))
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
				electrocute_mob(user, get_area(src), src, rand(0.7, 1))


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
		if(on && status == LIGHT_OK)
			for(var/i = 0; i < amount; i++)
				if(status != LIGHT_OK)
					break
				on = !on
				update(0)
				sleep(rand(5, 15))
			on = (status == LIGHT_OK)
			update(0)
		flickering = FALSE

// ai attack - make lights flicker, because why not

/obj/machinery/light/attack_ai(mob/user)
	src.flicker(1)
	return


//Xenos smashing lights
/obj/machinery/light/attack_alien(mob/living/carbon/xenomorph/M)
	if(status == 2) //Ignore if broken.
		return FALSE
	M.do_attack_animation(src)
	M.visible_message("<span class='danger'>\The [M] smashes [src]!</span>", \
	"<span class='danger'>We smash [src]!</span>", null, 5)
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
			visible_message("<span class='warning'>[user] smashed the light!</span>", null, "You hear a tinkle of breaking glass")
			broken()
			return

	// make it burn hands if not wearing fire-insulated gloves
	if(on)
		var/prot = 0
		var/mob/living/carbon/human/H = user

		if(istype(H))

			if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves
				if(G.max_heat_protection_temperature)
					prot = (G.max_heat_protection_temperature > 360)
		else
			prot = 1

		if(prot > 0)
			to_chat(user, "You remove the light [fitting]")
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
	on = TRUE
	update()

// explosion effect
// destroy the whole light fixture or just shatter it

/obj/machinery/light/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(75))
				broken()
		if(3.0)
			if (prob(50))
				broken()
	return

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
	seton(A.lightswitch && A.power_light)

// called when on fire

/obj/machinery/light/fire_act(exposed_temperature, exposed_volume)
	if(prob(max(0, exposed_temperature - 673)))   //0% at <400C, 100% at >500C
		broken()

// explode the light

/obj/machinery/light/proc/explode()
	var/turf/T = get_turf(src.loc)
	spawn(0)
		broken()	// break it first to give a warning
		sleep(2)
		explosion(T, 0, 0, 2, 2)
		sleep(1)
		qdel(src)

// the light item
// can be tube or bulb subtypes
// will fit into empty /obj/machinery/light of the corresponding type

/obj/item/light_bulb
	icon = 'icons/obj/lighting.dmi'
	force = 2
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	var/status = 0		// LIGHT_OK, LIGHT_BURNED or LIGHT_BROKEN
	var/base_state
	var/switchcount = 0	// number of times switched
	matter = list("metal" = 60)
	var/rigged = 0		// true if rigged to explode
	var/brightness = 2 //how much light it gives off

/obj/item/light_bulb/throw_impact(atom/hit_atom)
	..()
	shatter()

/obj/item/light_bulb/tube
	name = "light tube"
	desc = "A replacement light tube."
	icon_state = "ltube"
	base_state = "ltube"
	item_state = "c_tube"
	matter = list("glass" = 100)
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
	item_state = "contvapour"
	matter = list("glass" = 100)
	brightness = 5

/obj/item/light_bulb/bulb/fire
	name = "fire bulb"
	desc = "A replacement fire bulb."
	icon_state = "fbulb"
	base_state = "fbulb"
	item_state = "egg4"
	matter = list("glass" = 100)
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


/obj/item/light_bulb/New()
	..()
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

	if(istype(I, /obj/item/reagent_container/syringe))
		var/obj/item/reagent_container/syringe/S = I

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
		src.visible_message("<span class='warning'> [name] shatters.</span>","<span class='warning'> You hear a small glass object shatter.</span>")
		status = LIGHT_BROKEN
		force = 5
		sharp = IS_SHARP_ITEM_SIMPLE
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 25, 1)
		update()

/obj/machinery/landinglight
	name = "landing light"
	icon = 'icons/obj/landinglights.dmi'
	icon_state = "landingstripetop"
	desc = "A landing light, if it's flashing stay clear!"
	var/id = "" // ID for landing zone
	anchored = TRUE
	density = FALSE
	layer = BELOW_TABLE_LAYER
	use_power = 2
	idle_power_usage = 2
	active_power_usage = 20
	power_channel = LIGHT //Lights are calc'd via area so they dont need to be in the machine list
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE

/obj/machinery/landinglight/New()
	turn_off()

/obj/machinery/landinglight/proc/turn_off()
	icon_state = "landingstripe"
	set_light(0)

/obj/machinery/landinglight/ds1


/obj/machinery/landinglight/ds1/Initialize(mapload, ...)
	. = ..()
	id = "alamo"

/obj/machinery/landinglight/ds2


/obj/machinery/landinglight/ds2/Initialize(mapload, ...)
	. = ..()
	id = "normandy" // ID for landing zone

/obj/machinery/landinglight/proc/turn_on()
	icon_state = "landingstripe0"
	set_light(2)

/obj/machinery/landinglight/ds1/delayone/turn_on()
	icon_state = "landingstripe1"
	set_light(2)

/obj/machinery/landinglight/ds1/delaytwo/turn_on()
	icon_state = "landingstripe2"
	set_light(2)

/obj/machinery/landinglight/ds1/delaythree/turn_on()
	icon_state = "landingstripe3"
	set_light(2)

/obj/machinery/landinglight/ds2/delayone/turn_on()
	icon_state = "landingstripe1"
	set_light(2)

/obj/machinery/landinglight/ds2/delaytwo/turn_on()
	icon_state = "landingstripe2"
	set_light(2)

/obj/machinery/landinglight/ds2/delaythree/turn_on()
	icon_state = "landingstripe3"
	set_light(2)
