//This datum keeps track of individual squads. New squads can be added without any problem but to give them
//access you must add them individually to access.dm with the other squads. Just look for "access_alpha" and add the new one
//whereever you find it.

/datum/squad
	var/name = "New Squad"  //Name of the squad
	var/max_positions = -1 //Maximum number allowed in a squad. Defaults to infinite
	var/color = 0 //Color for helmets, etc.
	var/max_engineers = 2 //maximum # of engineers allowed in squad
	var/max_medics = 2 //Ditto, squad medics
	var/num_ranks = 2 //Ranks aren't currently used, but they let you promote people within a squad
	var/list/rank_name = list("Marine","Leader") //Currently just two ranks, marine and leader
	var/list/access = list()
	//vvv Do not change these
	var/mob/living/carbon/human/squad_leader = null //Who currently leads it.
	var/num_engineers = 0
	var/num_medics = 0
	var/count = 0 //Current # in the squad
	var/list/current_squads = list()
	//^^^ Do not change these


/datum/squad/alpha
	name = "Alpha"
	color = 1
	access = list(access_squad_alpha)

/datum/squad/bravo
	name = "Bravo"
	color = 2
	access = list(access_squad_bravo)

/datum/squad/charlie
	name = "Charlie"
	color = 3
	access = list(access_squad_charlie)

/datum/squad/delta
	name = "Delta"
	color = 4
	access = list(access_squad_delta)

//Populate the squad lists so we can grab them later
/datum/squad/proc/setup_squads()
	current_squads = typesof(/datum/squad)
	if(!current_squads.len)
		world << "\red Warning: No squads found!"
	return

//Counts up the # of people in a specific squad or in all squads
/datum/squad/proc/get_count(var/datum/squad/S)
	var/total = 0
	if(isnull(S) || !S) //No squad specified, count up totals for all squads
		for(var/datum/squad/Q in current_squads)
			total += Q.count
		return total //Just leave. This will return the # of people in all squads.
	else
		return S.count //Just return the # of people in the specified squad

//Returns the datum path of a squad by giving it the name, ie. "Charlie"
//returns null if you spelled it wrong
/datum/squad/proc/get_squad_by_name(var/text)
	for(var/datum/squad/Q in current_squads)
		if(Q.name == text)
			return Q
	return null

