/obj/var/list/req_access = null
/obj/var/list/req_one_access = null

//Don't directly use these two, please. No: magic numbers, Yes: defines.
/obj/var/req_one_access_txt = "0"
/obj/var/req_access_txt = "0"

//returns 1 if this mob has sufficient access to use this object
/obj/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(check_access())
		return TRUE
	if(issilicon(M))
		return TRUE //Silicons can access whatever they want

	var/obj/item/card/id/I = M.get_idcard() //if they are holding or wearing a card that has access, that works.
	if(check_access(I))
		return TRUE

/obj/item/proc/GetAccess()
	return list()

/obj/item/proc/GetID()
	return

/obj/proc/check_access(obj/item/I)
	//These generations have been moved out of /obj/New() because they were slowing down the creation of objects that never even used the access system.
	var/i
	if(!req_access)
		req_access = list()
		if(req_access_txt)
			var/req_access_str[] = text2list(req_access_txt,";")
			var/n
			for(i in req_access_str)
				n = text2num(i)
				if(n) req_access += n

	if(!req_one_access)
		req_one_access = list()
		if(req_one_access_txt)
			var/req_one_access_str[] = text2list(req_one_access_txt,";")
			var/n
			for(i in req_one_access_str)
				n = text2num(i)
				if(n) req_one_access += n

	if(!islist(req_access)) return 1//something's very wrong
	var/L[] = req_access
	if(!L.len && (!req_one_access || !req_one_access.len)) return 1//no requirements
	if(!I) return

	var/A[] = I.GetAccess()
	for(i in req_access)
		if(!(i in A)) return//doesn't have this access

	if(req_one_access && req_one_access.len)
		for(i in req_one_access)
			if(i in A) return 1//has an access from the single access list
		return
	return 1

/obj/proc/check_access_list(L[])
	if(!req_access  && !req_one_access)	return 1
	if(!islist(req_access)) return 1
	if(!req_access.len && (!req_one_access || !req_one_access.len))	return 1
	if(!islist(L))	return
	var/i
	for(i in req_access)
		if(!(i in L)) return //doesn't have this access
	if(req_one_access && req_one_access.len)
		for(i in req_one_access)
			if(i in L) return 1//has an access from the single access list
		return
	return 1

/proc/get_centcom_access(job)
	return get_all_centcom_access()

/proc/get_all_accesses()
	return get_all_marine_access() + list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS)

/proc/get_all_marine_access()
	return list(ACCESS_IFF_MARINE, ACCESS_MARINE_COMMANDER, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_BRIG,
				ACCESS_MARINE_ARMORY, ACCESS_MARINE_WO, ACCESS_MARINE_CMO, ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING,
				ACCESS_MARINE_MEDBAY, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_ENGPREP,ACCESS_MARINE_SMARTPREP,
				ACCESS_MARINE_LEADER, ACCESS_MARINE_SPECPREP, ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE,
				ACCESS_MARINE_DELTA, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP,
				ACCESS_MARINE_PILOT, ACCESS_MARINE_TANK)

/proc/get_all_centcom_access()
	return list(ACCESS_NT_PMC_GREEN, ACCESS_NT_PMC_ORANGE, ACCESS_NT_PMC_RED, ACCESS_NT_PMC_BLACK, ACCESS_NT_PMC_WHITE, ACCESS_NT_CORPORATE)

/proc/get_all_syndicate_access()
	return list(ACCESS_ILLEGAL_PIRATE)

/proc/get_antagonist_access()
	var/L[] = get_all_accesses() + get_all_syndicate_access()
	return L - ACCESS_IFF_MARINE

/proc/get_antagonist_pmc_access()
	return get_antagonist_access() + ACCESS_IFF_PMC

/proc/get_freelancer_access()
	return list(ACCESS_MARINE_BRIDGE, ACCESS_MARINE_CARGO, ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS)

/proc/get_region_accesses(var/code)
	switch(code)
		if(0) return get_all_accesses()
		if(1) return list(ACCESS_MARINE_WO, ACCESS_MARINE_BRIG)//security
		if(2) return list(ACCESS_MARINE_CMO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY)//medbay
		if(3) return list(ACCESS_MARINE_RESEARCH)//research
		if(4) return list(ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING)//engineering and maintenance
		if(5) return list(ACCESS_MARINE_COMMANDER, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_CARGO)//command
		if(6) return list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_ENGPREP, ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_SPECPREP)//spess mahreens
		if(7) return list(ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA)//squads
		if(8) return list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_LOGISTICS, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING)//Civilian

/proc/get_region_accesses_name(code)
	switch(code)
		if(0) return "All"
		if(1) return "[MAIN_SHIP_NAME] Security"//security
		if(2) return "[MAIN_SHIP_NAME] Medbay"//medbay
		if(3) return "[MAIN_SHIP_NAME] Research"//research
		if(4) return "[MAIN_SHIP_NAME] Engineering"//engineering and maintenance
		if(5) return "[MAIN_SHIP_NAME] Command"//command
		if(6) return "Marines"//marine prep
		if(7) return "Squads"//squads
		if(8) return "Civilian"//Civilian


/proc/get_access_desc(A)
	switch(A)
		if(ACCESS_MARINE_WO)			return "WO's Office"
		if(ACCESS_MARINE_BRIG) 			return "Brig"
		if(ACCESS_MARINE_CMO) 			return "CMO's Office"
		if(ACCESS_MARINE_MEDBAY)		return "[MAIN_SHIP_NAME] Medbay"
		if(ACCESS_MARINE_RESEARCH) 		return "[MAIN_SHIP_NAME] Research"
		if(ACCESS_MARINE_CE)		 	return "CE's Office"
		if(ACCESS_MARINE_ENGINEERING) 	return "[MAIN_SHIP_NAME] Engineering"
		if(ACCESS_MARINE_COMMANDER) 	return "Commander's Quarters"
		if(ACCESS_MARINE_LOGISTICS) 	return "[MAIN_SHIP_NAME] Logistics"
		if(ACCESS_MARINE_BRIDGE) 		return "[MAIN_SHIP_NAME] Bridge"
		if(ACCESS_MARINE_PREP) 			return "Marine Prep"
		if(ACCESS_MARINE_ENGPREP) 		return "Marine Squad Engineering"
		if(ACCESS_MARINE_MEDPREP) 		return "Marine Squad Medical"
		if(ACCESS_MARINE_SPECPREP) 		return "Marine Specialist"
		if(ACCESS_MARINE_SMARTPREP)		return "Marine Smartgunner"
		if(ACCESS_MARINE_LEADER) 		return "Marine Leader"
		if(ACCESS_MARINE_ALPHA) 		return "Alpha Squad"
		if(ACCESS_MARINE_BRAVO) 		return "Bravo Squad"
		if(ACCESS_MARINE_CHARLIE) 		return "Charlie Squad"
		if(ACCESS_MARINE_DELTA) 		return "Delta Squad"
		if(ACCESS_MARINE_CARGO) 		return "Requisitions"
		if(ACCESS_MARINE_DROPSHIP) 		return "Dropship Piloting"
		if(ACCESS_MARINE_PILOT) 		return "Pilot Gear"
		if(ACCESS_MARINE_TANK)			return "Tank"
		if(ACCESS_CIVILIAN_RESEARCH) 	return "Civilian Research"
		if(ACCESS_CIVILIAN_LOGISTICS) 	return "Civilian Command"
		if(ACCESS_CIVILIAN_ENGINEERING) return "Civilian Engineering"
		if(ACCESS_CIVILIAN_PUBLIC) 		return "Civilian"
		if(ACCESS_IFF_MARINE) 			return "[MAIN_SHIP_NAME] Identification"

/proc/get_centcom_access_desc(A)
	switch(A)
		if(ACCESS_NT_PMC_GREEN)
			return "NT PMC Green"
		if(ACCESS_NT_PMC_ORANGE)
			return "NT PMC Orange"
		if(ACCESS_NT_PMC_RED)
			return "NT PMC Red"
		if(ACCESS_NT_PMC_BLACK)
			return "NT PMC Black"
		if(ACCESS_NT_PMC_WHITE)
			return "NT PMC White"
		if(ACCESS_NT_CORPORATE)
			return "NT Executive"
		if(ACCESS_IFF_PMC)
			return "NT Identification"


/proc/get_all_jobs_titles()
	var/list/all_jobs_titles = new
	var/list/all_datums = subtypesof(/datum/job) - /datum/job/pmc
	var/datum/job/jobdatum
	for(var/jobtype in all_datums)
		jobdatum = new jobtype
		all_jobs_titles += jobdatum.title
	return all_jobs_titles


/proc/get_all_centcom_jobs()
	return list()


//gets the actual job rank (ignoring alt titles)
//this is used solely for sechuds
/obj/proc/GetJobRealName()
	if (!istype(src,/obj/item/card/id))
		return
	var/obj/item/card/id/I = src
	if(I.rank in joblist)
		return I.rank
	if(I.assignment in joblist)
		return I.assignment
	return "Unknown"

proc/FindNameFromID(mob/living/carbon/human/H)
	ASSERT(istype(H))
	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		return I.registered_name
	I = H.get_active_held_item()
	if(istype(I))
		return I.registered_name

proc/get_all_job_icons()
	return joblist + list("Prisoner")//For all existing HUD icons

/obj/proc/GetJobName() //Used in secHUD icon generation
	var/obj/item/card/id/I = src
	if(istype(I))
		var/job_icons = get_all_job_icons()
		var/centcom = get_all_centcom_jobs()
		if(I.assignment	in job_icons)
			return I.assignment//Check if the job has a hud icon
		if(I.rank in job_icons)
			return I.rank
		if(I.assignment	in centcom)
			return "Centcom"//Return with the NT logo if it is a Centcom job
		if(I.rank in centcom)
			return "Centcom"
	return "Unknown" //Return unknown if none of the above apply


/proc/get_marine_jobs()
		return list(
				"Commander",
				"Executive Officer",
				"Staff Officer",
				"Pilot Officer",
				"Tank Crewman",
				"Corporate Liaison",
				"Chief Engineer",
				"Maintenance Tech",
				"Requisitions Officer",
				"Cargo Technician",
				"Squad Leader",
				"Squad Engineer",
				"Squad Medic",
				"Squad Specialist",
				"Squad Smartgunner",
				"Squad Marine",
				"Chief Medical Officer",
				"Doctor",
				"Researcher",
				"Military Police",
				"Chief MP"
				)

/proc/get_paygrades(paygrade, size, gender)
	if(!paygrade)
		return
	switch(paygrade)
		if("C") . = size ? "" : "Civilian"
		if("CD") . = size ? "Dr. " : "Doctor"
		if("CCMO") . = size ? "Prof. " : "Professor"
		if("PMC1") . = size ? "PMC " : "PMC Standard"
		if("PMC2") . = size ? "PMC " : "PMC Gunner"
		if("PMC3") . = size ? "PMC " : "PMC Sniper"
		if("PMC4") . = size ? "PMC " : "PMC Leader"
		if("PMCDS") . = size ? "PMCDS " : "PMC Deathsquad"
		if("PMCDSL") . = size ? "PMCDS " : "PMC Deathsquad Leader"
		if("NT") . = size ? (gender == "female" ? "Ms. " : "Mr. ") : "Junior Executive"
		if("E1") . = size ? "PVT " : "Private"
		if("E2") . = size ? "PFC " : "Private First Class"
		if("E3") . = size ? "LCPL " : "Lance Corporal"
		if("E4") . = size ? "CPL " : "Corporal"
		if("E5") . = size ? "SGT " : "Sergeant"
		if("E6") . = size ? "SSGT " : "Staff Sergeant"
		if("E6E") . = size ? "TSGT " : "Technical Sergeant"
		if("E7") . = size ? "SFC " : "Sergeant First Class"
		if("E8") . = size ? "MSGT " : "Master Sergeant"
		if("E8E") . = size ? "FSGT " : "First Sergeant"
		if("E9") . = size ? "SGM " : "Sergeant Major"
		if("E9E") . = size ? "CSGM " : "Command Sergeant Major"
		if("O1") . = size ? "ENS " : "Ensign"
		if("O2") . = size ? "LT " : "Lieutenant"
		if("O3") . = size ? "LCDR " : "Lieutenant Commander"
		if("O4") . = size ? "CDR " : "Commander"
		if("O5") . = size ? "CPT " : "Captain"
		if("O6") . = size ? "RADM " : "Rear Admiral"
		if("O7") . = size ? "ADM " : "Admiral"
		if("O8") . = size ? "FADM " : "Fleet Admiral"
		if("O9") . = size ? "SMR " : "Sky Marshal"
		if("WO") . = size ? "WO " : "Warrant Officer"
		if("UPP1") . = size ? "UPVT " : "UPP Private"
		if("UPP2") . = size ? "UPFC " : "UPP Private First Class"
		if("UPP3") . = size ? "UCPL " : "UPP Corporal"
		if("UPP4") . = size ? "ULCPL " : "UPP Lance Corporal"
		if("UPP5") . = size ? "USGT " : "UPP Sergeant"
		if("UPP6") . = size ? "USSGT " : "UPP Staff Sergeant"
		if("UPP7") . = size ? "UENS " : "UPP Ensign"
		if("UPP8") . = size ? "ULT " : "UPP Lieutenant"
		if("UPP9") . = size ? "ULCDR " : "UPP Lieutenant Commander"
		if("UPP10") . = size ? "UCDR " : "UPP Commander"
		if("UPP11") . = size ? "UADM " : "UPP Admiral"
		if("UPPC1") . = size ? "UPPC " : "UPP Commando Standard"
		if("UPPC2") . = size ? "UPPC " : "UPP Commando Medic"
		if("UPPC3") . = size ? "UPPC " : "UPP Commando Leader"
		if("FRE1") . = size ? "FRE " : "Freelancer Standard"
		if("FRE2") . = size ? "FRE " : "Freelancer Medic"
		if("FRE3") . = size ? "FRE " : "Freelancer Leader"
		if("CLF1") . = size ? "CLF " : "CLF Standard"
		if("CLF2") . = size ? "CLF " : "CLF Medic"
		if("CLF3") . = size ? "CLF " : "CLF Leader"
		if("MRC1") . = size ? "MERC " : "MERC Heavy"
		if("MRC2") . = size ? "MERC " : "MERC Miner"
		if("MRC3") . = size ? "MERC " : "MERC Engineer"
		else . = paygrade + " " //custom paygrade

#define PAYGRADES_MARINE list("C","E1","E2","E3","E4","E5","E6","E6E","E7","E8","E8E","E9","E9E","O1","O2","O3","O4", "WO")
#define PAYGRADES_OFFICER list("O1","O2","O3","O4", "WO")
#define PAYGRADES_ENLISTED list("C","E1","E2","E3","E4","E5","E6","E7","E8","E9")

//Just marines
#define ALL_MARINE_ACCESS list(ACCESS_IFF_MARINE, ACCESS_MARINE_COMMANDER, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_BRIG, ACCESS_MARINE_ARMORY, ACCESS_MARINE_WO, ACCESS_MARINE_CMO, ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_ENGPREP,ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_SPECPREP, ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_PILOT, ACCESS_MARINE_TANK, ACCESS_CIVILIAN_ENGINEERING)

//Literally everything
#define ALL_ACCESS list(ACCESS_IFF_MARINE, ACCESS_MARINE_COMMANDER, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_BRIG, ACCESS_MARINE_ARMORY, ACCESS_MARINE_WO, ACCESS_MARINE_CMO, ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_ENGPREP,ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_SPECPREP, ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_PILOT, ACCESS_MARINE_TANK, ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS, ACCESS_NT_PMC_GREEN, ACCESS_NT_PMC_ORANGE, ACCESS_NT_PMC_RED, ACCESS_NT_PMC_BLACK, ACCESS_NT_PMC_WHITE, ACCESS_NT_CORPORATE, ACCESS_ILLEGAL_PIRATE, ACCESS_IFF_PMC)

//Removes PMC and Marine IFF
#define ALL_ANTAGONIST_ACCESS list(ACCESS_MARINE_COMMANDER, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_BRIG, ACCESS_MARINE_ARMORY, ACCESS_MARINE_WO, ACCESS_MARINE_CMO, ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_ENGPREP,ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_SPECPREP, ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_PILOT, ACCESS_MARINE_TANK, ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS, ACCESS_NT_PMC_GREEN, ACCESS_NT_PMC_ORANGE, ACCESS_NT_PMC_RED, ACCESS_NT_PMC_BLACK, ACCESS_NT_PMC_WHITE, ACCESS_NT_CORPORATE, ACCESS_ILLEGAL_PIRATE)