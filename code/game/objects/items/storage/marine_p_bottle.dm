//Marine-Grade pill bottles. Infinite supply variants of pill packets with a delay

/obj/item/storage/pill_bottle/marine
	name = "\improper Marine-grade pill bottle"
	desc = "Contains pills. Clearly made of cheaper material than normal, it's a bit harder to get the pills out."
	icon_state = "packet_canister"
	flags_storage = BYPASS_VENDOR_CHECK //Might as well let you restock these since they are infinite
	access_delay = 1.5 SECONDS
	///Skill requirement to bypass the struggle
	var/skill_needed = SKILL_MEDICAL_PRACTICED

/obj/item/storage/pill_bottle/marine/should_access_delay(obj/item/item, mob/user, taking_out)
	if(!taking_out) // Always allow items to be tossed in instantly
		return FALSE
	if(!user)
		return FALSE
	if(user.skills.getRating(SKILL_MEDICAL) >= skill_needed) //If you have the skill, it's instant
		return FALSE
	return TRUE

/obj/item/storage/pill_bottle/marine/bicaridine
	name = "bicaridine pill bottle"
	desc = "Contains pills that heal cuts and bruises, but cause slight pain. Take two to heal faster, but have slightly more pain.\
	The cheaper bottle quality makes it hard to take pills out."
	pill_type_to_fill = /obj/item/reagent_containers/pill/bicaridine
	greyscale_colors = "#DA0000#ffffff"
	description_overlay = "Bi"

/obj/item/storage/pill_bottle/marine/kelotane
	name = "kelotane pill bottle"
	desc = "Contains pills that heal burns, but cause slight pain. Take two to heal faster, but have slightly more pain.\
	The cheaper bottle quality makes it hard to take pills out."
	pill_type_to_fill = /obj/item/reagent_containers/pill/kelotane
	greyscale_colors = "#CC9900#FFFFFF"
	description_overlay = "Ke"

/obj/item/storage/pill_bottle/marine/tramadol
	name = "tramadol pill bottle"
	desc = "Contains pills that numb pain. Take two for a stronger effect at the cost of a toxic effect.\
	The cheaper bottle quality makes it hard to take pills out."
	pill_type_to_fill = /obj/item/reagent_containers/pill/tramadol
	greyscale_colors = "#8a8686#ffffff"
	description_overlay = "Ta"

/obj/item/storage/pill_bottle/marine/tricordrazine
	name = "tricordrazine pill bottle"
	desc = "Contains pills capable of minorly healing all main types of damages.\
	The cheaper bottle quality makes it hard to take pills out."
	icon_state = "pill_canistercomplete"
	pill_type_to_fill = /obj/item/reagent_containers/pill/tricordrazine
	greyscale_colors = "#f8f8f8#ffffff"
	greyscale_config = /datum/greyscale_config/pillbottleround
	description_overlay = "Ti"

/obj/item/storage/pill_bottle/marine/dylovene
	name = "dylovene pill bottle"
	desc = "Contains pills that heal toxic damage and purge toxins and neurotoxins of all kinds.\
	The cheaper bottle quality makes it hard to take pills out."
	pill_type_to_fill = /obj/item/reagent_containers/pill/dylovene
	greyscale_colors = "#669900#ffffff"
	description_overlay = "Dy"

/obj/item/storage/pill_bottle/marine/paracetamol
	name = "paracetamol pill bottle"
	desc = "Contains pills that mildly numb pain. Take two for a slightly stronger effect.\
	The cheaper bottle quality makes it hard to take pills out."
	pill_type_to_fill = /obj/item/reagent_containers/pill/paracetamol
	greyscale_colors = "#cac5c5#ffffff"
	greyscale_config = /datum/greyscale_config/pillbottlebox
	greyscale_colors = "#f8f4f8#ffffff"
	description_overlay = "Pa"

/obj/item/storage/pill_bottle/marine/isotonic
	name = "isotonic pill bottle"
	desc = "Contains pills that stimulate the regeneration of lost blood.\
	The cheaper bottle quality makes it hard to take pills out."
	pill_type_to_fill = /obj/item/reagent_containers/pill/isotonic
	greyscale_colors = "#5c0e0e#ffffff"
	description_overlay = "Is"




