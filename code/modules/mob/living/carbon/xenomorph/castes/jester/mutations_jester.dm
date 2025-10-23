//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/rejuvenating_riposte
	name = "Rejuvenating Riposte"
	desc = "You gain 3 orbitiing charms. While these charms are active, you have a 35% chance to riposte a attack, causing it to heal you instead of dealing damage, at a 1:1/2:1/3:1 ratio. Once used, a charm takes 60 seconds to regenerate. Attacks against you also have a 10& chance to crit, dealing 1.20/1.35/1.5x damage"
	/// For each structure, the additonal damage mult for crits against this mutation's owner
	var/damage_mult_per_structure = 0.15

/datum/mutation_upgrade/shell/rejuvenating_riposte/on_mutation_enabled()
	xenomorph_owner.RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_TAKING_DAMAGE, TYPE_PROC_REF(/mob/living/carbon/xenomorph/jester, handle_riposte))
	var/mob/living/carbon/xenomorph/jester/jestoid = xenomorph_owner
	jestoid.riposte_charms_overlay = new(jestoid, jestoid)
	jestoid.vis_contents += jestoid.riposte_charms_overlay
	jestoid.riposte_charms = 3
	jestoid.riposte_charms_max = 3
	jestoid.handle_riposte_overlay()

/datum/mutation_upgrade/shell/rejuvenating_riposte/on_mutation_disabled()
	xenomorph_owner.UnregisterSignal(xenomorph_owner, COMSIG_XENOMORPH_TAKING_DAMAGE)
	var/mob/living/carbon/xenomorph/jester/jestoid = xenomorph_owner
	jestoid.riposte_charms = 0
	jestoid.riposte_charms_max = 0
	jestoid.recieved_crit_damage_mult = 0
	jestoid.riposte_multipler = 1
	jestoid.vis_contents -= jestoid.riposte_charms_overlay
	qdel(jestoid.riposte_charms_overlay)

/datum/mutation_upgrade/shell/rejuvenating_riposte/on_structure_update(previous_amount, new_amount)
	var/mob/living/carbon/xenomorph/jester/jestoid = xenomorph_owner
	jestoid.riposte_multipler = new_amount
	jestoid.recieved_crit_damage_mult = 0.2 + damage_mult_per_structure * new_amount

/datum/mutation_upgrade/shell/rejuvenating_riposte/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "You charms heal you at a [new_amount]x ratio, but crits against you deal [1 + 0.2 + damage_mult_per_structure * new_amount]x damage"

//*********************//
//        Spur         //
//*********************//
/datum/mutation_upgrade/spur/specalized_claws
	name = "Specalized Claws"
	desc = "Your slash attacks have a 10/15/20% chance to apply a random debuff, from the same pool as Deck of Disaster. You loose Deck of Disaster"
	/// For each structure, the percentage chance to apply a random debuff.
	var/debuff_chance_per_structure = 5

/datum/mutation_upgrade/spur/specalized_claws/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/deck_of_disaster/dod = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/deck_of_disaster]
	dod.hidden = TRUE
	dod.active = FALSE
	xenomorph_owner.update_action_buttons(TRUE)

/datum/mutation_upgrade/spur/specalized_claws/on_mutation_disabled()
	var/mob/living/carbon/xenomorph/jester/jestoid = xenomorph_owner
	var/datum/action/ability/activable/xeno/deck_of_disaster/dod = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/deck_of_disaster]
	dod.hidden = FALSE
	dod.active = TRUE
	jestoid.debuff_slash_chance = initial(jestoid.chip_multipler)
	xenomorph_owner.update_action_buttons(TRUE)

/datum/mutation_upgrade/spur/specalized_claws/on_structure_update(previous_amount, new_amount)
	var/mob/living/carbon/xenomorph/jester/jestoid = xenomorph_owner
	jestoid.debuff_slash_chance = initial(jestoid.chip_multipler) + (5 + debuff_chance_per_structure * new_amount)

/datum/mutation_upgrade/spur/specalized_claws/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "You now have [5 + debuff_chance_per_structure * new_amount]% chance to apply a random debuff on slash, but you loose the ability to use Deck Of Disaster"

/datum/mutation_upgrade/spur/split_claws
	name = "Split Claws"
	desc = "Your slash attacks have a 10/15/20% chance to target a random, additional limb, dealing additional damage. You gain 20/30/40% less chips from slashing"
	/// For each structure, the percentage chance to double slash
	var/double_slash_chance_per_structure = 5
	/// For each structure, the percentage reduction to chips gain
	var/reduction_per_structure = 0.10

/datum/mutation_upgrade/spur/split_claws/on_mutation_disabled()
	var/mob/living/carbon/xenomorph/jester/jestoid = xenomorph_owner
	jestoid.chip_multipler = initial(jestoid.chip_multipler)
	jestoid.double_slash_chance = initial(jestoid.double_slash_chance)

/datum/mutation_upgrade/spur/split_claws/on_structure_update(previous_amount, new_amount)
	var/mob/living/carbon/xenomorph/jester/jestoid = xenomorph_owner
	jestoid.chip_multipler = initial(jestoid.chip_multipler) - (0.10 + reduction_per_structure * new_amount)
	jestoid.double_slash_chance = initial(jestoid.double_slash_chance) + 5 + double_slash_chance_per_structure * new_amount

/datum/mutation_upgrade/spur/split_claws/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "You now have [5 + double_slash_chance_per_structure * new_amount]% chance to double slash, but you gain [(0.10 + reduction_per_structure * new_amount) * 100]% less chips"

//*********************//
//        Veil         //
//*********************//
/datum/mutation_upgrade/veil/controled_chance
	name = "Controlled Chance"
	desc = "Pick from 2/3/4 options for tarot deck. Tarot deck's cooldown is 120/135/150% longer"
	/// For each structure, the percentage increase to Tarot deck's cooldown
	var/increase_per_structure = 0.15

/datum/mutation_upgrade/veil/controled_chance/on_mutation_disabled()
	var/datum/action/ability/xeno_action/tarot_deck/tarot = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tarot_deck]
	tarot.tarot_options = initial(tarot.tarot_options)
	tarot.cooldown_duration = initial(tarot.cooldown_duration)

/datum/mutation_upgrade/veil/controled_chance/on_structure_update(previous_amount, new_amount)
	var/datum/action/ability/xeno_action/tarot_deck/tarot = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tarot_deck]
	tarot.tarot_options = 1 + new_amount
	tarot.cooldown_duration = initial(tarot.cooldown_duration) * (1.05 + increase_per_structure * new_amount)

/datum/mutation_upgrade/veil/controled_chance/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "You now have [1 + new_amount] options for Tarot Deck, but its cooldown is [(1.05 + increase_per_structure * new_amount) * 100]% longer"
