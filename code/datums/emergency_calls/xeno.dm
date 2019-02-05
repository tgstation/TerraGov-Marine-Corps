/datum/emergency_call/xenomorphs
	name = "Xenomorphs"
	probability = 10
	auto_shuttle_launch = TRUE
	

/datum/emergency_call/xenomorphs/print_backstory(mob/living/carbon/Xenomorph/X)
	to_chat(X, "<B>You are Xenomorph from a distant hive.</b>")
	to_chat(X, "<B>You've been cruising in space for years until a new Queen reached out to you and took over the control of your shuttle.</b>")
	to_chat(X, "<B>Help the new Queen take over this sector. For the new Hive!</b>")


/datum/emergency_call/xenomorphs/spawn_items()
	var/turf/drop_spawn	= get_spawn_point(TRUE)
	if(istype(drop_spawn))
		new /obj/effect/alien/weeds/node(drop_spawn) //Drop some weeds for xeno plasma regen.


/datum/emergency_call/xenomorphs/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) 
		return

	var/mob/living/carbon/Xenomorph/new_xeno

	if(original)
		qdel(original)


	if(!leader)
		new_xeno = new /mob/living/carbon/Xenomorph/Ravager(spawn_loc)
		leader = new_xeno
		new_xeno.key = M.key
		print_backstory(new_xeno)
		return

	if(prob(35))
		new_xeno = new /mob/living/carbon/Xenomorph/Drone/elder(spawn_loc)
		new_xeno.key = M.key
		print_backstory(new_xeno)
		return


	if(prob(35))
		new_xeno = new /mob/living/carbon/Xenomorph/Spitter/mature(spawn_loc)
		new_xeno.key = M.key
		print_backstory(new_xeno)
		return

	new_xeno = new /mob/living/carbon/Xenomorph/Hunter/mature(spawn_loc)
	new_xeno.key = M.key
	print_backstory(new_xeno)