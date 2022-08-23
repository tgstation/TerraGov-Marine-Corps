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
	name = "alpha sensor tower"
	desc = "A tall tower with a sensor array at the top and a control box at the bottom. Has a lengthy activation process with 3 phases."
	icon = 'icons/obj/structures/sensor.dmi'
	icon_state = "sensor_loyalist"
	obj_flags = NONE
	density = TRUE
	layer = BELOW_OBJ_LAYER
	resistance_flags = RESIST_ALL
	var/current_timer
	var/generate_time = 150 SECONDS
	var/activate_time = 5 SECONDS // time to start the activation
	var/deactivate_time = 10 SECONDS // time to stop the activation proccess
	var/completed_segments = 0 // what segment we are on, (once this hits total, sensor tower segment is finished)
	var/id = 1
	var/activated = FALSE // if all segments are finished

/obj/structure/sensor_tower_patrol/Initialize()
	. = ..()
	update_icon()

/obj/structure/sensor_tower_patrol/attack_hand(mob/living/user)
	if(!ishuman(user))
		return
	if(user.do_actions)
		user.balloon_alert(user, "You are already doing something!")
		return
	if(user.faction != FACTION_TERRAGOV)
		if(current_timer)
			if(!do_after(user, deactivate_time, TRUE, src))
				return
			current_timer = null
			balloon_alert(user, "You stop the activation process!")
			update_icon()
			for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
				human.playsound_local(human, "sound/effects/CIC_order.ogg", 10, 1)
				human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:center valign='top'><u>OVERWATCH</u></span><br>" + "[src] activation process has been stopped.", /obj/screen/text/screen_text/command_order)
		balloon_alert(user, "Only TerraGov can activate the objective, defend this!")
		return
	if(activated)
		balloon_alert(user, "[src] is already fully activated!")
		return
	if(current_timer)
		balloon_alert(user, "[src] is currently activating!")
		return
	balloon_alert_to_viewers("[user] starts to activate [src]!")
	if(!do_after(user, activate_time, TRUE, src))
		return
	balloon_alert_to_viewers("[user] activates [src]!")
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		human.playsound_local(human, "sound/effects/CIC_order.ogg", 10, 1)
		human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:center valign='top'><u>OVERWATCH</u></span><br>" + "[src] is being activated.", /obj/screen/text/screen_text/command_order)
	current_timer = addtimer(CALLBACK(src, .proc/finish_activation), generate_time, TIMER_STOPPABLE)

/obj/structure/sensor_tower_patrol/proc/finish_activation()
	playsound(src, 'sound/machines/ping.ogg', 25, 1)
	current_timer = null
	balloon_alert_to_viewers("[src] has finished activation!")
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		human.playsound_local(human, "sound/effects/CIC_order.ogg", 10, 1)
		human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:center valign='top'><u>OVERWATCH</u></span><br>" + "[src] is fully activated.", /obj/screen/text/screen_text/command_order)
	SSticker.mode.sensors_activated += 1
	var/datum/game_mode/combat_patrol/sensor_capture/D = SSticker.mode
	var/current_time = timeleft(D.game_timer)
	D.game_timer = addtimer(CALLBACK(D, /datum/game_mode/combat_patrol.proc/set_game_end), current_time + 5 MINUTES, TIMER_STOPPABLE)
	activated = true
	update_icon()

/obj/structure/sensor_tower_patrol/update_icon()
	. = ..()
	update_control_minimap_icon()

/obj/structure/sensor_tower_patrol/proc/update_control_minimap_icon()
	SSminimaps.remove_marker(src)
	if(activated)
		SSminimaps.add_marker(src, z, MINIMAP_FLAG_ALL, "relay_[id]_on_full")
	else
		SSminimaps.add_marker(src, z, MINIMAP_FLAG_ALL, "relay_[id][current_timer ? "_on" : "_off"]")

/obj/structure/sensor_tower_patrol/bravo
	name = "bravo sensor tower"
	id = 2

/obj/structure/sensor_tower_patrol/charlie
	name = "charlie sensor tower"
	id = 3

/obj/structure/sensor_tower_patrol/delta
	name = "delta sensor tower"
	id = 4

/obj/structure/sensor_tower_patrol/echo
	name = "echo sensor tower"
	id = 5
