
//Xenomorphs, hostile to everyone.
/datum/emergency_call/xenos
	name = "Xenomorphs (Squad)"
	mob_max = 7
	probability = 10
	role_needed = BE_ALIEN

	New()
		..()
		arrival_message = "[MAIN_SHIP_NAME], this is USS Vriess respond-- #&...*#&^#.. signal.. oh god, they're in the vent---... Priority Warning: Signal lost."
		objectives = "For the Empress!"

/datum/emergency_call/xenos/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.
	var/chance = rand(0,3)
	var/mob/living/carbon/Xenomorph/new_xeno
	if(!leader)
		new_xeno = new /mob/living/carbon/Xenomorph/Ravager(spawn_loc)
		leader = new_xeno
	else if(chance == 0)
		new_xeno = new /mob/living/carbon/Xenomorph/Drone/elite(spawn_loc)
	else if(chance == 1)
		new_xeno = new /mob/living/carbon/Xenomorph/Spitter/mature(spawn_loc)
	else
		new_xeno = new /mob/living/carbon/Xenomorph/Hunter/mature(spawn_loc)
	new_xeno.key  = M.key

	if(original) //Just to be sure.
		cdel(original)



/datum/emergency_call/xenos/platoon
	name = "Xenomorphs (Platoon)"
	mob_min = 8
	mob_max = 30
	probability = 0
