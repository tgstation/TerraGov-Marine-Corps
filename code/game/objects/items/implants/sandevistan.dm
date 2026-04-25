#define SANDEVISTAN_IMPLANT "sandevistan_implant"

/obj/item/implant/sandevistan
	name = "sandevistan spinal implant"
	desc = "Overloads your central nervous system in order to do everything faster. Careful not to overuse it."
	icon_state = "imp_spinal"
	implant_color = null
	w_class = WEIGHT_CLASS_NORMAL
	allowed_limbs = list(BODY_ZONE_CHEST)
	cooldown_time = 5 SECONDS
	action_type = /datum/action/ability/activable/sandevistan
	///How long its been on for. Slowly goes down over time
	var/time_on = 0
	///If you're pushing it to the edge
	var/exerted = FALSE
	///modifier to multiplier on move delay and do_after
	var/action_modifier = 0.3
	///Movement speed modifier
	var/speed_modifier = -1
	///Gun scatter modifier
	var/scatter_mod = 5
	///Gun accuracy modifier
	var/accuracy_mod = 30
	///Modifier for melee/throw miss chance
	var/miss_chance_mod = 30
	COOLDOWN_DECLARE(alertcooldown)

/obj/item/implant/sandevistan/unimplant()
	if(active)
		toggle()
	return ..()

/obj/item/implant/sandevistan/activate()
	return toggle()

/obj/item/implant/sandevistan/update_icon_state()
	if(active)
		icon_state = initial(icon_state) + "_on"
	else
		icon_state = initial(icon_state)

/obj/item/implant/sandevistan/get_data()
	return {"
	<b>Implant Specifications:</b><BR>
	<b>Name:</b> Nanotrasen CDPR Sandevistan Implant<BR>
	<HR>
	<b>Implant Details:</b><BR>
	<b>Function:</b> Upon activation, this implant increases neural impulse speed, allowing the user's brain to process information, and react quicker than would be normally possible.<BR>
	The practical result in an increase in mobility and dexterity. <b> WARNING </b> Usage of the sandevistan is extremely taxing on the body, and prolonged use can lead to catastrophic injury or death."}

/obj/item/implant/sandevistan/process()
	if(!active)
		time_on -= 0.1 SECONDS
		if(time_on > 0)
			return
		time_on = 0
		STOP_PROCESSING(SSfastprocess, src)
		if(exerted)
			to_chat(implant_owner, "Your brains feels normal again.")
			exerted = FALSE
		return

	if(implant_owner.stat != CONSCIOUS)
		toggle(TRUE)
	time_on += 0.2 SECONDS
	switch(time_on)
		if(1 SECONDS to 2 SECONDS)
			if(COOLDOWN_FINISHED(src, alertcooldown))
				to_chat(implant_owner, span_alert("You feel your spine tingle."))
				COOLDOWN_START(src, alertcooldown, 10 SECONDS)
			implant_owner.hallucination += 2
			implant_owner.adjustFireLoss(1)
		if(2.1 SECONDS to 5 SECONDS)
			if(COOLDOWN_FINISHED(src, alertcooldown) || !exerted)
				to_chat(implant_owner, span_userdanger("Your spine and brain feel like they're burning!"))
				COOLDOWN_START(src, alertcooldown, 5 SECONDS)
			exerted = TRUE
			implant_owner.set_drugginess(10)
			implant_owner.hallucination += 10
			if(time_on > 3.6 SECONDS)
				implant_owner.adjustCloneLoss(1)
				implant_owner.adjustFireLoss(1)
			else
				implant_owner.adjustFireLoss(2)
		if(5.1 SECONDS to INFINITY)//no infinite abuse
			to_chat(implant_owner, span_userdanger("You feel a slight sense of shame as your brain and spine rip themselves apart from overexertion."))
			GLOB.round_statistics.sandevistan_gibs++
			implant_owner.gib()
			return

	if(!exerted)
		return
	var/side_effect_roll = rand(1, 100) + (time_on * 0.5)
	if((side_effect_roll > 90) && iscarbon(implant_owner))
		var/mob/living/carbon/carbon_owner = implant_owner
		carbon_owner.emote("me", 1, "coughs up blood!")
		carbon_owner.drip(10)
	if(side_effect_roll > 96)
		implant_owner.Stagger(1 SECONDS)
	if(side_effect_roll > 126)
		implant_owner.Stun(0.5 SECONDS)

///Turns it off or on
/obj/item/implant/sandevistan/proc/toggle(silent = FALSE)
	if(!active)
		playsound(implant_owner, 'sound/effects/spinal_implant_on.ogg', 60)
		implant_owner.add_movespeed_modifier(type, priority = 100, multiplicative_slowdown = speed_modifier)
		implant_owner.next_move_modifier -= action_modifier
		RegisterSignal(implant_owner, MOB_GET_DO_AFTER_COEFFICIENT, PROC_REF(apply_do_after_mod))
		RegisterSignal(implant_owner, MOB_GET_MISS_CHANCE_MOD, PROC_REF(apply_miss_chance_mod))
		implant_owner.AddComponentFrom(SANDEVISTAN_IMPLANT, /datum/component/after_image, 2 SECONDS, 0.5, TRUE)
		implant_owner.adjust_mob_scatter(scatter_mod)
		implant_owner.adjust_mob_accuracy(accuracy_mod)
		START_PROCESSING(SSfastprocess, src)
		GLOB.round_statistics.sandevistan_uses++
	else
		playsound(implant_owner, 'sound/effects/spinal_implant_off.ogg', 70)
		implant_owner.next_move_modifier += action_modifier
		UnregisterSignal(implant_owner, list(MOB_GET_DO_AFTER_COEFFICIENT, MOB_GET_MISS_CHANCE_MOD))
		implant_owner.remove_movespeed_modifier(type)
		implant_owner.RemoveComponentSource(SANDEVISTAN_IMPLANT, /datum/component/after_image)
		implant_owner.adjust_mob_scatter(-scatter_mod)
		implant_owner.adjust_mob_accuracy(-accuracy_mod)
	toggle_active(!active)
	if(!silent)
		to_chat(implant_owner, span_notice("You turn your spinal implant [active? "on" : "off"]."))
	update_icon()
	activation_action.update_button_icon()
	return TRUE

///Modifies do_after delays
/obj/item/implant/sandevistan/proc/apply_do_after_mod(datum/source, list/mod_list)
	mod_list += -action_modifier

///Modifies miss chance mod for melee/throw hits
/obj/item/implant/sandevistan/proc/apply_miss_chance_mod(datum/source, list/mod_list)
	mod_list += miss_chance_mod

//todo: make a generic activable/implant parent type
/datum/action/ability/activable/sandevistan
	action_icon = 'icons/obj/items/implants.dmi'
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY|ABILITY_IGNORE_SELECTED_ABILITY
	use_state_flags = ABILITY_USE_STAGGERED|ABILITY_USE_INCAP|ABILITY_USE_LYING|ABILITY_USE_BUCKLED|ABILITY_USE_BUSY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_IMPLANT_ABILITY_SANDEVISTAN,
	)

/datum/action/ability/activable/sandevistan/New(Target)
	. = ..()
	var/obj/item/implant/implant = Target
	name = implant.name
	action_icon_state = implant.icon_state
	cooldown_duration = implant.cooldown_time

/datum/action/ability/activable/sandevistan/update_button_icon()
	if(!target)
		return
	var/obj/item/implant/implant = target
	action_icon_state = implant.icon_state
	return ..()

/datum/action/ability/activable/sandevistan/use_ability()
	if(!target)
		return FALSE
	var/obj/item/implant/implant = target
	. = implant.activate()
	if(!.)
		return
	if(!implant.active)
		add_cooldown()
	update_button_icon()
