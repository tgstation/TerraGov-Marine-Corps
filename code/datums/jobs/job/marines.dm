/datum/job/terragov/squad
	job_category = JOB_CAT_MARINE
	supervisors = "the acting squad leader"
	selection_color = "#ffeeee"
	exp_type_department = EXP_TYPE_MARINES


/datum/job/terragov/squad/after_spawn(mob/living/carbon/C, mob/M, latejoin = FALSE)
	. = ..()
	C.hud_set_squad()
	C.set_nutrition(rand(60, 250))
	if(!ishuman(C))
		return
	var/mob/living/carbon/human/human_spawn = C
	if(!human_spawn.assigned_squad)
		CRASH("after_spawn called for a marine without an assigned_squad")
	to_chat(M, {"\nYou have been assigned to: <b><font size=3 color=[human_spawn.assigned_squad.color]>[lowertext(human_spawn.assigned_squad.name)] squad</font></b>.
Make your way to the cafeteria for some post-cryosleep chow, and then get equipped in your squad's prep room."})


//Squad Marine
/datum/job/terragov/squad/standard
	title = SQUAD_MARINE
	paygrade = "E2"
	comm_title = "Mar"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_DROPSHIP)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	outfit = /datum/outfit/job/marine/standard
	total_positions = -1
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_REGULAR, /datum/job/terragov/squad/specialist = SPEC_POINTS_REGULAR, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR)


/datum/job/terragov/squad/standard/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are a rank-and-file soldier of the TGMC, and that is your strength.
What you lack alone, you gain standing shoulder to shoulder with the men and women of the corps. Ooh-rah!"})


/datum/outfit/job/marine/standard
	name = SQUAD_MARINE
	jobtype = /datum/job/terragov/squad/standard

	id = /obj/item/card/id/dogtag
	back = /obj/item/storage/backpack/marine/satchel

/datum/outfit/job/marine/standard/equipped
	name = "Squad Marine (Equipped)"

	ears = /obj/item/radio/headset/mainship/marine
	w_uniform = /obj/item/clothing/under/marine
	wear_suit = /obj/item/clothing/suit/storage/marine/harness
	shoes = /obj/item/clothing/shoes/marine
	gloves =/obj/item/clothing/gloves/marine
	l_store = /obj/item/storage/pouch/firstaid/full
	r_hand = /obj/item/portable_vendor/marine/squadmarine

/datum/outfit/job/marine/standard/equipped/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)

//Squad Engineer
/datum/job/terragov/squad/engineer
	title = SQUAD_ENGINEER
	paygrade = "E3"
	comm_title = "Eng"
	total_positions = 12
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_ENGPREP, ACCESS_CIVILIAN_ENGINEERING, ACCESS_MARINE_REMOTEBUILD, ACCESS_MARINE_ENGINEERING)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_ENGPREP, ACCESS_CIVILIAN_ENGINEERING, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_REMOTEBUILD, ACCESS_MARINE_ENGINEERING)
	skills_type = /datum/skills/combat_engineer
	display_order = JOB_DISPLAY_ORDER_SUQAD_ENGINEER
	outfit = /datum/outfit/job/marine/engineer
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_REGULAR, /datum/job/terragov/squad/specialist = SPEC_POINTS_MEDIUM, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_MEDIUM)

/datum/job/terragov/squad/engineer/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou have the equipment and skill to build fortifications, reroute power lines, and bunker down.
Your squaddies will look to you when it comes to construction in the field of battle."})


/datum/outfit/job/marine/engineer
	name = SQUAD_ENGINEER
	jobtype = /datum/job/terragov/squad/engineer

	id = /obj/item/card/id/dogtag
	back = /obj/item/storage/backpack/marine/satchel

/datum/outfit/job/marine/engineer/equipped
	name = "Squad Engineer (Equipped)"

	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/radio/headset/mainship/marine
	w_uniform = /obj/item/clothing/under/marine/engineer
	wear_suit = /obj/item/clothing/suit/storage/marine
	shoes = /obj/item/clothing/shoes/marine
	gloves =/obj/item/clothing/gloves/marine/insulated
	l_store = /obj/item/storage/pouch/firstaid/full
	r_store = /obj/item/storage/pouch/construction/equippedengineer
	r_hand = /obj/item/portable_vendor/marine/squadmarine/engineer
	l_hand = /obj/item/encryptionkey/engi
	back = /obj/item/storage/backpack/marine/engineerpack

/datum/outfit/job/marine/engineer/equipped/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_pistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_pistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/lightreplacer, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/circuitboard/general, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)

//Squad Corpsman
/datum/job/terragov/squad/corpsman
	title = SQUAD_CORPSMAN
	paygrade = "Corp"
	comm_title = "Med"
	total_positions = 16
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/combat_medic
	display_order = JOB_DISPLAY_ORDER_SQUAD_CORPSMAN
	outfit = /datum/outfit/job/marine/corpsman
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_REGULAR, /datum/job/terragov/squad/specialist = SPEC_POINTS_MEDIUM, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_MEDIUM)

/datum/job/terragov/squad/corpsman/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou must tend the wounds of your squad mates and make sure they are healthy and active.
You may not be a fully-fledged doctor, but you stand between life and death when it matters."})

/datum/outfit/job/marine/corpsman
	name = SQUAD_CORPSMAN
	jobtype = /datum/job/terragov/squad/corpsman

	id = /obj/item/card/id/dogtag
	back = /obj/item/storage/backpack/marine/corpsman

/datum/outfit/job/marine/corpsman/equipped
	name = "Squad Corpsman (Equipped)"

	belt = /obj/item/storage/belt/combatLifesaver
	ears = /obj/item/radio/headset/mainship/marine
	w_uniform = /obj/item/clothing/under/marine/corpsman
	wear_suit = /obj/item/clothing/suit/storage/marine
	shoes = /obj/item/clothing/shoes/marine
	gloves =/obj/item/clothing/gloves/marine
	head = /obj/item/clothing/head/helmet/marine/corpsman
	l_store = /obj/item/storage/pouch/medkit/equippedcorpsman
	r_store = /obj/item/storage/pouch/medical/equippedcorpsman
	glasses = /obj/item/clothing/glasses/hud/health
	r_hand = /obj/item/portable_vendor/marine/squadmarine/corpsman
	l_hand = /obj/item/encryptionkey/med

/datum/outfit/job/marine/corpsman/equipped/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/oxycodone, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/hyperzine, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/bicaridine, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/kelotane , SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/medevac_beacon, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/roller/medevac, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/bodybag/cryobag, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/advanced/bruise_pack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/advanced/bruise_pack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/advanced/ointment, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/advanced/ointment, SLOT_IN_BACKPACK)

//Squad Smartgunner
/datum/job/terragov/squad/smartgunner
	title = SQUAD_SMARTGUNNER
	paygrade = "E3"
	comm_title = "SGnr"
	total_positions = 4
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_SMARTPREP)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/smartgunner
	display_order = JOB_DISPLAY_ORDER_SQUAD_SMARTGUNNER
	outfit = /datum/outfit/job/marine/smartgunner
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_REGULAR)
	job_points_needed  = 10 //Redefined via config.

/datum/job/terragov/squad/smartgunner/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are the smartgunner. Your job is to provide heavy weapons support."})


/datum/outfit/job/marine/smartgunner
	name = SQUAD_SMARTGUNNER
	jobtype = /datum/job/terragov/squad/smartgunner

	id = /obj/item/card/id/dogtag
	back = /obj/item/storage/backpack/marine/satchel

/datum/outfit/job/marine/smartgunner/equipped
	name = "Squad Smartgunner (Equipped)"

	ears = /obj/item/radio/headset/mainship/marine
	w_uniform = /obj/item/clothing/under/marine
	wear_suit = /obj/item/clothing/suit/storage/marine/smartgunner
	shoes = /obj/item/clothing/shoes/marine
	gloves =/obj/item/clothing/gloves/marine
	head = /obj/item/clothing/head/helmet/marine
	l_store = /obj/item/storage/pouch/firstaid/full
	suit_store = /obj/item/weapon/gun/rifle/standard_smartmachinegun
	glasses = /obj/item/clothing/glasses/night/m56_goggles
	r_hand = /obj/item/portable_vendor/marine/squadmarine/smartgunner

/datum/outfit/job/marine/smartgunner/equipped/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar , SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)

//Squad Specialist
/datum/job/terragov/squad/specialist
	title = SQUAD_SPECIALIST
	req_admin_notify = TRUE
	paygrade = "E4"
	comm_title = "Spec"
	total_positions = 0
	max_positions = 0
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_SPECPREP)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_SPECPREP, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/specialist
	display_order = JOB_DISPLAY_ORDER_SQUAD_SPECIALIST
	outfit = /datum/outfit/job/marine/specialist
	exp_requirements = XP_REQ_INTERMEDIATE
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_STRONG)
	job_points_needed  = 10 //Redefined via config.


/datum/job/terragov/squad/specialist/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are the very rare and valuable weapon expert, trained to use special equipment.
You can serve a variety of roles, so choose carefully."})


/datum/outfit/job/marine/specialist
	name = SQUAD_SPECIALIST
	jobtype = /datum/job/terragov/squad/specialist

	id = /obj/item/card/id/dogtag
	back = /obj/item/storage/backpack/marine/satchel
	head = /obj/item/clothing/head/helmet/specrag

//Squad Leader
/datum/job/terragov/squad/leader
	title = SQUAD_LEADER
	req_admin_notify = TRUE
	paygrade = "E5"
	comm_title = "SL"
	total_positions = 4
	supervisors = "the acting field commander"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_DROPSHIP)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/SL
	display_order = JOB_DISPLAY_ORDER_SQUAD_LEADER
	outfit = /datum/outfit/job/marine/leader
	exp_requirements = XP_REQ_EXPERIENCED
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_REGULAR, /datum/job/terragov/squad/specialist = SPEC_POINTS_HIGH, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_HIGH)


/datum/job/terragov/squad/leader/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are responsible for the men and women of your squad. Make sure they are on task, working together, and communicating.
You are also in charge of communicating with command and letting them know about the situation first hand. Keep out of harm's way."})


/datum/outfit/job/marine/leader
	name = SQUAD_LEADER
	jobtype = /datum/job/terragov/squad/leader

	id = /obj/item/card/id/dogtag
	back = /obj/item/storage/backpack/marine/satchel

/datum/outfit/job/marine/leader/equipped
	name = "Squad Leader (Equipped)"

	ears = /obj/item/radio/headset/mainship/marine
	w_uniform = /obj/item/clothing/under/marine
	wear_suit = /obj/item/clothing/suit/storage/marine/leader
	shoes = /obj/item/clothing/shoes/marine
	gloves =/obj/item/clothing/gloves/marine
	head = /obj/item/clothing/head/helmet/marine/leader
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/rifle/standard_assaultrifle/rifleman
	l_store = /obj/item/storage/pouch/firstaid/full
	r_store = /obj/item/storage/pouch/medical/equippedcorpsman
	r_hand = /obj/item/storage/box/squadmarine/squadleader
	l_hand = /obj/item/encryptionkey/squadlead
	belt = /obj/item/storage/belt/marine/t12

/datum/outfit/job/marine/leader/equipped/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/squad_beacon, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/squad_beacon, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/squad_beacon/bomb, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/motiondetector, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/whistle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/binoculars/tactical, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)


/datum/job/terragov/squad/leader/after_spawn(mob/living/carbon/C, mob/M, latejoin = FALSE)
	. = ..()
	if(!latejoin || !ishuman(C))
		return
	var/mob/living/carbon/human/H = C
	if(!H.assigned_squad)
		return
	if(H.assigned_squad.squad_leader != H)
		if(H.assigned_squad.squad_leader)
			H.assigned_squad.demote_leader()
		H.assigned_squad.promote_leader(H)
