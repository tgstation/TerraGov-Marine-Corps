//Colonist ERT for admin stuff.
/datum/emergency_call/colonist
	name = "Colonists"
	arrival_message = "Incoming Transmission: 'This is the *static*. We are *static*.'"
	objectives = "Follow the orders given to you."
	probability = 0


/datum/emergency_call/colonist/create_member(datum/mind/M) //Blank ERT with only basic items.
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) 
		return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new /mob/living/carbon/human(spawn_loc)

	mob.key = M.key
	mob.client?.change_view(world.view)
	spawn(0)
		var/datum/job/J = new /datum/job/other/colonist
		mob.set_everything(mob, "Colonist")
		J.generate_equipment(mob)
		to_chat(mob, "<span class='role_header'>You are a colonist!</span>")

	if(original)
		cdel(original)
	return