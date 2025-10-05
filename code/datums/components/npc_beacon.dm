///Allows an atom to rally NPC's to it
/datum/component/npc_beacon
	var/faction
	///Escort priority
	var/npc_priority
	///list of slaved NPC's
	var/list/npc_list = list()
	///Leash radius, will this matter?
	var/leash_range

	var/is_global = FALSE

/datum/component/npc_beacon/Initialize(new_faction, priority_rating = AI_ESCORT_RATING_ENSALVED_STRONG, _is_global = FALSE, list/slaved_npc_list, _leash_range = 9)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	faction = new_faction
	npc_priority = priority_rating
	is_global = _is_global //todo: make this a glob signal that goal nodes uses as well
	leash_range = _leash_range
	for(var/slave in slaved_npc_list)
		register_slave(slave)

/datum/component/npc_beacon/Destroy(force, silent)
	for(var/slave in npc_list)
		unregister_slave(slave)
	return ..()

/datum/component/npc_beacon/RegisterWithParent()
	//sig to add/remove npc slaves
	RegisterSignal(parent, COMSIG_COMPONENT_ADD_NEW_SLAVE_NPC, PROC_REF(register_slave))

/datum/component/npc_beacon/UnregisterFromParent()

/datum/component/npc_beacon/proc/get_escort_target(mob/living/source, list/goal_list)
	SIGNAL_HANDLER
	goal_list[parent] = npc_priority

/datum/component/npc_beacon/proc/register_slave(mob/living/new_slave)
	SIGNAL_HANDLER
	RegisterSignal(new_slave, COMSIG_NPC_FIND_NEW_ESCORT, PROC_REF(get_escort_target))
	RegisterSignal(new_slave, COMSIG_QDELETING, PROC_REF(unregister_slave))
	npc_list += new_slave

/datum/component/npc_beacon/proc/unregister_slave(mob/living/old_slave)
	SIGNAL_HANDLER
	UnregisterSignal(old_slave, list(COMSIG_NPC_FIND_NEW_ESCORT, COMSIG_QDELETING))
	npc_list -= old_slave

/////////
/obj/item/campaign_beacon/npc_controller
	name = "npc beacon"
	desc = "A bulky device that is used to provide precision guidance to powerful orbital weapon systems."
	icon = 'icons/obj/items/npc_beacon.dmi'
	icon_state = "beacon_undeployed"
	deployable_type = /obj/structure/npc_controller
	deploy_time = 2 SECONDS
	pixel_w = -4

/obj/item/campaign_beacon/npc_controller/tgmc_standard
	deployable_type = /obj/structure/npc_controller/tgmc_standard

/obj/structure/npc_controller
	name = "deployed npc beacon"
	desc = "An ominous red beacon, used to provide precision guidance to powerful orbital weapon systems."
	icon = 'icons/obj/items/npc_beacon.dmi'
	icon_state = "beacon_activating"
	base_icon_state = "beacon"
	faction = FACTION_TERRAGOV
	density = FALSE
	pixel_w = -8
	///List of jobs that are spawned by this item
	var/list/job_list

/obj/structure/npc_controller/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(spawn_mobs)), 3 SECONDS) //placeholder delay
	set_job_list()
	update_appearance()
	flick("[base_icon_state]_deploying", src)

/obj/structure/npc_controller/update_icon_state()
	if(length(job_list))
		icon_state = "[base_icon_state]_activating"
	else
		icon_state = "[base_icon_state]_deployed_on"

/obj/structure/npc_controller/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[base_icon_state]_emissive", src)

/obj/structure/npc_controller/proc/set_job_list()
	return

/obj/structure/npc_controller/proc/spawn_mobs()
	if(QDELETED(src))
		return
	var/turf/spawn_loc = get_turf(src)
	var/list/slave_list = spawn_npc_squad(spawn_loc, job_list)
	AddComponent(/datum/component/npc_beacon, faction, slaved_npc_list = slave_list)
	job_list = null
	update_appearance()

/obj/structure/npc_controller/tgmc_standard
	job_list = list(
		/datum/job/terragov/squad/standard/npc,
		/datum/job/terragov/squad/standard/npc,
	)

/obj/structure/npc_controller/tgmc_standard/set_job_list()
	job_list += pickweight(list(
		/datum/job/terragov/squad/standard/npc = 20,
		/datum/job/terragov/squad/engineer/npc = 30,
		/datum/job/terragov/squad/corpsman/npc = 30,
		/datum/job/terragov/squad/smartgunner/npc = 20,
		/datum/job/terragov/squad/leader/npc = 10,
	))
