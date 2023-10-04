/datum/emergency_call/xenomorphs_corrupted
	name = "Xenomorphs (Corrupted Hive)"
	base_probability = 0
	auto_shuttle_launch = TRUE
	spawn_type = null


/datum/emergency_call/xenomorphs_corrupted/print_backstory(mob/living/carbon/xenomorph/X)
	to_chat(X, "<B>We are a Xenomorph from an artifical corrupted hive created by the tallhosts.</b>")
	to_chat(X, "<B>We've been stuck on this shuttle for years until someone reached out to us and took over the control of our shuttle remotely.</b>")
	to_chat(X, "<B>From what we understand, it appears that someone launched this shuttle in order to help our fellow humans who are in trouble.</b>") // Human friendly ERT
	to_chat(X, "<B>Expand our hive and destroy any other hives that we may encounter. For the corrupted Hive!</b>")


/datum/emergency_call/xenomorphs_corrupted/spawn_items()
	var/turf/drop_spawn = get_spawn_point(TRUE)
	if(istype(drop_spawn))
		new /obj/alien/weeds/node(drop_spawn) //Drop some weeds for xeno plasma regen.


/datum/emergency_call/xenomorphs_corrupted/create_member(datum/mind/M)
	. = ..()
	if(!.)
		return

	var/mob/original = M.current
	var/turf/spawn_loc = .

	if(!leader)
		. = new /mob/living/carbon/xenomorph/ravager/Corrupted(spawn_loc, TRUE) //TRUE for the can_spawn_in_centcom, so they don't get sent to a different hive.
		leader = .
		M.transfer_to(., TRUE)
		print_backstory(.)
		return

	if(prob(35))
		. = new /mob/living/carbon/xenomorph/drone/Corrupted(spawn_loc, TRUE)
		M.transfer_to(., TRUE)
		print_backstory(.)
		return

	if(prob(35))
		. = new /mob/living/carbon/xenomorph/spitter/Corrupted(spawn_loc, TRUE)
		M.transfer_to(., TRUE)
		print_backstory(.)
		return

	. = new /mob/living/carbon/xenomorph/hunter/Corrupted(spawn_loc, TRUE)
	M.transfer_to(., TRUE)
	print_backstory(.)

	if(original)
		qdel(original)
