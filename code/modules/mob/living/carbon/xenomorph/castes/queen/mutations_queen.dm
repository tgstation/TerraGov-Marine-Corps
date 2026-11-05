//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/healthy_bulwark
	name = "Healthy Bulwark"
	desc = "Bulwark no longer grants armor. Bulwark now grants overheal of 80 for entering the affected area for the first time. This overheal is subtracted when leaving the affected area or when Bulwark ends."
	/// The amount of Overheal that Bulwark should be giving.
	var/overheal = 80

/datum/mutation_upgrade/shell/healthy_bulwark/on_mutation_enabled()
	var/datum/action/ability/xeno_action/bulwark/bulwark_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/bulwark]
	if(!bulwark_ability)
		return
	bulwark_ability.armor_multiplier = 0
	bulwark_ability.flat_overheal += overheal

/datum/mutation_upgrade/shell/healthy_bulwark/on_mutation_disabled()
	var/datum/action/ability/xeno_action/bulwark/bulwark_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/bulwark]
	if(!bulwark_ability)
		return
	bulwark_ability.armor_multiplier = initial(bulwark_ability.armor_multiplier)
	bulwark_ability.flat_overheal -= overheal

/datum/mutation_upgrade/shell/bulwark_zone
	name = "Bulwark Zone"
	desc = "Bulwark no longer requires you to channel, but ends when you leave the radius. It grants 60% of its original armor."
	/// The multiplier to add as Bulwark's initial armor multiplier to the ability.
	var/multiplier = -0.4

/datum/mutation_upgrade/shell/bulwark_zone/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/bulwark/bulwark_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/bulwark]
	if(!bulwark_ability)
		return
	bulwark_ability.channel_required = FALSE
	bulwark_ability.armor_multiplier += initial(bulwark_ability.armor_multiplier) * multiplier

/datum/mutation_upgrade/shell/bulwark_zone/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/bulwark/bulwark_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/bulwark]
	if(!bulwark_ability)
		return
	bulwark_ability.channel_required = initial(bulwark_ability.channel_required)
	bulwark_ability.armor_multiplier -= initial(bulwark_ability.armor_multiplier) * multiplier

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/alternative_sting
	name = "Alternative Sting"
	desc = "Ozelomelyn Sting is replaced with Neurotoxin Sting. Each interval gives 20% more chemicals."
	/// The multiplier of Neurotoxin Sting's initial sting amount to add to the ability.
	var/multiplier = 0.2
	/// The ability to be given back if the mutation is disabled.
	var/datum/action/ability/activable/xeno/neurotox_sting/ozelomelyn/removed_ability

/datum/mutation_upgrade/spur/alternative_sting/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/neurotox_sting/ozelomelyn/ozelomelyn_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting/ozelomelyn]
	if(ozelomelyn_ability)
		removed_ability = ozelomelyn_ability
		removed_ability.remove_action(xenomorph_owner)
	var/datum/action/ability/activable/xeno/neurotox_sting/neurotox_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	neurotox_ability = new()
	neurotox_ability.give_action(xenomorph_owner)
	neurotox_ability.sting_amount += initial(neurotox_ability.sting_amount) * multiplier

/datum/mutation_upgrade/spur/alternative_sting/on_mutation_disabled()
	if(removed_ability)
		removed_ability.give_action(xenomorph_owner)
		removed_ability = null
	var/datum/action/ability/activable/xeno/neurotox_sting/neurotox_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(neurotox_ability)
		xenomorph_owner.remove_ability(neurotox_ability)

/datum/mutation_upgrade/spur/alternative_sting/on_xenomorph_upgrade()
	var/datum/action/ability/activable/xeno/neurotox_sting/ozelomelyn/ozelomelyn_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting/ozelomelyn]
	if(!ozelomelyn_ability)
		return
	xenomorph_owner.remove_ability(ozelomelyn_ability)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/rallying_cry
	name = "Rallying Cry"
	desc = "Screech grant all xenomorphs within a 20-tile radius gain -0.5 speed for 4 seconds."
	/// The amount to add to Screech's movement speed modifier.
	var/movespeed_change = -0.5 // Negative = faster. Positive = slower.

/datum/mutation_upgrade/veil/rallying_cry/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/screech/screech_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/screech]
	if(!screech_ability)
		return
	screech_ability.movement_speed_modifier += movespeed_change

/datum/mutation_upgrade/veil/rallying_cry/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/screech/screech_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/screech]
	if(!screech_ability)
		return
	screech_ability.movement_speed_modifier -= movespeed_change
