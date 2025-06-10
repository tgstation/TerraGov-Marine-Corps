/obj/item/explosive/grenade/spawnergrenade
	desc = "It is set to detonate in 5 seconds. It will unleash unleash an unspecified anomaly into the vicinity."
	name = "delivery grenade"
	icon_state = "delivery"
	worn_icon_state = "flashbang"
	var/banglet = 0
	var/spawner_type = null // must be an object path
	var/deliveryamt = 1 // amount of type to deliver

/obj/item/explosive/grenade/spawnergrenade/prime()	// Prime now just handles the two loops that query for people in lockers and people who can see it.

	if(spawner_type && deliveryamt)
		// Make a quick flash
		var/turf/T = get_turf(src)
		playsound(T, 'sound/effects/phasein.ogg', 25, 1)
		for(var/mob/living/carbon/human/M in viewers(T, null))
			M.flash_act(1, TRUE)

		for(var/i=1, i<=deliveryamt, i++)
			var/atom/movable/x = new spawner_type
			x.loc = T
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(x, pick(NORTH,SOUTH,EAST,WEST))

			// Spawn some hostile syndicate critters

	qdel(src)


/obj/item/explosive/grenade/spawnergrenade/spesscarp
	name = "carp delivery grenade"
	spawner_type = /mob/living/simple_animal/hostile/carp
	deliveryamt = 5

/obj/item/explosive/grenade/human_spawner
	desc = "It is set to detonate in 5 seconds. It will unleash unleash an unspecified anomaly into the vicinity."
	name = "delivery grenade"
	icon_state = "delivery"
	worn_icon_state = "flashbang"
	var/list/job_list

/obj/item/explosive/grenade/human_spawner/prime()
	var/turf/spawn_loc = get_turf(src)
	if(!spawn_loc)
		qdel(src)
		return
	var/list/mob_list = list()
	for(var/i = 1 to length(job_list))
		var/mob/living/carbon/human/new_human = new()
		mob_list += new_human
		var/datum/job/new_job = SSjob.GetJobType(job_list[i])
		var/squad_to_insert_into
		if(ismarinejob(new_job) || issommarinejob(new_job))
			squad_to_insert_into = pick(SSjob.active_squads[new_job.faction])
		new_human.apply_assigned_role_to_spawn(new_job, new_human.client, squad_to_insert_into, TRUE)
		stoplag()
	for(var/mob/living/carbon/human/dude AS in mob_list)
		dude.forceMove(spawn_loc)
		dude.AddComponent(/datum/component/ai_controller, /datum/ai_behavior/human)
		if(istype(dude.wear_ear, /obj/item/radio/headset/mainship)) //due to the lagginess of spawning in mobs, this won't proc at the right time normally
			var/obj/item/radio/headset/mainship/worn_headset = dude.wear_ear
			worn_headset.update_minimap_icon()

	qdel(src)

/obj/item/explosive/grenade/human_spawner/marine
	job_list = list(
		/datum/job/terragov/squad/standard/npc,
		/datum/job/terragov/squad/standard/npc,
	)

/obj/item/explosive/grenade/human_spawner/marine/Initialize(mapload)
	job_list += pickweight(list(
		/datum/job/terragov/squad/standard/npc = 20,
		/datum/job/terragov/squad/engineer/npc = 30,
		/datum/job/terragov/squad/corpsman/npc = 30,
		/datum/job/terragov/squad/smartgunner/npc = 20,
		/datum/job/terragov/squad/leader/npc = 10,
	))
	return ..()

/obj/item/explosive/grenade/human_spawner/som
	job_list = list(
		/datum/job/som/ert/standard,
		/datum/job/som/ert/standard,
	)

/obj/item/explosive/grenade/human_spawner/som/Initialize(mapload)
	job_list += pickweight(list(
		/datum/job/som/ert/standard = 20,
		/datum/job/som/ert/medic = 30,
		/datum/job/som/ert/veteran = 30,
		/datum/job/som/ert/specialist = 20,
		/datum/job/som/ert/leader = 10,
	))
	return ..()
