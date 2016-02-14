//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31
//Sulaco access levels

/var/const/access_sulaco_captain = 1
/var/const/access_sulaco_logistics = 2
/var/const/access_sulaco_brig = 3
/var/const/access_sulaco_armory = 4
/var/const/access_sulaco_CMO = 5
/var/const/access_sulaco_CE = 6
/var/const/access_sulaco_engineering = 7
/var/const/access_sulaco_medbay = 8
/var/const/access_marine_prep = 9
/var/const/access_marine_medprep = 10
/var/const/access_marine_engprep = 11
/var/const/access_marine_leader = 12
/var/const/access_marine_specprep = 13
/var/const/access_sulaco_research = 14
/var/const/access_squad_alpha = 15
/var/const/access_squad_bravo = 16
/var/const/access_squad_charlie = 17
/var/const/access_squad_delta = 18
/var/const/access_sulaco_bridge = 19
/var/const/access_sulaco_chemistry = 20
/var/const/access_sulaco_cargo = 21

//Surface access levels

/var/const/access_civilian_generic = 100
/var/const/access_civilian_command = 101
/var/const/access_civilian_engi = 102
/var/const/access_civilian_research = 103

/var/const/access_centcomm = 200 // One generic access for centcomm, fuckit
/var/const/access_syndicate = 201 // One generic access for centcomm, fuckit

/*
/var/const/access_security = 1 // Security equipment
/var/const/access_brig = 2 // Brig timers and permabrig
/var/const/access_armory = 3
/var/const/access_forensics_lockers= 4
/var/const/access_medical = 5
/var/const/access_morgue = 6
/var/const/access_tox = 7
/var/const/access_tox_storage = 8
/var/const/access_genetics = 9
/var/const/access_engine = 10
/var/const/access_engine_equip= 11
/var/const/access_maint_tunnels = 12
/var/const/access_external_airlocks = 13
/var/const/access_emergency_storage = 14
/var/const/access_change_ids = 15
/var/const/access_ai_upload = 16
/var/const/access_teleporter = 17
/var/const/access_eva = 18
/var/const/access_heads = 19
/var/const/access_captain = 20
/var/const/access_all_personal_lockers = 21
/var/const/access_chapel_office = 22
/var/const/access_tech_storage = 23
/var/const/access_atmospherics = 24
/var/const/access_bar = 25
/var/const/access_janitor = 26
/var/const/access_crematorium = 27
/var/const/access_kitchen = 28
/var/const/access_robotics = 29
/var/const/access_rd = 30
/var/const/access_cargo = 31
/var/const/access_construction = 32
/var/const/access_chemistry = 33
/var/const/access_cargo_bot = 34
/var/const/access_hydroponics = 35
/var/const/access_manufacturing = 36
/var/const/access_library = 37
/var/const/access_lawyer = 38
/var/const/access_virology = 39
/var/const/access_cmo = 40
/var/const/access_qm = 41
/var/const/access_court = 42
/var/const/access_clown = 43
/var/const/access_mime = 44
/var/const/access_surgery = 45
/var/const/access_theatre = 46
/var/const/access_research = 47
/var/const/access_mining = 48
/var/const/access_mining_office = 49 //not in use
/var/const/access_mailsorting = 50
/var/const/access_mint = 51
/var/const/access_mint_vault = 52
/var/const/access_heads_vault = 53
/var/const/access_mining_station = 54
/var/const/access_xenobiology = 55
/var/const/access_ce = 56
/var/const/access_hop = 57
/var/const/access_hos = 58
/var/const/access_RC_announce = 59 //Request console announcements
/var/const/access_keycard_auth = 60 //Used for events which require at least two people to confirm them
/var/const/access_tcomsat = 61 // has access to the entire telecomms satellite / machinery
/var/const/access_gateway = 62
/var/const/access_sec_doors = 63 // Security front doors
/var/const/access_psychiatrist = 64 // Psychiatrist's office
/var/const/access_xenoarch = 65

	//BEGIN CENTCOM ACCESS
	/*Should leave plenty of room if we need to add more access levels.
/var/const/Mostly for admin fun times.*/
/var/const/access_cent_general = 101//General facilities.
/var/const/access_cent_thunder = 102//Thunderdome.
/var/const/access_cent_specops = 103//Special Ops.
/var/const/access_cent_medical = 104//Medical/Research
/var/const/access_cent_living = 105//Living quarters.
/var/const/access_cent_storage = 106//Generic storage areas.
/var/const/access_cent_teleporter = 107//Teleporter.
/var/const/access_cent_creed = 108//Creed's office.
/var/const/access_cent_captain = 109//Captain's office/ID comp/AI.

	//The Syndicate
/var/const/access_syndicate = 150//General Syndicate Access

	//MONEY
/var/const/access_crate_cash = 200

/var/const/access_logistics = 300

/*
/var/const/access_alpha_prep = 301
/var/const/access_alpha_mprep = 302
/var/const/access_alpha_eprep = 303
/var/const/access_alpha_sprep = 304
/var/const/access_alpha_leader = 305

//Bravo prep stuff
/var/const/access_bravo_prep = 306
/var/const/access_bravo_mprep = 307
/var/const/access_bravo_eprep = 308
/var/const/access_bravo_sprep = 309
/var/const/access_bravo_leader = 310

//Charlie prep stuff
/var/const/access_charlie_prep = 311
/var/const/access_charlie_mprep = 312
/var/const/access_charlie_eprep = 313
/var/const/access_charlie_sprep = 314
/var/const/access_charlie_leader = 315

//Delta prep stuff
/var/const/access_delta_prep = 316
/var/const/access_delta_mprep = 317
/var/const/access_delta_eprep = 318
/var/const/access_delta_sprep = 319
/var/const/access_delta_leader = 320
*/

/var/const/access_xeno_containment = 400

/var/const/access_medical_bay = 500
/var/const/access_medical_chem = 501
/var/const/access_medical_surgery = 502
/var/const/access_medical_genetics = 503
/var/const/access_medical_storage = 504

/var/const/access_sulaco_brig = 600
/var/const/access_sulaco_cells = 601

/var/const/access_marine_prep = 301
/var/const/access_marine_medprep = 302
/var/const/access_marine_engprep = 303
/var/const/access_marine_leader = 304

/var/const/access_alpha_squad = 330
/var/const/access_bravo_squad = 331
/var/const/access_charlie_squad = 332
/var/const/access_delta_squad = 333
*/




/obj/var/list/req_access = null
/obj/var/req_access_txt = "0"
/obj/var/list/req_one_access = null
/obj/var/req_one_access_txt = "0"

//returns 1 if this mob has sufficient access to use this object
/obj/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(src.check_access(null))
		return 1
	if(istype(M, /mob/living/silicon))
		//AI can do whatever he wants
		return 1
	else if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(src.check_access(H.get_active_hand()) || src.check_access(H.wear_id))
			return 1
	else if(istype(M, /mob/living/carbon/monkey) || istype(M, /mob/living/carbon/alien))
		var/mob/living/carbon/george = M
		//they can only hold things :(
		if(src.check_access(george.get_active_hand()))
			return 1
	return 0

/obj/item/proc/GetAccess()
	return list()

/obj/item/proc/GetID()
	return null

/obj/proc/check_access(obj/item/I)
	//These generations have been moved out of /obj/New() because they were slowing down the creation of objects that never even used the access system.
	if(!src.req_access)
		src.req_access = list()
		if(src.req_access_txt)
			var/list/req_access_str = text2list(req_access_txt,";")
			for(var/x in req_access_str)
				var/n = text2num(x)
				if(n)
					req_access += n

	if(!src.req_one_access)
		src.req_one_access = list()
		if(src.req_one_access_txt)
			var/list/req_one_access_str = text2list(req_one_access_txt,";")
			for(var/x in req_one_access_str)
				var/n = text2num(x)
				if(n)
					req_one_access += n

	if(!istype(src.req_access, /list)) //something's very wrong
		return 1

	var/list/L = src.req_access
	if(!L.len && (!src.req_one_access || !src.req_one_access.len)) //no requirements
		return 1
	if(!I)
		return 0
	for(var/req in src.req_access)
		if(!(req in I.GetAccess())) //doesn't have this access
			return 0
	if(src.req_one_access && src.req_one_access.len)
		for(var/req in src.req_one_access)
			if(req in I.GetAccess()) //has an access from the single access list
				return 1
		return 0
	return 1


/obj/proc/check_access_list(var/list/L)
	if(!src.req_access  && !src.req_one_access)	return 1
	if(!istype(src.req_access, /list))	return 1
	if(!src.req_access.len && (!src.req_one_access || !src.req_one_access.len))	return 1
	if(!L)	return 0
	if(!istype(L, /list))	return 0
	for(var/req in src.req_access)
		if(!(req in L)) //doesn't have this access
			return 0
	if(src.req_one_access && src.req_one_access.len)
		for(var/req in src.req_one_access)
			if(req in L) //has an access from the single access list
				return 1
		return 0
	return 1

/proc/get_centcom_access(job)
	return get_all_centcom_access()
	/*
	switch(job)
		if("VIP Guest")
			return list(access_cent_general)
		if("Custodian")
			return list(access_cent_general, access_cent_living, access_cent_storage)
		if("Thunderdome Overseer")
			return list(access_cent_general, access_cent_thunder)
		if("Intel Officer")
			return list(access_cent_general, access_cent_living)
		if("Medical Officer")
			return list(access_cent_general, access_cent_living, access_cent_medical)
		if("Death Commando")
			return list(access_cent_general, access_cent_specops, access_cent_living, access_cent_storage)
		if("Research Officer")
			return list(access_cent_general, access_cent_specops, access_cent_medical, access_cent_teleporter, access_cent_storage)
		if("BlackOps Commander")
			return list(access_cent_general, access_cent_thunder, access_cent_specops, access_cent_living, access_cent_storage, access_cent_creed)
		if("Supreme Commander")
		*/


/proc/get_all_accesses()
	return list(access_sulaco_captain, access_sulaco_logistics, access_sulaco_bridge, access_sulaco_brig, access_sulaco_armory, access_sulaco_CMO, access_sulaco_CE, access_sulaco_engineering, access_sulaco_medbay, access_marine_prep, access_marine_medprep, access_marine_engprep, access_marine_leader, access_marine_specprep, access_squad_alpha, access_squad_bravo, access_squad_charlie, access_squad_delta, access_sulaco_chemistry, access_sulaco_research, access_civilian_generic, access_civilian_research, access_civilian_engi, access_civilian_command, access_sulaco_cargo)

/proc/get_all_marine_access()
	return list(access_sulaco_captain, access_sulaco_logistics, access_sulaco_bridge, access_sulaco_brig, access_sulaco_armory, access_sulaco_CMO, access_sulaco_CE, access_sulaco_engineering, access_sulaco_medbay, access_marine_prep, access_marine_medprep, access_marine_engprep, access_marine_leader, access_marine_specprep, access_squad_alpha, access_squad_bravo, access_squad_charlie, access_squad_delta, access_sulaco_chemistry, access_sulaco_research, access_sulaco_cargo)

/proc/get_all_centcom_access()
	return list(access_centcomm)

/proc/get_all_syndicate_access()
	return list(access_syndicate)

/proc/get_region_accesses(var/code)
	switch(code)
		if(0)
			return get_all_accesses()
		if(1) //security
			return list(access_sulaco_brig)
		if(2) //medbay
			return list(access_sulaco_CMO, access_sulaco_medbay)
		if(3) //research
			return list(access_sulaco_research, access_sulaco_chemistry)
		if(4) //engineering and maintenance
			return list(access_sulaco_CE, access_sulaco_engineering)
		if(5) //command
			return list(access_sulaco_captain, access_sulaco_logistics, access_sulaco_bridge, access_sulaco_cargo)
		if(6) //spess mahreens
			return list(access_marine_prep, access_marine_medprep, access_marine_engprep, access_marine_leader, access_marine_specprep)
		if(7) //squads
			return list(access_squad_alpha, access_squad_bravo, access_squad_charlie, access_squad_delta)
		if(8) //Civilian
			return list(access_civilian_generic, access_civilian_command, access_civilian_research, access_civilian_engi)

/proc/get_region_accesses_name(var/code)
	switch(code)
		if(0)
			return "All"
		if(1) //security
			return "Sulaco Security"
		if(2) //medbay
			return "Sulaco Medbay"
		if(3) //research
			return "Sulaco Research"
		if(4) //engineering and maintenance
			return "Sulaco Engineering"
		if(5) //command
			return "Sulaco Command"
		if(6) //marine prep
			return "Marines"
		if(7) //squads
			return "Squads"
		if(8) //Civilian
			return "Civilian"

/proc/get_access_desc(A)
	switch(A)
		if(access_sulaco_brig)
			return "Brig"
		if(access_sulaco_CMO)
			return "CMO's Office"
		if(access_sulaco_medbay)
			return "Sulaco Medbay"
		if(access_sulaco_research)
			return "Sulaco Research"
		if(access_sulaco_CE)
			return "CE's Office"
		if(access_sulaco_engineering)
			return "Sulaco Engineering"
		if(access_sulaco_captain)
			return "Captain's Quarters"
		if(access_sulaco_logistics)
			return "Sulaco Logistics"
		if(access_sulaco_bridge)
			return "Sulaco Bridge"
		if(access_marine_prep)
			return "Marine Prep"
		if(access_marine_engprep)
			return "Marine Engineer Prep"
		if(access_marine_medprep)
			return "Marine Medical Prep"
		if(access_marine_specprep)
			return "Marine Specialist Prep"
		if(access_marine_leader)
			return "Marine Leader Prep"
		if(access_squad_alpha)
			return "Alpha Squad"
		if(access_squad_bravo)
			return "Bravo Squad"
		if(access_squad_charlie)
			return "Charlie Squad"
		if(access_squad_delta)
			return "Delta Squad"
		if(access_civilian_research)
			return "Civilian Research"
		if(access_civilian_command)
			return "Civilian Command"
		if(access_civilian_engi)
			return "Civilian Engineering"
		if(access_civilian_generic)
			return "Civilian"
		if(access_sulaco_cargo)
			return "Requisitions"

/proc/get_centcom_access_desc(A)
	switch(A)
		if(access_centcomm)
			return "Code Black"

/proc/get_all_jobs()
	var/list/all_jobs = list()
	var/list/all_datums = typesof(/datum/job)
//	all_datums.Remove(list(/datum/job,/datum/job/ai,/datum/job/cyborg))
	var/datum/job/jobdatum
	for(var/jobtype in all_datums)
		jobdatum = new jobtype
		// if(jobdatum.title in get_marine_jobs())
		all_jobs.Add(jobdatum.title)
	return all_jobs

/proc/get_all_centcom_jobs()
	return list("VIP Guest","Custodian","Thunderdome Overseer","Intel Officer","Medical Officer","Death Commando","Research Officer","BlackOps Commander","Supreme Commander")

//gets the actual job rank (ignoring alt titles)
//this is used solely for sechuds
/obj/proc/GetJobRealName()
	if (!istype(src, /obj/item/device/pda) && !istype(src,/obj/item/weapon/card/id))
		return

	var/rank
	var/assignment
	if(istype(src, /obj/item/device/pda))
		if(src:id)
			rank = src:id:rank
			assignment = src:id:assignment
	else if(istype(src, /obj/item/weapon/card/id))
		rank = src:rank
		assignment = src:assignment

	if( rank in joblist )
		return rank

	if( assignment in joblist )
		return assignment

	return "Unknown"

//gets the alt title, failing that the actual job rank
//this is unused
/obj/proc/sdsdsd()	//GetJobDisplayName
	if (!istype(src, /obj/item/device/pda) && !istype(src,/obj/item/weapon/card/id))
		return

	var/assignment
	if(istype(src, /obj/item/device/pda))
		if(src:id)
			assignment = src:id:assignment
	else if(istype(src, /obj/item/weapon/card/id))
		assignment = src:assignment

	if(assignment)
		return assignment

	return "Unknown"

proc/FindNameFromID(var/mob/living/carbon/human/H)
	ASSERT(istype(H))
	var/obj/item/weapon/card/id/C = H.get_active_hand()
	if( istype(C) || istype(C, /obj/item/device/pda) )
		var/obj/item/weapon/card/id/ID = C

		if( istype(C, /obj/item/device/pda) )
			var/obj/item/device/pda/pda = C
			ID = pda.id
		if(!istype(ID))
			ID = null

		if(ID)
			return ID.registered_name

	C = H.wear_id

	if( istype(C) || istype(C, /obj/item/device/pda) )
		var/obj/item/weapon/card/id/ID = C

		if( istype(C, /obj/item/device/pda) )
			var/obj/item/device/pda/pda = C
			ID = pda.id
		if(!istype(ID))
			ID = null

		if(ID)
			return ID.registered_name

proc/get_all_job_icons() //For all existing HUD icons
	return joblist + list("Prisoner")

/obj/proc/GetJobName() //Used in secHUD icon generation
	var/obj/item/weapon/card/id/I
	if(istype(src, /obj/item/device/pda))
		var/obj/item/device/pda/P = src
		I = P.id
	else if(istype(src, /obj/item/weapon/card/id))
		I = src

	if(I)
		var/job_icons = get_all_job_icons()
		var/centcom = get_all_centcom_jobs()

		if(I.assignment	in job_icons) //Check if the job has a hud icon
			return I.assignment
		if(I.rank in job_icons)
			return I.rank

		if(I.assignment	in centcom) //Return with the NT logo if it is a Centcom job
			return "Centcom"
		if(I.rank in centcom)
			return "Centcom"
	else
		return

	return "Unknown" //Return unknown if none of the above apply


/proc/get_marine_jobs()
		return list(
		"Commander",
		"Executive Officer",
		"Bridge Officer",
		"Corporate Liaison",
		"Chief Engineer",
		"Maintenance Tech",
		"Requisitions Officer",
		"Cargo Technician",
		"Squad Leader",
		"Squad Engineer",
		"Squad Medic",
		"Squad Specialist",
		"Squad Marine",
		"Chief Medical Officer",
		"Doctor",
		"Researcher",
		"Military Police"
		)

/*
/proc/get_marine_access(job)
	switch(job)
		if("Squad Leader")
			return list(access_marine_prep, access_marine_medprep, access_marine_engprep, access_marine_leader)
		if("Squad Medic")
			return list(access_marine_prep, access_marine_medprep)
		if("Squad Engineer")
			return list(access_marine_prep, access_marine_eprep)
		if("Squad Marine")
			return list(access_marine_prep, access_marine_sprep)
		if("Logistics Officer")
			return list(access_logistics)
		if("Commander")
			return list(access_marine_prep, access_marine_medprep, access_marine_engprep, access_marine_leader, access_logistics, access_xeno_containment, access_medical_bay, access_medical_surgery, access_medical_chem, access_medical_storage, access_medical_genetics, access_robotics, access_sulaco_brig, access_sulaco_cells)
		if("Researcher")
			return list(access_xeno_containment, access_robotics)
		if("Sulaco Medic")
			return list(access_medical_bay, access_medical_surgery, access_medical_chem, access_medical_genetics, access_medical_storage)
		if("Military Police")
			return list(access_sulaco_brig, access_sulaco_cells, access_logistics, access_xeno_containment, access_robotics, access_medical_bay, access_medical_surgery)


/proc/get_marine_access_desc(A)
	switch(A)
		if(access_marine_prep)
			return "Marine Preparation"
		if(access_marine_mprep)
			return "Medical Preparation"
		if(access_marine_eprep)
			return "Engineering Preparation"
		if(access_marine_sprep)
			return "Standard Preparation"
		if(access_marine_leader)
			return "Leader Preparation"
		if(access_logistics)
			return "Logistics"
		if(access_xeno_containment)
			return "Xenomorphic Containment"
		if(access_medical_bay)
			return "Sulaco Med Bay"
		if(access_medical_chem)
			return "Sulaco Med Chemistry"
		if(access_medical_genetics)
			return "Sulaco Med Genetics"
		if(access_medical_surgery)
			return "Sulaco Med Surgery"
		if(access_medical_storage)
			return "Sulaco Med Storage"
		if(access_sulaco_brig)
			return "Sulaco Brig"
		if(access_sulaco_cells)
			return "Sulaco Brig Cells"

/proc/get_all_marine_accesses()
	return list(access_marine_prep, access_marine_medprep, access_marine_engprep, access_marine_leader, access_logistics, access_xeno_containment, access_medical_bay, access_medical_surgery, access_medical_chem, access_medical_storage, access_medical_genetics, access_robotics, access_sulaco_brig, access_sulaco_cells)

/proc/get_marine_region_accesses_name(var/code)
	switch(code)
		if(1)
			return "Alpha"
		if(2)
			return "Bravo"
		if(3)
			return "Charlie"
		if(4)
			return "Delta"
		if(5)
			return "Command"
		if(6)
			return "Research"
		if(7)
			return "Misc"
//All obsolete
/proc/get_marine_region_accesses(var/code)
	switch(code)
		if(1)
			return list(access_marine_prep, access_marine_medprep, access_marine_engprep, access_marine_leader)
		if(2)
			return list(access_marine_prep, access_marine_medprep, access_marine_engprep, access_marine_leader)
		if(3)
			return list(access_marine_prep, access_marine_medprep, access_marine_engprep, access_marine_leader)
		if(4)
			return list(access_marine_prep, access_marine_medprep, access_marine_engprep, access_marine_leader)
		if(5)
			return list(access_logistics)
		if(6)
			return list(access_xeno_containment)
		if(7)
			return list(access_medical_bay, access_medical_surgery, access_medical_chem, access_medical_storage, access_medical_genetics, access_sulaco_brig, access_sulaco_cells)
*/