


//Deathsquad Commandos
/datum/emergency_call/death
	name = "Weyland Deathsquad"
	mob_max = 8
	mob_min = 5
	arrival_message = "Intercepted Transmission: '!`2*%slau#*jer t*h$em a!l%. le&*ve n(o^ w&*nes%6es.*v$e %#d ou^'"
	objectives = "Wipe out everything. Ensure there are no traces of the infestation or any witnesses."
	probability = 0
	shuttle_id = "Distress_PMC"
	name_of_spawn = "Distress_PMC"



// DEATH SQUAD--------------------------------------------------------------------------------
/datum/emergency_call/death/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new(spawn_loc)
	mob.gender = pick(MALE)
	//var/datum/preferences/A = new()
	//A.randomize_appearance_for(mob)
	var/list/first_names_mr = list("Alpha","Beta", "Gamma", "Delta","Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu", "Nu", "Xi", "Omnicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega")
	if(mob.gender == MALE)
		mob.real_name = "[pick(first_names_mr)]"
	else
		mob.real_name = "[pick(first_names_mr)]"
	mob.name = mob.real_name
	mob.age = rand(17,45)
	mob.dna.ready_dna(mob)
	mob.key = M.key
	if(mob.client) mob.client.change_view(world.view)
	mob.mind.assigned_role = "MODE"
	mob.mind.special_role = "DEATH SQUAD"
	ticker.mode.traitors += mob.mind
	mob.mind.set_cm_skills(/datum/skills/commando/deathsquad)
	spawn(0)
		if(!leader)       //First one spawned is always the leader.
			leader = mob
			spawn_officer(mob)
			mob << "<font size='3'>\red You are the Death Squad Leader!</font>"
			mob << "<B> You must clear out any traces of the infestation and its survivors..</b>"
			mob << "<B> Follow any orders directly from Weyland-Yutani!</b>"
		else
			spawn_standard(mob)
			mob << "<font size='3'>\red You are a Death Squad Commando!!</font>"
			mob << "<B> You must clear out any traces of the infestation and its survivors..</b>"
			mob << "<B> Follow any orders directly from Weyland-Yutani!</b>"

	spawn(10)
		M << "<B>Objectives:</b> [objectives]"

	if(original)
		cdel(original)
	return


/datum/emergency_call/death/proc/spawn_standard(var/mob/M)
	if(!M || !istype(M)) return
	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/commando(M), WEAR_EAR)
	M.equip_to_slot_or_del(new /obj/item/clothing/glasses/m42_goggles	(M), WEAR_EYES)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC/commando(M), WEAR_BODY)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC/commando(M), WEAR_JACKET)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC/commando(M), WEAR_HANDS)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/commando(M), WEAR_HEAD)
	M.equip_to_slot_or_del(new /obj/item/storage/backpack/commando(M), WEAR_BACK)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC/commando(M), WEAR_FEET)
	M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC(M), WEAR_FACE)
	M.equip_to_slot_or_del(new /obj/item/tank/emergency_oxygen/engi(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary(M), WEAR_L_STORE)
	M.equip_to_slot_or_del(new /obj/item/explosive/plastique(M), WEAR_R_STORE)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/mateba(M), WEAR_WAIST)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/mateba(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a/elite(M), WEAR_J_STORE)

	var/obj/item/card/id/W = new(src)
	W.assignment = "Deathsquad"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_antagonist_pmc_access()
	M.equip_to_slot_or_del(W, WEAR_ID)

/datum/emergency_call/death/proc/spawn_officer(var/mob/M)
	if(!M || !istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/commando(M), WEAR_EAR)
	M.equip_to_slot_or_del(new /obj/item/clothing/glasses/m42_goggles	(M), WEAR_EYES)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC/commando(M), WEAR_BODY)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC/commando(M), WEAR_JACKET)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC/commando(M), WEAR_HANDS)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/commando(M), WEAR_HEAD)
	M.equip_to_slot_or_del(new /obj/item/storage/backpack/commando(M), WEAR_BACK)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC/commando(M), WEAR_FEET)
	M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/leader(M), WEAR_FACE)
	M.equip_to_slot_or_del(new /obj/item/tank/emergency_oxygen/engi(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary(M), WEAR_L_STORE)
	M.equip_to_slot_or_del(new /obj/item/explosive/plastique(M), WEAR_R_STORE)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/mateba(M), WEAR_WAIST)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/mateba(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a/elite(M), WEAR_J_STORE)

	var/obj/item/card/id/W = new(src)
	W.assignment = "Deathsquad Leader"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_antagonist_pmc_access()
	M.equip_to_slot_or_del(W, WEAR_ID)
