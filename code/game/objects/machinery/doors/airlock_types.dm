
/obj/machinery/door/airlock/secure
	name = "\improper Secure Airlock"
	icon = 'icons/obj/doors/Door_secure.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_com
	openspeed = 34

/obj/machinery/door/airlock/command
	name = "\improper Command Airlock"
	icon = 'icons/obj/doors/mainship/comdoor.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_com

/obj/machinery/door/airlock/command/thunderdome
	name = "\improper Thunderdome Administration"
	icon = 'icons/obj/doors/mainship/comdoor.dmi'
	req_access = list(ACCESS_CIVILIAN_ENGINEERING)

/obj/machinery/door/airlock/security
	name = "\improper Security Airlock"
	icon = 'icons/obj/doors/Doorsec.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_sec

/obj/machinery/door/airlock/engineering
	name = "\improper Engineering Airlock"
	icon = 'icons/obj/doors/mainship/engidoor.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_eng

/obj/machinery/door/airlock/engineering/evac
	icon = 'icons/obj/doors/mainship/pod_doors.dmi'
	icon_state = "door_locked"

/obj/machinery/door/airlock/medical
	name = "\improper Medical Airlock"
	icon = 'icons/obj/doors/mainship/medidoor.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_med

/obj/machinery/door/airlock/maintenance
	name = "\improper Maintenance Hatch"
	icon = 'icons/obj/doors/mainship/maintdoor.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_mai

/obj/machinery/door/airlock/external
	name = "\improper External Airlock"
	icon = 'icons/obj/doors/Doorext.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_ext

/obj/machinery/door/airlock/external/brig
	req_access = list(ACCESS_MARINE_BRIG)

/obj/machinery/door/airlock/glass
	name = "\improper Glass Airlock"
	icon = 'icons/obj/doors/mainship/personaldoor.dmi'
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/centcom
	name = "\improper Airlock"
	icon = 'icons/obj/doors/mainship/securedoor.dmi'
	opacity = TRUE

/obj/machinery/door/airlock/vault
	name = "\improper Vault"
	icon = 'icons/obj/doors/vault.dmi'
	opacity = TRUE
	assembly_type = /obj/structure/door_assembly/door_assembly_highsecurity //Until somebody makes better sprites.

/obj/machinery/door/airlock/freezer
	name = "\improper Freezer Airlock"
	icon = 'icons/obj/doors/mainship/personaldoor.dmi'
	opacity = TRUE
	assembly_type = /obj/structure/door_assembly/door_assembly_fre

/obj/machinery/door/airlock/hatch
	name = "\improper Airtight Hatch"
	icon = 'icons/obj/doors/mainship/securedoor.dmi'
	opacity = TRUE
	assembly_type = /obj/structure/door_assembly/door_assembly_hatch

/obj/machinery/door/airlock/hatch/engineering
	req_access = list(ACCESS_MARINE_ENGINEERING)

/obj/machinery/door/airlock/maintenance_hatch
	name = "\improper Maintenance Hatch"
	icon = 'icons/obj/doors/mainship/maintdoor.dmi'
	opacity = TRUE
	assembly_type = /obj/structure/door_assembly/door_assembly_mhatch

/obj/machinery/door/airlock/glass_command
	name = "\improper Command Airlock"
	icon = 'icons/obj/doors/mainship/comdoor.dmi'
	opacity = FALSE
	assembly_type = /obj/structure/door_assembly/door_assembly_com
	glass = TRUE

/obj/machinery/door/airlock/glass_engineering
	name = "\improper Engineering Airlock"
	icon = 'icons/obj/doors/mainship/engidoor.dmi'
	opacity = FALSE
	assembly_type = /obj/structure/door_assembly/door_assembly_eng
	glass = TRUE

/obj/machinery/door/airlock/glass_security
	name = "\improper Security Airlock"
	icon = 'icons/obj/doors/Doorsec.dmi'
	opacity = FALSE
	assembly_type = /obj/structure/door_assembly/door_assembly_sec
	glass = TRUE

/obj/machinery/door/airlock/glass_security/locked
	icon_state = "door_locked"
	locked = TRUE

/obj/machinery/door/airlock/glass_medical
	name = "\improper Medical Airlock"
	icon = 'icons/obj/doors/Doormedglass.dmi'
	opacity = FALSE
	assembly_type = /obj/structure/door_assembly/door_assembly_med
	glass = TRUE

/obj/machinery/door/airlock/mining
	name = "\improper Mining Airlock"
	icon = 'icons/obj/doors/Doormining.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_min

/obj/machinery/door/airlock/marine
	name = "\improper Airlock"
	icon = 'icons/obj/doors/door_marines.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_min

/obj/machinery/door/airlock/atmos
	name = "\improper Atmospherics Airlock"
	icon = 'icons/obj/doors/Dooratmo.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_atmo

/obj/machinery/door/airlock/research
	name = "\improper Research Airlock"
	icon = 'icons/obj/doors/Doorresearch.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_research

/obj/machinery/door/airlock/glass_research
	name = "\improper Research Airlock"
	icon = 'icons/obj/doors/Doorresearchglass.dmi'
	opacity = FALSE
	assembly_type = /obj/structure/door_assembly/door_assembly_research
	glass = TRUE

/obj/machinery/door/airlock/glass_mining
	name = "\improper Mining Airlock"
	icon = 'icons/obj/doors/Doorminingglass.dmi'
	opacity = FALSE
	assembly_type = /obj/structure/door_assembly/door_assembly_min
	glass = TRUE

/obj/machinery/door/airlock/glass_atmos
	name = "\improper Atmospherics Airlock"
	icon = 'icons/obj/doors/Dooratmoglass.dmi'
	opacity = FALSE
	assembly_type = /obj/structure/door_assembly/door_assembly_atmo
	glass = TRUE

/obj/machinery/door/airlock/gold
	name = "\improper Gold Airlock"
	icon = 'icons/obj/doors/Doorgold.dmi'
	mineral = "gold"

/obj/machinery/door/airlock/silver
	name = "\improper Silver Airlock"
	icon = 'icons/obj/doors/Doorsilver.dmi'
	mineral = "silver"

/obj/machinery/door/airlock/diamond
	name = "\improper Diamond Airlock"
	icon = 'icons/obj/doors/Doordiamond.dmi'
	mineral = "diamond"

/obj/machinery/door/airlock/uranium
	name = "\improper Uranium Airlock"
	desc = "And they said I was crazy."
	icon = 'icons/obj/doors/Dooruranium.dmi'
	mineral = "uranium"


/obj/machinery/door/airlock/phoron
	name = "\improper Phoron Airlock"
	desc = "No way this can end badly."
	icon = 'icons/obj/doors/Doorphoron.dmi'
	mineral = "phoron"



/obj/machinery/door/airlock/sandstone
	name = "\improper Sandstone Airlock"
	icon = 'icons/obj/doors/Doorsand.dmi'
	mineral = "sandstone"

/obj/machinery/door/airlock/science
	name = "\improper Research Airlock"
	icon = 'icons/obj/doors/Doorsci.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_science

/obj/machinery/door/airlock/glass_science
	name = "\improper Research Airlock"
	icon = 'icons/obj/doors/Doorsciglass.dmi'
	opacity = FALSE
	assembly_type = /obj/structure/door_assembly/door_assembly_science
	glass = TRUE

/obj/machinery/door/airlock/highsecurity
	name = "\improper High Tech Security Airlock"
	icon = 'icons/obj/doors/hightechsecurity.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_highsecurity





//MARINE SHIP AIRLOCKS

/obj/machinery/door/airlock/mainship
	name = "\improper Airlock"
	icon = 'icons/obj/doors/mainship/comdoor.dmi' //Tiles with is here FOR SAFETY PURPOSES
	openspeed = 4 //shorter open animation.

/obj/machinery/door/airlock/mainship/security
	name = "\improper Security Airlock"
	icon = 'icons/obj/doors/mainship/secdoor.dmi'
	req_access = list(ACCESS_MARINE_BRIG)

/obj/machinery/door/airlock/mainship/security/free_access
	req_access = null

/obj/machinery/door/airlock/mainship/security/locked
	icon_state = "door_locked"
	locked = TRUE

/obj/machinery/door/airlock/mainship/security/locked/free_access
	req_access = null

/obj/machinery/door/airlock/mainship/security/checkpoint
	name = "\improper Security Checkpoint"

/obj/machinery/door/airlock/mainship/security/CMA
	name = "\improper Chief Master at Arms's Bunks"

/obj/machinery/door/airlock/mainship/security/glass
	name = "\improper Security Airlock"
	icon = 'icons/obj/doors/mainship/secdoor_glass.dmi'
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/mainship/security/glass/free_access
	req_access = null

/obj/machinery/door/airlock/mainship/security/glass/office
	name = "\improper Security Office"

/obj/machinery/door/airlock/mainship/security/glass/cells
	name = "\improper Security Cells"

/obj/machinery/door/airlock/mainship/security/glass/CMA
	name = "\improper Chief Master at Arms's Office"

/obj/machinery/door/airlock/mainship/command
	name = "\improper Command Airlock"
	icon = 'icons/obj/doors/mainship/comdoor.dmi'
	req_access = list(ACCESS_MARINE_BRIDGE)

/obj/machinery/door/airlock/mainship/command/free_access
	req_access = null

/obj/machinery/door/airlock/mainship/command/locked
	icon_state = "door_locked"
	locked = TRUE

/obj/machinery/door/airlock/mainship/command/locked/free_access
	req_access = null

/obj/machinery/door/airlock/mainship/command/open
	icon_state = "door_open"
	density = FALSE
	opacity = FALSE

/obj/machinery/door/airlock/mainship/command/open/free_access
	req_access = null

/obj/machinery/door/airlock/mainship/command/canterbury //For wall-smoothing
	req_access = list(ACCESS_MARINE_DROPSHIP)

/obj/machinery/door/airlock/mainship/command/cic
	name = "\improper Combat Information Center"

/obj/machinery/door/airlock/mainship/command/brief
	name = "\improper Briefing Room"

/obj/machinery/door/airlock/mainship/command/CPToffice
	name = "\improper Captain's Office"

/obj/machinery/door/airlock/mainship/command/CPTstudy
	name = "\improper Captain's Study"
	req_access = list(ACCESS_MARINE_CAPTAIN)

/obj/machinery/door/airlock/mainship/command/CPTmess
	name = "\improper Captain's Mess"

/obj/machinery/door/airlock/mainship/command/FCDRoffice
	name = "\improper Field Commander's Office"

/obj/machinery/door/airlock/mainship/command/FCDRquarters
	name = "\improper FCDR's Quarters"

/obj/machinery/door/airlock/mainship/command/officer
	name = "\improper Officer's Quarters"

/obj/machinery/door/airlock/mainship/secure
	name = "\improper Secure Airlock"
	icon = 'icons/obj/doors/mainship/securedoor.dmi'
	req_access = list(ACCESS_MARINE_BRIDGE)

/obj/machinery/door/airlock/mainship/secure/free_access
	req_access = null

/obj/machinery/door/airlock/mainship/secure/locked
	icon_state = "door_locked"
	locked = TRUE

/obj/machinery/door/airlock/mainship/secure/locked/free_access
	req_access = null

/obj/machinery/door/airlock/mainship/secure/open
	icon_state = "door_open"
	density = FALSE
	opacity = FALSE

/obj/machinery/door/airlock/mainship/secure/open/free_access
	req_access = null

/obj/machinery/door/airlock/mainship/secure/tcomms
	name = "\improper Telecommunications"

/obj/machinery/door/airlock/mainship/secure/evac
	name = "\improper Evacuation Airlock"

/obj/machinery/door/airlock/mainship/secure/evac/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_EVACUATION_STARTED, PROC_REF(force_open))

///Force open that door
/obj/machinery/door/airlock/mainship/secure/proc/force_open()
	SIGNAL_HANDLER
	unlock(TRUE)
	INVOKE_ASYNC(src, PROC_REF(open), TRUE)
	lock(TRUE)

/obj/machinery/door/airlock/mainship/ai
	name = "\improper AI Core"
	icon = 'icons/obj/doors/mainship/personaldoor.dmi'
	req_access = list(ACCESS_MARINE_BRIDGE)

/obj/machinery/door/airlock/mainship/ai/glass
	name = "\improper AI Core"
	icon = 'icons/obj/doors/Doorglass.dmi'
	opacity = FALSE
	glass = TRUE



/obj/machinery/door/airlock/mainship/evacuation
	name = "\improper Evacuation Airlock"
	icon = 'icons/obj/doors/mainship/securedoor.dmi'


/obj/machinery/door/airlock/mainship/maint
	name = "\improper Maintenance Hatch"
	icon = 'icons/obj/doors/mainship/maintdoor.dmi'
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_ENGINEERING)

/obj/machinery/door/airlock/mainship/maint/free_access

/obj/machinery/door/airlock/mainship/maint/core
	name = "\improper Core Hatch"

/obj/machinery/door/airlock/mainship/maint/hangar
	name = "\improper Hangar Control Room"
	req_one_access = list(ACCESS_MARINE_DROPSHIP)

/obj/machinery/door/airlock/mainship/engineering
	name = "\improper Engineering Airlock"
	icon = 'icons/obj/doors/mainship/engidoor.dmi'
	opacity = FALSE
	glass = TRUE
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_ENGINEERING)

/obj/machinery/door/airlock/mainship/engineering/glass
	name = "\improper Engineering Glass Airlock"
	icon = 'icons/obj/doors/mainship/engidoor_glass.dmi'

/obj/machinery/door/airlock/mainship/engineering/free_access
	req_one_access = null

/obj/machinery/door/airlock/mainship/engineering/storage
	name = "\improper Engineering Storage"
	icon = 'icons/obj/doors/mainship/maintdoor.dmi'

/obj/machinery/door/airlock/mainship/engineering/disposals
	name = "\improper Disposals"

/obj/machinery/door/airlock/mainship/engineering/workshop
	name = "\improper Engineering Workshop"

/obj/machinery/door/airlock/mainship/engineering/engine
	name = "\improper Engineering Engine Monitoring"

/obj/machinery/door/airlock/mainship/engineering/atmos
	name = "\improper Atmospherics Wing"

/obj/machinery/door/airlock/mainship/engineering/CSEoffice
	name = "\improper Chief Ship Engineer's Office"
	req_access = list(ACCESS_MARINE_CE)

/obj/machinery/door/airlock/mainship/engineering/server_room
	name = "\improper Server Room"
	req_one_access = null

/obj/machinery/door/airlock/mainship/medical
	name = "\improper Medical Airlock"
	icon = 'icons/obj/doors/mainship/medidoor.dmi'
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_BRIDGE)


/obj/machinery/door/airlock/mainship/medical/free_access
	req_one_access = list()

/obj/machinery/door/airlock/mainship/medical/morgue
	name = "\improper Morgue"
	req_access = list(ACCESS_MARINE_CHEMISTRY)

/obj/machinery/door/airlock/mainship/medical/or
	name = "\improper Operating Theatre"

/obj/machinery/door/airlock/mainship/medical/or/or1
	name = "\improper Operating Theatre 1"
/obj/machinery/door/airlock/mainship/medical/or/or2
	name = "\improper Operating Theatre 2"

/obj/machinery/door/airlock/mainship/medical/or/or3
	name = "\improper Operating Theatre 3"

/obj/machinery/door/airlock/mainship/medical/or/or4
	name = "\improper Operating Theatre 4"

/obj/machinery/door/airlock/mainship/medical/or/free_access
	req_one_access = null

/obj/machinery/door/airlock/mainship/medical/glass
	name = "\improper Medical Airlock"
	icon = 'icons/obj/doors/mainship/medidoor_glass.dmi'
	opacity = FALSE
	glass = TRUE
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_BRIDGE)

/obj/machinery/door/airlock/mainship/medical/glass/free_access
	req_one_access = null

/obj/machinery/door/airlock/mainship/medical/glass/CMO
	name = "\improper CMO's Office"
	req_access = list(ACCESS_MARINE_CMO)

/obj/machinery/door/airlock/mainship/medical/glass/chemistry
	name = "\improper Chemistry Laboratory"
	req_access = list(ACCESS_MARINE_CHEMISTRY)

/obj/machinery/door/airlock/mainship/medical/glass/research
	req_access = list(ACCESS_MARINE_RESEARCH)

/obj/machinery/door/airlock/mainship/research
	name = "\improper Research Airlock"
	icon = 'icons/obj/doors/mainship/medidoor.dmi'
	req_access = list(ACCESS_MARINE_RESEARCH)

/obj/machinery/door/airlock/mainship/research/free_access
	req_access = null

/obj/machinery/door/airlock/mainship/research/open
	icon_state = "door_open"
	density = FALSE
	opacity = FALSE

/obj/machinery/door/airlock/mainship/research/open/free_access
	req_one_access = null

/obj/machinery/door/airlock/mainship/research/locked
	icon_state = "door_locked"
	locked = TRUE

/obj/machinery/door/airlock/mainship/research/locked/free_access
	req_one_access = null

/obj/machinery/door/airlock/mainship/research/chemistry
	name = "\improper Chemistry Laboratory"
	req_access = list(ACCESS_MARINE_CHEMISTRY)

/obj/machinery/door/airlock/mainship/research/or
	name = "\improper Experimental Operating Theatre"

/obj/machinery/door/airlock/mainship/research/pen
	name = "\improper Research Pens"

/obj/machinery/door/airlock/mainship/research/glass
	icon = 'icons/obj/doors/mainship/medidoor_glass.dmi'
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/mainship/research/glass/wing
	name = "\improper Medical Research Wing"
	id = "researchdoorext"

/obj/machinery/door/airlock/mainship/research/glass/cell
	name = "\improper Containment Cell"
	id = "Containment Cell"
	icon_state = "door_locked"
	locked = TRUE

/obj/machinery/door/airlock/mainship/research/glass/cell/cell1
	name = "\improper Containment Cell 1"
	id = "Containment Cell 1"

/obj/machinery/door/airlock/mainship/research/glass/cell/cell2
	name = "\improper Containment Cell 2"
	id = "Containment Cell 2"

/obj/machinery/door/airlock/mainship/research/glass/free_access
	req_access = null

/obj/machinery/door/airlock/mainship/generic
	name = "\improper Airlock"
	icon = 'icons/obj/doors/mainship/personaldoor.dmi'

/obj/machinery/door/airlock/mainship/generic/corporate
	name = "Corporate Liaison's Office"
	icon = 'icons/obj/doors/mainship/personaldoor.dmi'
	req_access = list(ACCESS_NT_CORPORATE)

/obj/machinery/door/airlock/mainship/generic/corporate/quarters
	name = "Corporate Liaison's Quarters"

/obj/machinery/door/airlock/mainship/generic/bathroom
	name = "\improper Bathroom"

/obj/machinery/door/airlock/mainship/generic/bathroom/toilet
	name = "\improper Toilet"

/obj/machinery/door/airlock/mainship/generic/pilot
	name = "\improper Pilot's Office"
	req_access = list(ACCESS_MARINE_PILOT)

/obj/machinery/door/airlock/mainship/generic/pilot/bunk
	name = "\improper Pilot's Bunks"

/obj/machinery/door/airlock/mainship/generic/pilot/quarters
	name = "\improper Pilot's Quarters"

/obj/machinery/door/airlock/mainship/generic/mech_pilot
	name = "\improper Mech Pilot's Office"
	req_access = list(ACCESS_MARINE_MECH)

/obj/machinery/door/airlock/mainship/generic/mech_pilot/bunk
	name = "\improper Mech Pilot's Bunks"

/obj/machinery/door/airlock/mainship/generic/ert
	name = "\improper Airlock"
	icon = 'icons/obj/doors/mainship/personaldoor.dmi'
	interaction_flags = INTERACT_MACHINE_NOSILICON //go away naughty AI

/obj/machinery/door/airlock/mainship/generic/glass
	name = "\improper Glass Airlock"
	icon = 'icons/obj/doors/mainship/personaldoor_glass.dmi'

/obj/machinery/door/airlock/mainship/marine
	name = "\improper Airlock"
	icon = 'icons/obj/doors/mainship/prepdoor.dmi'
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/mainship/marine/handle_weldingtool_overlay(removing = FALSE)
	if(!removing)
		if(dir & NORTH|SOUTH)
			add_overlay(GLOB.welding_sparks_prepdoor)
		else
			add_overlay(GLOB.welding_sparks)
	else
		if(dir & NORTH|SOUTH)
			cut_overlay(GLOB.welding_sparks_prepdoor)
		else
			cut_overlay(GLOB.welding_sparks)

/obj/machinery/door/airlock/mainship/marine/canterbury //For wallsmoothing

/obj/machinery/door/airlock/mainship/marine/general/sl
	name = "\improper Squad Leader Preparations"
	icon = 'icons/obj/doors/mainship/prepdoor.dmi'
	req_access = list(ACCESS_MARINE_LEADER)
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/mainship/marine/general/smart
	name = "\improper Smartgunner Preparations"
	icon = 'icons/obj/doors/mainship/prepdoor.dmi'
	req_access = list(ACCESS_MARINE_SMARTPREP)
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/mainship/marine/general/corps
	name = "\improper Corpsman Preparations"
	icon = 'icons/obj/doors/mainship/prepdoor.dmi'
	req_access = list(ACCESS_MARINE_MEDPREP)
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/mainship/marine/general/engi
	name = "\improper Engineer Preparations"
	icon = 'icons/obj/doors/mainship/prepdoor.dmi'
	req_access = list(ACCESS_MARINE_ENGPREP)
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/mainship/marine/requisitions
	name = "\improper Requisitions Bay"
	icon = 'icons/obj/doors/mainship/prepdoor.dmi'
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO)
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/mainship/marine/requisitions/lift
	name = "\improper ASRS Lift"
	req_one_access = null

/obj/machinery/door/airlock/mainship/marine/alpha
	name = "\improper Alpha Squad Preparations"
	icon = 'icons/obj/doors/mainship/prepdoor_alpha.dmi'
	req_access = list(ACCESS_MARINE_PREP)
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_ALPHA)
	opacity = FALSE
	glass = TRUE
	dir = SOUTH

/obj/machinery/door/airlock/mainship/marine/alpha/sl
	name = "\improper Alpha Squad Leader Preparations"
	req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_ALPHA)
	req_one_access = null

/obj/machinery/door/airlock/mainship/marine/alpha/engineer
	name = "\improper Alpha Squad Engineer Preparations"
	req_access = list(ACCESS_MARINE_ENGPREP, ACCESS_MARINE_ALPHA)
	req_one_access = null

/obj/machinery/door/airlock/mainship/marine/alpha/medic
	name = "\improper Alpha Squad Medic Preparations"
	req_access = list(ACCESS_MARINE_MEDPREP, ACCESS_MARINE_ALPHA)
	req_one_access = null

/obj/machinery/door/airlock/mainship/marine/alpha/smart
	name = "\improper Alpha Squad Smartgunner Preparations"
	req_access = list(ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_ALPHA)
	req_one_access = null

/obj/machinery/door/airlock/mainship/marine/bravo
	name = "\improper Bravo Squad Preparations"
	icon = 'icons/obj/doors/mainship/prepdoor_bravo.dmi'
	req_access = list(ACCESS_MARINE_PREP)
	req_one_access = list(ACCESS_MARINE_LOGISTICS,ACCESS_MARINE_BRAVO)
	opacity = FALSE
	glass = TRUE
	dir = SOUTH

/obj/machinery/door/airlock/mainship/marine/bravo/sl
	name = "\improper Bravo Squad Leader Preparations"
	req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_BRAVO)
	req_one_access = null

/obj/machinery/door/airlock/mainship/marine/bravo/engineer
	name = "\improper Bravo Squad Engineer Preparations"
	req_access = list(ACCESS_MARINE_ENGPREP, ACCESS_MARINE_BRAVO)
	req_one_access = null

/obj/machinery/door/airlock/mainship/marine/bravo/medic
	name = "\improper Bravo Squad Medic Preparations"
	req_access = list(ACCESS_MARINE_MEDPREP, ACCESS_MARINE_BRAVO)
	req_one_access = null

/obj/machinery/door/airlock/mainship/marine/bravo/smart
	name = "\improper Bravo Squad Smartgunner Preparations"
	req_access = list(ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_BRAVO)
	req_one_access = null

/obj/machinery/door/airlock/mainship/marine/charlie
	name = "\improper Charlie Squad Preparations"
	icon = 'icons/obj/doors/mainship/prepdoor_charlie.dmi'
	req_access = list(ACCESS_MARINE_PREP)
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CHARLIE)
	opacity = FALSE
	glass = TRUE
	dir = SOUTH

/obj/machinery/door/airlock/mainship/marine/charlie/sl
	name = "\improper Charlie Squad Leader Preparations"
	req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_CHARLIE)
	req_one_access = null

/obj/machinery/door/airlock/mainship/marine/charlie/engineer
	name = "\improper Charlie Squad Engineer Preparations"
	req_access = list(ACCESS_MARINE_ENGPREP, ACCESS_MARINE_CHARLIE)
	req_one_access = null

/obj/machinery/door/airlock/mainship/marine/charlie/medic
	name = "\improper Charlie Squad Medic Preparations"
	req_access = list(ACCESS_MARINE_MEDPREP, ACCESS_MARINE_CHARLIE)
	req_one_access = null

/obj/machinery/door/airlock/mainship/marine/charlie/smart
	name = "\improper Charlie Squad Smartgunner Preparations"
	req_access = list(ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_CHARLIE)
	req_one_access = null

/obj/machinery/door/airlock/mainship/marine/delta
	name = "\improper Delta Squad Preparations"
	icon = 'icons/obj/doors/mainship/prepdoor_delta.dmi'
	req_access = list(ACCESS_MARINE_PREP)
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_DELTA)
	opacity = FALSE
	glass = TRUE
	dir = SOUTH

/obj/machinery/door/airlock/mainship/marine/delta/sl
	name = "\improper Delta Squad Leader Preparations"
	req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_DELTA)
	req_one_access = null

/obj/machinery/door/airlock/mainship/marine/delta/engineer
	name = "\improper Delta Squad Engineer Preparations"
	req_access = list(ACCESS_MARINE_ENGPREP, ACCESS_MARINE_DELTA)
	req_one_access = null

/obj/machinery/door/airlock/mainship/marine/delta/medic
	name = "\improper Delta Squad Medic Preparations"
	req_access = list(ACCESS_MARINE_MEDPREP, ACCESS_MARINE_DELTA)
	req_one_access = null

/obj/machinery/door/airlock/mainship/marine/delta/smart
	name = "\improper Delta Squad Smartgunner Preparations"
	req_access = list(ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_DELTA)
	req_one_access = null



//DROPSHIP SIDE AIRLOCKS

/obj/machinery/door/airlock/dropship_hatch
	name = "\improper Dropship Hatch"
	icon = 'icons/obj/doors/mainship/dropship1_side.dmi' //Tiles with is here FOR SAFETY PURPOSES
	id = "sh_dropship1"
	openspeed = 4 //shorter open animation.
	resistance_flags = RESIST_ALL
	no_panel = TRUE
	not_weldable = TRUE

/obj/machinery/door/airlock/dropship_hatch/proc/lockdown()
	unlock()
	close()
	lock()

/obj/machinery/door/airlock/dropship_hatch/proc/release()
	unlock()

/obj/machinery/door/airlock/dropship_hatch/ex_act(severity)
	return

/obj/machinery/door/airlock/dropship_hatch/close(forced=0)
	if(forced)
		for(var/mob/living/L in loc)
			step(L, pick(EAST,WEST)) // bump them off the tile
		safe = 0 // in case anyone tries to run into the closing door~
		..()
		safe = 1 // without having to rewrite closing proc~spookydonut
	else
		..()


/obj/machinery/door/airlock/dropship_hatch/left
	dir = EAST

/obj/machinery/door/airlock/dropship_hatch/right
	dir = WEST

/obj/machinery/door/airlock/dropship_hatch/left/two
	icon = 'icons/obj/doors/mainship/dropship2_side.dmi' //Tiles with is here FOR SAFETY PURPOSES
	id = "sh_dropship2"

/obj/machinery/door/airlock/dropship_hatch/right/two
	icon = 'icons/obj/doors/mainship/dropship2_side.dmi' //Tiles with is here FOR SAFETY PURPOSES
	id = "sh_dropship2"

/obj/machinery/door/airlock/hatch/cockpit
	icon = 'icons/obj/doors/mainship/dropship1_pilot.dmi'
	name = "\improper Cockpit"
	req_access = list(ACCESS_MARINE_DROPSHIP)
	resistance_flags = RESIST_ALL
	no_panel = TRUE
	not_weldable = TRUE

/obj/machinery/door/airlock/hatch/cockpit/canAIControl(mob/user)
	return TRUE

/obj/machinery/door/airlock/hatch/cockpit/two
	icon = 'icons/obj/doors/mainship/dropship2_pilot.dmi'

//PRISON AIRLOCKS
/obj/machinery/door/airlock/prison
	name = "\improper Cell Door"
	icon = 'icons/obj/doors/prison/celldoor.dmi'
	glass = FALSE

/obj/machinery/door/airlock/prison/open
	icon_state = "door_open"
	density = FALSE
	opacity = FALSE

/obj/machinery/door/airlock/prison/horizontal
	dir = SOUTH

/obj/machinery/door/airlock/prison/horizontal/open
	icon_state = "door_open"
	density = FALSE
	opacity = FALSE


//Colony Mapped Doors
/obj/machinery/door/airlock/colony


/obj/machinery/door/airlock/colony/engineering
	icon = 'icons/obj/doors/mainship/engidoor.dmi'
	opacity = FALSE
	glass = TRUE
	req_access = list(ACCESS_CIVILIAN_ENGINEERING)

/obj/machinery/door/airlock/colony/engineering/smes
	name = "\improper Engineering Dome SMES"

/obj/machinery/door/airlock/colony/engineering/nexusstorage
	name = "\improper Nexus Cargo Storage"

/obj/machinery/door/airlock/colony/engineering/nexusstorage/open
	icon_state = "door_open"
	density = FALSE
	opacity = FALSE


/obj/machinery/door/airlock/colony/medical
	icon = 'icons/obj/doors/mainship/medidoor_glass.dmi'
	opacity = FALSE
	glass = TRUE
	req_access = list(ACCESS_CIVILIAN_MEDICAL)

/obj/machinery/door/airlock/colony/medical/domestorage
	name = "\improper Medical Dome Storage"

/obj/machinery/door/airlock/colony/medical/domesurgery
	name = "\improper Medical Dome Surgery"

/obj/machinery/door/airlock/colony/medical/domelockers
	name = "\improper Medical Dome Lockers"

/obj/machinery/door/airlock/colony/medical/hydroponics
	name = "\improper Hydroponics Dome"
	req_access = list(ACCESS_CIVILIAN_PUBLIC)


/obj/machinery/door/airlock/colony/research
	icon = 'icons/obj/doors/mainship/medidoor.dmi'
	req_access = list(ACCESS_CIVILIAN_RESEARCH)

/obj/machinery/door/airlock/colony/research/dome
	name = "\improper Research Dome"
	icon_state = "door_locked"
	locked = TRUE
