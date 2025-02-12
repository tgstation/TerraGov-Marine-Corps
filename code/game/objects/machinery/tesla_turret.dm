/obj/item/tesla_turret
	name = "tesla turret"
	desc = "A turret that drains plasma of nearby xenomorphs."
	icon = 'icons/obj/machines/deployable/sentry/tesla.dmi'
	icon_state = "grounding_rod_open0"
	max_integrity = 200

	/// Variables to be used by the deployable, are moved into the deployable when deployed and back when undeployed.
	/// Range, duh.
	var/max_range = 5
	/// Battery to run on
	var/obj/item/cell/battery
	/// Cost for having active but doing nothing
	var/passive_cost = 25
	/// Cost PER XENO to drain on shock
	var/active_cost = 75

/obj/item/tesla_turret/Initialize(mapload)
	. = ..()
	var/matrix/M = transform
	M.Scale(0.75)
	transform = M

	AddComponent(/datum/component/deployable_item, /obj/machinery/deployable/tesla_turret, 2 SECONDS, 4 SECONDS)

/obj/item/tesla_turret/Destroy()
	QDEL_NULL(battery)
	return ..()

/obj/item/tesla_turret/examine(mob/user)
	. = ..()
	if(!in_range(src, user))
		return
	if(!battery)
		. += span_warning("It lacks a battery and will not turn on.")
		return
	. += span_notice("There is \a [battery] inside. [battery.charge]/[battery.maxcharge] left.")
	. += span_notice("<b>Use</b> inhand or <b>Right-click</b> to remove it.")

/obj/item/tesla_turret/get_mechanics_info()
	. = ..()
	. += "It has a range of [max_range] tile\s."
	. += "<br>"
	. += "It passively uses [passive_cost] power."
	. += "<br>"
	. += "It will drain [active_cost] power per xenomorph hit."

/obj/item/tesla_turret/attack_self(mob/living/user)
	. = ..()
	if(!in_range(src, user))
		return
	if(!battery)
		balloon_alert(user, "no battery")
		return
	user.put_in_hands(battery)
	balloon_alert(user, "removed battery")
	battery = null

/obj/item/tesla_turret/attack_hand_alternate(mob/living/user)
	. = ..()
	if(!in_range(src, user))
		return
	if(!battery)
		balloon_alert(user, "no battery")
		return
	if(!user.put_in_hands(battery))
		battery.forceMove(drop_location())
	balloon_alert(user, "removed battery")
	battery = null

/obj/item/tesla_turret/attackby(obj/item/cell/inserting_item, mob/user, params)
	. = ..()
	if(!istype(inserting_item))
		return
	if(istype(inserting_item, /obj/item/cell/lasgun))
		balloon_alert(user, "won't fit")
		return
	if(battery)
		balloon_alert(user, "already has")
		return
	if(!user.temporarilyRemoveItemFromInventory(inserting_item))
		return

	battery = inserting_item
	battery.moveToNullspace()
	return TRUE

/obj/machinery/deployable/tesla_turret
	icon = 'icons/obj/machines/deployable/sentry/tesla.dmi'
	icon_state = "grounding_rod0"
	base_icon_state = "grounding_rod"
	density = TRUE
	anchored = TRUE
	resistance_flags = XENO_DAMAGEABLE
	allow_pass_flags = PASSABLE
	hud_possible = list(MACHINE_HEALTH_HUD, MACHINE_AMMO_HUD)
	/// Range, duh.
	var/max_range = 5
	/// Battery to run on
	var/obj/item/cell/battery
	/// Is this running
	VAR_PRIVATE/active = FALSE
	/// Cost for having active but doing nothing
	var/passive_cost = 25
	/// Cost PER XENO to drain on shock
	var/active_cost = 75

/obj/machinery/deployable/tesla_turret/Initialize(mapload, obj/item/tesla_turret/internal_item, mob/deployer)
	. = ..()
	if(internal_item)
		max_range = internal_item.max_range
		passive_cost = internal_item.passive_cost
		active_cost = internal_item.active_cost

		battery = internal_item.battery
		internal_item.battery = null

/obj/machinery/deployable/tesla_turret/Destroy()
	QDEL_NULL(battery)
	return ..()

/obj/machinery/deployable/tesla_turret/examine(mob/user)
	. = ..()
	if(!in_range(src, user))
		return
	if(!battery)
		. += span_warning("It lacks a battery and will not turn on.")
		return
	. += span_notice("There is \a [battery] inside. [battery.charge]/[battery.maxcharge] left.")
	. += span_notice("<b>Right-click</b> to remove it.")
	if(!active)
		return
	. += span_warning("It is currently active.")

/obj/machinery/deployable/tesla_turret/get_mechanics_info()
	. = ..()
	. += "<br>"
	. += "It has a range of [max_range] tile\s."
	. += "<br>"
	. += "It passively uses [passive_cost] power."
	. += "<br>"
	. += "It will drain [active_cost] power per xenomorph hit."

/obj/machinery/deployable/tesla_turret/attackby(obj/item/cell/inserting_item, mob/user, params)
	. = ..()
	if(!istype(inserting_item))
		return
	if(istype(inserting_item, /obj/item/cell/lasgun))
		balloon_alert(user, "won't fit")
		return
	if(battery)
		balloon_alert(user, "already has")
		return
	if(!user.temporarilyRemoveItemFromInventory(inserting_item))
		return

	battery = inserting_item
	battery.moveToNullspace()
	update_appearance(UPDATE_ICON)
	return TRUE

/obj/machinery/deployable/tesla_turret/attack_hand_alternate(mob/living/user)
	. = ..()
	if(!in_range(src, user))
		return
	if(!battery)
		balloon_alert(user, "no battery")
		return
	if(active)
		balloon_alert(user, "turn off first")
		return
	user.put_in_hands(battery)
	battery = null
	balloon_alert(user, "removed battery")
	update_appearance(UPDATE_ICON)

/obj/machinery/deployable/tesla_turret/interact(mob/user)
	. = ..()
	// Tell me again why ghosts can call interact uninterrupted again?
	if(istype(user, /mob/dead))
		return
	if(!battery)
		balloon_alert(user, "no battery")
		return
	if(!battery.use(0))
		balloon_alert(user, "no power")
		return
	toggle(!active)

/obj/machinery/deployable/tesla_turret/proc/toggle(state, silent = FALSE)
	if(state)
		active = TRUE
		START_PROCESSING(SSobj, src)
		if(!silent)
			balloon_alert_to_viewers("turned on")
	else
		active = FALSE
		STOP_PROCESSING(SSobj, src)
		if(!silent)
			balloon_alert_to_viewers("turned off")
	update_appearance(UPDATE_ICON)

/obj/machinery/deployable/tesla_turret/process()
	if(!battery || !active || !battery.use(0))
		balloon_alert_to_viewers("shuts off!")
		toggle(FALSE, TRUE)
		return
	if(battery.use(passive_cost))
		/// Needs to have enough charge to hit at least one xeno
		var/max_targets = max(trunc(battery.charge / active_cost), 0)
		if(!max_targets)
			hud_set_tesla_battery()
			return
		var/xeno_amount = length(zap_beam(src, max_range, 4, max_targets = max_targets))
		if(!xeno_amount)
			hud_set_tesla_battery()
			return
		battery.use(active_cost * xeno_amount)
		playsound(src, 'sound/weapons/guns/fire/tesla.ogg', 60, TRUE)
	else
		balloon_alert_to_viewers("shuts off!")
		toggle(FALSE, TRUE)
	hud_set_tesla_battery()

/obj/machinery/deployable/tesla_turret/MouseDrop(mob/living/carbon/human/marine)
	if(marine != usr || !in_range(src, marine))
		return
	if(active)
		if(shock(marine, 70))
			balloon_alert_to_viewers("sparks!")
		else
			balloon_alert(marine, "turn off first!")
		return
	if(battery)
		var/obj/item/tesla_turret/internal = internal_item.resolve()
		if(internal)
			internal.max_range = max_range
			internal.passive_cost = passive_cost
			internal.active_cost = active_cost

			internal.battery = battery
			battery = null
	return ..()

/obj/machinery/deployable/tesla_turret/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][!!battery]"
	if(active)
		icon_state = "[base_icon_state]hit"
	hud_set_tesla_battery()
