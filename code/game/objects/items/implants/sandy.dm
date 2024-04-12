/obj/item/implant/spinalspeed
	name = "neural overclocker implant"
	desc = "Overloads your central nervous system in order to do everything faster. Careful not to overuse it."
	//slot = ORGAN_SLOT_THRUSTERS
	icon_state = "imp_spinal"
	//implant_overlay = null
	implant_color = null
	//actions_types = list(/datum/action/item_action/organ_action/toggle)
	w_class = WEIGHT_CLASS_NORMAL
	var/on = FALSE
	var/time_on = 0
	var/hasexerted = FALSE
	var/list/hsv
	var/last_step = 0
	COOLDOWN_DECLARE(alertcooldown)
	COOLDOWN_DECLARE(startsoundcooldown)
	COOLDOWN_DECLARE(endsoundcooldown)

/*
/obj/item/implant/spinalspeed/Insert(mob/living/carbon/M, special = 0)
	. = ..()

/obj/item/implant/spinalspeed/Remove(mob/living/carbon/M, special = 0)
	if(on)
		toggle(silent = TRUE)
	..()

/obj/item/implant/spinalspeed/ui_action_click()
	toggle()
**/

/obj/item/implant/spinalspeed/activate()
	toggle()

/obj/item/implant/spinalspeed/proc/toggle(silent = FALSE)
	if(!on)
		if(COOLDOWN_CHECK(src, startsoundcooldown))
			playsound(implant_owner, 'sound/effects/spinal_implant_on.ogg', 60)
			COOLDOWN_START(src, startsoundcooldown, 1 SECONDS)
		implant_owner.add_movespeed_modifier("spinalimplant", priority=100, multiplicative_slowdown=-1)
		implant_owner.next_move_modifier *= 0.7
		implant_owner.AddComponent(/datum/component/after_image, 2 SECONDS, 0.5, TRUE)
	else
		if(COOLDOWN_CHECK(src, endsoundcooldown))
			playsound(implant_owner, 'sound/effects/spinal_implant_off.ogg', 70)
			COOLDOWN_START(src, endsoundcooldown, 1 SECONDS)
		implant_owner.next_move_modifier /= 0.7
		implant_owner.remove_movespeed_modifier("spinalimplant")
		var/datum/component/after_image = implant_owner.GetComponent(/datum/component/after_image)
		qdel(after_image)
	on = !on
	if(!silent)
		to_chat(implant_owner, span_notice("You turn your spinal implant [on? "on" : "off"]."))
	update_icon()

/*
/obj/item/implant/spinalspeed/update_icon()
	if(on)
		icon_state = "imp_spinal-on"
	else
		icon_state = "imp_spinal"
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()
**/

/*
/obj/item/implant/spinalspeed/on_life()
	if(on)
		if(implant_owner.stat == UNCONSCIOUS || implant_owner.stat == DEAD)
			toggle(silent = TRUE)
		time_on += 1
		switch(time_on)
			if(20 to 50)
				if(COOLDOWN_CHECK(src, alertcooldown))
					to_chat(implant_owner, span_alert("You feel your spine tingle."))
					COOLDOWN_START(src, alertcooldown, 10 SECONDS)
				implant_owner.hallucination += 5
				implant_owner.adjustFireLoss(1)
			if(50 to 100)
				if(COOLDOWN_CHECK(src, alertcooldown) || !hasexerted)
					to_chat(implant_owner, span_userdanger("Your spine and brain feel like they're burning!"))
					COOLDOWN_START(src, alertcooldown, 5 SECONDS)
				hasexerted = TRUE
				implant_owner.set_drugginess(10)
				implant_owner.hallucination += 100
				implant_owner.adjustFireLoss(5)
			if(100 to INFINITY)//no infinite abuse
				to_chat(implant_owner, span_userdanger("You feel a slight sense of shame as your brain and spine rip themselves apart from overexertion."))
				implant_owner.gib()
	else
		time_on -= 2

	time_on = max(time_on, 0)
	if(hasexerted && time_on == 0)
		to_chat(implant_owner, "Your brains feels normal again.")
		hasexerted = FALSE
**/

/*
/obj/item/implant/spinalspeed/emp_act(severity)
	. = ..()
	switch(severity)//i don't want emps to just be damage again, that's boring
		if(EMP_HEAVY)
			implant_owner.set_drugginess(40)
			implant_owner.hallucination += 500
			implant_owner.blur_eyes(20)
			implant_owner.dizziness += 10
			time_on += 10
			implant_owner.adjustFireLoss(10)
			to_chat(implant_owner, span_warning("Your spinal implant malfunctions and you feel it scramble your brain!"))
		if(EMP_LIGHT)
			implant_owner.set_drugginess(20)
			implant_owner.hallucination += 200
			implant_owner.blur_eyes(10)
			implant_owner.dizziness += 5
			time_on += 5
			implant_owner.adjustFireLoss(5)
			to_chat(implant_owner, span_danger("Your spinal implant malfunctions and you suddenly feel... wrong."))
**/
