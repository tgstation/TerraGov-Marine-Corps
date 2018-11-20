/obj/item/clothing/suit/equipped(mob/M)
	check_limb_support()
	return ..()

/obj/item/clothing/suit/dropped()
	check_limb_support()
	return ..()

/obj/item/clothing/suit/Dispose()
	check_limb_support()
	return ..()

// Some space suits are equipped with reactive membranes that support
// broken limbs - at the time of writing, only the ninja suit, but
// I can see it being useful for other suits as we expand them. ~ Z
// The actual splinting occurs in /datum/limb/proc/fracture()
/obj/item/clothing/suit/proc/check_limb_support()

	// If this isn't set, then we don't need to care.
	if(!supporting_limbs?.len)
		return

	var/mob/living/carbon/human/H = loc

	// If the holder isn't human, or the holder IS and is wearing the suit, it keeps supporting the limbs.
	if(!istype(H) || H.wear_suit == src)
		return

	// Otherwise, remove the splints.
	for(var/datum/limb/E in supporting_limbs)
		E.status &= ~ LIMB_SPLINTED
	supporting_limbs = list()
