//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/healthy_bulwark
	name = "Healthy Bulwark"
	desc = "Bulwark no longer grants armor. Instead, it grants overheal of 60/80/100 for entering the affected area for the first time. This overheal is subtracted when leaving the affected area or when Bulwark ends."
	/// For the first structure, the amount of overheal that Bulwark will grant.
	var/overheal_increase_initial = 40
	/// For each structure, the additional amount of overheal that Bulwark will grant.
	var/overheal_increase_per_structure = 20

/datum/mutation_upgrade/shell/healthy_bulwark/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Bulwark no longer grants armor. Instead, it grants overheal of [overheal_increase_initial + (overheal_increase_per_structure * new_amount)] for entering the affected area for the first time. This overheal is subtracted when leaving the affected area or when Bulwark ends."

/datum/mutation_upgrade/shell/healthy_bulwark/on_mutation_enabled()
	var/datum/action/ability/xeno_action/bulwark/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/bulwark]
	if(!ability)
		return FALSE
	ability.armor_multiplier = 0
	ability.overheal_addition += overheal_increase_initial
	return ..()

/datum/mutation_upgrade/shell/healthy_bulwark/on_mutation_disabled()
	var/datum/action/ability/xeno_action/bulwark/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/bulwark]
	if(!ability)
		return FALSE
	ability.armor_multiplier = initial(ability.armor_multiplier)
	ability.overheal_addition -= overheal_increase_initial
	return ..()

/datum/mutation_upgrade/shell/healthy_bulwark/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/bulwark/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/bulwark]
	if(!ability)
		return FALSE
	ability.overheal_addition += (new_amount - previous_amount) * overheal_increase_per_structure

/datum/mutation_upgrade/shell/bulwark_zone
	name = "Bulwark Zone"
	desc = "Bulwark no longer requires you to stand still, but ends when you leave the radius. It grants 50/60/70% of its original armor."
	/// For the first structure, the percentage to increase the armor multiplier by.
	var/armor_multiplier_percentage_increase_initial = -0.6
	/// For each structure, the additional percentage to increase the armor multiplier by.
	var/armor_multiplier_percentage_increase_per_structure = 0.1

/datum/mutation_upgrade/shell/bulwark_zone/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Bulwark no longer requires you to stand still, but ends when you leave the radius. It grants [PERCENT(1 + armor_multiplier_percentage_increase_initial + (armor_multiplier_percentage_increase_per_structure * new_amount))]% of its original armor and ends when you run out of plasma or leave its radius."

/datum/mutation_upgrade/shell/bulwark_zone/on_mutation_enabled()
	var/datum/action/ability/xeno_action/bulwark/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/bulwark]
	if(!ability)
		return FALSE
	ability.channel_required = FALSE
	ability.armor_multiplier += armor_multiplier_percentage_increase_initial * initial(ability.armor_multiplier)
	return ..()

/datum/mutation_upgrade/shell/bulwark_zone/on_mutation_disabled()
	var/datum/action/ability/xeno_action/bulwark/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/bulwark]
	if(!ability)
		return FALSE
	ability.channel_required = initial(ability.channel_required)
	ability.armor_multiplier -= armor_multiplier_percentage_increase_initial * initial(ability.armor_multiplier)
	return ..()

/datum/mutation_upgrade/shell/bulwark_zone/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/bulwark/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/bulwark]
	if(!ability)
		return FALSE
	ability.overheal_addition += (new_amount - previous_amount) * armor_multiplier_percentage_increase_per_structure * initial(ability.armor_multiplier)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/alternative_sting
	name = "Alternative Sting"
	desc = "Ozelomelyn Sting is replaced with Neurotoxin Sting. Each interval gives 10/20/30% more chemicals."
	/// For each structure, the additional percentage of reagents to add to the amount of reagents Neurotoxin Sting will inject.
	var/percentage_additional_reagents_per_structure = 0.1

/datum/mutation_upgrade/spur/alternative_sting/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Ozelomelyn Sting is replaced with Neurotoxin Sting. Each interval gives [PERCENT(percentage_additional_reagents_per_structure * new_amount)]% more chemicals."

/datum/mutation_upgrade/spur/alternative_sting/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/neurotox_sting/ozelomelyn/oze_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting/ozelomelyn]
	if(oze_ability)
		oze_ability.remove_action(xenomorph_owner)
	var/datum/action/ability/activable/xeno/neurotox_sting/neuro_ability = new()
	neuro_ability.give_action(xenomorph_owner)
	return ..()

/datum/mutation_upgrade/spur/alternative_sting/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/neurotox_sting/neuro_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(neuro_ability)
		neuro_ability.remove_action(xenomorph_owner)
	var/datum/action/ability/activable/xeno/neurotox_sting/ozelomelyn/oze_ability = new()
	oze_ability.give_action(xenomorph_owner)
	return ..()

/datum/mutation_upgrade/spur/alternative_sting/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/neurotox_sting/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(!ability)
		return
	ability.sting_amount += (new_amount - previous_amount) * percentage_additional_reagents_per_structure

/datum/mutation_upgrade/spur/alternative_sting/on_xenomorph_upgrade()
	var/datum/action/ability/activable/xeno/neurotox_sting/ozelomelyn/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting/ozelomelyn]
	if(ability)
		ability.remove_action(xenomorph_owner)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/rallying_cry
	name = "Rallying Cry"
	desc = "Screech grant all xenomorphs within a 20-tile radius gain -0.3/-0.5/-0.7 speed for 4 seconds."
	/// For the first structure, the amount of movespeed to add.
	var/movespeed_increase_initial = -0.1
	/// For each structure, the additional amount of movespeed to add.
	var/movespeed_increase_per_structure = -0.2

/datum/mutation_upgrade/veil/rallying_cry/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Screech grant all xenomorphs within a 20-tile radius gain [movespeed_increase_initial + (movespeed_increase_per_structure * new_amount)] speed for 6 seconds."

/datum/mutation_upgrade/veil/rallying_cry/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/screech/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/screech]
	if(!ability)
		return FALSE
	ability.movespeed_amount += movespeed_increase_initial
	return ..()

/datum/mutation_upgrade/veil/rallying_cry/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/screech/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/screech]
	if(!ability)
		return FALSE
	ability.movespeed_amount -= movespeed_increase_initial
	return ..()

/datum/mutation_upgrade/veil/rallying_cry/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/screech/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/screech]
	if(!ability)
		return FALSE
	ability.movespeed_amount += (new_amount - previous_amount) * movespeed_increase_per_structure
