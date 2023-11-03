/**
* Job related clothing
*/

//Botonist
/obj/item/clothing/suit/apron
	name = "apron"
	desc = "A basic blue apron."
	icon_state = "apron"
	item_state = "apron"
	blood_overlay_type = "armor"
	flags_armor_protection = NONE
	allowed = list (
		/obj/item/reagent_containers/spray/plantbgone,
		/obj/item/tool/analyzer/plant_analyzer,
		/obj/item/seeds,
		/obj/item/reagent_containers/glass/fertilizer,
		/obj/item/tool/minihoe,
		/obj/item/flashlight,
		/obj/item/binoculars,
		/obj/item/weapon/combat_knife,
		/obj/item/attachable/bayonetknife,
		/obj/item/storage/holster/blade
	)


/obj/item/clothing/suit/surgical
	name = "surgical apron"
	desc = "A plastic covering to prevent the passage of bodily fluids during surgery."
	icon_state = "surgical"
	item_state = "surgical"
	flags_armor_protection = CHEST
	allowed = list(
		/obj/item/tank/emergency_oxygen,
		/obj/item/healthanalyzer,
		/obj/item/flashlight/pen,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/spray,
		/obj/item/reagent_containers/pill,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/tool/surgery,
		/obj/item/stack/nanopaste,
		/obj/item/tweezers,
		/obj/item/tweezers_advanced,
	)
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 0, ACID = 0)


//Captain
/obj/item/clothing/suit/captunic
	name = "captain's parade tunic"
	desc = "Worn by a Captain to show their class."
	icon_state = "captunic"
	item_state = "bio_suit"
	flags_armor_protection = CHEST|ARMS
	flags_inv_hide = HIDEJUMPSUIT

/obj/item/clothing/suit/captunic/capjacket
	name = "captain's uniform jacket"
	desc = "A less formal jacket for everyday captain use."
	icon_state = "capjacket"
	item_state = "bio_suit"
	flags_armor_protection = CHEST|GROIN|LEGS|ARMS
	flags_inv_hide = HIDEJUMPSUIT

//Chaplain
/obj/item/clothing/suit/chaplain_hoodie
	name = "chaplain hoodie"
	desc = "This suit says to you 'hush'!"
	icon_state = "chaplain_hoodie"
	item_state = "chaplain_hoodie"
	flags_armor_protection = CHEST|ARMS

/obj/item/clothing/suit/nun
	name = "nun robe"
	desc = "Maximum piety in this star system."
	icon_state = "nun"
	item_state = "nun"
	flags_armor_protection = CHEST|GROIN|LEGS|ARMS
	flags_inv_hide = HIDESHOES|HIDEJUMPSUIT

//Chef
/obj/item/clothing/suit/chef
	name = "Chef's apron"
	desc = "An apron used by a high class chef."
	icon_state = "chef"
	item_state = "chef"
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	flags_armor_protection = CHEST|GROIN|ARMS
	allowed = list (/obj/item/tool/kitchen/knife,
	/obj/item/tool/kitchen/knife/butcher)

/obj/item/clothing/suit/chef/classic
	name = "A classic chef's apron."
	desc = "A basic, dull, white chef's apron."
	icon_state = "apronchef"
	item_state = "apronchef"
	blood_overlay_type = "armor"
	flags_armor_protection = NONE

//Security
/obj/item/clothing/suit/security
	desc = "You shouldn't see this"
	flags_armor_protection = CHEST|GROIN|ARMS

/obj/item/clothing/suit/security/formal
	name = "formal jacket"
	desc = "A formal military jacket. Not recommended for combat use."
	icon_state = "officerbluejacket"

/obj/item/clothing/suit/security/formal/tan
	icon_state = "officertanjacket"

/obj/item/clothing/suit/security/formal/officer
	name = "officer's jacket"
	desc = "An officer's formal jacket, makes you look authoritative."
	icon_state = "wardenbluejacket"

/obj/item/clothing/suit/security/formal/officer/tan
	icon_state = "wardentanjacket"

/obj/item/clothing/suit/security/formal/senior_officer
	name = "senior officer's jacket"
	desc = "This piece of clothing was specifically designed for asserting superior authority."
	icon_state = "hosbluejacket"

/obj/item/clothing/suit/security/formal/senior_officer/tan
	icon_state = "hostanjacket"

//Detective
/obj/item/clothing/suit/storage/det_suit
	name = "coat"
	desc = "An 18th-century multi-purpose trenchcoat. Someone who wears this means serious business."
	icon_state = "detective"
	item_state = "det_suit"
	blood_overlay_type = "coat"
	flags_armor_protection = CHEST|ARMS
	allowed = list(
		/obj/item/tank/emergency_oxygen,
		/obj/item/flashlight,
		/obj/item/weapon/gun,
		/obj/item/ammo_magazine,
		/obj/item/ammo_casing,
		/obj/item/weapon/baton,
		/obj/item/restraints/handcuffs,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/detective_scanner,
		/obj/item/taperecorder,
		/obj/item/weapon/combat_knife,
		/obj/item/attachable/bayonetknife,
		/obj/item/storage/holster/blade,
	)
	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 25, ENERGY = 10, BOMB = 0, BIO = 0, FIRE = 10, ACID = 10)

/obj/item/clothing/suit/storage/det_suit/black
	icon_state = "detective2"

//Forensics
/obj/item/clothing/suit/storage/forensics
	name = "jacket"
	desc = "A forensics technician jacket."
	item_state = "det_suit"
	flags_armor_protection = CHEST|ARMS
	allowed = list(
		/obj/item/tank/emergency_oxygen,
		/obj/item/flashlight,
		/obj/item/weapon/gun,
		/obj/item/ammo_magazine,
		/obj/item/ammo_casing,
		/obj/item/weapon/baton,
		/obj/item/restraints/handcuffs,
		/obj/item/detective_scanner,
		/obj/item/taperecorder,
	)
	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 15, ENERGY = 10, BOMB = 0, BIO = 0, FIRE = 10, ACID = 10)

/obj/item/clothing/suit/storage/forensics/red
	name = "red jacket"
	desc = "A red forensics technician jacket."
	icon_state = "forensics_red"

/obj/item/clothing/suit/storage/forensics/blue
	name = "blue jacket"
	desc = "A blue forensics technician jacket."
	icon_state = "forensics_blue"

//Engineering
/obj/item/clothing/suit/storage/hazardvest
	name = "orange reflective safety vest"
	desc = "A high-visibility vest used in work zones."
	icon_state = "hazard"
	item_state = "hazard"
	blood_overlay_type = "armor"
	allowed = list(
		/obj/item/tool/analyzer,
		/obj/item/flashlight,
		/obj/item/tool/multitool,
		/obj/item/pipe_painter,
		/obj/item/radio,
		/obj/item/t_scanner,
		/obj/item/tool/crowbar,
		/obj/item/tool/screwdriver,
		/obj/item/tool/weldingtool,
		/obj/item/tool/wirecutters,
		/obj/item/tool/wrench,
		/obj/item/tank/emergency_oxygen,
		/obj/item/clothing/mask/gas,
		/obj/item/tool/taperoll/engineering,
	)
	flags_armor_protection = CHEST

/obj/item/clothing/suit/storage/hazardvest/lime
	name = "lime reflective safety vest"
	icon_state = "hazard_lime"
	item_state = "hazard_lime"

/obj/item/clothing/suit/storage/hazardvest/blue
	name = "blue reflective safety vest"
	icon_state = "hazard_blue"
	item_state = "hazard_blue"

//Lawyer
/obj/item/clothing/suit/storage/lawyer/bluejacket
	name = "Blue Suit Jacket"
	desc = "A snappy dress jacket."
	icon_state = "suitjacket_blue_open"
	item_state = "suitjacket_blue_open"
	blood_overlay_type = "coat"
	flags_armor_protection = CHEST|ARMS

/obj/item/clothing/suit/storage/lawyer/purpjacket
	name = "Purple Suit Jacket"
	desc = "A snappy dress jacket."
	icon_state = "suitjacket_purp"
	item_state = "suitjacket_purp"
	blood_overlay_type = "coat"
	flags_armor_protection = CHEST|ARMS

//Internal Affairs
/obj/item/clothing/suit/storage/internalaffairs
	name = "Internal Affairs Jacket"
	desc = "A smooth black jacket."
	icon_state = "ia_jacket_open"
	item_state = "ia_jacket"
	blood_overlay_type = "coat"
	flags_armor_protection = CHEST|ARMS

/obj/item/clothing/suit/storage/internalaffairs/verb/toggle()
	set name = "Toggle Coat Buttons"
	set category = "Object"
	set src in usr

	if(!usr.canmove || usr.stat || usr.restrained())
		return FALSE

	switch(icon_state)
		if("ia_jacket_open")
			src.icon_state = "ia_jacket"
			to_chat(usr, "You button up the jacket.")
		if("ia_jacket")
			src.icon_state = "ia_jacket_open"
			to_chat(usr, "You unbutton the jacket.")
		else
			to_chat(usr, "You attempt to button-up the velcro on your [src], before promptly realising that it won't work.")
			return FALSE
	update_clothing_icon()	//so our overlays update

//Medical
/obj/item/clothing/suit/storage/fr_jacket
	name = "first responder jacket"
	desc = "A high-visibility jacket worn by medical first responders."
	icon_state = "fr_jacket_open"
	item_state = "fr_jacket"
	blood_overlay_type = "armor"
	allowed = list(
		/obj/item/stack/medical,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/syringe,
		/obj/item/healthanalyzer,
		/obj/item/flashlight,
		/obj/item/radio,
		/obj/item/tank/emergency_oxygen,
	)
	flags_armor_protection = CHEST|ARMS

/obj/item/clothing/suit/storage/fr_jacket/verb/toggle()
	set name = "Toggle Jacket Buttons"
	set category = "Object"
	set src in usr

	if(!usr.canmove || usr.stat || usr.restrained())
		return FALSE

	switch(icon_state)
		if("fr_jacket_open")
			src.icon_state = "fr_jacket"
			to_chat(usr, "You button up the jacket.")
		if("fr_jacket")
			src.icon_state = "fr_jacket_open"
			to_chat(usr, "You unbutton the jacket.")
	update_clothing_icon()	//so our overlays update

//Mime
/obj/item/clothing/suit/suspenders
	name = "suspenders"
	desc = "They suspend the illusion of the mime's play."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "suspenders"
	blood_overlay_type = "armor" //it's the less thing that I can put here
	flags_armor_protection = NONE

/obj/item/clothing/suit/storage/snow_suit
	name = "snow suit"
	desc = "A standard snow suit. It can protect the wearer from extreme cold."
	icon_state = "snowsuit_alpha"
	flags_armor_protection = CHEST|GROIN|ARMS
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS
	soft_armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	blood_overlay_type = "armor"
	siemens_coefficient = 0.7
	permeability_coefficient = 0.8
	allowed = list (/obj/item/flashlight, /obj/item/tank/emergency_oxygen)

/obj/item/clothing/suit/storage/snow_suit/doctor
	name = "doctor's snow suit"
	icon_state = "snowsuit_doctor"
	permeability_coefficient = 0.6
	soft_armor = list(MELEE = 25, BULLET = 35, LASER = 35, ENERGY = 20, BOMB = 10, BIO = 0, FIRE = 20, ACID = 20)

/obj/item/clothing/suit/storage/snow_suit/engineer
	name = "engineer's snow suit"
	icon_state = "snowsuit_engineer"
	soft_armor = list(MELEE = 25, BULLET = 35, LASER = 35, ENERGY = 20, BOMB = 10, BIO = 0, FIRE = 20, ACID = 20)
