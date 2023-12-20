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

/proc/get_region_accesses(code)
	switch(code)
		if(0)
			return ALL_ACCESS
		if(1)
			return list(ACCESS_MARINE_CAPTAIN, ACCESS_MARINE_COMMANDER, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_PILOT, ACCESS_MARINE_MECH, ACCESS_MARINE_BRIDGE)//command
		if(2)
			return list(ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_REMOTEBUILD)//engineering and maintenance
		if(3)
			return list(ACCESS_MARINE_CMO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_RESEARCH)//medbay
		if(4)
			return list(ACCESS_MARINE_RO, ACCESS_MARINE_CARGO)//req
		if(5)
			return list(ACCESS_MARINE_WO, ACCESS_MARINE_ARMORY, ACCESS_MARINE_BRIG)//security
		if(6)
			return list(ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_ENGPREP, ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_LEADER)//spess mahreens
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
		if(ACCESS_MARINE_MECH)
			return "Mech"
		if(ACCESS_CIVILIAN_RESEARCH)
			return "Civilian Research"
		if(ACCESS_CIVILIAN_LOGISTICS)
			return "Civilian Command"
		if(ACCESS_CIVILIAN_ENGINEERING)
			return "Civilian Engineering"
		if(ACCESS_CIVILIAN_PUBLIC)
			return "Civilian"

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
			. = size ? "Dr." : "Doctor"
		if("PROF")
			. = size ? "Prof." : "Professor"
		if("RES")
			. = size ? "RES" : "Medical Resident"
		if("MD")
			. = size ? "MD" : "Medical Doctor"
		if("CHO")
			. = size ? "CHO" : "Chief Health Officer"
		if("CMO")
			. = size ? "CMO" : "Chief Medical Officer"
		if("CMN")
			. = size ? "CMN" : "Crewman"
		if("PMC1")
			. = size ? "PMC" : "PM Contractor"
		if("PMC2")
			. = size ? "PMSC" : "PM Senior Contractor"
		if("PMC3")
			. = size ? "PMSC" : "PM Senior Contractor"
		if("PMC4")
			. = size ? "PMTL" : "PM Team Leader"
		if("PMCDS")
			. = size ? "APS" : "Assets Protection Specialist"
		if("PMCDSL")
			. = size ? "APTL" : "Assets Protection Team Leader"
		if("NT1")
			. = size ? "INT" : "Corporate Intern"
		if("NT2")
			. = size ? "ASSOC" : "Corporate Associate"
		if("NT3")
			. = size ? "PTNR" : "Corporate Partner"
		if("NT4")
			. = size ? "ANLST" : "Corporate Analyst"
		if("NT5")
			. = size ? "SPVR" : "Corporate Supervisor"
		if("E1")
			. = size ? "PVT" : "Private"
		if("E2")
			. = size ? "PFC" : "Private First Class"
		if("E3")
			. = size ? "LCPL" : "Lance Corporal"
		if("E3E")
			. = size ? "SCPL" : "Section Corporal" //Anachronistic if we're going by common US ranks, above E3 but below E4.
		if("E4")
			. = size ? "CPL" : "Corporal"
		if("E5")
			. = size ? "SGT" : "Sergeant"
		if("E6")
			. = size ? "SSGT" : "Staff Sergeant"
		if("E7")
			. = size ? "GYSGT" : "Gunnery Sergeant"
		if("E8")
			. = size ? "MSGT" : "Master Sergeant"
		if("E8E")
			. = size ? "FSGT" : "First Sergeant"
		if("E9")
			. = size ? "SGM" : "Sergeant Major"
		if("E9E")
			. = size ? "CSGM" : "Command Sergeant Major"
		if("O1")
			. = size ? "ENS" : "Ensign"
		if("O2")
			. = size ? "LTJG" : "Lieutenant Junior Grade"
		if("O3")
			. = size ? "LT" : "Lieutenant"
		if("O4")
			. = size ? "LCDR" : "Lieutenant Commander"
		if("O5")
			. = size ? "CDR" : "Commander"
		if("O6")
			. = size ? "CPT" : "Captain"
		if("O7")
			. = size ? "COMM" : "Commodore"
		if("O8")
			. = size ? "RADM" : "Rear Admiral"
		if("O9")
			. = size ? "VADM" : "Vice Admiral"
		if("10")
			. = size ? "ADM" : "Admiral"
		if("11")
			. = size ? "FADM" : "Fleet Admiral"
		if("WO")
			. = size ? "WO" : "Warrant Officer"
		if("CWO")
			. = size ? "CWO" : "Chief Warrant Officer"
		if("PO3")
			. = size ? "PO3" : "Petty Officer Third Class"
		if("PO2")
			. = size ? "PO2" : "Petty Officer Second Class"
		if("PO1")
			. = size ? "PO1" : "Petty Officer First Class"
		if("CPO")
			. = size ? "CPO" : "Chief Petty Officer"
		if("MO4")
			. = size ? "MAJ" : "Major"
		if("MO5")
			. = size ? "LtCol" : "Lieutenant Colonel"
		if("UPP1")
			. = size ? "UGNR" : "USL Gunner"
		if("UPP2")
			. = size ? "USUR" : "USL Surgeon"
		if("UPP3")
			. = size ? "UPOM" : "USL Powder Monkey"
		if("UPP4")
			. = size ? "UCPT" : "USL Captain"
		if("UPP5")
			. = size ? "UQM" : "USL Quartermaster"
		if("UPP6")
			. = size ? "USSGT" : "USL Staff Sergeant"
		if("UPP7")
			. = size ? "UENS" : "USL Ensign"
		if("UPP8")
			. = size ? "ULT" : "USL Lieutenant"
		if("UPP9")
			. = size ? "ULCDR" : "USL Lieutenant Commander"
		if("UPP10")
			. = size ? "UCDR" : "USL Commander"
		if("UPP11")
			. = size ? "UADM" : "USL Admiral"
		if("UPPC1")
			. = size ? "UEPM" : "USL Elite Powder Monkey"
		if("UPPC2")
			. = size ? "UESUR" : "USL Elite Surgeon"
		if("UPPC3")
			. = size ? "UECPT" : "USL Elite Captain"
		if("FRE1")
			. = size ? "FRE" : "Freelancer Standard"
		if("FRE2")
			. = size ? "FRE" : "Freelancer Medic"
		if("FRE3")
			. = size ? "FRE" : "Freelancer Veteran"
		if("FRE4")
			. = size ? "FRE" : "Freelancer Leader"
		if("CLF1")
			. = size ? "CLF" : "CLF Standard"
		if("CLF2")
			. = size ? "CLF" : "CLF Medic"
		if("CLF3")
			. = size ? "CLF" : "CLF Leader"
		if("SOM_E1")
			. = size ? "PTE" : "SOM Private"
		if("SOM_E2")
			. = size ? "PFC" : "SOM Private First Class"
		if("SOM_E3")
			. = size ? "LCP" : "SOM Lance Corporal"
		if("SOM_E4")
			. = size ? "CPL" : "SOM Corporal"
		if("SOM_E5")
			. = size ? "CFC" : "SOM Corporal First Class"
		if("SOM_S1")
			. = size ? "3SG" : "SOM Third Sergeant"
		if("SOM_S2")
			. = size ? "2SG" : "SOM Second Sergeant"
		if("SOM_S3")
			. = size ? "1SG" : "SOM First Sergeant"
		if("SOM_S4")
			. = size ? "SSG" : "SOM Staff Sergeant"
		if("SOM_S5")
			. = size ? "MSG" : "SOM Master Sergeant"
		if("SOM_W1")
			. = size ? "3WO" : "SOM Third Warrant Officer"
		if("SOM_W2")
			. = size ? "2WO" : "SOM Second Warrant Officer"
		if("SOM_W3")
			. = size ? "1WWO" : "SOM First Warrant Officer"
		if("SOM_W4")
			. = size ? "MWO" : "SOM Master Warrant Officer"
		if("SOM_W5")
			. = size ? "SWO" : "SOM Senior Warrant Officer"
		if("SOM_W6")
			. = size ? "CWO" : "SOM Chief Warrant Officer"
		if("SOM_O1")
			. = size ? "2LT" : "SOM Second Lieutenant"
		if("SOM_O2")
			. = size ? "LTA" : "SOM Lieutenant"
		if("SOM_O3")
			. = size ? "CPT" : "SOM Captain"
		if("SOM_O4")
			. = size ? "MAJ" : "SOM Major"
		if("SOM_O5")
			. = size ? "LTC" : "SOM Lieutenant-Colonel"
		if("SOM_O6")
			. = size ? "SLTC" : "SOM Senior Lieutenant-Colonel"
		if("SOM_O7")
			. = size ? "COL" : "SOM Colonel"
		if("SOM_G1")
			. = size ? "BG" : "SOM Brigadier-General"
		if("SOM_G2")
			. = size ? "MG" : "SOM Major-General"
		if("SOM_G3")
			. = size ? "LG" : "SOM Lieutenant-General"
		if("SOM_G4")
			. = size ? "GEN" : "SOM General"
		if("SOM_A1")
			. = size ? "RADM(1)" : "SOM Rear-Admiral"
		if("SOM_A2")
			. = size ? "RADM(2)" : "SOM Rear-Admiral"
		if("SOM_A3")
			. = size ? "VADM" : "SOM Vice-Admiral"
		if("SOM_A4")
			. = size ? "ADM" : "SOM Admiral"
		if("ICC1")
			. = size ? "ICC" : "ICC Standard"
		if("ICC2")
			. = size ? "ICC" : "ICC Medic"
		if("ICC3")
			. = size ? "ICCG" : "ICC Guard"
		if("ICC4")
			. = size ? "ICCL" : "ICC Leader"
		if("MRC1")
			. = size ? "MERC" : "MERC Heavy"
		if("MRC2")
			. = size ? "MERC" : "MERC Miner"
		if("MRC3")
			. = size ? "MERC" : "MERC Engineer"
		if("VM")
			. = size ? "VAT" : "VatGrown Marine"
		if("Mk.III")
			. = size ? "Mk.III" : "Mark III"
		if("Mk.II")
			. = size ? "Mk.II" : "Mark II"
		if("Mk.I")
			. = size ? "Mk.I" : "Mark I"
		else
			. = paygrade //custom paygrade
