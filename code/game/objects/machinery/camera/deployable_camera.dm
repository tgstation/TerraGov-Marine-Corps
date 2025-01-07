GLOBAL_VAR_INIT(deployed_cameras, 0)

/obj/machinery/camera/deployable
	name = "\"Huginn\" ROC-58 Observer"
	desc = "The ROC-58 deployable camera, designed for use in the field to increase the tactical utility of overwatch."
	network = list("marinesl", "marine")
	icon_state = "deployable"
	layer = ABOVE_ALL_MOB_LAYER//it flies after all

/obj/machinery/camera/deployable/Initialize(mapload, newDir)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED, PROC_REF(on_mission_end))

/obj/machinery/camera/deployable/update_icon_state()
	. = ..()
	if(obj_integrity <= 0)
		icon_state = "deployableoff"
	else
		icon_state = "deployable"

///Deletes itself on campaign mission end
/obj/machinery/camera/deployable/proc/on_mission_end(datum/source, /datum/campaign_mission/ending_mission, winning_faction)
	SIGNAL_HANDLER
	qdel(src)

/obj/item/deployable_camera
	name = "Undeployed \"Huginn\" ROC-58 Observer"
	desc = "A deployable camera for use with overwatch systems."
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "deployableitem"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/deployable_camera/attack_self(mob/user)
	user.visible_message(span_notice("[user] throws [src] into the air!"),
		span_notice("You throw [src] into the air!"))

	for(var/mob/living/silicon/ai/AI AS in GLOB.ai_list)
		to_chat(AI, span_notice("NOTICE - \"Huginn\" ROC-58 Observer has been deployed at [AREACOORD_NO_Z(user)]."))
	var/obj/machinery/camera/deployable/newcam = new(get_turf(user))
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
	newcam.setDir(user.dir)
	qdel(src)
