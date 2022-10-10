/obj/structure/sensor_tower
	name = "sensor tower"
	desc = "A tall tower with a sensor array at the top and a control box at the bottom. Used to hack into colony control."
	icon = 'icons/obj/structures/sensor.dmi'
	icon_state = "sensor"
	obj_flags = NONE
	density = TRUE
	layer = BELOW_OBJ_LAYER
	resistance_flags = RESIST_ALL
	///Which faction controls this sensor tower
	var/faction

/obj/structure/sensor_tower/Initialize()
	. = ..()
	GLOB.zones_to_control += src
	update_icon()

/obj/structure/sensor_tower/Destroy()
	GLOB.zones_to_control -= src
	return ..()

/obj/structure/sensor_tower/update_icon_state()
	icon_state = initial(icon_state)
	switch(faction)
		if(FACTION_TERRAGOV)
			icon_state += "_loyalist"
		if(FACTION_TERRAGOV_REBEL)
			icon_state += "_rebel"

/obj/structure/sensor_tower/attack_hand(mob/living/user)
	if(!ishuman(user))
		return
	if(!(SSticker.mode?.flags_round_type & MODE_TWO_HUMAN_FACTIONS))
		to_chat(user, span_warning("There is nothing to do with [src]"))
		return
	var/mob/living/carbon/human/human_user = user
	if(human_user.faction == faction)
		to_chat(user, span_notice("Your faction already controls this."))
		return
	user.visible_message(span_notice("[user] starts to capture [src]!"), span_notice("You start to capture [src]."))
	if(!do_after(user, 5 SECONDS, TRUE, src))
		return
	user.visible_message(span_notice("[user] captured [src]! For the [human_user.faction]s"), span_notice("You captured [src]! For the [human_user.faction]s"))
	faction = human_user.faction
	update_icon()

/obj/structure/sensor_tower/update_icon()
	. = ..()
	update_control_minimap_icon()

///Update the minimap blips to show who is controlling this area
/obj/structure/sensor_tower/proc/update_control_minimap_icon()
	switch(faction)
		if(FACTION_TERRAGOV)
			SSminimaps.remove_marker(src)
			SSminimaps.add_marker(src, z, MINIMAP_FLAG_ALL, "loyalist_zone")
		if(FACTION_TERRAGOV_REBEL)
			SSminimaps.remove_marker(src)
			SSminimaps.add_marker(src, z, MINIMAP_FLAG_ALL, "rebel_zone")
		else
			SSminimaps.remove_marker(src)
			SSminimaps.add_marker(src, z, MINIMAP_FLAG_ALL, "neutral_zone")

/obj/structure/sensor_tower_patrol
	name = "sensor tower"
	desc = "A tall tower with a sensor array at the top and a control box at the bottom. Has a lengthy activation process."
	icon = 'icons/obj/structures/sensor.dmi'
	icon_state = "sensor"
	obj_flags = NONE
	density = TRUE
	layer = BELOW_OBJ_LAYER
	resistance_flags = RESIST_ALL
	///The timer for when the sensor tower activates
	var/current_timer
	///Time it takes for the sensor tower to fully activate
	var/generate_time = 250 SECONDS
	///Time it takes to start the activation
	var/activate_time = 5 SECONDS
	///Time it takes to stop the activation
	var/deactivate_time = 10 SECONDS
	///Count amount of sensor towers existing
	var/static/id = 1
	///The id for the tower when it initializes, used for minimap icon
	var/towerid
	///True if the sensor tower has finished activation, used for minimap icon and preventing deactivation
	var/activated = FALSE
	///Prevents there being more than one sensor tower being activated
	var/static/already_activated = FALSE

/obj/structure/sensor_tower_patrol/Initialize()
	. = ..()
	name += " " + num2text(id)
	towerid = id
	id++
	update_icon()

/obj/structure/sensor_tower_patrol/update_icon_state()
	icon_state = initial(icon_state)
	if(current_timer || activated)
		icon_state += "_loyalist"

/obj/structure/sensor_tower_patrol/attack_hand(mob/living/user)
	if(!ishuman(user))
		return
	if(user.do_actions)
		user.balloon_alert(user, "You are already doing something!")
		return
	if(user.faction != FACTION_TERRAGOV)
		if(current_timer)
			balloon_alert(user, "You begin to stop the activation process!")
			if(!do_after(user, deactivate_time, TRUE, src))
				return
			balloon_alert(user, "You stop the activation process!")
			deactivate()
		else if(activated)
			balloon_alert(user, "This sensor tower is already fully activated, you cannot deactivate it!")
		else
			balloon_alert(user, "This sensor tower is not activated yet, don't let it be activated!")
		return
	if(activated)
		balloon_alert(user, "This sensor tower is already fully activated!")
		return
	if(current_timer)
		balloon_alert(user, "This sensor tower is currently activating!")
		return
	if(already_activated)
		balloon_alert(user, "Theres already a sensor tower being activated!")
		return
	balloon_alert_to_viewers("You start to activate this sensor tower!")
	if(!do_after(user, activate_time, TRUE, src))
		return
	if(already_activated)
		balloon_alert(user, "Theres already a sensor tower being activated!")
		return
	balloon_alert_to_viewers("You activate this sensor tower!")
	begin_activation()

///Starts timer and sends an alert
/obj/structure/sensor_tower_patrol/proc/begin_activation()
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		human.playsound_local(human, "sound/effects/CIC_order.ogg", 10, 1)
		human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:center valign='top'><u>OVERWATCH</u></span><br>" + "[src] is being activated.", /obj/screen/text/screen_text/command_order)
	current_timer = addtimer(CALLBACK(src, .proc/finish_activation), generate_time, TIMER_STOPPABLE)
	already_activated = TRUE
	update_icon()

///When timer ends add a point to the point pool in sensor capture, increase game timer, and send an alert
/obj/structure/sensor_tower_patrol/proc/finish_activation()
	if(!current_timer)
		return
	if(activated)
		return
	playsound(src, 'sound/machines/ping.ogg', 25, 1)
	current_timer = null
	balloon_alert_to_viewers("[src] has finished activation!")
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		human.playsound_local(human, "sound/effects/CIC_order.ogg", 10, 1)
		human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:center valign='top'><u>OVERWATCH</u></span><br>" + "[src] is fully activated.", /obj/screen/text/screen_text/command_order)
	var/datum/game_mode/combat_patrol/sensor_capture/mode = SSticker.mode
	mode.sensors_activated += 1
	var/current_time = timeleft(mode.game_timer)
	mode.game_timer = addtimer(CALLBACK(mode, /datum/game_mode/combat_patrol.proc/set_game_end), current_time + 7 MINUTES, TIMER_STOPPABLE)
	activated = TRUE
	already_activated = FALSE
	update_icon()

///Stops timer if activating and sends an alert
/obj/structure/sensor_tower_patrol/proc/deactivate()
	current_timer = null
	already_activated = FALSE
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		human.playsound_local(human, "sound/effects/CIC_order.ogg", 10, 1)
		human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:center valign='top'><u>OVERWATCH</u></span><br>" + "[src] activation process has been stopped.", /obj/screen/text/screen_text/command_order)
	update_icon()

/obj/structure/sensor_tower_patrol/update_icon()
	. = ..()
	update_control_minimap_icon()

///Update minimap icon of tower if its deactivated, activated , and fully activated
/obj/structure/sensor_tower_patrol/proc/update_control_minimap_icon()
	if(activated)
		SSminimaps.add_marker(src, z, MINIMAP_FLAG_ALL, "relay_[towerid]_on_full")
	else
		SSminimaps.add_marker(src, z, MINIMAP_FLAG_ALL, "relay_[towerid][current_timer ? "_on" : "_off"]")
