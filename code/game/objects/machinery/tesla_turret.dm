/obj/item/tesla_turret
	name = "tesla turret"
	desc = "A turret that drains plasma of nearby xenomorphs."
	icon = 'icons/obj/machines/deployable/sentry/tesla.dmi'
	icon_state = "grounding_rod_open0"
	max_integrity = 250
	var/obj/item/cell/battery

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
	if(!battery || !in_range(src, user))
		return
	. += span_notice("There is \a [battery] inside. [battery.charge]/[battery.maxcharge] left.")
	. += span_notice("Alt-click to remove it.")

/obj/item/tesla_turret/AltClick(mob/user)
	. = ..()
	if(!in_range(src, user))
		return
	if(!battery)
		balloon_alert(user, "no battery")
		return
	if(!user.put_in_active_hand(battery))
		battery.forceMove(drop_location())
	balloon_alert(user, "removed battery")
	battery = null

/obj/item/tesla_turret/attackby(obj/item/cell/inserting_item, mob/user, params)
	. = ..()
	if(!istype(inserting_item))
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
	/// Range, duh.
	var/max_range = 5
	/// Battery to run on
	var/obj/item/cell/battery
	/// Is this running
	VAR_PRIVATE/active = FALSE
	/// Cost for having active but doing nothing
	var/passive_cost = 50
	/// Cost PER XENO to drain on shock
	var/active_cost = 100

/obj/machinery/deployable/tesla_turret/Initialize(mapload, obj/item/tesla_turret/internal_item, mob/deployer)
	. = ..()
	if(internal_item?.battery)
		battery = internal_item.battery
		internal_item.battery = null

/obj/machinery/deployable/tesla_turret/examine(mob/user)
	. = ..()
	if(!battery || !in_range(src, user))
		return
	. += span_notice("There is \a [battery] inside. [battery.charge]/[battery.maxcharge] left.")
	. += span_notice("Alt-click to remove it.")
	if(!active)
		return
	. += span_warning("It is currently active.")

/obj/machinery/deployable/tesla_turret/attackby(obj/item/cell/inserting_item, mob/user, params)
	. = ..()
	if(!istype(inserting_item))
		return
	if(!user.temporarilyRemoveItemFromInventory(inserting_item))
		return

	battery = inserting_item
	battery.moveToNullspace()
	update_appearance(UPDATE_ICON)
	return TRUE

/obj/machinery/deployable/tesla_turret/AltClick(mob/user)
	. = ..()
	if(!in_range(src, user))
		return
	if(!battery)
		balloon_alert(user, "no battery")
		return
	if(active)
		balloon_alert(user, "turn off first")
		return
	if(!user.put_in_active_hand(battery))
		battery.forceMove(drop_location())
	battery = null
	balloon_alert(user, "removed battery")
	update_appearance(UPDATE_ICON)

/obj/machinery/deployable/tesla_turret/interact(mob/user)
	. = ..()
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
			return
		var/xeno_amount = length(zap_beam(src, max_range, 4, max_targets = max_targets))
		if(!xeno_amount)
			return
		/// I will actually explode if this math doesn't work
		battery.use(active_cost * xeno_amount)
		playsound(src, 'sound/weapons/guns/fire/tesla.ogg', 60, TRUE)
	else
		balloon_alert_to_viewers("shuts off!")
		toggle(FALSE, TRUE)

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
			internal.battery = battery
			battery = null
	return ..()

/obj/machinery/deployable/tesla_turret/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][!!battery]"
	if(active)
		icon_state = "[base_icon_state]hit"
