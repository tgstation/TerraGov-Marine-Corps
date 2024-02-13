#define RESEARCH_DELAY 2 SECONDS

/obj/item/tool/research/xeno_probe
	name = "xenomorph analyzer"
	desc = "A tool for analyzing xenomorphs for research material. Just click on a xenomorph. Can be used to befriend Newt."
	icon = 'icons/obj/items/surgery_tools.dmi'
	icon_state = "predator_bonesaw"
	///List of rewards for each xeno tier
	var/static/list/xeno_tier_rewards = list(
		XENO_TIER_ZERO = list(
			/obj/item/research_resource/xeno/tier_one,
		),
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

/obj/item/tool/research/xeno_probe/attack(mob/living/M, mob/living/user)
	if(!isxeno(M))
		return ..()

	var/mob/living/carbon/xenomorph/target_xeno = M

	var/list/xeno_rewards = xeno_tier_rewards[target_xeno.tier]
	if(!xeno_rewards)
		balloon_alert(user, "Can't research")
		return ..()

	if(HAS_TRAIT(target_xeno, TRAIT_RESEARCHED))
		balloon_alert(user, "Already probed")
		return ..()

	if(user.skills.getRating(SKILL_MEDICAL) < SKILL_MEDICAL_EXPERT)
		user.balloon_alert_to_viewers("Tries to find weak point on [target_xeno]")
		var/fumbling_time = 15 SECONDS - 2 SECONDS * user.skills.getRating(SKILL_MEDICAL)
		if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
			return ..()
	user.balloon_alert_to_viewers("Begins cutting [target_xeno]")
	if(!do_after(user, 5 SECONDS, NONE, src, BUSY_ICON_FRIENDLY))
		return ..()

	if(HAS_TRAIT(target_xeno, TRAIT_RESEARCHED))
		balloon_alert(user, "Already probed")
		return ..()

	var/reward_typepath = pick(xeno_rewards)
	var/obj/reward = new reward_typepath
	reward.forceMove(get_turf(user))
	ADD_TRAIT(target_xeno, TRAIT_RESEARCHED, TRAIT_RESEARCHED)

	return ..()

#undef RESEARCH_DELAY
