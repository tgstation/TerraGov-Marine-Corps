/datum/emergency_call/xenomorphs_zeta
	name = "Xenomorphs (Zeta Hive)"
	base_probability = 0
	auto_shuttle_launch = TRUE
	spawn_type = null


/datum/emergency_call/xenomorphs_zeta/print_backstory(mob/living/carbon/xenomorph/X)
	to_chat(X, "<B>We are a Xenomorph from the Zeta hive.</b>")
	to_chat(X, "<B>We've been cruising in space for years until a new Queen reached out to us and took over the control of our shuttle.</b>") // Admin-only ERT, so queens only.
	to_chat(X, "<B>Expand our hive and destroy any who dare to oppose our influence especially other hives. For the Zeta Hive!</b>")


/datum/emergency_call/xenomorphs_zeta/spawn_items()
	var/turf/drop_spawn	= get_spawn_point(TRUE)
	if(istype(drop_spawn))
		new /obj/effect/alien/weeds/node(drop_spawn) //Drop some weeds for xeno plasma regen.


/datum/emergency_call/xenomorphs_zeta/create_member(datum/mind/M)
	. = ..()
	if(!.)
		return

	var/mob/original = M.current
	var/turf/spawn_loc = .

	if(!leader)
		. = new /mob/living/carbon/xenomorph/ravager/Zeta(spawn_loc, TRUE) //TRUE for the can_spawn_in_centcom, so they don't get sent to a different hive.
		leader = .
		M.transfer_to(., TRUE)
		print_backstory(.)
		return

	if(prob(35))
		. = new /mob/living/carbon/xenomorph/drone/elder/Zeta(spawn_loc, TRUE)
		M.transfer_to(., TRUE)
		print_backstory(.)
		return

	if(prob(35))
		. = new /mob/living/carbon/xenomorph/spitter/mature/Zeta(spawn_loc, TRUE)
		M.transfer_to(., TRUE)
		print_backstory(.)
		return

	. = new /mob/living/carbon/xenomorph/hunter/mature/Zeta(spawn_loc, TRUE)
	M.transfer_to(., TRUE)
	print_backstory(.)

	if(original)
		qdel(original)
