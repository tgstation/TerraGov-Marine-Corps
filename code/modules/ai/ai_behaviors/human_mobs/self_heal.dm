/datum/ai_behavior/human
	///Chat lines for trying to heal
	var/list/healing_chat = list("Healing, cover me!", "Healing over here.", "Where's the damn medic?", "Medic!", "Treating wounds.", "It's just a flesh wound.", "Need a little help here!", "Cover me!.")
	///Chat lines for retreating on low health
	var/list/retreating_chat = list("Falling back!", "Cover me, I'm hit!", "I'm hit!", "Medic!", "Disengaging!", "Help me!", "Need a little help here!", "Tactical withdrawal.", "Repositioning.")

///Reacts if the mob is below the min health threshold
/datum/ai_behavior/human/proc/check_for_critical_health(datum/source, damage)
	SIGNAL_HANDLER
	COOLDOWN_START(src, ai_damage_cooldown, 5 SECONDS)
	if(current_action == MOVING_TO_SAFETY)
		return
	var/mob/living/living_mob = mob_parent
	if(!(human_ai_behavior_flags & HUMAN_AI_SELF_HEAL) || living_mob.health - damage > minimum_health * living_mob.maxHealth)
		return
	if(mob_parent.incapacitated() || mob_parent.lying_angle) //todo: maybe remove or change this when we add team healing
		return
	if(!check_hazards())
		return
	var/atom/next_target = get_nearest_target(mob_parent, target_distance, TARGET_HOSTILE, mob_parent.faction, need_los = TRUE)
	if(!next_target)
		INVOKE_ASYNC(src, PROC_REF(try_heal))
		return
	if(prob(50))
		try_speak(pick(retreating_chat))
	set_run(TRUE)
	target_distance = 12
	change_action(MOVING_TO_SAFETY, next_target, list(INFINITY))

///Will try healing if possible
/datum/ai_behavior/human/proc/try_heal()
	var/mob/living/living_parent = mob_parent
	if(living_parent.on_fire)
		living_parent.do_resist()
		return

	if(!COOLDOWN_CHECK(src, ai_damage_cooldown))
		return

	if(prob(75))
		try_speak(pick(healing_chat))
	var/list/dam_list = list(
		BRUTE = living_parent.getBruteLoss(),
		BURN = living_parent.getFireLoss(),
		TOX = living_parent.getToxLoss(),
		OXY = living_parent.getOxyLoss(),
		CLONE = living_parent.getCloneLoss(),
		PAIN = 0,
	)

	change_action(MOB_HEALING)

	if(iscarbon(mob_parent))
		var/mob/living/carbon/carbon_parent = mob_parent
		dam_list[PAIN] = carbon_parent.getShock_Stage() * 3 //pain is pretty important, but has low numbers and takes time to change

	var/list/priority_list = sortTim(dam_list.Copy(), /proc/cmp_numeric_dsc, TRUE)
	for(var/damtype in priority_list)
		if(dam_list[damtype] <= 15)
			continue
		if(do_heal(damtype))
			continue

	if(ishuman(mob_parent))
		var/mob/living/carbon/human/human_parent = mob_parent
		var/list/broken_limbs = list()
		for(var/datum/limb/limb AS in human_parent.limbs)
			if(!(limb.limb_status & LIMB_BROKEN) || (limb.limb_status & LIMB_SPLINTED))
				continue
			broken_limbs += limb
		for(var/broken_limb in broken_limbs)
			if(!do_splint(broken_limb))
				//send sig to call for help splinting
				break

	change_action(MOVING_TO_NODE)

///Tries to heal damage of a given type
/datum/ai_behavior/human/proc/do_heal(damtype)
	var/obj/item/heal_item
	var/list/med_list

	switch(damtype)
		if(BRUTE)
			med_list = mob_inventory.brute_list
		if(BURN)
			med_list = mob_inventory.burn_list
		if(TOX)
			med_list = mob_inventory.tox_list
		if(OXY)
			med_list = mob_inventory.oxy_list
		if(CLONE)
			med_list = mob_inventory.clone_list
		if(PAIN)
			med_list = mob_inventory.pain_list

	for(var/obj/item/stored_item AS in med_list)
		if(!stored_item.ai_should_use(mob_parent, mob_parent))
			continue
		heal_item = stored_item
		break

	if(!heal_item)
		return FALSE
	heal_item.ai_use(mob_parent, mob_parent)
	return TRUE

///Tries to splint a limb
/datum/ai_behavior/human/proc/do_splint(datum/limb/broken_limb)
	var/obj/item/stack/medical/splint/splint = locate(/obj/item/stack/medical/splint) in mob_inventory.medical_list
	if(!splint)
		return FALSE
	mob_parent.zone_selected = broken_limb.name //why god do we rely on the limb name, which isnt a define?
	if(splint.attack(mob_parent, mob_parent))
		. = TRUE
	mob_parent.zone_selected = BODY_ZONE_CHEST

//TODO: probs move these - more than just medical relevant

///Checks if the AI can or should use this
/obj/item/proc/ai_should_use(mob/living/target, mob/living/user)
	return TRUE

///AI uses this item in some manner
/obj/item/proc/ai_use(mob/living/target, mob/living/user)
	return FALSE

/obj/item/stack/medical/ai_use(mob/living/target, mob/living/user)
	attack(target, user) //attack chain is a bit funny between different medical items like reagent containers below

/obj/item/stack/medical/heal_pack/ai_should_use(mob/living/target, mob/living/user)
	if(!ishuman(target))
		return FALSE
	var/mob/living/carbon/human/human_mob = target
	for(var/limb AS in human_mob.limbs)
		if(can_heal_limb(limb))
			return TRUE
	return FALSE

/obj/item/reagent_containers/ai_should_use(mob/living/target, mob/living/user)
	for(var/datum/reagent/reagent AS in reagents.reagent_list)
		if(reagent.volume + target.reagents.get_reagent_amount(reagent.type) > reagent.overdose_threshold)
			return FALSE
	return TRUE

/obj/item/reagent_containers/ai_use(mob/living/target, mob/living/user)
	afterattack(target, user, TRUE)

/obj/item/reagent_containers/hypospray/ai_should_use(mob/living/target, mob/living/user)
	if(!length(reagents.reagent_list)) //todo: discard if empty
		return FALSE
	for(var/datum/reagent/reagent AS in reagents.reagent_list)
		if((reagent.volume / reagents.total_volume * amount_per_transfer_from_this) + target.reagents.get_reagent_amount(reagent.type) > reagent.overdose_threshold)
			return FALSE
	return TRUE
