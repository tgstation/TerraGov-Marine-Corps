#define JOB_DISPLAY_ORDER_MILITARY_POLICE 25
#define MILITARY_POLICE "Military Policeman"

/obj/item/storage/belt/security/mp/Initialize()
	. = ..()
	new /obj/item/explosive/grenade/flashbang(src)
	new /obj/item/explosive/grenade/chem_grenade/teargas(src)
	new /obj/item/reagent_containers/spray/pepper(src)
	new /obj/item/restraints/handcuffs(src)
	new /obj/item/restraints/handcuffs(src)
	new /obj/item/flash(src)
	new /obj/item/weapon/baton(src)

/obj/item/storage/pouch/magazine/large/laser
	fill_type = /obj/item/cell/lasgun/lasrifle
	fill_number = 3

/obj/item/card/id/sec
	name = "identification card"
	desc = "A security card which shows law and order."
	icon_state = "sec"
	item_state = "silver_id"

/datum/skills/military_police
	name = MILITARY_POLICE
	cqc = SKILL_CQC_MP
	police = SKILL_POLICE_MP
	medical = SKILL_MEDICAL_PRACTICED
	pistols = SKILL_PISTOLS_TRAINED
	firearms = SKILL_FIREARMS_TRAINED
	shotguns = SKILL_SHOTGUNS_TRAINED

/datum/job/terragov/command/military_police
	title = MILITARY_POLICE
	paygrade = "MP"
	comm_title = "MP"
	total_positions = 0
	access = list(ACCESS_MARINE_BRIDGE, ACCESS_MARINE_BRIG, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_CIVILIAN_MEDICAL)
	minimal_access = ALL_MARINE_ACCESS
	skills_type = /datum/skills/military_police
	display_order = JOB_DISPLAY_ORDER_MILITARY_POLICE
	outfit = /datum/outfit/job/command/military_police
	exp_requirements = XP_REQ_INTERMEDIATE
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_ALWAYS_VISIBLE_ON_MINIMAP
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Death<br /><br />
		<b>You answer to the</b> Captain<br /><br />
		<b>Unlock Requirement</b>: 10h as any TGMC<br /><br />
		<b>Gamemode Availability</b>: Distress<br /><br /><br />
		<b>Duty</b>: Your primary job is to uphold the law, order, peace and stability aboard the ship. Marines can get rowdy after a few weeks of cryosleep!
In addition, you are tasked with the security of high-ranking personnel, including the command staff. Keep them safe!
	"}

	minimap_icon = "military_police"

/datum/job/terragov/command/military_police/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"Your primary job is to uphold the law, order, peace and stability aboard the ship. Marines can get rowdy after a few weeks of cryosleep!
In addition, you are tasked with the security of high-ranking personnel, including the command staff. Keep them safe!"})

/datum/outfit/job/command/military_police
	name = MILITARY_POLICE
	jobtype = /datum/job/terragov/command/military_police

	id = /obj/item/card/id/sec
	ears = /obj/item/radio/headset/mainship/mp
	belt = /obj/item/storage/belt/security/mp
	w_uniform = /obj/item/clothing/under/marine/mp
	shoes = /obj/item/clothing/shoes/jackboots/mp
	head = /obj/item/clothing/head/beret/sec/mp
	glasses = /obj/item/clothing/glasses/sunglasses/sechud/mp
	r_store = /obj/item/storage/pouch/magazine/large/laser
	l_store = /obj/item/storage/pouch/pistol/laserpistol
	gloves = /obj/item/clothing/gloves/marine/mp
	back = /obj/item/storage/backpack/satchel/sec
	wear_suit = /obj/item/clothing/suit/armor/bulletproof/mp
	suit_store = /obj/item/weapon/gun/energy/taser

/obj/item/radio/headset/mainship/mp
	name = "security radio headset"
	icon_state = "mp_headset"
	keyslot = /obj/item/encryptionkey/mcom

/obj/item/storage/pouch/pistol/laserpistol/Initialize()
	. = ..()
	new /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol/tactical(src)

/obj/item/clothing/glasses/sunglasses/sechud/mp/Initialize()
	. = ..()
	AddComponent(/datum/component/clothing_tint, TINT_NONE)

/obj/item/reagent_containers/hypospray/attack(mob/living/carbon/M as mob, mob/user as mob)
	var/mob/living/carbon/human/H = M
	var/datum/limb/affecting = H.get_limb(user.zone_selected)

	if(affecting.body_part == HEAD)
		if(H.head && istype(H.head,/obj/item/clothing/head/beret/sec/mp))
			to_chat(user, span_warning("You can't apply [src] through [H.head]!"))
			return TRUE
	else
		if(H.wear_suit && istype(H.wear_suit,/obj/item/clothing/suit/armor/bulletproof/mp))
			to_chat(user, span_warning("You can't apply [src] through [H.wear_suit]!"))
			return TRUE

/obj/item/clothing/suit/armor/bulletproof/mp
	name = "security bulletproof vest"
	soft_armor = list(MELEE = 35, BULLET = 95, LASER = 95, ENERGY = 0, BOMB = 30, BIO = 95, FIRE = 0, ACID = 15)

/obj/item/clothing/head/beret/sec/mp
	soft_armor = list(MELEE = 10, BULLET = 75, LASER = 75, ENERGY = 0, BOMB = 0, BIO = 85, FIRE = 0, ACID = 0)

/obj/item/clothing/shoes/jackboots/mp
	soft_armor = list(MELEE = 10, BULLET = 85, LASER = 85, ENERGY = 5, BOMB = 0, BIO = 85, FIRE = 0, ACID = 0)

/obj/item/clothing/gloves/marine/mp
	name = "security combat gloves"
	desc = "Standard issue military police tactical gloves. It reads: 'knit by Marine Widows Association'."
	soft_armor = list(MELEE = 15, BULLET = 80, LASER = 80, ENERGY = 0, BOMB = 0, BIO = 90, FIRE = 0, ACID = 0)
