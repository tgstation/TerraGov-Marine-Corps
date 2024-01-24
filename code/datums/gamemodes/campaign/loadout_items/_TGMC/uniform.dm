/datum/loadout_item/uniform
	item_slot = ITEM_SLOT_ICLOTHING

/datum/loadout_item/uniform/empty
	name = "no uniform"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
	jobs_supported = list(
		SQUAD_MARINE,
		SQUAD_CORPSMAN,
		SQUAD_ENGINEER,
		SQUAD_SMARTGUNNER,
		SQUAD_LEADER,
		FIELD_COMMANDER,
		STAFF_OFFICER,
		CAPTAIN,
		SOM_SQUAD_MARINE,
		SOM_SQUAD_CORPSMAN,
		SOM_SQUAD_ENGINEER,
		SOM_SQUAD_VETERAN,
		SOM_SQUAD_LEADER,
		SOM_FIELD_COMMANDER,
		SOM_STAFF_OFFICER,
		SOM_COMMANDER,
	)


/datum/loadout_item/uniform/marine_standard
	name = "TGMC uniform"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented marine uniform. You suspect it's not as robust-proof as advertised."
	item_typepath = /obj/item/clothing/under/marine/black_vest
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/uniform/red_fatigue
	name = "Big Red fatigues"
	desc = "Originated from Big Red. Designed for dry, low humid, and Mars-eqse environments, they're meant for recon, stealth, and evac operations. \
	They come with a built in cassette player hearable only to the user to help pass time, during any possible long waits. They make you feel like one with the desert, \
	forged by the beating Sun. Rumors had it that it can recycle your sweat and urine for drinkable water!"
	item_typepath = /obj/item/clothing/under/marine/red_fatigue/black_vest
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER)

/datum/loadout_item/uniform/striped_fatigue
	name = "Striped fatigues"
	desc = "A simple set of camo pants and a striped shirt."
	item_typepath = /obj/item/clothing/under/marine/striped/black_vest
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER)

/datum/loadout_item/uniform/lv_fatigue
	name = "LV-624 fatigues"
	desc = "Originated from LV-624. Designed for wet, high humid, and jungle environments, they're meant for recon, stealth, and evac operations. \
	They come with a built in cassette player hearable only to the user to help pass time, during any possible long waits. \
	Somewhere, someone is playing 'Fortunate Sons' in the background, and you can smell napalm and Agent Orange in the air..."
	item_typepath = /obj/item/clothing/under/marine/lv_fatigue/black_vest
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER)

/datum/loadout_item/uniform/orion_fatigue
	name = "Orion fatigues"
	desc = "Originated from Orion Military Outpost. Designed for ship and urban environments, they're meant for recon, stealth, and evac operations. \
	They come with a built in cassette player hearable only to the user to help pass time, during any possible long waits. They're the definition of over-funded ideas, \
	least they look neat. It is very likely that a boot fresh from boot camp to buy this at the BX with his E-1 pay because of how tacticool it looks."
	item_typepath = /obj/item/clothing/under/marine/orion_fatigue/black_vest
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER)

/datum/loadout_item/uniform/white_dress
	name = "white dress uniform"
	desc = "A standard-issue TerraGov Marine Corps white dress uniform. \
	The starch in the fabric chafes a small amount but it pales in comparison to the pride you feel when you first put it on during graduation from boot camp. Doesn't seem to fit perfectly around the waist though."
	item_typepath = /obj/item/clothing/under/marine/whites
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER, STAFF_OFFICER, CAPTAIN)

//corpsman
/datum/loadout_item/uniform/marine_corpsman
	name = "corpsman fatigues"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented combat corpsman fatigues. You suspect it's not as robust-proof as advertised."
	item_typepath = /obj/item/clothing/under/marine/corpsman/corpman_vest
	jobs_supported = list(SQUAD_CORPSMAN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/uniform/marine_corpsman/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/bodybag/cryobag, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tweezers_advanced, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/nanoblood, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/spaceacillin, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/combat_advanced, SLOT_IN_ACCESSORY)

//engineer
/datum/loadout_item/uniform/marine_engineer
	name = "Engineer fatigues"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented combat engineer fatigues. You suspect it's not as robust-proof as advertised."
	req_desc = "Requires a tool pouch. You ARE an engineer, right?"
	item_typepath = /obj/item/clothing/under/marine/engineer/black_vest
	jobs_supported = list(SQUAD_ENGINEER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
	item_whitelist = list(
		/obj/item/storage/pouch/tools/full = ITEM_SLOT_R_POCKET,
	)

//FC
/datum/loadout_item/uniform/field_commander
	name = "FC uniform"
	desc = "A special-issue, kevlar-weaved, hazmat-tested, EMF-augmented worn by a field-grade officer of the TGMC. You suspect it's not as robust-proof as advertised."
	item_typepath = /obj/item/clothing/under/marine/officer/exec/webbing
	jobs_supported = list(FIELD_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

//Staff officer
/datum/loadout_item/uniform/staff_officer
	name = "SO uniform"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented staff officer uniform. Do the navy proud."
	item_typepath = /obj/item/clothing/under/marine/officer/bridge
	jobs_supported = list(STAFF_OFFICER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

//Captain
/datum/loadout_item/uniform/captain_officer
	name = "Captain uniform"
	desc = "A special-issue, well-ironed, kevlar-weaved, hazmat-tested, EMF-augmented uniform worth of a TerraGov Naval Captain. Even looking at it the wrong way could result in being court-martialed."
	item_typepath = /obj/item/clothing/under/marine/officer/command
	jobs_supported = list(CAPTAIN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
