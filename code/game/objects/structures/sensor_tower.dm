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
		if(FACTION_SOM)
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
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		human.playsound_local(human, "sound/effects/CIC_order.ogg", 10, 1)
		human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:center valign='top'><u>SENSOR TOWER CAPTURED</u></span><br>" + "[faction] HAS CAPTURED THE SENSOR TOWER.", /obj/screen/text/screen_text/command_order)
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
		if(FACTION_SOM)
			SSminimaps.remove_marker(src)
			SSminimaps.add_marker(src, z, MINIMAP_FLAG_ALL, "som_zone")
		else
			SSminimaps.remove_marker(src)
			SSminimaps.add_marker(src, z, MINIMAP_FLAG_ALL, "neutral_zone")

