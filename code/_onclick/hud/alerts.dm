//A system to manage and display alerts on screen without needing you to do it yourself

//PUBLIC -  call these wherever you want


/mob/proc/throw_alert(category, type, severity, obj/new_master, override = FALSE, mob/initiator)

/* Proc to create or update an alert. Returns the alert if the alert is new or updated, 0 if it was thrown already
category is a text string. Each mob may only have one alert per category; the previous one will be replaced
path is a type path of the actual alert type to throw
severity is an optional number that will be placed at the end of the icon_state for this alert
For example, high pressure's icon_state is "highpressure" and can be serverity 1 or 2 to get "highpressure1" or "highpressure2"
new_master is optional and sets the alert's icon state to "template" in the ui_style icons with the master as an overlay.
Clicks are forwarded to master
Override makes it so the alert is not replaced until cleared by a clear_alert with clear_override, and it's used for hallucinations.

mob/initiator is optional and is used for alerts that are thrown by other mobs, such as high-fiving
*/

	if(!category || QDELETED(src))
		return

	var/atom/movable/screen/alert/thealert
	if(alerts[category])
		thealert = alerts[category]
		if(thealert.override_alerts)
			return FALSE
		if(new_master && new_master != thealert.master)
			WARNING("[src] threw alert [category] with new_master [new_master] while already having that alert with master [thealert.master]")

			clear_alert(category)
			return .()
		else if(thealert.type != type)
			clear_alert(category)
			return .()
		else if(!severity || severity == thealert.severity)
			if(thealert.timeout)
				clear_alert(category)
				return .()
			else //no need to update
				return FALSE
	else
		thealert = new type()
		thealert.override_alerts = override
		if(override)
			thealert.timeout = null
	thealert.owner = src

	if(new_master)
		var/old_layer = new_master.layer
		var/old_plane = new_master.plane
		new_master.layer = FLOAT_LAYER
		new_master.plane = FLOAT_PLANE
		thealert.add_overlay(new_master)
		new_master.layer = old_layer
		new_master.plane = old_plane
		thealert.icon_state = "template" // We'll set the icon to the client's ui pref in reorganize_alerts()
		thealert.master = new_master
	else
		thealert.icon_state = "[initial(thealert.icon_state)][severity]"
		thealert.severity = severity

	alerts[category] = thealert
	if(client && hud_used)
		hud_used.reorganize_alerts()
	thealert.transform = matrix(32, 6, MATRIX_TRANSLATE)
	animate(thealert, transform = matrix(), time = 2.5, easing = CUBIC_EASING)

	if(thealert.timeout)
		addtimer(CALLBACK(src, PROC_REF(alert_timeout), thealert, category), thealert.timeout)
		thealert.timeout = world.time + thealert.timeout - world.tick_lag

	//Only matters for alerts that are thrown by other mobs
	if(initiator)
		var/atom/movable/screen/alert/interaction/interaction_alert = thealert
		interaction_alert.initiating_mob = initiator
		interaction_alert.register_mob_movement()
		return interaction_alert

	return thealert

/mob/proc/alert_timeout(atom/movable/screen/alert/alert, category)
	if(alert.timeout && alerts[category] == alert && world.time >= alert.timeout)
		clear_alert(category)

// Proc to clear an existing alert.
/mob/proc/clear_alert(category, clear_override = FALSE)
	var/atom/movable/screen/alert/alert = alerts[category]
	if(!alert)
		return FALSE
	if(alert.override_alerts && !clear_override)
		return FALSE

	alerts -= category
	if(client && hud_used)
		hud_used.reorganize_alerts()
		client.screen -= alert
	qdel(alert)

/atom/movable/screen/alert
	icon = 'icons/mob/screen_alert.dmi'
	icon_state = "default"
	name = "Alert"
	desc = "Something seems to have gone wrong with this alert, so report this bug please"
	mouse_opacity = MOUSE_OPACITY_ICON
	var/timeout = 0 //If set to a number, this alert will clear itself after that many deciseconds
	var/severity = 0
	var/alerttooltipstyle = ""
	var/override_alerts = FALSE //If it is overriding other alerts of the same type
	var/mob/owner //Alert owner


/atom/movable/screen/alert/fire
	name = "On Fire"
	desc = "You're on fire. Stop, drop and roll to put the fire out or move to a vacuum area."
	icon_state = "fire"

/atom/movable/screen/alert/fire/Click()
	var/mob/living/L = usr
	if(!istype(L) || usr != owner)
		return
	L.resist()

//GHOSTS
//TODO: expand this system to replace the pollCandidates/CheckAntagonist/"choose quickly"/etc Yes/No messages
/atom/movable/screen/alert/notify_action
	name = "Notification"
	desc = "A new notification. You can enter it."
	icon_state = "template"
	timeout = 15 SECONDS
	var/atom/target = null
	var/action = NOTIFY_JUMP

/atom/movable/screen/alert/notify_action/Click()
	var/mob/dead/observer/G = usr
	if(!istype(G) || usr != owner)
		return
	if(!G.client)
		return
	if(!target)
		return
	switch(action)
		if(NOTIFY_ATTACK)
			target.attack_ghost(G)
		if(NOTIFY_JUMP)
			var/turf/T = get_turf(target)
			if(T)
				G.forceMove(T)
		if(NOTIFY_ORBIT)
			G.ManualFollow(target)
		if(NOTIFY_JOIN_AS_LARVA)
			if(!isxeno(target))
				return FALSE
			switch(tgui_alert(G, "What would you like to do?", "Burrowed larva source available", list("Join as Larva", "Jump to it", "Cancel")))
				if("Join as Larva")
					SSticker.mode.spawn_larva(G, target)
				if("Jump to it")
					G.forceMove(get_turf(target))


//OBJECT-BASED

/atom/movable/screen/alert/restrained/buckled
	name = "Buckled"
	desc = "You've been buckled to something. Click the alert to unbuckle unless you're handcuffed."
	icon_state = "buckled"

/atom/movable/screen/alert/restrained/handcuffed
	name = "Handcuffed"
	desc = "You're handcuffed and can't act. If anyone drags you, you won't be able to move. Click the alert to free yourself."

/atom/movable/screen/alert/restrained/Click()
	if(!isliving(usr) || usr != owner)
		return
	var/mob/living/L = usr
	return L.do_resist()


// PRIVATE = only edit, use, or override these if you're editing the system as a whole

// Re-render all alerts - also called in /datum/hud/show_hud() because it's needed there
/datum/hud/proc/reorganize_alerts(mob/viewmob)
	var/mob/screenmob = viewmob || mymob
	if(!screenmob.client)
		return
	var/list/alerts = mymob.alerts
	if(!length(alerts))
		return FALSE
	if(!hud_shown)
		for(var/category in alerts)
			var/atom/movable/screen/alert/alert = alerts[category]
			screenmob.client.screen -= alert
		return TRUE
	var/c = 0
	for(var/category in alerts)
		var/atom/movable/screen/alert/alert = alerts[category]
		c++
		switch(c)
			if(1)
				. = ui_alert1
			if(2)
				. = ui_alert2
			if(3)
				. = ui_alert3
			if(4)
				. = ui_alert4
			if(5)
				. = ui_alert5 // Right now there's 5 slots
			else
				. = ""
		alert.screen_loc = .
		screenmob.client.screen |= alert
	if(!viewmob)
		for(var/obs in mymob.observers)
			reorganize_alerts(obs)
	return TRUE

/atom/movable/screen/alert/Click(location, control, params)
	if(!usr?.client)
		return
	var/paramslist = params2list(params)
	if(paramslist["shift"]) // screen objects don't do the normal Click() stuff so we'll cheat
		to_chat(usr, span_boldnotice("[name]</span> - <span class='info'>[desc]"))
		return
	if(master)
		return usr.client.Click(master, location, control, params)

/atom/movable/screen/alert/Destroy()
	master = null
	owner = null
	return ..()


//MECHS
/atom/movable/screen/alert/nocell
	name = "Missing Power Cell"
	desc = "Unit has no power cell. No modules available until a power cell is reinstalled. Robotics may provide assistance."
	icon_state = "no_cell"

/atom/movable/screen/alert/emptycell
	name = "Out of Power"
	desc = "Unit's power cell has no charge remaining. No modules available until power cell is recharged."
	icon_state = "empty_cell"

/atom/movable/screen/alert/lowcell
	name = "Low Charge"
	desc = "Unit's power cell is running low."
	icon_state = "low_cell"

/atom/movable/screen/alert/low_mech_integrity
	name = "Mech Damaged"
	desc = "Mech integrity is low."
	icon_state = "low_mech_integrity"

//Mob interactions
/atom/movable/screen/alert/interaction
	name = "high five"
	desc = "You gonna leave them hanging?"
	icon_state = "drunk2"	//It looks jolly
	///Sound filed played when interaction is successful
	var/interaction_sound = 'sound/effects/snap.ogg'
	///The mob that initiated the alert, if one exists
	var/mob/initiating_mob

/atom/movable/screen/alert/interaction/proc/register_mob_movement()
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(interactees_moved))
	RegisterSignal(initiating_mob, COMSIG_MOVABLE_MOVED, PROC_REF(interactees_moved))

/atom/movable/screen/alert/interaction/proc/interactees_moved()
	if(!owner.Adjacent(initiating_mob))
		end_interaction(FALSE)

/atom/movable/screen/alert/interaction/proc/end_interaction(success = TRUE)
	if(!success)
		owner.visible_message(failure_message())
	UnregisterSignal(initiating_mob, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	owner.clear_alert(ALERT_INTERACTION)

/atom/movable/screen/alert/interaction/Click()
	if(usr != owner || !can_interact(owner))
		end_interaction(FALSE)
		return FALSE

	return action()

///Called when the interaction is accepted
/atom/movable/screen/alert/interaction/proc/action()
	interaction_animation()

	owner.visible_message(success_message())
	playsound(owner, interaction_sound, 50, TRUE)
	end_interaction()

///Seperate proc meant to be overriden for unique animations
/atom/movable/screen/alert/interaction/proc/interaction_animation()
	owner.face_atom(initiating_mob)
	initiating_mob.face_atom(owner)

	//Calculate the distances between the two mobs
	var/x_distance = owner.x - initiating_mob.x
	var/y_distance = owner.y - initiating_mob.y

	animate(owner, pixel_x = owner.pixel_x - x_distance * 8, pixel_y = owner.pixel_y - y_distance * 8, time = 0.5 SECONDS, easing = BACK_EASING, flags = ANIMATION_PARALLEL)
	animate(pixel_x = initial(owner.pixel_x), pixel_y = initial(owner.pixel_y), time = 0.1 SECONDS)
	animate(initiating_mob, pixel_x = initiating_mob.pixel_x + x_distance * 8, pixel_y = initiating_mob.pixel_y + y_distance * 8, time = 0.5 SECONDS, easing = BACK_EASING, flags = ANIMATION_PARALLEL)
	animate(pixel_x = initial(initiating_mob.pixel_x), pixel_y = initial(initiating_mob.pixel_y), time = 0.1 SECONDS)

///Returns a string for successful interactions
/atom/movable/screen/alert/interaction/proc/success_message()
	return "[owner] high fives [initiating_mob]!"

///Returns a string for unsuccessful interactions
/atom/movable/screen/alert/interaction/proc/failure_message()
	return "[owner] left [initiating_mob] hanging in the air..."

/atom/movable/screen/alert/interaction/fist_bump
	name = "fist bump"
	desc = "Bro."
	interaction_sound = 'sound/weapons/throwtap.ogg'

//Benos turn around and slap with their tail instead of a fist bump
/atom/movable/screen/alert/interaction/fist_bump/interaction_animation()
	owner.face_atom(initiating_mob)
	initiating_mob.face_atom(owner)

	var/x_distance = owner.x - initiating_mob.x
	var/y_distance = owner.y - initiating_mob.y

	if(isxeno(owner))
		animate(owner, pixel_x = owner.pixel_x - x_distance * 8, pixel_y = owner.pixel_y - y_distance * 8, dir = initiating_mob.dir,
				time = 0.5 SECONDS, easing = BACK_EASING, flags = ANIMATION_PARALLEL)
		owner.face_atom(initiating_mob)
	else
		animate(owner, pixel_x = owner.pixel_x - x_distance * 8, pixel_y = owner.pixel_y - y_distance * 8,
				time = 0.5 SECONDS, easing = BACK_EASING, flags = ANIMATION_PARALLEL)
	animate(pixel_x = initial(owner.pixel_x), pixel_y = initial(owner.pixel_y), time = 0.1 SECONDS)

	if(isxeno(initiating_mob))
		animate(initiating_mob, pixel_x = initiating_mob.pixel_x + x_distance * 8, pixel_y = initiating_mob.pixel_y + y_distance * 8, dir = owner.dir,
				time = 0.5 SECONDS, easing = BACK_EASING, flags = ANIMATION_PARALLEL)
		initiating_mob.face_atom(owner)
	else
		animate(initiating_mob, pixel_x = initiating_mob.pixel_x + x_distance * 8, pixel_y = initiating_mob.pixel_y + y_distance * 8,
				time = 0.5 SECONDS, easing = BACK_EASING, flags = ANIMATION_PARALLEL)
	animate(pixel_x = initial(initiating_mob.pixel_x), pixel_y = initial(initiating_mob.pixel_y), time = 0.1 SECONDS)

//We support interspecies bumping of fists and tails!
/atom/movable/screen/alert/interaction/fist_bump/success_message()
	var/owner_xeno = isxeno(owner)
	var/initiating_mob_xeno = isxeno(initiating_mob)
	if(owner_xeno && initiating_mob_xeno)
		return "[owner] and [initiating_mob] slap tails together!"
	if(owner_xeno)
		return "[owner] slaps [initiating_mob]'s fist!"
	if(initiating_mob_xeno)
		return "[owner] fist bumps [initiating_mob]'s tail!"
	return "[owner] fist bumps [initiating_mob]!"

/atom/movable/screen/alert/interaction/fist_bump/failure_message()
	return "[owner] left [initiating_mob] hanging. Not cool!"

/atom/movable/screen/alert/interaction/headbutt
	name = "head bump"
	desc = "Touch skulls."
	interaction_sound = 'sound/weapons/throwtap.ogg'

/atom/movable/screen/alert/interaction/headbutt/interaction_animation()
	owner.face_atom(initiating_mob)
	initiating_mob.face_atom(owner)

	var/x_distance = owner.x - initiating_mob.x
	var/y_distance = owner.y - initiating_mob.y

	var/matrix/owner_matrix = owner.transform
	var/matrix/initiating_mob_matrix = initiating_mob.transform
	var/rotation_angle
	//This was so much pain, maintainers forgive me
	if(owner.dir & (EAST | WEST))
		if(isxenorunner(owner))	//Rounies get special upwards headbutts
			rotation_angle = owner.dir & EAST ? -15 : 15
		else
			rotation_angle = owner.dir & EAST ? 15 : -15

		//The animation if the mobs face east/west is to rotate their heads together
		animate(owner, pixel_x = owner.pixel_x - x_distance * 8, pixel_y = owner.pixel_y - y_distance * 8,
				transform = owner_matrix.Turn(rotation_angle), time = 0.5 SECONDS, easing = BACK_EASING, flags = ANIMATION_PARALLEL)
		animate(pixel_x = initial(owner.pixel_x), pixel_y = initial(owner.pixel_y),
				transform = owner_matrix.Turn(-rotation_angle), time = 0.1 SECONDS)
	else
		//If facing north or south, basically the same animation as the high five but move even closer
		animate(owner, pixel_x = owner.pixel_x - x_distance * 8, pixel_y = owner.pixel_y - y_distance * 16,
				time = 0.5 SECONDS, easing = BACK_EASING, flags = ANIMATION_PARALLEL)
		animate(pixel_x = initial(owner.pixel_x), pixel_y = initial(owner.pixel_y), time = 0.1 SECONDS)

	if(initiating_mob.dir & (EAST | WEST))
		if(isxenorunner(initiating_mob))
			rotation_angle = initiating_mob.dir & EAST ? -15 : 15
		else
			rotation_angle = initiating_mob.dir & EAST ? 15 : -15

		animate(initiating_mob, pixel_x = initiating_mob.pixel_x + x_distance * 8, pixel_y = initiating_mob.pixel_y + y_distance * 8,
				transform = initiating_mob_matrix.Turn(rotation_angle), time = 0.5 SECONDS, easing = BACK_EASING, flags = ANIMATION_PARALLEL)
		animate(pixel_x = initial(initiating_mob.pixel_x), pixel_y = initial(initiating_mob.pixel_y),
				transform = initiating_mob_matrix.Turn(-rotation_angle), time = 0.1 SECONDS)
	else
		animate(initiating_mob, pixel_x = initiating_mob.pixel_x + x_distance * 8, pixel_y = initiating_mob.pixel_y + y_distance * 16,
				time = 0.5 SECONDS, easing = BACK_EASING, flags = ANIMATION_PARALLEL)
		animate(pixel_x = initial(initiating_mob.pixel_x), pixel_y = initial(initiating_mob.pixel_y), time = 0.1 SECONDS)

/atom/movable/screen/alert/interaction/headbutt/success_message()
	return "[owner] and [initiating_mob] bonk heads together!!"

/atom/movable/screen/alert/interaction/headbutt/failure_message()
	return "[owner] did not headbutt [initiating_mob]..."

///All in one function to begin interactions
/mob/proc/interaction_emote(mob/initiator, mob/target)
	if(can_interact(target))
		var/target_zone = ran_zone(initiator.zone_selected)
		if(target_zone == BODY_ZONE_L_ARM || target_zone == BODY_ZONE_R_ARM)
			if(isxeno(target) && isxeno(initiator))	//Benos don't high five each other, they slap tails!
				return target.throw_alert(ALERT_INTERACTION, /atom/movable/screen/alert/interaction/fist_bump, initiator = initiator)
			return target.throw_alert(ALERT_INTERACTION, /atom/movable/screen/alert/interaction, initiator = initiator)
		if(target_zone == BODY_ZONE_PRECISE_L_HAND || target_zone == BODY_ZONE_PRECISE_R_HAND)
			return target.throw_alert(ALERT_INTERACTION, /atom/movable/screen/alert/interaction/fist_bump, initiator = initiator)
		if(target_zone == BODY_ZONE_HEAD)
			return target.throw_alert(ALERT_INTERACTION, /atom/movable/screen/alert/interaction/headbutt, initiator = initiator)

/*
If anyone wants to add more interactions, here is an easy test item to use, just be sure to comment out any can_interact checks
/obj/item/test/attack_self(mob/user)
	var/mob/target = tgui_input_list(user, "Select a target", "Select a target", GLOB.alive_living_list)
	if(!target)
		return
	user.throw_alert(ALERT_INTERACTION, /atom/movable/screen/alert/interaction, initiator = target)
*/
