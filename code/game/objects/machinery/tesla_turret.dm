#define TESLA_TURRET_MAX_RANGE 6
///How many targets it can hit per activation
#define TESLA_TURRET_MAX_TARGETS 3
#define TESLA_TURRET_COST_PASSIVE 25
#define TESLA_TURRET_COST_ACTIVE 100

/obj/item/tesla_turret
	name = "tesla turret"
	desc = "A turret that drains plasma of nearby xenomorphs."
	icon = 'icons/obj/machines/deployable/sentry/tesla.dmi'
	icon_state = "tesla_coil_handheld"
	max_integrity = 200

	/// Variables to be used by the deployable, are moved into the deployable when deployed and back when undeployed.
	/// Range, duh.
	var/max_range = TESLA_TURRET_MAX_RANGE
	/// Battery to run on
	var/obj/item/cell/battery
	/// Cost for having active but doing nothing
	var/passive_cost = TESLA_TURRET_COST_PASSIVE
	/// Cost PER XENO to drain on shock
	var/active_cost = TESLA_TURRET_COST_ACTIVE

/obj/item/tesla_turret/Initialize(mapload)
	. = ..()
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
		balloon_alert(user, "no battery!")
		return
	user.put_in_hands(battery)
	balloon_alert(user, "removed battery")
	battery = null

/obj/item/tesla_turret/attack_hand_alternate(mob/living/user)
	. = ..()
	if(!in_range(src, user))
		return
	if(!battery)
		balloon_alert(user, "no battery!")
		return
	user.put_in_hands(battery)
	balloon_alert(user, "removed battery")
	battery = null

/obj/item/tesla_turret/attackby(obj/item/cell/inserting_item, mob/user, params)
	. = ..()
	if(!istype(inserting_item))
		return
	if(istype(inserting_item, /obj/item/cell/lasgun))
		balloon_alert(user, "won't fit!")
		return
	if(battery)
		balloon_alert(user, "already has one!")
		return
	if(!user.temporarilyRemoveItemFromInventory(inserting_item))
		return

	battery = inserting_item
	battery.moveToNullspace()
	return TRUE

/obj/machinery/deployable/tesla_turret
	icon = 'icons/obj/machines/deployable/sentry/tesla.dmi'
	icon_state = "defense_base_off"
	base_icon_state = "defense_base"
	density = TRUE
	anchored = TRUE
	resistance_flags = XENO_DAMAGEABLE
	allow_pass_flags = PASSABLE
	hud_possible = list(MACHINE_HEALTH_HUD, MACHINE_AMMO_HUD)
	/// Range, duh.
	var/max_range = TESLA_TURRET_MAX_RANGE
	/// Battery to run on
	var/obj/item/cell/battery
	/// Is this running
	VAR_PRIVATE/active = FALSE
	/// Cost for having active but doing nothing
	var/passive_cost = TESLA_TURRET_COST_PASSIVE
	/// Cost PER XENO to drain on shock
	var/active_cost = TESLA_TURRET_COST_ACTIVE

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
		balloon_alert(user, "won't fit!")
		return
	if(battery)
		balloon_alert(user, "already has one!")
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
		balloon_alert(user, "no battery!")
		return
	if(active)
		balloon_alert(user, "turn it off first!")
		return
	user.put_in_hands(battery)
	battery = null
	balloon_alert(user, "removed battery")
	update_appearance(UPDATE_ICON)

/obj/machinery/deployable/tesla_turret/interact(mob/user)
	. = ..()
	if(isdead(user))
		return
	if(!battery)
		balloon_alert(user, "no battery!")
		return
	if(!battery.use(0))
		balloon_alert(user, "no power!")
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
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/deployable/tesla_turret/process()
	if(!battery || !active || !battery.use(0))
		balloon_alert_to_viewers("shuts off")
		toggle(FALSE, TRUE)
		return
	if(!battery.use(passive_cost))
		balloon_alert_to_viewers("shuts off")
		toggle(FALSE, TRUE)
		hud_set_tesla_battery()
		return
	/// Needs to have enough charge to hit at least one xeno
	var/max_zap_targets = clamp(trunc(battery.charge / active_cost), 0, TESLA_TURRET_MAX_TARGETS)
	if(!max_zap_targets)
		hud_set_tesla_battery()
		return
	var/xeno_amount = length(zap_beam(src, max_range, 4, max_targets = max_zap_targets))
	if(!xeno_amount)
		hud_set_tesla_battery()
		return
	battery.use(active_cost * xeno_amount)
	playsound(src, 'sound/weapons/guns/fire/tesla.ogg', 60, TRUE)
	hud_set_tesla_battery()

/obj/machinery/deployable/tesla_turret/disassemble(mob/marine)
	if(active)
		if(shock(marine, 70))
			to_chat(marine, span_userdanger("You're shocked by \the [src]!"))
		else
			balloon_alert(marine, "turn it off first!")
		return
	return ..()

/obj/machinery/deployable/tesla_turret/post_disassemble(mob/user)
	. = ..()
	if(!.)
		return

	var/obj/item/tesla_turret/internal = internal_item.resolve()
	if(!internal)
		return
	internal.max_range = max_range
	internal.passive_cost = passive_cost
	internal.active_cost = active_cost

	internal.battery = battery
	battery = null

/obj/machinery/deployable/tesla_turret/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][battery ? "" : "_off"]"
	hud_set_tesla_battery()

/obj/machinery/deployable/tesla_turret/update_overlays()
	. = ..()
	. += "tesla_coil[active ? "_on" : ""]"
	hud_set_tesla_battery()

/// I hate this so much, thank you for having a flag called pass_projectile but it only does so up to proj.ammo.barricade_clear_distance
/obj/machinery/deployable/tesla_turret/projectile_hit(atom/movable/projectile/proj, cardinal_move, uncrossing)
	if(src != proj.original_target)
		return FALSE

	return ..()

#undef TESLA_TURRET_MAX_RANGE
#undef TESLA_TURRET_COST_PASSIVE
#undef TESLA_TURRET_COST_ACTIVE
