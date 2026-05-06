GLOBAL_VAR_INIT(deployed_cameras, 0)

#define DEPLOYABLE_CAM_ALERT_TIME 10 SECONDS

/obj/machinery/camera/deployable
	name = "\"Huginn\" ROC-58 Observer"
	desc = "The ROC-58 deployable camera, designed for use in the field to increase the tactical utility of overwatch."
	network = list("marinesl", "marine")
	icon_state = "deployable"
	base_icon_state = "deployable"
	layer = ABOVE_ALL_MOB_LAYER//it flies after all
	///Radio so that the sentry can scream for help
	var/obj/item/radio/internal_radio
	///proximity monitor for threat detection
	var/datum/proximity_monitor/proximity_monitor
	var/sense_range = 7
	COOLDOWN_DECLARE(proxy_alert_cooldown)
	var/threat_detected = FALSE

/obj/machinery/camera/deployable/Initialize(mapload, newDir, new_faction)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED, PROC_REF(on_mission_end))
	faction = new_faction
	proximity_monitor = new(src, sense_range) // starts on
	internal_radio = new /obj/item/radio/sentry(src, faction)
	update_minimap_icon()
	add_filter(type, 2, drop_shadow_filter(y = -16, color = COLOR_TRANSPARENT_SHADOW, size = 0.9))

/obj/machinery/camera/deployable/Destroy()
	QDEL_NULL(proximity_monitor)
	QDEL_NULL(internal_radio)
	return ..()

/obj/machinery/camera/deployable/setDir(newdir)
	. = ..()
	pixel_z = 16
	pixel_w = 0

/obj/machinery/camera/deployable/toggle_cam(mob/user, displaymessage = TRUE)
	. = ..()
	if(!proximity_monitor)
		return
	if(!(camera_flags & CAMERA_OPERATING))
		proximity_monitor.set_range(0)
		return
	proximity_monitor.set_range(sense_range)

/obj/machinery/camera/deployable/HasProximity(atom/movable/AM)
	if(!COOLDOWN_FINISHED(src, proxy_alert_cooldown))
		return
	if(!valid_prox_target(AM))
		return
	sense(AM)

/obj/machinery/camera/deployable/proc/valid_prox_target(atom/movable/AM)
	if(AM.faction == faction)
		return FALSE

	if(isliving(AM))
		return TRUE

	if(!isobj(AM))
		return FALSE

	if(ismecha(AM))
		return TRUE
	if(isvehicle(AM))
		return TRUE

	return FALSE

/obj/machinery/camera/deployable/proc/sense(atom/movable/baddie)
	COOLDOWN_START(src, proxy_alert_cooldown, DEPLOYABLE_CAM_ALERT_TIME)
	threat_detected = TRUE

	audible_message("[icon2html(src, hearers(src))] *beep* *beep* *beep*", null, sense_range)
	internal_radio.talk_into(src, "[baddie] detected in [AREACOORD(src)]")
	playsound(get_turf(src), 'sound/machines/triple_beep.ogg', 100, TRUE, 9)
	update_minimap_icon()
	update_appearance(UPDATE_ICON)
	addtimer(CALLBACK(src, PROC_REF(clear_warning)), DEPLOYABLE_CAM_ALERT_TIME)

///Clears any threat warnings
/obj/machinery/camera/deployable/proc/clear_warning()
	threat_detected = FALSE
	update_minimap_icon()
	update_appearance(UPDATE_ICON)

/obj/machinery/camera/deployable/proc/update_minimap_icon()
	if(!(faction in GLOB.faction_to_minimap_flag))
		return
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, GLOB.faction_to_minimap_flag[faction], image('icons/UI_icons/map_blips.dmi', null, "gargoyle[threat_detected ? "_warn" : "_passive"]", MINIMAP_LOCATOR_LAYER))

/////

/obj/machinery/camera/deployable/update_icon_state()
	icon_state = base_icon_state
	if(obj_integrity <= 0)
		icon_state += "_off"
		return
	if(threat_detected)
		icon_state += "_threat"

///Deletes itself on campaign mission end
/obj/machinery/camera/deployable/proc/on_mission_end(datum/source, /datum/campaign_mission/ending_mission, winning_faction)
	SIGNAL_HANDLER
	qdel(src)

/obj/item/deployable_camera
	name = "Undeployed \"Huginn\" ROC-58 Observer"
	desc = "A deployable camera for use with overwatch systems."
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "deployable_item"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/deployable_camera/attack_self(mob/user)
	user.visible_message(span_notice("[user] throws [src] into the air!"),
		span_notice("You throw [src] into the air!"))

	for(var/mob/living/silicon/ai/AI AS in GLOB.ai_list)
		to_chat(AI, span_notice("NOTICE - \"Huginn\" ROC-58 Observer has been deployed at [AREACOORD_NO_Z(user)]."))
	var/obj/machinery/camera/deployable/newcam = new(get_turf(user), user.dir, user.faction)
	var/dat
	if(ishuman(user))
		var/mob/living/carbon/human/squaddie = user
		var/datum/squad/squad = squaddie.assigned_squad
		if(squad)
			newcam.network += list("[lowertext(squad.name)]")
			dat += squad.name
			dat += " "
	dat += newcam.name
	GLOB.deployed_cameras++
	dat += " [GLOB.deployed_cameras]"
	newcam.name = dat
	newcam.c_tag = newcam.name
	qdel(src)
