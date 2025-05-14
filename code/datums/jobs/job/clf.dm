/datum/job/clf
	access = list(ACCESS_CLF_CARGO, ACCESS_CLF_TADPOLE)
	minimal_access = list(ACCESS_CLF_CARGO, ACCESS_CLF_TADPOLE)
	skills_type = /datum/skills/crafty
	faction = FACTION_CLF
	shadow_languages = list(/datum/language/xenocommon)
	job_category = JOB_CAT_MARINE

/datum/job/clf/after_spawn(mob/living/carbon/C, mob/M, latejoin = FALSE)
	. = ..()
	SSminimaps.add_marker(C, MINIMAP_FLAG_MARINE_CLF, image('ntf_modular/icons/UI_icons/map_blips.dmi', null, comm_title))
	var/datum/action/minimap/clf/mini = new
	mini.give_action(C)

/datum/job/clf/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"As a CLF member you are a ex NTC worker, now a servant of Xenomorphs, they are superior, evolved beings that you must serve.
You can understand but not speak xeno language but they can understand your language already, Obey your Xenomorph masters.
Your primary goal is to serve the hive, and ultimate goal is to liberate the colonies from all occupational forces so the Xenos may reclaim the lands, and breed your kind forever."})

//CLF Standard
/datum/job/clf/standard
	title = "CLF Standard"
	paygrade = "CLF1"
	comm_title = "CLF1"
	outfit = /datum/outfit/job/clf/standard/uzi
	job_flags = JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_LATEJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_OVERRIDELATEJOINSPAWN|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_ADDTOMANIFEST
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/clf/standard/uzi,
		/datum/outfit/job/clf/standard/skorpion,
		/datum/outfit/job/clf/standard/mpi_km,
		/datum/outfit/job/clf/standard/shotgun,
		/datum/outfit/job/clf/standard/garand,
		/datum/outfit/job/clf/standard/fanatic,
		/datum/outfit/job/clf/standard/som_smg,
	)

//the base loadout for all clf standards
/datum/outfit/job/clf/standard
	name = "CLF Standard"
	jobtype = /datum/job/clf/standard

	id = /obj/item/card/id/dogtag/clf
	ears = /obj/item/radio/headset/distress/dutch
	w_uniform = /obj/item/clothing/under/colonist
	shoes = /obj/item/clothing/shoes/marine/clf/full
	wear_suit = /obj/item/clothing/suit/storage/faction/militia
	gloves = /obj/item/clothing/gloves/black
	head = /obj/item/clothing/head/strawhat
	r_store = /obj/item/storage/pouch/medical_injectors/firstaid
	l_store = /obj/item/storage/pill_bottle/zoom
	back = /obj/item/storage/backpack/lightpack


/datum/outfit/job/clf/standard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)

/datum/outfit/job/clf/standard/uzi
	belt = /obj/item/storage/belt/knifepouch
	suit_store = /obj/item/weapon/gun/smg/uzi/mag_harness


/datum/outfit/job/clf/standard/uzi/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)

/datum/outfit/job/clf/standard/skorpion
	belt = /obj/item/weapon/gun/shotgun/double/sawn
	suit_store = /obj/item/weapon/gun/smg/skorpion/mag_harness

/datum/outfit/job/clf/standard/skorpion/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)

/datum/outfit/job/clf/standard/mpi_km
	belt = /obj/item/storage/belt/marine/som
	suit_store = /obj/item/weapon/gun/rifle/mpi_km/standard


/datum/outfit/job/clf/standard/mpi_km/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)

/datum/outfit/job/clf/standard/shotgun
	belt = /obj/item/storage/belt/shotgun
	suit_store = /obj/item/weapon/gun/shotgun/pump/standard

/datum/outfit/job/clf/standard/shotgun/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)

/datum/outfit/job/clf/standard/fanatic
	head = /obj/item/clothing/head/headband/rambo
	wear_suit = /obj/item/clothing/suit/storage/marine/boomvest/fast
	belt = /obj/item/weapon/gun/shotgun/double/sawn
	suit_store = /obj/item/weapon/gun/smg/skorpion/mag_harness

/datum/outfit/job/clf/standard/fanatic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)

/datum/outfit/job/clf/standard/som_smg
	belt = /obj/item/storage/belt/marine/som
	suit_store = /obj/item/weapon/gun/smg/som/basic


/datum/outfit/job/clf/standard/som_smg/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)

/datum/outfit/job/clf/standard/garand
	belt = /obj/item/storage/belt/marine/som
	suit_store = /obj/item/weapon/gun/rifle/garand


/datum/outfit/job/clf/standard/garand/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/garand, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/garand, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/garand, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/garand, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/garand, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/garand, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)

//CLF Medic
/datum/job/clf/medic
	title = "CLF Medic"
	paygrade = "CLF2"
	comm_title = "CLF2"
	job_flags = JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_LATEJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_OVERRIDELATEJOINSPAWN|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_ADDTOMANIFEST
	skills_type = /datum/skills/combat_medic/crafty
	outfit = /datum/outfit/job/clf/medic/uzi
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/clf/medic/uzi,
		/datum/outfit/job/clf/medic/skorpion,
		/datum/outfit/job/clf/medic/paladin,
	)
	access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_CLF_CARGO, ACCESS_CLF_TADPOLE)
	minimal_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_CLF_CARGO, ACCESS_CLF_TADPOLE)

//the base loadout for all clf medics
/datum/outfit/job/clf/medic
	name = "CLF Medic"
	jobtype = /datum/job/clf/medic

	id = /obj/item/card/id/dogtag/clf
	belt = /obj/item/storage/belt/lifesaver/full/upp
	ears = /obj/item/radio/headset/distress/dutch
	head = /obj/item/clothing/head/tgmcberet/bloodred
	w_uniform = /obj/item/clothing/under/colonist
	shoes = /obj/item/clothing/shoes/marine/clf/full
	wear_suit = /obj/item/clothing/suit/storage/faction/militia
	gloves = /obj/item/clothing/gloves/black
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/smg/skorpion
	l_store = /obj/item/storage/pouch/medical_injectors/medic
	back = /obj/item/storage/backpack/lightpack


/datum/outfit/job/clf/medic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/tweezers, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)

/datum/outfit/job/clf/medic/uzi
	suit_store = /obj/item/weapon/gun/smg/uzi/mag_harness
	r_store = /obj/item/storage/holster/flarepouch

/datum/outfit/job/clf/medic/uzi/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/grenade_launcher/single_shot/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)

/datum/outfit/job/clf/medic/skorpion
	suit_store = /obj/item/weapon/gun/smg/skorpion/mag_harness
	r_store = /obj/item/storage/holster/flarepouch

/datum/outfit/job/clf/medic/skorpion/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/grenade_launcher/single_shot/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flare, SLOT_IN_R_POUCH)

/datum/outfit/job/clf/medic/paladin
	suit_store = /obj/item/weapon/gun/shotgun/pump/cmb/mag_harness
	r_store = /obj/item/storage/pouch/shotgun

/datum/outfit/job/clf/medic/paladin/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_R_POUCH)

//CLF Specialist
/datum/job/clf/specialist
	title = "CLF Specialist"
	paygrade = "CLF4"
	comm_title = "CLF4"
	skills_type = /datum/skills/crafty
	job_flags = JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_LATEJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_OVERRIDELATEJOINSPAWN|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_ADDTOMANIFEST
	outfit = /datum/outfit/job/clf/specialist
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/clf/specialist/dpm,
		/datum/outfit/job/clf/specialist/clf_heavyrifle,
		/datum/outfit/job/clf/specialist/clf_heavymachinegun,
	)

//The base loadout for all CLF Specialists
/datum/outfit/job/clf/specialist
	name = "CLF Specialist"
	jobtype = /datum/job/clf/specialist

	id = /obj/item/card/id/dogtag/clf
	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/distress/dutch
	w_uniform = /obj/item/clothing/under/colonist/webbing
	shoes = /obj/item/clothing/shoes/black
	wear_suit = /obj/item/clothing/suit/storage/faction/militia
	gloves = /obj/item/clothing/gloves/black
	head = /obj/item/clothing/head/helmet/marine
	r_store = /obj/item/storage/pouch/pistol
	l_store = /obj/item/storage/pouch/medical_injectors/firstaid


/datum/outfit/job/clf/specialist/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/highpower(H), SLOT_IN_R_POUCH)

/datum/outfit/job/clf/specialist/dpm
	suit_store = /obj/item/weapon/gun/rifle/dpm

/datum/outfit/job/clf/specialist/dpm/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/dpm, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/dpm, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/dpm, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/dpm, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/dpm, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/dpm, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)

/datum/outfit/job/clf/specialist/clf_heavyrifle
	suit_store = /obj/item/weapon/gun/clf_heavyrifle
	back = /obj/item/shotgunbox/clf_heavyrifle
	belt = /obj/item/storage/belt/utility/full

/datum/outfit/job/clf/specialist/clf_heavyrifle/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)

/datum/outfit/job/clf/specialist/clf_heavymachinegun
	suit_store = /obj/item/weapon/gun/icc_hmg
	belt = /obj/item/storage/belt/sparepouch
	back = /obj/item/storage/backpack/lightpack

/datum/outfit/job/clf/specialist/clf_heavymachinegun/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/icc_hmg, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/icc_hmg, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/icc_hmg, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)


//CLF Leader
/datum/job/clf/leader
	title = "CLF Leader"
	paygrade = "CLF3"
	comm_title = "CLF3"
	job_flags = JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_LATEJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_OVERRIDELATEJOINSPAWN|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_ADDTOMANIFEST
	skills_type = /datum/skills/sl/clf
	outfit = /datum/outfit/job/clf/leader/assault_rifle
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/clf/leader/assault_rifle,
		/datum/outfit/job/clf/leader/mpi_km,
		/datum/outfit/job/clf/leader/som_rifle,
		/datum/outfit/job/clf/leader/upp_rifle,
		/datum/outfit/job/clf/leader/lmg_d,
	)

//the base loadout for all clf leaders
/datum/outfit/job/clf/leader
	name = "CLF Leader"
	jobtype = /datum/job/clf/leader

	id = /obj/item/card/id/dogtag/clf
	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/distress/dutch
	w_uniform = /obj/item/clothing/under/colonist/webbing
	shoes = /obj/item/clothing/shoes/black
	wear_suit = /obj/item/clothing/suit/storage/faction/militia
	gloves = /obj/item/clothing/gloves/black
	head = /obj/item/clothing/head/militia
	glasses = /obj/item/clothing/glasses/hud/health
	r_store = /obj/item/storage/pouch/pistol
	l_store = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/lightpack


/datum/outfit/job/clf/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/highpower(H), SLOT_IN_R_POUCH)

/datum/outfit/job/clf/leader/assault_rifle
	suit_store = /obj/item/weapon/gun/rifle/m16/ugl

/datum/outfit/job/clf/leader/assault_rifle/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)

/datum/outfit/job/clf/leader/mpi_km
	suit_store = /obj/item/weapon/gun/rifle/mpi_km/grenadier
	belt = /obj/item/storage/belt/marine/som

/datum/outfit/job/clf/leader/mpi_km/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)

/datum/outfit/job/clf/leader/som_rifle
	suit_store = /obj/item/weapon/gun/rifle/som/basic
	belt = /obj/item/storage/belt/marine/som

/datum/outfit/job/clf/leader/som_rifle/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/smoke_burst, SLOT_IN_ACCESSORY)

/datum/outfit/job/clf/leader/upp_rifle
	suit_store = /obj/item/weapon/gun/rifle/type71/flamer/standard

/datum/outfit/job/clf/leader/upp_rifle/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)

/datum/outfit/job/clf/leader/lmg_d
	suit_store = /obj/item/weapon/gun/rifle/lmg_d/magharness
	belt = /obj/item/storage/belt/marine/som

/datum/outfit/job/clf/leader/lmg_d/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lmg_d, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lmg_d, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lmg_d, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lmg_d, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lmg_d, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lmg_d, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)

/datum/job/clf/breeder
	title = "CLF Breeder"
	paygrade = "CLF0"
	comm_title = "CLF0"
	outfit = /datum/outfit/job/clf/breeder
	job_flags = JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_LATEJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_OVERRIDELATEJOINSPAWN|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_ADDTOMANIFEST
	multiple_outfits = FALSE

/datum/outfit/job/clf/breeder
	name = "CLF Breeder"
	jobtype = /datum/job/clf/breeder

	id = /obj/item/card/id/dogtag/clf
	ears = /obj/item/radio/headset/distress/dutch
	w_uniform = /obj/item/clothing/under/swimsuit/purple
	shoes = /obj/item/clothing/shoes/sandal
	belt = /obj/item/storage/holster/t19/full
	r_store = /obj/item/flashlight
	back = /obj/item/storage/backpack/lightpack

/datum/outfit/job/clf/breeder/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/tramadol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/kelotane, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/dylovene, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/spaceacillin, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/monkeycube/wrapped, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/monkeycube/wrapped, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_BELT)

/datum/job/clf/silicon
	job_category = JOB_CAT_SILICON
	selection_color = "#aaee55"

//synthetic
/datum/job/clf/silicon/synthetic/clf
	title = "CLF Synthetic"
	req_admin_notify = TRUE
	comm_title = "Syn"
	paygrade = "Mk.I"
	supervisors = "the xenomorphs and CLF"
	total_positions = 1
	skills_type = /datum/skills/synthetic
	access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_CLF_CARGO, ACCESS_CLF_TADPOLE)
	minimal_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_CLF_CARGO, ACCESS_CLF_TADPOLE)
	display_order = JOB_DISPLAY_ORDER_SYNTHETIC
	outfit = /datum/outfit/job/civilian/synthetic/clf
	exp_requirements = XP_REQ_EXPERIENCED
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_SPECIALNAME|JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_ALWAYS_VISIBLE_ON_MINIMAP
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE_STRONG,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Soul Crushing<br /><br />
		<b>You answer to the</b> acting Command Staff and the human crew<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Crash, Nuclear War<br /><br /><br />
		<b>Duty</b>: Be a synthussy.
	"}
	minimap_icon = "synth"

/datum/job/clf/silicon/synthetic/clf/get_special_name(client/preference_source)
	return preference_source.prefs.synthetic_name

/datum/job/clf/silicon/synthetic/clf/return_spawn_type(datum/preferences/prefs)
	if(prefs?.synthetic_type == "Early Synthetic")
		return /mob/living/carbon/human/species/early_synthetic
	return /mob/living/carbon/human/species/synthetic

/datum/job/clf/silicon/synthetic/clf/return_skills_type(datum/preferences/prefs)
	if(prefs?.synthetic_type == "Early Synthetic")
		return /datum/skills/early_synthetic
	return ..()

/datum/job/clf/silicon/synthetic/clf/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 600) // starting
			new_human.wear_id.paygrade = "Mk.I"
		if(601 to 1500) // 10hrs
			new_human.wear_id.paygrade = "Mk.II"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "Mk.III"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "Mk.IV"
		if(18001 to INFINITY) // 300 hrs
			new_human.wear_id.paygrade = "Mk.V"

/datum/job/clf/silicon/synthetic/clf/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"Your primary job is to support and assist all clf departments and personnel on-board.
In addition, being a Synthetic gives you knowledge in every field and specialization possible on-board the ship."})


/datum/outfit/job/civilian/synthetic/clf
	name = SYNTHETIC
	jobtype = /datum/job/clf/silicon/synthetic

	id = /obj/item/card/id/dogtag/clf
	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/radio/headset/distress/dutch
	w_uniform = /obj/item/clothing/under/rank/synthetic
	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/insulated
	r_store = /obj/item/storage/pouch/general/medium
	l_store = /obj/item/storage/pouch/general/medium
