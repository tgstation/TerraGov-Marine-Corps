

//Blank colonist ERT for admin stuff.
/datum/emergency_call/colonist
	name = "Colonists"
	mob_max = 8
	mob_min = 1
	arrival_message = "Incoming Transmission: 'This is the *static*. We are *static*.'"
	objectives = "Follow the orders given to you."
	probability = 0


/datum/emergency_call/colonist/create_member(datum/mind/M) //Blank ERT with only basic items.
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
	H.mind.assigned_role = "Colonist"
	H.mind.special_role = "MODE"
	ticker.mode.traitors += H.mind
	H.mind.cm_skills = null //no restriction
	H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), WEAR_FEET)
	H.equip_to_slot(new /obj/item/weapon/combat_knife(H), WEAR_L_STORE)
	H.equip_to_slot(new /obj/item/device/flashlight(H), WEAR_R_STORE)

	spawn(20)
		if(H && H.loc)
			to_chat(H, "<span class='role_header'>You are a colonist!</span>")
			to_chat(H, "<span class='role_body'>You have been put into the game by a staff member. Please follow all staff instructions.</span>")

	if(original && original.loc) cdel(original)