#define MINE_LIVING_ONLY (1<<0)
#define MINE_VEHICLE_ONLY (1<<1)
#define MINE_LIVING_OR_VEHICLE MINE_LIVING_ONLY|MINE_VEHICLE_ONLY

/**
Mines

Mines have an invisible "tripwire" atom that explodes when crossed
Stepping directly on the mine will also blow it up
*/
/obj/item/explosive/mine
	name = "\improper M20 Claymore anti-personnel mine"
	desc = "The M20 Claymore is a directional proximity triggered anti-personnel mine designed by Armat Systems for use by the TerraGov Marine Corps."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "m20"
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 5
	throw_range = 6
	throw_speed = 3
	flags_atom = CONDUCT
	///Trigger flags for this mine
	var/target_mode = MINE_LIVING_ONLY
	/// IFF signal - used to determine friendly units
	var/iff_signal = NONE
	/// If the mine has been triggered
	var/triggered = FALSE
	/// State of the mine. Will the mine explode or not
	var/armed = FALSE
	/// Tripwire holds reference to the tripwire obj that is used to trigger an explosion
	var/obj/effect/mine_tripwire/tripwire

/obj/item/explosive/mine/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/item/explosive/mine/Destroy()
	QDEL_NULL(tripwire)
	return ..()

/// Update the icon, adding "_armed" if appropriate to the icon_state.
/obj/item/explosive/mine/update_icon()
	icon_state = "[initial(icon_state)][armed ? "_armed" : ""]"

/// On explosion mines trigger their own explosion, assuming there were not deleted straight away (larger explosions or probability)
/obj/item/explosive/mine/ex_act()
	. = ..()
	if(!QDELETED(src))
		INVOKE_ASYNC(src, PROC_REF(trigger_explosion))

/// Any emp effects mines will trigger their explosion
/obj/item/explosive/mine/emp_act()
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(trigger_explosion))

/// Flamer fire will cause mines to trigger their explosion
/obj/item/explosive/mine/flamer_fire_act(burnlevel)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(trigger_explosion))

/// attack_self is used to arm the mine
/obj/item/explosive/mine/attack_self(mob/living/user)
	if(!user.loc || user.loc.density)
		to_chat(user, span_warning("You can't plant a mine here."))
		return

	if(locate(/obj/item/explosive/mine) in get_turf(src))
		to_chat(user, span_warning("There already is a mine at this position!"))
		return

	if(armed)
		return
	if(!do_after(user, 10, NONE, src, BUSY_ICON_HOSTILE))
		user.visible_message(span_notice("[user] stops deploying [src]."), \
	span_notice("You stop deploying \the [src]."))
		return
	user.visible_message(span_notice("[user] finishes deploying [src]."), \
	span_notice("You finish deploying [src]."))
	var/obj/item/card/id/id = user.get_idcard()
	deploy_mine(user, id?.iff_signal)
	user.record_traps_created()

///this proc is used to deploy a mine
/obj/item/explosive/mine/proc/deploy_mine(mob/living/user, iff_sig)
	iff_signal = iff_sig
	anchored = TRUE
	armed = TRUE
	playsound(src.loc, 'sound/weapons/mine_armed.ogg', 25, 1)
	update_icon()
	if(user)
		user.drop_held_item()
		setDir(user.dir)
	else
		setDir(pick(CARDINAL_ALL_DIRS))
	tripwire = new /obj/effect/mine_tripwire(get_step(loc, dir))
	tripwire.linked_mine = src

/// Supports diarming a mine
/obj/item/explosive/mine/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!ismultitool(I) || !anchored)
		return

	user.visible_message(span_notice("[user] starts disarming [src]."), \
	span_notice("You start disarming [src]."))

	if(!do_after(user, 8 SECONDS, NONE, src, BUSY_ICON_FRIENDLY))
		user.visible_message("<span class='warning'>[user] stops disarming [src].", \
		"<span class='warning'>You stop disarming [src].")
		return

	user.visible_message("<span class='notice'>[user] finishes disarming [src].", \
	"<span class='notice'>You finish disarming [src].")
	anchored = FALSE
	armed = FALSE
	update_icon()
	QDEL_NULL(tripwire)

//Mine can also be triggered if you "cross right in front of it" (same tile)
/obj/item/explosive/mine/proc/on_cross(datum/source, atom/movable/A, oldloc, oldlocs)
	if(!isliving(A))
		return
	if(CHECK_MULTIPLE_BITFIELDS(A.pass_flags, HOVERING))
		return
	var/mob/living/L = A
	if(L.lying_angle) ///so dragged corpses don't trigger mines.
		return
	trip_mine(A)

/obj/item/explosive/mine/proc/trip_mine(atom/movable/victim)
	if(!armed || triggered)
		return FALSE
	var/mob/living/living_victim
	if((target_mode & MINE_LIVING_ONLY) && isliving(victim))
		living_victim = victim
	else if((target_mode & MINE_VEHICLE_ONLY) && isvehicle(victim))
		var/obj/vehicle/vehicle_victim = victim
		if(!length(vehicle_victim.occupants))
			return FALSE
		living_victim = vehicle_victim.occupants[1]

	if(!living_victim)
		return FALSE
	if((living_victim.status_flags & INCORPOREAL))
		return FALSE
	if(living_victim.stat == DEAD)
		return FALSE
	var/obj/item/card/id/id = living_victim.get_idcard()
	if(id?.iff_signal & iff_signal)
		return FALSE

	living_victim.visible_message(span_danger("[icon2html(src, viewers(living_victim))] \The [src] clicks as [victim] moves in front of it."), \
	span_danger("[icon2html(src, viewers(living_victim))] \The [src] clicks as you move in front of it."), \
	span_danger("You hear a click."))

	playsound(loc, 'sound/weapons/mine_tripped.ogg', 25, 1)
	INVOKE_ASYNC(src, PROC_REF(trigger_explosion))
	return TRUE

/// Alien attacks trigger the explosive to instantly detonate
/obj/item/explosive/mine/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE
	if(triggered) //Mine is already set to go off
		return

	if(X.a_intent == INTENT_HELP)
		return
	X.visible_message(span_danger("[X] has slashed [src]!"), \
	span_danger("We slash [src]!"))
	playsound(loc, 'sound/weapons/slice.ogg', 25, 1)
	INVOKE_ASYNC(src, PROC_REF(trigger_explosion))

/// Trigger an actual explosion and delete the mine.
/obj/item/explosive/mine/proc/trigger_explosion()
	if(triggered)
		return
	triggered = TRUE
	explosion(tripwire ? tripwire.loc : loc, light_impact_range = 3)
	QDEL_NULL(tripwire)
	qdel(src)

/// This is a mine_tripwire that is basically used to extend the mine and capture bump movement further infront of the mine
/obj/effect/mine_tripwire
	name = "claymore tripwire"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_MAXIMUM
	resistance_flags = UNACIDABLE
	var/obj/item/explosive/mine/linked_mine

/obj/effect/mine_tripwire/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/effect/mine_tripwire/Destroy()
	linked_mine = null
	return ..()

/// When crossed the tripwire triggers the linked mine
/obj/effect/mine_tripwire/proc/on_cross(datum/source, atom/movable/AM, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(!istype(AM))
		return

	if(!linked_mine)
		qdel(src)
		return

	if(CHECK_MULTIPLE_BITFIELDS(AM.pass_flags, HOVERING))
		return

	if(linked_mine.triggered) //Mine is already set to go off
		return

	if(!isliving(AM) && !(isvehicle(AM)))
		return
	linked_mine.trip_mine(AM)

/// PMC specific mine, with IFF for PMC units
/obj/item/explosive/mine/pmc
	name = "\improper M20P Claymore anti-personnel mine"
	desc = "The M20P Claymore is a directional proximity triggered anti-personnel mine designed by Armat Systems for use by the TerraGov Marine Corps. It has been modified for use by the NT PMC forces."
	icon_state = "m20p"

/obj/item/explosive/mine/anti_tank
	name = "\improper M92 Valiant anti-tank mine"
	desc = "The M92 Valiant is a anti-tank mine designed by Armat Systems for use by the TerraGov Marine Corps against heavy armour, both tanks and mechs."
	icon_state = "m92"
	target_mode = MINE_VEHICLE_ONLY

/obj/item/explosive/mine/anti_tank/trigger_explosion()
	if(triggered)
		return
	triggered = TRUE
	explosion(tripwire ? tripwire.loc : loc, 2, 0, 0, 4)
	QDEL_NULL(tripwire)
	qdel(src)

/obj/item/explosive/mine/anti_tank/ex_act()
	qdel(src)
