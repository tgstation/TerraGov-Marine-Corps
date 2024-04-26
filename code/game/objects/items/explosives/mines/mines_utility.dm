/* Tactical mines - Non-lethal, utility-focused gadgets */
/obj/item/mine/alarm
	name = "\improper S20 Proximity Alarm"
	desc = "The S20 proximity mine serve a different purpose other than exploding. Instead it will announce enemy movements, giving early warning when hostiles approach."
	icon_state = "m20"
	detonation_message = "blares \"Intruder detected!\""
	detonation_sound = 'sound/machines/triple_beep.ogg'
	range = 5
	duration = -1
	undeploy_delay = 0.5 SECONDS
	deploy_delay = 1 SECONDS
	mine_features = MINE_STANDARD_FLAGS|MINE_REUSABLE
	///Internal radio that transmits alerts, spawned on Initialize()
	var/obj/item/radio/radio
	///To prevent spam
	COOLDOWN_DECLARE(alarm_cooldown)
	///Time between alarm messages
	var/cooldown = 2 SECONDS
	///Reference to the unique timer that deletes the minimap icon when done
	var/minimap_timer
	///How long a minimap icon remains
	var/minimap_duration = 7 SECONDS

/obj/item/mine/alarm/Initialize()
	. = ..()
	radio = new(src)
	radio.frequency = FREQ_COMMON	//Frequency argument on talk_into is bugged so making it common by default

/obj/item/mine/alarm/trip_mine(atom/movable/victim)
	if(!COOLDOWN_CHECK(src, alarm_cooldown))
		return
	return ..()

/obj/item/mine/alarm/extra_effects(atom/movable/victim)
	triggered = FALSE	//Reset the mine but not disarm it
	if(!victim)
		return FALSE

	var/mini_icon = "defiler"	//Closest thing to a generic warning icon
	if(isxeno(victim))
		var/mob/living/carbon/xenomorph/beno_victim = victim
		mini_icon = beno_victim.xeno_caste.minimap_icon
	else if(ishuman(victim))
		var/mob/living/carbon/human/human_victim = victim
		if(human_victim.job)
			mini_icon = human_victim.job.minimap_icon

	var/marker_flags
	if(CHECK_BITFIELD(iff_signal, TGMC_LOYALIST_IFF))
		marker_flags |= MINIMAP_FLAG_MARINE
	else	//I have been told ERT factions don't have a minimap anyways
		marker_flags |= MINIMAP_FLAG_MARINE_SOM

	radio.talk_into(src, "ALERT! Hostile/Unknown: [victim.name] | [AREACOORD_NO_Z(src)]")
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, z, marker_flags, mini_icon)
	deltimer(minimap_timer)
	minimap_timer = addtimer(CALLBACK(SSminimaps, TYPE_PROC_REF(/datum/controller/subsystem/minimaps, remove_marker), src), minimap_duration, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
	COOLDOWN_START(src, alarm_cooldown, cooldown)

/obj/item/mine/alarm/disarm()
	. = ..()
	SSminimaps.remove_marker(src)	//Do a minimap icon removal on being disarmed just in case

/obj/item/mine/emp
	name = "\improper EMP mine"
	desc = "Emits a powerful electromagnetic pulse that disables electronics."
	icon_state = "m20"
	detonation_message = "makes a high pitched whine."
	detonation_sound = 'sound/effects/nightvision.ogg'
	range = 3
	duration = 1.5 SECONDS
	undeploy_delay = 2 SECONDS
	deploy_delay = 2 SECONDS
	mine_features = MINE_STANDARD_FLAGS|MINE_REUSABLE|MINE_CUSTOM_RANGE
	///The internal cell powering it
	var/obj/item/cell/battery

/obj/item/mine/emp/Initialize()
	. = ..()
	if(battery)
		battery = new battery(src)

/obj/item/mine/emp/examine(mob/user)
	. = ..()
	. += span_notice("[battery ? "Battery Charge - [PERCENT(battery.charge/battery.maxcharge)]%" : "No battery installed."]")

/obj/item/mine/emp/attackby(obj/item/I, mob/user, params)
	if(!iscell(I))
		return ..()

	if(battery)
		balloon_alert(user, "There is already a battery installed!")
		return

	user.transferItemToLoc(I, src)
	battery = I
	update_icon()

/obj/item/mine/emp/screwdriver_act(mob/living/user, obj/item/I)
	if(!battery)
		balloon_alert(user, "No battery installed!")
		return

	user.put_in_hands(battery)
	battery = null
	update_icon()

/obj/item/mine/emp/trip_mine(atom/movable/victim)
	if(!battery?.charge)
		return FALSE
	return ..()

/obj/item/mine/emp/extra_effects(atom/movable/victim)
	addtimer(CALLBACK(src, PROC_REF(do_empulse)), duration - 1)	//Make the timer slightly less than duration otherwise it gets disarmed

///Separate proc that performs empulse() if it was not disarmed before the timer was done
/obj/item/mine/emp/proc/do_empulse()
	if(!battery?.charge)
		return FALSE
	if(!triggered)
		return FALSE
	//Find the logarithm of current charge, subtract 2, multiply it to the power of 3, then round down
	//Best formula I could come up with that kept scaling smooth and didn't have extreme highs or lows
	//Standard cell (1k charge) will only affect the tile it is on; a hyper cell (30k charge) will reach 15 tiles
	var/light_emp_range = FLOOR((log(10, battery.charge) - 2) ** 3, 1)
	var/heavy_emp_range = FLOOR(light_emp_range/2, 1)	//Heavy range is half of the light range rounded down
	empulse(get_turf(src), heavy_emp_range, light_emp_range)
	battery.charge = 0	//Detonation always drains the battery completely

/obj/item/mine/emp/battery_included
	battery = /obj/item/cell/high

/obj/item/mine/flash
	name = "flash mine"
	desc = "Blinds nearby enemies when activated."
	icon_state = "flash"
	detonation_message = "clicks."
	range = 4
	duration = -1
	undeploy_delay = 1 SECONDS
	deploy_delay = 1 SECONDS
	mine_features = MINE_STANDARD_FLAGS|MINE_REUSABLE
	///How long to blind a victim
	var/flash_duration = 3 SECONDS
	///The internal cell powering it
	var/obj/item/cell/battery
	///How much energy is drained from the internal cell
	var/energy_cost = 500	//Average cell holds 1000, so has 2 charges
	///To prevent spam
	COOLDOWN_DECLARE(flash_cooldown)
	///Time between alarm messages
	var/cooldown = 3 SECONDS

/obj/item/mine/flash/Initialize()
	. = ..()
	if(battery)
		battery = new battery(src)

/obj/item/mine/flash/examine(mob/user)
	. = ..()
	. += span_notice("[battery ? "Battery Charge - [PERCENT(battery.charge/battery.maxcharge)]%" : "No battery installed."]")

/obj/item/mine/flash/attackby(obj/item/I, mob/user, params)
	if(!iscell(I))
		return ..()

	if(battery)
		balloon_alert(user, "There is already a battery installed!")
		return

	user.transferItemToLoc(I, src)
	battery = I
	update_icon()

/obj/item/mine/flash/screwdriver_act(mob/living/user, obj/item/I)
	if(!battery)
		balloon_alert(user, "No battery installed!")
		return

	user.put_in_hands(battery)
	battery = null
	update_icon()

/obj/item/mine/flash/trip_mine(atom/movable/victim)
	if(!COOLDOWN_CHECK(src, flash_cooldown))
		return FALSE

	if(!battery?.charge)
		return FALSE

	return ..()

/obj/item/mine/flash/extra_effects(atom/movable/victim)
	if(!battery?.charge || battery.charge < energy_cost)
		balloon_alert_to_viewers("Out of charge!")
		disarm()
		return

	triggered = FALSE	//Reset the mine but not disarm it
	var/turf/epicenter = get_turf(src)
	playsound(epicenter, "flashbang", 65, FALSE, range + 2)

	for(var/mob/living/carbon/bystander in oviewers(range, epicenter))
		if(!HAS_TRAIT(bystander, TRAIT_FLASHBANGIMMUNE))
			bystander.flash_act(duration = flash_duration)

	battery.charge -= energy_cost
	COOLDOWN_START(src, flash_cooldown, cooldown)

/obj/item/mine/flash/battery_included
	battery = /obj/item/cell
