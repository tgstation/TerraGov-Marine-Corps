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

	/// IFF signal - used to determine friendly units
	var/iff_signal = NONE
	/// If the mine has been triggered
	var/triggered = FALSE
	/// State of the mine. Will the mine explode or not
	var/armed = FALSE
	/// Tripwire holds reference to the tripwire obj that is used to trigger an explosion
	var/obj/effect/mine_tripwire/tripwire

/obj/item/explosive/mine/Initialize()
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_cross,
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
		INVOKE_ASYNC(src, .proc/trigger_explosion)

/// Any emp effects mines will trigger their explosion
/obj/item/explosive/mine/emp_act()
	. = ..()
	INVOKE_ASYNC(src, .proc/trigger_explosion)

/// Flamer fire will cause mines to trigger their explosion
/obj/item/explosive/mine/flamer_fire_act(burnlevel)
	. = ..()
	INVOKE_ASYNC(src, .proc/trigger_explosion)

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

	user.visible_message(span_notice("[user] starts deploying [src]."), \
	span_notice("You start deploying [src]."))
	if(!do_after(user, 40, TRUE, src, BUSY_ICON_HOSTILE))
		user.visible_message(span_notice("[user] stops deploying [src]."), \
	span_notice("You stop deploying \the [src]."))
		return
	user.visible_message(span_notice("[user] finishes deploying [src]."), \
	span_notice("You finish deploying [src]."))
	var/obj/item/card/id/id = user.get_idcard()
	deploy_mine(user, id?.iff_signal)

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

	if(!do_after(user, 8 SECONDS, TRUE, src, BUSY_ICON_FRIENDLY))
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
	if(CHECK_MULTIPLE_BITFIELDS(A.flags_pass, HOVERING))
		return
	var/mob/living/L = A
	if(L.lying_angle) ///so dragged corpses don't trigger mines.
		return
	trip_mine(A)

/obj/item/explosive/mine/proc/trip_mine(mob/living/L)
	if(!armed || triggered)
		return FALSE
	if((L.status_flags & INCORPOREAL))
		return FALSE
	var/obj/item/card/id/id = L.get_idcard()
	if(id?.iff_signal & iff_signal)
		return FALSE

	L.visible_message(span_danger("[icon2html(src, viewers(L))] \The [src] clicks as [L] moves in front of it."), \
	span_danger("[icon2html(src, viewers(L))] \The [src] clicks as you move in front of it."), \
	span_danger("You hear a click."))

	playsound(loc, 'sound/weapons/mine_tripped.ogg', 25, 1)
	INVOKE_ASYNC(src, .proc/trigger_explosion)
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
	INVOKE_ASYNC(src, .proc/trigger_explosion)

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

/obj/effect/mine_tripwire/Initialize()
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_cross,
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/effect/mine_tripwire/Destroy()
	linked_mine = null
	return ..()

/// When crossed the tripwire triggers the linked mine
/obj/effect/mine_tripwire/proc/on_cross(datum/source, atom/A, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(!linked_mine)
		qdel(src)
		return

	if(CHECK_MULTIPLE_BITFIELDS(A.flags_pass, HOVERING))
		return

	if(linked_mine.triggered) //Mine is already set to go off
		return

	if(linked_mine && isliving(A))
		linked_mine.trip_mine(A)

/// PMC specific mine, with IFF for PMC units
/obj/item/explosive/mine/pmc
	name = "\improper M20P Claymore anti-personnel mine"
	desc = "The M20P Claymore is a directional proximity triggered anti-personnel mine designed by Armat Systems for use by the TerraGov Marine Corps. It has been modified for use by the NT PMC forces."
	icon_state = "m20p"
