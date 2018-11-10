//Terrified pizza delivery
/datum/emergency_call/pizza
	name = "Pizza Delivery"
	mob_max = 1
	arrival_message = "Incoming Transmission: 'That'll be.. sixteen orders of cheesy fries, eight large double topping pizzas, nine bottles of Four Loko.. hello? Is anyone on this ship? Your pizzas are getting cold.'"
	objectives = "Make sure you get a tip!"
	probability = 5

/datum/emergency_call/pizza/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) 
		return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new /mob/living/carbon/human(spawn_loc)

	mob.key = M.key
	mob.client?.change_view(world.view)
	spawn(0)
		var/datum/job/J = new /datum/job/other/pizza
		mob.set_everything(mob, "Pizza Deliverer")
		J.generate_equipment(mob)
		var/pizzatxt = pick("Discount Pizza","Pizza Kingdom","Papa Pizza")
		to_chat(mob, "<font size='3'>\red You are a pizza deliverer! Your employer is the [pizzatxt] Corporation.</font>")
		to_chat(mob, "Your job is to deliver your pizzas. You're PRETTY sure this is the right place..")
	spawn(10)
		to_chat(M, "<B>Objectives:</b> [objectives]")

	if(original)
		cdel(original)
	return