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
///Can't activate unless mission is starting or started
#define REWARD_ACTIVE_MISSION_ONLY (1<<4)
///Temporarily unusable
#define REWARD_DISABLED (1<<5)
///Currently active, used for UI purposes
#define REWARD_ACTIVE (1<<6)
///debuff, used for UI purposes
#define REWARD_DEBUFF (1<<7)

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
	///Cost in attrition points if this reward is purchased
	var/cost = 1

	var/ui_icon = "test"

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
/datum/campaign_reward/proc/activated_effect() //this shit should probably be in some checker proc for sanity
	SHOULD_CALL_PARENT(TRUE)
	if((reward_flags & REWARD_CONSUMED) || reward_flags & REWARD_DISABLED || uses <= 0)
		return FALSE

	if(reward_flags & REWARD_ACTIVE_MISSION_ONLY)
		var/datum/game_mode/hvh/campaign/mode = SSticker.mode
		var/datum/campaign_mission/current_mission = mode.current_mission
		if(!current_mission || (current_mission.mission_state == MISSION_STATE_FINISHED))
			to_chat(faction.faction_leader, span_warning("Unavailable until next mission confirmed."))
			return

	uses --
	if(uses <= 0)
		reward_flags |= REWARD_CONSUMED
	return TRUE

///Triggers any immediate effects of this reward
/datum/campaign_reward/proc/immediate_effect()
	return
///Triggers any passive effects of this reward
/datum/campaign_reward/proc/passive_effect() //functionally identical to immediate effect, but specifically intended to be removable, and displayed differently in the UI
	return

/datum/campaign_reward/proc/remove_passive_effect()
	return

///Deactivates the asset once the mission is over
/datum/campaign_reward/proc/deactivate()
	SIGNAL_HANDLER
	reward_flags &= ~REWARD_ACTIVE
	UnregisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED)

//Parent for all 'spawn stuff' rewards
/datum/campaign_reward/equipment
	///list of objects to spawn when this reward is activated
	var/list/obj/equipment_to_spawn = list()

/datum/campaign_reward/equipment/activated_effect()
	. = ..()
	if(!.)
		return

	var/turf/spawn_location = get_turf(pick(GLOB.campaign_reward_spawners[faction.faction]))
	playsound(spawn_location,'sound/effects/phasein.ogg', 80, FALSE)
	for(var/obj/object AS in equipment_to_spawn)
		new object(spawn_location)

/datum/campaign_reward/equipment/power_armor
	name = "B18 consignment"
	desc = "Three sets of B18 power armor."
	detailed_desc = "Your battalion has been assigned a number of B18 power armor sets, available at your request. B18 is TGMC's premier infantry armor, providing superior protection, mobility and an advanced automedical system."
	uses = 3
	cost = 15
	ui_icon = "b18"
	equipment_to_spawn = list(
		/obj/item/clothing/head/helmet/marine/specialist,
		/obj/item/clothing/gloves/marine/specialist,
		/obj/item/clothing/suit/storage/marine/specialist,
	)

/datum/campaign_reward/equipment/gorgon_armor
	name = "Gorgon consignment"
	desc = "Five sets of Gorgon power armor."
	detailed_desc = "Your battalion has been assigned a number of Gorgon power armor sets, available at your request. Gorgon armor is the SOM's elite infantry armor, providing superior protection and an automedical system without significantly compromising on speed."
	uses = 5
	cost = 10
	ui_icon = "gorgon"
	equipment_to_spawn = list(
		/obj/item/clothing/head/modular/som/leader,
		/obj/item/clothing/suit/modular/som/heavy/leader/valk,
	)

/datum/campaign_reward/equipment/medkit_basic
	name = "Medical supplies"
	desc = "A small number of medkits."
	detailed_desc = "A number of medkits with some basic medical supplies."
	ui_icon = "medkit"
	uses = 2
	cost = 1
	equipment_to_spawn = list(
		/obj/effect/supply_drop/medical_basic,
	)

/datum/campaign_reward/equipment/materials_pack
	name = "Construction supplies"
	desc = "Metal, plasteel and sandbags."
	detailed_desc = "A significant quantity of metal, plasteel and sandbags. Perfect for fortifying a defensive position"
	ui_icon = "materials"
	uses = 1
	cost = 4
	equipment_to_spawn = list(
		/obj/item/storage/box/crate/loot/materials_pack,
		/obj/item/tool/shovel/etool,
		/obj/item/tool/shovel/etool,
		/obj/item/tool/shovel/etool,
	)

/datum/campaign_reward/equipment/mech_heavy
	name = "Heavy combat mech"
	desc = "One heavy combat mech."
	detailed_desc = "Your battalion has been assigned a single Vanguard heavy combat mech. The Vanguard has extreme durability and offensive capability. Able to wade through the thickest of fighting with ease, it is the TGMC's premier assault mech, although its speed and maneuverability are somewhat lackluster."
	ui_icon = "heavy_mech"
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

/datum/campaign_reward/bonus_job/activated_effect()
	. = ..()
	if(!.)
		return

	for(var/job_type in bonus_job_list)
		var/datum/job/bonus_job = SSjob.type_occupations[job_type]
		bonus_job.add_job_positions(bonus_job_list[job_type])

	reward_flags |= REWARD_ACTIVE

	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED, TYPE_PROC_REF(/datum/campaign_reward, deactivate), override = TRUE) //you could use this multiple times per mission

///Removes the job slots once the mission is over
/datum/campaign_reward/bonus_job/deactivate()
	. = ..()
	for(var/job_type in bonus_job_list)
		var/datum/job/bonus_job = SSjob.type_occupations[job_type]
		bonus_job.set_job_positions(0)

/datum/campaign_reward/bonus_job/colonial_militia
	name = "Colonial militia support"
	desc = "A colonial militia squad to augment our forces"
	detailed_desc = "A large number of militia job slots are opened at no attrition cost. \
	A local colonial militia sympathetic to our cause has offered a squad to support our troops. Equipped with lesser arms and armor than our own troops, but fairly numerous."
	ui_icon = "militia"
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
	ui_icon = "freelancers"
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
	ui_icon = "icc"
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
	ui_icon = "pmc"
	bonus_job_list = list(
		/datum/job/pmc/leader/campaign_bonus = 1,
		/datum/job/pmc/gunner/campaign_bonus = 2,
		/datum/job/pmc/standard/campaign_bonus = 4,
	)

/datum/campaign_reward/bonus_job/combat_robots
	name = "Combat robots"
	desc = "A shipment of combat robots to bolster your forces"
	detailed_desc = "A four combat robot job slots are opened at no attrition cost. \
	Combat robots are tough to kill, being immune to pain and chemicals, and resist both fire and radiation. They suffer from low mobility however."
	ui_icon = "combat_robots"
	cost = 6
	bonus_job_list = list(
		/datum/job/terragov/squad/standard/campaign_robot = 4,
	)

//Parent for all passive attrition modifiers
/datum/campaign_reward/attrition_modifier
	reward_flags = REWARD_PASSIVE_EFFECT|REWARD_ACTIVE
	///Modifier to faction passive attrition gain
	var/attrition_mod = 0

/datum/campaign_reward/attrition_modifier/passive_effect()
	. = ..()
	faction.attrition_gain_multiplier += attrition_mod

/datum/campaign_reward/attrition_modifier/remove_passive_effect()
	faction.attrition_gain_multiplier -= attrition_mod
	reward_flags |= REWARD_CONSUMED

/datum/campaign_reward/attrition_modifier/Destroy(force, ...)
	if(!(reward_flags & REWARD_CONSUMED))
		remove_passive_effect()
	return ..()

/datum/campaign_reward/attrition_modifier/bonus_standard
	name = "Improved supply lines"
	desc = "+20% passive Attrition Point gain"
	detailed_desc = "Improved supply lines allow for the smooth transfer of men and materiel, allowing for the deployment of more combat forces."
	attrition_mod = 0.2
	ui_icon = "logistics_buff"

/datum/campaign_reward/attrition_modifier/malus_standard
	name = "Degraded supply lines"
	desc = "-20% passive Attrition Point gain"
	detailed_desc = "Damage to our supply lines have increased the difficulty and time required to move men and materiel, resulting in a lower deployment of combat forces."
	attrition_mod = -0.2
	ui_icon = "logistics_malus"
	reward_flags = REWARD_PASSIVE_EFFECT|REWARD_DEBUFF

/datum/campaign_reward/attrition_modifier/malus_teleporter
	name = "Bluespace logistics disabled"
	desc = "-20% passive Attrition Point gain"
	detailed_desc = "The loss of our teleporter arrays has increased the difficulty and time required to move men and materiel, resulting in a lower deployment of combat forces."
	attrition_mod = -0.2
	ui_icon = "bluespace_logistics_malus"
	reward_flags = REWARD_PASSIVE_EFFECT|REWARD_DEBUFF

/datum/campaign_reward/teleporter_disabled
	name = "Teleporter Array disabled"
	desc = "Teleporter Array has been permenantly disabled"
	detailed_desc = "The Bluespace drive powering all Teleporter Arrays in the conflict zone has been destroyed, rending all Teleporter Arrays inoperable. You'll have to deploy the old fashion way from here on out."
	reward_flags = REWARD_IMMEDIATE_EFFECT|REWARD_DEBUFF
	ui_icon = "tele_broken"

/datum/campaign_reward/teleporter_disabled/immediate_effect()
	for(var/obj/structure/teleporter_array/teleporter AS in GLOB.teleporter_arrays)
		if(teleporter.faction != faction.faction)
			continue
		teleporter.teleporter_status = TELEPORTER_ARRAY_INOPERABLE
		to_chat(faction.faction_leader, span_warning("Error: The Teleporter Array has been rendered permanently inoperable."))
		return

/datum/campaign_reward/teleporter_charges
	name = "Delegated Teleporter Array access"
	desc = "+2 uses of the Teleporter Array"
	detailed_desc = "Central command have allocated the battalion with two additional uses of the Teleporter Array. Its extremely costly to run and demand is high across the conflict zone, so make them count."
	ui_icon = "tele_uses"
	uses = 3
	cost = 6

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
	ui_icon = "tele_enabled"
	uses = 2
	cost = 5
	reward_flags = REWARD_ACTIVATED_EFFECT|REWARD_ACTIVE_MISSION_ONLY

/datum/campaign_reward/teleporter_enabled/activated_effect()
	var/obj/structure/teleporter_array/friendly_teleporter
	for(var/obj/structure/teleporter_array/teleporter AS in GLOB.teleporter_arrays)
		if(teleporter.faction != faction.faction)
			continue
		if(teleporter.teleporter_status == TELEPORTER_ARRAY_INOPERABLE)
			to_chat(faction.faction_leader, span_warning("The Teleporter Array has been permanently disabled due to the destruction of the linked Bluespace drive."))
			return
		friendly_teleporter = teleporter
		break
	if(!friendly_teleporter)
		CRASH("no teleporter found")
	. = ..()
	if(!.)
		return

	friendly_teleporter.teleporter_status = TELEPORTER_ARRAY_READY
	to_chat(faction.faction_leader, span_warning("Teleporter Array powered up. Link to Bluespace drive confirmed. Ready for teleportation."))
	reward_flags |= REWARD_ACTIVE
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED, TYPE_PROC_REF(/datum/campaign_reward, deactivate))

/datum/campaign_reward/droppod_refresh
	name = "Rearm drop pod bays"
	desc = "replace all used drop pods"
	detailed_desc = "Replace all drop pods that have been previously deployed with refurbished units or ones from fleet storage, ready for immediate use."
	ui_icon = "droppod_refresh"
	uses = 1
	cost = 10

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
	ui_icon = "droppod_active"
	uses = 3
	cost = 9
	reward_flags = REWARD_ACTIVATED_EFFECT|REWARD_ACTIVE_MISSION_ONLY

/datum/campaign_reward/droppod_enabled/activated_effect()
	var/datum/game_mode/hvh/campaign/mode = SSticker.mode
	var/datum/campaign_mission/current_mission = mode.current_mission
	if(current_mission.mission_flags & MISSION_DISALLOW_DROPPODS)
		to_chat(faction.faction_leader, span_warning("External factors prevent the ship from repositioning at this time. Drop pods unavailable."))
		return

	. = ..()
	if(!.)
		return

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAMPAIGN_ENABLE_DROPPODS)
	to_chat(faction.faction_leader, span_warning("Ship repositioned, drop pods are now ready for use."))
	reward_flags |= REWARD_ACTIVE
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED, TYPE_PROC_REF(/datum/campaign_reward, deactivate))

/datum/campaign_reward/droppod_disable
	name = "Disable drop pods"
	desc = "Prevents the enemy from using drop pods in the current or next mission"
	detailed_desc = "Ground to Space weapon systems are activated to prevent TGMC close orbit support ships from positioning themselves for drop pod orbital assaults during the current or next mission."
	ui_icon = "droppod_broken"
	uses = 2
	reward_flags = REWARD_ACTIVATED_EFFECT|REWARD_ACTIVE_MISSION_ONLY

/datum/campaign_reward/droppod_disable/activated_effect()
	var/datum/game_mode/hvh/campaign/mode = SSticker.mode
	var/datum/campaign_mission/current_mission = mode.current_mission
	if(current_mission.mission_flags & MISSION_DISALLOW_DROPPODS)
		to_chat(faction.faction_leader, span_warning("Enemy drop pods already unable to deploy during this mission."))
		return

	. = ..()
	if(!.)
		return

	current_mission.mission_flags |= MISSION_DISALLOW_DROPPODS
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAMPAIGN_DISABLE_DROPPODS)
	to_chat(faction.faction_leader, span_warning("Orbital deterrence systems activated. Enemy drop pods disabled for this mission."))

/datum/campaign_reward/fire_support
	name = "CAS mission"
	desc = "Close Air Support is deployed to support this mission."
	detailed_desc = "A limited number of Close Air Support attack runs are available via tactical binoculars for this mission. Excellent for disrupting dug in enemy positions."
	ui_icon = "cas"
	uses = 1
	cost = 10
	reward_flags = REWARD_ACTIVATED_EFFECT|REWARD_ACTIVE_MISSION_ONLY
	var/list/fire_support_types = list(
		FIRESUPPORT_TYPE_GUN = 4,
		FIRESUPPORT_TYPE_ROCKETS = 2,
		FIRESUPPORT_TYPE_CRUISE_MISSILE = 1,
	)

/datum/campaign_reward/fire_support/activated_effect()
	var/datum/game_mode/hvh/campaign/mode = SSticker.mode
	var/datum/campaign_mission/current_mission = mode.current_mission
	if(current_mission.mission_flags & MISSION_DISALLOW_FIRESUPPORT)
		to_chat(faction.faction_leader, span_warning("Fire support unavailable during this mission."))
		return

	. = ..()
	if(!.)
		return

	for(var/firesupport_type in fire_support_types)
		var/datum/fire_support/fire_support_option = GLOB.fire_support_types[firesupport_type]
		fire_support_option.enable_firesupport(fire_support_types[firesupport_type])

	reward_flags |= REWARD_ACTIVE
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED, TYPE_PROC_REF(/datum/campaign_reward, deactivate), override = TRUE) //you could use this multiple times per mission

///Turns off the fire support and resets its uses
/datum/campaign_reward/fire_support/deactivate()
	. = ..()
	for(var/firesupport_type in fire_support_types)
		var/datum/fire_support/fire_support_option = GLOB.fire_support_types[firesupport_type]
		fire_support_option.disable()

/datum/campaign_reward/fire_support/som_cas
	fire_support_types = list(
		FIRESUPPORT_TYPE_VOLKITE = 3,
		FIRESUPPORT_TYPE_INCEND_ROCKETS = 2,
		FIRESUPPORT_TYPE_RAD_MISSILE = 2,
	)

/datum/campaign_reward/fire_support/mortar
	name = "Mortar support"
	desc = "Mortar teams are activated to provide firesupport for this mission."
	detailed_desc = "A limited number of mortar strikes are available via tactical binoculars for this mission. Excellent for disrupting dug in enemy positions."
	ui_icon = "mortar"
	cost = 6
	fire_support_types = list(
		FIRESUPPORT_TYPE_HE_MORTAR = 6,
		FIRESUPPORT_TYPE_INCENDIARY_MORTAR = 3,
		FIRESUPPORT_TYPE_SMOKE_MORTAR = 2,
		FIRESUPPORT_TYPE_ACID_SMOKE_MORTAR = 2,
	)

/datum/campaign_reward/fire_support/som_mortar
	name = "Mortar support"
	desc = "Mortar teams are activated to provide firesupport for this mission."
	detailed_desc = "A limited number of mortar strikes are available via tactical binoculars for this mission. Excellent for disrupting dug in enemy positions."
	ui_icon = "mortar"
	cost = 6
	fire_support_types = list(
		FIRESUPPORT_TYPE_HE_MORTAR_SOM = 6,
		FIRESUPPORT_TYPE_INCENDIARY_MORTAR_SOM = 3,
		FIRESUPPORT_TYPE_SMOKE_MORTAR_SOM = 2,
		FIRESUPPORT_TYPE_SATRAPINE_SMOKE_MORTAR = 2,
	)

//This is a malus effect, some other active disabling ability may belong to the team doing the disabling
/datum/campaign_reward/reward_disabler
	name = "REWARD_DISABLER"
	desc = "base type of disabler, you shouldn't see this."
	detailed_desc = "Why can you see this? Report on github."
	uses = 2
	reward_flags = REWARD_IMMEDIATE_EFFECT|REWARD_DEBUFF
	///The types of rewards disabled
	var/list/types_disabled
	///Any mission flags that will override this disabler
	var/override_flags = NONE
	///Rewards currently disabled. Recorded to reenable later
	var/list/types_currently_disabled = list()

/datum/campaign_reward/reward_disabler/activated_effect()
	var/datum/game_mode/hvh/campaign/mode = SSticker.mode
	var/datum/campaign_mission/current_mission = mode.current_mission
	if(current_mission.mission_flags & override_flags) //already disabled, don't need this
		return

	. = ..()
	if(!.)
		return

	for(var/datum/campaign_reward/reward_type AS in faction.faction_rewards)
		if(reward_type.type in types_disabled)
			reward_type.reward_flags |= REWARD_DISABLED
			types_currently_disabled += reward_type

	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED, TYPE_PROC_REF(/datum/campaign_reward, deactivate))
	if(!uses)
		UnregisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_LOADED)
		reward_flags &= ~REWARD_DEBUFF

/datum/campaign_reward/reward_disabler/immediate_effect()
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_LOADED, TYPE_PROC_REF(/datum/campaign_reward, activated_effect))

/datum/campaign_reward/reward_disabler/deactivate()
	for(var/datum/campaign_reward/reward_type AS in types_currently_disabled)
		reward_type.reward_flags &= ~REWARD_DISABLED
	types_currently_disabled.Cut()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED)

/datum/campaign_reward/reward_disabler/tgmc_cas
	name = "CAS disabled"
	desc = "CAS fire support temporarily disabled."
	detailed_desc = "Hostile actions have resulted in the temporary loss of our access to close air support"
	ui_icon = "cas_disabled"
	types_disabled = list(/datum/campaign_reward/fire_support)
	override_flags = MISSION_DISALLOW_FIRESUPPORT

/datum/campaign_reward/reward_disabler/som_cas
	name = "CAS disabled"
	desc = "CAS fire support temporarily disabled."
	detailed_desc = "Hostile actions have resulted in the temporary loss of our access to close air support"
	ui_icon = "cas_disabled"
	types_disabled = list(/datum/campaign_reward/fire_support/som_cas)
	override_flags = MISSION_DISALLOW_FIRESUPPORT

/datum/campaign_reward/reward_disabler/tgmc_mortar
	name = "Mortar support disabled"
	desc = "Mortar fire support temporarily disabled."
	detailed_desc = "Hostile actions have resulted in the temporary loss of our access to mortar fire support"
	ui_icon = "mortar_disabled"
	types_disabled = list(/datum/campaign_reward/fire_support/mortar)
	override_flags = MISSION_DISALLOW_FIRESUPPORT

/datum/campaign_reward/reward_disabler/tgmc_mortar/long
	uses = 3

/datum/campaign_reward/reward_disabler/som_mortar
	name = "Mortar support disabled"
	desc = "Mortar fire support temporarily disabled."
	detailed_desc = "Hostile actions have resulted in the temporary loss of our access to mortar fire support"
	ui_icon = "mortar_disabled"
	types_disabled = list(/datum/campaign_reward/fire_support/som_mortar)
	override_flags = MISSION_DISALLOW_FIRESUPPORT

/datum/campaign_reward/reward_disabler/som_mortar/long
	uses = 3

/datum/campaign_reward/reward_disabler/drop_pods
	name = "Drop pods disabled"
	desc = "Drop pod access temporarily disabled."
	detailed_desc = "Hostile actions have resulted in the temporary loss of our access to drop pod deployment"
	ui_icon = "droppod_disabled"
	types_disabled = list(/datum/campaign_reward/droppod_enabled)
	override_flags = MISSION_DISALLOW_DROPPODS

/datum/campaign_reward/reward_disabler/drop_pods
	name = "Teleporter disabled"
	desc = "Teleporter temporarily disabled."
	detailed_desc = "Hostile actions have resulted in the temporary loss of our access to teleporter deployment"
	ui_icon = "tele_disabled"
	types_disabled = list(/datum/campaign_reward/teleporter_enabled)
