// Tools used for research
/obj/item/tool/research/xeno_analyzer
	name = "xenomorph analyzer"
	desc = "A tool for scanning objects for research material."
	icon = 'icons/obj/items/surgery_tools.dmi'
	icon_state = "predator_bonesaw"
	var/skill_threshold = SKILL_MEDICAL_EXPERT
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

	var/research_delay_temp = research_delay

	if(user.skills.getRating("medical") < skill_threshold)
		research_delay_temp += 4 SECONDS

	if(!do_after(user, research_delay_temp, TRUE, target_xeno, BUSY_ICON_FRIENDLY, null, PROGRESS_BRASS))
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
