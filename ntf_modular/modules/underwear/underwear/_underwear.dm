//Fuck it we making underwear actual items
/obj/item/clothing/underwear
	name = "Underwear"
	desc = "If you're reading this, something went wrong."
	icon = 'ntf_modular/modules/underwear/underwear/underwear.dmi' //if someone is willing to make proper inventory sprites that'd be very cash money
	//body_parts_covered = GROIN
	equip_slot_flags = ITEM_SLOT_UNDERWEAR
	//supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/underwear/Move(atom/newloc, direction, glide_size_override)
	. = ..()
	setDir(SOUTH)
