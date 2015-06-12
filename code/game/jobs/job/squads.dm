
//This datum keeps track of individual squads. New squads can be added without any problem but to give them
//access you must add them individually to access.dm with the other squads. Just look for "access_alpha" and add the new one

//Note: some important procs are held by the job controller, in job_controller.dm.
//In particular, get_lowest_squad() and randomize_squad()


/datum/squad
	var/name = "Empty Squad"  //Name of the squad
	var/max_positions = -1 //Maximum number allowed in a squad. Defaults to infinite
	var/color = 0 //Color for helmets, etc.
	var/list/access = list() //Which special access do we grant them
	var/usable = 0	 //Is it a valid squad?
	var/no_random_spawn = 0 //Stop players from spawning into the squad
	var/max_engineers = 2 //maximum # of engineers allowed in squad
	var/max_medics = 2 //Ditto, squad medics
	var/max_specialists = 1
	var/num_specialists = 0
	var/max_leaders = 1
	var/num_leaders = 0
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
	usable = 1

/datum/squad/bravo
	name = "Bravo"
	color = 2
	access = list(access_squad_bravo)
	usable = 1

/datum/squad/charlie
	name = "Charlie"
	color = 3
	access = list(access_squad_charlie)
	usable = 1

/datum/squad/delta
	name = "Delta"
	color = 4
	access = list(access_squad_delta)
	usable = 1



//Straight-up insert a marine into a squad.
//This sets their ID, increments the total count, and so on. Everything else is done in job_controller.dm.
//So it does not check if the squad is too full already, or randomize it, etc.
/datum/squad/proc/put_marine_in_squad(var/mob/living/carbon/human/M)
	if(!M || !istype(M,/mob/living/carbon/human)) return 0//Logic
	if(!src.usable) return 0
	if(!M.mind) return 0
	if(!M.mind.assigned_role || M.mind.assigned_squad) return 0//Not yet

	var/obj/item/weapon/card/id/C = null
	C = M.wear_id
	if(!C) C = M.get_active_hand()
	if(!C) return 0//Abort, no ID found

	if(M.mind.assigned_role == "Squad Engineer") src.num_engineers++
	if(M.mind.assigned_role == "Squad Medic") src.num_medics++
	if(M.mind.assigned_role == "Squad Specialist") src.num_specialists++
	if(M.mind.assigned_role == "Squad Leader") //If more than one leader are somehow added, it will replace the old with new.
		src.squad_leader = M
		src.num_leaders++

	src.count++ //Add up the tally. This is important in even squad distribution.

	M.mind.assigned_squad = src //Add them to the squad
	var/c_oldass = C.assignment
	C.access += src.access //Add their squad access to their ID
	C.assignment = "[src.name] [c_oldass]"
	C.name = "[C.registered_name]'s ID Card ([C.assignment])"
	return 1