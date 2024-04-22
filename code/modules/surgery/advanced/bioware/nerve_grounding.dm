/datum/surgery/advanced/bioware/nerve_grounding
	name = "Nerve Grounding"
	desc = ""
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/ground_nerves,
				/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)
	bioware_target = BIOWARE_NERVES

/datum/surgery_step/ground_nerves
	name = "ground nerves"
	accept_hand = TRUE
	time = 155

/datum/surgery_step/ground_nerves/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>I start rerouting [target]'s nerves.</span>",
		"<span class='notice'>[user] starts rerouting [target]'s nerves.</span>",
		"<span class='notice'>[user] starts manipulating [target]'s nervous system.</span>")

/datum/surgery_step/ground_nerves/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>I successfully reroute [target]'s nervous system!</span>",
		"<span class='notice'>[user] successfully reroutes [target]'s nervous system!</span>",
		"<span class='notice'>[user] finishes manipulating [target]'s nervous system.</span>")
	new /datum/bioware/grounded_nerves(target)
	return TRUE

/datum/bioware/grounded_nerves
	name = "Grounded Nerves"
	desc = ""
	mod_type = BIOWARE_NERVES

/datum/bioware/grounded_nerves/on_gain()
	..()
	ADD_TRAIT(owner, TRAIT_SHOCKIMMUNE, "grounded_nerves")

/datum/bioware/grounded_nerves/on_lose()
	..()
	REMOVE_TRAIT(owner, TRAIT_SHOCKIMMUNE, "grounded_nerves")
