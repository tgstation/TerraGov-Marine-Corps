/* SURGERY STEPS */

/datum/surgery_step
	var/priority = 0 //Steps with higher priority will be attempted first. Accepts decimals

	//Provisional priority list
	//0 : Generic (Incision, Bones, Internal Bleeding, Limb Removal, Cautery)
	//X + 0.1 : Upgrades
	//1 : Generic Priority (Necrosis, Encased Surgery, Cavities, Implants, Reattach)
	//2 : Sub-Surgeries (Mouth and Eyes)
	//3 : Special surgeries (Embryos, Bone Chips, Hematoma)

	var/list/allowed_tools = null //Array of type path referencing tools that can be used for this step, and how well are they suited for it
	var/list/allowed_species = null //List of names referencing mutantraces that this step applies to.
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
	return

//Does stuff to end the step, which is normally print a message + do whatever this step changes
/datum/surgery_step/proc/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	return

//Stuff that happens when the step fails
/datum/surgery_step/proc/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	return null

proc/spread_germs_to_organ(datum/limb/E, mob/living/carbon/human/user)
	if(!istype(user) || !istype(E)) return

	//Gloves
	if(user.gloves)
		if(user.gloves.germ_level && user.gloves.germ_level > 60)
			E.germ_level += user.gloves.germ_level / 2
	else if(user.germ_level)
		E.germ_level += user.germ_level / 2

	//Masks
	if(user.wear_mask)
		if(user.germ_level && istype(user.wear_mask, /obj/item/clothing/mask/cigarette))
			E.germ_level += user.germ_level + 200  // fuck you smoking doctors
		else if(user.wear_mask.germ_level && !istype(user.wear_mask, /obj/item/clothing/mask/surgical) && prob(30))
			E.germ_level += user.wear_mask.germ_level / 2
	else if(user.germ_level && prob(60))
		E.germ_level += user.germ_level / 2

	if(locate(/obj/structure/bed/roller, E.owner.loc))
		E.germ_level += 100
	else if(locate(/obj/structure/table/, E.owner.loc))
		E.germ_level += 200

proc/do_surgery(mob/living/carbon/M, mob/living/user, obj/item/tool)
	if(!istype(M))
		return 0
	if(user.a_intent == "harm") //Check for Hippocratic Oath
		return 0
	if(user.action_busy) //already doing an action
		return 1
	if(user.mind && user.mind.cm_skills && user.mind.cm_skills.surgery < SKILL_SURGERY_TRAINED)
		user << "<span class='warning'>You have no idea how to do surgery...</span>"
		return 1
	var/datum/limb/affected = M.get_limb(user.zone_selected)
	if(!affected)
		return 0
	if(affected.in_surgery_op) //two surgeons can't work on same limb at same time
		user << "<span class='warning'>You can't operate on the patient's [affected.display_name] while it's already being operated on.</span>"
		return 1

	for(var/datum/surgery_step/S in surgery_steps)
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
					if(M.shock_stage > 100) //Being near to unconsious is good in this case
						multipler += 0.25
				if(istype(M.loc, /turf/open/shuttle/dropship))
					multipler -= 0.65
				Clamp(multipler, 0, 1)

				if(isSynth(M) || isYautja(M)) multipler = 1

				//calculate step duration
				var/step_duration = rand(S.min_duration, S.max_duration)
				if(user.mind && user.mind.cm_skills)
					//1 second reduction per level above minimum for performing surgery
					step_duration = max(5, step_duration - 10*user.mind.cm_skills.surgery)

				//Multiply tool success rate with multipler
				if(prob(S.tool_quality(tool) * multipler) &&  do_mob(user, M, step_duration, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL, TRUE))
					if(S.can_use(user, M, user.zone_selected, tool, affected, TRUE)) //to check nothing changed during the do_mob
						S.end_step(user, M, user.zone_selected, tool, affected) //Finish successfully

				else if((tool in user.contents) && user.Adjacent(M)) //Or
					if(M.stat == CONSCIOUS) //If not on anesthetics or not unconsious, warn player
						if(ishuman(M))
							var/mob/living/carbon/human/H = M
							if(!(H.species.flags & NO_PAIN))
								M.emote("pain")
						user << "<span class='danger'>[M] moved during the surgery! Use anesthetics!</span>"
					S.fail_step(user, M, user.zone_selected, tool, affected) //Malpractice
				else //This failing silently was a pain.
					user << "<span class='warning'>You must remain close to your patient to conduct surgery.</span>"
				affected.in_surgery_op = FALSE
				return 1				   //Don't want to do weapony things after surgery

	if(user.a_intent == "help")
		user << "<span class='warning'>You can't see any useful way to use \the [tool] on [M].</span>"
		return 1
	return 0

//Comb Sort. This works apparently, so we're keeping it that way
proc/sort_surgeries()
	var/gap = surgery_steps.len
	var/swapped = 1
	while(gap > 1 || swapped)
		swapped = 0
		if(gap > 1)
			gap = round(gap / 1.247330950103979)
		if(gap < 1)
			gap = 1
		for(var/i = 1; gap + i <= surgery_steps.len; i++)
			var/datum/surgery_step/l = surgery_steps[i]		//Fucking hate
			var/datum/surgery_step/r = surgery_steps[gap+i]	//how lists work here
			if(l.priority < r.priority)
				surgery_steps.Swap(i, gap + i)
				swapped = 1



/datum/surgery_status/
	var/eyes	=	0
	var/face	=	0
	var/head_reattach = 0
	var/current_organ = "organ"
	var/in_progress = 0
	var/is_same_target = "" //Safety check to prevent surgery juggling
	var/necro = 0
