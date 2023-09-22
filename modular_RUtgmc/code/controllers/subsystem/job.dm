//Gives the player the stuff they should have with their rank.
/datum/controller/subsystem/job/spawn_character(mob/new_player/player, joined_late = FALSE)
	var/mob/living/new_character = player.new_character
	var/datum/job/job = player.assigned_role

	new_character.apply_assigned_role_to_spawn(job, player.client, player.assigned_squad)

	//If we joined at roundstart we should be positioned at our workstation
	var/turf/spawn_turf
	if(!joined_late || job.job_flags & JOB_FLAG_OVERRIDELATEJOINSPAWN)
		var/datum/job/terragov/squad/marine = job
		var/mob/living/carbon/human/h = new_character
		if(!ishuman(new_character) || !h.assigned_squad || !length_char(GLOB.start_squad_landmarks_list))
			spawn_turf = job.return_spawn_turf()
		else
			spawn_turf = marine.spawn_by_squads(h.assigned_squad.id)
	if(spawn_turf)
		SendToAtom(new_character, spawn_turf)
	else
		SendToLateJoin(new_character, job)

	job.radio_help_message(player)

	job.after_spawn(new_character, player, joined_late) // note: this happens before new_character has a key!

	return new_character

/datum/controller/subsystem/job/SendToLateJoin(mob/M, datum/job/assigned_role)
	switch(assigned_role.faction)
		if(FACTION_SOM)
			if(length(GLOB.latejoinsom))
				SendToAtom(M, pick(GLOB.latejoinsom))
				return
		else
			var/mob/living/carbon/human/h = M
			if(h.assigned_squad && length_char(GLOB.latejoin_squad_landmarks_list))
				SendToAtom(M, pick(GLOB.latejoin_squad_landmarks_list[h.assigned_squad.id]))
				return
			else
				if(length_char(GLOB.latejoin))
					SendToAtom(M, pick(GLOB.latejoin))
					return
	message_admins("Unable to send mob [M] to late join!")
	CRASH("Unable to send mob [M] to late join!")
