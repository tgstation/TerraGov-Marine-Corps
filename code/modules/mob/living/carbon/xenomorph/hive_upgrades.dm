GLOBAL_LIST_INIT(upgrade_categories, list("Buildings", "Defences", "Xenos"))//, "Primordial"))//uncomment to unlock globally

/datum/hive_upgrade
	///name of the upgrade, string, used in ui
	var/name = "Error upgrade"
	///desc of the upgrade, string, used in ui
	var/desc = "Error upgrade description"
	///name of the category it belongs to, string, used in ui
	var/category = "ERROR CATEGORY"
	///Psy point cost, float
	var/psypoint_cost = 10
	///upgrade flag var
	var/flags_upgrade = NONE
	///gamemode flags to whether this upgrade is purchasable
	var/flags_gamemode = ABILITY_ALL_GAMEMODE
	///int of the times we bought this upgrade
	var/times_bought = 0
	///string for UI icon in buyable_icons.dmi for this upgrade
	var/icon = "larvasilo"

/**
 * Buys the upgrade and applies its effects
 * returns true on success false on fail
 * Arguments:
 * * buyer: Xeno trying to buy this upgrade
 */
/datum/hive_upgrade/proc/on_buy(mob/living/carbon/xenomorph/buyer)
	SHOULD_CALL_PARENT(TRUE)
	SSpoints.xeno_points_by_hive[buyer.hivenumber] -= psypoint_cost
	times_bought++
	return TRUE

/**
 * Whether we can buy this upgrade, used to set the menu button as grey or not
 * returns true on can false on cannot
 * Arguments:
 * * buyer: Xeno trying to buy this upgrade
 * * silent: whether to send error messages to the buyer
 */
/datum/hive_upgrade/proc/can_buy(mob/living/carbon/xenomorph/buyer, silent = TRUE)
	SHOULD_CALL_PARENT(TRUE)
	if((flags_upgrade & UPGRADE_FLAG_ONETIME) && times_bought)
		return FALSE
	if(SSpoints.xeno_points_by_hive[buyer.hivenumber] < psypoint_cost)
		if(!silent)
			to_chat(buyer, span_xenowarning("You need [psypoint_cost-SSpoints.xeno_points_by_hive[buyer.hivenumber]] more points to request this blessing!"))
		return FALSE
	return TRUE

/datum/hive_upgrade/building
	category = "Buildings"
	///The type of building created
	var/building_type

/datum/hive_upgrade/building/can_buy(mob/living/carbon/xenomorph/buyer, silent)
	. = ..()
	if(!.)
		return
	var/turf/buildloc = get_step(buyer, SOUTHWEST)
	if(!buildloc)
		return FALSE

	if(buildloc.density)
		if(!silent)
			to_chat(buyer, span_xenowarning("You cannot build in a dense location!"))
		return FALSE

/datum/hive_upgrade/building/on_buy(mob/living/carbon/xenomorph/buyer)
	if(!do_after(buyer, 10 SECONDS, TRUE, buyer, BUSY_ICON_BUILD))
		return FALSE

	if(!can_buy(buyer, FALSE))
		return FALSE

	if(SSpoints.xeno_points_by_hive[buyer.hivenumber] < psypoint_cost)
		to_chat(buyer, span_xenowarning("Someone used all the psych points while we were building!"))
		return FALSE

	var/turf/buildloc = get_step(buyer, SOUTHWEST)

	var/atom/built = new building_type(buildloc, buyer.hivenumber)
	to_chat(buyer, span_notice("We build \a [built] for [psypoint_cost] psy points."))
	log_game("[buyer] has built \a [built] in [AREACOORD(buildloc)], spending [psypoint_cost] psy points in the process")
	xeno_message("[buyer] has built \a [built] at [get_area(buildloc)]!", "xenoannounce", 5, buyer.hivenumber)
	return ..()

/datum/hive_upgrade/building/silo
	name = "Larva Silo"
	desc = "Constructs a silo that generates xeno larvas over time. Requires open space and time to place."
	psypoint_cost = SILO_PRICE
	icon = "larvasilo"
	flags_upgrade = ABILITY_DISTRESS
	building_type = /obj/structure/xeno/silo

/datum/hive_upgrade/building/silo/can_buy(mob/living/carbon/xenomorph/buyer, silent = TRUE)
	. = ..()
	if(!.)
		return

	var/turf/buildloc = get_step(buyer, SOUTHWEST)
	if(!buildloc)
		return FALSE

	if(buildloc.density)
		if(!silent)
			to_chat(buyer, span_xenowarning("You cannot build in a dense location!"))
		return FALSE

/datum/hive_upgrade/building/silo/on_buy(mob/living/carbon/xenomorph/buyer)

	for(var/obj/structure/xeno/silo/silo AS in GLOB.xeno_resin_silos)
		if(get_dist(silo, buyer) < 15)
			to_chat(buyer, span_xenowarning("Another silo is too close!"))
			return FALSE

	return ..()

/datum/hive_upgrade/building/evotower
	name = "Evolution Tower"
	desc = "Constructs a tower that increases the rate of evolution point generation by 1.25 times per tower."
	psypoint_cost = 300
	icon = "evotower"
	flags_upgrade = ABILITY_DISTRESS
	building_type = /obj/structure/xeno/evotower

/datum/hive_upgrade/building/maturitytower
	name = "Maturity Tower"
	desc = "Constructs a tower that increases the rate of maturity point generation by 1.2 times per tower."
	psypoint_cost = 300
	icon = "maturitytower"
	flags_upgrade = ABILITY_DISTRESS
	building_type = /obj/structure/xeno/maturitytower

/datum/hive_upgrade/building/spawner
	name = "Spawner"
	desc = "Constructs a spawner that generates ai xenos over time"
	psypoint_cost = 600
	icon = "spawner"
	flags_upgrade = ABILITY_DISTRESS
	building_type = /obj/structure/xeno/spawner

/datum/hive_upgrade/defence
	category = "Defences"

/datum/hive_upgrade/defence/turret
	name = "Acid turret"
	desc = "Places a acid spitting resin turret under you. Must be at least 6 tiles away from other turrets, not near fog and on a weeded area."
	icon = "acidturret"
	psypoint_cost = XENO_TURRET_PRICE
	flags_gamemode = ABILITY_DISTRESS
	var/build_time = 15 SECONDS
	var/turret_type = /obj/structure/xeno/xeno_turret

/datum/hive_upgrade/defence/turret/can_buy(mob/living/carbon/xenomorph/buyer, silent = TRUE)
	. = ..()
	if(!.)
		return
	var/turf/T = get_turf(buyer)
	var/mob/living/carbon/xenomorph/blocker = locate() in T
	if(blocker && blocker != buyer && blocker.stat != DEAD)
		if(!silent)
			to_chat(buyer, span_xenowarning("You cannot build with [blocker] in the way!"))
		return FALSE

	if(!T.is_weedable())
		return FALSE

	var/obj/effect/alien/weeds/alien_weeds = locate() in T

	if(!alien_weeds)
		if(!silent)
			to_chat(buyer, span_xenowarning("No weeds here!"))
		return FALSE

	if(!T.check_alien_construction(buyer, silent = silent, planned_building = /obj/structure/xeno/xeno_turret) || !T.check_disallow_alien_fortification(buyer))
		return FALSE
	return TRUE

/datum/hive_upgrade/defence/turret/on_buy(mob/living/carbon/xenomorph/buyer)
	for(var/obj/structure/xeno/xeno_turret/turret AS in GLOB.xeno_resin_turrets)
		if(get_dist(turret, buyer) < 6)
			to_chat(buyer, span_xenowarning("Another turret is too close!"))
			return FALSE

	if(!do_after(buyer, build_time, TRUE, buyer, BUSY_ICON_BUILD))
		return FALSE

	if(!can_buy(buyer, FALSE))
		return FALSE

	to_chat(buyer, span_xenowarning("We build a new acid turret, spending [psypoint_cost] psychic points in the process"))
	new turret_type(get_turf(buyer), buyer.hivenumber)

	log_game("[buyer] built a turret in [AREACOORD(buyer)], spending [psypoint_cost] psy points in the process")
	xeno_message("[buyer] has built a new turret at [get_area(buyer)]!", "xenoannounce", 5, buyer.hivenumber)

	return ..()

/datum/hive_upgrade/defence/turret/sticky
	name = "Sticky resin turret"
	desc = "Places a sticky spit spitting resin turret under you. Must be at least 6 tiles away from other turrets, not near fog and on a weeded area."
	icon = "resinturret"
	psypoint_cost = 50
	turret_type = /obj/structure/xeno/xeno_turret/sticky

/datum/hive_upgrade/xenos
	category = "Xenos"

/datum/hive_upgrade/xenos/king
	name = "King"
	desc = "Places a Psychic Echo chamber that tallhosts can detect, then after a summon time selects a random sister to take over the mind of the gravity manipulating King."
	icon = "king"
	flags_gamemode = ABILITY_DISTRESS
	psypoint_cost = 1800

/datum/hive_upgrade/xenos/king/can_buy(mob/living/carbon/xenomorph/buyer, silent = TRUE)
	. = ..()
	if(!.)
		return
	if(buyer.hive.king_present)
		if(!silent)
			to_chat(buyer, span_xenowarning("Another king is alive already!"))
		return FALSE

/datum/hive_upgrade/xenos/king/on_buy(mob/living/carbon/xenomorph/buyer)
	to_chat(buyer, span_xenonotice("We begin constructing a psychic echo chamber for the Queen Mother..."))
	if(!do_after(buyer, 15 SECONDS, FALSE, buyer, BUSY_ICON_HOSTILE))
		return FALSE
	var/obj/structure/resin/king_pod = new /obj/structure/resin/king_pod(get_turf(buyer), buyer.hivenumber)
	log_game("[key_name(buyer)] has created a pod in [AREACOORD(buyer)]")
	xeno_message("<B>[buyer] has created a king pod at [get_area(buyer)]. Defend it until the Queen Mother summons a king!</B>", hivenumber = buyer.hivenumber, target = king_pod, arrow_type = /obj/screen/arrow/leader_tracker_arrow)
	priority_announce("WARNING: Psychic anomaly detected at [get_area(buyer)]. Assault of the area reccomended.", "TGMC Intel Division")
	return ..()

/datum/hive_upgrade/primordial
	category = "Primordial"
	flags_upgrade = UPGRADE_FLAG_ONETIME|UPGRADE_FLAG_MESSAGE_HIVE

/datum/hive_upgrade/primordial/can_buy(mob/living/carbon/xenomorph/buyer, silent = TRUE)
	. = ..()
	if(!isxenoqueen(buyer) && !isxenoshrike(buyer))
		if(!silent)
			to_chat(buyer, span_xenonotice("You must be a ruler to buy this!"))
		return FALSE


/datum/hive_upgrade/primordial/queen
	name = PRIMORDIAL_QUEEN
	desc = "Unlocks the primordial empresses queen charge. Walk in a straight line to begin charging. Can be toggled."
	psypoint_cost = 300
	icon = "primoqueen"

/datum/hive_upgrade/primordial/shrike
	name = PRIMORDIAL_SHRIKE
	desc = "Unlocks the primordial shrikes gravity bomb. Activate to throw a gravity grenade thats sucks in everything in a radius."
	psypoint_cost = 300
	icon = "primoshrike"

/datum/hive_upgrade/primordial/defiler
	name = PRIMORDIAL_DEFILER
	desc = "Unlocks the primordial defilers tentacle. Can grab most items and tallhosts from range and bring them to the defiler."
	psypoint_cost = 225
	icon = "primodefiler"

/datum/hive_upgrade/primordial/sentinel
	name = PRIMORDIAL_SENTINEL
	desc = "Unlocks the primordial sentinels neurogas grenade. Allows them to throw a grenade that emits gas in an area."
	psypoint_cost = 75
	icon = "primosent"

/datum/hive_upgrade/primordial/ravager
	name = PRIMORDIAL_RAVAGER
	desc = "Unlocks the primordial ravgers vampirism. A passive ability that increases the ravagers healing as it hits more enemies."
	psypoint_cost = 225
	icon = "primorav"

/datum/hive_upgrade/primordial/crusher
	name = PRIMORDIAL_CRUSHER
	desc = "Unlocks the primordial crushers advance. An ability that allows them to charge up their charge and release it in a sudden burst."
	psypoint_cost = 225
	icon = "primocrush"

/datum/hive_upgrade/primordial/hunter
	name = PRIMORDIAL_HUNTER
	desc = "Replaces the hunters stealth ability with the ability to disguise itself as any object."
	psypoint_cost = 125
	icon = "primohunter"

/datum/hive_upgrade/primordial/defender
	name = PRIMORDIAL_DEFENDER
	desc = "Unlocks the primordial defenders centrifugal force. An ability that allows them to rapidly spin and attack enemies nearby."
	psypoint_cost = 75
	icon = "primodefender"
