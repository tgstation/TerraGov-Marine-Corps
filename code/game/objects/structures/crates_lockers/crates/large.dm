/obj/structure/closet/crate/large
	name = "large crate"
	desc = ""
	icon_state = "largecrate"
	density = TRUE
	material_drop_amount = 4
	delivery_icon = "deliverybox"
	integrity_failure = 0 //Makes the crate break when integrity reaches 0, instead of opening and becoming an invisible sprite.
	open_sound = 'sound/blank.ogg'
	close_sound = 'sound/blank.ogg'
	open_sound_volume = 25
	close_sound_volume = 50

/obj/structure/closet/crate/large/attack_hand(mob/user)
	add_fingerprint(user)
	if(manifest)
		tear_manifest(user)
	else
		to_chat(user, "<span class='warning'>I need a crowbar to pry this open!</span>")

/obj/structure/closet/crate/large/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_CROWBAR)
		if(manifest)
			tear_manifest(user)

		user.visible_message("<span class='notice'>[user] pries \the [src] open.</span>", \
							 "<span class='notice'>I pry open \the [src].</span>", \
							 "<span class='hear'>I hear splitting wood.</span>")
		playsound(src.loc, 'sound/blank.ogg', 75, TRUE)

		var/turf/T = get_turf(src)
		for(var/i in 1 to material_drop_amount)
			new material_drop(src)
		for(var/atom/movable/AM in contents)
			AM.forceMove(T)

		qdel(src)

	else
		if(user.used_intent.type == INTENT_HARM)	//Only return  ..() if intent is harm, otherwise return 0 or just end it.
			return ..()						//Stops it from opening and turning invisible when items are used on it.

		else
			to_chat(user, "<span class='warning'>I need a crowbar to pry this open!</span>")
			return FALSE //Just stop. Do nothing. Don't turn into an invisible sprite. Don't open like a locker.
					//The large crate has no non-attack interactions other than the crowbar, anyway.
