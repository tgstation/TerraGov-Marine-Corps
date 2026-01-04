/datum/fire_support
	///time it takes to reload fully.
	var/solmode_rearm_duration = 3 MINUTES
	var/rearm_timer
	var/bino_cooldown_mult = 1

/datum/fire_support/gau/solmode
	uses = 5
	impact_quantity = 8
	solmode_rearm_duration = 5 SECONDS
	cooldown_duration = 15 SECONDS
	bino_cooldown_mult = 0.2

/datum/fire_support/rockets/solmode
	uses = 4
	impact_quantity = 12
	solmode_rearm_duration = 5 MINUTES
	cooldown_duration = 15 SECONDS
	bino_cooldown_mult = 0.5

/datum/fire_support/cruise_missile/solmode
	uses = 2
	cooldown_duration = 30 SECONDS
	solmode_rearm_duration = 10 MINUTES

/datum/fire_support/droppod/solmode
	fire_support_type = FIRESUPPORT_TYPE_SENTRY_POD_SOLMODE
	solmode_rearm_duration = 4
	bino_cooldown_mult = 0.1

/datum/fire_support/droppod/supply/solmode
	fire_support_type = FIRESUPPORT_TYPE_SUPPLY_POD_SOLMODE
	solmode_rearm_duration = 4
	bino_cooldown_mult = 0.1

//som shit has also lasting fire and overall crazy so i gotta gut em a bit.
/datum/fire_support/volkite/solmode
	uses = 4
	cooldown_duration = 30 SECONDS //they still got fire so give it a break
	solmode_rearm_duration = 5 MINUTES
	fire_support_type = FIRESUPPORT_TYPE_VOLKITE_SOLMODE
	bino_cooldown_mult = 0.2

/datum/fire_support/incendiary_rockets/solmode
	uses = 3
	impact_quantity = 6
	fire_support_type = FIRESUPPORT_TYPE_INCEND_ROCKETS_SOLMODE
	solmode_rearm_duration = 5 MINUTES
	cooldown_duration = 30 SECONDS
	bino_cooldown_mult = 0.5

/datum/fire_support/rad_missile/solmode
	uses = 2
	cooldown_duration = 1 MINUTES
	fire_support_type = FIRESUPPORT_TYPE_RAD_MISSILE_SOLMODE
	solmode_rearm_duration = 10 MINUTES

/datum/fire_support/tele_cope/solmode
	uses = 2
	fire_support_type = FIRESUPPORT_TYPE_TELE_COPE_SOLMODE
	solmode_rearm_duration = 10 MINUTES //free cope.
	bino_cooldown_mult = 0.1

/obj/item/binoculars/fire_support/extended
	name = "pair of NTC command laser-designator"
	desc = "A pair of binoculars, used to mark targets for tactical strikes, connected directly to factional ship systems and squadrons. Unique action to toggle mode. Ctrl+Click when using to target something."
	mode_list = list(
		FIRESUPPORT_TYPE_GUN_SOLMODE,
		FIRESUPPORT_TYPE_ROCKETS_SOLMODE,
		FIRESUPPORT_TYPE_CRUISE_MISSILE_SOLMODE,
		FIRESUPPORT_TYPE_SUPPLY_POD_SOLMODE,
		FIRESUPPORT_TYPE_SENTRY_POD_SOLMODE,
	)
	var/bino_cooldown = 30 SECONDS
	var/bino_cooldown_timer = 0
	var/list/weapon_cooldowns = list()
	faction = FACTION_TERRAGOV
	color = COLOR_RED_GRAY //so its distinguishable hopefully

/obj/item/binoculars/fire_support/extended/sl
	name = "pair of NTC SL laser-designator"
	mode_list = list(
		FIRESUPPORT_TYPE_GUN_SOLMODE,
		FIRESUPPORT_TYPE_ROCKETS_SOLMODE,
		FIRESUPPORT_TYPE_SUPPLY_POD_SOLMODE,
		FIRESUPPORT_TYPE_SENTRY_POD_SOLMODE,
	)

/obj/item/binoculars/fire_support/extended/som
	name = "pair of SOM command laser-designator"
	mode_list = list(
		FIRESUPPORT_TYPE_VOLKITE_SOLMODE,
		FIRESUPPORT_TYPE_INCEND_ROCKETS_SOLMODE,
		FIRESUPPORT_TYPE_RAD_MISSILE_SOLMODE,
		FIRESUPPORT_TYPE_TELE_COPE_SOLMODE,
	)
	faction = FACTION_SOM
	color = COLOR_TAN_ORANGE

/obj/item/binoculars/fire_support/extended/som/sl
	name = "pair of SOM SL laser-designator"
	mode_list = list(
		FIRESUPPORT_TYPE_VOLKITE_SOLMODE,
		FIRESUPPORT_TYPE_INCEND_ROCKETS_SOLMODE,
		FIRESUPPORT_TYPE_TELE_COPE_SOLMODE,
	)

/obj/item/binoculars/fire_support/extended/examine(mob/user)
	. = ..()
	if(!mode)
		return
	for(var/modething in mode_list)
		var/datum/fire_support/themode = GLOB.fire_support_types[modething]
		if(timeleft(themode.rearm_timer))
			. += span_warning("-[themode.name] - full rearm in [round(timeleft(themode.rearm_timer) MILLISECONDS)] seconds.")

/obj/item/binoculars/fire_support/extended/equipped(mob/user, slot)
	. = ..()
	if(user.faction != faction)
		user.balloon_alert_to_viewers("drops [src] due to an electric shock!")
		user.dropItemToGround(src)

/obj/item/binoculars/fire_support/extended/acquire_target(atom/target, mob/living/carbon/human/user)
	set waitfor = 0
	//had issues with parent so fuck it
	if(!(COOLDOWN_FINISHED(src, bino_cooldown_timer)))
		balloon_alert(user, "Too soon! Systems recalibrating... [round((bino_cooldown_timer - world.time)/10)]s")
		return
	if(user.do_actions)
		balloon_alert_to_viewers("busy!")
		return
	if(is_mainship_level(user.z))
		user.balloon_alert(user, "can't use these here!")
		return
	if(faction && user.faction != faction)
		balloon_alert_to_viewers("security locks engaged")
		return
	if(laser_overlay)
		to_chat(user, span_warning("You're already targeting something."))
		return
	if(!bino_checks(target, user))
		return
	if(!can_see_target(target, user))
		balloon_alert_to_viewers("no clear view!")
		return

	playsound(src, 'sound/effects/nightvision.ogg', 35)
	to_chat(user, span_notice("INITIATING LASER TARGETING. Stand still."))
	target_atom = target
	laser_overlay = image('icons/obj/items/projectiles.dmi', icon_state = "sniper_laser", layer =-LASER_LAYER)
	target_atom.apply_fire_support_laser(laser_overlay)
	if(!do_after(user, target_acquisition_delay, NONE, user, BUSY_ICON_HOSTILE, extra_checks = CALLBACK(src, PROC_REF(can_see_target), target, user)))
		to_chat(user, span_danger("You lose sight of your target!"))
		playsound(user,'sound/machines/click.ogg', 25, 1)
		unset_target()
		return
	if(!bino_checks(target, user))
		return

	playsound(src, 'sound/effects/binoctarget.ogg', 35)
	mode.initiate_fire_support(get_turf(target_atom), user)
	unset_target()
	if(mode && mode.solmode_rearm_duration && !timeleft(mode.rearm_timer)) //start rearming timer after first use.
		mode.rearm_timer = addtimer(CALLBACK(src, PROC_REF(recharge_weapon), mode, user), mode.solmode_rearm_duration, TIMER_STOPPABLE)
	COOLDOWN_START(src, bino_cooldown_timer, (bino_cooldown * mode.bino_cooldown_mult))

/obj/item/binoculars/fire_support/extended/proc/recharge_weapon(var/datum/fire_support/weapontype, mob/living/carbon/human/user)
	playsound(loc, 'sound/effects/radiostatic.ogg', 50, TRUE)
	weapontype.enable_firesupport(initial(weapontype.uses) - weapontype.uses)
	if(user.get_active_held_item(src)) //if still holding this shit
		balloon_alert(user, "[weapontype] fully rearmed.")
		to_chat(user, span_notice("[weapontype] fully rearmed."))
