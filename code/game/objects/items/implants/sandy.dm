#define SANDEVISTAN_IMPLANT "sandevistan_implant"

/obj/item/implant/spinalspeed
	name = "neural overclocker implant"
	desc = "Overloads your central nervous system in order to do everything faster. Careful not to overuse it."
	icon_state = "imp_spinal"
	//implant_overlay = null
	implant_color = null
	w_class = WEIGHT_CLASS_NORMAL
	allowed_limbs = list(BODY_ZONE_CHEST)
	cooldown_time = 9 SECONDS
	///How long its been on for
	var/time_on = 0
	///If you're pushing it to the edge
	var/hasexerted = FALSE
	///modifier to multiplier on move delay and do_after
	var/action_modifier = 0.3
	///Movement speed modifier
	var/speed_modifier = -1
	COOLDOWN_DECLARE(alertcooldown)

/obj/item/implant/spinalspeed/unimplant()
	if(active)
		toggle()
	return ..()

/obj/item/implant/spinalspeed/activate()
	return toggle()

/obj/item/implant/spinalspeed/update_icon_state()
	if(active)
		icon_state = initial(icon_state) + "_on"
	else
		icon_state = initial(icon_state)

/obj/item/implant/spinalspeed/process()
	if(active)
		if(implant_owner.stat != CONSCIOUS)
			toggle(TRUE)
		time_on ++
		switch(time_on)
			if(10 to 25)
				if(COOLDOWN_CHECK(src, alertcooldown))
					to_chat(implant_owner, span_alert("You feel your spine tingle."))
					COOLDOWN_START(src, alertcooldown, 10 SECONDS)
				implant_owner.hallucination += 5
				implant_owner.adjustFireLoss(1)
			if(26 to 50)
				if(COOLDOWN_CHECK(src, alertcooldown) || !hasexerted)
					to_chat(implant_owner, span_userdanger("Your spine and brain feel like they're burning!"))
					COOLDOWN_START(src, alertcooldown, 5 SECONDS)
				hasexerted = TRUE
				implant_owner.set_drugginess(10)
				implant_owner.hallucination += 100
				implant_owner.adjustFireLoss(5)
			if(51 to INFINITY)//no infinite abuse
				to_chat(implant_owner, span_userdanger("You feel a slight sense of shame as your brain and spine rip themselves apart from overexertion."))
				implant_owner.gib()
	else
		time_on -= 0.5
		if(time_on <= 0)
			time_on = 0
			STOP_PROCESSING(SSfastprocess, src)

	if(hasexerted && time_on == 0)
		to_chat(implant_owner, "Your brains feels normal again.")
		hasexerted = FALSE

///Turns it off or on
/obj/item/implant/spinalspeed/proc/toggle(silent = FALSE)
	if(!active)
		if(!COOLDOWN_CHECK(src, activation_cooldown))
			return FALSE
		playsound(implant_owner, 'sound/effects/spinal_implant_on.ogg', 60)
		implant_owner.add_movespeed_modifier(type, priority = 100, multiplicative_slowdown = speed_modifier)
		implant_owner.next_move_modifier -= action_modifier
		RegisterSignal(implant_owner, MOB_GET_DO_AFTER_COEFFICIENT, PROC_REF(apply_do_after_mod))
		implant_owner.AddComponentFrom(SANDEVISTAN_IMPLANT, /datum/component/after_image, 2 SECONDS, 0.5, TRUE)
		START_PROCESSING(SSfastprocess, src)
	else
		playsound(implant_owner, 'sound/effects/spinal_implant_off.ogg', 70)
		COOLDOWN_START(src, activation_cooldown, cooldown_time)
		implant_owner.next_move_modifier += action_modifier
		UnregisterSignal(implant_owner, MOB_GET_DO_AFTER_COEFFICIENT)
		implant_owner.remove_movespeed_modifier(type)
		implant_owner.RemoveComponentSource(SANDEVISTAN_IMPLANT, /datum/component/after_image)
	toggle_active(!active)
	if(!silent)
		to_chat(implant_owner, span_notice("You turn your spinal implant [active? "on" : "off"]."))
	update_icon()
	activation_action.update_button_icon()
	return TRUE

///Modifies do_after delays
/obj/item/implant/spinalspeed/proc/apply_do_after_mod(datum/source, list/mod_list)
	mod_list += -action_modifier

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
