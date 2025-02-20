
GLOBAL_LIST_INIT(ai_brute_heal_items, list(
	/obj/item/reagent_containers/pill/bicaridine,
	/obj/item/reagent_containers/hypospray/autoinjector/bicaridine,
	/obj/item/reagent_containers/hypospray/advanced/bicaridine,
	/obj/item/reagent_containers/hypospray/autoinjector/combat,
	/obj/item/reagent_containers/pill/tricordrazine,
	/obj/item/reagent_containers/hypospray/advanced/tricordrazine,
	/obj/item/reagent_containers/hypospray/advanced/combat_advanced,
	/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced,
	/obj/item/reagent_containers/pill/meralyne,
	/obj/item/reagent_containers/hypospray/advanced/meralyne,
	/obj/item/reagent_containers/hypospray/advanced/meraderm,
	/obj/item/reagent_containers/hypospray/autoinjector/neuraline,
	/obj/item/reagent_containers/hypospray/autoinjector/russian_red,
	/obj/item/reagent_containers/hypospray/autoinjector/elite,
	/obj/item/stack/medical/heal_pack/gauze/sectoid,
	/obj/item/stack/medical/heal_pack/advanced/bruise_pack,
	/obj/item/stack/medical/heal_pack/gauze,
))

GLOBAL_LIST_INIT(ai_burn_heal_items, list(
	/obj/item/reagent_containers/pill/kelotane,
	/obj/item/reagent_containers/hypospray/autoinjector/kelotane,
	/obj/item/reagent_containers/hypospray/advanced/kelotane,
	/obj/item/reagent_containers/hypospray/autoinjector/combat,
	/obj/item/reagent_containers/pill/tricordrazine,
	/obj/item/reagent_containers/hypospray/advanced/tricordrazine,
	/obj/item/reagent_containers/hypospray/advanced/combat_advanced,
	/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced,
	/obj/item/reagent_containers/pill/dermaline,
	/obj/item/reagent_containers/hypospray/advanced/dermaline,
	/obj/item/reagent_containers/hypospray/advanced/meraderm,
	/obj/item/reagent_containers/hypospray/autoinjector/neuraline,
	/obj/item/reagent_containers/hypospray/autoinjector/russian_red,
	/obj/item/reagent_containers/hypospray/autoinjector/elite,
	/obj/item/stack/medical/heal_pack/gauze/sectoid,
	/obj/item/stack/medical/heal_pack/advanced/burn_pack,
	/obj/item/stack/medical/heal_pack/ointment,
))

GLOBAL_LIST_INIT(ai_tox_heal_items, list(
	/obj/item/reagent_containers/hypospray/autoinjector/antitox_mix,
	/obj/item/reagent_containers/pill/dylovene,
	/obj/item/reagent_containers/hypospray/advanced/dylovene,
	/obj/item/reagent_containers/hypospray/autoinjector/dylovene,
	/obj/item/reagent_containers/pill/tricordrazine,
	/obj/item/reagent_containers/hypospray/advanced/tricordrazine,
))

GLOBAL_LIST_INIT(ai_oxy_heal_items, list(
	/obj/item/reagent_containers/hypospray/autoinjector/dexalin,
	/obj/item/reagent_containers/pill/tricordrazine,
	/obj/item/reagent_containers/hypospray/advanced/tricordrazine,
))

GLOBAL_LIST_INIT(ai_clone_heal_items, list(
	/obj/item/reagent_containers/hypospray/autoinjector/rezadone,
	/obj/item/reagent_containers/hypospray/autoinjector/elite,
))

GLOBAL_LIST_INIT(ai_pain_heal_items, list(
	/obj/item/reagent_containers/pill/tramadol,
	/obj/item/reagent_containers/hypospray/autoinjector/tramadol,
	/obj/item/reagent_containers/hypospray/advanced/tramadol,
	/obj/item/reagent_containers/hypospray/autoinjector/combat,
	/obj/item/reagent_containers/hypospray/advanced/oxycodone,
	/obj/item/reagent_containers/hypospray/autoinjector/oxycodone,
	/obj/item/reagent_containers/hypospray/advanced/combat_advanced,
	/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced,
	/obj/item/reagent_containers/hypospray/autoinjector/neuraline,
	/obj/item/reagent_containers/hypospray/autoinjector/russian_red,
	/obj/item/reagent_containers/hypospray/autoinjector/elite,
))

GLOBAL_LIST_INIT(ai_damtype_to_heal_list, list(
	BRUTE = GLOB.ai_brute_heal_items,
	BURN = GLOB.ai_burn_heal_items,
	TOX = GLOB.ai_tox_heal_items,
	OXY = GLOB.ai_oxy_heal_items,
	CLONE = GLOB.ai_clone_heal_items,
	PAIN = GLOB.ai_pain_heal_items,
))

//obj/item/stack/medical/splint

/datum/ai_behavior/human
	var/list/healing_chat = list("Healing, cover me!", "Healing over here.", "Where's the damn medic?", "Medic!", "Treating wounds.", "It's just a flesh wound.", "Need a little help here!", "Cover me!.")

	var/list/retreating_chat = list("Falling back!", "Cover me, I'm hit!", "I'm hit!", "Medic!", "Disengaging!", "Help me!", "Need a little help here!", "Tactical withdrawal.", "Repositioning.")

///Will try healing if possible
/datum/ai_behavior/human/proc/try_heal()
	if(prob(75))
		try_speak(pick(healing_chat))
	var/mob/living/living_parent = mob_parent

	if(living_parent.on_fire)
		//extinguish proc so they use an extinguisher if they got it?
		living_parent.do_resist()
		return

	var/list/dam_list = list(
		BRUTE = living_parent.getBruteLoss(),
		BURN = living_parent.getFireLoss(),
		TOX = living_parent.getToxLoss(),
		OXY = living_parent.getOxyLoss(),
		CLONE = living_parent.getCloneLoss(),
		PAIN = 0,
	)

	if(iscarbon(mob_parent))
		var/mob/living/carbon/carbon_parent = mob_parent
		dam_list[PAIN] = carbon_parent.getShock_Stage() * 3 //pain is pretty important, but has low numbers and takes time to change

	var/dam_threshold = 15 //placeholder define
	var/list/priority_list = sortTim(dam_list.Copy(), /proc/cmp_numeric_dsc, TRUE)
	for(var/damtype in priority_list)
		if(dam_list[damtype] <= dam_threshold)
			return
		if(do_heal(damtype))
			continue //cycle through all dam types



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
		if(!stored_item.ai_should_use(mob_parent))
			continue
		heal_item = stored_item
		break

	if(!heal_item)
		return FALSE
	change_action(MOB_HEALING)
	heal_item.ai_use(mob_parent)
	change_action(MOVING_TO_NODE) //MOVING_TO_SAFETY
	return TRUE

/datum/ai_behavior/human/proc/check_for_critical_health(datum/source, damage)
	SIGNAL_HANDLER
	var/mob/living/living_mob = mob_parent
	if(!can_heal || living_mob.health - damage > minimum_health * living_mob.maxHealth)
		return
	var/atom/next_target = get_nearest_target(mob_parent, target_distance, TARGET_HOSTILE, mob_parent.faction)
	if(!next_target || !line_of_sight(mob_parent, next_target)) //no hostiles around
		try_heal()
		return
	if(prob(50))
		try_speak(pick(retreating_chat))
	target_distance = 15
	change_action(MOVING_TO_SAFETY, next_target, INFINITY)
	UnregisterSignal(mob_parent, COMSIG_HUMAN_DAMAGE_TAKEN)


//to move/////////////////////////
/obj/item/proc/ai_should_use(mob/living/ai_mob)
	return TRUE

//more than just medical relevant

/obj/item/proc/ai_use(mob/living/ai_mob)
	return FALSE

/obj/item/stack/medical/ai_use(mob/living/ai_mob)
	//attackself calls this but doesn't return anything
	attack(ai_mob, ai_mob)

/obj/item/stack/medical/heal_pack/ai_should_use(mob/living/ai_mob)
	if(!ishuman(ai_mob))
		return FALSE
	var/mob/living/carbon/human/human_mob = ai_mob
	for(var/limb AS in human_mob.limbs)
		if(can_heal_limb(limb))
			return TRUE
	return FALSE

/obj/item/reagent_containers/ai_should_use(mob/living/ai_mob)
	for(var/datum/reagent/reagent AS in reagents.reagent_list)
		if(reagent.volume + ai_mob.reagents.get_reagent_amount(reagent.type) > reagent.overdose_threshold)
			return FALSE
	return TRUE

/obj/item/reagent_containers/ai_use(mob/living/ai_mob)
	attack_self(ai_mob)

/obj/item/reagent_containers/hypospray/ai_should_use(mob/living/ai_mob)
	if(!length(reagents.reagent_list))
		return FALSE
	for(var/datum/reagent/reagent AS in reagents.reagent_list)
		if((reagent.volume / reagents.total_volume * amount_per_transfer_from_this) + ai_mob.reagents.get_reagent_amount(reagent.type) > reagent.overdose_threshold)
			return FALSE
	return TRUE
