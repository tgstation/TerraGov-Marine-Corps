/* SURGERY STEPS */

GLOBAL_LIST_EMPTY(surgery_steps)

/datum/surgery_step
	var/priority = 0 //Steps with higher priority will be attempted first. Accepts decimals

	//Provisional priority list
	//0 : Generic (Incision, Bones, Internal Bleeding, Limb Removal, Cautery)
	//X + 0.1 : Upgrades
	//1 : Generic Priority (Necrosis, Encased Surgery, Cavities, Implants, Reattach)
	//2 : Sub-Surgeries (Mouth and Eyes)
	//3 : Special surgeries (Embryos, Bone Chips, Hematoma)

	var/list/allowed_tools = null //Array of type path referencing tools that can be used for this step, and how well are they suited for it
	var/list/allowed_species = null //List of names referencing species that this step applies to.
	var/list/disallowed_species = null



	var/min_duration = 0 //Minimum duration of the step
	var/max_duration = 0 //Maximum duration of the step

	var/can_infect = 0 //Evil infection stuff that will make everyone hate me
	var/blood_level = 0 //How much blood this step can get on surgeon. 1 - hands, 2 - full body

	//Returns how well tool is suited for this step
	proc/tool_quality(obj/item/tool)
		for(var/T in allowed_tools)
			if(istype(tool, T))
				return allowed_tools[T]
		return 0

//Checks if this step applies to the user mob at all
/datum/surgery_step/proc/is_valid_target(mob/living/carbon/target)
	if(!hasorgans(target))
		return 0
	if(allowed_species)
		for(var/species in allowed_species)
			if(target.species.name == species)
				return 1

	if(disallowed_species)
		for(var/species in disallowed_species)
			if(target.species.name == species)
				return 0
	return 1


//Checks whether this step can be applied with the given user and target
/datum/surgery_step/proc/can_use(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/limb/affected, only_checks)
	return 0

//Does stuff to begin the step, usually just printing messages. Moved germs transfering and bloodying here too
/datum/surgery_step/proc/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(can_infect && affected)
		spread_germs_to_organ(affected, user)
	if(ishuman(user) && prob(60))
		var/mob/living/carbon/human/H = user
		if(blood_level)
			H.bloody_hands(target, 0)
		if(blood_level > 1)
			H.bloody_body(target, 0)


//Does stuff to end the step, which is normally print a message + do whatever this step changes
/datum/surgery_step/proc/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	return

//Stuff that happens when the step fails
/datum/surgery_step/proc/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	return null

proc/spread_germs_to_organ(datum/limb/E, mob/living/carbon/human/user)
	if(!istype(user) || !istype(E))
		return

	//Gloves
	if(user.gloves)
		if(istype(user.gloves, /obj/item/clothing/gloves/latex))
			E.germ_level += user.gloves.germ_level * 0.1
		else if(user.gloves.germ_level && user.gloves.germ_level > 60)
			E.germ_level += user.gloves.germ_level * 0.2
	else
		E.germ_level += user.germ_level * 0.33

	//Masks
	if(user.wear_mask)
		if(istype(user.wear_mask, /obj/item/clothing/mask/cigarette))
			E.germ_level += user.germ_level * 1
		else if(istype(user.wear_mask, /obj/item/clothing/mask/surgical))
			E.germ_level += user.wear_mask.germ_level * 0.1
		else
			E.germ_level += user.wear_mask.germ_level * 0.2
	else
		E.germ_level += user.germ_level * 0.33

	//Suits
	if(user.wear_suit)
		if(istype(user.wear_suit, /obj/item/clothing/suit/surgical))
			E.germ_level += user.germ_level * 0.1
		else
			E.germ_level += user.germ_level * 0.2
	else
		E.germ_level += user.germ_level * 0.33

	if(locate(/obj/structure/bed/roller, E.owner.loc))
		E.germ_level += 75
	else if(locate(/obj/structure/table/, E.owner.loc))
		E.germ_level += 100


proc/do_surgery(mob/living/carbon/M, mob/living/user, obj/item/tool)
	if(!istype(M))
		return 0
	if(user.a_intent == INTENT_HARM) //Check for Hippocratic Oath
		return 0
	if(user.do_actions) //already doing an action
		return 1
	if(user.skills.getRating("surgery") < SKILL_SURGERY_PROFESSIONAL)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out how to operate [M].</span>",
		"<span class='notice'>You fumble around figuring out how to operate [M].</span>")
		var/fumbling_time = max(0,SKILL_TASK_FORMIDABLE - ( 8 SECONDS * user.skills.getRating("surgery") )) // 20 secs non-trained, 12 amateur, 4 trained, 0 prof
		if(fumbling_time && !do_after(user, fumbling_time, TRUE, M, BUSY_ICON_UNSKILLED))
			return
	var/datum/limb/affected = user.client.prefs.toggles_gameplay & RADIAL_MEDICAL ? radial_medical(M, user) : M.get_limb(user.zone_selected)
	if(!affected)
		return TRUE
	if(affected.in_surgery_op) //two surgeons can't work on same limb at same time
		to_chat(user, "<span class='warning'>You can't operate on the patient's [affected.display_name] while it's already being operated on.</span>")
		return TRUE

	for(var/i in GLOB.surgery_steps)
		var/datum/surgery_step/S = i
		//Check if tool is right or close enough, and the target mob valid, and if this step is possible
		if(S.tool_quality(tool) && S.is_valid_target(M))
			var/step_is_valid = S.can_use(user, M, user.zone_selected, tool, affected)
			if(step_is_valid)
				if(step_is_valid == SPECIAL_SURGERY_INVALID) //This is a failure that already has a message for failing.
					return 1
				affected.in_surgery_op = TRUE
				S.begin_step(user, M, user.zone_selected, tool, affected) //Start on it
				//We had proper tools! (or RNG smiled.) and user did not move or change hands.

				//Success multiplers!
				var/multipler = 1 //1 = 100%
				if(locate(/obj/structure/bed/roller, M.loc))
					multipler -= 0.10
				else if(locate(/obj/structure/table/, M.loc))
					multipler -= 0.20
				if(M.stat == CONSCIOUS)//If not on anesthetics or not unconsious
					multipler -= 0.5
					switch(M.reagent_pain_modifier)
						if(PAIN_REDUCTION_MEDIUM to PAIN_REDUCTION_HEAVY)
							multipler += 0.15
						if(PAIN_REDUCTION_HEAVY to PAIN_REDUCTION_VERY_HEAVY)
							multipler += 0.25
						if(PAIN_REDUCTION_VERY_HEAVY to PAIN_REDUCTION_FULL)
							multipler += 0.40
						if(PAIN_REDUCTION_FULL to INFINITY)
							multipler += 0.45
					if(M.shock_stage > 100) //Being near to unconsious is good in this case
						multipler += 0.25
				if(issynth(M))
					multipler = 1

				//calculate step duration
				var/step_duration = max(0.5 SECONDS, rand(S.min_duration, S.max_duration) - 1 SECONDS * user.skills.getRating("surgery"))

				//Multiply tool success rate with multipler
				if(do_mob(user, M, step_duration, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL, extra_checks = CALLBACK(user, /mob.proc/break_do_after_checks, null, null, user.zone_selected)) && prob(S.tool_quality(tool) * CLAMP01(multipler)))
					if(S.can_use(user, M, user.zone_selected, tool, affected, TRUE)) //to check nothing changed during the do_mob
						S.end_step(user, M, user.zone_selected, tool, affected) //Finish successfully

				else if((tool in user.contents) && user.Adjacent(M)) //Or
					if(M.stat == CONSCIOUS) //If not on anesthetics or not unconsious, warn player
						if(ishuman(M))
							var/mob/living/carbon/human/H = M
							if(!(H.species.species_flags & NO_PAIN))
								M.emote("pain")
						to_chat(user, "<span class='danger'>[M] moved during the surgery! Use anesthetics!</span>")
					S.fail_step(user, M, user.zone_selected, tool, affected) //Malpractice
				else //This failing silently was a pain.
					to_chat(user, "<span class='warning'>You must remain close to your patient to conduct surgery.</span>")
				affected.in_surgery_op = FALSE
				return 1				   //Don't want to do weapony things after surgery

	if(user.a_intent == INTENT_HELP)
		to_chat(user, "<span class='warning'>You can't see any useful way to use \the [tool] on [M].</span>")
		return 1
	return 0

//Comb Sort. This works apparently, so we're keeping it that way
/proc/sort_surgeries()
	var/gap = length(GLOB.surgery_steps)
	var/swapped = 1
	while(gap > 1 || swapped)
		swapped = 0
		if(gap > 1)
			gap = round(gap / 1.247330950103979)
		if(gap < 1)
			gap = 1
		for(var/i = 1; gap + i <= length(GLOB.surgery_steps); i++)
			var/datum/surgery_step/l = GLOB.surgery_steps[i]		//Fucking hate
			var/datum/surgery_step/r = GLOB.surgery_steps[gap+i]	//how lists work here
			if(l.priority < r.priority)
				GLOB.surgery_steps.Swap(i, gap + i)
				swapped = 1



/datum/surgery_status/
	var/eyes	=	0
	var/face	=	0
	var/head_reattach = 0
	var/current_organ = "organ"
	var/in_progress = 0
	var/is_same_target = "" //Safety check to prevent surgery juggling
	var/necro = 0
