/datum/loadout_item/uniform
	item_slot = ITEM_SLOT_ICLOTHING

/datum/loadout_item/uniform/empty
	name = "no uniform"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/uniform/marine_standard
	name = "TGMC uniform"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented marine uniform. You suspect it's not as robust-proof as advertised."
	item_typepath = /obj/item/clothing/under/marine/black_vest
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER)

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

/datum/loadout_item/uniform/marine_corpsman
	name = "corpsman fatigues"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/under/marine/corpsman/corpman_vest
	jobs_supported = list(SQUAD_CORPSMAN)
