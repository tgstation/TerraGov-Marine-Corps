
//Terrified pizza delivery
/datum/emergency_call/pizza
	name = "Pizza Delivery"
	mob_max = 1
	mob_min = 1
	arrival_message = "Incoming Transmission: 'That'll be.. sixteen orders of cheesy fries, eight large double topping pizzas, nine bottles of Four Loko.. hello? Is anyone on this ship? Your pizzas are getting cold.'"
	objectives = "Make sure you get a tip!"
	probability = 5

/datum/emergency_call/pizza/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new(spawn_loc)
	mob.gender = pick(MALE,FEMALE)
	var/datum/preferences/A = new()
	A.randomize_appearance_for(mob)
	if(mob.gender == MALE)
		mob.real_name = "[pick(first_names_male)] [pick(last_names)]"
	else
		mob.real_name = "[pick(first_names_female)] [pick(last_names)]"
	mob.name = mob.real_name
	mob.age = rand(17,45)
	mob.dna.ready_dna(mob)
	mob.key = M.key
	if(mob.client) mob.client.change_view(world.view)
	mob.mind.assigned_role = "MODE"
	mob.mind.special_role = "Pizza"
	ticker.mode.traitors += mob.mind
	mob.mind.set_cm_skills(/datum/skills/civilian)
	spawn(0)
		spawn_pizza(mob)
		var/pizzatxt = pick("Discount Pizza","Pizza Kingdom","Papa Pizza")
		to_chat(mob, "<font size='3'>\red You are a pizza deliverer! Your employer is the [pizzatxt] Corporation.</font>")
		to_chat(mob, "Your job is to deliver your pizzas. You're PRETTY sure this is the right place..")
	spawn(10)
		to_chat(M, "<B>Objectives:</b> [objectives]")

	if(original)
		cdel(original)
	return

/datum/emergency_call/pizza/proc/spawn_pizza(var/mob/M)
	if(!M || !istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/clothing/under/pizza(M), WEAR_BODY)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/soft/red(M), WEAR_HEAD)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/red(M), WEAR_FEET)
	M.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel(M), WEAR_BACK)
	M.equip_to_slot_or_del(new /obj/item/pizzabox/margherita(M), WEAR_R_HAND)
	M.equip_to_slot_or_del(new /obj/item/device/radio(M), WEAR_R_STORE)
	M.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/cans/dr_gibb(M), WEAR_L_STORE)
	M.equip_to_slot_or_del(new /obj/item/device/flashlight(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/pizzabox/vegetable(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/pizzabox/mushroom(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/pizzabox/meat(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/cans/dr_gibb(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/cans/thirteenloko(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/holdout(M.back), WEAR_IN_BACK)

	var/obj/item/card/id/W = new(src)
	W.assignment = "Pizza Deliverer"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_freelancer_access()
	M.equip_to_slot_or_del(W, WEAR_ID)