//Deathsquad Commandos
/datum/emergency_call/death
	name = "Deathsquad"
	arrival_message = "Intercepted Transmission: '!`2*%slau#*jer t*h$em a!l%. le&*ve n(o^ w&*nes%6es.*v$e %#d ou^'"
	objectives = "Wipe out everything. Ensure there are no traces of the infestation or any witnesses."
	probability = 0
	shuttle_id = "Distress_PMC"
	name_of_spawn = "Distress_PMC"



// DEATH SQUAD--------------------------------------------------------------------------------
/datum/emergency_call/death/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current
	var/list/names = list("Alpha","Beta", "Gamma", "Delta","Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu", "Nu", "Xi", "Omnicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega")
	
	if(!istype(spawn_loc)) 
		return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new /mob/living/carbon/human(spawn_loc)
	
	mob.name = pick(names)
	mob.real_name = mob.name
	mob.voice_name = mob.name

	mob.key = M.key
	mob.client?.change_view(world.view)
	spawn(0)
		if(!leader)       //First one spawned is always the leader.
			leader = mob
			var/datum/job/J = new /datum/job/pmc/deathsquad/leader
			mob.set_everything(mob, "PMC Deathsquad Leader")
			J.generate_equipment(mob)
			to_chat(mob, "<font size='3'>\red You are the Death Squad Leader!</font>")
			to_chat(mob, "<B> You must clear out any traces of the infestation and its survivors..</b>")
			to_chat(mob, "<B> Follow any orders directly from Nanotrasen!</b>")
		else
			var/datum/job/J = new /datum/job/pmc/deathsquad/standard
			mob.set_everything(mob, "PMC Deathsquad Standard")
			J.generate_equipment(mob)
			to_chat(mob, "<font size='3'>\red You are a Death Squad Commando!!</font>")
			to_chat(mob, "<B> You must clear out any traces of the infestation and its survivors..</b>")
			to_chat(mob, "<B> Follow any orders directly from Nanotrasen!</b>")

	spawn(10)
		to_chat(M, "<B>Objectives:</b> [objectives]")

	if(original)
		cdel(original)
	return