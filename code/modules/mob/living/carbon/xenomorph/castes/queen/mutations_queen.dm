//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/healthy_bulwark
	name = "Healthy Bulwark"
	desc = "Bulwark no longer grants armor. Bulwark now grants overheal of 60/80/100 for entering the affected area for the first time. This overheal is subtracted when leaving the affected area or when Bulwark ends."
	/// For the first structure, the amount of Overheal that Bulwark should be giving.
	var/overheal_initial = 40
	/// For each structure, the amount of Overheal that Bulwark should be giving.
	var/overheal_per_structure = 20

/datum/mutation_upgrade/shell/healthy_bulwark/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Bulwark no longer grants armor. Bulwark now grants overheal of [get_overheal(new_amount)] for entering the affected area for the first time. This overheal is subtracted when leaving the affected area or when Bulwark ends."

/datum/mutation_upgrade/shell/healthy_bulwark/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/bulwark/bulwark_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/bulwark]
	if(!bulwark_ability)
		return
	bulwark_ability.armor_multiplier = 0
	bulwark_ability.flat_overheal += get_overheal(0)

/datum/mutation_upgrade/shell/healthy_bulwark/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/bulwark/bulwark_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/bulwark]
	if(!bulwark_ability)
		return
	bulwark_ability.armor_multiplier = initial(bulwark_ability.armor_multiplier)
	bulwark_ability.flat_overheal -= get_overheal(0)

/datum/mutation_upgrade/shell/healthy_bulwark/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/bulwark/bulwark_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/bulwark]
	if(!bulwark_ability)
		return
	bulwark_ability.flat_overheal += get_overheal(new_amount - previous_amount, FALSE)

/// Returns the amount of Overheal that Bulwark should be giving.
/datum/mutation_upgrade/shell/healthy_bulwark/proc/get_overheal(structure_count, include_initial = TRUE)
	return (include_initial ? overheal_initial : 0) + (overheal_per_structure * structure_count)

/datum/mutation_upgrade/shell/bulwark_zone
	name = "Bulwark Zone"
	desc = "Bulwark no longer requires you to channel, but ends when you leave the radius. It grants 50/60/70% of its original armor."
	/// For the first structure, the multiplier to add as Bulwark's initial armor multiplier to the ability.
	var/multiplier_initial = -0.6
	/// For each structure, the multiplier to add as Bulwark's initial armor multiplier to the ability.
	var/multiplier_per_structure = 0.1

/datum/mutation_upgrade/shell/bulwark_zone/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Bulwark no longer requires you to stand still, but ends when you leave the radius. It grants [PERCENT(1 + get_multiplier(new_amount))]% of its original armor."

/datum/mutation_upgrade/shell/bulwark_zone/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/bulwark/bulwark_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/bulwark]
	if(!bulwark_ability)
		return
	bulwark_ability.channel_required = FALSE
	bulwark_ability.armor_multiplier += initial(bulwark_ability.armor_multiplier) * get_multiplier(0)

/datum/mutation_upgrade/shell/bulwark_zone/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/bulwark/bulwark_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/bulwark]
	if(!bulwark_ability)
		return
	bulwark_ability.channel_required = initial(bulwark_ability.channel_required)
	bulwark_ability.armor_multiplier -= initial(bulwark_ability.armor_multiplier) * get_multiplier(0)

/datum/mutation_upgrade/shell/bulwark_zone/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/bulwark/bulwark_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/bulwark]
	if(!bulwark_ability)
		return
	bulwark_ability.armor_multiplier += initial(bulwark_ability.armor_multiplier) * get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier to add as Bulwark's initial armor multiplier to the ability.
/datum/mutation_upgrade/shell/bulwark_zone/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/alternative_sting
	name = "Alternative Sting"
	desc = "Ozelomelyn Sting is replaced with Neurotoxin Sting. Each interval gives 10/20/30% more chemicals."
	/// For each structure, the multiplier of Neurotoxin Sting's initial sting amount to add to the ability.
	var/multiplier_per_structure = 0.1

/datum/mutation_upgrade/spur/alternative_sting/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Ozelomelyn Sting is replaced with Neurotoxin Sting. Each interval gives [PERCENT(get_multiplier(new_amount))]% more chemicals."

/datum/mutation_upgrade/spur/alternative_sting/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/neurotox_sting/ozelomelyn/ozelomelyn_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting/ozelomelyn]
	if(ozelomelyn_ability)
		ozelomelyn_ability.remove_action(xenomorph_owner)
		qdel(ozelomelyn_ability)
	var/datum/action/ability/activable/xeno/neurotox_sting/neurotox_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(!neurotox_ability)
		neurotox_ability = new()
		neurotox_ability.give_action(xenomorph_owner)
	return ..()

/datum/mutation_upgrade/spur/alternative_sting/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/neurotox_sting/neurotox_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(neurotox_ability)
		neurotox_ability.remove_action(xenomorph_owner)
		qdel(neurotox_ability)
	var/datum/action/ability/activable/xeno/neurotox_sting/ozelomelyn/ozelomelyn_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting/ozelomelyn]
	if(!ozelomelyn_ability)
		ozelomelyn_ability = new()
		ozelomelyn_ability.give_action(xenomorph_owner)
	return ..()

/datum/mutation_upgrade/spur/alternative_sting/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/neurotox_sting/neurotox_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(!neurotox_ability)
		return
	neurotox_ability.sting_amount += initial(neurotox_ability.sting_amount) * get_multiplier(new_amount - previous_amount)

/datum/mutation_upgrade/spur/alternative_sting/on_xenomorph_upgrade()
	var/datum/action/ability/activable/xeno/neurotox_sting/ozelomelyn/ozelomelyn_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting/ozelomelyn]
	if(ozelomelyn_ability)
		ozelomelyn_ability.remove_action(xenomorph_owner)
		qdel(ozelomelyn_ability)

/// Returns the multiplier of Neurotoxin Sting's initial sting amount to add to the ability.
/datum/mutation_upgrade/spur/alternative_sting/proc/get_multiplier(structure_count)
	return multiplier_per_structure * structure_count

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/rallying_cry
	name = "Rallying Cry"
	desc = "Screech grant all xenomorphs within a 20-tile radius gain -0.3/-0.5/-0.7 speed for 4 seconds."
	/// For the first structure, the amount to add to Screech's movement speed modifier.
	var/movement_initial = -0.1
	/// For each structure, the amount to add to Screech's movement speed modifier.
	var/movement_structure = -0.2

/datum/mutation_upgrade/veil/rallying_cry/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Screech grant all xenomorphs within a 20-tile radius gain [get_movement(new_amount)] speed for 4 seconds."

/datum/mutation_upgrade/veil/rallying_cry/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/screech/screech_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/screech]
	if(!screech_ability)
		return
	screech_ability.movement_speed_modifier += get_movement(0)

/datum/mutation_upgrade/veil/rallying_cry/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/screech/screech_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/screech]
	if(!screech_ability)
		return
	screech_ability.movement_speed_modifier -= get_movement(0)

/datum/mutation_upgrade/veil/rallying_cry/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/screech/screech_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/screech]
	if(!screech_ability)
		return
	screech_ability.movement_speed_modifier += get_movement(new_amount - previous_amount, FALSE)

/// Returns the amount to add to Screech's movement speed modifier.
/datum/mutation_upgrade/veil/rallying_cry/proc/get_movement(structure_count, include_initial = TRUE)
	return (include_initial ? movement_initial : 0) + (movement_structure * structure_count)
