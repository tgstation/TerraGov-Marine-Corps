
/datum/emergency_call/zombie
	name = "Zombies"
	mob_max = 8
	mob_min = 1
	probability = 0
	auto_shuttle_launch = TRUE //can't use the shuttle console with zombie claws, so has to autolaunch.


/datum/emergency_call/zombie/create_member(datum/mind/M)
	var/turf/T = get_spawn_point()
	var/mob/original = M.current

	if(!istype(T)) return FALSE

	var/mob/living/carbon/human/H = new(T)
	H.gender = pick(MALE, FEMALE)
	var/datum/preferences/A = new
	A.randomize_appearance_for(H)
	H.real_name = capitalize(pick(H.gender == MALE ? first_names_male : first_names_female)) + " " + capitalize(pick(last_names))
	H.name = H.real_name
	H.age = rand(21,45)
	H.dna.ready_dna(H)
	H.key = M.key
	if(H.client) H.client.change_view(world.view)
	H.mind.assigned_role = "Zombie"
	H.mind.special_role = "MODE"
	ticker.mode.traitors += H.mind
	H.mind.cm_skills = null //no restriction
	H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), WEAR_FEET)
	H.set_species("Zombie")
	H.contract_disease(new /datum/disease/black_goo)
	for(var/datum/disease/black_goo/BG in H.viruses)
		BG.stage = 5

	spawn(20)
		if(H && H.loc)
			to_chat(H, "<span class='role_header'>You are a Zombie!</span>")
			to_chat(H, "<span class='role_body'>Spread... Consume... Infect...</span>")

	if(original && original.loc)
		cdel(original)