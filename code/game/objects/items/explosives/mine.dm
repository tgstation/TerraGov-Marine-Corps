/**
Mines

Mines have an invisible "tripwire" atom that explodes when crossed
Stepping directly on the mine will also blow it up
*/
/obj/item/explosive/mine
	name = "\improper M20 Claymore anti-personnel mine"
	desc = "The M20 Claymore is a directional proximity triggered anti-personnel mine designed by Armat Systems for use by the TerraGov Marine Corps."
	icon_state = "m20"
	icon = 'icons/obj/items/grenade.dmi'
	resistance_flags = XENO_DAMAGEABLE
	flags_atom = CONDUCT
	w_class = WEIGHT_CLASS_SMALL
	force = 5
	throwforce = 5
	throw_range = 6
	throw_speed = 3
	///Message sent to nearby players when this mine is triggered; "The [name] [message]."
	var/detonation_message = "makes a loud click"
	///How many tiles around/in front of itself will trigger detonation
	var/range = 3
	///How many tiles around/in front of itself before it starts detecting; at 0, you can trigger the tile the mine is on
	var/buffer_range = 1
	///Determines how wide the cone for detecting victims is
	var/angle = 110
	///Time before the mine explodes
	var/detonation_delay = 0
	///Requires physical weight to detonate if touched; mine will detonate even if buffer_range is 0
	var/pressure_activated = FALSE
	///If TRUE, damage will cause this mine to explode; EMPs will disable volatile mines
	var/volatile = FALSE
	///Time it takes to disable this mine
	var/disarm_delay = 1 SECONDS
	///Time it takes to turn off and pack up a mine
	var/undeploy_delay = 1 SECONDS
	///Time it takes to set up a mine
	var/deploy_delay = 1 SECONDS
	/// IFF signal - used to determine friendly units
	var/iff_signal = NONE
	/// If the mine has been triggered
	var/triggered = FALSE
	/// State of the mine. Will the mine explode or not
	var/armed = FALSE
	///List of references to each dummy object that serve as triggers for this mine
	var/list/triggers = list()

	/* -- Explosion data -- */
	///How large the devestation impact is
	var/uber_explosion_range = 0
	///How large the heavy impact is
	var/heavy_explosion_range = 0
	///How large the light impact is
	var/light_explosion_range = 2
	///How far away a player can be to be blinded by the explosion
	var/blinding_range = 0
	///How far flames spread around the explosion
	var/incendiary_range = 0
	///How far away objects are thrown
	var/launch_distance = 0
	///Color of the explosion
	var/explosion_color = LIGHT_COLOR_LAVA	//Default used by explosions
	///The ammo datum used for this mine's shrapnel
	var/shrapnel_type = /datum/ammo/bullet/claymore_shrapnel
	///How far the shrapnel can go before it is deleted
	var/shrapnel_range = 5

/obj/item/explosive/mine/Initialize()
	. = ..()
	if(!buffer_range || pressure_activated)
		var/static/list/connections = list(COMSIG_ATOM_ENTERED = PROC_REF(on_cross))
		AddElement(/datum/element/connect_loc, connections)

/obj/item/explosive/mine/Destroy()
	QDEL_LIST(triggers)
	return ..()

/// Update the icon, adding "_armed" if appropriate to the icon_state.
/obj/item/explosive/mine/update_icon()
	icon_state = "[initial(icon_state)][armed ? "_armed" : ""]"

/obj/item/explosive/mine/attack_self(mob/living/user)
	. = ..()
	setup(user)

///Runs the checks for attempting to deploy a mine
/obj/item/explosive/mine/proc/setup(mob/living/user)
	if(!user.loc || user.loc.density)
		balloon_alert(user, "You can't plant a mine here.")
		return FALSE
	if(locate(/obj/item/explosive/mine) in get_turf(src))
		balloon_alert(user, "There already is a mine at this position!")
		return FALSE
	if(armed || triggered)	//Just in case
		return FALSE
	if(!do_after(user, deploy_delay, TRUE, src, BUSY_ICON_BUILD))
		return FALSE
	//Probably important to keep this logged, just in case
	visible_message(span_notice("[user] deploys a [src]."), span_notice("You deploy a [src]."))
	var/obj/item/card/id/id = user.get_idcard()
	deploy(user, id?.iff_signal)

///Process for arming the mine; anchoring, setting who it belongs to, generating the trigger zones
/obj/item/explosive/mine/proc/deploy(mob/living/user, faction)
	iff_signal = faction
	anchored = TRUE
	armed = TRUE
	playsound(src.loc, 'sound/weapons/mine_armed.ogg', 25, 1)
	if(user)
		user.temporarilyRemoveItemFromInventory(src)
		forceMove(drop_location())
		setDir(user.dir)
	else
		setDir(pick(CARDINAL_DIRS))
	if(range)
		var/list/trigger_turfs = generate_true_cone(get_turf(src), range, buffer_range, angle, dir2angle(dir), bypass_xeno = TRUE, air_pass = TRUE)
		for(var/turf/T in trigger_turfs)
			var/obj/effect/mine_tripwire/tripwire = new /obj/effect/mine_tripwire(T)
			tripwire.linked_mine = src
			triggers += tripwire
	update_icon()

/obj/item/explosive/mine/attack_hand(mob/living/user)
	. = ..()
	if(anchored || armed)
		undeploy(user)

///Required checks before a mine is turned off and packed up
/obj/item/explosive/mine/proc/undeploy(mob/living/user)
	if(iff_signal)	//Has to actually be registered with a faction, otherwise it's hostile to everyone!
		var/obj/item/card/id/id_card = user.get_idcard()
		if(id_card && id_card.iff_signal == iff_signal)
			if(undeploy_delay && !do_after(user, undeploy_delay, TRUE, src))
				return FALSE
			return disarm()
	balloon_alert(user, "Must be defused!")

/obj/item/explosive/mine/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(ismultitool(I))
		bomb_defusal(user)	//Sweaty palms time

///The process for trying to disarm a mine
/obj/item/explosive/mine/proc/bomb_defusal(mob/user)
	//Mine defusal time is de/increased by 1 second per skill point
	var/skill_issue = max(disarm_delay - user.skills.getRating(SKILL_ENGINEER) + SKILL_ENGINEER_ENGI, 0)
	if(skill_issue)	//If you got the time down to 0, you can just skip this whole disarming process you smart egg!
		if(user.skills.getRating(SKILL_ENGINEER) >= SKILL_ENGINEER_ENGI)
			user.visible_message(span_notice("[user] starts disarming [src]."), \
			span_notice("You start disarming [src]."))
		else
			user.visible_message(span_notice("[user] visibly struggles to disarm [src]."), \
			span_notice("You try your best to disarm [src]."))
		if(!do_after(user, skill_issue, TRUE, src, skill_issue > disarm_delay ? BUSY_ICON_UNSKILLED : BUSY_ICON_DANGER))
			user.visible_message("<span class='warning'>[user] stops disarming [src].", \
			"<span class='warning'>You stop disarming [src].")
			return FALSE
	user.visible_message("<span class='notice'>[user] disarmed [src].", \
	"<span class='notice'>You disarmed [src].")
	disarm(user)

///Turns off the mine
/obj/item/explosive/mine/proc/disarm()
	armed = FALSE
	anchored = FALSE
	if(triggered)	//Good job, you managed to disarm it before it blew
		triggered = FALSE
	update_icon()
	QDEL_LIST(triggers)

///Checks if a mob entered the tile this mine is on, and if it can cause it to trigger
/obj/item/explosive/mine/proc/on_cross(datum/source, atom/movable/A, oldloc, oldlocs)
	if(!isliving(A))
		return FALSE
	if(pressure_activated)
		if(!CHECK_MULTIPLE_BITFIELDS(A.flags_pass, HOVERING))	//Flying mobs can't trip this mine
			return trip_mine(A)
		return FALSE
	var/mob/living/L = A
	if(L.stat) //Weight-based mines will still be detonated by the dead! This only matters for things like claymores
		return FALSE
	trip_mine(A)

///Process for triggering detonation
/obj/item/explosive/mine/proc/trip_mine(mob/living/L)
	if(!armed || triggered)
		return FALSE
	if((L.status_flags & INCORPOREAL))
		return FALSE
	var/obj/item/card/id/id = L.get_idcard()
	if(id?.iff_signal & iff_signal)
		return FALSE
	visible_message(span_danger("[icon2html(src, viewers(src))] \The [src] [detonation_message]."))
	playsound(loc, 'sound/weapons/mine_tripped.ogg', 25, 1)
	if(detonation_delay)
		addtimer(CALLBACK(src, PROC_REF(trigger_explosion)), detonation_delay)
		return TRUE
	trigger_explosion()
	return TRUE

///Trigger an actual explosion and delete the mine.
/obj/item/explosive/mine/proc/trigger_explosion()
	if(triggered)
		return
	triggered = TRUE
	if(light_explosion_range || heavy_explosion_range || uber_explosion_range)
		//Directional-based explosives (like claymores) will spawn the explosion in front instead of on themselves
		explosion((buffer_range && !pressure_activated) ? get_step(src, dir) : loc, uber_explosion_range, heavy_explosion_range, light_explosion_range, \
		blinding_range, incendiary_range, launch_distance, color = explosion_color)
	if(shrapnel_range && shrapnel_type)
		var/obj/projectile/projectile_to_fire = new /obj/projectile(get_turf(src))
		projectile_to_fire.generate_bullet(shrapnel_type)
		projectile_to_fire.fire_at(get_step(src, dir), src, src, shrapnel_range, projectile_to_fire.ammo.shell_speed)
	QDEL_LIST(triggers)
	qdel(src)

///If this mine is volatile, explode! Easier to copy paste this into several places
/obj/item/explosive/mine/proc/volatility_check()
	if(volatile)
		//Let's make sure everyone knows it was not activated by normal circumstances
		visible_message(span_danger("[icon2html(src, viewers(src))] \The [src]'s detonation mechanism is accidentally triggered!"))
		trigger_explosion()

//On explosion, mines trigger their own explosion, assuming they were not deleted straight away (larger explosions or probability)
/obj/item/explosive/mine/ex_act()
	. = ..()
	if(!QDELETED(src))
		volatility_check()

//Any EMP effects will render volatiles mines disabled
/obj/item/explosive/mine/emp_act()
	. = ..()
	if(volatile)
		disarm()

//Fire will cause mines to trigger their explosion
/obj/item/explosive/mine/flamer_fire_act(burnlevel)
	. = ..()
	volatility_check()

/obj/item/explosive/mine/fire_act()
	. = ..()
	volatility_check()

/obj/item/explosive/mine/take_damage(damage_amount, damage_type, damage_flag, effects, attack_dir, armour_penetration)
	. = ..()
	volatility_check()

///This is a mine_tripwire that is basically used to extend the mine and capture bump movement further infront of the mine
/obj/effect/mine_tripwire
	name = "claymore tripwire"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon_state = "blocker"
	//invisibility = INVISIBILITY_MAXIMUM
	var/obj/item/explosive/mine/linked_mine

/obj/effect/mine_tripwire/Initialize()
	. = ..()
	var/static/list/connections = list(COMSIG_ATOM_ENTERED = PROC_REF(on_cross))
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
	range = 6
	angle = 60
	shrapnel_type = /datum/ammo/bullet/claymore_shrapnel/pmc
	shrapnel_range = 8
