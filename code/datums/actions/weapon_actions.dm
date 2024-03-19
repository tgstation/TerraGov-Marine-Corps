//Stamina using weapon based abilities
/datum/action/ability/activable/weapon_skill
	action_icon = 'icons/mob/actions.dmi'
	///Damage of this attack
	var/damage
	///Penetration of this attack
	var/penetration

/datum/action/ability/activable/weapon_skill/New(Target, _damage, _penetration)
	. = ..()
	damage = _damage
	penetration = _penetration

/datum/action/ability/activable/weapon_skill/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/carbon_owner = owner
	if(carbon_owner.getStaminaLoss() > 0) //this specifically lets you use these abilities with no stamina, but not if you have actual stamina loss
		if(!silent)
			carbon_owner.balloon_alert(owner, "Catch your breath!")
		return FALSE

/datum/action/ability/activable/weapon_skill/succeed_activate(ability_cost_override)
	if(QDELETED(owner))
		return
	ability_cost_override = ability_cost_override? ability_cost_override : ability_cost
	if(ability_cost_override > 0)
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.adjustStaminaLoss(ability_cost_override)
