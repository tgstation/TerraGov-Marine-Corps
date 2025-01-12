// the light item
// can be tube or bulb subtypes
// will fit into empty /obj/machinery/light of the corresponding type

/obj/item/light_bulb
	icon = 'icons/obj/lighting.dmi'
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/lights_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/lights_right.dmi',
	)
	force = 2
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	base_icon_state
	///Condition of the bulb
	var/status = LIGHT_OK
	///Number of times toggled
	var/switchcount = 0
	///If its rigged to explode
	var/rigged = 0
	///Light level this gives off when on
	var/brightness = 2

/obj/item/light_bulb/throw_impact(atom/hit_atom)
	. = ..()
	if(!.)
		return
	shatter()

/obj/item/light_bulb/tube
	name = "light tube"
	desc = "A replacement light tube."
	icon_state = "ltube"
	base_icon_state = "ltube"
	worn_icon_state = "c_tube"
	brightness = 8

/obj/item/light_bulb/tube/blue
	icon_state = "btube1"

/obj/item/light_bulb/tube/large
	w_class = WEIGHT_CLASS_SMALL
	name = "large light tube"
	brightness = 15

/obj/item/light_bulb/bulb
	name = "light bulb"
	desc = "A replacement light bulb."
	icon_state = "lbulb"
	base_icon_state = "lbulb"
	brightness = 5

/obj/item/light_bulb/bulb/blue
	icon_state = "bbulb1"

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
	existing_bulb.state = LIGHT_TILE_OK
	light_tile.update_icon()
	to_chat(user, span_notice("You replace the light bulb."))


// update the icon state and description of the light

/obj/item/light_bulb/proc/update()
	switch(status)
		if(LIGHT_OK)
			icon_state = base_icon_state
			desc = "A replacement [name]."
		if(LIGHT_BURNED)
			icon_state = "[base_icon_state]_burned"
			desc = "A burnt-out [name]."
		if(LIGHT_BROKEN)
			icon_state = "[base_icon_state]_broken"
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
	if(.)
		return

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
		src.visible_message(span_warning("[name] shatters."),span_warning("You hear a small glass object shatter."))
		status = LIGHT_BROKEN
		force = 5
		sharp = IS_SHARP_ITEM_SIMPLE
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 25, 1)
		update()
