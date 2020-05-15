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
	flags_armor_protection = 0
	allowed = list (
		/obj/item/reagent_containers/spray/plantbgone,
		/obj/item/analyzer/plant_analyzer,
		/obj/item/seeds,
		/obj/item/reagent_containers/glass/fertilizer,
		/obj/item/tool/minihoe
	)
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/suit.dmi')


/obj/item/clothing/suit/surgical
	name = "surgical apron"
	desc = "A plastic covering to prevent the passage of bodily fluids during surgery."
	icon_state = "surgical"
	item_state = "surgical"
	flags_armor_protection = CHEST
	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0)
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/suit.dmi')


//Captain
/obj/item/clothing/suit/captunic
	name = "captain's parade tunic"
	desc = "Worn by a Captain to show their class."
	icon_state = "captunic"
	item_state = "bio_suit"
	flags_armor_protection = CHEST|ARMS
	flags_inv_hide = HIDEJUMPSUIT
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/suit.dmi')

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
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/suit.dmi')

/obj/item/clothing/suit/nun
	name = "nun robe"
	desc = "Maximum piety in this star system."
	icon_state = "nun"
	item_state = "nun"
	flags_armor_protection = CHEST|GROIN|LEGS|ARMS
	flags_inv_hide = HIDESHOES|HIDEJUMPSUIT
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/suit.dmi')

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
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/suit.dmi')

/obj/item/clothing/suit/chef/classic
	name = "A classic chef's apron."
	desc = "A basic, dull, white chef's apron."
	icon_state = "apronchef"
	item_state = "apronchef"
	blood_overlay_type = "armor"
	flags_armor_protection = 0

//Security
/obj/item/clothing/suit/security/navyofficer
	name = "security officer's jacket"
	desc = "This jacket is for those special occasions when a security officer actually feels safe."
	icon_state = "officerbluejacket"
	item_state = "officerbluejacket"
	flags_armor_protection = CHEST|GROIN|ARMS

/obj/item/clothing/suit/security/navywarden
	name = "warden's jacket"
	desc = "Perfectly suited for the warden that wants to leave an impression of style on those who visit the brig."
	icon_state = "wardenbluejacket"
	item_state = "wardenbluejacket"
	flags_armor_protection = CHEST|GROIN|ARMS

/obj/item/clothing/suit/security/navyhos
	name = "head of security's jacket"
	desc = "This piece of clothing was specifically designed for asserting superior authority."
	icon_state = "hosbluejacket"
	item_state = "hosbluejacket"
	flags_armor_protection = CHEST|GROIN|ARMS

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
		/obj/item/taperecorder
	)
	soft_armor = list("melee" = 50, "bullet" = 10, "laser" = 25, "energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 10, "acid" = 10)
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/suit.dmi')

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
		/obj/item/taperecorder
	)
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 15, "energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 10, "acid" = 10)

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
	name = "hazard vest"
	desc = "A high-visibility vest used in work zones."
	icon_state = "hazard"
	item_state = "hazard"
	blood_overlay_type = "armor"
	allowed = list(
		/obj/item/analyzer,
		/obj/item/flashlight,
		/obj/item/multitool,
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
		/obj/item/tool/taperoll/engineering
	)
	flags_armor_protection = CHEST

	sprite_sheets = list("Vox" = 'icons/mob/species/vox/suit.dmi')

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
		/obj/item/tank/emergency_oxygen
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
	flags_armor_protection = 0
