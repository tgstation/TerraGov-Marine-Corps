//STRIKE TEAMS
//Thanks to Kilakk for the admin-button portion of this code.

var/list/response_team_members = list()
var/global/send_emergency_team = 0 // Used for automagic response teams
                                   // 'admin_emergency_team' for admin-spawned response teams
var/ert_base_chance = 10 // Default base chance. Will be incremented by increment ERT chance.
var/can_call_ert

/client/proc/response_team()
	set name = "Dispatch Emergency Response Team"
	set category = "Special Verbs"
	set desc = "Send an emergency response team to the station"

	if(!holder)
		to_chat(usr, "\red Only administrators may use this command.")
		return
	if(!ticker)
		to_chat(usr, "\red The game hasn't started yet!")
		return
	if(ticker.current_state == 1)
		to_chat(usr, "\red The round hasn't started yet!")
		return
	if(send_emergency_team)
		to_chat(usr, "\red Central Command has already dispatched an emergency response team!")
		return
	if(alert("Do you want to dispatch an Emergency Response Team?",,"Yes","No") != "Yes")
		return
	if(get_security_level() != "red") // Allow admins to reconsider if the alert level isn't Red
		switch(alert("The station is not in red alert. Do you still want to dispatch a response team?",,"Yes","No"))
			if("No")
				return
	if(send_emergency_team)
		to_chat(usr, "\red Looks like somebody beat you to it!")
		return

	message_admins("[key_name_admin(usr)] is dispatching an Emergency Response Team.", 1)
	log_admin("[key_name(usr)] used Dispatch Response Team.")
	trigger_armed_response_team(1)

/*
client/verb/JoinResponseTeam()
	set category = "IC"

	if(istype(usr,/mob/dead/observer) || istype(usr,/mob/new_player))
		if(!send_emergency_team)
			to_chat(usr, "No emergency response team is currently being sent.")
			return
	/*	if(admin_emergency_team)
			to_chat(usr, "An emergency response team has already been sent.")
			return */
		if(jobban_isbanned(usr, "Syndicate") || jobban_isbanned(usr, "Emergency Response Team") || jobban_isbanned(usr, "Security Officer"))
			to_chat(usr, "<font color=red><b>You are jobbanned from the emergency reponse team!")
			return

		if(response_team_members.len > 5) to_chat(usr, "The emergency response team is already full!")


		for (var/obj/effect/landmark/L in landmarks_list) if (L.name == "Commando")
			L.name = null//Reserving the place.
			var/new_name = input(usr, "Pick a name","Name") as null|text
			if(!new_name)//Somebody changed his mind, place is available again.
				L.name = "Commando"
				return
			var/leader_selected = isemptylist(response_team_members)
			var/mob/living/carbon/human/new_commando = create_response_team(L.loc, leader_selected, new_name)
			qdel(L)
			new_commando.mind.key = usr.key
			new_commando.key = usr.key

			to_chat(new_commando, "\blue You are [!leader_selected?"a member":"the <B>LEADER</B>"] of an Emergency Response Team, a type of military division, under CentComm's service. There is a code red alert on [station_name()], you are tasked to go and fix the problem.")
			to_chat(new_commando, "<b>You should first gear up and discuss a plan with your team. More members may be joining, don't move out before you're ready.")
			if(!leader_selected)
				to_chat(new_commando, "<b>As member of the Emergency Response Team, you answer only to your leader and CentComm officials.</b>")
			else
				to_chat(new_commando, "<b>As leader of the Emergency Response Team, you answer only to CentComm, and have authority to override the Captain where it is necessary to achieve your mission goals. It is recommended that you attempt to cooperate with the captain where possible, however.")
			return

	else
		to_chat(usr, "You need to be an observer or new player to use this.")
*/
// returns a number of dead players in %
proc/percentage_dead()
	var/total = 0
	var/deadcount = 0
	for(var/mob/living/carbon/human/H in mob_list)
		if(H.client) // Monkeys and mice don't have a client, amirite?
			if(H.stat == 2) deadcount++
			total++

	if(total == 0) return 0
	else return round(100 * deadcount / total)

// counts the number of antagonists in %
proc/percentage_antagonists()
	var/total = 0
	var/antagonists = 0
	for(var/mob/living/carbon/human/H in mob_list)
		if(is_special_character(H) >= 1)
			antagonists++
		total++

	if(total == 0) return 0
	else return round(100 * antagonists / total)

// Increments the ERT chance automatically, so that the later it is in the round,
// the more likely an ERT is to be able to be called.
proc/increment_ert_chance()
	while(send_emergency_team == 0) // There is no ERT at the time.
		if(get_security_level() == "green")
			ert_base_chance += 1
		if(get_security_level() == "blue")
			ert_base_chance += 2
		if(get_security_level() == "red")
			ert_base_chance += 3
		if(get_security_level() == "delta")
			ert_base_chance += 10           // Need those big guns
		sleep(600 * 3) // Minute * Number of Minutes


proc/trigger_armed_response_team(var/force = 0)
	if(!can_call_ert && !force)
		return
	if(send_emergency_team)
		return

	var/send_team_chance = ert_base_chance // Is incremented by increment_ert_chance.
	send_team_chance += 2*percentage_dead() // the more people are dead, the higher the chance
	send_team_chance += percentage_antagonists() // the more antagonists, the higher the chance
	send_team_chance = min(send_team_chance, 100)

	if(force) send_team_chance = 100

	// there's only a certain chance a team will be sent
	if(!prob(send_team_chance))
		command_announcement.Announce("It would appear that an emergency response team was requested for [station_name()]. Unfortunately, we were unable to send one at this time.", "Central Command")
		can_call_ert = 0 // Only one call per round, ladies.
		return

	command_announcement.Announce("It would appear that an emergency response team was requested for [station_name()]. We will prepare and send one as soon as possible.", "Central Command")

	can_call_ert = 0 // Only one call per round, gentleman.
	send_emergency_team = 1

	sleep(600 * 5)
	send_emergency_team = 0 // Can no longer join the ERT.

/client/proc/create_response_team(obj/spawn_location, leader_selected = 0, commando_name)

	//to_chat(usr, "\red ERT has been temporarily disabled. Talk to a coder.")
	//return

	var/mob/living/carbon/human/M = new(null)
	response_team_members |= M

	//todo: god damn this.
	//make it a panel, like in character creation
	var/new_facial = input("Please select facial hair color.", "Character Generation") as color
	if(new_facial)
		M.r_facial = hex2num(copytext(new_facial, 2, 4))
		M.g_facial = hex2num(copytext(new_facial, 4, 6))
		M.b_facial = hex2num(copytext(new_facial, 6, 8))

	var/new_hair = input("Please select hair color.", "Character Generation") as color
	if(new_facial)
		M.r_hair = hex2num(copytext(new_hair, 2, 4))
		M.g_hair = hex2num(copytext(new_hair, 4, 6))
		M.b_hair = hex2num(copytext(new_hair, 6, 8))

	var/new_eyes = input("Please select eye color.", "Character Generation") as color
	if(new_eyes)
		M.r_eyes = hex2num(copytext(new_eyes, 2, 4))
		M.g_eyes = hex2num(copytext(new_eyes, 4, 6))
		M.b_eyes = hex2num(copytext(new_eyes, 6, 8))


	// hair
	var/list/all_hairs = subtypesof(/datum/sprite_accessory/hair)
	var/list/hairs = list()

	// loop through potential hairs
	for(var/x in all_hairs)
		var/datum/sprite_accessory/hair/H = new x // create new hair datum based on type x
		hairs.Add(H.name) // add hair name to hairs
		qdel(H) // delete the hair after it's all done

//	var/new_style = input("Please select hair style", "Character Generation")  as null|anything in hairs
//hair
	var/new_hstyle = input(usr, "Select a hair style", "Grooming")  as null|anything in hair_styles_list
	if(new_hstyle)
		M.h_style = new_hstyle

	// facial hair
	var/new_fstyle = input(usr, "Select a facial hair style", "Grooming")  as null|anything in facial_hair_styles_list
	if(new_fstyle)
		M.f_style = new_fstyle


	var/new_gender = alert(usr, "Please select gender.", "Character Generation", "Male", "Female")
	if (new_gender)
		if(new_gender == "Male")
			M.gender = MALE
		else
			M.gender = FEMALE
	//M.rebuild_appearance()
	M.update_hair()
	M.update_body()
	M.check_dna(M)

	M.real_name = commando_name
	M.name = commando_name
	M.age = !leader_selected ? rand(23,35) : rand(35,45)

	M.dna.ready_dna(M)//Creates DNA.

	//Creates mind stuff.
	M.mind = new
	M.mind.current = M
	M.mind.original = M
	M.mind.assigned_role = "MODE"
	M.mind.special_role = "Response Team"
	if(!(M.mind in ticker.minds))
		ticker.minds += M.mind//Adds them to regular mind list.
	M.loc = spawn_location
	M.equip_strike_team(leader_selected)
	return M

/mob/living/carbon/human/proc/equip_strike_team(leader_selected = 0)

	//Special radio setup
	equip_to_slot_or_del(new /obj/item/device/radio/headset/ert(src), WEAR_EAR)

	//Replaced with new ERT uniform
	equip_to_slot_or_del(new /obj/item/clothing/under/ert(src), WEAR_BODY)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/swat(src), WEAR_FEET)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/swat(src), WEAR_HANDS)
	equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(src), WEAR_EYES)
/*

	//Old ERT Uniform
	//Basic Uniform
	equip_to_slot_or_del(new /obj/item/clothing/under/syndicate/tacticool(src), WEAR_BODY)
	equip_to_slot_or_del(new /obj/item/device/flashlight(src), WEAR_L_STORE)
	equip_to_slot_or_del(new /obj/item/clipboard(src), WEAR_R_STORE)
	equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(src), WEAR_WAIST)
	equip_to_slot_or_del(new /obj/item/clothing/mask/gas/swat(src), WEAR_FACE)

	//Glasses
	equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud(src), WEAR_EYES)

	//Shoes & gloves
	equip_to_slot_or_del(new /obj/item/clothing/shoes/swat(src), WEAR_FEET)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/swat(src), WEAR_HANDS)

	//Removed
//	equip_to_slot_or_del(new /obj/item/clothing/suit/armor/swat(src), WEAR_JACKET)
//	equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/deathsquad(src), WEAR_HEAD)

	//Backpack
	equip_to_slot_or_del(new /obj/item/storage/backpack/security(src), WEAR_BACK)
	equip_to_slot_or_del(new /obj/item/storage/box/engineer(src), WEAR_IN_BACK)
	equip_to_slot_or_del(new /obj/item/storage/firstaid/regular(src), WEAR_IN_BACK)
*/
	var/obj/item/card/id/W = new(src)
	W.assignment = "Emergency Response Team[leader_selected ? " Leader" : ""]"
	W.registered_name = real_name
	W.name = "[real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_all_centcom_access()
	equip_to_slot_or_del(W, WEAR_ID)

	return 1

//debug verb (That is horribly coded, LEAVE THIS OFF UNLESS PRIVATELY TESTING. Seriously.
/*client/verb/ResponseTeam()
	set category = "Admin"
	if(!send_emergency_team)
		send_emergency_team = 1*/
