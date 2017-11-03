

/client/proc/cmd_admin_select_mob_rank(var/mob/living/carbon/human/H in mob_list)
	set category = "Fun"
	set name = "Select Rank"
	if(!istype(H))
		alert("Invalid mob")
		return

	var/rank_list = list("Custom") + RoleAuthority.roles_by_name

	var/newrank = input("Select new rank for [H]", "Change the mob's rank and skills") as null|anything in rank_list
	if (!newrank)
		return
	if(!H || !H.mind)
		return
	var/obj/item/card/id/I = H.wear_id
	feedback_add_details("admin_verb","SMRK") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	if(newrank != "Custom")
		var/datum/job/J = RoleAuthority.roles_by_name[newrank]
		H.mind.role_comm_title = J.comm_title
		H.mind.skills_list = J.skills_list
		if(istype(I))
			I.access = J.get_access()
			I.rank = J.title
			I.assignment = J.disp_title
			I.name = "[I.registered_name]'s ID Card ([I.assignment])"
			I.paygrade = J.paygrade
	else
		var/newcommtitle = input("Write the custom title appearing on comms chat (e.g. Spc)", "Comms title") as null|text
		if(!newcommtitle)
			return
		if(!H || !H.mind)
			return

		H.mind.role_comm_title = newcommtitle

		if(!istype(I) || I != H.wear_id)
			usr << "The mob has no id card, unable to modify ID and chat title."
		else
			var/newchattitle = input("Write the custom title appearing in chat (e.g. SGT)", "Chat title") as null|text
			if(!newchattitle)
				return
			if(!H || I != H.wear_id)
				return

			I.paygrade = newchattitle

			var/IDtitle = input("Write the custom title on your ID (e.g. Squad Specialist)", "ID title") as null|text
			if(!IDtitle)
				return
			if(!H || I != H.wear_id)
				return

			I.rank = IDtitle
			I.assignment = IDtitle
			I.name = "[I.registered_name]'s ID Card ([I.assignment])"

		if(!H.mind)
			usr << "The mob has no mind, unable to modify skills."
		else
			var/newskillset = input("Select a skillset", "Skill Set") as null|anything in RoleAuthority.roles_by_name
			if(!newskillset)
				return

			if(!H || !H.mind)
				return

			var/datum/job/J = RoleAuthority.roles_by_name[newskillset]
			H.mind.skills_list = J.skills_list




/client/proc/cmd_admin_dress(var/mob/living/carbon/human/M in mob_list)
	set category = "Fun"
	set name = "Select Equipment"
	if(!ishuman(M))
		alert("Invalid mob")
		return
	//log_admin("[key_name(src)] has alienized [M.key].")
	var/list/dresspacks = list(
		"strip",
		"USCM Cryo",
		"USCM Private",
		"USCM Specialist (Smartgunner)",
		"USCM Specialist (Armor)",
		"USCM Second-Lieutenant (SO)",
		"USCM First-Lieutenant (XO)",
		"USCM Captain (CO)",
		"USCM Officer (USCM Command)",
		"USCM Admiral (USCM Command)",
		"USCM Combat Synth (Smartgunner)",
		"Weyland-Yutani PMC (Standard)",
		"Weyland-Yutani PMC (Leader)",
		"Weyland-Yutani PMC (Gunner)",
		"Weyland-Yutani PMC (Sniper)",
		"UPP Soldier (Standard)",
		"UPP Soldier (Medic)",
		"UPP Soldier (Heavy)",
		"UPP Soldier (Leader)",
		"UPP Commando (Standard)",
		"UPP Commando (Medic)",
		"UPP Commando (Leader)",
		"CLF Fighter (Standard)",
		"CLF Fighter (Medic)",
		"CLF Fighter (Leader)",
		"Freelancer (Standard)",
		"Freelancer (Medic)",
		"Freelancer (Leader)",
		"Weyland-Yutani Deathsquad",
		"Business Person",
		"UPP Spy",
		"Mk50 Compression Suit",
		"Fleet Admiral",
		"Yautja Warrior",
		"Yautja Elder"
		)

	var/dresscode = input("Select dress for [M]", "Robust quick dress shop") as null|anything in dresspacks
	if (isnull(dresscode))
		return
	feedback_add_details("admin_verb","SEQ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	for (var/obj/item/I in M)
		if (istype(I, /obj/item/implant))
			continue
		cdel(I)
	M.arm_equipment(M, dresscode)
	M.regenerate_icons()
	log_admin("[key_name(usr)] changed the equipment of [key_name(M)] to [dresscode].")
	message_admins("\blue [key_name_admin(usr)] changed the equipment of [key_name_admin(M)] to [dresscode].", 1)
	return


//note: when adding new dresscodes, on top of adding a proper skills_list, make sure the ID given has
//a rank that matches a job title unless you want the human to bypass the skill system.
/mob/proc/arm_equipment(var/mob/living/carbon/human/M, var/dresscode)
	switch(dresscode)
		if ("strip")
			//do nothing
		if("USCM Cryo")
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/marine(M), WEAR_BACK)

			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "Squad Marine"
			W.rank = "Squad Marine"
			W.registered_name = M.real_name
			W.paygrade = "E2"
			M.equip_to_slot_or_del(W, WEAR_ID)
			if(M.mind)
				M.mind.role_comm_title = "Mar"
				M.mind.assigned_role = "Squad Marine"
				M.mind.skills_list = list("cqc"=SKILL_CQC_DEFAULT,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_DEFAULT,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_DEFAULT,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if("USCM Private")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/storage/belt/marine(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/marine(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/combat_knife(M), WEAR_L_HAND)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine(M), WEAR_HANDS)

			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "Squad Marine"
			W.rank = "Squad Marine"
			W.registered_name = M.real_name
			W.paygrade = "E2"
			M.equip_to_slot_or_del(W, WEAR_ID)
			if(M.mind)
				M.mind.role_comm_title = "Mar"
				M.mind.assigned_role = "Squad Marine"
				M.mind.skills_list = list("cqc"=SKILL_CQC_DEFAULT,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_DEFAULT,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_DEFAULT,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if("USCM Specialist (Smartgunner)")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/smartgunner(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/specrag(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/storage/belt/marine(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/smartgun_powerpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/smartgun(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/combat_knife(M), WEAR_L_HAND)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m56_goggles(M), WEAR_EYES)

			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "Squad Smartgunner"
			W.rank = "Squad Smartgunner"
			W.registered_name = M.real_name
			W.paygrade = "E3"
			M.equip_to_slot_or_del(W, WEAR_ID)
			if(M.mind)
				M.mind.role_comm_title = "LCpl"
				M.mind.assigned_role = "Squad Smartgunner"
				M.mind.skills_list = list("cqc"=SKILL_CQC_DEFAULT,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_DEFAULT,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_BEGINNER,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_DEFAULT,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if("USCM Combat Synth (Smartgunner)")
			var/obj/item/clothing/under/marine/J = new(M)
			J.icon_state = ""
			J.item_color = ""
			M.equip_to_slot_or_del(J, WEAR_BODY)
			var/obj/item/clothing/head/helmet/specrag/L = new(M)
			L.icon_state = ""
			L.name = "synth faceplate"
			L.canremove = 0
			L.anti_hug = 99

			M.equip_to_slot_or_del(L, WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/smartgunner(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/storage/belt/marine(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/smartgun_powerpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/smartgun(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/combat_knife(M), WEAR_L_HAND)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m56_goggles(M), WEAR_EYES)

			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card (Combat Synth)"
			W.access = list()
			W.assignment = "Squad Smartgunner"
			W.rank = "Squad Smartgunner"
			W.registered_name = M.real_name
			W.paygrade = "E3"
			M.equip_to_slot_or_del(W, WEAR_ID)
			M.set_species("Machine")
			if(M.mind)
				M.mind.role_comm_title = "LCpl"
				M.mind.assigned_role = "Squad Smartgunner"
				M.mind.skills_list = list("cqc"=SKILL_CQC_DEFAULT,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_DEFAULT,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_DEFAULT,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if("USCM Specialist (Armor)")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/specialist(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/specialist(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/storage/belt/marine(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/marine(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(M), WEAR_FACE)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/combat_knife(M), WEAR_L_HAND)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/specialist(M), WEAR_HANDS)

			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "Squad Specialist"
			W.rank = "Squad Specialist"
			W.registered_name = M.real_name
			W.paygrade = "E5"
			M.equip_to_slot_or_del(W, WEAR_ID)
			if(M.mind)
				M.mind.role_comm_title = "Spc"
				M.mind.assigned_role = "Squad Specialist"
				M.mind.skills_list = list("cqc"=SKILL_CQC_TRAINED,"endurance"=0,"engineer"=SKILL_ENGINEER_METAL,"firearms"=SKILL_FIREARMS_DEFAULT,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_TRAINED,"leadership"=SKILL_LEAD_BEGINNER,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_DEFAULT,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)


		if("USCM Second-Lieutenant (SO)")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/bridge(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap/ro(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m4a3/full(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/marine(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)

			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "Second Lieutenant"
			W.rank = "Staff Officer"
			W.registered_name = M.real_name
			W.paygrade = "O2"
			M.equip_to_slot_or_del(W, WEAR_ID)
			if(M.mind)
				M.mind.role_comm_title = "SO"
				M.mind.assigned_role = "Staff Officer"
				M.mind.skills_list = list("cqc"=SKILL_CQC_DEFAULT,"endurance"=0,"engineer"=SKILL_ENGINEER_PLASTEEL,"firearms"=SKILL_FIREARMS_DEFAULT,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_EXPERT,"medical"=SKILL_MEDICAL_MEDIC,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_DEFAULT,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if("USCM First-Lieutenant (XO)")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/exec(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m44/full(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/marine(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)

			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "USCM Executive Officer"
			W.rank = "Executive Officer"
			W.registered_name = M.real_name
			W.paygrade = "O3"
			M.equip_to_slot_or_del(W, WEAR_ID)
			if(M.mind)
				M.mind.role_comm_title = "XO"
				M.mind.assigned_role = "Executive Officer"
				M.mind.skills_list = list("cqc"=SKILL_CQC_DEFAULT,"endurance"=0,"engineer"=SKILL_ENGINEER_PLASTEEL,"firearms"=SKILL_FIREARMS_DEFAULT,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_MASTER,"medical"=SKILL_MEDICAL_MEDIC,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_DEFAULT,"police"=SKILL_POLICE_FLASH,"powerloader"=SKILL_POWERLOADER_TRAINED)

		if("USCM Captain (CO)")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/command(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/cmberet/tan(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/storage/belt/gun/mateba/cmateba/full(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/marine(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)

			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "USCM Commanding Officer"
			W.rank = "Commander"
			W.registered_name = M.real_name
			W.paygrade = "O4"
			M.equip_to_slot_or_del(W, WEAR_ID)
			if(M.mind)
				M.mind.role_comm_title = "CO"
				M.mind.assigned_role = "Commander"
				M.mind.skills_list = list("cqc"=SKILL_CQC_DEFAULT,"endurance"=0,"engineer"=SKILL_ENGINEER_PLASTEEL,"firearms"=SKILL_FIREARMS_DEFAULT,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_MASTER,"medical"=SKILL_MEDICAL_MEDIC,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_DEFAULT,"police"=SKILL_POLICE_FLASH,"powerloader"=SKILL_POWERLOADER_TRAINED)

		if("Weyland-Yutani PMC (Standard)")
			var/choice = rand(1,4)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC(M), WEAR_FACE)

			M.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/PMC(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/device/flashlight(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/baton(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m4a3/vp70(M), WEAR_WAIST)

			switch(choice)
				if(1,2,3)
					M.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/m39/elite(M), WEAR_R_HAND)
					M.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large/pmc_m39(M), WEAR_L_STORE)
					M.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large/pmc_m39(M), WEAR_R_STORE)
					M.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39/ap(M.back), WEAR_IN_BACK)
					M.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39/ap(M.back), WEAR_IN_BACK)
				if(4)
					M.equip_to_slot_or_del(new /obj/item/weapon/gun/flamer(M), WEAR_R_HAND)
					M.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/pistol/pmc_vp70(M), WEAR_L_STORE)
					M.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/pistol/pmc_vp70(M), WEAR_R_STORE)
					M.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank(M.back), WEAR_IN_BACK)
					M.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank(M.back), WEAR_IN_BACK)
					M.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank(M.back), WEAR_IN_BACK)
					M.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank(M.back), WEAR_IN_BACK)

			var/obj/item/card/id/W = new(src)
			W.assignment = "PMC Standard"
			W.rank = "PMC Standard"
			W.registered_name = M.real_name
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.paygrade = "PMC1"
			M.equip_to_slot_or_del(W, WEAR_ID)

			if(M.mind)
				M.mind.assigned_role = "PMC"
				M.mind.special_role = "MODE"
				M.mind.skills_list = list("cqc"=SKILL_CQC_DEFAULT,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_DEFAULT,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_DEFAULT,"police"=SKILL_POLICE_MP,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if("Weyland-Yutani PMC (Leader)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC/leader(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC/leader(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/leader(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/leader(M), WEAR_FACE)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/baton(M.back), WEAR_IN_BACK)

			M.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m4a3/vp70(M), WEAR_WAIST)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a/elite(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large/pmc_rifle(M), WEAR_L_STORE)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large/pmc_rifle(M), WEAR_R_STORE)


			var/obj/item/card/id/W = new(src)
			W.assignment = "PMC Officer"
			W.rank = "PMC Leader"
			W.registered_name = M.real_name
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.paygrade = "PMC4"
			M.equip_to_slot_or_del(W, WEAR_ID)

			if(M.mind)
				M.mind.role_comm_title = "SL"
				M.mind.assigned_role = "PMC Leader"
				M.mind.special_role = "MODE"
				M.mind.skills_list = list("cqc"=SKILL_CQC_TRAINED,"endurance"=0,"engineer"=SKILL_ENGINEER_PLASTEEL,"firearms"=SKILL_FIREARMS_TRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_TRAINED,"medical"=SKILL_MEDICAL_CHEM,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_MP,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if("Weyland-Yutani PMC (Gunner)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m56_goggles(M), WEAR_EYES)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/smartgunner/veteran/PMC(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/gunner(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/leader(M), WEAR_FACE)
			M.equip_to_slot_or_del(new /obj/item/smartgun_powerpack/snow(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/smartgun(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/general/medium(M), WEAR_R_STORE)

			M.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m4a3/vp70(M), WEAR_WAIST)

			var/obj/item/card/id/W = new(src)
			W.assignment = "PMC Specialist"
			W.rank = "PMC Gunner"
			W.registered_name = M.real_name
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.paygrade = "PMC3"
			M.equip_to_slot_or_del(W, WEAR_ID)

			if(M.mind)
				M.mind.role_comm_title = "Spc"
				M.mind.assigned_role = "PMC"
				M.mind.special_role = "MODE"
				M.mind.skills_list = list("cqc"=SKILL_CQC_TRAINED,"endurance"=0,"engineer"=SKILL_ENGINEER_METAL,"firearms"=SKILL_FIREARMS_TRAINED,"smartgun"=SKILL_SMART_TRAINED,"heavy_weapons"=SKILL_HEAVY_TRAINED,"leadership"=SKILL_LEAD_BEGINNER,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if("Weyland-Yutani PMC (Sniper)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC/sniper(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/sniper(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/m42_goggles(M), WEAR_EYES)

			M.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel(M), WEAR_BACK)

			M.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m4a3/vp70(M), WEAR_WAIST)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/sniper/elite(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large/pmc_sniper(M), WEAR_L_STORE)


			var/obj/item/card/id/W = new(src)
			W.assignment = "PMC Sniper"
			W.rank = "PMC Sharpshooter"
			W.registered_name = M.real_name
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.paygrade = "PMC3"
			M.equip_to_slot_or_del(W, WEAR_ID)

			if(M.mind)
				M.mind.role_comm_title = "Spc"
				M.mind.assigned_role = "PMC"
				M.mind.special_role = "MODE"
				M.mind.skills_list = list("cqc"=SKILL_CQC_TRAINED,"endurance"=0,"engineer"=SKILL_ENGINEER_METAL,"firearms"=SKILL_FIREARMS_TRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_TRAINED,"leadership"=SKILL_LEAD_BEGINNER,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if("Weyland-Yutani Deathsquad")
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
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large/pmc_rifle(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/pistol/pmc_mateba(M), WEAR_L_STORE)

			M.equip_to_slot_or_del(new /obj/item/storage/belt/gun/mateba/full(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/explosive/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a/elite(M), WEAR_J_STORE)

			var/obj/item/card/id/W = new(M)
			W.assignment = "Commando"
			W.rank = "PMC Commando"
			W.registered_name = M.real_name
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.icon_state = "centcom"
			W.access = get_antagonist_pmc_access()
			M.equip_to_slot_or_del(W, WEAR_ID)

			if(M.mind)
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "DEATH SQUAD"
				M.mind.skills_list = list("cqc"=3,"endurance"=0,"engineer"=SKILL_ENGINEER_ENGI,"firearms"=SKILL_FIREARMS_TRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_BEGINNER,"medical"=SKILL_MEDICAL_CHEM,"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)


		if("USCM Officer (USCM Command)")
			M.equip_if_possible(new /obj/item/clothing/under/rank/centcom/officer(M), WEAR_BODY)
			M.equip_if_possible(new /obj/item/clothing/shoes/centcom(M), WEAR_FEET)
			M.equip_if_possible(new /obj/item/clothing/gloves/white(M), WEAR_HANDS)
			M.equip_if_possible(new /obj/item/clothing/head/beret/centcom/officer(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(M), WEAR_EAR)


			var/obj/item/device/pda/heads/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "USCM Officer"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"

			M.equip_if_possible(pda, WEAR_R_STORE)
			M.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(M), WEAR_EYES)
			M.equip_if_possible(new /obj/item/storage/pouch/general/large(M), WEAR_R_STORE)

			var/obj/item/card/id/centcom/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "USCM Officer"
			W.registered_name = M.real_name
			W.paygrade = "O5"
			M.equip_if_possible(W, WEAR_ID)
			if(M.mind)
				M.mind.role_comm_title = "Cpt"
				M.mind.skills_list = list("cqc"=SKILL_CQC_DEFAULT,"endurance"=0,"engineer"=SKILL_ENGINEER_PLASTEEL,"firearms"=SKILL_FIREARMS_DEFAULT,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_MASTER,"medical"=SKILL_MEDICAL_MEDIC,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_DEFAULT,"police"=SKILL_POLICE_FLASH,"powerloader"=SKILL_POWERLOADER_TRAINED)

		if("USCM Admiral (USCM Command)")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/admiral(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/centcom(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/storage/belt/gun/mateba/admiral(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/admiral(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest/admiral(M), WEAR_JACKET)

			M.equip_to_slot_or_del(new /obj/item/clothing/mask/breath(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/tank/emergency_oxygen/engi(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/box/handcuffs(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/pistol/pmc_mateba(M), WEAR_L_STORE)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/mateba(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/MP/admiral(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/handcuffs(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/handcuffs(M.back), WEAR_IN_BACK)




			var/obj/item/device/pda/heads/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "USCM Admiral"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"

			M.equip_if_possible(pda, WEAR_R_STORE)
			M.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(M), WEAR_EYES)

			var/obj/item/card/id/centcom/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "USCM Admiral"
			W.registered_name = M.real_name
			W.paygrade = "O7"
			M.equip_if_possible(W, WEAR_ID)
			if(M.mind)
				M.mind.role_comm_title = "ADM"
				M.mind.skills_list = list("cqc"=SKILL_CQC_DEFAULT,"endurance"=0,"engineer"=SKILL_ENGINEER_PLASTEEL,"firearms"=SKILL_FIREARMS_DEFAULT,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_MASTER,"medical"=SKILL_MEDICAL_MEDIC,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_DEFAULT,"police"=SKILL_POLICE_FLASH,"powerloader"=SKILL_POWERLOADER_TRAINED)


		if("UPP Soldier (Standard)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/UPP(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/UPP(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/storage/belt/marine/upp(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)

			M.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/upp(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/bayonet/upp(M), WEAR_L_STORE)

			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "UPP Soldier"
			W.registered_name = M.real_name
			W.access = get_antagonist_access()
			W.paygrade = "E1"
			M.equip_to_slot_or_del(W, WEAR_ID)
			M.add_language("Russian")

			if(M.mind)
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "UPP"
				M.mind.skills_list = list("cqc"=SKILL_CQC_DEFAULT,"endurance"=0,"engineer"=SKILL_ENGINEER_METAL,"firearms"=SKILL_FIREARMS_DEFAULT,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_DEFAULT,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)


		if("UPP Soldier (Medic)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP/medic(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/UPP(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/storage/belt/combatLifesaver/upp(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/skorpion/upp(M), WEAR_R_HAND)

			M.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/device/healthanalyzer(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/device/defibrillator(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/firstaid/fire(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/tramadol(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/upp_smg, WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/bayonet/upp(M), WEAR_L_STORE)

			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(M), WEAR_EYES)

			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "UPP Medic"
			W.registered_name = M.real_name
			W.paygrade = "E4"
			W.access = get_antagonist_access()
			M.equip_to_slot_or_del(W, WEAR_ID)
			M.add_language("Russian")


			if(M.mind)
				M.mind.role_comm_title = "Cpl"
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "UPP"
				M.mind.skills_list = list("cqc"=SKILL_CQC_DEFAULT,"endurance"=0,"engineer"=SKILL_ENGINEER_METAL,"firearms"=SKILL_FIREARMS_DEFAULT,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_BEGINNER,"medical"=SKILL_MEDICAL_MEDIC,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_DEFAULT,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)


		if("UPP Soldier (Heavy)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/UPP/heavy(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/UPP/heavy(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/storage/belt/marine/upp(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)

			M.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/flamer(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/c99/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large/upp(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/bayonet/upp(M), WEAR_L_STORE)


			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "UPP Specialist"
			W.registered_name = M.real_name
			W.paygrade = "E5"
			W.access = get_antagonist_access()
			M.equip_to_slot_or_del(W, WEAR_ID)
			M.add_language("Russian")


			if(M.mind)
				M.mind.role_comm_title = "Spc"
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "UPP"
				M.mind.skills_list = list("cqc"=SKILL_CQC_TRAINED,"endurance"=0,"engineer"=SKILL_ENGINEER_METAL,"firearms"=SKILL_FIREARMS_TRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_TRAINED,"leadership"=SKILL_LEAD_BEGINNER,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)


		if("UPP Soldier (Leader)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/UPP/heavy(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap/beret(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)

			M.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/flamer(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/storage/belt/gun/korovin/standard(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large/upp(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/bayonet/upp(M), WEAR_L_STORE)

			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "UPP Leader"
			W.registered_name = M.real_name
			W.paygrade = "E6"
			W.access = get_antagonist_access()
			M.equip_to_slot_or_del(W, WEAR_ID)
			M.add_language("Russian")

			if(M.mind)
				M.mind.role_comm_title = "SL"
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "UPP"
				M.mind.skills_list = list("cqc"=SKILL_CQC_TRAINED,"endurance"=0,"engineer"=SKILL_ENGINEER_PLASTEEL,"firearms"=SKILL_FIREARMS_TRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_TRAINED,"medical"=SKILL_MEDICAL_MEDIC,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)



		if("UPP Commando (Standard)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/UPP/commando(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/storage/belt/gun/korovin/tranq(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/upp(M), WEAR_FACE)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m42_night_goggles/upp(M), WEAR_EYES)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/carbine/commando(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/storage/belt/gun/korovin/tranq(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)

			M.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/device/chameleon	(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large/upp(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/bayonet/upp(M), WEAR_L_STORE)

			M.equip_to_slot_or_del(new /obj/item/handcuffs(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/handcuffs(M.back), WEAR_IN_BACK)


			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "UPP Commando"
			W.registered_name = M.real_name
			W.paygrade = "E2"
			W.access = get_antagonist_access()
			M.equip_to_slot_or_del(W, WEAR_ID)
			M.add_language("Russian")

			if(M.mind)
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "UPP"
				M.mind.skills_list = list("cqc"=3,"endurance"=0,"engineer"=SKILL_ENGINEER_ENGI,"firearms"=SKILL_FIREARMS_TRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_BEGINNER,"medical"=SKILL_MEDICAL_CHEM,"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)


		if("UPP Commando (Medic)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP/medic(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/UPP/commando(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/upp(M), WEAR_FACE)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m42_night_goggles/upp(M), WEAR_EYES)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/carbine/commando(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/storage/belt/gun/korovin/tranq(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/device/healthanalyzer(M.back), WEAR_IN_BACK)

			M.equip_to_slot_or_del(new /obj/item/device/defibrillator(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/firstaid/fire(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/tramadol(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large/upp(M), WEAR_R_STORE)

			M.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/device/chameleon	(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/explosive/upp(M), WEAR_L_STORE)

			M.equip_to_slot_or_del(new /obj/item/handcuffs(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/handcuffs(M.back), WEAR_IN_BACK)


			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "UPP Commando Medic"
			W.registered_name = M.real_name
			W.paygrade = "E4"
			W.access = get_antagonist_access()
			M.equip_to_slot_or_del(W, WEAR_ID)
			M.add_language("Russian")

			if(M.mind)
				M.mind.role_comm_title = "Cpl"
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "UPP"
				M.mind.skills_list = list("cqc"=3,"endurance"=0,"engineer"=SKILL_ENGINEER_ENGI,"firearms"=SKILL_FIREARMS_TRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_BEGINNER,"medical"=SKILL_MEDICAL_MEDIC,"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if("UPP Commando (Leader)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/bears(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/UPP/commando(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap/beret(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/upp(M), WEAR_FACE)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m42_night_goggles/upp(M), WEAR_EYES)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/carbine/commando(M), WEAR_R_HAND)
			M.equip_to_slot_or_del(new /obj/item/storage/belt/gun/korovin/tranq(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(M.back), WEAR_IN_BACK)

			M.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/device/chameleon	(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large/upp(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/explosive/upp(M), WEAR_L_STORE)

			M.equip_to_slot_or_del(new /obj/item/handcuffs(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/handcuffs(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/box/handcuffs(M.back), WEAR_IN_BACK)




			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "UPP Commando Leader"
			W.registered_name = M.real_name
			W.paygrade = "E6"
			W.access = get_antagonist_access()
			M.equip_to_slot_or_del(W, WEAR_ID)
			M.add_language("Russian")


			if(M.mind)
				M.mind.role_comm_title = "SL"
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "UPP"
				M.mind.skills_list = list("cqc"=3,"endurance"=0,"engineer"=SKILL_ENGINEER_ENGI,"firearms"=SKILL_FIREARMS_TRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_TRAINED,"medical"=SKILL_MEDICAL_CHEM,"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)


		if("CLF Fighter (Standard)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/militia(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/militia(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/device/flashlight(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/stick(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/general(M), WEAR_R_STORE)

			spawn_rebel_gun(M)
			spawn_rebel_gun(M,1)

			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "Colonist"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)
			W.access = get_all_accesses()

			if(M.mind)
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "CLF"
				M.mind.skills_list = list("cqc"=SKILL_CQC_DEFAULT,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_DEFAULT,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_DEFAULT,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if("CLF Fighter (Medic)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/militia(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/militia(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/stick(M.back), WEAR_IN_BACK)

			M.equip_to_slot_or_del(new /obj/item/device/defibrillator(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/firstaid/fire(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/tramadol(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/device/flashlight(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/device/healthanalyzer(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(M), WEAR_EYES)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/general(M), WEAR_L_STORE)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/medical(M), WEAR_R_STORE)


			spawn_rebel_gun(M)
			spawn_rebel_gun(M,1)

			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "Colonist Medic"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)
			W.access = get_all_accesses()

			if(M.mind)
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "CLF"
				M.mind.skills_list = list("cqc"=SKILL_CQC_DEFAULT,"endurance"=0,"engineer"=SKILL_ENGINEER_METAL,"firearms"=SKILL_FIREARMS_DEFAULT,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_BEGINNER,"medical"=SKILL_MEDICAL_MEDIC,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_DEFAULT,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if("CLF Fighter (Leader)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/militia(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/frelancer(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/stick(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/stick(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/device/flashlight(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/box/handcuffs(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/general/medium(M), WEAR_L_STORE)

			spawn_rebel_gun(M)
			spawn_rebel_gun(M,1)
			spawn_rebel_gun(M,1)

			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "Colonist Leader"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)
			W.access = get_all_accesses()

			if(M.mind)
				M.mind.role_comm_title = "Lead"
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "CLF"
				M.mind.skills_list = list("cqc"=SKILL_CQC_TRAINED,"endurance"=0,"engineer"=SKILL_ENGINEER_PLASTEEL,"firearms"=SKILL_FIREARMS_TRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_TRAINED,"medical"=SKILL_MEDICAL_CHEM,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if("Freelancer (Standard)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/freelancer(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/freelancer(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/frelancer(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/storage/belt/marine(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/stick(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/stick(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/general(M), WEAR_R_STORE)

			spawn_merc_gun(M)
			spawn_rebel_gun(M,1)


			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "Freelancer"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)
			W.access = get_all_accesses()

			if(M.mind)
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "FREELANCERS"
				M.mind.skills_list = list("cqc"=SKILL_CQC_DEFAULT,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_DEFAULT,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_DEFAULT,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if("Freelancer (Medic)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/freelancer(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/freelancer(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/frelancer(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/storage/belt/marine(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/stick(M.back), WEAR_IN_BACK)

			M.equip_to_slot_or_del(new /obj/item/device/defibrillator(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/firstaid/fire(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/tramadol(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/device/healthanalyzer(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/medical(M), WEAR_L_STORE)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/general(M), WEAR_R_STORE)

			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(M), WEAR_EYES)

			spawn_merc_gun(M)

			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "Freelancer Medic"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)
			W.access = get_all_accesses()

			if(M.mind)
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "FREELANCERS"
				M.mind.skills_list = list("cqc"=SKILL_CQC_DEFAULT,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_DEFAULT,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_BEGINNER,"medical"=SKILL_MEDICAL_MEDIC,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_DEFAULT,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)


		if("Freelancer (Leader)")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/freelancer(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/faction/freelancer(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/frelancer/beret(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/storage/belt/marine(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/stick(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/general/medium(M), WEAR_R_STORE)

			spawn_merc_gun(M)
			spawn_merc_gun(M,1)

			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list()
			W.assignment = "Freelancer Warlord"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, WEAR_ID)
			M.add_language("Russian")
			M.add_language("Sainja")
			W.access = get_all_accesses()

			if(M.mind)
				M.mind.role_comm_title = "Lead"
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "FREELANCERS"
				M.mind.skills_list = list("cqc"=SKILL_CQC_TRAINED,"endurance"=0,"engineer"=SKILL_ENGINEER_PLASTEEL,"firearms"=SKILL_FIREARMS_TRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_TRAINED,"medical"=SKILL_MEDICAL_CHEM,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if("Business Person")
			M.equip_if_possible(new /obj/item/clothing/under/lawyer/bluesuit(M), WEAR_BODY)
			M.equip_if_possible(new /obj/item/clothing/shoes/centcom(M), WEAR_FEET)
			M.equip_if_possible(new /obj/item/clothing/gloves/white(M), WEAR_HANDS)

			M.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(M), WEAR_EYES)
			M.equip_if_possible(new /obj/item/clipboard(M), WEAR_WAIST)

			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.item_state = "id_inv"
			W.access = get_all_accesses()
			W.access = get_all_centcom_access()
			W.assignment = "Corporate Representative"
			W.registered_name = M.real_name
			M.equip_if_possible(W, WEAR_ID)
			if(M.mind)
				M.mind.skills_list = list("cqc"=SKILL_CQC_WEAK,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_UNTRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_WEAK,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_UNTRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if("UPP Spy")
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/industrial(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/engi(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mt(M), WEAR_EAR)

			M.equip_to_slot_or_del(new /obj/item/handcuffs(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/c99/upp/tranq(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99t(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99t(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/device/chameleon	(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/upp(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/explosive/plastique(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/box/handcuffs(M.back), WEAR_IN_BACK)
			M.equip_to_slot_or_del(new /obj/item/storage/pouch/general/large(M), WEAR_R_STORE)

			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = list(ACCESS_MARINE_ENGINEERING)
			W.assignment = "Maintenance Tech"
			W.registered_name = M.real_name
			W.paygrade = "E6E"
			M.equip_if_possible(W, WEAR_ID)

			if(M.mind)
				M.mind.role_comm_title = "MT"
				M.mind.assigned_role = "MODE"
				M.mind.special_role = "UPP"
				M.mind.skills_list = list("cqc"=SKILL_CQC_TRAINED,"endurance"=0,"engineer"=SKILL_ENGINEER_PLASTEEL,"firearms"=SKILL_FIREARMS_TRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_BEGINNER,"medical"=SKILL_MEDICAL_CHEM,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=1)


		if("Mk50 Compression Suit")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots(M), WEAR_FEET)

			M.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(M), WEAR_BODY)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/compression(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/compression(M), WEAR_HEAD)
			var /obj/item/tank/jetpack/J = new /obj/item/tank/jetpack/oxygen(M)
			M.equip_to_slot_or_del(J, WEAR_BACK)
			J.toggle()
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/breath(M), WEAR_FACE)
			J.Topic(null, list("stat" = 1))
			spawn_merc_gun(M)
			if(M.mind)
				M.mind.skills_list = list("cqc"=SKILL_CQC_DEFAULT,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_DEFAULT,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_DEFAULT,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if("Fleet Admiral") //Renamed from Soviet Admiral
			M.equip_to_slot_or_del(new /obj/item/clothing/head/hgpiratecap(M), WEAR_HEAD)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/eyepatch(M), WEAR_EYES)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/hgpirate(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel(M), WEAR_BACK)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/soviet(M), WEAR_BODY)
			var/obj/item/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.access = list()
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "Fleet Admiral"
			W.registered_name = M.real_name
			W.paygrade = "O8"
			M.equip_to_slot_or_del(W, WEAR_ID)
			if(M.mind)
				M.mind.role_comm_title = "FADM"
				M.mind.skills_list = list("cqc"=SKILL_CQC_DEFAULT,"endurance"=0,"engineer"=SKILL_ENGINEER_PLASTEEL,"firearms"=SKILL_FIREARMS_DEFAULT,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_MASTER,"medical"=SKILL_MEDICAL_MEDIC,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_DEFAULT,"police"=SKILL_POLICE_FLASH,"powerloader"=SKILL_POWERLOADER_TRAINED)


		if("Yautja Warrior")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/chainshirt(M), WEAR_BODY)
			var/obj/item/clothing/gloves/yautja/bracer = new(M)
			bracer.charge = 2500
			bracer.charge_max = 2500
			M.verbs += /obj/item/clothing/gloves/yautja/proc/translate
			bracer.upgrades = 1
			M.equip_to_slot_or_del((bracer), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/yautja(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/weapon/yautja_knife(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/device/yautja_teleporter(M),WEAR_L_STORE)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/yautja(M), WEAR_FACE)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/yautja(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/yautja(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/yautja(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/yautja(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/yautja_sword(M), WEAR_L_HAND)
			M.equip_to_slot_or_del(new /obj/item/explosive/grenade/spawnergrenade/smartdisc(M), WEAR_R_HAND)

		if("Yautja Elder")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/chainshirt(M), WEAR_BODY)
			var/obj/item/clothing/gloves/yautja/bracer = new(M)
			bracer.charge = 3000
			bracer.charge_max = 3000
			M.verbs += /obj/item/clothing/gloves/yautja/proc/translate
			bracer.upgrades = 2
			M.equip_to_slot_or_del((bracer), WEAR_HANDS)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/yautja(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/weapon/yautja_knife(M), WEAR_R_STORE)
			M.equip_to_slot_or_del(new /obj/item/device/yautja_teleporter(M),WEAR_L_STORE)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/yautja(M), WEAR_FACE)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/yautja(M), WEAR_FEET)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/yautja(M), WEAR_EAR)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/yautja/full(M), WEAR_JACKET)
			M.equip_to_slot_or_del(new /obj/item/storage/backpack/yautja(M), WEAR_WAIST)
			M.equip_to_slot_or_del(new /obj/item/weapon/twohanded/glaive(M), WEAR_L_HAND)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasmarifle(M), WEAR_R_HAND)







/proc/spawn_merc_gun(var/atom/M,var/sidearm = 0)
	if(!M) return

	var/atom/spawnloc = M

	var/list/merc_sidearms = list(
		/obj/item/weapon/gun/revolver/small = /obj/item/ammo_magazine/revolver/small,
		/obj/item/weapon/gun/pistol/heavy = /obj/item/ammo_magazine/pistol/heavy,
		/obj/item/weapon/gun/pistol/m1911 = /obj/item/ammo_magazine/pistol/m1911,
		/obj/item/weapon/gun/pistol/kt42 = /obj/item/ammo_magazine/pistol/automatic,
		/obj/item/weapon/gun/pistol/holdout = /obj/item/ammo_magazine/pistol/holdout,
		/obj/item/weapon/gun/pistol/highpower = /obj/item/ammo_magazine/pistol/highpower,
		/obj/item/weapon/gun/smg/mp7 = /obj/item/ammo_magazine/smg/mp7,
		/obj/item/weapon/gun/smg/skorpion = /obj/item/ammo_magazine/smg/skorpion,
		/obj/item/weapon/gun/smg/uzi = /obj/item/ammo_magazine/smg/uzi,
		/obj/item/weapon/gun/smg/uzi = /obj/item/ammo_magazine/smg/uzi/extended)

	var/list/merc_firearms = list(
		/obj/item/weapon/gun/shotgun/merc = /obj/item/ammo_magazine/shotgun,
		/obj/item/weapon/gun/shotgun/combat = /obj/item/ammo_magazine/shotgun,
		/obj/item/weapon/gun/shotgun/double = /obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/weapon/gun/shotgun/pump/cmb = /obj/item/ammo_magazine/shotgun/incendiary,
		/obj/item/weapon/gun/rifle/mar40 = /obj/item/ammo_magazine/rifle/mar40,
		/obj/item/weapon/gun/rifle/mar40/carbine = /obj/item/ammo_magazine/rifle/mar40,
		/obj/item/weapon/gun/rifle/m41aMK1 = /obj/item/ammo_magazine/rifle/m41aMK1,
		/obj/item/weapon/gun/smg/p90 = /obj/item/ammo_magazine/smg/p90,
		/obj/item/weapon/gun/smg/uzi = /obj/item/ammo_magazine/smg/uzi/extended)

	var/gunpath = sidearm? pick(merc_sidearms) : pick(merc_firearms)
	var/ammopath = sidearm? merc_sidearms[gunpath] : merc_firearms[gunpath]
	var/obj/item/weapon/gun/gun

	if(gunpath)
		gun = new gunpath(spawnloc)
		if(ishuman(spawnloc))
			var/mob/living/carbon/human/H = spawnloc
			H.equip_to_slot_or_del(gun, sidearm? WEAR_L_HAND : WEAR_R_HAND)
			if(ammopath && H.back && istype(H.back,/obj/item/storage))
				new ammopath(H.back)
				new ammopath(H.back)
				new ammopath(H.back)
				new ammopath(H.back)
		else
			if(ammopath)
				spawnloc = get_turf(spawnloc)
				new ammopath(spawnloc)
				new ammopath(spawnloc)
				new ammopath(spawnloc)

	return 1

/proc/spawn_rebel_gun(var/atom/M,var/sidearm = 0)
	if(!M) return
	var/atom/spawnloc = M

	var/list/rebel_firearms = list(
		/obj/item/weapon/gun/shotgun/merc = /obj/item/ammo_magazine/shotgun,
		/obj/item/weapon/gun/shotgun/double = /obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/weapon/gun/shotgun/double = /obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/weapon/gun/shotgun/double = /obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/weapon/gun/shotgun/double = /obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/weapon/gun/shotgun/double = /obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/weapon/gun/shotgun/pump/cmb = /obj/item/ammo_magazine/shotgun/incendiary,
		/obj/item/weapon/gun/shotgun/pump/cmb = /obj/item/ammo_magazine/shotgun/incendiary,
		/obj/item/weapon/gun/rifle/mar40 = /obj/item/ammo_magazine/rifle/mar40,
		/obj/item/weapon/gun/rifle/mar40/carbine = /obj/item/ammo_magazine/rifle/mar40,
		/obj/item/weapon/gun/rifle/mar40/carbine = /obj/item/ammo_magazine/rifle/mar40,
		/obj/item/weapon/gun/rifle/mar40/carbine = /obj/item/ammo_magazine/rifle/mar40,
		/obj/item/weapon/gun/smg/uzi = /obj/item/ammo_magazine/smg/uzi/extended,
		/obj/item/weapon/gun/smg/uzi = /obj/item/ammo_magazine/smg/uzi/extended,
		/obj/item/weapon/gun/revolver/small = /obj/item/ammo_magazine/revolver/small,
		/obj/item/weapon/gun/revolver/small = /obj/item/ammo_magazine/revolver/small,
		/obj/item/weapon/gun/revolver/small = /obj/item/ammo_magazine/revolver/small,
		/obj/item/weapon/gun/pistol/heavy = /obj/item/ammo_magazine/pistol/heavy,
		/obj/item/weapon/gun/pistol/kt42 = /obj/item/ammo_magazine/pistol/automatic,
		/obj/item/weapon/gun/pistol/holdout = /obj/item/ammo_magazine/pistol/holdout,
		/obj/item/weapon/gun/pistol/highpower = /obj/item/ammo_magazine/pistol/highpower,
		/obj/item/weapon/gun/smg/mp7 = /obj/item/ammo_magazine/smg/mp7,
		/obj/item/weapon/gun/smg/skorpion = /obj/item/ammo_magazine/smg/skorpion,
		/obj/item/weapon/gun/smg/skorpion/upp = /obj/item/ammo_magazine/smg/skorpion,
		/obj/item/weapon/gun/shotgun/double/sawn = /obj/item/ammo_magazine/shotgun/incendiary,
		/obj/item/weapon/gun/shotgun/double/sawn = /obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/weapon/gun/revolver/cmb = /obj/item/ammo_magazine/revolver/cmb,
		/obj/item/weapon/gun/revolver/cmb = /obj/item/ammo_magazine/revolver/cmb,
		/obj/item/weapon/gun/pistol/c99 = /obj/item/ammo_magazine/pistol/c99,
		/obj/item/weapon/gun/pistol/vp70 = /obj/item/ammo_magazine/pistol/vp70
		)


	var/list/rebel_sidearms = list(
		/obj/item/storage/large_holster/katana/full = null,
		/obj/item/storage/large_holster/katana/full = null,
		/obj/item/storage/large_holster/katana/full = null,
		/obj/item/storage/large_holster/machete/full = null,
		/obj/item/weapon/combat_knife = null,
		/obj/item/explosive/grenade/frag/stick = null,
		/obj/item/explosive/grenade/frag/stick = null,
		/obj/item/explosive/grenade/frag/stick = null,
		/obj/item/weapon/combat_knife/upp = null,
		/obj/item/weapon/gun/pistol/holdout = /obj/item/ammo_magazine/pistol/holdout,
		/obj/item/weapon/gun/pistol/holdout = /obj/item/ammo_magazine/pistol/holdout,
		/obj/item/weapon/gun/revolver/cmb = /obj/item/ammo_magazine/revolver/cmb,
		/obj/item/weapon/gun/revolver/small = /obj/item/ammo_magazine/revolver/small,
		/obj/item/reagent_container/spray/pepper = null,
		/obj/item/reagent_container/spray/pepper = null,
		/obj/item/clothing/tie/storage/webbing = null,
		/obj/item/clothing/tie/storage/webbing = null,
		/obj/item/storage/belt/marine = null,
		/obj/item/storage/pill_bottle/tramadol = null,
		/obj/item/explosive/grenade/phosphorus = null,
		/obj/item/clothing/glasses/welding = null,
		/obj/item/reagent_container/ld50_syringe/choral = null,
		/obj/item/storage/firstaid/regular = null,
		/obj/item/reagent_container/pill/cyanide = null,
		/obj/item/device/megaphone = null,
		/obj/item/storage/belt/utility/full = null,
		/obj/item/storage/belt/utility/full = null,
		/obj/item/storage/bible = null,
		/obj/item/tool/surgery/scalpel = null,
		/obj/item/tool/surgery/scalpel = null,
		/obj/item/weapon/baseballbat = null,
		/obj/item/weapon/baseballbat = null,
		/obj/item/weapon/baseballbat = null,
		/obj/item/weapon/baseballbat/metal = null,
		/obj/item/explosive/grenade/empgrenade = null,
		/obj/item/explosive/grenade/smokebomb = null,
		/obj/item/explosive/grenade/smokebomb = null,
		/obj/item/explosive/grenade/smokebomb = null,
		/obj/item/explosive/grenade/phosphorus/upp = null,
		/obj/item/tool/hatchet = null,
		/obj/item/tool/hatchet = null,
		/obj/item/tool/hatchet = null,
		/obj/item/storage/box/MRE = null,
		/obj/item/clothing/mask/fluff/balaclava = null,
		/obj/item/clothing/glasses/night/m42_night_goggles/upp = null,
		/obj/item/storage/box/handcuffs = null,
		/obj/item/storage/pill_bottle/happy = null,
		/obj/item/weapon/twohanded/fireaxe = null,
		/obj/item/weapon/twohanded/spear = null
		)

	var/gunpath = sidearm? pick(rebel_sidearms) : pick(rebel_firearms)
	var/ammopath = sidearm? rebel_sidearms[gunpath] : rebel_firearms[gunpath]
	var/obj/item/weapon/gun/gun

	if(gunpath)
		gun = new gunpath(spawnloc)
		if(ishuman(spawnloc))
			var/mob/living/carbon/human/H = spawnloc
			H.equip_to_slot_or_del(gun, sidearm? WEAR_L_HAND : WEAR_R_HAND)
			if(ammopath && H.back && istype(H.back,/obj/item/storage) && ammopath != null)
				new ammopath(H.back)
				new ammopath(H.back)
				new ammopath(H.back)
				new ammopath(H.back)
		else
			if(ammopath != null)
				spawnloc = get_turf(spawnloc)
				new ammopath(spawnloc)
				new ammopath(spawnloc)
				new ammopath(spawnloc)


	return 1


/proc/spawn_slavic_gun(var/atom/M,var/sidearm = 0)
	if(!M) return

	var/atom/spawnloc = M

	var/list/rus_sidearms = list(
		/obj/item/weapon/gun/revolver/upp = /obj/item/ammo_magazine/revolver/upp,
		/obj/item/weapon/gun/revolver/mateba = /obj/item/ammo_magazine/revolver/mateba,
		/obj/item/weapon/gun/pistol/c99 = /obj/item/ammo_magazine/pistol/c99,
		/obj/item/weapon/gun/pistol/c99/russian = /obj/item/ammo_magazine/pistol/c99,
		/obj/item/weapon/gun/pistol/kt42 = /obj/item/ammo_magazine/pistol/automatic,
		/obj/item/weapon/gun/smg/ppsh = /obj/item/ammo_magazine/smg/ppsh,
		/obj/item/weapon/gun/smg/ppsh = /obj/item/ammo_magazine/smg/ppsh/extended)

	var/list/rus_firearms = list(/obj/item/weapon/gun/rifle/mar40,
		/obj/item/weapon/gun/rifle/mar40 = /obj/item/ammo_magazine/rifle/mar40,
		/obj/item/weapon/gun/rifle/mar40 = /obj/item/ammo_magazine/rifle/mar40/extended,
		/obj/item/weapon/gun/rifle/mar40/carbine = /obj/item/ammo_magazine/rifle/mar40,
		/obj/item/weapon/gun/smg/ppsh = /obj/item/ammo_magazine/smg/ppsh/extended,
		/obj/item/weapon/gun/rifle/sniper/svd = /obj/item/ammo_magazine/rifle/sniper/svd)

	var/gunpath = sidearm? pick(rus_sidearms) : pick(rus_firearms)
	var/ammopath = sidearm? rus_sidearms[gunpath] : rus_firearms[gunpath]
	var/obj/item/weapon/gun/gun

	if(gunpath)
		gun = new gunpath(spawnloc)
		if(ishuman(spawnloc))
			var/mob/living/carbon/human/H = spawnloc
			H.equip_to_slot_or_del(gun, sidearm? WEAR_L_HAND : WEAR_R_HAND)
			if(ammopath && H.back && istype(H.back,/obj/item/storage))
				new ammopath(H.back)
				new ammopath(H.back)
		else
			if(ammopath)
				spawnloc = get_turf(spawnloc)
				new ammopath(spawnloc)
				new ammopath(spawnloc)

	return 1