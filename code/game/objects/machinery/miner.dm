#define MINER_RUNNING 0
#define MINER_SMALL_DAMAGE 1
#define MINER_MEDIUM_DAMAGE 2
#define MINER_DESTROYED 3
#define MINER_LIGHT_RUNNING 8
#define MINER_LIGHT_SDAMAGE 4
#define MINER_LIGHT_MDAMAGE 2
#define MINER_LIGHT_DESTROYED 0
#define MINER_AUTOMATED "mining computer"
#define MINER_RESISTANT "reinforced components"
#define MINER_OVERCLOCKED "high-efficiency drill"

#define PHORON_CRATE_SELL_AMOUNT 150
#define PLATINUM_CRATE_SELL_AMOUNT 300
#define PHORON_DROPSHIP_BONUS_AMOUNT 15
#define PLATINUM_DROPSHIP_BONUS_AMOUNT 30
///Resource generator that produces a certain material that can be repaired by marines and attacked by xenos, Intended as an objective for marines to play towards to get more req gear
/obj/machinery/miner
	name = "\improper Nanotrasen phoron Mining Well"
	desc = "Top-of-the-line Nanotrasen research drill with it's own export module, used to extract phoron in vast quantities. Selling the phoron mined by these would net a nice profit..."
	icon = 'icons/obj/mining_drill.dmi'
	density = TRUE
	icon_state = "mining_drill_active"
	anchored = TRUE
	coverage = 30
	layer = ABOVE_MOB_LAYER
	resistance_flags = RESIST_ALL | DROPSHIP_IMMUNE
	allow_pass_flags = PASS_PROJECTILE|PASS_AIR
	///How many sheets of material we have stored
	var/stored_mineral = 0
	///Current status of the miner
	var/miner_status = MINER_RUNNING
	///Tracks how many ticks have passed since we last added a sheet of material
	var/add_tick = 0
	///How many times we neeed to tick for a resource to be created, in this case this is 2* the specified amount
	var/required_ticks = 70  //make one crate every 140 seconds
	///The mineral type that's produced
	var/mineral_value = PHORON_CRATE_SELL_AMOUNT
	///Applies the actual bonus points for the dropship for each sale
	var/dropship_bonus = PHORON_DROPSHIP_BONUS_AMOUNT
	///Health for the miner we use because changing obj_integrity is apparently bad
	var/miner_integrity = 100
	///Max health of the miner
	var/max_miner_integrity = 100
	///What type of upgrade it has installed , used to change the icon of the miner.
	var/miner_upgrade_type
	///What faction secured that miner
	var/faction = FACTION_TERRAGOV

/obj/machinery/miner/damaged	//mapping and all that shebang
	miner_status = MINER_DESTROYED
	icon_state = "mining_drill_error"

/obj/machinery/miner/damaged/init_marker()
	return //Marker will be set by itself once processing pauses when it detects this miner is broke.

/obj/machinery/miner/damaged/platinum
	name = "\improper Nanotrasen platinum Mining Well"
	desc = "A Nanotrasen platinum drill with an internal export module. Produces even more valuable materials than it's phoron counterpart"
	mineral_value = PLATINUM_CRATE_SELL_AMOUNT
	dropship_bonus = PLATINUM_DROPSHIP_BONUS_AMOUNT
/obj/machinery/miner/Initialize(mapload)
	. = ..()
	init_marker()
	start_processing()
	RegisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED, PROC_REF(disable_on_hijack))

/**
 * This proc is called during Initialize() and should be used to initially setup the minimap marker of a functional miner.
 * * For a miner starting broken, it should be overridden and immediately return instead, as broken miners will automatically set their minimap marker during their first process()
 **/
/obj/machinery/miner/proc/init_marker()
	var/marker_icon = "miner_[mineral_value >= PLATINUM_CRATE_SELL_AMOUNT ? "platinum" : "phoron"]_on"
	SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips.dmi', null, marker_icon))

/obj/machinery/miner/update_icon()
	switch(miner_status)
		if(MINER_RUNNING)
			icon_state = "mining_drill_active_[miner_upgrade_type]"
			set_light(MINER_LIGHT_RUNNING, MINER_LIGHT_RUNNING)
		if(MINER_SMALL_DAMAGE)
			icon_state = "mining_drill_braced_[miner_upgrade_type]"
			set_light(MINER_LIGHT_SDAMAGE, MINER_LIGHT_SDAMAGE)
		if(MINER_MEDIUM_DAMAGE)
			icon_state = "mining_drill_[miner_upgrade_type]"
			set_light(MINER_LIGHT_MDAMAGE, MINER_LIGHT_MDAMAGE)
		if(MINER_DESTROYED)
			icon_state = "mining_drill_error_[miner_upgrade_type]"
			set_light(MINER_LIGHT_DESTROYED, MINER_LIGHT_DESTROYED)

/// Called whenever someone attacks the miner with a object which is considered a upgrade.The object needs to have a uptype var.
/obj/machinery/miner/proc/attempt_upgrade(obj/item/minerupgrade/upgrade, mob/user, params)
	if(miner_upgrade_type)
		to_chat(user, span_info("The [src]'s module sockets are already occupied by the [miner_upgrade_type]."))
		return FALSE
	if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
		user.visible_message(span_notice("[user] fumbles around figuring out how to install the module on [src]."),
		span_notice("You fumble around figuring out how to install the module on [src]."))
		var/fumbling_time = 15 SECONDS - 2 SECONDS * user.skills.getRating(SKILL_ENGINEER)
		if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
			return FALSE
	user.visible_message(span_notice("[user] begins attaching a module to [src]'s sockets."))
	to_chat(user, span_info("You begin installing the [upgrade] on the miner."))
	if(!do_after(user, 15 SECONDS, NONE, src, BUSY_ICON_BUILD))
		return FALSE
	switch(upgrade.uptype)
		if(MINER_RESISTANT)
			max_miner_integrity = 300
			miner_integrity = 300
		if(MINER_OVERCLOCKED)
			required_ticks = 60
		if(MINER_AUTOMATED)
			if(stored_mineral)
				SSpoints.supply_points[faction] += mineral_value * stored_mineral
				SSpoints.dropship_points += dropship_bonus * stored_mineral
				GLOB.round_statistics.points_from_mining += mineral_value * stored_mineral
				do_sparks(5, TRUE, src)
				playsound(loc,'sound/effects/phasein.ogg', 50, FALSE)
				say("Ore shipment has been sold for [mineral_value * stored_mineral] points.")
				stored_mineral = 0
				start_processing()
	miner_upgrade_type = upgrade.uptype
	user.visible_message(span_notice("[user] attaches the [miner_upgrade_type] to the [src]!"))
	qdel(upgrade)
	playsound(loc,'sound/items/screwdriver.ogg', 25, TRUE)
	update_icon()

/obj/machinery/miner/attackby(obj/item/I,mob/user,params)
	. = ..()
	if(istype(I, /obj/item/minerupgrade))
		var/obj/item/minerupgrade/upgrade = I
		if(!(miner_status == MINER_RUNNING))
			to_chat(user, span_info("[src]'s module sockets seem bolted down."))
			return FALSE
		attempt_upgrade(upgrade,user)

/obj/machinery/miner/welder_act(mob/living/user, obj/item/I)
	. = ..()
	var/obj/item/tool/weldingtool/weldingtool = I
	if((miner_status == MINER_RUNNING) && miner_upgrade_type)
		if(!weldingtool.remove_fuel(2,user))
			to_chat(user, span_info("You need more welding fuel to complete this task!"))
			return FALSE
		to_chat(user, span_info("You begin uninstalling the [miner_upgrade_type] from the miner!"))
		user.visible_message(span_notice("[user] begins dismantling the [miner_upgrade_type] from the miner."))
		if(!do_after(user, 30 SECONDS, NONE, src, BUSY_ICON_BUILD))
			return FALSE
		user.visible_message(span_notice("[user] dismantles the [miner_upgrade_type] from the miner!"))
		var/obj/item/upgrade
		switch(miner_upgrade_type)
			if(MINER_RESISTANT)
				upgrade = new /obj/item/minerupgrade/reinforcement
				if(miner_integrity < max_miner_integrity)
					miner_integrity = round(miner_integrity/3)
					set_miner_status()
				else
					miner_integrity = initial(miner_integrity)
				max_miner_integrity = initial(max_miner_integrity)
			if(MINER_OVERCLOCKED)
				upgrade = new /obj/item/minerupgrade/overclock
				required_ticks = initial(required_ticks)
			if(MINER_AUTOMATED)
				upgrade = new /obj/item/minerupgrade/automatic
		upgrade.forceMove(user.loc)
		miner_upgrade_type = null
		update_icon()
	if(miner_status != MINER_DESTROYED)
		return
	if(!weldingtool.remove_fuel(1, user))
		to_chat(user, span_warning("You need more welding fuel to complete this task."))
		return FALSE
	if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
		user.visible_message(span_notice("[user] fumbles around figuring out [src]'s internals."),
		span_notice("You fumble around figuring out [src]'s internals."))
		var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating(SKILL_ENGINEER)
		if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED, extra_checks = CALLBACK(weldingtool, /obj/item/tool/weldingtool/proc/isOn)))
			return FALSE
	playsound(loc, 'sound/items/weldingtool_weld.ogg', 25)
	user.visible_message(span_notice("[user] starts welding [src]'s internal damage."),
	span_notice("You start welding [src]'s internal damage."))
	add_overlay(GLOB.welding_sparks)
	if(!do_after(user, 200, NONE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(weldingtool, /obj/item/tool/weldingtool/proc/isOn)))
		cut_overlay(GLOB.welding_sparks)
		return FALSE
	if(miner_status != MINER_DESTROYED )
		cut_overlay(GLOB.welding_sparks)
		return FALSE
	playsound(loc, 'sound/items/welder2.ogg', 25, TRUE)
	miner_integrity = 0.33 * max_miner_integrity
	set_miner_status()
	user.visible_message(span_notice("[user] welds [src]'s internal damage."),
	span_notice("You weld [src]'s internal damage."))
	cut_overlay(GLOB.welding_sparks)
	record_miner_repair(user)
	return TRUE

/obj/machinery/miner/wirecutter_act(mob/living/user, obj/item/I)
	if(miner_status != MINER_MEDIUM_DAMAGE)
		return
	if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
		user.visible_message(span_notice("[user] fumbles around figuring out [src]'s wiring."),
		span_notice("You fumble around figuring out [src]'s wiring."))
		var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating(SKILL_ENGINEER)
		if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
			return FALSE
	playsound(loc, 'sound/items/wirecutter.ogg', 25, TRUE)
	user.visible_message(span_notice("[user] starts securing [src]'s wiring."),
	span_notice("You start securing [src]'s wiring."))
	if(!do_after(user, 120, NONE, src, BUSY_ICON_BUILD))
		return FALSE
	if(miner_status != MINER_MEDIUM_DAMAGE)
		return FALSE
	playsound(loc, 'sound/items/wirecutter.ogg', 25, TRUE)
	miner_integrity = 0.66 * max_miner_integrity
	set_miner_status()
	user.visible_message(span_notice("[user] secures [src]'s wiring."),
	span_notice("You secure [src]'s wiring."))
	record_miner_repair(user)
	return TRUE

/obj/machinery/miner/wrench_act(mob/living/user, obj/item/I)
	if(miner_status != MINER_SMALL_DAMAGE)
		return
	if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
		user.visible_message(span_notice("[user] fumbles around figuring out [src]'s tubing and plating."),
		span_notice("You fumble around figuring out [src]'s tubing and plating."))
		var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating(SKILL_ENGINEER)
		if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
			return FALSE
	playsound(loc, 'sound/items/ratchet.ogg', 25, TRUE)
	user.visible_message(span_notice("[user] starts repairing [src]'s tubing and plating."),
	span_notice("You start repairing [src]'s tubing and plating."))
	if(!do_after(user, 150, NONE, src, BUSY_ICON_BUILD))
		return FALSE
	if(miner_status != MINER_SMALL_DAMAGE)
		return FALSE
	playsound(loc, 'sound/items/ratchet.ogg', 25, TRUE)
	miner_integrity = max_miner_integrity
	set_miner_status()
	user.visible_message(span_notice("[user] repairs [src]'s tubing and plating."),
	span_notice("You repair [src]'s tubing and plating."))
	start_processing()
	faction = user.faction
	record_miner_repair(user)
	return TRUE

/obj/machinery/miner/examine(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	if(!miner_upgrade_type)
		. += span_info("[src]'s module sockets seem empty, an upgrade could be installed.")
	else
		. += span_info("[src]'s module sockets are occupied by the [miner_upgrade_type].")

	switch(miner_status)
		if(MINER_DESTROYED)
			. += span_info("It's heavily damaged, and you can see internal workings.</span>\n<span class='info'>Use a blowtorch, then wirecutters, then a wrench to repair it.")
		if(MINER_MEDIUM_DAMAGE)
			. += span_info("It's damaged, and there are broken wires hanging out.</span>\n<span class='info'>Use wirecutters, then wrench to repair it.")
		if(MINER_SMALL_DAMAGE)
			. += span_info("It's lightly damaged, and you can see some dents and loose piping.</span>\n<span class='info'>Use a wrench to repair it.")
		if(MINER_RUNNING)
			. += span_info("[src]'s storage module displays [stored_mineral] crates are ready to be exported.")

/obj/machinery/miner/attack_hand(mob/living/user)
	if(miner_status != MINER_RUNNING)
		to_chat(user, span_warning("[src] is damaged!"))
		return
	if(miner_upgrade_type == MINER_AUTOMATED)
		to_chat(user, span_warning("[src] is automated!"))
		return
	if(!stored_mineral)
		to_chat(user, span_warning("[src] is not ready to produce a shipment yet!"))
		return

	SSpoints.supply_points[faction] += mineral_value * stored_mineral
	SSpoints.dropship_points += dropship_bonus * stored_mineral
	GLOB.round_statistics.points_from_mining += mineral_value * stored_mineral
	do_sparks(5, TRUE, src)
	playsound(loc,'sound/effects/phasein.ogg', 50, FALSE)
	say("Ore shipment has been sold for [mineral_value * stored_mineral] points.")
	stored_mineral = 0
	start_processing()

/obj/machinery/miner/process()
	if(miner_status != MINER_RUNNING || mineral_value == 0)
		stop_processing()
		SSminimaps.remove_marker(src)
		var/marker_icon = "miner_[mineral_value >= PLATINUM_CRATE_SELL_AMOUNT ? "platinum" : "phoron"]_off"
		SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips.dmi', null, marker_icon))
		return
	if(add_tick >= required_ticks)
		if(miner_upgrade_type == MINER_AUTOMATED)
			for(var/direction in GLOB.cardinals)
				if(!isopenturf(get_step(loc, direction))) //Must be open on one side to operate
					continue
				SSpoints.supply_points[faction] += mineral_value
				SSpoints.dropship_points += dropship_bonus
				GLOB.round_statistics.points_from_mining += mineral_value
				do_sparks(5, TRUE, src)
				playsound(loc,'sound/effects/phasein.ogg', 50, FALSE)
				say("Ore shipment has been sold for [mineral_value] points.")
				add_tick = 0
				return
			playsound(loc,'sound/machines/buzz-two.ogg', 35, FALSE)
			add_tick = 0
			return
		stored_mineral += 1
		add_tick = 0
	if(stored_mineral >= 8)	//Stores 8 boxes worth of minerals
		stop_processing()
	else
		add_tick += 1

/obj/machinery/miner/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL) //Incorporeal xenos cannot attack physically.
		return
	if(miner_upgrade_type == MINER_RESISTANT && !(X.mob_size == MOB_SIZE_BIG || X.xeno_caste.caste_flags & CASTE_IS_STRONG))
		X.visible_message(span_notice("[X]'s claws bounce off of [src]'s reinforced plating."),
		span_notice("We can't slash through [src]'s reinforced plating!"))
		return
	while(miner_status != MINER_DESTROYED)
		if(X.do_actions)
			return balloon_alert(X, "busy")
		if(!do_after(X, 1.5 SECONDS, NONE, src, BUSY_ICON_DANGER, BUSY_ICON_HOSTILE))
			return
		X.do_attack_animation(src, ATTACK_EFFECT_CLAW)
		X.visible_message(span_danger("[X] slashes \the [src]!"), \
		span_danger("We slash \the [src]!"), null, 5)
		playsound(loc, "alien_claw_metal", 25, TRUE)
		miner_integrity -= 25
		set_miner_status()
		if(miner_status == MINER_DESTROYED && X.client)
			var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[X.ckey]
			personal_statistics.miner_sabotages_performed++

/obj/machinery/miner/proc/set_miner_status()
	var/health_percent = round((miner_integrity / max_miner_integrity) * 100)
	switch(health_percent)
		if(-INFINITY to 0)
			miner_status = MINER_DESTROYED
			stored_mineral = 0
		if(1 to 50)
			stored_mineral = 0
			miner_status = MINER_MEDIUM_DAMAGE
		if(51 to 99)
			stored_mineral = 0
			miner_status = MINER_SMALL_DAMAGE
		if(100 to INFINITY)
			start_processing()
			SSminimaps.remove_marker(src)
			var/marker_icon = "miner_[mineral_value >= PLATINUM_CRATE_SELL_AMOUNT ? "platinum" : "phoron"]_on"
			SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips.dmi', null, marker_icon))
			miner_status = MINER_RUNNING
	update_icon()

///Called via global signal to prevent perpetual mining
/obj/machinery/miner/proc/disable_on_hijack()
	mineral_value = 0
	miner_integrity = 0
	set_miner_status()
