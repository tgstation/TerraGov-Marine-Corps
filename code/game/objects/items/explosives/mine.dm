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
	/// Faction they belong too
	var/faction = NONE
	/// If the mine has been triggered
	var/triggered = FALSE
	/// State of the mine. Will the mine explode or not
	var/armed = FALSE
	/// Tripwire holds reference to the tripwire obj that is used to trigger an explosion
	var/list/obj/effect/mine_tripwire/tripwire = list()
	//how far the mine can detect, 0 means standard just infront and on it
	var/trip_range = 0
	//time it takes to deploy the mine
	var/deploy_time = 40
	//can be picked up
	var/pick_upable = FALSE
	//Do we make the click notification?
	var/click_sound = TRUE
	//how many times we can trigger if we can trigger multiple times
	COOLDOWN_DECLARE(mine_tripped)

/obj/item/explosive/mine/Initialize()
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

	user.visible_message(span_notice("[user] starts deploying [src]."), \
	span_notice("You start deploying [src]."))
	if(!do_after(user, deploy_time, TRUE, src, BUSY_ICON_HOSTILE))
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
	faction = user.faction
	anchored = TRUE
	armed = TRUE
	playsound(src.loc, 'sound/weapons/mine_armed.ogg', 25, 1)
	update_icon()

	if(user)
		user.drop_held_item()
		setDir(user.dir)
	else
		setDir(pick(CARDINAL_ALL_DIRS))
	if(!trip_range)
		var/obj/effect/mine_tripwire/wire = new(get_step(loc, dir))
		tripwire += wire
		wire.linked_mine = src
	else
		for(var/turf/open/floor/T in orange(trip_range,src))
			var/obj/effect/mine_tripwire/wire = new(T)
			tripwire += wire
			wire.linked_mine = src

/obj/item/explosive/mine/proc/undeploy_mine()
	QDEL_NULL(tripwire)
	anchored = FALSE
	armed = FALSE
	update_icon()

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
	if(COOLDOWN_CHECK(src,mine_tripped))
		L.visible_message(span_danger("[icon2html(src, viewers(L))] \The [src] clicks as [L] moves in front of it."), \
		span_danger("[icon2html(src, viewers(L))] \The [src] clicks as you move in front of it."), \
		span_danger("You hear a click."))
		playsound(loc, 'sound/weapons/mine_tripped.ogg', 25, 1)

	INVOKE_ASYNC(src, PROC_REF(trigger_explosion), L)
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
/obj/item/explosive/mine/proc/trigger_explosion(mob/living/tripper)
	if(triggered)
		return
	triggered = TRUE
	explosion(loc, light_impact_range = 3)
	QDEL_NULL(tripwire)
	qdel(src)

/obj/item/explosive/mine/MouseDrop()
	if(!pick_upable)
		return
	if(!do_after(usr, deploy_time, TRUE, src, BUSY_ICON_HOSTILE))
		usr.visible_message(span_notice("[usr] stops undeploying [src]."), \
		span_notice("You stop undeploying \the [src]."))
		return
	usr.visible_message(span_notice("[usr] finishes undeploying [src]."), \
	span_notice("You finish undeploying [src]."))
	undeploy_mine()

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
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
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
		var/mob/living/unlucky_person = A
		// Don't trigger for dead people
		if(unlucky_person.stat == DEAD)
			return
		linked_mine.trip_mine(A)

/// PMC specific mine, with IFF for PMC units
/obj/item/explosive/mine/pmc
	name = "\improper M20P Claymore anti-personnel mine"
	desc = "The M20P Claymore is a directional proximity triggered anti-personnel mine designed by Armat Systems for use by the TerraGov Marine Corps. It has been modified for use by the NT PMC forces."
	icon_state = "m20p"

/obj/item/explosive/mine/alert
	name = "\improper S20 Alert system"
	desc = "The S20 Alert system behaves much like a regulair mine. But instead of exploding it will alert marine forces of movements. Giving early warning when hostiles aproach"
	var/obj/item/radio/radio
	deploy_time = 5
	pick_upable = TRUE
	trip_range = 3

/obj/item/explosive/mine/alert/Initialize()
	. = ..()
	radio = new(src)

/obj/item/explosive/mine/alert/trigger_explosion(mob/living/tripper)
	if(!COOLDOWN_CHECK(src, mine_tripped))
		return
	COOLDOWN_START(src, mine_tripped, 3 SECONDS)
	if(tripper)
		var/mini_icon
		if(isxeno(tripper))
			var/mob/living/carbon/xenomorph/X = tripper
			mini_icon = X.xeno_caste.minimap_icon
		else
			mini_icon = tripper.job

		var/marker_flags
		if(faction == FACTION_TERRAGOV)
			marker_flags = MINIMAP_FLAG_MARINE
		else if(faction == FACTION_TERRAGOV_REBEL)
			marker_flags = MINIMAP_FLAG_MARINE_REBEL
		else if(faction == FACTION_SOM)
			marker_flags = MINIMAP_FLAG_MARINE_SOM
		else
			marker_flags = MINIMAP_FLAG_MARINE

		radio.talk_into(src, "<b>ALERT! [src] detected Hostile/Unknown: [tripper.name] at: [AREACOORD_NO_Z(src)].</b>", FREQ_COMMON)


		SSminimaps.add_marker(src, z, marker_flags, mini_icon)
		addtimer(CALLBACK(SSminimaps, TYPE_PROC_REF(/datum/controller/subsystem/minimaps, remove_marker),src), 5 SECONDS)
