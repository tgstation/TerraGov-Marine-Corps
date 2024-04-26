/*
Mines

Mines use invisible /obj/effect/mine_trigger objects that tell the mine to explode when something crosses over it

Shrapnel-based explosives (like claymores) will not actually hit anything standing on the same tile due to fire_at() not
taking that kind of thing into account, setting buffer_range = 0 or making them pressure activated is useless
*/

/* Flags for mine_features */
///For pressure mines that trigger when something crosses them
#define MINE_PRESSURE_SENSITIVE (1<<0)
///For pressure mines that only trigger when heavy objects cross them
#define MINE_PRESSURE_WEIGHTED (1<<1)
///For mines that only trigger when conscious mobs cross them
#define MINE_DISCERN_LIVING (1<<2)
///For mines that can be disabled by EMPs
#define MINE_ELECTRONIC (1<<3)
///For mines that limit their effects to a specific direction (like claymores)
#define MINE_DIRECTIONAL (1<<4)
///For mines that can have their range changed
#define MINE_CUSTOM_RANGE (1<<5)
///For mines that can be disarmed or interacted with in any way once triggered
#define MINE_INTERRUPTIBLE (1<<6)
///For mines that do not delete themselves upon detonation
#define MINE_REUSABLE (1<<7)
///Record war crimes when deploying this mine
#define MINE_ILLEGAL (1<<8)

///Common flags for most mines; reduce amount of flags needed to copy paste
#define MINE_STANDARD_FLAGS MINE_DISCERN_LIVING|MINE_ELECTRONIC|MINE_INTERRUPTIBLE

/* Flags for volatility; also go under mine_features */
///For mines that detonate when damaged physically (hit by a bullet, slashed, etc.)
#define MINE_VOLATILE_DAMAGE (1<<9)
///For mines that detonate when damaged by fire
#define MINE_VOLATILE_FIRE (1<<10)
///For mines that detonate when damaged by explosions
#define MINE_VOLATILE_EXPLOSION (1<<11)
///For mines that detonate when hit by EMPs
#define MINE_VOLATILE_EMP (1<<12)

//Flags for craftable IED
#define IED_SECURED (1<<0)
#define IED_WIRED (1<<1)
#define IED_CONNECTED (1<<2)
#define IED_FINISHED IED_SECURED|IED_WIRED|IED_CONNECTED

/obj/item/mine
	name = "not a real mine"
	desc = "Dummy object. Otherwise changing stats on the parent item would cause chaos/tedium every time."
	icon = 'icons/obj/items/mine.dmi'
	icon_state = "proximity"
	resistance_flags = XENO_DAMAGEABLE
	atom_flags = CONDUCT
	w_class = WEIGHT_CLASS_SMALL
	max_integrity = 100
	force = 5
	throwforce = 5
	throw_range = 6
	throw_speed = 3
	atom_flags = CONDUCT
	/// IFF signal - used to determine friendly units
	var/iff_signal = NONE
	///If the mine has been triggered
	var/triggered = FALSE
	///State of the mine. Will the mine explode or not
	var/armed = FALSE
	///List of references to each dummy object that serve as triggers for this mine
	var/list/triggers = list()
	///Stored reference to the duration timer that leads to self-deletion; can be modified or stopped once started
	var/deletion_timer

	/* -- Gameplay data -- */
	///Message sent to nearby players when this mine is triggered; "The [name] [message]"
	var/detonation_message = "screams for the sweet release of death."
	///Sound played when the mine is triggered
	var/detonation_sound = 'sound/weapons/mine_tripped.ogg'
	///How many tiles around/in front of itself will trigger detonation
	var/range = 0
	///How many tiles around/in front of itself before it starts detecting; at 0, you can trigger the tile the mine is on
	var/buffer_range = 0
	///Determines how wide the cone for detecting victims is
	var/angle = 0
	///How long this mine is active once detonated; for things like slow or radiation fields; set to -1 if it stays active until prompted
	var/duration = 0
	///Time before the mine explodes
	var/detonation_delay = 0
	///Time it takes to disable this mine
	var/disarm_delay = 0
	///Time it takes to turn off and pack up a mine
	var/undeploy_delay = 0
	///Time it takes to set up a mine
	var/deploy_delay = 0
	///Flags for what this mine can do; see top of mine.dm for defines
	var/mine_features = MINE_STANDARD_FLAGS

	/* -- Explosion data -- */
	///How large the devestation impact is
	var/uber_explosion_range = 0
	///How large the heavy impact is
	var/heavy_explosion_range = 0
	///How large the light impact is
	var/light_explosion_range = 0
	///How large the weak impact is
	var/weak_explosion_range = 0
	///How far away a player can be to be blinded by the explosion
	var/blinding_range = 0
	///How far away objects are thrown
	var/launch_distance = 0
	///Color of the explosion
	var/explosion_color = LIGHT_COLOR_LAVA	//Default used by explosions
	///Radius of how far flames are spawned
	var/fire_range = 0
	///How long the spawned fire will stay alight on a tile
	var/fire_intensity = 0
	///How long a mob keeps burning
	var/fire_duration = 0
	///How much damage is inflicted when a mob enters the fire tile
	var/fire_damage = 0
	///How intense the fire burns on a mob over time; higher number means higher damage initially
	var/fire_stacks = 0
	///Color of the flames; either red, blue, or green
	var/fire_color = "red"
	///The ammo datum used for this mine's shrapnel
	var/shrapnel_type = null
	///How far the shrapnel can go before it is deleted
	var/shrapnel_range = 0
	///Type of smoke to spawn
	var/datum/effect_system/smoke_spread/gas_type = null
	///Radius of the mine's smoke cloud
	var/gas_range = 0
	///How long the gas cloud remains; do not use SECONDS as it is used by the smoke object's process(), which is called roughly every second
	var/gas_duration = 0

/obj/item/mine/Initialize(mapload)
	. = ..()
	if(!buffer_range || CHECK_BITFIELD(mine_features, MINE_PRESSURE_SENSITIVE|MINE_PRESSURE_WEIGHTED))
		var/static/list/connections = list(COMSIG_ATOM_ENTERED = PROC_REF(on_cross))
		AddElement(/datum/element/connect_loc, connections)

/obj/item/mine/Destroy()
	delete_detection_zone()
	return ..()

/obj/item/mine/examine(mob/user)
	. = ..()
	. += range ? "Has a detection range of [span_bold("[range]")] tile[range > 1 ? "s" : ""]." : "Only detonated if stepped on."
	if(buffer_range)
		. += "Cannot be triggered within [span_bold("[buffer_range]")] tile[buffer_range > 1 ? "s" : ""] of itself."
	if(CHECK_BITFIELD(mine_features, MINE_CUSTOM_RANGE))
		. += "[span_bold("Alt Click")] to change the detection range."
	if(!CHECK_BITFIELD(mine_features, MINE_DISCERN_LIVING))
		. += span_warning("This mine can be triggered by objects!")
	if(armed)
		. += span_warning("It is active!")

///Update the icon, adding "_armed" or "_deployed" (or nothing if not planted)
/obj/item/mine/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][anchored ? (armed ? "_armed" : "_deployed") : ""]"

/obj/item/mine/AltClick(mob/user)
	if(armed)
		balloon_alert(user, "Undeploy [src] to adjust range!")
		return FALSE
	if(!can_interact(user))
		return FALSE
	var/new_range = tgui_input_number(user, "Input the detection range of [src] in tiles, up to 7", "Set Range", range, 7, 1)
	//Check if the user is still near this mine or if a value was provided; also make sure the mine isn't already planted
	if(!new_range || armed || !can_interact(user))
		return FALSE
	range = new_range

/obj/item/mine/attack_self(mob/living/user)
	. = ..()
	setup(user)

///Runs the checks for attempting to deploy a mine
/obj/item/mine/proc/setup(mob/living/user)
	if(!user.loc || user.loc.density)
		balloon_alert(user, "No space!")
		return FALSE
	if(locate(/obj/item/mine) in get_turf(src))
		balloon_alert(user, "Already a mine here!")
		return FALSE
	if(armed || triggered)	//Just in case
		return FALSE
	if(!do_after(user, deploy_delay, NONE, src, BUSY_ICON_BUILD))
		return FALSE

	//Probably important to keep this logged, just in case
	visible_message(span_notice("[user] deploys a [src]."))
	var/obj/item/card/id/id = user.get_idcard()
	deploy(user, id?.iff_signal)
	user.record_traps_created()
	if(CHECK_BITFIELD(mine_features, MINE_ILLEGAL) && user)
		user.record_war_crime()
	return TRUE

///Process for arming the mine; anchoring, setting who it belongs to, generating the trigger zones
/obj/item/mine/proc/deploy(mob/living/user, faction)
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

	generate_detection_zone()
	update_icon()

/obj/item/mine/attack_hand(mob/living/user)
	. = ..()
	if(anchored || armed)
		undeploy(user)
	if(.)
		return

///Required checks before a mine is turned off and packed up
/obj/item/mine/proc/undeploy(mob/living/user)
	if(triggered && !CHECK_BITFIELD(mine_features, MINE_INTERRUPTIBLE))
		balloon_alert(user, "Too late, run!")
		return FALSE

	if(iff_signal)	//Has to actually be registered with a faction, otherwise it's hostile to everyone!
		var/obj/item/card/id/id_card = user.get_idcard()
		if(id_card && id_card.iff_signal == iff_signal)
			if(undeploy_delay && !do_after(user, undeploy_delay, TRUE, src))
				return FALSE
			//The brain damaged and blind are likely to fumble it
			if((user.brainloss > BRAIN_DAMAGE_MILD && prob(user.brainloss)) || (user.eye_blind && prob(50)))
				visible_message(span_alert("[user] accidentally set off [src]!"), \
				span_alert("You pressed the wrong button, dumb ass."))
				trigger_explosion(user)
				return
			disarm()
			return

	balloon_alert(user, "Must be defused!")

/obj/item/mine/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(ismultitool(I))
		bomb_defusal(user)	//Sweaty palms time

///The process for trying to disarm a mine
/obj/item/mine/proc/bomb_defusal(mob/user)
	if(triggered && !CHECK_BITFIELD(mine_features, MINE_INTERRUPTIBLE))
		balloon_alert(user, "Can't disarm this, run!")
		return FALSE

	//Mine defusal time is de/increased by 1 second per skill point
	var/skill_issue = max(disarm_delay - user.skills.getRating(SKILL_ENGINEER) + SKILL_ENGINEER_ENGI, 0)

	//Chance for failure below; only /living/ types can be checked for brain damage
	var/mob/living/living = isliving(user) ? user : null
	var/extra_failure_risk = living ? living.brainloss : 0

	if(skill_issue)	//If you got the time down to 0, you can just skip this whole disarming process you smart egg!
		if(user.skills.getRating(SKILL_ENGINEER) >= SKILL_ENGINEER_ENGI)
			user.visible_message(span_notice("[user] starts disarming [src]."), \
			span_notice("You start disarming [src]."))
		else if(user.skills.getRating(SKILL_ENGINEER) == SKILL_ENGINEER_DEFAULT)
			user.visible_message(span_warning("[user] is about to do something stupid!"), \
			span_warning("You are about to get yourself killed."))
			extra_failure_risk += 50	//Just add a flat 50% chance of failure if you're completely unskilled
		else
			user.visible_message(span_notice("[user] visibly struggles to disarm [src]."), \
			span_notice("You try your best to disarm [src]."))

		if(!do_after(user, skill_issue, TRUE, src, skill_issue > disarm_delay ? BUSY_ICON_UNSKILLED : BUSY_ICON_BUILD))
			user.visible_message(span_notice("[user] stops disarming [src]."), \
			span_notice("You stop disarming [src]."))
			return FALSE

	if(prob(extra_failure_risk))
		user.visible_message(span_alert("[user] accidentally set off [src]!"), \
		span_alert("You failed to disarm [src]!"))
		trigger_explosion(user)
		return

	//Let everyone know a mine was disarmed, but no need to log it to chat
	balloon_alert_to_viewers("[src] disarmed")
	disarm(user)

///Turns off the mine
/obj/item/mine/proc/disarm()
	if(!CHECK_BITFIELD(mine_features, MINE_REUSABLE) && deletion_timer)	//Non-reuseable mine already doing it's thing? Deletion upon disarming then
		qdel(src)
		return

	armed = FALSE
	anchored = FALSE
	triggered = FALSE	//Good job, you managed to disarm it before it blew
	update_icon()
	delete_detection_zone()
	if(deletion_timer)
		deltimer(deletion_timer)

///Generate the trigger zones for the mine
/obj/item/mine/proc/generate_detection_zone()
	if(!range)
		return

	if(length(triggers))
		delete_detection_zone()

	var/list/trigger_turfs = generate_true_cone(get_turf(src), range, buffer_range, angle, dir2angle(dir), bypass_xeno = TRUE, air_pass = TRUE)
	for(var/turf/T in trigger_turfs)
		var/obj/effect/mine_trigger/tripwire = new /obj/effect/mine_trigger(T)
		tripwire.linked_mine = src
		triggers += tripwire

///Delete the trigger zones for the mine
/obj/item/mine/proc/delete_detection_zone()
	if(!length(triggers))
		return

	QDEL_LIST(triggers)

///Checks if a mob entered the tile this mine is on, and if it can cause it to trigger
/obj/item/mine/proc/on_cross(datum/source, atom/movable/AM, oldloc, oldlocs)
	if(AM.status_flags & INCORPOREAL)	//Don't let ghosts trigger them
		return FALSE

	var/mob/living/crosser = isliving(AM) ? AM : null
	if(CHECK_BITFIELD(mine_features, MINE_DISCERN_LIVING))	//If only conscious mobs can trigger this mine, run the appropriate checks
		if(!crosser)
			return FALSE
		if(crosser.stat)
			return FALSE

	if(CHECK_BITFIELD(mine_features, MINE_PRESSURE_SENSITIVE|MINE_PRESSURE_WEIGHTED))
		//Flying mobs can't trip this mine
		if(CHECK_MULTIPLE_BITFIELDS(AM.pass_flags, HOVERING))
			return FALSE

		if(CHECK_BITFIELD(mine_features, MINE_PRESSURE_WEIGHTED))
			//Maybe do some exercise and you won't trip mines so easily
			if(crosser)
				var/mob/living/carbon/possible_fatty = iscarbon(crosser) ? crosser : null
				if(crosser.mob_size < MOB_SIZE_BIG || possible_fatty?.nutrition >= NUTRITION_OVERFED)
					return FALSE

			//Only heavy objects can trip this mine (or a structure)
			else if(isitem(AM))
				var/obj/item/object = AM
				if(object.w_class < WEIGHT_CLASS_HUGE)
					return FALSE

	//All crossing conditions met, run the triggering-related checks
	trip_mine(AM)

///Process for triggering detonation
/obj/item/mine/proc/trip_mine(atom/movable/victim)
	if(!armed || triggered)
		return FALSE

	if(ishuman(victim))
		var/mob/living/carbon/human/human_victim = victim
		var/obj/item/card/id/id_card = human_victim.get_idcard()
		if(id_card?.iff_signal == iff_signal)
			return FALSE

	else if(isvehicle(victim))
		var/obj/vehicle/vehicle_victim = victim
		if(vehicle_victim.iff_signal == iff_signal)
			return FALSE

	trigger_explosion(victim)

///Trigger the mine; needs to be a separate proc so that we can use a timer
/obj/item/mine/proc/trigger_explosion(atom/movable/victim)
	if(triggered)
		return FALSE

	triggered = TRUE
	if(detonation_message)
		visible_message(span_danger("[icon2html(src, viewers(src))] \The [src] [detonation_message]"))
	playsound(loc, detonation_sound, 50, sound_range = 7)
	if(detonation_delay)
		addtimer(CALLBACK(src, PROC_REF(explode)), detonation_delay)
		return
	explode(victim)

///Proc that actually causes the explosion; will return TRUE for the sake of reusable mines or mines with durations (at the moment, the radiation mine)
/obj/item/mine/proc/explode(atom/movable/victim)
	if(!triggered)
		return FALSE

	if(light_explosion_range || heavy_explosion_range || uber_explosion_range || weak_explosion_range)
		//Directional-based explosives (like claymores) will spawn the explosion in front instead of on themselves
		explosion((CHECK_BITFIELD(mine_features, MINE_DIRECTIONAL)) ? get_step(src, dir) : loc, \
		uber_explosion_range, heavy_explosion_range, light_explosion_range, weak_explosion_range, \
		blinding_range, throw_range = launch_distance, color = explosion_color)

	if(fire_range)
		flame_radius(fire_range, (CHECK_BITFIELD(mine_features, MINE_DIRECTIONAL)) ? get_step(src, dir) : loc, \
		fire_intensity, fire_duration, fire_damage, fire_stacks, colour = fire_color)

	if(shrapnel_range && shrapnel_type)	//Spawn projectiles, their associated data, and then launch it the direction it is facing
		var/obj/projectile/projectile_to_fire = new /obj/projectile(get_turf(src))
		projectile_to_fire.generate_bullet(shrapnel_type)
		projectile_to_fire.fire_at(get_step(src, dir), null, src, shrapnel_range, projectile_to_fire.ammo.shell_speed)

	if(gas_type && gas_duration)
		var/datum/effect_system/smoke_spread/smoke = new gas_type()
		playsound(src, 'sound/effects/smoke.ogg', 25, 1, gas_range + 2)
		smoke.set_up(gas_range, get_turf(src), gas_duration)
		smoke.start()

	//If this is a mine that causes effects over time, call extra_effects() and set timers before deletion/disarming
	if(duration || duration < 0)
		extra_effects(victim)
		if(duration > 0)
			//Mines that are reusable will go back to sleep after the duration
			if(CHECK_BITFIELD(mine_features, MINE_REUSABLE))
				deletion_timer = addtimer(CALLBACK(src, PROC_REF(disarm)), duration, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
				return TRUE
			//Mines that are not reusable will delete themselves after the duration
			deletion_timer = addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), duration, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
		//Negative duration means the mine will stay active indefinitely, so just do nothing but return TRUE
		return TRUE

	//Reusable mines do not delete themselves upon detonation, just go back to sleep
	if(CHECK_BITFIELD(mine_features, MINE_REUSABLE))
		disarm()
		return TRUE

	delete_detection_zone()
	qdel(src)

///Shove any code for special effects caused by this mine here
/obj/item/mine/proc/extra_effects(atom/movable/victim)
	return

///If this mine is volatile, explode! See top of mine.dm for volatility flags
/obj/item/mine/proc/volatility_check(flag)
	if(CHECK_BITFIELD(mine_features, flag))
		//Let's make sure everyone knows it was not activated by normal circumstances
		visible_message(span_danger("[icon2html(src, viewers(src))] \The [src]'s detonation mechanism is accidentally triggered!"))
		trigger_explosion()

//On explosion, mines trigger their own explosion, assuming they were not deleted straight away (larger explosions or probability)
/obj/item/mine/ex_act(severity)
	. = ..()
	if(QDELETED(src) || !armed)
		return

	//Only heavy and light explosions can cause a detonation, and depending on RNG
	if(severity == EXPLODE_DEVASTATE || (severity == EXPLODE_HEAVY && prob(25)) || (severity == EXPLODE_LIGHT && prob(50)) || severity == EXPLODE_WEAK)
		return

	volatility_check(MINE_VOLATILE_EXPLOSION)

//Fire will cause mines to trigger their explosion
/obj/item/mine/fire_act()
	volatility_check(MINE_VOLATILE_FIRE)

/obj/item/mine/take_damage(damage_amount, damage_type, damage_flag, effects, attack_dir, armour_penetration, mob/living/blame_mob)
	if(damage_amount)	//Only do this if the mine actually took damage; run it before damage is dealt in case it destroys the mine
		volatility_check(MINE_VOLATILE_DAMAGE)
	return ..()

//Any EMP effects will render electronic mines disabled, or trigger them if they are volatile
/obj/item/mine/emp_act(severity)
	if(CHECK_BITFIELD(mine_features, MINE_VOLATILE_EMP))
		trigger_explosion()
		return
	if(CHECK_BITFIELD(mine_features, MINE_ELECTRONIC))
		disarm()

///Act as dummy objects that detects if something touched it, causing the linked mine to detonate
/obj/effect/mine_trigger
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon_state = "blocker"	//For debugging; comment out the invisibility var below to see mine sensor zones
	invisibility = INVISIBILITY_MAXIMUM
	///The explosive this dummy object is connected to
	var/obj/item/mine/linked_mine

/obj/effect/mine_trigger/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(COMSIG_ATOM_ENTERED = PROC_REF(on_cross))
	AddElement(/datum/element/connect_loc, connections)
	RegisterSignal(loc, COMSIG_TURF_CHANGE, PROC_REF(on_turf_change))

/obj/effect/mine_trigger/Destroy()
	linked_mine = null
	return ..()

///If the turf this trigger is on changes, update the detection zones to prevent orphaned triggers
/obj/effect/mine_trigger/proc/on_turf_change()
	SIGNAL_HANDLER
	linked_mine.generate_detection_zone()

///When crossed, triggers the linked mine if checks pass
/obj/effect/mine_trigger/proc/on_cross(datum/source, atom/movable/AM, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(!linked_mine)	//If this doesn't belong to a mine, why does this object exist?!
		qdel(src)
		return
	if(linked_mine.triggered) //Mine is already set to go off
		return FALSE
	if(CHECK_BITFIELD(linked_mine.mine_features, MINE_DISCERN_LIVING))	//If only mobs can trigger the mine this belongs to, check if they are conscious
		if(!isliving(AM))
			return FALSE
		var/mob/living/unlucky_person = AM
		if(unlucky_person.stat)
			return FALSE
	linked_mine.trip_mine(AM)
