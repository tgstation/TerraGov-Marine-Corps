/mob/living/silicon/robot/Life()
	set invisibility = 0
	set background = 1

	. = ..()

	//Status updates, death etc.
	clamp_values()

	if(client)
		update_items()
	if (stat != DEAD) //still using power
		use_power()
		process_killswitch()
		process_locks()

/mob/living/silicon/robot/update_stat()
	. = ..()
	if(status_flags & GODMODE)
		return
	if(stat == DEAD)
		SSmobs.stop_processing(src)
		return FALSE

	if(health <= get_death_threshold())
		death()
		return
	if(knocked_out || stunned || knocked_down || !has_power) //Stunned etc.
		stat = UNCONSCIOUS
		blind_eyes(1)
	else
		stat = CONSCIOUS
		adjust_blindness(-1)

	update_canmove()

/mob/living/silicon/robot/proc/clamp_values()

//	SetStunned(min(stunned, 30))
	SetKnockedout(min(knocked_out, 30))
//	SetKnockeddown(min(knocked_down, 20))
	sleeping = 0
	adjustBruteLoss(0)
	adjustToxLoss(0)
	adjustOxyLoss(0)
	adjustFireLoss(0)

/mob/living/silicon/robot/proc/use_power()
	// Debug only
	// to_chat(world, "DEBUG: life.dm line 35: cyborg use_power() called at tick [controller_iteration]")
	used_power_this_tick = 0
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		C.update_power_state()

	if ( cell && is_component_functioning("power cell") && src.cell.charge > 0 )
		if(module_state_1)
			cell_use_power(50) // 50W load for every enabled tool TODO: tool-specific loads
		if(module_state_2)
			cell_use_power(50)
		if(module_state_3)
			cell_use_power(50)

		if(lights_on)
			cell_use_power(30) 	// 30W light. Normal lights would use ~15W, but increased for balance reasons.

		has_power = 1
	else
		if (has_power)
			to_chat(src, "<span class='warning'> You are now running on emergency backup power.</span>")
		has_power = 0
		if(lights_on) // Light is on but there is no power!
			lights_on = 0
			SetLuminosity(0)

/mob/living/silicon/robot/handle_status_effects()
	..()

	if(camera && !scrambledcodes)
		if(stat == DEAD || isWireCut(5))
			camera.status = 0
		else
			camera.status = 1

	if(sleeping)
		KnockOut(2)
		sleeping--

	density = !lying

	if ((sdisabilities & BLIND))
		blind_eyes(1)
	if ((sdisabilities & DEAF))
		ear_deaf = 1

	//update the state of modules and components here
	if (stat != CONSCIOUS)
		uneq_all()

	if(!is_component_functioning("radio"))
		radio.on = 0
	else
		radio.on = 1

	if(is_component_functioning("camera"))
		adjust_blindness(-1)
	else
		set_blindness(1)

	return 1

/mob/living/silicon/robot/handle_regular_hud_updates()
	..()

	update_sight()

	if (hud_used && hud_used.healths)
		if (src.stat != DEAD)
			switch(round(health * 100 / maxHealth))
				if(100 to INFINITY)
					hud_used.healths.icon_state = "health0"
				if(75 to 99)
					hud_used.healths.icon_state = "health1"
				if(50 to 74)
					hud_used.healths.icon_state = "health2"
				if(25 to 49)
					hud_used.healths.icon_state = "health3"
				if(10 to 24)
					hud_used.healths.icon_state = "health4"
				if(0 to 9)
					hud_used.healths.icon_state = "health5"
				else
					hud_used.healths.icon_state = "health6"
		else
			hud_used.healths.icon_state = "health7"

		if(connected_ai)
			connected_ai.connected_robots -= src
			connected_ai = null

	if (cells)
		if (cell)
			var/cellcharge = cell.charge/cell.maxcharge
			switch(cellcharge)
				if(0.75 to INFINITY)
					cells.icon_state = "charge4"
				if(0.5 to 0.75)
					cells.icon_state = "charge3"
				if(0.25 to 0.5)
					cells.icon_state = "charge2"
				if(0 to 0.25)
					cells.icon_state = "charge1"
				else
					cells.icon_state = "charge0"
		else
			cells.icon_state = "charge-empty"

	if(hud_used && hud_used.bodytemp_icon)
		switch(bodytemperature) //310.055 optimal body temp
			if(335 to INFINITY)
				hud_used.bodytemp_icon.icon_state = "temp2"
			if(320 to 335)
				hud_used.bodytemp_icon.icon_state = "temp1"
			if(300 to 320)
				hud_used.bodytemp_icon.icon_state = "temp0"
			if(260 to 300)
				hud_used.bodytemp_icon.icon_state = "temp-1"
			else
				hud_used.bodytemp_icon.icon_state = "temp-2"


//Oxygen and fire does nothing yet!!
//	if (src.oxygen) src.oxygen.icon_state = "oxy[src.oxygen_alert ? 1 : 0]"
//	if (src.fire) src.fire.icon_state = "fire[src.fire_alert ? 1 : 0]"

	if(stat != DEAD) //the dead get zero fullscreens

		if(interactee)
			interactee.check_eye(src)
		else
			if(client && !client.adminobs)
				reset_view(null)

	return 1

/mob/living/silicon/robot/proc/update_items()
	if (client)
		client.screen -= contents
		for(var/obj/I in contents)
			if(I && !(istype(I,/obj/item/cell) || istype(I,/obj/item/radio)  || istype(I,/obj/machinery/camera) || istype(I,/obj/item/mmi)))
				client.screen += I
	if(module_state_1)
		module_state_1:screen_loc = ui_inv1
	if(module_state_2)
		module_state_2:screen_loc = ui_inv2
	if(module_state_3)
		module_state_3:screen_loc = ui_inv3
	update_icons()

/mob/living/silicon/robot/proc/process_killswitch()
	if(killswitch)
		killswitch_time --
		if(killswitch_time <= 0)
			if(client)
				to_chat(src, "<span class='danger'>Killswitch Activated</span>")
			killswitch = 0
			spawn(5)
				gib()

/mob/living/silicon/robot/proc/process_locks()
	if(weapon_lock)
		uneq_all()
		weaponlock_time --
		if(weaponlock_time <= 0)
			if(src.client)
				to_chat(src, "<span class='danger'>Weapon Lock Timed Out!</span>")
			weapon_lock = 0
			weaponlock_time = 120

/mob/living/silicon/robot/update_canmove()
	if(knocked_out || stunned || knocked_down || buckled || lockcharge || !is_component_functioning("actuator"))
		canmove = FALSE
	else
		canmove = TRUE
	return canmove
