//based on the tesla turret
//code by tery so blame them

#define TESLA_MAX_RANGE 5
#define TESLA_MAX_TARGETS 7
#define TESLA_COST_PASSIVE 1
#define TESLA_COST_ACTIVE 1

/obj/machinery/tesla_orb
	name = "mysterious orbs"
	desc = "A collection of mysterious floating orbs. You can see lightning arc between them, better not get too close."
	icon = 'icons/obj/tesla_orb.dmi'
	icon_state = "orb"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	allow_pass_flags = PASS_GLASS
	resistance_flags = RESIST_ALL
	light_on = TRUE
	light_range = 4
	light_power = 2
	light_color = COLOR_DARK_CYAN
	/// Range, duh.
	var/max_range = TESLA_MAX_RANGE
	/// Cost for having active but doing nothing
	var/passive_cost = TESLA_COST_PASSIVE
	/// Cost PER XENO to drain on shock
	var/active_cost = TESLA_COST_ACTIVE

/obj/machinery/tesla_orb/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	update_icon()
	///animate(src, time = 10, loop = -1, easing = LINEAR_EASING)

/obj/machinery/tesla_orb/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/machinery/tesla_orb/examine(mob/user)
	. = ..()
	if(!in_range(src, user))
		return
	. += span_warning("It seems to be volatile.")

/obj/machinery/tesla_orb/attack_hand_alternate(mob/living/user)
	. = ..()
	if(!in_range(src, user))
		return
	if(shock(user, 100))
		to_chat(user, span_userdanger("You're shocked by \the [src]!"))
		return

/obj/machinery/tesla_orb/interact(mob/user)
	. = ..()
	if(isdead(user))
		return
	if(shock(user, 100))
		to_chat(user, span_userdanger("You're shocked by \the [src]!"))
		return

/obj/machinery/tesla_orb/process()
	var/targets = length(zap_all(src, max_range, 30, 0, TESLA_MAX_TARGETS))
	if(!targets)
		return
	playsound(src, 'sound/weapons/guns/fire/tesla.ogg', 60, TRUE)

/// I hate this so much, thank you for having a flag called pass_projectile but it only does so up to proj.ammo.barricade_clear_distance
/obj/machinery/tesla_orb/projectile_hit(atom/movable/projectile/proj, cardinal_move, uncrossing)
	if(src != proj.original_target)
		return FALSE

	return ..()

#undef TESLA_MAX_RANGE
#undef TESLA_COST_PASSIVE
#undef TESLA_COST_ACTIVE
