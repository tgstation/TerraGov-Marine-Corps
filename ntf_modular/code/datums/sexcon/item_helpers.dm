/proc/get_candle_in_either_hand(mob/living/carbon/human/user)
	for(var/obj/item/thing in user.get_held_items())
		if(thing == null)
			continue
		if(!istype(thing, /obj/item/tool/candle))
			continue
		return thing
	return null
