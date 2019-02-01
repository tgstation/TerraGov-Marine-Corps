
/obj/machinery/door/airlock/secure
	name = " Secure Airlock"
	icon = 'icons/obj/doors/Door_secure.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_com
	openspeed = 34

/obj/machinery/door/airlock/command
	name = " Command Airlock"
	icon = 'icons/obj/doors/Doorcom.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_com

/obj/machinery/door/airlock/security
	name = " Security Airlock"
	icon = 'icons/obj/doors/Doorsec.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_sec

/obj/machinery/door/airlock/engineering
	name = " Engineering Airlock"
	icon = 'icons/obj/doors/Dooreng.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_eng

/obj/machinery/door/airlock/medical
	name = " Medical Airlock"
	icon = 'icons/obj/doors/Doormed.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_med

/obj/machinery/door/airlock/maintenance
	name = " Maintenance Hatch"
	icon = 'icons/obj/doors/Doormaint.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_mai

/obj/machinery/door/airlock/external
	name = " External Airlock"
	icon = 'icons/obj/doors/Doorext.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_ext

/obj/machinery/door/airlock/glass
	name = " Glass Airlock"
	icon = 'icons/obj/doors/Doorglass.dmi'
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/centcom
	name = " Airlock"
	icon = 'icons/obj/doors/Doorele.dmi'
	opacity = 1

/obj/machinery/door/airlock/vault
	name = " Vault"
	icon = 'icons/obj/doors/vault.dmi'
	opacity = 1
	assembly_type = /obj/structure/door_assembly/door_assembly_highsecurity //Until somebody makes better sprites.

/obj/machinery/door/airlock/freezer
	name = " Freezer Airlock"
	icon = 'icons/obj/doors/Doorfreezer.dmi'
	opacity = 1
	assembly_type = /obj/structure/door_assembly/door_assembly_fre

/obj/machinery/door/airlock/hatch
	name = " Airtight Hatch"
	icon = 'icons/obj/doors/Doorhatchele.dmi'
	opacity = 1
	assembly_type = /obj/structure/door_assembly/door_assembly_hatch

/obj/machinery/door/airlock/maintenance_hatch
	name = " Maintenance Hatch"
	icon = 'icons/obj/doors/Doorhatchmaint2.dmi'
	opacity = 1
	assembly_type = /obj/structure/door_assembly/door_assembly_mhatch

/obj/machinery/door/airlock/glass_command
	name = " Command Airlock"
	icon = 'icons/obj/doors/Doorcomglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_com
	glass = 1

/obj/machinery/door/airlock/glass_engineering
	name = " Engineering Airlock"
	icon = 'icons/obj/doors/Doorengglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_eng
	glass = 1

/obj/machinery/door/airlock/glass_security
	name = " Security Airlock"
	icon = 'icons/obj/doors/Doorsecglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_sec
	glass = 1

/obj/machinery/door/airlock/glass_medical
	name = " Medical Airlock"
	icon = 'icons/obj/doors/Doormedglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_med
	glass = 1

/obj/machinery/door/airlock/mining
	name = " Mining Airlock"
	icon = 'icons/obj/doors/Doormining.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_min

/obj/machinery/door/airlock/marine
    name = " Airlock"
    icon = 'icons/obj/doors/door_marines.dmi'
    assembly_type = /obj/structure/door_assembly/door_assembly_min

/obj/machinery/door/airlock/atmos
	name = " Atmospherics Airlock"
	icon = 'icons/obj/doors/Dooratmo.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_atmo

/obj/machinery/door/airlock/research
	name = " Research Airlock"
	icon = 'icons/obj/doors/Doorresearch.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_research

/obj/machinery/door/airlock/glass_research
	name = " Research Airlock"
	icon = 'icons/obj/doors/Doorresearchglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_research
	glass = 1
	heat_proof = 1

/obj/machinery/door/airlock/glass_mining
	name = " Mining Airlock"
	icon = 'icons/obj/doors/Doorminingglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_min
	glass = 1

/obj/machinery/door/airlock/glass_atmos
	name = " Atmospherics Airlock"
	icon = 'icons/obj/doors/Dooratmoglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_atmo
	glass = 1

/obj/machinery/door/airlock/gold
	name = " Gold Airlock"
	icon = 'icons/obj/doors/Doorgold.dmi'
	mineral = "gold"

/obj/machinery/door/airlock/silver
	name = " Silver Airlock"
	icon = 'icons/obj/doors/Doorsilver.dmi'
	mineral = "silver"

/obj/machinery/door/airlock/diamond
	name = " Diamond Airlock"
	icon = 'icons/obj/doors/Doordiamond.dmi'
	mineral = "diamond"

/obj/machinery/door/airlock/uranium
	name = " Uranium Airlock"
	desc = "And they said I was crazy."
	icon = 'icons/obj/doors/Dooruranium.dmi'
	mineral = "uranium"
	var/last_event = 0

/obj/machinery/door/airlock/uranium/process()
	if(world.time > last_event+20)
		if(prob(50))
			radiate()
		last_event = world.time
	..()

/obj/machinery/door/airlock/uranium/proc/radiate()
	for(var/mob/living/L in range (3,src))
		L.apply_effect(15,IRRADIATE,0)
	return

/obj/machinery/door/airlock/phoron
	name = " Phoron Airlock"
	desc = "No way this can end badly."
	icon = 'icons/obj/doors/Doorphoron.dmi'
	mineral = "phoron"



/obj/machinery/door/airlock/sandstone
	name = " Sandstone Airlock"
	icon = 'icons/obj/doors/Doorsand.dmi'
	mineral = "sandstone"

/obj/machinery/door/airlock/science
	name = " Research Airlock"
	icon = 'icons/obj/doors/Doorsci.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_science

/obj/machinery/door/airlock/glass_science
	name = " Research Airlock"
	icon = 'icons/obj/doors/Doorsciglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_science
	glass = 1

/obj/machinery/door/airlock/highsecurity
	name = " High Tech Security Airlock"
	icon = 'icons/obj/doors/hightechsecurity.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_highsecurity





//ALMAYER AIRLOCKS

/obj/machinery/door/airlock/almayer
	name = " Airlock"
	icon = 'icons/obj/doors/almayer/comdoor.dmi' //Tiles with is here FOR SAFETY PURPOSES
	openspeed = 4 //shorter open animation.
	tiles_with = list(
		/turf/closed/wall,
		/obj/structure/window/framed/almayer,
		/obj/machinery/door/airlock)

	New()
		spawn(10) // No fucken idea but this somehow makes it work. What the actual fuck.
			relativewall_neighbours()
		..()


/obj/machinery/door/airlock/almayer/security
	name = " Security Airlock"
	icon = 'icons/obj/doors/almayer/secdoor.dmi'
	req_access_txt = "3"

/obj/machinery/door/airlock/almayer/security/glass
	name = " Security Airlock"
	icon = 'icons/obj/doors/almayer/secdoor_glass.dmi'
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/command
	name = " Command Airlock"
	icon = 'icons/obj/doors/almayer/comdoor.dmi'
	req_access_txt = "19"

/obj/machinery/door/airlock/almayer/secure
	name = " Secure Airlock"
	icon = 'icons/obj/doors/almayer/securedoor.dmi'
	req_access_txt = "19"

/obj/machinery/door/airlock/almayer/maint
	name = " Maintenance Hatch"
	icon = 'icons/obj/doors/almayer/maintdoor.dmi'
	req_access_txt = "0"
	req_one_access_txt = "2;7"

/obj/machinery/door/airlock/almayer/engineering
	name = " Engineering Airlock"
	icon = 'icons/obj/doors/almayer/engidoor.dmi'
	opacity = 0
	glass = 1
	req_access_txt = "0"
	req_one_access_txt = "2;7"

/obj/machinery/door/airlock/almayer/medical
	name = " Medical Airlock"
	icon = 'icons/obj/doors/almayer/medidoor.dmi'
	req_access_txt = "0"
	req_one_access_txt =  "2;8;19"

/obj/machinery/door/airlock/almayer/medical/glass
	name = " Medical Airlock"
	icon = 'icons/obj/doors/almayer/medidoor_glass.dmi'
	opacity = 0
	glass = 1
	req_access_txt = "0"
	req_one_access_txt =  "2;8;19"

/obj/machinery/door/airlock/almayer/research
	name = " Research Airlock"
	icon = 'icons/obj/doors/almayer/medidoor.dmi'
	req_access = list(ACCESS_MARINE_RESEARCH)

/obj/machinery/door/airlock/almayer/research/glass
	icon = 'icons/obj/doors/almayer/medidoor_glass.dmi'
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/generic
	name = " Airlock"
	icon = 'icons/obj/doors/almayer/personaldoor.dmi'

/obj/machinery/door/airlock/almayer/generic/corporate
	name = "Corporate Liaison's Quarters"
	icon = 'icons/obj/doors/almayer/personaldoor.dmi'
	req_access_txt = "200"

/obj/machinery/door/airlock/almayer/marine
	name = " Airlock"
	icon = 'icons/obj/doors/almayer/prepdoor.dmi'
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/requisitions
	name = " Requisitions Bay"
	icon = 'icons/obj/doors/almayer/prepdoor.dmi'
	req_access_txt = "0"
	req_one_access_txt =  "2;21"
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/alpha
	name = " Alpha Squad Preparations"
	icon = 'icons/obj/doors/almayer/prepdoor_alpha.dmi'
	req_access_txt = "9"
	req_one_access_txt =  "2;15"
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/alpha/sl
	name = " Alpha Squad Leader Preparations"
	req_access_txt ="12;15"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/alpha/spec
	name = " Alpha Squad Specialist Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "13"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/alpha/engineer
	name = " Alpha Squad Engineer Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "11"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/alpha/medic
	name = " Alpha Squad Medic Preparations"
	req_access_txt ="10;15"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/alpha/smart
	name = " Alpha Squad Smartgunner Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "25"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/bravo
	name = " Bravo Squad Preparations"
	icon = 'icons/obj/doors/almayer/prepdoor_bravo.dmi'
	req_access_txt = "9"
	req_one_access_txt =  "2;16"
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/bravo/sl
	name = " Bravo Squad Leader Preparations"
	req_access_txt ="12;16"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/bravo/spec
	name = " Bravo Squad Specialist Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "13"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/bravo/engineer
	name = " Bravo Squad Engineer Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "11"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/bravo/medic
	name = " Bravo Squad Medic Preparations"
	req_access_txt ="10;16"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/bravo/smart
	name = " Bravo Squad Smartgunner Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "25"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/charlie
	name = " Charlie Squad Preparations"
	icon = 'icons/obj/doors/almayer/prepdoor_charlie.dmi'
	req_access_txt = "9"
	req_one_access_txt =  "2;17"
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/charlie/sl
	name = " Charlie Squad Leader Preparations"
	req_access_txt ="12;17"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/charlie/spec
	name = " Charlie Squad Specialist Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "13"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/charlie/engineer
	name = " Charlie Squad Engineer Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "11"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/charlie/medic
	name = " Charlie Squad Medic Preparations"
	req_access_txt ="10;17"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/charlie/smart
	name = " Charlie Squad Smartgunner Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "25"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/delta
	name = " Delta Squad Preparations"
	icon = 'icons/obj/doors/almayer/prepdoor_delta.dmi'
	req_access_txt = "9"
	req_one_access_txt =  "2;18"
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/delta/sl
	name = " Delta Squad Leader Preparations"
	req_access_txt ="12;18"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/delta/spec
	name = " Delta Squad Specialist Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "13"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/delta/engineer
	name = " Delta Squad Engineer Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "11"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/delta/medic
	name = " Delta Squad Medic Preparations"
	req_access_txt ="10;18"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/delta/smart
	name = " Delta Squad Smartgunner Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "25"
	dir = 2
	opacity = 0
	glass = 1



//DROPSHIP SIDE AIRLOCKS

/obj/machinery/door/airlock/dropship_hatch
	name = " Dropship Hatch"
	icon = 'icons/obj/doors/almayer/dropship1_side.dmi' //Tiles with is here FOR SAFETY PURPOSES
	id = "sh_dropship1"
	openspeed = 4 //shorter open animation.
	unacidable = 1
	no_panel = 1
	not_weldable = 1

/obj/machinery/door/airlock/dropship_hatch/ex_act(severity)
	return

/obj/machinery/door/airlock/dropship_hatch/close(var/forced=0)
	if(forced)
		for(var/mob/living/L in loc)
			step(L, pick(EAST,WEST)) // bump them off the tile
		safe = 0 // in case anyone tries to run into the closing door~
		..()
		safe = 1 // without having to rewrite closing proc~spookydonut
	else
		..()

/obj/machinery/door/airlock/dropship_hatch/unlock()
	if(z == 4) // in flight
	 return
	..()

/obj/machinery/door/airlock/dropship_hatch/two
	icon = 'icons/obj/doors/almayer/dropship2_side.dmi' //Tiles with is here FOR SAFETY PURPOSES
	id = "sh_dropship2"

/obj/machinery/door/airlock/hatch/cockpit
	icon = 'icons/obj/doors/almayer/dropship1_pilot.dmi'
	name = " Cockpit"
	req_access_txt = "22"
	req_one_access_txt = "0"
	unacidable = 1
	no_panel = 1
	not_weldable = 1

/obj/machinery/door/airlock/hatch/cockpit/two
	icon = 'icons/obj/doors/almayer/dropship2_pilot.dmi'

//PRISON AIRLOCKS
/obj/machinery/door/airlock/prison/
	name = " Cell Door"
	icon = 'icons/obj/doors/prison/celldoor.dmi'
	glass = 0

/obj/machinery/door/airlock/prison/horizontal
	dir = 2
