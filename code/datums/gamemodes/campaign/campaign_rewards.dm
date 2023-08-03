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

/datum/campaign_reward/Destroy(force, ...)
	faction = null
	return ..()

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
		/obj/vehicle/sealed/mecha/combat/greyscale/vanguard/noskill,
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

/datum/campaign_reward/bonus_job/colonial_militia
	name = "Colonial militia support"
	desc = "A colonial militia squad to augment our forces"
	detailed_desc = "A large number of militia job slots are opened at no attrition cost. \
	A local colonial militia sympathetic to our cause has offered a squad to support our troops. Equipped with lesser arms and armor than our own troops, but fairly numerous."
	bonus_job_list = list(
		/datum/job/som/mercenary/militia/leader = 1,
		/datum/job/som/mercenary/militia/medic = 2,
		/datum/job/som/mercenary/militia/standard = 9,
	)

//TODO: create new jobs
/datum/campaign_reward/bonus_job/freelancer
	name = "Freelancer team"
	desc = "A squad of freelance guns for hire to support our forces"
	detailed_desc = "A moderate number of freelancer job slots are opened at no attrition cost. \
	A contract has been bought for a squad of freelancers to augment our forces. With comparable equipment and training, they can help turn the tables when our forces are stretched thin."
	bonus_job_list = list(
		/datum/job/freelancer/leader/campaign_bonus = 1,
		/datum/job/freelancer/grenadier/campaign_bonus = 2,
		/datum/job/freelancer/medic/campaign_bonus = 1,
		/datum/job/freelancer/standard/campaign_bonus = 5,
	)

/datum/campaign_reward/bonus_job/icc
	name = "ICC strike team"
	desc = "A squad of ICC soldiers to support our forces"
	detailed_desc = "A moderate number of ICC job slots are opened at no attrition cost. \
	The ICC have authorised a small, local detachment of their troops to aid us in our conflict. They are well armed and armored, and could prove a valuable advantage in a fight."
	bonus_job_list = list(
		/datum/job/icc/leader/campaign_bonus = 1,
		/datum/job/icc/guard/campaign_bonus = 2,
		/datum/job/icc/medic/campaign_bonus = 1,
		/datum/job/icc/standard/campaign_bonus = 6,
	)

/datum/campaign_reward/bonus_job/pmc
	name = "PMC security detail"
	desc = "An elite PMC team to assist in a joint operation"
	detailed_desc = "A small number of PMC job slots are opened at no attrition cost. \
	NanoTrasen have authorised a small team of their PMC contractors to assist us in combat. With superior arms and armor, they a powerful tactical asset."
	bonus_job_list = list(
		/datum/job/pmc/leader/campaign_bonus = 1,
		/datum/job/pmc/gunner/campaign_bonus = 2,
		/datum/job/pmc/standard/campaign_bonus = 4,
	)

//Parent for all passive attrition modifiers
/datum/campaign_reward/attrition_modifier
	reward_flags = REWARD_PASSIVE_EFFECT
	///Modifier to faction passive attrition gain
	var/attrition_mod = 0

/datum/campaign_reward/attrition_modifier/passive_effect()
	faction.attrition_gain_multiplier += attrition_mod

/datum/campaign_reward/attrition_modifier/Destroy(force, ...)
	faction.attrition_gain_multiplier -= attrition_mod
	return ..()

/datum/campaign_reward/attrition_modifier/bonus_standard
	name = "Improved supply lines"
	desc = "+20% passive Attrition Point gain"
	detailed_desc = "Improved supply lines allow for the smooth transfer of men and materiel, allowing for the deployment of more combat forces."
	attrition_mod = 0.2

/datum/campaign_reward/attrition_modifier/malus_standard
	name = "Degraded supply lines"
	desc = "-20% passive Attrition Point gain"
	detailed_desc = "Damage to our supply lines have increased the difficulty and time required to move men and materiel, resulting in a lower deployment of combat forces."
	attrition_mod = -0.2

/datum/campaign_reward/teleporter_disabled
	name = "Teleporter Array disabled"
	desc = "Teleporter Array has been permenantly disabled"
	detailed_desc = "The Bluespace drive powering all Teleporter Arrays in the conflict zone has been destroyed, rending all Teleporter Arrays inoperable. You'll have to deploy the old fashion way from here on out."

/datum/campaign_reward/teleporter_disabled/immediate_effect()
	for(var/obj/structure/teleporter_array/teleporter AS in GLOB.teleporter_arrays)
		if(teleporter.faction != faction.faction)
			continue
		teleporter.teleporter_status = TELEPORTER_ARRAY_INOPERABLE
		to_chat(faction.faction_leader, span_warning("The Teleporter Array has been rendered inoperable."))
		return

/datum/campaign_reward/teleporter_charges
	name = "Delegated Teleporter Array access"
	desc = "+2 uses of the Teleporter Array"
	detailed_desc = "Central command have allocated the battalion with two additional uses of the Teleporter Array. Its extremely costly to run and demand is high across the conflict zone, so make them count."
	uses = 3

/datum/campaign_reward/teleporter_charges/activated_effect()
	. = ..()
	if(!.)
		return

	for(var/obj/structure/teleporter_array/teleporter AS in GLOB.teleporter_arrays)
		if(teleporter.faction != faction.faction)
			continue
		teleporter.charges ++
		to_chat(faction.faction_leader, span_warning("An additional activation of the Teleporter Array is now ready for use."))
		return

/datum/campaign_reward/teleporter_enabled
	name = "Enable Teleporter Array"
	desc = "Enables the use of the Teleporter Array for the current or next mission"
	detailed_desc = "Established a link between our Teleporter Array and its master Bluespace drive, allowing its operation during the current or next mission."
	uses = 2

/datum/campaign_reward/teleporter_enabled/activated_effect()
	var/datum/game_mode/hvh/campaign/mode = SSticker.mode
	var/datum/campaign_mission/current_mission = mode.current_mission
	if(!current_mission || (current_mission.mission_state == MISSION_STATE_FINISHED))
		to_chat(faction.faction_leader, span_warning("Unavailable until next mission confirmed."))
		return

	var/obj/structure/teleporter_array/friendly_teleporter
	for(var/obj/structure/teleporter_array/teleporter AS in GLOB.teleporter_arrays)
		if(teleporter.faction != faction.faction)
			continue
		if(teleporter.teleporter_status == TELEPORTER_ARRAY_INOPERABLE)
			to_chat(faction.faction_leader, span_warning("The Teleporter Array has been permanently disabled due to the destruction of the linked Bluespace drive."))
			return
		friendly_teleporter = teleporter
		break

	. = ..()
	if(!.)
		return

	friendly_teleporter.teleporter_status = TELEPORTER_ARRAY_READY
	to_chat(faction.faction_leader, span_warning("Teleporter Array powered up. Link to Bluespace drive confirmed. Ready for teleportation."))

/datum/campaign_reward/droppod_refresh
	name = "Rearm drop pod bays"
	desc = "replace all used drop pods"
	detailed_desc = "Replace all drop pods that have been previously deployed with refurbished units or ones from fleet storage, ready for immediate use."
	uses = 1

/datum/campaign_reward/droppod_refresh/activated_effect()
	. = ..()
	if(!.)
		return

	for(var/obj/structure/drop_pod_launcher/launcher AS in GLOB.droppod_bays)
		launcher.refresh_pod()
	to_chat(faction.faction_leader, span_warning("All drop pods have been restocked."))
	return

/datum/campaign_reward/droppod_enabled
	name = "Enable drop pods"
	desc = "Enables the use of drop pods for the current or next mission"
	detailed_desc = "Repositions the ship to allow for orbital drop pod insertion during the current or next mission."
	uses = 3

/datum/campaign_reward/droppod_enabled/activated_effect()
	var/datum/game_mode/hvh/campaign/mode = SSticker.mode
	var/datum/campaign_mission/current_mission = mode.current_mission

	if(!current_mission || (current_mission.mission_state == MISSION_STATE_FINISHED))
		to_chat(faction.faction_leader, span_warning("Unavailable until next mission confirmed."))
		return

	if(current_mission.mission_flags & MISSION_DISALLOW_DROPPODS)
		to_chat(faction.faction_leader, span_warning("External factors prevent the ship from repositioning at this time. Drop pods unavailable."))
		return

	. = ..()
	if(!.)
		return

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAMPAIGN_ENABLE_DROPPODS)
	to_chat(faction.faction_leader, span_warning("Ship repositioned, drop pods are now ready for use."))

/datum/campaign_reward/droppod_disable
	name = "Disable drop pods"
	desc = "Prevents the enemy from using drop pods in the current or next mission"
	detailed_desc = "Ground to Space weapon systems are activated to prevent TGMC close orbit support ships from positioning themselves for drop pod orbital assaults during the current or next mission."
	uses = 2

/datum/campaign_reward/droppod_disable/activated_effect()
	var/datum/game_mode/hvh/campaign/mode = SSticker.mode
	var/datum/campaign_mission/current_mission = mode.current_mission

	if(!current_mission || (current_mission.mission_state == MISSION_STATE_FINISHED))
		to_chat(faction.faction_leader, span_warning("Unavailable until next mission confirmed."))
		return

	if(current_mission.mission_flags & MISSION_DISALLOW_DROPPODS)
		to_chat(faction.faction_leader, span_warning("Enemy drop pods already unable to deploy during this mission."))
		return

	. = ..()
	if(!.)
		return

	current_mission.mission_flags |= MISSION_DISALLOW_DROPPODS
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAMPAIGN_DISABLE_DROPPODS)
	to_chat(faction.faction_leader, span_warning("Orbital deterrence systems activated. Enemy drop pods disabled for this mission."))
