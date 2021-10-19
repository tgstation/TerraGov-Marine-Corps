// Tools used for research
/obj/item/tool/research
	var/skill_type = "medical"
	var/skill_threshold = SKILL_MEDICAL_EXPERT

/obj/item/tool/research/xeno_analyzer
	name = "xenomorph analyzer"
	desc = "A tool for scanning objects for research material."
	icon = 'icons/obj/items/surgery_tools.dmi'
	icon_state = "predator_bonesaw"
	var/research_delay = 2 SECONDS
	var/list/xeno_tier_rewards = list(
		XENO_TIER_ONE = list(
			/obj/item/research_resource/xeno/tier_one,
		),
		XENO_TIER_TWO = list(
			/obj/item/research_resource/xeno/tier_two,
		),
		XENO_TIER_THREE = list(
			/obj/item/research_resource/xeno/tier_three,
		),
		XENO_TIER_FOUR = list(
			/obj/item/research_resource/xeno/tier_four,
		),
	)

/obj/item/tool/research/xeno_analyzer/attack(mob/living/M, mob/living/user)
	if(!isxeno(M))
		return ..()

	var/mob/living/carbon/xenomorph/target_xeno = M

	if(target_xeno.researched)
		to_chat(user, span_notice("[target_xeno] has already been probed."))
		return ..()

	if(user.skills.getRating(skill_type) < skill_threshold)
		to_chat(user, "You need higher [skill_type] skill.")

	if(!do_after(user, research_delay, TRUE, target_xeno, BUSY_ICON_FRIENDLY, null, PROGRESS_BRASS))
		return ..()

	if(target_xeno.researched)
		to_chat(user, span_notice("[target_xeno] has already been probed."))
		return ..()

	var/list/xeno_rewards = xeno_tier_rewards[target_xeno.tier]

	var/reward_typepath = xeno_rewards[rand(1, xeno_rewards.len)]
	var/obj/reward = new reward_typepath
	reward.forceMove(get_turf(user))
	target_xeno.researched = TRUE

	return ..()

/obj/item/tool/research/excavation_tool
	name = "subterrain scanner and excavator"
	desc = "A tool for locating and uncovering underground resources."
	icon = 'icons/obj/items/surgery_tools.dmi'
	icon_state = "alien_drill"

/obj/item/tool/research/excavation_tool/unique_action(mob/user)
	. = ..()
	if(user.skills.getRating(skill_type) < skill_threshold)
		to_chat(user, "You need higher [skill_type] skill.")
		return

	var/turf/center_turf = get_turf(user.loc)

	if(!do_after(user, 10 SECONDS, TRUE, center_turf, BUSY_ICON_FRIENDLY, null, PROGRESS_BRASS))
		return ..()

	var/list/checked_turfs = filled_turfs(center_turf, 3, "circle")
	var/excavation_site
	for(var/turf/turf_to_check as() in checked_turfs)
		excavation_site = locate(/obj/effect/landmark/excavation_site) in turf_to_check
		if(excavation_site)
			break

	if (!excavation_site)
		say(span_notice("<b>No excavation site found at location.</b>"))
		return

	say(span_notice("<b>Excavation site found, escavating...</b>"))
	SSexcavation.excavate_area(get_area(excavation_site))
