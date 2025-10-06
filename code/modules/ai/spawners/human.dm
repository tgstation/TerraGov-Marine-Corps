///Spawns a number of human mobs at a given location, based of a list of jobs
/proc/spawn_npc_squad(turf/location, list/role_list)
	if(!isturf(location))
		location = get_turf(location)
	if(!location)
		return
	var/list/mob_list = list()
	var/squad_to_insert_into
	var/datum/job/job_checked = SSjob.GetJobType(role_list[1])
	if(ismarinejob(job_checked) || issommarinejob(job_checked))
		squad_to_insert_into = pick(SSjob.active_squads[job_checked.faction])

	for(var/i = 1 to length(role_list))
		var/mob/living/carbon/human/new_human = new()
		mob_list += new_human
		var/datum/job/new_job = SSjob.GetJobType(role_list[i])
		new_human.apply_assigned_role_to_spawn(new_job, new_human.client, squad_to_insert_into, TRUE)
		stoplag()

	for(var/mob/living/carbon/human/dude AS in mob_list)
		dude.forceMove(location)
		dude.AddComponent(/datum/component/ai_controller, /datum/ai_behavior/human)
		if(istype(dude.wear_ear, /obj/item/radio/headset/mainship)) //due to the lagginess of spawning in mobs, this won't proc at the right time normally
			var/obj/item/radio/headset/mainship/worn_headset = dude.wear_ear
			worn_headset.update_minimap_icon()

/obj/effect/ai_node/spawner/human
	name = "AI human spawner node"
	use_postspawn = TRUE //Gotta equip those AI you know

/obj/effect/ai_node/spawner/human/deathsquad
	spawntypes = /mob/living/carbon/human/node_pathing
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/human/deathsquad/postspawn(list/squad)
	var/mob/living/carbon/human/SL = pick_n_take(squad)
	var/datum/job/job = SSjob.GetJobType(/datum/job/deathsquad/leader)
	SL.apply_assigned_role_to_spawn(job)
	job = SSjob.GetJobType(/datum/job/deathsquad/standard)
	for(var/mob/living/carbon/human/squaddie AS in squad)
		squaddie.apply_assigned_role_to_spawn(job)
