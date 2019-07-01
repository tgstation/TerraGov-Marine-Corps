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
	return list(ACCESS_IFF_MARINE, ACCESS_MARINE_CAPTAIN, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_BRIG,
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

/proc/get_region_accesses(code)
	switch(code)
		if(0) return get_all_accesses()
		if(1) return list(ACCESS_MARINE_WO, ACCESS_MARINE_BRIG)//security
		if(2) return list(ACCESS_MARINE_CMO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY)//medbay
		if(3) return list(ACCESS_MARINE_RESEARCH)//research
		if(4) return list(ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING)//engineering and maintenance
		if(5) return list(ACCESS_MARINE_CAPTAIN, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_CARGO)//command
		if(6) return list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_ENGPREP, ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_SPECPREP)//spess mahreens
		if(7) return list(ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA)//squads
		if(8) return list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_LOGISTICS, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING)//Civilian

/proc/get_region_accesses_name(code)
	switch(code)
		if(0) return "All"
		if(1) return "[CONFIG_GET(string/ship_name)] Security"//security
		if(2) return "[CONFIG_GET(string/ship_name)] Medbay"//medbay
		if(3) return "[CONFIG_GET(string/ship_name)] Research"//research
		if(4) return "[CONFIG_GET(string/ship_name)] Engineering"//engineering and maintenance
		if(5) return "[CONFIG_GET(string/ship_name)] Command"//command
		if(6) return "Marines"//marine prep
		if(7) return "Squads"//squads
		if(8) return "Civilian"//Civilian


/proc/get_access_desc(A)
	switch(A)
		if(ACCESS_MARINE_WO)
			return "WO's Office"
		if(ACCESS_MARINE_BRIG)
			return "Brig"
		if(ACCESS_MARINE_CMO)
			return "CMO's Office"
		if(ACCESS_MARINE_MEDBAY)
			return "[CONFIG_GET(string/ship_name)] Medbay"
		if(ACCESS_MARINE_RESEARCH)
			return "[CONFIG_GET(string/ship_name)] Research"
		if(ACCESS_MARINE_CE)
			return "CE's Office"
		if(ACCESS_MARINE_ENGINEERING)
			return "[CONFIG_GET(string/ship_name)] Engineering"
		if(ACCESS_MARINE_CAPTAIN)
			return "Captain's Quarters"
		if(ACCESS_MARINE_LOGISTICS)
			return "[CONFIG_GET(string/ship_name)] Logistics"
		if(ACCESS_MARINE_BRIDGE)
			return "[CONFIG_GET(string/ship_name)] Bridge"
		if(ACCESS_MARINE_PREP)
			return "Marine Prep"
		if(ACCESS_MARINE_ENGPREP)
			return "Marine Squad Engineering"
		if(ACCESS_MARINE_MEDPREP)
			return "Marine Squad Medical"
		if(ACCESS_MARINE_SPECPREP)
			return "Marine Specialist"
		if(ACCESS_MARINE_SMARTPREP)
			return "Marine Smartgunner"
		if(ACCESS_MARINE_LEADER)
			return "Marine Leader"
		if(ACCESS_MARINE_ALPHA)
			return "Alpha Squad"
		if(ACCESS_MARINE_BRAVO)
			return "Bravo Squad"
		if(ACCESS_MARINE_CHARLIE)
			return "Charlie Squad"
		if(ACCESS_MARINE_DELTA)
			return "Delta Squad"
		if(ACCESS_MARINE_CARGO)
			return "Requisitions"
		if(ACCESS_MARINE_DROPSHIP)
			return "Dropship Piloting"
		if(ACCESS_MARINE_PILOT)
			return "Pilot Gear"
		if(ACCESS_MARINE_TANK)
			return "Tank"
		if(ACCESS_CIVILIAN_RESEARCH)
			return "Civilian Research"
		if(ACCESS_CIVILIAN_LOGISTICS)
			return "Civilian Command"
		if(ACCESS_CIVILIAN_ENGINEERING)
			return "Civilian Engineering"
		if(ACCESS_CIVILIAN_PUBLIC)
			return "Civilian"
		if(ACCESS_IFF_MARINE)
			return "[CONFIG_GET(string/ship_name)] Identification"

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
	if(I.rank in SSjob.name_occupations)
		return I.rank
	if(I.assignment in SSjob.name_occupations)
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
	return SSjob.name_occupations + list("Prisoner")//For all existing HUD icons

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
				"Captain",
				"Field Commander",
				"Intelligence Officer",
				"Pilot Officer",
				"Tank Crewman",
				"Corporate Liaison",
				"Chief Ship Engineer",
				"Ship Engineer",
				"Requisitions Officer",
				"Cargo Technician",
				"Squad Leader",
				"Squad Engineer",
				"Squad Corpsman",
				"Squad Specialist",
				"Squad Smartgunner",
				"Squad Marine",
				"Chief Medical Officer",
				"Medical Officer",
				"Medical Researcher",
				"Master at Arms",
				"Command Master at Arms"
				)

/datum/paygrade
	var/index
	var/short
	var/female
	var/long

/datum/paygrade/civilian
	index = "C"
	short = ""
	long = "Civilian"

/datum/paygrade/civilian_doctor
	index = "CD"
	short = "Dr. "
	long = "Doctor"

/datum/paygrade/civilian_doctor_chief
	index = "CCMO"
	short = "Prof. "
	long = "Professor"

/datum/paygrade/pmcontractor
	index = "PMC1"
	short = "PMC "
	long = "PM Contractor"

/datum/paygrade/pmsenior_contractor
	index = "PMC2"
	short = "PMSC "
	long = "PM Senior Contractor"

/datum/paygrade/pmsenior_contractor2
	index = "PMC3"
	short = "PMSC "
	long = "PM Senior Contractor"

/datum/paygrade/pm_team_leader
	index = "PMC4"
	short = "PMTL "
	long = "PM Team Leader"

/datum/paygrade/assets_protection_specialist
	index = "PMCDS"
	short = "APS "
	long = "Assets Protection Specialist"

/datum/paygrade/assets_protection_team_leader
	index = "PMCDSL"
	short = "APTL "
	long = "Assets Protection Team Leader"

/datum/paygrade/executive
	index = "NT"
	short = "Mr. "
	female = "Ms. "
	long = "Junior Executive"

/datum/paygrade/private
	index = "E1"
	short = "PVT "
	long = "Private"

/datum/paygrade/pfc
	index = "E2"
	short = "PFC "
	long = "Private First Class"

/datum/paygrade/lcpl
	index = "E3"
	short = "LCPL "
	long = "Lance Corporal"

/datum/paygrade/cpl
	index = "E4"
	short = "CPL "
	long = "Corporal"

/datum/paygrade/sgt
	index = "E5"
	short = "SGT "
	long = "Sergeant"

/datum/paygrade/ssgt
	index = "E6"
	short = "SSGT "
	long = "Staff Sergeant"

/datum/paygrade/gysgt
	index = "E7"
	short = "GYSGT "
	long = "Gunnery Sergeant"

/datum/paygrade/msgt
	index = "E8"
	short = "MSGT "
	long = "Master Sergeant"

/datum/paygrade/fsgt
	index = "E8E"
	short = "FSGT "
	long = "First Sergeant"

/datum/paygrade/sgm
	index = "E9"
	short = "SGM "
	long = "Sergeant Major"

/datum/paygrade/csm
	index = "E9E"
	short = "CSGM "
	long = "Command Sergeant Major"

/datum/paygrade/ens
	index = "O1"
	short = "ENS "
	long = "Ensign"

/datum/paygrade/ltjg
	index = "O2"
	short = "LTJG "
	long = "Lieutenant Junior Grade"

/datum/paygrade/lt
	index = "O3"
	short = "LT "
	long = "Lieutenant"

/datum/paygrade/lcdr
	index = "O4"
	short = "LCDR "
	long = "Lieutenant Commander"

/datum/paygrade/cdr
	index = "O5"
	short = "CDR "
	long = "Commander"

/datum/paygrade/cpt
	index = "O6"
	short = "CPT "
	long = "Captain"

/datum/paygrade/comm
	index = "O7"
	short = "COMM "
	long = "Commodore"

/datum/paygrade/radm
	index = "O8"
	short = "RADM "
	long = "Rear Admiral"

/datum/paygrade/vadm
	index = "O9"
	short = "VADM "
	long = "Vice Admiral"

/datum/paygrade/adm
	index = "10"
	short = "ADM "
	long = "Admiral"

/datum/paygrade/fadm
	index = "11"
	short = "FADM "
	long = "Fleet Admiral"

/datum/paygrade/wo
	index = "WO"
	short = "WO "
	long = "Warrant Officer"

/datum/paygrade/cwo
	index = "CWO"
	short = "CWO "
	long = "Chief Warrant Officer"

/datum/paygrade/po
	index = "PO"
	short = "PO "
	long = "Petty Officer"

/datum/paygrade/cpo
	index = "CPO"
	short = "CPO "
	long = "Chief Petty Officer"

/datum/paygrade/maj
	index = "MO4"
	short = "MAJ "
	long = "Major"

/datum/paygrade/upvt
	index = "UPP1"
	short = "UPVT "
	long = "UPP Private"

/datum/paygrade/upfc
	index = "UPP2"
	short = "UPFC "
	long = "UPP Private First Class"

/datum/paygrade/ucpl
	index = "UPP3"
	short = "UCPL "
	long = "UPP Corporal"

/datum/paygrade/ulcpl
	index = "UPP4"
	short = "ULCPL "
	long = "UPP Lance Corporal"

/datum/paygrade/usgt
	index = "UPP5"
	short = "USGT "
	long = "UPP Sergeant"

/datum/paygrade/ussgt
	index = "UPP6"
	short = "USSGT "
	long = "UPP Staff Sergeant"

/datum/paygrade/uens
	index = "UPP7"
	short = "UENS "
	long = "UPP Ensign"

/datum/paygrade/ult
	index = "UPP8"
	short = "ULT "
	long = "UPP Lieutenant"

/datum/paygrade/ulcdr
	index = "UPP9"
	short = "ULCDR "
	long = "UPP Lieutenant Commander"

/datum/paygrade/ucdr
	index = "UPP10"
	short = "UCDR "
	long = "UPP Commander"

/datum/paygrade/uadm
	index = "UPP11"
	short = "UADM "
	long = "UPP Admiral"

/datum/paygrade/uppc
	index = "UPPC1"
	short = "UPPC "
	long = "UPP Commando Standard"

/datum/paygrade/uppcm
	index = "UPPC2"
	short = "UPPC "
	long = "UPP Commando Medic"

/datum/paygrade/uppcl
	index = "UPPC3"
	short = "UPPC "
	long = "UPP Commando Leader"

/datum/paygrade/fres
	index = "FRE1"
	short = "FRE "
	long = "Freelancer Standard"

/datum/paygrade/frem
	index = "FRE2"
	short = "FRE "
	long = "Freelancer Medic"

/datum/paygrade/frel
	index = "FRE3"
	short = "FRE "
	long = "Freelancer Leader"

/datum/paygrade/clfs
	index = "CLF1"
	short = "CLF "
	long = "CLF Standard"

/datum/paygrade/clfm
	index = "CLF2"
	short = "CLF "
	long = "CLF Medic"

/datum/paygrade/clfl
	index = "CLF3"
	short = "CLF "
	long = "CLF Leader"

/datum/paygrade/soms
	index = "SOM1"
	short = "SOM "
	long = "SOM Standard"

/datum/paygrade/somm
	index = "SOM2"
	short = "SOM "
	long = "SOM Medic"

/datum/paygrade/somv
	index = "SOM3"
	short = "SOM "
	long = "SOM Veteran"

/datum/paygrade/soml
	index = "SOM4"
	short = "SOM "
	long = "SOM Leader"

/datum/paygrade/merch
	index = "MRC1"
	short = "MERC "
	long = "MERC Heavy"

/datum/paygrade/mercm
	index = "MRC2"
	short = "MERC "
	long = "MERC Miner"

/datum/paygrade/merce
	index = "MRC3"
	short = "MERC "
	long = "MERC Engineer"

GLOBAL_LIST_EMPTY(paygrades_marine)
GLOBAL_LIST_EMPTY(paygrades_officer)
GLOBAL_LIST_EMPTY(paygrades_enlisted)

//Just marines
#define ALL_MARINE_ACCESS list(ACCESS_IFF_MARINE, ACCESS_MARINE_CAPTAIN, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_BRIG, ACCESS_MARINE_ARMORY, ACCESS_MARINE_WO, ACCESS_MARINE_CMO, ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_ENGPREP,ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_SPECPREP, ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_PILOT, ACCESS_MARINE_TANK, ACCESS_CIVILIAN_ENGINEERING)

//Literally everything
#define ALL_ACCESS list(ACCESS_IFF_MARINE, ACCESS_MARINE_CAPTAIN, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_BRIG, ACCESS_MARINE_ARMORY, ACCESS_MARINE_WO, ACCESS_MARINE_CMO, ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_ENGPREP,ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_SPECPREP, ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_PILOT, ACCESS_MARINE_TANK, ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS, ACCESS_NT_PMC_GREEN, ACCESS_NT_PMC_ORANGE, ACCESS_NT_PMC_RED, ACCESS_NT_PMC_BLACK, ACCESS_NT_PMC_WHITE, ACCESS_NT_CORPORATE, ACCESS_ILLEGAL_PIRATE, ACCESS_IFF_PMC)

//Removes PMC and Marine IFF
#define ALL_ANTAGONIST_ACCESS list(ACCESS_MARINE_CAPTAIN, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_BRIG, ACCESS_MARINE_ARMORY, ACCESS_MARINE_WO, ACCESS_MARINE_CMO, ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_ENGPREP,ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_SPECPREP, ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_PILOT, ACCESS_MARINE_TANK, ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS, ACCESS_NT_PMC_GREEN, ACCESS_NT_PMC_ORANGE, ACCESS_NT_PMC_RED, ACCESS_NT_PMC_BLACK, ACCESS_NT_PMC_WHITE, ACCESS_NT_CORPORATE, ACCESS_ILLEGAL_PIRATE)
