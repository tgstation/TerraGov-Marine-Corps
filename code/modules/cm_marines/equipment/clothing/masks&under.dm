//========================//MASKS AND UNDER\\============================\\
//=======================================================================\\

/*This should contain all the various under clothing people can wear, along
with all of the masks and or other facial coverings. For the latter category
it doesn't matter if they provide hugger protection or not. This can also
include jackets and regular suits, not armor.*/

//=======================================================================\\
//=======================================================================\\


//===========================//MASKS\\===================================\\
//=======================================================================\\

//Mask
/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/obj/clothing/masks.dmi'
	flags_armor_protection = HEAD
	flags_pass = PASSTABLE
	flags_atom = FPRINT
	flags_equip_slot = SLOT_FACE
	flags_armor_protection = FACE|EYES
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/masks.dmi')
	var/anti_hug = 0

/obj/item/clothing/mask/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_wear_mask()

/obj/item/clothing/mask/proc/filter_air(datum/gas_mixture/air)
	return

/obj/item/clothing/mask/rebreather
	name = "rebreather"
	desc = "A close-fitting device that instantly heats or cools down air when you inhale so it doesn't damage your lungs."
	icon_state = "rebreather"
	item_state = "rebreather"
	w_class = 2
	flags_armor_protection = 0
	flags_inventory = COVERMOUTH|HIDELOWHAIR|ALLOWREBREATH

/obj/item/clothing/mask/rebreather/scarf
	name = "heat absorbent coif"
	desc = "A close-fitting cap that covers the top, back, and sides of the head. Can also be adjusted to cover the lower part of the face so it keeps the user warm in harsh conditions."
	icon_state = "coif"
	item_state = "coif"
	flags_inventory = COVERMOUTH|HIDEALLHAIR|HIDEEARS|ALLOWREBREATH
	flags_cold_protection = HEAD
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature

/obj/item/clothing/mask/gas
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. Filters harmful gases from the air."
	icon_state = "gas_alt"
	flags_inventory = HIDEEARS | HIDEEYES | HIDEFACE | COVERMOUTH | COVEREYES | ALLOWINTERNALS | HIDELOWHAIR | BLOCKGASEFFECT
	w_class = 3.0
	item_state = "gas_alt"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	siemens_coefficient = 0.9
	var/gas_filter_strength = 1			//For gas mask filters
	var/list/filtered_gases = list("phoron", "sleeping_agent", "carbon_dioxide")

/obj/item/clothing/mask/gas/filter_air(datum/gas_mixture/air)
	var/datum/gas_mixture/filtered = new

	for(var/g in filtered_gases)
		if(air.gas[g])
			filtered.gas[g] = air.gas[g] * gas_filter_strength
			air.gas[g] -= filtered.gas[g]

	air.update_values()
	filtered.update_values()

	return filtered

/obj/item/clothing/mask/gas/PMC
	name = "\improper M8 pattern armored balaclava"
	desc = "An armored balaclava designed to conceal both the identity of the operator and act as an air-filter."
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "helmet"
	icon_state = "pmc_mask"
	anti_hug = 3
	armor = list(melee = 10, bullet = 10, laser = 5, energy = 5, bomb = 10, bio = 1, rad = 1)
	flags_inventory = HIDEEARS|HIDEFACE|COVERMOUTH|ALLOWINTERNALS|HIDEALLHAIR|BLOCKGASEFFECT|ALLOWREBREATH

/obj/item/clothing/mask/gas/PMC/leader
	name = "\improper M8 pattern armored balaclava"
	desc = "An armored balaclava designed to conceal both the identity of the operator and act as an air-filter. This particular suit looks like it belongs to a high-ranking officer."
	icon = 'icons/PMC/PMC.dmi'
	item_state = "officer_mask"
	icon_state = "officer_mask"

/obj/item/clothing/mask/gas/bear
	name = "tactical balaclava"
	desc = "A superior balaclava worn by the Iron Bears."
	icon = 'icons/PMC/PMC.dmi'
	item_state = "bear_mask"
	icon_state = "bear_mask"
	icon_override = 'icons/PMC/PMC.dmi'
	anti_hug = 2

//=========================//MARINES\\===================================\\
//=======================================================================\\

/obj/item/clothing/under
	icon = 'icons/obj/clothing/uniforms.dmi'
	name = "under"
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	permeability_coefficient = 0.90
	flags_pass = PASSTABLE
	flags_atom = FPRINT
	flags_equip_slot = SLOT_ICLOTHING
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	w_class = 3
	var/has_sensor = 1//For the crew computer 2 = unable to change mode
	var/sensor_mode = 3
		/*
		1 = Report living/dead
		2 = Report detailed damages
		3 = Report location
		*/
	var/obj/item/clothing/tie/hastie = null
	var/displays_id = 1
	var/base_color
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/uniform.dmi')

	New()
		..()
		base_color = item_color

/obj/item/clothing/under/marine
	name = "\improper USCM uniform"
	desc = "A standard-issue Marine uniform. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	siemens_coefficient = 0.9
	icon_state = "marine_jumpsuit"
	item_state = "marine_jumpsuit"
	item_color = "marine_jumpsuit"
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 5, bomb = 5, bio = 5, rad = 5)

	New(loc,expected_type 		= /obj/item/clothing/under/marine,
		new_name[] 			= list(/datum/game_mode/ice_colony = "\improper USCM snow uniform"),
		new_protection[] 	= list(/datum/game_mode/ice_colony = ICE_PLANET_min_cold_protection_temperature),
		icon_override[] 	= null
		)
		select_gamemode_skin(expected_type,icon_override,new_name,new_protection)
		..()

//Marine pyjamas, they inherit the base game's pyjamas path so that you can't wear armor with them
/obj/item/clothing/under/pj/marine
	name = "marine underpants"
	desc = "A simple undergarment worn by USCM operators during cryosleep. Makes you drowsy and slower while wearing. You should find an actual uniform."
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	icon_state = "marine_underpants"
	item_state = "marine_underpants"
	item_color = "marine_underpants"
	slowdown = SLOWDOWN_UNDER_UNFITTING

/obj/item/clothing/under/marine/medic
	name = "\improper USCM medic uniform"
	desc = "A standard-issue Marine Medic uniform. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon_state = "marine_medic"
	item_state = "marine_medic"
	item_color = "marine_medic"

	New(loc,expected_type 		= type,
		new_name[] 			= list(/datum/game_mode/ice_colony = "\improper USCM medic snow uniform"),
		new_protection[] 	= list(/datum/game_mode/ice_colony = ICE_PLANET_min_cold_protection_temperature))
		..(loc,expected_type, new_name, new_protection)

/obj/item/clothing/under/marine/engineer
	name = "\improper USCM engineer uniform"
	desc = "A standard-issue Marine Engineer uniform. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon_state = "marine_engineer"
	item_state = "marine_engineer"
	item_color = "marine_engineer"

	New(loc,expected_type 		= type,
		new_name[] 			= list(/datum/game_mode/ice_colony = "\improper USCM engineer snow uniform"),
		new_protection[] 	= list(/datum/game_mode/ice_colony = ICE_PLANET_min_cold_protection_temperature))
		..(loc,expected_type, new_name, new_protection)

/obj/item/clothing/under/marine/sniper
	name = "\improper USCM sniper uniform"
	New(loc,expected_type 		= type,
		new_name[] 			= list(/datum/game_mode/ice_colony = "\improper USCM sniper snow uniform"),
		new_protection[] 	= list(/datum/game_mode/ice_colony = ICE_PLANET_min_cold_protection_temperature),
		icon_override[]		= list(/datum/game_mode/ice_colony = "s_marine_sniper")
		)
		..(loc,expected_type, new_name, new_protection, icon_override)

//========================//OFFICERS\\===================================\\
//=======================================================================\\

/obj/item/clothing/under/rank/chef/exec
	name = "\improper Weyland Yutani suit"
	desc = "A formal white undersuit."

/obj/item/clothing/under/rank/ro_suit
	name = "requisition officer suit."
	desc = "A nicely-fitting military suit for a requisition officer. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon_state = "RO_jumpsuit"
	item_state = "RO_jumpsuit"
	item_color = "RO_jumpsuit"

/obj/item/clothing/suit/storage/RO
	name = "\improper RO jacket"
	desc = "A green jacket worn by crew on the Sulaco. The back has the flag of the United Americas on it."
	icon_state = "RO_jacket"
	item_state = "RO_jacket"
	blood_overlay_type = "coat"
	flags_armor_protection = UPPER_TORSO|ARMS

/obj/item/clothing/under/marine/mp
	name = "military police jumpsuit"
	desc = "A standard-issue Military Police uniform. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon_state = "MP_jumpsuit"
	item_state = "MP_jumpsuit"
	item_color = "MP_jumpsuit"

/obj/item/clothing/under/marine/officer
	name = "marine officer uniform"
	desc = "Softer than silk. Lighter than feather. More protective than Kevlar. Fancier than a regular jumpsuit, too. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon_state = "milohachert"
	item_state = "milohachert"
	item_color = "milohachert"

/obj/item/clothing/under/marine/officer/warrant
	name = "warrant officer uniform"
	desc = "A uniform typically worn by a Warrant Officer of the USCM. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions. This uniform includes a small EMF distributor to help nullify energy-based weapon fire, along with a hazmat chemical filter woven throughout the material to ward off biological and radiation hazards."
	icon_state = "WO_jumpsuit"
	item_color = "WO_jumpsuit"

/obj/item/clothing/under/marine/officer/technical
	name = "technical officer uniform"
	icon_state = "johnny"
	item_color = "johnny"

/obj/item/clothing/under/marine/officer/logistics
	name = "marine officer uniform"
	desc = "A uniform worn by commissioned officers of the USCM. Do the corps proud. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon_state = "BO_jumpsuit"
	item_color = "BO_jumpsuit"

/obj/item/clothing/under/marine/officer/pilot
	name = "pilot officer bodysuit"
	desc = "A bodysuit worn by pilot officers of the USCM, and is meant for survival in inhospitable conditions. Fly the marines onwards to glory. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon_state = "pilot_flightsuit"
	item_state = "pilot_flightsuit"
	item_color = "pilot_flightsuit"
	flags_cold_protection = ICE_PLANET_min_cold_protection_temperature

/obj/item/clothing/under/marine/officer/bridge
	name = "bridge officer uniform"
	desc = "A uniform worn by commissioned officers of the USCM. Do the corps proud. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon_state = "BO_jumpsuit"
	item_state = "BO_jumpsuit"
	item_color = "BO_jumpsuit"

/obj/item/clothing/under/marine/officer/exec
	name = "executive officer uniform"
	desc = "A uniform typically worn by a first-lieutenant Executive Officer in the USCM. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon_state = "XO_jumpsuit"
	item_state = "XO_jumpsuit"
	item_color = "XO_jumpsuit"

/obj/item/clothing/under/marine/officer/command
	name = "commander uniform"
	desc = "The well-ironed uniform of a USCM Captain, the commander onboard the USS Sulaco. Even looking at it the wrong way could result in being court-marshalled. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon_state = "CO_jumpsuit"
	item_state = "CO_jumpsuit"
	item_color = "CO_jumpsuit"

/obj/item/clothing/under/marine/officer/ce
	name = "chief engineer uniform"
	desc = "A uniform for the engineering crew of the USS Sulaco. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	armor = list(melee = 5, bullet = 5, laser = 25, energy = 5, bomb = 5, bio = 5, rad = 25)
	icon_state = "EC_jumpsuit"
	item_state = "EC_jumpsuit"
	item_color = "EC_jumpsuit"

/obj/item/clothing/under/marine/officer/engi
	name = "engineer uniform"
	desc = "A uniform for the engineering crew of the USS Sulaco. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	armor = list(melee = 5, bullet = 5, laser = 15, energy = 5, bomb = 5, bio = 5, rad = 10)
	icon_state = "E_jumpsuit"
	item_state = "E_jumpsuit"
	item_color = "E_jumpsuit"

/obj/item/clothing/under/marine/officer/researcher
	name = "researcher clothes"
	desc = "A simple set of civilian clothes worn by researchers. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 10, bomb = 10, bio = 10, rad = 5)
	icon_state = "research_jumpsuit"
	item_state = "research_jumpsuit"
	item_color = "research_jumpsuit"

//=========================//RESPONDERS\\================================\\
//=======================================================================\\

/obj/item/clothing/under/marine/veteran/PMC
	name = "\improper PMC uniform"
	desc = "A white set of fatigues, designed for private security operators. The symbol of the Weyland-Yutani corporation is emblazed on the suit."
	icon = 'icons/PMC/PMC.dmi'
	//icon_override = 'icons/PMC/PMC.dmi'
	icon_state = "pmc_jumpsuit"
	item_state = "armor"
	item_color = "pmc_jumpsuit"
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	armor = list(melee = 10, bullet = 10, laser = 5, energy = 5, bomb = 10, bio = 1, rad = 1)

/obj/item/clothing/under/marine/veteran/PMC/leader
	name = "\improper PMC command uniform"
	desc = "A white set of fatigues, designed for private security operators. The symbol of the Weyland-Yutani corporation is emblazed on the suit. This particular suit looks like it belongs to a high-ranking officer."
	item_state = "officer_jumpsuit"
	item_color = "officer_jumpsuit"

/obj/item/clothing/under/marine/veteran/PMC/commando
	name = "\improper PMC commando uniform"
	desc = "An armored uniform worn by Weyland Yutani elite commandos. It is well protected while remaining light and comfortable."
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "commando_jumpsuit"
	item_state = "commando_jumpsuit"
	item_color = "commando_jumpsuit"
	armor = list(melee = 10, bullet = 10, laser = 10, energy = 20, bomb = 10, bio = 10, rad = 10)
	has_sensor = 0

/obj/item/clothing/under/marine/veteran/bear
	name = "\improper Iron Bear uniform"
	desc = "A uniform worn by Iron Bears mercenaries in the service of Mother Russia. Smells a little like an actual bear."
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "bear_jumpsuit"
	item_state = "bear_jumpsuit"
	item_color = "bear_jumpsuit"
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	has_sensor = 0

/obj/item/clothing/under/marine/veteran/dutch
	name = "\improper Dutch's Dozen uniform"
	desc = "A comfortable uniform worn by the Dutch's Dozen mercenaries. It's seen some definite wear and tear, but is still in good condition."
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "dutch_jumpsuit"
	item_state = "dutch_jumpsuit"
	item_color = "dutch_jumpsuit"
	has_sensor = 0

/obj/item/clothing/under/marine/veteran/dutch/ranger
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "dutch_jumpsuit2"
	item_state = "dutch_jumpsuit2"
	item_color = "dutch_jumpsuit2"

//===========================//CIVILIANS\\===============================\\
//=======================================================================\\

/obj/item/clothing/under/pizza
	name = "pizza delivery uniform"
	desc = "An ill-fitting, slightly stained uniform for a pizza delivery pilot. Smells of cheese."
	icon_state = "redshirt2"
	item_state = "r_suit"
	item_color = "redshirt2"
	has_sensor = 0

/obj/item/clothing/under/colonist
	name = "colonist uniform"
	desc = "A stylish grey-green jumpsuit - standard issue for colonists."
	icon_state = "colonist"
	item_state = "colonist"
	item_color = "colonist"
	has_sensor = 0

/obj/item/clothing/under/CM_uniform
	name = "colonial marshal uniform"
	desc = "A blue shirt and tan trousers - the official uniform for a Colonial Marshal."
	icon_state = "marshal"
	item_state = "marshal"
	item_color = "marshal"
	armor = list(melee = 15, bullet = 15, laser = 15,energy = 5, bomb = 5, bio = 5, rad = 5)
	has_sensor = 0

/obj/item/clothing/suit/storage/CMB
	name = "\improper CMB jacket"
	desc = "A green jacket worn by crew on the Colonial Marshals."
	icon_state = "CMB_jacket"
	item_state = "CMB_jacket"
	blood_overlay_type = "coat"
	flags_armor_protection = UPPER_TORSO|ARMS

/obj/item/clothing/under/liaison_suit
	name = "liaison's tan suit"
	desc = "A stiff, stylish tan suit commonly worn by businessmen from the Weyland Yutani corporation. Expertly crafted to make you look like a prick."
	icon_state = "liaison_regular"
	item_state = "liaison_regular"
	item_color = "liaison_regular"

/obj/item/clothing/under/liaison_suit/outing
	name = "liaison's outfit"
	desc = "A casual outfit consisting of a collared shirt and a vest. Looks like something you might wear on the weekends, or on a visit to a derelict colony."
	icon_state = "liaison_outing"
	item_state = "liaison_outing"
	item_color = "liaison_outing"

/obj/item/clothing/under/liaison_suit/formal
	name = "liaison's white suit"
	desc = "A formal, white suit. Looks like something you'd wear to a funeral, a Weyland-Yutani corporate dinner, or both. Stiff as a board, but makes you feel like rolling out of a Rolls-Royce."
	icon_state = "liaison_formal"
	item_state = "liaison_formal"
	item_color = "liaison_formal"

/obj/item/clothing/under/liaison_suit/suspenders
	name = "liaison's attire"
	desc = "A collared shirt, complimented by a pair of suspenders. Worn by Weyland-Yutani employees who ask the tough questions. Smells faintly of cigars and bad acting."
	icon_state = "liaison_suspenders"
	item_state = "liaison_suspenders"
	item_color = "liaison_suspenders"

/obj/item/clothing/suit/storage/snow_suit
	name = "snow suit"
	desc = "A standard snow suit. It can protect the wearer from extreme cold."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "snowsuit_alpha"
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 15, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	blood_overlay_type = "armor"
	siemens_coefficient = 0.7

/obj/item/clothing/suit/storage/snow_suit/doctor
	name = "doctor's snow suit"
	icon_state = "snowsuit_doctor"
	armor = list(melee = 25, bullet = 35, laser = 35, energy = 20, bomb = 10, bio = 0, rad = 0)

/obj/item/clothing/suit/storage/snow_suit/engineer
	name = "engineer's snow suit"
	icon_state = "snowsuit_engineer"
	armor = list(melee = 25, bullet = 35, laser = 35, energy = 20, bomb = 10, bio = 0, rad = 0)

//==========================//UNDER PROCS\\=============================\\
//=======================================================================\\

/obj/item/clothing/under/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_w_uniform()

/obj/item/clothing/under/attackby(obj/item/I, mob/user)
	if(hastie)
		hastie.attackby(I, user)
		return

	if(!hastie && istype(I, /obj/item/clothing/tie))
		user.drop_item()
		hastie = I
		hastie.on_attached(src, user)

		if(istype(loc, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = loc
			H.update_inv_w_uniform()

		return

	if(src.loc == user && istype(I,/obj/item/clothing/under) && src != I)
		if(istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			if(H.w_uniform == src)
				H.u_equip(src)
				if(H.equip_to_appropriate_slot(I))
					H.put_in_active_hand(src)
					H.update_icons()

	..()

/obj/item/clothing/under/attack_hand(mob/user as mob)
	//only forward to the attached accessory if the clothing is equipped (not in a storage)
	if(hastie && src.loc == user)
		hastie.attack_hand(user)
		return

	if ((ishuman(usr) || ismonkey(usr)) && src.loc == user)	//make it harder to accidentally undress yourself
		return

	..()

/obj/item/clothing/under/MouseDrop(obj/over_object as obj)
	if (ishuman(usr) || ismonkey(usr))
		//makes sure that the clothing is equipped so that we can't drag it into our hand from miles away.
		if (!canremove || !(loc == usr))
			return

		if (!( usr.restrained() ) && !( usr.stat ))
			if(over_object)
				switch(over_object.name)
					if("r_hand")
						usr.u_equip(src)
						usr.put_in_r_hand(src)
					if("l_hand")
						usr.u_equip(src)
						usr.put_in_l_hand(src)
				add_fingerprint(usr)


/obj/item/clothing/under/examine()
	set src in view()
	..()
	if(has_sensor)
		switch(src.sensor_mode)
			if(0)
				usr << "Its sensors appear to be disabled."
			if(1)
				usr << "Its binary life sensors appear to be enabled."
			if(2)
				usr << "Its vital tracker appears to be enabled."
			if(3)
				usr << "Its vital tracker and tracking beacon appear to be enabled."
	if(hastie)
		usr << "\A [hastie] is clipped to it."

/obj/item/clothing/under/proc/set_sensors(mob/usr as mob)
	var/mob/M = usr
	if (istype(M, /mob/dead/)) return
	if (usr.stat || usr.restrained()) return
	if(has_sensor >= 2)
		usr << "The controls are locked."
		return 0
	if(has_sensor <= 0)
		usr << "This suit does not have any sensors."
		return 0

	var/list/modes = list("Off", "Binary sensors", "Vitals tracker", "Tracking beacon")
	var/switchMode = input("Select a sensor mode:", "Suit Sensor Mode", modes[sensor_mode + 1]) in modes
	if(get_dist(usr, src) > 1)
		usr << "You have moved too far away."
		return
	sensor_mode = modes.Find(switchMode) - 1

	if (src.loc == usr)
		switch(sensor_mode)
			if(0)
				usr << "You disable your suit's remote sensing equipment."
			if(1)
				usr << "Your suit will now report whether you are live or dead."
			if(2)
				usr << "Your suit will now report your vital lifesigns."
			if(3)
				usr << "Your suit will now report your vital lifesigns as well as your coordinate position."
	else if (istype(src.loc, /mob))
		switch(sensor_mode)
			if(0)
				for(var/mob/V in viewers(usr, 1))
					V.show_message("\red [usr] disables [src.loc]'s remote sensing equipment.", 1)
			if(1)
				for(var/mob/V in viewers(usr, 1))
					V.show_message("[usr] turns [src.loc]'s remote sensors to binary.", 1)
			if(2)
				for(var/mob/V in viewers(usr, 1))
					V.show_message("[usr] sets [src.loc]'s sensors to track vitals.", 1)
			if(3)
				for(var/mob/V in viewers(usr, 1))
					V.show_message("[usr] sets [src.loc]'s sensors to maximum.", 1)

/obj/item/clothing/under/verb/toggle()
	set name = "Toggle Suit Sensors"
	set category = "Object"
	set src in usr
	set_sensors(usr)
	..()

/obj/item/clothing/under/verb/rollsuit()
	set name = "Roll Down Jumpsuit"
	set category = "Object"
	set src in usr
	if(!isliving(usr)) return
	if(usr.stat) return

	if(base_color + "_d_s" in icon_states('icons/mob/uniform_0.dmi'))
		var/full_coverage = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
		if(item_color == base_color)
			var/partial_coverage = UPPER_TORSO|LOWER_TORSO|LEGS
			var/final_coverage
			//Marine uniforms can only roll up the sleeves, not wear it at the waist.
			if(istype(src,/obj/item/clothing/under/marine))
				final_coverage = copytext(item_color,1,3) == "s_" ? full_coverage : partial_coverage
			else final_coverage = partial_coverage & ~UPPER_TORSO
			flags_armor_protection = final_coverage
			item_color = "[base_color]_d"
		else
			flags_armor_protection = full_coverage
			item_color = base_color

		flags_cold_protection = flags_armor_protection
		flags_heat_protection = flags_armor_protection
		update_clothing_icon()

	else usr << "<span class='warning'>You cannot roll down the uniform!</span>"

/obj/item/clothing/under/proc/remove_accessory(mob/user as mob)
	if(!hastie)
		return

	hastie.on_removed(user)
	hastie = null
	update_clothing_icon()

/obj/item/clothing/under/verb/removetie()
	set name = "Remove Accessory"
	set category = "Object"
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.stat) return

	src.remove_accessory(usr)

/obj/item/clothing/under/rank/New()
	//sensor_mode = pick(0,1,2,3) //Why was this a thing --MadSnailDisease
	..()

/obj/item/clothing/under/emp_act(severity)
	if (hastie)
		hastie.emp_act(severity)
	..()
