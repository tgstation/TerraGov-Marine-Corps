/obj/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(check_access())
		return TRUE

	if(issilicon(M))
		return TRUE //Silicons can access whatever they want

	if(IsAdminGhost(M))
		return TRUE

	var/obj/item/card/id/I = M.get_idcard() //if they are holding or wearing a card that has access, that works.
	if(check_access(I))
		return TRUE


/obj/proc/check_access(obj/item/card/id/ID)
	if(!LAZYLEN(req_access) && !LAZYLEN(req_one_access))
		return TRUE

	if(!istype(ID))
		return FALSE

	for(var/i in req_access)
		if(!(i in ID.access))
			return FALSE

	if(LAZYLEN(req_one_access))
		for(var/i in req_one_access)
			if(!(i in ID.access))
				continue
			return TRUE
		return FALSE

	return TRUE


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


/proc/get_region_accesses(code)
	switch(code)
		if(0)
			return ALL_ACCESS
		if(1)
			return list(ACCESS_MARINE_CAPTAIN, ACCESS_MARINE_COMMANDER, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_PILOT, ACCESS_MARINE_TANK, ACCESS_MARINE_BRIDGE)//command
		if(2)
			return list(ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_REMOTEBUILD)//engineering and maintenance
		if(3)
			return list(ACCESS_MARINE_CMO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_RESEARCH)//medbay
		if(4)
			return list(ACCESS_MARINE_RO, ACCESS_MARINE_CARGO)//req
		if(5)
			return list(ACCESS_MARINE_WO, ACCESS_MARINE_ARMORY, ACCESS_MARINE_BRIG)//security
		if(6)
			return list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_ENGPREP, ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_SPECPREP)//spess mahreens
		if(7)
			return list(ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA)//squads
		if(8)
			return list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_LOGISTICS, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING)//Civilian


/proc/get_region_accesses_name(code)
	switch(code)
		if(0)
			return "All"
		if(1)
			return "[SSmapping.configs[SHIP_MAP].map_name] Command"//command
		if(2)
			return "[SSmapping.configs[SHIP_MAP].map_name] Engineering"//engineering
		if(3)
			return "[SSmapping.configs[SHIP_MAP].map_name] Medical"//medbay
		if(4)
			return "[SSmapping.configs[SHIP_MAP].map_name] Requisitions"//requisitions
		if(5)
			return "[SSmapping.configs[SHIP_MAP].map_name] Security"//security
		if(6)
			return "[SSmapping.configs[SHIP_MAP].map_name] Marine"//marine prep
		if(7)
			return "Squad Access"//squads
		if(8)
			return "Civilian"//Civilian


/proc/get_access_desc(A)
	switch(A)
		if(ACCESS_MARINE_WO)
			return "WO's Office"
		if(ACCESS_MARINE_BRIG)
			return "Brig"
		if(ACCESS_MARINE_ARMORY)
			return "Armory"
		if(ACCESS_MARINE_CMO)
			return "CMO's Office"
		if(ACCESS_MARINE_MEDBAY)
			return "Medbay"
		if(ACCESS_MARINE_CHEMISTRY)
			return "Chemistry"
		if(ACCESS_MARINE_RESEARCH)
			return "Research"
		if(ACCESS_MARINE_CE)
			return "CE's Office"
		if(ACCESS_MARINE_ENGINEERING)
			return "Engineering"
		if(ACCESS_MARINE_REMOTEBUILD)
			return "FOB Construction Drone"
		if(ACCESS_MARINE_CAPTAIN)
			return "Captain's Quarters"
		if(ACCESS_MARINE_COMMANDER)
			return "Field Commander's Quarters"
		if(ACCESS_MARINE_LOGISTICS)
			return "Logistics"
		if(ACCESS_MARINE_BRIDGE)
			return "Bridge"
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
		if(ACCESS_MARINE_RO)
			return "RO's Office"
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
			return "Crew Identification"

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


/proc/get_access_job_name(obj/item/card/id/ID)
	var/first_matched
	for(var/i in SSjob.occupations)
		var/datum/job/J = i
		if(J.title == ID.rank)
			return J.title
		if(!first_matched && (J.access ~= ID.access))
			first_matched = J.title
	if(first_matched)
		return first_matched
	else if(length(ID.access))
		return "Custom [ADMIN_VV(ID.access)]"
	else
		return "None"


/proc/get_paygrades(paygrade, size, gender)
	if(!paygrade)
		return
	switch(paygrade)
		if("C")
			. = size ? "" : "Civilian"
		if("CD")
			. = size ? "Dr. " : "Doctor"
		if("CCMO")
			. = size ? "Prof. " : "Professor"
		if("CMN")
			. = size ? "CMN" : "Crewman"
		if("PMC1")
			. = size ? "PMC " : "PM Contractor"
		if("PMC2")
			. = size ? "PMSC " : "PM Senior Contractor"
		if("PMC3")
			. = size ? "PMSC " : "PM Senior Contractor"
		if("PMC4")
			. = size ? "PMTL " : "PM Team Leader"
		if("PMCDS")
			. = size ? "APS " : "Assets Protection Specialist"
		if("PMCDSL")
			. = size ? "APTL " : "Assets Protection Team Leader"
		if("NT")
			. = size ? (gender == FEMALE ? "Ms. " : "Mr. ") : "Junior Executive"
		if("E1")
			. = size ? "IRREG " : "Irregular"
		if("E2")
			. = size ? "REG " : "Regular"
		if("E3")
			. = size ? "STD " : "Standard"
		if("E3E")
			. = size ? "VET " : "Veteran" //Anachronistic if we're going by common US ranks, above E3 but below E4.
		if("E4")
			. = size ? "ADT " : "Adept"
		if("E5")
			. = size ? "SSD " : "Seasoned"
		if("E6")
			. = size ? "VET " : "Veteran"
		if("E7")
			. = size ? "CHVET " : "Chief Veteran"
		if("E8")
			. = size ? "CHVET " : "Chief Veteran"
		if("E8E")
			. = size ? "FSGT " : "First Sergeant"
		if("E9")
			. = size ? "SGM " : "Sergeant Major"
		if("E9E")
			. = size ? "CSGM " : "Command Sergeant Major"
		if("O1")
			. = size ? "CAMAN " : "Chief Airman"
		if("O2")
			. = size ? "ACE " : "Ace"
		if("O3")
			. = size ? "EXPT " : "Expert"
		if("O4")
			. = size ? "CHVET " : "Chief Veteran"
		if("O5")
			. = size ? "CHVET " : "Chief Veteran"
		if("O6")
			. = size ? "CHF " : "Chief"
		if("O7")
			. = size ? "CHF " : "Chief"
		if("O8")
			. = size ? "CFCPT " : "Chief Captain"
		if("O9")
			. = size ? "VADM " : "Vice Admiral"
		if("10")
			. = size ? "ADM " : "Admiral"
		if("11")
			. = size ? "FADM " : "Fleet Admiral"
		if("WO")
			. = size ? "ARMAN " : "Airman"
		if("CWO")
			. = size ? "VAMAN " : "Veteran Airman"
		if("PO3")
			. = size ? "ACE " : "Ace"
		if("PO2")
			. = size ? "EXPT " : "Expert"
		if("PO1")
			. = size ? "EXPT " : "Expert"
		if("CPO")
			. = size ? "CHVET " : "Chief Veteran"
		if("MO4")
			. = size ? "EXPT " : "Expert"
		if("MO5")
			. = size ? "ETCHF " : "Expert Chief"
		if("UPP1")
			. = size ? "UGNR " : "USL Gunner"
		if("UPP2")
			. = size ? "USUR " : "USL Surgeon"
		if("UPP3")
			. = size ? "UPOM " : "USL Powder Monkey"
		if("UPP4")
			. = size ? "UCPT " : "USL Captain"
		if("UPP5")
			. = size ? "UQM " : "USL Quartermaster"
		if("UPP6")
			. = size ? "USSGT " : "USL Staff Sergeant"
		if("UPP7")
			. = size ? "UENS " : "USL Ensign"
		if("UPP8")
			. = size ? "ULT " : "USL Lieutenant"
		if("UPP9")
			. = size ? "ULCDR " : "USL Lieutenant Commander"
		if("UPP10")
			. = size ? "UCDR " : "USL Commander"
		if("UPP11")
			. = size ? "UADM " : "USL Admiral"
		if("UPPC1")
			. = size ? "UEPM " : "USL Elite Powder Monkey"
		if("UPPC2")
			. = size ? "UESUR " : "USL Elite Surgeon"
		if("UPPC3")
			. = size ? "UECPT " : "USL Elite Captain"
		if("FRE1")
			. = size ? "FRE " : "Freelancer Standard"
		if("FRE2")
			. = size ? "FRE " : "Freelancer Medic"
		if("FRE3")
			. = size ? "FRE " : "Freelancer Leader"
		if("CLF1")
			. = size ? "CLF " : "CLF Standard"
		if("CLF2")
			. = size ? "CLF " : "CLF Medic"
		if("CLF3")
			. = size ? "CLF " : "CLF Leader"
		if("SOM1")
			. = size ? "SGT " : "SFOC-T Navy Operator"
		if("SOM2")
			. = size ? "SSGT " : "SFOC-T Navy Intimidator"
		if("SOM3")
			. = size ? "FSGT " : "SFOC-T Navy Dominator"
		if("SOM4")
			. = size ? "MSGT " : "SFOC-T Navy Elite"
		if("MRC1")
			. = size ? "MERC " : "MERC Heavy"
		if("MRC2")
			. = size ? "MERC " : "MERC Miner"
		if("MRC3")
			. = size ? "MERC " : "MERC Engineer"
		if("VM")
			. = size ? "VAT " : "VatGrown Irregular"
		if("Mk.III")
			. = size ? "Mk.III " : "Mark III"
		if("Mk.II")
			. = size ? "Mk.II " : "Mark II"
		if("Mk.I")
			. = size ? "Mk.I " : "Mark I"
		else
			. = paygrade + " " //custom paygrade
