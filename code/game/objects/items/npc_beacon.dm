
//the holdable item
/obj/item/campaign_beacon/npc_beacon
	name = "\improper N.P.C. beacon"
	desc = "A bulky device that is used to teleport emergency support units directly into battle. Often used for garrisoning important locations."
	icon = 'icons/obj/items/npc_beacon.dmi'
	icon_state = "beacon_undeployed"
	base_icon_state = "beacon"
	deployable_type = /obj/structure/npc_beacon
	deploy_time = 2 SECONDS
	pixel_w = -4
	w_class = WEIGHT_CLASS_BULKY

/obj/item/campaign_beacon/npc_beacon/examine(mob/user)
	. = ..()
	. += span_notice("This one belongs to [faction ? faction : "no one"].")

/obj/item/campaign_beacon/npc_beacon/tgmc
	name = "\improper NTF N.P.C. beacon"
	deployable_type = /obj/structure/npc_beacon/tgmc_standard
	faction = FACTION_TERRAGOV

/obj/item/campaign_beacon/npc_beacon/tgmc/big
	name = "\improper Large NTF N.P.C. beacon"
	icon_state = "fc_beacon_undeployed"
	base_icon_state = "fc_beacon"
	deployable_type = /obj/structure/npc_beacon/tgmc_big

/obj/item/campaign_beacon/npc_beacon/som
	name = "\improper SOM N.P.C. beacon"
	deployable_type = /obj/structure/npc_beacon/som_standard
	faction = FACTION_SOM

/obj/item/campaign_beacon/npc_beacon/som/big
	name = "\improper Large SOM N.P.C. beacon"
	icon_state = "fc_beacon_undeployed"
	base_icon_state = "fc_beacon"
	deployable_type = /obj/structure/npc_beacon/som_big

//The deployed beacon, although this could be map spawned as well
/obj/structure/npc_beacon
	name = "\improper N.P.C. beacon"
	desc = "A bulky device that is used to teleport emergency support units directly into battle. Often used for garrisoning important locations."
	icon = 'icons/obj/items/npc_beacon.dmi'
	icon_state = "beacon_activating"
	base_icon_state = "beacon"
	density = FALSE
	resistance_flags = RESIST_ALL
	pixel_w = -8
	///List of jobs that are spawned by this item
	var/list/job_list

/obj/structure/npc_beacon/Initialize(mapload, obj/item/_internal_item, mob/deployer)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(spawn_mobs)), 3 SECONDS)
	if(_internal_item)
		name = _internal_item.name
		desc = _internal_item.desc
		icon = _internal_item.icon
		base_icon_state = _internal_item.base_icon_state
	if(deployer)
		faction = deployer.faction
	set_job_list()
	update_appearance()
	flick("[base_icon_state]_deploying", src)

/obj/structure/npc_beacon/update_icon_state()
	if(length(job_list))
		icon_state = "[base_icon_state]_activating"
	else
		icon_state = "[base_icon_state]_deployed_on"

/obj/structure/npc_beacon/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[base_icon_state]_emissive", src)

///Does any customisation to the spawn list
/obj/structure/npc_beacon/proc/set_job_list()
	return

///Spawns and slaves the NPCs
/obj/structure/npc_beacon/proc/spawn_mobs()
	if(QDELETED(src))
		return
	var/turf/spawn_loc = get_turf(src)
	var/list/slave_list = spawn_npc_squad(spawn_loc, job_list)
	AddComponent(/datum/component/npc_controller, faction, slaved_npc_list = slave_list)
	job_list = null
	update_appearance()

	playsound(src, 'sound/magic/lightningbolt.ogg', 50, 0)
	new /obj/effect/temp_visual/blink_drive(get_turf(src))

/obj/structure/npc_beacon/tgmc_standard
	job_list = list(
		/datum/job/terragov/squad/standard/npc,
		/datum/job/terragov/squad/standard/npc,
	)

/obj/structure/npc_beacon/tgmc_standard/set_job_list()
	job_list += pickweight(list(
		/datum/job/terragov/squad/standard/npc = 20,
		/datum/job/terragov/squad/engineer/npc = 30,
		/datum/job/terragov/squad/corpsman/npc = 30,
		/datum/job/terragov/squad/smartgunner/npc = 20,
		/datum/job/terragov/squad/leader/npc = 10,
	))

/obj/structure/npc_beacon/tgmc_big
	icon_state = "fc_beacon_activating"
	base_icon_state = "fc_beacon"
	job_list = list(
		/datum/job/terragov/squad/standard/npc,
		/datum/job/terragov/squad/standard/npc,
		/datum/job/terragov/squad/smartgunner/npc,
		/datum/job/terragov/squad/corpsman/npc,
	)

/obj/structure/npc_beacon/tgmc_big/set_job_list()
	job_list += pickweight(list(
		/datum/job/terragov/squad/standard/npc = 15,
		/datum/job/terragov/squad/engineer/npc = 25,
		/datum/job/terragov/squad/smartgunner/npc = 20,
		/datum/job/terragov/squad/leader/npc = 60,
	))

/obj/structure/npc_beacon/som_standard
	job_list = list(
		/datum/job/som/ert/standard,
		/datum/job/som/ert/standard,
	)

/obj/structure/npc_beacon/som_standard/set_job_list()
	job_list += pickweight(list(
		/datum/job/som/ert/standard = 20,
		/datum/job/som/ert/medic = 30,
		/datum/job/som/ert/veteran = 30,
		/datum/job/som/ert/leader = 10,
	))

/obj/structure/npc_beacon/som_big
	icon_state = "fc_beacon_activating"
	base_icon_state = "fc_beacon"
	job_list = list(
		/datum/job/som/ert/standard,
		/datum/job/som/ert/standard,
		/datum/job/som/ert/medic,
		/datum/job/som/ert/veteran,
	)

/obj/structure/npc_beacon/som_big/set_job_list()
	job_list += pickweight(list(
		/datum/job/som/ert/standard = 15,
		/datum/job/som/ert/veteran = 25,
		/datum/job/som/ert/specialist = 20,
		/datum/job/som/ert/leader = 60,
	))
