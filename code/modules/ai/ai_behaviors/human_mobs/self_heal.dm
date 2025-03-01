/datum/ai_behavior/human
	///Chat lines for trying to heal
	var/list/self_heal_chat = list("Healing, cover me!", "Healing over here.", "Where's the damn medic?", "Medic!", "Treating wounds.", "It's just a flesh wound.", "Need a little help here!", "Cover me!.")
	///Chat lines for retreating on low health
	var/list/retreating_chat = list("Falling back!", "Cover me, I'm hit!", "I'm hit!", "Medic!", "Disengaging!", "Help me!", "Need a little help here!", "Tactical withdrawal.", "Repositioning.")

///Will try healing if possible
/datum/ai_behavior/human/proc/try_heal()
	var/mob/living/living_parent = mob_parent
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_AI_NEED_HEAL, mob_parent)
	if(living_parent.on_fire)
		living_parent.do_resist()
		return

	if(!COOLDOWN_CHECK(src, ai_damage_cooldown))
		return

	if(prob(75))
		try_speak(pick(self_heal_chat))
	var/list/dam_list = list(
		BRUTE = living_parent.getBruteLoss(),
		BURN = living_parent.getFireLoss(),
		TOX = living_parent.getToxLoss(),
		OXY = living_parent.getOxyLoss(),
		CLONE = living_parent.getCloneLoss(),
		PAIN = 0,
	)

	human_ai_state_flags |= HUMAN_AI_SELF_HEALING

	if(iscarbon(mob_parent))
		var/mob/living/carbon/carbon_parent = mob_parent
		dam_list[PAIN] = carbon_parent.getShock_Stage() * 3 //pain is pretty important, but has low numbers and takes time to change

	dam_list = sortTim(dam_list, /proc/cmp_numeric_dsc, TRUE)
	for(var/dam_type in dam_list)
		if(dam_list[dam_type] <= 15)
			continue
		if(heal_by_type(mob_parent, dam_type))
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
				break

	human_ai_state_flags &= ~HUMAN_AI_SELF_HEALING
	late_initialize()

///Tries to splint a limb
/datum/ai_behavior/human/proc/do_splint(datum/limb/broken_limb, target = mob_parent)
	var/obj/item/stack/medical/splint/splint = locate(/obj/item/stack/medical/splint) in mob_inventory.medical_list
	if(!splint)
		return FALSE
	mob_parent.zone_selected = broken_limb.name //why god do we rely on the limb name, which isnt a define?
	if(splint.attack(target, mob_parent))
		. = TRUE
	mob_parent.zone_selected = BODY_ZONE_CHEST
