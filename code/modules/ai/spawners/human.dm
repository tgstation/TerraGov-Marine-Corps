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
