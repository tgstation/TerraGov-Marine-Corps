/obj/structure/sign
	icon = 'icons/obj/decals.dmi'
	anchored = 1
	opacity = 0
	density = 0
	layer = WALL_OBJ_LAYER

/obj/structure/sign/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			qdel(src)
			return
		if(3.0)
			qdel(src)
			return
		else
	return

/obj/structure/sign/attackby(obj/item/tool as obj, mob/user as mob)	//deconstruction
	if(istype(tool, /obj/item/tool/screwdriver) && !istype(src, /obj/structure/sign/double))
		to_chat(user, "You unfasten the sign with your [tool].")
		var/obj/item/sign/S = new(src.loc)
		S.name = name
		S.desc = desc
		S.icon_state = icon_state
		//var/icon/I = icon('icons/obj/decals.dmi', icon_state)
		//S.icon = I.Scale(24, 24)
		S.sign_state = icon_state
		qdel(src)
	else ..()

/obj/item/sign
	name = "sign"
	desc = ""
	icon = 'icons/obj/decals.dmi'
	w_class = 3		//big
	var/sign_state = ""

/obj/item/sign/attackby(obj/item/tool as obj, mob/user as mob)	//construction
	if(istype(tool, /obj/item/tool/screwdriver) && isturf(user.loc))
		var/direction = input("In which direction?", "Select direction.") in list("North", "East", "South", "West", "Cancel")
		if(direction == "Cancel") return
		var/obj/structure/sign/S = new(user.loc)
		switch(direction)
			if("North")
				S.pixel_y = 32
			if("East")
				S.pixel_x = 32
			if("South")
				S.pixel_y = -32
			if("West")
				S.pixel_x = -32
			else return
		S.name = name
		S.desc = desc
		S.icon_state = sign_state
		to_chat(user, "You fasten \the [S] with your [tool].")
		qdel(src)
	else ..()

/obj/structure/sign/double/map
	name = "station map"
	desc = "A framed picture of the station."

/obj/structure/sign/double/map/left
	icon_state = "map-left"

/obj/structure/sign/double/map/right
	icon_state = "map-right"

/obj/structure/sign/securearea
	name = " SECURE AREA"
	desc = "A warning sign which reads 'SECURE AREA'."
	icon_state = "securearea"

/obj/structure/sign/biohazard
	name = " BIOHAZARD"
	desc = "A warning sign which reads 'BIOHAZARD'."
	icon_state = "bio"

/obj/structure/sign/electricshock
	name = " HIGH VOLTAGE"
	desc = "A warning sign which reads 'HIGH VOLTAGE'."
	icon_state = "shock"

/obj/structure/sign/examroom
	name = " EXAM"
	desc = "A guidance sign which reads 'EXAM ROOM'."
	icon_state = "examroom"

/obj/structure/sign/vacuum
	name = " HARD VACUUM AHEAD"
	desc = "A warning sign which reads 'HARD VACUUM AHEAD'."
	icon_state = "space"

/obj/structure/sign/deathsposal
	name = " DISPOSAL LEADS TO SPACE"
	desc = "A warning sign which reads 'DISPOSAL LEADS TO SPACE'."
	icon_state = "deathsposal"

/obj/structure/sign/pods
	name = " ESCAPE PODS"
	desc = "A warning sign which reads 'ESCAPE PODS'."
	icon_state = "pods"

/obj/structure/sign/fire
	name = " DANGER: FIRE"
	desc = "A warning sign which reads 'DANGER: FIRE'."
	icon_state = "fire"

/obj/structure/sign/nosmoking_1
	name = " NO SMOKING"
	desc = "A warning sign which reads 'NO SMOKING'."
	icon_state = "nosmoking"

/obj/structure/sign/nosmoking_2
	name = " NO SMOKING"
	desc = "A warning sign which reads 'NO SMOKING'."
	icon_state = "nosmoking2"

/obj/structure/sign/redcross
	name = "medbay"
	desc = "The Intergalactic symbol of Medical institutions. You'll probably get help here."
	icon_state = "redcross"

/obj/structure/sign/greencross
	name = "medbay"
	desc = "The Intergalactic symbol of Medical institutions. You'll probably get help here."
	icon_state = "greencross"

/obj/structure/sign/goldenplaque
	name = "The Most Robust Men Award for Robustness"
	desc = "To be Robust is not an action or a way of life, but a mental state. Only those with the force of Will strong enough to act during a crisis, saving friend from foe, are truly Robust. Stay Robust my friends."
	icon_state = "goldenplaque"

/obj/structure/sign/kiddieplaque
	name = "AI developers plaque"
	desc = "Next to the extremely long list of names and job titles, there is a drawing of a little child. The child appears to be retarded. Beneath the image, someone has scratched the word \"PACKETS\""
	icon_state = "kiddieplaque"

/obj/structure/sign/atmosplaque
	name = " FEA Atmospherics Division plaque"
	desc = "This plaque commemorates the fall of the Atmos FEA division. For all the charred, dizzy, and brittle men who have died in its hands."
	icon_state = "atmosplaque"

/obj/structure/sign/double/maltesefalcon	//The sign is 64x32, so it needs two tiles. ;3
	name = "The Maltese Falcon"
	desc = "The Maltese Falcon, Space Bar and Grill."

/obj/structure/sign/double/maltesefalcon/left
	icon_state = "maltesefalcon-left"

/obj/structure/sign/double/maltesefalcon/right
	icon_state = "maltesefalcon-right"

/obj/structure/sign/science			//These 3 have multiple types, just var-edit the icon_state to whatever one you want on the map
	name = " SCIENCE!"
	desc = "A warning sign which reads 'SCIENCE!'."
	icon_state = "science1"

/obj/structure/sign/chemistry
	name = " CHEMISTRY"
	desc = "A warning sign which reads 'CHEMISTRY'."
	icon_state = "chemistry1"

/obj/structure/sign/botany
	name = " HYDROPONICS"
	desc = "A warning sign which reads 'HYDROPONICS'."
	icon_state = "hydro1"

/obj/structure/sign/directions/science
	name = " Science department"
	desc = "A direction sign, pointing out which way the Science department is."
	icon_state = "direction_sci"

/obj/structure/sign/directions/engineering
	name = " Engineering department"
	desc = "A direction sign, pointing out which way the Engineering department is."
	icon_state = "direction_eng"

/obj/structure/sign/directions/security
	name = " Security department"
	desc = "A direction sign, pointing out which way the Security department is."
	icon_state = "direction_sec"

/obj/structure/sign/directions/medical
	name = " Medical Bay"
	desc = "A direction sign, pointing out which way the Medical Bay is."
	icon_state = "direction_med"

/obj/structure/sign/directions/evac
	name = " Escape Arm"
	desc = "A direction sign, pointing out which way the escape shuttle dock is."
	icon_state = "direction_evac"

/obj/structure/sign/safety/
	name = "sign"
	icon = 'icons/obj/safety_signs.dmi'
	desc = "A sign warning of a particular hazard"
	anchored = 1
	opacity = 0
	density = 0

/obj/structure/sign/safety/airlock
	name = " Airlock"
	desc = "A sign denoting the presence of an airlock nearby."
	icon_state = "sign_airlock"

/obj/structure/sign/safety/rad_shield
	name = " Radiation shielded area"
	desc = "A sign denoting the presence of a lead radiation shielding."
	icon_state = "sign_rad_shield"

/obj/structure/sign/safety/no_grav
	name = " Caution: Zero Gravity Area"
	desc = "A warning sign that warns of a Zero Gravity Area"
	icon_state = "sign_nograv"

/obj/structure/sign/safety/grav_suit
	name = " Caution: Artifical Gravity Suit Required"
	desc = "A warning sign advising the use of an artifical gravity suit"
	icon_state = "sign_artgrav_suit"

/obj/structure/sign/safety/electronics
	name = " Caution: Electrical Systems"
	desc = "A warning sign that warns of electrical systems"
	icon_state = "sign_electronics"

/obj/structure/sign/safety/autodoc
	name = " Autodoc"
	desc = "A sign denoting the presence of a automated doctor nearby"
	icon_state = "sign_autodoc"

/obj/structure/sign/safety/bridge
	name = " Bridge"
	desc = "A sign signifying the bridge"
	icon_state = "sign_bridge"

/obj/structure/sign/safety/blast_door
	name = " Caution: Bulkhead"
	desc = "A sign warning of a bulkhead door nearby"
	icon_state = "sign_blastdoor"

/obj/structure/sign/safety/breakroom
	name = " Breakroom"
	desc = "A sign denoting the presence of a breakroom nearby"
	icon_state = "sign_coffee"

/obj/structure/sign/safety/medical
	name = " Medical Bay"
	desc = "A sign that denotes the proximity of a medical facility"
	icon_state = "sign_medical"

/obj/structure/sign/safety/maintenance
	name = " Maintenance Shaft"
	desc = "A sign warning of a nearby maintenance shaft."
	icon_state = "sign_maint"

/obj/structure/sign/safety/galley
	name = " Galley"
	desc = "A sign that denotes the proximity of food nearby."
	icon_state = "sign_galley"

/obj/structure/sign/safety/atmospherics
	name = " Life Support System"
	desc = "A sign that denotes the proximity of a life supprot system."
	icon_state = "sign_life_support"

/obj/structure/sign/safety/vent
	name = " Warning: Exhaust Vent"
	desc = "A warning sign that indicates a hazardous exhaust vent nearby"
	icon_state = "sign_exhaust"

/obj/structure/sign/safety/storage
	name = " Storage Area"
	desc = "A sign that denotes the proximity of a storage facility."
	icon_state = "sign_storage"

/obj/structure/sign/safety/medical_supplies
	name = " First-Aid"
	desc = "A sign denoting the presence of nearby "
	icon_state = "sign_medical_life_support"

/obj/structure/sign/safety/EVA
	name = " EVA Suit Locker"
	desc = "A sign that indicates the presence of a EVA Suit Locker"
	icon_state = "sign_space_suit_locker"

/obj/structure/sign/safety/laser
	name = " Warning: High-Energy Laser"
	desc = "A warning sign that warns of a lethal energy laser nearby"
	icon_state = "sign_laser"

/obj/structure/sign/safety/vacuum
	name = " Warning: Vacuum"
	desc = "A warning sign indicating a pressureless area nearby"
	icon_state = "sign_vacuum"

/obj/structure/sign/safety/ladder
	name = " Warning: Ladder"
	desc = "A sign that denotes the proximity of a ladder"
	icon_state = "sign_ladder"

/obj/structure/sign/safety/pressure
	name = " Warning: Pressurised Area Ahead"
	desc = "A sign that warns of a pressurised area nearby"
	icon_state = "sign_pressurised_area"

/obj/structure/sign/safety/high_radiation
	name = " Warning:HIGH RADIATION LEVELS"
	desc = "A sign that warns of dangerous radiation nearby"
	icon_state = "sign_high_rad"

/obj/structure/sign/safety/rad_hazard
	name = " Warning: Radiation Hazard"
	desc = "A sign that warns of radiation nearby"
	icon_state = "sign_rad_hazard"

/obj/structure/sign/safety/cryogenic
	name = " Cryogenic Vault"
	desc = "A sign that denotes the presence of a cryogenic vault"
	icon_state = "sign_cryo_vault"

/obj/structure/sign/safety/hazard
	name = " Warning: Hazardous Materials"
	desc = "A sign that warns of hazardous materials nearby"
	icon_state = "sign_hazard"

/obj/structure/sign/safety/computer
	name = " Warning: Critical System"
	desc = "A warning sign that warns of facility critical computer systems"
	icon_state = "sign_computer"

/obj/structure/sign/safety/hydro
	name = " Hydrophonics"
	desc = "A sign that denotes the presence of a hydrophonic facility"
	icon_state = "sign_food_fridge"

/obj/structure/sign/safety/fridge
	name = " Refridgerated Storage"
	desc = "A sign that denotes the presence of a refridgeration facility"
	icon_state = "sign_cold_storage"

/obj/structure/sign/safety/radio
	name = " Intercommunication System"
	desc = "A sign notifying the presence of a intercomm system."
	icon_state = "sign_intercomm"



//Marine signs

/obj/structure/sign/ROsign
	name = " USCM Requisitions Office Guidelines"
	desc = " 1. You are not entitled to service or equipment. Attachments are a privilege, not a right.\n 2. You must be fully dressed to obtain service. Cryosleep underwear is non-permissible.\n 3. The Requsitions Officer has the final say and the right to decline service. Only the Acting Commander may override his decisions.\n 4. Please treat your Requsitions staff with respect. They work hard."
	icon_state = "roplaque"

/obj/structure/sign/prop1
	name = " USCM Poster"
	desc = "The symbol of the United States Colonial Marines."
	icon_state = "prop1"

/obj/structure/sign/prop2
	name = " USCM Poster"
	desc = "A deeply faded poster of a group of glamorous United States Colonial Marines in uniform. Probably taken pre-Alpha."
	icon_state = "prop2"

/obj/structure/sign/prop3
	name = " USCM Poster"
	desc = "An old recruitment poster for the USCM. Looking at it floods you with a mixture of pride and sincere regret."
	icon_state = "prop3"
