///Can attach a lock
#define DOOR_LOCKABLE 1<<0
///Can be opened with violence
#define DOOR_FORCEABLE 1<<1
///If the door is open
#define DOOR_OPEN 1<<2
///Is currently opening
#define DOOR_OPENING 1<<3
///Is currently closing
#define DOOR_CLOSING 1<<4

///Set of flags your average door will most likely have
#define STANDARD_DOOR_FLAGS DOOR_LOCKABLE|DOOR_FORCEABLE

/obj/structure/door
	name = "door"
	desc = "It opens and closes - nothing out of the ordinary."
	icon = 'icons/obj/doors/mineral_doors.dmi'
	icon_state = ""
	opacity = TRUE
	density = TRUE
	allow_pass_flags = PASS_AIR
	resistance_flags = XENO_DAMAGEABLE
	layer = DOOR_CLOSED_LAYER
	max_integrity = 100
	explosion_block = 0.5
	///The name of the door, assigned at initialization; use this instead of initial(name)
	var/base_name
	///Door specific flags
	var/door_flags = STANDARD_DOOR_FLAGS
	///Reference to the lock installed on this door
	var/obj/item/lock/lock
	///What material the door is made of; used for repairs and deconstruction
	var/obj/item/stack/material_type = /obj/item/stack/sheet/wood
	///How many units of material this door is made of
	var/material_amount = 4
	///Sound when opened
	var/open_sound = 'sound/machines/door_open.ogg'
	///Sound when closed
	var/close_sound = 'sound/machines/door_close.ogg'
	///Sound when locked and trying to open
	var/locked_sound = 'sound/machines/door_locked.ogg'
	///Sound when trying to use violence against a door
	var/slam_sound = 'sound/effects/slam3.ogg'
	///Sound when knocking on a door
	var/knocking_sound = 'sound/effects/glassknock.ogg'
	///How long it takes to open the door; recommended to not make this the entire length of the animation for "feel" reasons
	var/opening_time = 0.5 SECONDS
	///How long it takes to close the door; will be the same as opening_time if not set
	var/closing_time
	///Reference to the timer that closes or opens a door
	var/delay_timer
	///Steps in sequential order to de/construct this door; make this list null if you do not want this door to be built or taken apart
	var/list/construction_steps = list(TOOL_SCREWDRIVER, TOOL_CROWBAR)
	///What step in the de/construction process this door is on; 1 means it is fully built
	var/construction_steps_index = 1
	///How long each step of de/construction takes
	var/tool_action_time = 1 SECONDS

/obj/structure/door/Initialize(mapload, built)
	. = ..()
	initialize_lock()

	if(!closing_time)
		closing_time = opening_time

	base_name = name
	if(built)
		name = "[name] frame"
		anchored = FALSE
		open(TRUE, FALSE, TRUE)
		construction_steps_index = length(construction_steps)
		if(!construction_steps_index)
			stack_trace("A player built a door that cannot be de/constructed. This door should be deleted immediately to prevent runtimes.")

	var/static/list/connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_try_exit),
		COMSIG_ATOM_EXITED = PROC_REF(on_exited))
	AddElement(/datum/element/connect_loc, connections)

///Separate proc for creating a lock if a door is meant to spawn with one
/obj/structure/door/proc/initialize_lock()
	if(!lock)
		return

	if(!CHECK_BITFIELD(door_flags, DOOR_LOCKABLE))
		QDEL_NULL(lock)
		stack_trace("An attempt was made to attach a lock to a door that cannot have one.")
		return

	lock = new lock(src)

/obj/structure/door/examine(mob/user)
	. = ..()
	if(lock)
		. += span_notice("It is [span_bold("[lock.locked ? "locked" : "unlocked"]")]. The lock has [lock.personal_lock_id ? span_bold(lock.personal_lock_id) : "nothing"] engraved on it.")

	switch(obj_integrity/max_integrity)
		if(0 to 0.15)
			. += span_danger("It's about to fall apart!")
		if(0.15 to 0.5)
			. += span_warning("It's severely damaged.")
		if(0.5 to 0.99)
			. += span_notice("It could use repairs.")

	if(construction_steps_index != 1)
		. += span_notice("To build, [span_bold(tool_define_to_tool_action(construction_steps[construction_steps_index - 1]))] it.")
	. += span_notice("To deconstruct, [span_bold(tool_define_to_tool_action(construction_steps[construction_steps_index]))] it.")

//If deconstructed, lock is simply dropped; if destroyed, lock is destroyed with it!
/obj/structure/door/deconstruct(disassembled)
	if(disassembled)
		detach_lock()

	drop_materials(disassembled)
	return ..()

/obj/structure/door/Destroy()
	if(lock)
		QDEL_NULL(lock)
	deltimer(delay_timer)
	return ..()

///Handle spawning materials when deconstructed/destroyed
/obj/structure/door/proc/drop_materials(disassembled)
	if(!material_type || !material_amount)
		return

	if(!disassembled)
		material_amount = FLOOR(material_amount / 2, 1)

	//If someone somehow makes this number negative, I'm going to be very upset
	if(!material_amount)
		return

	new material_type(get_turf(src), material_amount)

//For if you have something like a see-through wire fence door (I took the code from barricades)
/obj/structure/door/update_icon_state()
	if(!CHECK_BITFIELD(atom_flags, ON_BORDER))
		return

	switch(dir)
		//Display door as usual
		if(SOUTH)
			layer = initial(layer)
		//Display door behind any objects or mobs
		if(NORTH)
			layer = BELOW_OBJ_LAYER
		//Display door behind any similar on_border objects that are facing south
		else
			layer = initial(layer) - 0.01

/obj/structure/door/update_overlays()
	. = ..()
	if(lock && !CHECK_BITFIELD(door_flags, DOOR_OPENING) && !CHECK_BITFIELD(door_flags, DOOR_CLOSING))
		. += initial(lock.icon_state)	//Be sure to make an overlay for each lock in whatever .dmi this door is from

/obj/structure/door/attack_hand(mob/living/user)
	. = ..()
	//If for whatever reason a user wants to knock on an unlocked door, just use disarm intent
	if(user.a_intent == INTENT_DISARM)
		playsound(src, knocking_sound, 50, FALSE, 5, 1)
		return

	if(CHECK_BITFIELD(door_flags, DOOR_OPEN))
		attempt_to_close(user)
	else
		attempt_to_open(user, direction_from_opener = angle2dir(Get_Angle(src, user)))

/obj/structure/door/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount, damage_type, armor_type, effects, armor_penetration, isrightclick)
	switch(xeno_attacker.a_intent)
		if(INTENT_DISARM)	//Yes, benos can knock :))
			playsound(src, knocking_sound, 50, FALSE, 5, 1)
			return

		if(INTENT_HELP)
			if(CHECK_BITFIELD(door_flags, DOOR_OPEN))
				attempt_to_close(xeno_attacker)
			else
				attempt_to_open(xeno_attacker, direction_from_opener = angle2dir(Get_Angle(src, xeno_attacker)))
			return

	return ..()

/obj/structure/door/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(isdoorkey(attacking_item))
		toggle_lock(user, attacking_item)
		return

	if(islock(attacking_item))
		attach_lock(user, attacking_item)
		return

	if(isitemstack(attacking_item))
		handle_repairs(user, attacking_item)
		return

//If you too are confused by these names, this one is only called when hit by an object from a user not on help intent
/obj/structure/door/attacked_by(obj/item/attacking_item, mob/living/user, def_zone)
	. = ..()
	if(attacking_item.damtype != BURN)
		return

	//I dislike this get_burn_damage_multiplier and would improve it but I am tired at this point
	take_damage(max(0, attacking_item.force * get_burn_damage_multiplier(attacking_item, user)), attacking_item.damtype, MELEE)

///Takes extra damage if our attacking item does burn damage
/obj/structure/door/proc/get_burn_damage_multiplier(obj/item/attacking_item, mob/living/user, bonus_damage = 0)
	if(!isplasmacutter(attacking_item) || material_type != /obj/item/stack/sheet/wood)
		return bonus_damage

	var/obj/item/tool/pickaxe/plasmacutter/attacking_pc = attacking_item
	if(attacking_pc.start_cut(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD, no_string = TRUE))
		bonus_damage += PLASMACUTTER_RESIN_MULTIPLIER * 0.5
		attacking_pc.cut_apart(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD) //Minimal energy cost.

	return bonus_damage

/**
 * Repairs the door with the material provided, assuming it matches the material type of the door
 * * user - The mob repairing the door
 * * material - The material used to repair the door
 * * The repair amount is proportional to the value of material_amount and scales with the max_integrity
 * * For example: a door has 4 material_amount, so every 1 material used will repair 25% of the door's integrity; this will repair 25 points if the max_integrity is 100
 * * Like barricade repairs, this process is repeated automatically until the door is fully repaired or the material runs out
 */
/obj/structure/door/proc/handle_repairs(mob/user, obj/item/stack/material)
	if(!user || !material_type || !material_amount)
		return

	if(obj_integrity >= max_integrity)
		balloon_alert(user, "No repairs needed")
		return

	if(material.get_amount() < 1)
		balloon_alert(user, "Insufficient material")
		return

	if(!do_after(user, tool_action_time, NONE, src, BUSY_ICON_BUILD))
		return

	if(!material.use(1))
		balloon_alert(user, "Insufficient material")
		return

	repair_damage(max_integrity * (1 / material_amount), user)
	if(obj_integrity >= max_integrity)
		//Make it visible so everyone else can see you repaired it to full condition
		balloon_alert_to_viewers("Repaired!")
		return

	handle_repairs(user, material)

/obj/structure/door/screwdriver_act(mob/living/user, obj/item/I)
	return handle_tools(user, I)

/obj/structure/door/crowbar_act(mob/living/user, obj/item/I)
	return handle_tools(user, I)

/obj/structure/door/wrench_act(mob/living/user, obj/item/I)
	return handle_tools(user, I)

/obj/structure/door/wirecutter_act(mob/living/user, obj/item/I)
	return handle_tools(user, I)

/obj/structure/door/welder_act(mob/living/user, obj/item/I)
	if(!length(construction_steps))
		return FALSE

	if(!CHECK_BITFIELD(door_flags, DOOR_FORCEABLE))
		to_chat(user, span_warning("[src] is too sturdy to disassemble!"))
		return FALSE

	if(lock?.locked && CHECK_BITFIELD(door_flags, DOOR_OPEN))
		balloon_alert(user, "Unlock it first!")
		return FALSE

	if(I.tool_behaviour != construction_steps[construction_steps_index])
		if(construction_steps_index == 1 || (I.tool_behaviour != construction_steps[construction_steps_index - 1]))
			return FALSE

		var/obj/item/tool/weldingtool/welder = I
		if(!welder.check_fuel() || !welder.isOn())
			return FALSE

		if(tool_action_time && !do_after(user, tool_action_time, NONE, src, BUSY_ICON_BUILD))
			return FALSE

		if(!welder.remove_fuel(M = user))
			return FALSE

		do_deconstruction()
		return TRUE

	//Man, these welder procs should really be consolidated
	var/obj/item/tool/weldingtool/welder = I
	if(!welder.check_fuel() || !welder.isOn())	//Make sure the welder is on and has fuel
		return FALSE

	if(tool_action_time && !do_after(user, tool_action_time, NONE, src, BUSY_ICON_BUILD))
		return FALSE

	if(!welder.remove_fuel(M = user))	//Make sure the welder still has fuel after it's done
		return FALSE

	do_deconstruction()
	return TRUE

/obj/structure/door/weld_cut_act(mob/living/user, obj/item/I)
	if(!length(construction_steps))
		return FALSE

	if(!CHECK_BITFIELD(door_flags, DOOR_FORCEABLE))
		to_chat(user, span_warning("[src] is too sturdy to disassemble!"))
		return FALSE

	if(lock?.locked && CHECK_BITFIELD(door_flags, DOOR_OPEN))
		balloon_alert(user, "Unlock it first!")
		return FALSE

	if(I.tool_behaviour != construction_steps[construction_steps_index])
		if(construction_steps_index == 1 || (I.tool_behaviour != construction_steps[construction_steps_index - 1]))
			return FALSE

		var/obj/item/tool/pickaxe/plasmacutter/cutter = I
		if(!(cutter.cell.charge >= cutter.cell.charge_amount) || !cutter.powered)
			cutter.fizzle_message(user)
			return FALSE

		playsound(src, cutter.cutting_sound, 25, 1)
		cutter.eyecheck(user)
		if(tool_action_time && !do_after(user, tool_action_time, NONE, src, BUSY_ICON_BUILD))
			return FALSE

		if(!(cutter.cell.charge >= cutter.cell.charge_amount) || !cutter.powered)
			cutter.fizzle_message(user)
			return FALSE

		cutter.use_charge(user)
		do_construction()
		return TRUE

	//This is even worse than the welder procs... at least it had procs
	var/obj/item/tool/pickaxe/plasmacutter/cutter = I
	if(!(cutter.cell.charge >= cutter.cell.charge_amount) || !cutter.powered)
		cutter.fizzle_message(user)
		return FALSE

	playsound(src, cutter.cutting_sound, 25, 1)
	cutter.eyecheck(user)
	if(tool_action_time && !do_after(user, tool_action_time, NONE, src, BUSY_ICON_BUILD))
		return FALSE

	if(!(cutter.cell.charge >= cutter.cell.charge_amount) || !cutter.powered)
		cutter.fizzle_message(user)
		return FALSE

	cutter.use_charge(user)
	do_deconstruction()
	return TRUE

/obj/structure/door/multitool_act(mob/living/user, obj/item/I)
	return handle_tools(user, I)

/obj/structure/door/analyzer_act(mob/living/user, obj/item/I)
	return handle_tools(user, I)

///Reduce line copy and pasting by having one proc do (most of) them
/obj/structure/door/proc/handle_tools(mob/living/user, obj/item/tool)
	if(!length(construction_steps))	//No message needed because the user would know if they examined the door!
		return FALSE

	if(!CHECK_BITFIELD(door_flags, DOOR_FORCEABLE))
		to_chat(user, span_warning("[src] is too sturdy to disassemble!"))
		return FALSE

	//Don't allow de/construction if the door is closed and locked
	if(lock?.locked && CHECK_BITFIELD(door_flags, DOOR_OPEN))
		balloon_alert(user, "Unlock it first!")
		return FALSE

	//Check if the tool can deconstruct the door
	if(tool.tool_behaviour != construction_steps[construction_steps_index])
		//Check if the tool can construct the door; make sure list[0] isn't done by accident
		if(construction_steps_index == 1 || (tool.tool_behaviour != construction_steps[construction_steps_index - 1]))
			return FALSE

		if(tool_action_time && !do_after(user, tool_action_time, NONE, src, BUSY_ICON_BUILD))
			return FALSE

		//Checks passed, construct one step
		do_construction()
		return TRUE

	if(tool_action_time && !do_after(user, tool_action_time, NONE, src, BUSY_ICON_BUILD))
		return FALSE

	//Checks passed, deconstructed one step
	do_deconstruction()
	return TRUE

///Deconstruct the door
/obj/structure/door/proc/do_deconstruction()
	var/number_of_steps = length(construction_steps)
	construction_steps_index++

	if(construction_steps_index == number_of_steps)
		name = "[base_name] frame"
		anchored = FALSE
		return	//Don't need to keep going if this condition was met

	if(construction_steps_index > number_of_steps)
		deconstruct(TRUE)

///Build the door
/obj/structure/door/proc/do_construction()
	var/number_of_steps = length(construction_steps)
	construction_steps_index--

	if(construction_steps_index != number_of_steps - 1)
		name = base_name
		anchored = initial(anchored)

/obj/structure/door/proc/toggle_lock(mob/user, obj/item/key/door/key)
	if(!lock)
		balloon_alert(user, "No lock installed")
		return

	lock.toggle(user, key)

/obj/structure/door/Cross(atom/movable/AM)
	. = ..()
	if(.)	//Non-full tile doors will not block the crosser, no need to continue below
		if(CHECK_BITFIELD(atom_flags, ON_BORDER) && REVERSE_DIR(dir) == AM.dir)	//Auto close non-full tile doors if the crosser walked through the door
			auto_close(AM)
		return

	//Don't care about the user if they're not a mob type
	attempt_to_open(ismob(AM) ? AM : null, direction_from_opener = angle2dir(Get_Angle(src, AM)), bumped = TRUE)
	var/is_open = CHECK_BITFIELD(door_flags, DOOR_OPEN)

	//For non-full tile doors, this checks if a mob entered a tile with said door and the mob walked directly through the door so that it can be closed behind them
	if(is_open && CHECK_BITFIELD(atom_flags, ON_BORDER) && REVERSE_DIR(dir) == AM.dir)
		auto_close(AM)

	return is_open	//Will be TRUE if the door opened instantly to not delay a mob's movement

///Mob opening the door has no left leg
#define OPENER_MISSING_LEFT_LEG 1<<0
///Mob opening the door has no right leg
#define OPENER_MISSING_RIGHT_LEG 1<<1
///Mob opening the door has no unbroken legs
#define OPENER_ALL_LEGS_CRIPPLED 1<<2

///To prevent doing 5 kicks a second; will return FALSE if the cooldown is still active, TRUE if it is not and will start the cooldown
/obj/structure/door/proc/handle_door_force_open_cooldown(mob/door_opener, cooldown = 1.5 SECONDS)
	if(TIMER_COOLDOWN_CHECK(door_opener, COOLDOWN_FORCE_OPEN_DOOR))
		return FALSE

	TIMER_COOLDOWN_START(door_opener, COOLDOWN_FORCE_OPEN_DOOR, cooldown)
	return TRUE

///To prevent near instantly killing people with door slams; will return FALSE if the cooldown is still active, TRUE if it is not and will start the cooldown
/obj/structure/door/proc/handle_door_force_close_cooldown(mob/door_opener, cooldown = 1 SECONDS)
	if(TIMER_COOLDOWN_CHECK(door_opener, COOLDOWN_FORCE_CLOSE_DOOR))
		return FALSE

	TIMER_COOLDOWN_START(door_opener, COOLDOWN_FORCE_CLOSE_DOOR, cooldown)
	return TRUE

///Separated this proc so that individual doors can override this if they want to change how it is forced open; do not call this, use attempt_to_open()
/obj/structure/door/proc/force_door_open(mob/user, forced, damage = 10, bumped, leg_flags)
	if(!forced && user && !handle_door_force_open_cooldown(user))
		return FALSE

	playsound(src, slam_sound, 70, FALSE, 10, 2)
	if(!CHECK_BITFIELD(door_flags, DOOR_FORCEABLE))
		if(user)
			to_chat(user, span_warning("[src] is too sturdy for brute force!"))
		return FALSE

	//Do all of this if there is a door kicker/tackler
	if(user)
		//If not tackling the door, that means they are attempting to kick it with a broken leg, so let's see if we got any legs to break for being a fool
		if(!bumped && CHECK_BITFIELD(leg_flags, OPENER_ALL_LEGS_CRIPPLED))
			var/mob/living/kicker = user
			kicker.apply_damage(15, BRUTE, CHECK_BITFIELD(leg_flags, OPENER_MISSING_RIGHT_LEG) ? BODY_ZONE_L_LEG : BODY_ZONE_R_LEG, penetration = 100)
			kicker.Knockdown(2 SECONDS)	//Get floored, nerd

		else if(user.throwing && isliving(user))
			var/mob/living/living_battering_ram = user
			//Unlike kicking with a broken leg, getting thrown against a door damages your whole body but can be reduced with armor
			living_battering_ram.take_overall_damage(40, BRUTE, MELEE, penetration = 50)
			living_battering_ram.Knockdown(2 SECONDS)

		//+1 because small mobs will have a value of 0...
		damage *= user.mob_size + 1
		take_damage(damage)
		lock?.take_damage(damage)

		//The ?. is still necessary because the lock could be destroyed before getting to this line
		if(lock?.lock_strength > damage)
			return FALSE

		if(bumped)
			if(user.throwing)
				visible_message(span_danger("[user]'s body flies through [src]!"),
								span_danger("Your body slams through [src]!"),
								span_danger("You hear someone's entire body crash through a door!"))
			else
				visible_message(span_danger("[user] bashes through [src]!"),
								span_danger("You bash through [src]!"),
								span_danger("You hear someone bash a door down!"))
		else
			visible_message(span_danger("[user] kicks open [src]!"),
							span_danger("You kick open [src]!"),
							span_danger("You hear someone kick open a door!"))

	//Abbreviated processes that will run if this door is being opened by something like an explosion
	else
		take_damage(damage)
		lock?.take_damage(damage)
		if(lock?.lock_strength > damage)
			return FALSE

	return TRUE

///Is used whenever the lock is forcibly removed from the door, like from an explosion or being kicked open	//Nevermind, explosion code doesn't pass an origin
/obj/structure/door/proc/eject_lock(direction, range = 5, speed = 2)
	if(!lock)
		return

	lock.forceMove(get_turf(src))
	if(direction)
		lock.throw_at(get_ranged_target_turf(src, direction, range), range, speed, targetted_throw = FALSE)
	lock = null

/**
 * Proper way to open a door; use open() if you just want it magically opened
 * * Returns TRUE for instant opening so that Cross() can return TRUE as well, to allow for non-delayed movement
 * * user - Set this if a mob type is opening this door
 * * instant - TRUE if you want to open it instantly
 * * slammed - TRUE if you want to open it through violent means
 * * forced - TRUE if you want to guarantee opening it
 * * direction_from_opener - use angle2dir(Get_Angle(src, opening_atom)) if it is being forcibly opened or if a mob is opening this
 * * bumped - TRUE if a mob is trying to open this door by walking into it; used for changing the visible message
 * * damage - By default 10, use this to inflict damage on the door when forced open
 */
/obj/structure/door/proc/attempt_to_open(mob/user, instant, slammed, forced, direction_from_opener, bumped, damage = 10)
	if(CHECK_BITFIELD(door_flags, DOOR_OPEN) || (CHECK_BITFIELD(door_flags, DOOR_OPENING) && !(instant || forced)))
		return

	if(construction_steps_index != 1)
		if(!bumped && user)	//It's spammy if you push it by walking into it
			balloon_alert(user, "Needs assembly!")
		return

	//The code below feels like a sin but this seems to be the easiest way to get the conditions of the opener's legs
	var/opener_leg_flags = NONE

	//To avoid using 3 ternaries in 1 line...
	//Will be TRUE if the user is not being thrown across the room and is on harm intent; also why isn't this named THROWN???
	var/is_someone_forcing_door_open = user && user.a_intent == INTENT_HARM ? !user.throwing : FALSE
	//It got even longer trying to accommodate for non-carbons so not going to deal with them
	var/mob/living/carbon/kicker
	if(is_someone_forcing_door_open)
		instant = TRUE	//Kicking or tackling a door will always be instant
		kicker = (!isxeno(user) && iscarbon(user)) ? user : null
	if(kicker)
		var/mob/living/carbon/carbon = user
		var/datum/limb/l_leg/left_leg = carbon.get_limb("l_leg")
		var/datum/limb/r_leg/right_leg = carbon.get_limb("r_leg")

		if(CHECK_BITFIELD(left_leg.limb_status, LIMB_AMPUTATED) || CHECK_BITFIELD(left_leg.limb_status, LIMB_DESTROYED))
			ENABLE_BITFIELD(opener_leg_flags, OPENER_MISSING_LEFT_LEG)
		if(CHECK_BITFIELD(right_leg.limb_status, LIMB_AMPUTATED) || CHECK_BITFIELD(right_leg.limb_status, LIMB_DESTROYED))
			ENABLE_BITFIELD(opener_leg_flags, OPENER_MISSING_RIGHT_LEG)

		//Cripple check only matters if they have any legs to begin with
		if(!CHECK_MULTIPLE_BITFIELDS(opener_leg_flags, OPENER_MISSING_LEFT_LEG|OPENER_MISSING_RIGHT_LEG))
			var/legs_broken = 0
			if(CHECK_BITFIELD(left_leg.limb_status, LIMB_STABILIZED) || CHECK_BITFIELD(left_leg.limb_status, LIMB_SPLINTED) || CHECK_BITFIELD(left_leg.limb_status, LIMB_BROKEN))
				legs_broken++
			if(CHECK_BITFIELD(right_leg.limb_status, LIMB_STABILIZED) || CHECK_BITFIELD(right_leg.limb_status, LIMB_SPLINTED) || CHECK_BITFIELD(right_leg.limb_status, LIMB_BROKEN))
				legs_broken++
			if(legs_broken == 2 || (legs_broken && CHECK_BITFIELD(opener_leg_flags, OPENER_MISSING_LEFT_LEG|OPENER_MISSING_RIGHT_LEG)))
				ENABLE_BITFIELD(opener_leg_flags, OPENER_ALL_LEGS_CRIPPLED)

	//If the opener is missing a leg, they need to walk into it; if missing all legs, they can't forcibly open it
	//This was all one if check using a ternary operator but got wayyyyy too long
	var/can_kicker_kick_this_door
	if(bumped)
		can_kicker_kick_this_door = !CHECK_MULTIPLE_BITFIELDS(opener_leg_flags, OPENER_MISSING_LEFT_LEG|OPENER_MISSING_RIGHT_LEG)
	else
		can_kicker_kick_this_door = !CHECK_BITFIELD(opener_leg_flags, OPENER_MISSING_LEFT_LEG) || !CHECK_BITFIELD(opener_leg_flags, OPENER_MISSING_RIGHT_LEG)

	//When to actually force a door open?
	//If a mob isn't opening it but instant or slammed is TRUE, if a mob is flying into it, or if a mob is kicking/tackling it
	if((!user && (instant || slammed)) || user?.throwing || (kicker ? can_kicker_kick_this_door : is_someone_forcing_door_open))
		if(!force_door_open(user, forced, damage, bumped, opener_leg_flags))
			return

		//Only eject the lock if it was actually keeping it from being opened
		if(lock?.locked)
			eject_lock(REVERSE_DIR(direction_from_opener))

		//Not passing the slammed argument because we already play the slamming sound every attempt
		open(instant)
		return

	if(!forced && lock?.locked)
		playsound(loc, locked_sound, 40, FALSE, 5, 1)
		return

	open(instant, slammed)

/**
 * Used in any instance where you only want to open a door
 * * instant - TRUE if you want to open it instantly
 * * slammed - TRUE if you want to open it through violent means
 * * silent - TRUE if you don't want to play the opening sound (does not affect the slamming sound)
 */
/obj/structure/door/proc/open(instant, slammed, silent)
	deltimer(delay_timer)
	if(slammed)
		playsound(src, slam_sound, 70, FALSE, 10, 2)

	if(!silent && open_sound)
		playsound(src, open_sound, 40, FALSE, 5, 1)

	if(instant || !opening_time)
		ENABLE_BITFIELD(door_flags, DOOR_OPEN)
		DISABLE_BITFIELD(door_flags, DOOR_OPENING)
		DISABLE_BITFIELD(door_flags, DOOR_CLOSING)
		layer = DOOR_OPEN_LAYER
		icon_state = "[initial(icon_state)]_open"
		density = FALSE
		opacity = FALSE
		update_icon()
		return

	ENABLE_BITFIELD(door_flags, DOOR_OPENING)
	update_icon()	//Update icon before flicking so the lock overlay is removed, apparently doesn't work right if after flick
	flick("[initial(icon_state)]_opening", src)
	delay_timer = addtimer(CALLBACK(src, PROC_REF(open), TRUE, slammed, TRUE), opening_time, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)

/**
 * Proper way to close a door; use close() if you just want it magically closed
 * * user - Set this if a mob type is closing this door
 * * instant - TRUE if you want to close it instantly
 * * slammed - TRUE if you want to close it through violent means
 * * forced - TRUE if you want to guarantee closing it
 */
/obj/structure/door/proc/attempt_to_close(mob/user, instant, slammed, forced)
	//To allow slamming a door on someone
	var/slam_the_door = user?.a_intent == INTENT_HARM

	//In addition to making sure we're not closing an already closing door
	//Check to see if a living mob is in the way of the door closing; if there is one, don't close the door (unless it's being forcibly closed)
	//Do half of the checks on this variable so that it doesn't get too long
	var/is_there_mob_on_full_tile_door = !CHECK_BITFIELD(atom_flags, ON_BORDER) && !(instant || forced) && (locate(/mob/living) in loc)
	if(!CHECK_BITFIELD(door_flags, DOOR_OPEN) || CHECK_BITFIELD(door_flags, DOOR_CLOSING) || (is_there_mob_on_full_tile_door && !slam_the_door))
		return

	if(construction_steps_index != 1)
		if(user)
			balloon_alert(user, "Needs assembly!")
		return

	if(slam_the_door && !handle_door_force_close_cooldown(user))
		return

	close(slam_the_door, slam_the_door)

/**
 * Used in any instance where you only want to close a door
 * * instant - TRUE if you want to close it instantly
 * * slammed - TRUE if you want to close it through violent means
 * * silent - TRUE if you don't want to play the closing sound (does not affect the slamming sound)
 */
/obj/structure/door/proc/close(instant, slammed, silent)
	deltimer(delay_timer)

	if(!silent && close_sound)
		playsound(src, close_sound, 40, FALSE, 5, 1)

	if(instant || !closing_time)
		var/door_recoil_damage_multiplier = door_combat()
		DISABLE_BITFIELD(door_flags, DOOR_OPEN)
		DISABLE_BITFIELD(door_flags, DOOR_CLOSING)
		DISABLE_BITFIELD(door_flags, DOOR_OPENING)
		layer = CHECK_BITFIELD(door_flags, DOOR_OPEN) ? DOOR_OPEN_LAYER : initial(layer)
		icon_state = initial(icon_state)
		density = !density
		opacity = initial(opacity)	//So stuff like windoors remain transparent
		if(slammed)
			playsound(src, slam_sound, 70, FALSE, 10, 2)
		update_icon()
		//So you can't just camp a door and use it as a weapon forever
		if(door_recoil_damage_multiplier)
			take_damage(30 * door_recoil_damage_multiplier, BRUTE, MELEE)

		//Open it if a mob is blocking the door from closing
		if(!CHECK_BITFIELD(atom_flags, ON_BORDER) && locate(/mob/living) in loc)
			attempt_to_open(forced = TRUE)

		return

	ENABLE_BITFIELD(door_flags, DOOR_CLOSING)
	update_icon()
	flick("[initial(icon_state)]_closing", src)
	delay_timer = addtimer(CALLBACK(src, PROC_REF(close), TRUE, slammed, TRUE), closing_time, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)

///Handles automatically closing a door
/obj/structure/door/proc/auto_close(mob/door_closer)
	//Don't close the door if the person passing through isn't being very polite; prevent auto closing locked doors for players' sanity
	if(!ismob(door_closer) || !CHECK_BITFIELD(door_flags, DOOR_OPEN) || CHECK_BITFIELD(door_flags, DOOR_CLOSING) || door_closer.throwing || door_closer.a_intent != INTENT_HELP || lock?.locked)
		return

	//Check if a non-mob type is near the door so the door doesn't close itself in someone's face
	var/nearby_turfs = get_adjacent_open_turfs(src)
	for(var/T in nearby_turfs)
		//Using a for loop instead of locate() to check if a nearby mob is the one closing it
		for(var/mob/living/L in T)
			if(L != door_closer)
				return

	attempt_to_close(door_closer)

/obj/structure/door/on_try_exit(datum/source, atom/movable/mover, direction, list/knownblockers)
	. = ..()
	//Check for livings instead of mobs because I imagine a ghost might accidentally close it
	//Also only bother if the door is non-full tile and facing the same direction as the mover
	if(!isliving(mover) || !CHECK_BITFIELD(atom_flags, ON_BORDER) || direction != dir)
		return .

	if(. != COMPONENT_ATOM_BLOCK_EXIT)	//Close the door if the mover was going through it and it was already open
		auto_close(mover)
		return .

	//Open the door since it's blocking the mover's attempt to exit
	attempt_to_open(ismob(mover) ? mover : null, direction_from_opener = angle2dir(Get_Angle(src, mover)), bumped = TRUE)
	if(CHECK_BITFIELD(door_flags, DOOR_OPEN))
		return . == COMPONENT_ATOM_BLOCK_EXIT ? FALSE : .	//So that it doesn't block the mover if it's already open

	return .

///Used for auto closing with full tile doors as this is called only when an atom completely exits the tile this door is on
/obj/structure/door/proc/on_exited(datum/source, atom/movable/AM, direction)
	SIGNAL_HANDLER
	if(CHECK_BITFIELD(atom_flags, ON_BORDER))	//See on_try_exit()
		return

	auto_close(AM)

/obj/structure/door/proc/attach_lock(mob/user, obj/item/lock/attaching_lock)
	if(!CHECK_BITFIELD(door_flags, DOOR_LOCKABLE))
		balloon_alert(user, "Cannot attach a lock to this door")
		return

	if(lock)
		balloon_alert(user, "Already has a lock")
		return

	if(CHECK_BITFIELD(door_flags, DOOR_OPENING) || CHECK_BITFIELD(door_flags, DOOR_CLOSING))
		balloon_alert(user, "Wait for the door")
		return

	if(user)
		if(!do_after(user, attaching_lock.attach_time, NONE, src, BUSY_ICON_BUILD))
			return

		user.temporarilyRemoveItemFromInventory(attaching_lock)

	attaching_lock.forceMove(src)
	lock = attaching_lock
	update_icon()

/obj/structure/door/proc/detach_lock()
	if(!lock)
		return

	lock.forceMove(get_turf(src))
	lock = null
	update_icon()

///Why is this a separate proc? Because resin doors need to override this otherwise benos will be getting slapped by their own doors
/obj/structure/door/proc/door_combat()
	var/result = 0
	//Make sure the door wasn't closed gently
	if(!CHECK_BITFIELD(door_flags, DOOR_CLOSING))
		for(var/mob/living/they_let_the_door_hit_them_on_the_way_out in loc)
			//Door combat let's goooo
			they_let_the_door_hit_them_on_the_way_out.take_overall_damage(20, BRUTE, MELEE)
			result += 1 * (they_let_the_door_hit_them_on_the_way_out.mob_size + 1)

	return result

//Explosions can open doors!
/obj/structure/door/ex_act(severity)
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		return

	//These numbers are arbitrary as hell... why can't severity be a damage amount instead, Tivi?!
	switch(severity)
		if(EXPLODE_DEVASTATE)
			deconstruct()	//Just die

		/*
		Yes I know these values are pretty low compared to mineral door healths but
		1. Incredibly hard to find materials to build them
		2. They are way too tanky, I'm only not touching them because of reason 1
		Although this is all assuming 100 HP is a good standard for doors, so someone should change these values if that does not remain the case
		Note: attempt_to_open will only deal their damage if the door was not open, so open doors in a way take half damage!
		*/
		if(EXPLODE_HEAVY)
			take_damage(150)
			attempt_to_open(null, TRUE, TRUE, damage = 150)
		if(EXPLODE_LIGHT)
			take_damage(75)
			attempt_to_open(null, TRUE, TRUE, damage = 75)
		if(EXPLODE_WEAK)
			take_damage(25)
			attempt_to_open(damage = 25)	//Pretty weak so not even forced open

/obj/structure/door/mineral_door
	name = "mineral door"
	allow_pass_flags = NONE	//I guess these are airtight?
	icon_state = "metal"

/obj/structure/door/mineral_door/wood
	name = "wooden door"
	icon_state = "wood"
	open_sound = 'sound/effects/doorcreaky.ogg'
	close_sound = 'sound/effects/doorcreaky.ogg'

/obj/structure/door/mineral_door/wood/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/obj/structure/door/mineral_door/iron
	name = "iron door"
	max_integrity = 500
	material_type = /obj/item/stack/sheet/metal

/obj/structure/door/mineral_door/silver
	name = "silver door"
	icon_state = "silver"
	max_integrity = 500
	material_type = /obj/item/stack/sheet/mineral/silver

/obj/structure/door/mineral_door/gold
	name = "gold door"
	icon_state = "gold"
	max_integrity = 250
	material_type = /obj/item/stack/sheet/mineral/gold

/obj/structure/door/mineral_door/uranium
	name = "uranium door"
	icon_state = "uranium"
	max_integrity = 500
	material_type = /obj/item/stack/sheet/mineral/uranium

/obj/structure/door/mineral_door/sandstone
	name = "sandstone door"
	icon_state = "sandstone"
	material_type = /obj/item/stack/sheet/mineral/sandstone

/obj/structure/door/mineral_door/transparent
	name = "generic transparent door"
	opacity = FALSE

/obj/structure/door/mineral_door/transparent/phoron
	name = "phoron door"
	icon_state = "phoron"
	max_integrity = 250
	material_type = /obj/item/stack/sheet/mineral/phoron

/obj/structure/door/mineral_door/transparent/phoron/attackby(obj/item/attacking_item as obj, mob/user as mob)
	if(istype(attacking_item, /obj/item/tool/weldingtool))
		var/obj/item/tool/weldingtool/WT = attacking_item
		if(WT.remove_fuel(0, user))
			var/turf/T = get_turf(src)
			T.ignite(25, 25)
			visible_message(span_danger("[src] suddenly combusts!"))

	return ..()

/obj/structure/door/mineral_door/transparent/phoron/fire_act(burn_level)
	if(burn_level > 30)
		var/turf/T = get_turf(src)
		T.ignite(25, 25)

/obj/structure/door/mineral_door/transparent/diamond
	name = "diamond door"
	icon_state = "diamond"
	max_integrity = 1000
	material_type = /obj/item/stack/sheet/mineral/diamond

/obj/structure/door/non_full_tile_door
	name = "DO NOT USE THIS"
	desc = "THIS IS AN EXAMPLE OF A NON-FULL TILE DOOR. MAKE AN ACTUAL ITEM AND PATH."
	icon_state = "diamond"
	atom_flags = ON_BORDER
	opacity = FALSE
