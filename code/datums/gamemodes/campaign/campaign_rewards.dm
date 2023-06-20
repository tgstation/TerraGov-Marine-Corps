//specific rewards won during a campaign game

//todo: move to the actual define page
//campaign reward defines

///Whether this reward has been completed used and has no further effect
#define REWARD_CONSUMED (1<<0)
///This reward must be explicitly activated
#define REWARD_ACTIVATED_EFFECT (1<<1)
///This reward is active as soon as it is won
#define REWARD_IMMEDIATE_EFFECT (1<<2)
///This reward has a passive effect
#define REWARD_PASSIVE_EFFECT (1<<3)

/datum/campaign_reward
	///Name of this reward
	var/name = "Placeholder reward"
	///Basic description
	var/desc = "This is a reward. It's a placeholder"
	///Detailed description
	var/detailed_desc = "This is a placeholder reward. You shouldn't see this, it does nothing at all."
	///The faction associated with these stats
	var/datum/faction_stats/faction
	///reward related flags
	var/reward_flags = REWARD_ACTIVATED_EFFECT
	///Number of times this can be used
	var/uses = 1

/datum/campaign_reward/New(datum/faction_stats/winning_faction)
	. = ..()
	faction = winning_faction
	if(reward_flags & REWARD_IMMEDIATE_EFFECT)
		immediate_effect()
	if(reward_flags & REWARD_PASSIVE_EFFECT)
		passive_effect()

///Triggers any active effects of this reward
/datum/campaign_reward/proc/activated_effect() //this shit should be in come checker proc for sanity
	SHOULD_CALL_PARENT(TRUE)
	if((reward_flags & REWARD_CONSUMED) || uses <= 0)
		return FALSE

	uses --
	if(uses <= 0)
		reward_flags |= REWARD_CONSUMED
	return TRUE

///Triggers any immediate effects of this reward
/datum/campaign_reward/proc/immediate_effect()

///Triggers any passive effects of this reward
/datum/campaign_reward/proc/passive_effect()



//Parent for all 'spawn stuff' rewards
/datum/campaign_reward/equipment
	///list of objects to spawn when this reward is activated
	var/list/obj/equipment_to_spawn = list()

/datum/campaign_reward/equipment/activated_effect()
	. = ..()
	if(!.)
		return

	var/turf/spawn_location = get_turf(faction.faction_leader)  //placeholder spawn location

	playsound(spawn_location,'sound/effects/phasein.ogg', 80, FALSE)

	for(var/obj/object AS in equipment_to_spawn)
		new object(spawn_location)

/datum/campaign_reward/equipment/power_armor
	name = "B18 consignment"
	desc = "Two sets of B18 power armor."
	detailed_desc = "Your battalion has been assigned two sets of B18 power armor, available at your request. B18 is TGMC's premier infantry armor, providing superior protection, mobility and an advanced automedical system."
	uses = 2
	equipment_to_spawn = list(
		/obj/item/clothing/head/helmet/marine/specialist,
		/obj/item/clothing/gloves/marine/specialist,
		/obj/item/clothing/suit/storage/marine/specialist,
	)

/datum/campaign_reward/equipment/mech_heavy
	name = "Heavy combat mech"
	desc = "One heavy combat mech."
	detailed_desc = "Your battalion has been assigned a single Vanguard heavy combat mech. The Vanguard has extreme durability and offensive capability. Able to wade through the thickest of fighting with ease, it is the TGMC's premier assault mech, although its speed and maneuverability are somewhat lackluster."
	uses = 1
	equipment_to_spawn = list(
		/obj/vehicle/sealed/mecha/combat/greyscale/vanguard,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/heavy_cannon,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser_projector,
		/obj/item/mecha_ammo/vendable/heavycannon,
		/obj/item/mecha_ammo/vendable/heavycannon,
		/obj/item/mecha_ammo/vendable/heavycannon,
	)

//Parent for all bonus role rewards
/datum/campaign_reward/bonus_job
	///list of bonus jobs to grant for this reward
	var/list/datum/job/bonus_job_list = list()
	//todo: add functionality to have jobs available only for a single mission

/datum/campaign_reward/bonus_job/activated_effect()
	. = ..()
	if(!.)
		return

	for(var/job_type in bonus_job_list)
		var/datum/job/bonus_job = SSjob.type_occupations[job_type]
		bonus_job.add_job_positions(bonus_job_list[job_type])

/datum/campaign_reward/bonus_job/colonists
	bonus_job_list = list(
		/datum/job/som/mercenary/clf = 3,
	)


////test use only
//CLF recruit
/datum/job/som/mercenary/clf
	title = "Colonial militant"
	paygrade = "CLF1"
	comm_title = "CLF"
	skills_type = /datum/skills/fo
	outfit = /datum/outfit/job/som/mercenary/clf
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	html_description = {"
		<b>Difficulty</b>:Very Hard<br /><br />
		<b>You answer to the</b> commanding officer<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Campaign<br /><br /><br />
		<b>Duty</b>: Lead your platoon on the field. Take advantage of the military staff and assets you will need for the mission, keep good relations between command and the marines. Assist your commander if available.
	"}
	minimap_icon = "som_fieldcommander"
	job_cost = 0

/datum/job/som/mercenary/clf/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"blah blah blah"}) //update

/datum/outfit/job/som/mercenary/clf
	name = "CLF Standard"
	jobtype = /datum/job/som/mercenary/clf

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/dutch
	w_uniform = /obj/item/clothing/under/colonist
	shoes = /obj/item/clothing/shoes/marine/clf/full
	wear_suit = /obj/item/clothing/suit/storage/faction/militia
	belt = /obj/item/storage/belt/knifepouch
	suit_store = /obj/item/weapon/gun/smg/uzi/mag_harness
	gloves = /obj/item/clothing/gloves/black
	head = /obj/item/clothing/head/strawhat
	r_store = /obj/item/storage/pouch/medical_injectors/firstaid
	l_store = /obj/item/storage/pill_bottle/zoom
	back = /obj/item/storage/backpack/lightpack


/datum/outfit/job/som/mercenary/clf/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/uzi/extended, SLOT_IN_BACKPACK)
