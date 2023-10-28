/*
This file is where all variables and functions related to personal lists are defined
I've done my best to make it as organized for future additions and changes, but yes it is a lot

The personal_statistics_list serves as a large directory for ckeys and their version of /datum/personal_statistics
In /datum/personal_statistics is where all the data is stored, manipulated by various procs throughout the code

The most basic way to add to something is like this:
	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[ckey]
	personal_statistics.stat_you_want_changed++

It searches for the ckey in the global list (you may need to do mob.ckey) and then grabs their /datum/personal_statistics
Then it accesses the desired statistic in personal_statistics!

In the event where you are not using a ckey directly (for example: mob.ckey) you should always do an:
	if(mob.ckey)
		//continue with code

This is to prevent any possible errors with ckey-less mobs

To then display the statistic at the end of the round, you have to add it to the compose_report() proc like so:
	if(stat_you_want_changed)
		stats += "[stat_you_want_changed] things happened."

This is added to the list of stats that are put together for displaying to the player when the round ends

Hopefully this mini-tutorial helps you if you want to add more things to be tracked!
*/

GLOBAL_LIST_EMPTY(personal_statistics_list)

/datum/personal_statistics
	//Combat
	var/projectiles_fired = 0
	var/projectiles_hit = 0
	var/melee_hits = 0

	var/projectile_damage = 0
	var/melee_damage = 0

	//We are watching
	var/friendly_fire_damage = 0

	var/projectiles_caught = 0
	var/projectiles_reflected = 0
	var/rockets_reflected = 0

	var/grenades_primed = 0
	var/traps_created = 0

	var/limbs_lost = 0
	var/delimbs = 0
	var/internal_injuries = 0
	var/internal_injuries_inflicted = 0

	//Medical
	var/self_heals = 0
	var/heals = 0
	var/revives = 0
	var/surgical_actions_performed = 0
	var/list/chemicals_ingested = list()

	var/times_revived = 0
	var/deaths = 0

	//Downtime
	var/time_resting = 0
	var/time_unconscious = 0
	var/time_in_stasis = 0
	var/time_in_cryo = 0

	//Support & logistics
	var/weeds_planted = 0
	var/structures_built = 0
	var/times_repaired = 0
	var/integrity_repaired = 0
	var/generator_repairs_performed = 0
	var/miner_repairs_performed = 0
	var/apcs_repaired = 0

	var/generator_sabotages_performed = 0
	var/miner_sabotages_performed = 0
	var/apcs_slashed = 0

	var/artillery_fired = 0

	var/req_points_used = 0

	var/drained = 0
	var/cocooned = 0
	var/recycle_points_denied = 0
	var/huggers_created = 0
	var/impregnations = 0

	//Close air support
	var/cas_cannon_shots = 0
	var/cas_laser_shots = 0
	var/cas_minirockets_fired = 0
	var/cas_rockets_fired = 0
	var/cas_points_used = 0

	//Funny things to keep track of
	var/weights_lifted = 0
	var/sippies = 0
	var/war_crimes = 0
	var/tactical_unalives = 0	//Someone should add a way to determine if you died to a grenade in your hand and add it to this

///Calculated from the chemicals_ingested list, returns a string: "[chemical name], [amount] units"
/datum/personal_statistics/proc/get_most_ingested_chemical()
	var/list/winner = list("none", 0)
	if(LAZYLEN(chemicals_ingested))
		for(var/chem in chemicals_ingested)
			if(winner[2] < chemicals_ingested[chem])
				winner[1] = chem
				winner[2] = chemicals_ingested[chem]
	return "[winner[1]], [winner[2]] units"

///Assemble a list of statistics associated with the ckey this datum belongs to
/datum/personal_statistics/proc/compose_report()
	var/list/stats = list()
	stats += "<br><hr><u>Your personal round statistics:</u><br>"
	//Combat
	if(projectiles_fired)
		stats += "Fired [projectiles_fired] projectile\s."
		stats += "[projectiles_hit] projectile\s hit their target\s."
		stats += projectiles_hit ? "Your accuracy score is [PERCENT(projectiles_hit / projectiles_fired)]%!" : "You missed every shot!"
		stats += projectile_damage ? "[projectile_damage] projectile damage dealt!" : "You dealt no projectile damage."
		stats += ""
	if(melee_hits)
		stats += "Landed [melee_hits] melee attack\s."
		stats += melee_damage ? "[melee_damage] melee damage dealt!" : "You dealt no melee damage."
		stats += ""
	stats += friendly_fire_damage ? "You caused [friendly_fire_damage] damage to allies...<br>" : "You avoided committing acts of friendly fire!<br>"

	if(projectiles_caught)
		stats += "[projectiles_caught] projectile\s caught by psychic shield."
		stats += "[projectiles_reflected] projectile\s [projectiles_reflected != 1 ? "were" : "was"] reflected."
		if(rockets_reflected)
			stats += "[rockets_reflected] rocket\s [rockets_reflected != 1 ? "were" : "was"] reflected!"
		stats += ""

	if(grenades_primed)
		stats += "[grenades_primed] grenade\s thrown."
	if(traps_created)
		stats += "[traps_created] trap\s/mine\s/hazard\s placed."
	if(grenades_primed || traps_created)
		stats += ""

	stats += "Lost [limbs_lost] limb[limbs_lost != 1 ? "s" : ""]."
	if(delimbs)
		stats += "You severed [delimbs] limb\s!"
	stats += internal_injuries ? "You suffered [internal_injuries] internal injur[internal_injuries != 1 ? "ies" : "y"]." : "You avoided any internal injuries."
	if(internal_injuries_inflicted)
		stats += "Inflicted [internal_injuries_inflicted] internal injur[internal_injuries_inflicted > 1 ? "ies" : "y"] on [internal_injuries_inflicted > 1 ? "others" : "somebody"]."

	//Medical
	stats += "<hr>"
	if(self_heals)
		stats += "You healed yourself [self_heals] time\s."
	if(heals)
		stats += "Healed others [heals] time\s."
	if(surgical_actions_performed)
		stats += "Performed [surgical_actions_performed] surgical operation\s."
	if(revives)
		stats += "Performed [revives] revive\s."
	if(times_revived)
		stats += "You were revived [times_revived] time\s."
	stats += deaths ? "You died [deaths] time\s." : "You survived the whole round."

	//Downtime
	var/list/downtime_stats = list()
	if(time_resting)
		downtime_stats += "You were lying down for [DisplayTimeText(time_resting)]."
	if(time_unconscious)
		downtime_stats += "Slept for [DisplayTimeText(time_unconscious)]."
	if(time_in_stasis)
		downtime_stats += "Spent [DisplayTimeText(time_in_stasis)] in stasis."
	if(time_in_cryo)
		downtime_stats += "Spent [DisplayTimeText(time_in_cryo)] in cryo."

	if(LAZYLEN(downtime_stats))
		stats += "<hr>"
		stats += downtime_stats

	//Support & logistics
	var/list/support_stats = list()
	if(weeds_planted)
		support_stats += "Planted [weeds_planted] weed node\s."
	if(structures_built)
		support_stats += "Built [structures_built] structure\s."
	if(times_repaired)
		support_stats += "Performed [times_repaired] repair\s."
	if(integrity_repaired)
		support_stats += "Repaired [integrity_repaired] point\s of integrity."
	if(generator_repairs_performed)
		support_stats += "Performed [generator_repairs_performed] generator repair\s."
	if(miner_repairs_performed)
		support_stats += "Performed [miner_repairs_performed] miner repair\s."
	if(apcs_repaired)
		support_stats += "Repaired [apcs_repaired] APC\s."

	if(generator_sabotages_performed)
		support_stats += "Sabotaged [generator_sabotages_performed] generator\s."
	if(miner_sabotages_performed)
		support_stats += "Sabotaged [miner_sabotages_performed] miner\s."
	if(apcs_slashed)
		support_stats += "Slashed [apcs_slashed] APC\s."

	if(artillery_fired)
		support_stats += "Fired [artillery_fired] artillery shell\s."

	if(req_points_used)
		support_stats += "Used [req_points_used] requisition point\s."

	if(drained)
		support_stats += "Drained [drained] host\s."
	if(cocooned)
		support_stats += "Cocooned [cocooned] host\s."
	if(recycle_points_denied)
		support_stats += "Recycled [recycle_points_denied] sister\s to continue serving the hive even in death."
	if(huggers_created)
		support_stats += "Gave birth to [huggers_created] hugger\s."
	if(impregnations)
		support_stats += "Impregnated [impregnations] host\s."

	if(LAZYLEN(support_stats))
		stats += "<hr>"
		stats += support_stats

	//Close air support
	var/list/cas_stats = list()
	if(cas_cannon_shots)
		cas_stats += "Shot [cas_cannon_shots] GAU-21 cannon voll[cas_cannon_shots > 1 ? "ies" : "ey"]."
	if(cas_laser_shots)
		cas_stats += "You scorched the battlefield with [cas_laser_shots] high-power laser beam\s."
	if(cas_minirockets_fired)
		cas_stats += "Launched [cas_minirockets_fired] air-to-surface mini-rocket\s."
	if(cas_rockets_fired)
		cas_stats += "Launched [cas_rockets_fired] air-to-surface laser-guide rocket\s."
	if(cas_points_used)
		cas_stats += "Used [cas_points_used] dropship fabricator point\s."

	if(LAZYLEN(cas_stats))
		stats += "<hr>"
		stats += cas_stats

	//The funnies
	var/list/misc_stats = list()
	if(LAZYLEN(chemicals_ingested))
		misc_stats += "Most consumed reagent: [get_most_ingested_chemical()]"
	if(weights_lifted)
		misc_stats += "You lifted [weights_lifted] weight\s[weights_lifted > 100 ? ". Sick gains!" : "."]"
	if(sippies)
		misc_stats += "You put your mouth on the communal drinking fountain [sippies] time\s."
	if(war_crimes)
		misc_stats += "You have committed [war_crimes] war crime\s."
	if(tactical_unalives)
		misc_stats += "You strategically ended your life [tactical_unalives] time\s."

	if(LAZYLEN(misc_stats))
		stats += "<hr>"
		stats += misc_stats

	//Replace any instances of line breaks after horizontal rules to prevent unneeded empty spaces
	return replacetext(jointext(stats, "<br>"), "<hr><br>", "<hr>")



/* Not sure what folder to put a file of just record keeping procs, so just leaving them here
The alternative is scattering them everywhere under their respective objects which is a bit messy */

///Tally to personal_statistics that a melee attack took place, and record the damage dealt
/mob/living/proc/record_melee_damage(mob/living/user, damage)
	if(!user.ckey)
		return FALSE
	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[user.ckey]
	personal_statistics.melee_hits++
	personal_statistics.melee_damage += damage
	return TRUE

/mob/living/carbon/human/record_melee_damage(mob/living/user, damage, delimbed)
	. = ..()
	if(!. || !delimbed)
		return FALSE
	var/datum/personal_statistics/personal_statistics
	//Tally to the victim that they lost a limb; tally to the attacker that they delimbed someone
	if(ckey)
		personal_statistics = GLOB.personal_statistics_list[ckey]
		personal_statistics.limbs_lost++
	personal_statistics = GLOB.personal_statistics_list[user.ckey]
	personal_statistics.delimbs++
	return TRUE

///Record whenever a player shoots things, taking into account bonus projectiles without running these checks multiple times
/obj/projectile/proc/record_projectile_fire(mob/shooter)
	//Part of code where this is called already checks if the shooter is a mob
	if(!shooter.ckey)
		return FALSE

	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[shooter.ckey]
	//I am trusting that nobody makes an ammo type that fires multiple projectiles and that each of those fire multiple projectiles
	personal_statistics.projectiles_fired += 1 + ammo.bonus_projectiles_amount
	return TRUE

//Lasers have their own fire_at()
/obj/projectile/hitscan/record_projectile_fire(shooter)
	//It does not check if the shooter is a mob
	if(!ismob(shooter))
		return FALSE
	return ..()

///Tally to personal_statistics that a successful shot was made and record the damage dealt
/mob/living/proc/record_projectile_damage(mob/shooter, damage)
	//Check if a ckey exists; the check for victim aliveness is handled before the proc call
	if(!shooter.ckey)
		return FALSE
	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[shooter.ckey]
	personal_statistics.projectiles_hit++
	personal_statistics.projectile_damage += damage
	if(faction && isliving(shooter))	//See if any friendly fire was made
		var/mob/living/L = shooter
		if(faction == L.faction)
			personal_statistics.friendly_fire_damage += damage	//FF multiplier already included by the way
	return TRUE

///Record what reagents and how much of them were transferred to a mob into their ckey's /datum/personal_statistics
/obj/item/reagent_containers/proc/record_reagent_consumption(amount, list/reagents_list, mob/user, mob/receiver)
	if(!amount || !LAZYLEN(reagents_list))
		return FALSE

	//Declare separate variables for the user and receiver's personal_statistics, then assign them or make them null if no ckey
	var/datum/personal_statistics/personal_statistics_user
	var/datum/personal_statistics/personal_statistics_receiver
	personal_statistics_user = user?.ckey ? GLOB.personal_statistics_list[user.ckey] : null
	if(user == receiver)
		receiver = null
	else
		personal_statistics_receiver = receiver?.ckey ? GLOB.personal_statistics_list[receiver.ckey] : null

	//Just give up, how did this even happen?
	if(!personal_statistics_user && !personal_statistics_receiver)
		return FALSE

	var/is_healing
	var/portion = amount / reagents.total_volume
	for(var/datum/reagent/chem in reagents_list)
		//If there is a receiving mob, let's try to record they ingested something
		if(receiver)
			if(personal_statistics_receiver)	//Only record if they have a ckey
				personal_statistics_receiver.chemicals_ingested[chem.name] += chem.volume * portion
		//If there is no receiver, that means the user is the one that needs their chems stat updated
		else
			personal_statistics_user.chemicals_ingested[chem.name] += chem.volume * portion

		//Determine if a healing chem was involved; only needs to be done once
		if(!is_healing && istype(chem, /datum/reagent/medicine))
			if(personal_statistics_user)
				//If a receiving mob exists, we tally up to the user mob's stats that it performed a heal
				if(receiver)
					personal_statistics_user.heals++
				else
					personal_statistics_user.self_heals++
			is_healing = TRUE
	return TRUE

///Determine if a self or non-self heal occurred, and tally up the user mob's respective stat
/obj/item/stack/medical/proc/record_healing(mob/living/user, mob/living/receiver)
	if(!user.ckey)
		return FALSE

	var/datum/personal_statistics/personal_statistics_user = GLOB.personal_statistics_list[user.ckey]
	if(user == receiver)
		receiver = null

	//If a receiving mob exists, we tally up to the user mob's stats that it performed a heal
	if(receiver)
		personal_statistics_user.heals++
	else
		personal_statistics_user.self_heals++
	return TRUE

///Record what was drank and if it was medicinal
/obj/machinery/deployable/reagent_tank/proc/record_sippies(amount, list/reagents_list, mob/user)
	if(!amount || !LAZYLEN(reagents_list) || !user.ckey)
		return FALSE

	var/is_healing
	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[user.ckey]
	var/portion = amount / reagents.total_volume
	for(var/datum/reagent/chem in reagents_list)
		//Add the chem and amount consumed to the list
		personal_statistics.chemicals_ingested[chem.name] += chem.volume * portion
		//Determine if a healing chem was involved; only needs to be done once
		if(!is_healing && istype(chem, /datum/reagent/medicine))
			personal_statistics.self_heals++
			is_healing = TRUE
	personal_statistics.sippies++
	return TRUE

///Tally up the corresponding weapon used by the pilot into their /datum/personal_statistics
/obj/docking_port/mobile/marine_dropship/casplane/proc/record_cas_activity(obj/structure/dropship_equipment/cas/weapon/weapon)
	if(!chair.occupant.ckey)
		return FALSE

	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[chair.occupant.ckey]
	//Increment variable based on weapon type
	switch(weapon.type)
		if(/obj/structure/dropship_equipment/cas/weapon/heavygun)
			personal_statistics.cas_cannon_shots++
		if(/obj/structure/dropship_equipment/cas/weapon/heavygun/radial_cas)
			personal_statistics.cas_cannon_shots++
		if(/obj/structure/dropship_equipment/cas/weapon/laser_beam_gun)
			personal_statistics.cas_laser_shots++
		if(/obj/structure/dropship_equipment/cas/weapon/minirocket_pod)
			personal_statistics.cas_minirockets_fired++
		if(/obj/structure/dropship_equipment/cas/weapon/rocket_pod)
			personal_statistics.cas_rockets_fired++
	return TRUE

///Tally how many req-points worth of xenomorphs have been recycled
/mob/living/carbon/xenomorph/proc/record_recycle_points(mob/living/carbon/xenomorph/trash)
	if(!ckey)
		return FALSE
	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[ckey]
	personal_statistics.recycle_points_denied += trash.get_export_value()
	return TRUE

///Separate record keeping proc to reduce copy pasta
/obj/machinery/miner/proc/record_miner_repair(mob/user)
	if(!user.ckey)
		return FALSE
	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[user.ckey]
	personal_statistics.miner_repairs_performed++
	return TRUE

///Record how much time a mob was lying down for
/mob/living/proc/record_time_lying_down()
	if(!last_rested)
		return FALSE
	if(!ckey)	//Reset their time if they have no ckey
		last_rested = 0
		return FALSE
	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[ckey]
	personal_statistics.time_resting += world.time - last_rested
	return TRUE

///Record how long a mob was knocked out or sleeping
/mob/living/proc/record_time_unconscious()
	if(!last_unconscious)
		return FALSE
	if(!ckey)
		last_unconscious = 0
		return FALSE
	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[ckey]
	personal_statistics.time_unconscious += world.time - last_unconscious
	return TRUE

///Record how long a mob was in a stasis bag
/mob/living/proc/record_time_in_stasis()
	if(!time_entered_stasis)
		return FALSE
	if(!ckey)
		time_entered_stasis = 0
		return FALSE
	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[ckey]
	personal_statistics.time_in_stasis += world.time - time_entered_stasis
	return TRUE

///Record how long a mob was in a cryo tube
/mob/living/proc/record_time_in_cryo()
	if(!time_entered_cryo)
		return FALSE
	if(!ckey)
		time_entered_cryo = 0
		return FALSE
	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[ckey]
	personal_statistics.time_in_cryo += world.time - time_entered_cryo
	return TRUE

///Tally up to a player's generator_repairs_performed stat when a step is completed in a generator's repairs
/obj/machinery/power/proc/record_generator_repairs(mob/user)
	if(!user.ckey)
		return FALSE
	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[user.ckey]
	personal_statistics.generator_repairs_performed++
	return TRUE

///Tally up when a player damages/destroys/corrupts a generator
/obj/machinery/power/proc/record_generator_sabotages(mob/user)
	if(!user.ckey)
		return FALSE
	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[user.ckey]
	personal_statistics.generator_sabotages_performed++
	return TRUE

///Tally up when a player successfully completes a step
/datum/surgery_step/proc/record_surgical_operation(mob/user)
	if(!user.ckey)
		return FALSE
	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[user.ckey]
	personal_statistics.surgical_actions_performed++
	return TRUE

///Record when a bone break or internal bleeding is inflicted
/datum/species/proc/record_internal_injury(mob/living/carbon/human/victim, mob/attacker, old_status, new_status)
	if(old_status == new_status || (!victim.ckey && !attacker?.ckey))
		return FALSE

	//If neither of these flags was enabled after being damaged, then no internal injury occurred
	if(!(CHECK_BITFIELD(old_status, LIMB_BROKEN|LIMB_BLEEDING) ^ CHECK_BITFIELD(new_status, LIMB_BROKEN|LIMB_BLEEDING)))
		return FALSE

	if(victim.ckey)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[victim.ckey]
		personal_statistics.internal_injuries++
	if(attacker?.ckey)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[attacker.ckey]
		personal_statistics.internal_injuries_inflicted++
	return TRUE

///Short proc that tallies up traps_created; reduce copy pasta
/mob/proc/record_traps_created()
	if(!ckey)
		return FALSE
	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[ckey]
	personal_statistics.traps_created++
	return TRUE

///Tally up bullets caught/reflected
/obj/effect/xeno/shield/proc/record_projectiles_frozen(mob/user, amount, reflected = FALSE)
	if(!user.ckey)
		return FALSE
	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[user.ckey]
	personal_statistics.projectiles_caught += amount
	if(reflected)
		personal_statistics.projectiles_reflected += amount
	return TRUE

///Tally when a structure is constructed
/mob/proc/record_structures_built()
	if(!ckey)
		return FALSE
	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[ckey]
	personal_statistics.structures_built++
	return TRUE

/mob/proc/record_war_crime()
	if(!ckey)
		return FALSE
	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[ckey]
	personal_statistics.war_crimes++
	return TRUE

/mob/proc/record_tactical_unalive()
	if(!ckey)
		return FALSE
	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[ckey]
	personal_statistics.tactical_unalives++
	return TRUE
