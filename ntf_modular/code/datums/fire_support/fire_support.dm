/datum/fire_support
	///time it takes to reload fully.
	var/solmode_rearm_duration = 3 MINUTES
	var/rearm_timer = 0
	var/bino_cooldown_mult = 1

/datum/fire_support/gau/solmode
	impact_quantity = 8
	uses = 5
	cooldown_duration = 5 SECONDS
	bino_cooldown_mult = 0.2

/datum/fire_support/rockets/solmode
	uses = 2
	scatter_range = 6
	impact_quantity = 12
	solmode_rearm_duration = 5 MINUTES
	bino_cooldown_mult = 0.5

/datum/fire_support/cruise_missile/solmode
	uses = 2
	solmode_rearm_duration = 10 MINUTES

/datum/fire_support/droppod/solmode
	fire_support_type = FIRESUPPORT_TYPE_SENTRY_POD_SOLMODE
	bino_cooldown_mult = 0.1

/datum/fire_support/droppod/supply/solmode
	fire_support_type = FIRESUPPORT_TYPE_SUPPLY_POD_SOLMODE
	bino_cooldown_mult = 0.1

//som shit has also lasting fire and overall crazy so i gotta gut em a bit.
/datum/fire_support/volkite/solmode
	uses = 3
	cooldown_duration = 10 SECONDS //they still got fire so give it a break
	fire_support_type = FIRESUPPORT_TYPE_VOLKITE_SOLMODE
	bino_cooldown_mult = 0.2

/datum/fire_support/incendiary_rockets/solmode
	uses = 2
	scatter_range = 6
	impact_quantity = 6
	fire_support_type = FIRESUPPORT_TYPE_INCEND_ROCKETS_SOLMODE
	solmode_rearm_duration = 5 MINUTES
	bino_cooldown_mult = 0.5

/datum/fire_support/rad_missile/solmode
	uses = 2
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

/obj/item/binoculars/fire_support/examine(mob/user)
	. = ..()
	. += span_warning("Rearm in [round(timeleft(mode.rearm_timer) MILLISECONDS)] seconds.")

/obj/item/binoculars/fire_support/extended/equipped(mob/user, slot)
	. = ..()
	if(user.faction != faction)
		user.balloon_alert_to_viewers("drops [src] due to an electric shock!")
		user.dropItemToGround(src)

/obj/item/binoculars/fire_support/extended/acquire_target(atom/target, mob/living/carbon/human/user)
	if(!(COOLDOWN_FINISHED(src, bino_cooldown_timer)))
		balloon_alert(user, "Too soon! Systems recalibrating... [round((bino_cooldown_timer - world.time)/10)]s")
		return
	. = ..()
	if(!.)
		return
	if(mode && mode.solmode_rearm_duration && !mode.rearm_timer) //start rearming timer after first use.
		mode.rearm_timer = addtimer(CALLBACK(src, PROC_REF(recharge_weapon), mode, user), mode.solmode_rearm_duration, TIMER_CLIENT_TIME)
	COOLDOWN_START(src, bino_cooldown_timer, (bino_cooldown * mode.bino_cooldown_mult))

/obj/item/binoculars/fire_support/extended/proc/recharge_weapon(var/datum/fire_support/weapontype, mob/living/carbon/human/user)
	playsound(loc, 'sound/effects/radiostatic.ogg', 50, TRUE)
	weapontype.enable_firesupport(initial(weapontype.uses) - weapontype.uses)
	if(user.get_active_held_item(src)) //if still holding this shit
		balloon_alert(user, "[weapontype] fully rearmed.")
		to_chat(user, span_notice("[weapontype] fully rearmed."))
