// ***************************************
// *********** Drop
// ***************************************
/datum/status_effect/stacking/stimulant
	tick_interval = 2 SECONDS
	alert_type = null
	delay_before_decay = 30 SECONDS
	stack_threshold = 50

/datum/status_effect/stacking/stimulant/drop
	id = "drop stimulant"

/datum/status_effect/stacking/stimulant/drop/on_apply()
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.ranged_accuracy_mod += 20
	carbon_owner.ranged_scatter_mod -= 5

	//X.add_filter("resin_jelly_outline", 2, outline_filter(1, COLOR_TAN_ORANGE))
	return TRUE

/datum/status_effect/stacking/stimulant/drop/on_remove()
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.ranged_accuracy_mod += 20
	carbon_owner.ranged_scatter_mod -= 5

	//X.remove_filter("resin_jelly_outline")
	owner.balloon_alert(owner, "You feel the world turn grey")
	return ..()

/datum/status_effect/stacking/stimulant/drop/tick()
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	if(carbon_owner.traumatic_shock * 1.3 > carbon_owner.shock_stage)
		carbon_owner.adjustShock_Stage(carbon_owner.traumatic_shock * 1.3)
	return ..()



//temp until I put this somewhere proper

/obj/item/stimulant
	icon = 'icons/obj/items/syringe.dmi'
	icon_state = ""
	var/datum/status_effect/stacking/stimulant/stim_type
	var/stim_stacks = 45
	var/stim_message

/obj/item/stimulant/attack_self(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/carbon_user = user
	carbon_user.apply_status_effect(stim_type, stim_stacks)
	carbon_user.balloon_alert(carbon_user, stim_message)
	qdel(src)

/obj/item/stimulant/drop
	name = "drop booster"
	desc = "Drop pushes the user into a heightened state of neural activity, greatly improving hand eye co-ordination but making them more sensitive to pain."
	icon_state = "borghypo"
	stim_type = STATUS_EFFECT_STIMULANT_DROP
	stim_message = "You can suddenly feel everything!"
