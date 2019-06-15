
//NOT bitflags, just global constant values
#define HDPT_PRIMARY "primary"
#define HDPT_SECDGUN "secondary"
#define HDPT_SUPPORT "support"
#define HDPT_ARMOR "armor"
#define HDPT_TREADS "treads"

//Percentages of what hardpoints take what damage, e.g. armor takes 37.5% of the damage
GLOBAL_LIST_INIT(armorvic_dmg_distributions, list(
	HDPT_PRIMARY = 0.15,
	HDPT_SECDGUN = 0.125,
	HDPT_SUPPORT = 0.075,
	HDPT_ARMOR = 0.5,
	HDPT_TREADS = 0.15))

//Currently unused, I thought I was gonna need to fuck with stuff but we good
/*
var/list/TANK_HARDPOINT_OFFSETS = list(
	HDPT_MAINGUN = "0,0",
	HDPT_SECDGUN = "0,0",
	HDPT_SUPPORT = "0,0",
	HDPT_ARMOR = "0,0",
	HDPT_TREADS = "0,0")*/

//The main object, should be an abstract class
/obj/vehicle/multitile/root/cm_armored
	name = "Armored Vehicle"
	desc = "Get inside to operate the vehicle."
	hitbox_type = /obj/vehicle/multitile/hitbox/cm_armored //Used for emergencies and respawning hitboxes

	//What slots the vehicle can have
	var/list/hardpoints = list(HDPT_ARMOR, HDPT_TREADS, HDPT_SECDGUN, HDPT_SUPPORT, HDPT_PRIMARY)

	//The next world.time when the tank can move
	var/next_move = 0

	//Below are vars that can be affected by hardpoints, generally used as ratios or decisecond timers

	move_delay = 30 //default 3 seconds per tile

	var/active_hp

	var/list/dmg_distribs = list()

	//Changes cooldowns and accuracies
	var/list/misc_ratios = list(
		"move" = 1.0,
		"prim_acc" = 1.0,
		"secd_acc" = 1.0,
		"supp_acc" = 1.0,
		"prim_cool" = 1.0,
		"secd_cool" = 1.0,
		"supp_cool" = 1.0)

	//Changes how much damage the tank takes
	var/list/dmg_multipliers = list(
		"all" = 1.0, //for when you want to make it invincible
		"acid" = 1.0,
		"slash" = 1.0,
		"bullet" = 1.0,
		"explosive" = 1.0,
		"blunt" = 1.0,
		"abstract" = 1.0) //abstract for when you just want to hurt it

	//Decisecond cooldowns for the slots
	var/list/cooldowns = list(
		"primary" = 300,
		"secondary" = 200,
		"support" = 150)

	//Percentage accuracies for slot
	var/list/accuracies = list(
		"primary" = 0.97,
		"secondary" = 0.67,
		"support" = 0.5)

	//Placeholders
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "cargo_engine"

/obj/vehicle/multitile/root/cm_armored/Destroy()
	for(var/i in linked_objs)
		var/obj/O = linked_objs[i]
		if(O == src)
			continue
		qdel(O, TRUE) //Delete all of the hitboxes etc

	return ..()

//What to do if all ofthe installed modules have been broken
/obj/vehicle/multitile/root/cm_armored/proc/handle_all_modules_broken()
	return

/obj/vehicle/multitile/root/cm_armored/proc/deactivate_all_hardpoints()
	var/list/slots = get_activatable_hardpoints()
	for(var/slot in slots)
		var/obj/item/hardpoint/HP = hardpoints[slot]
		HP?.deactivate()

/obj/vehicle/multitile/root/cm_armored/proc/remove_all_players()
	return

//The basic vehicle code that moves the tank, with movement delay implemented
/obj/vehicle/multitile/root/cm_armored/relaymove(mob/user, direction)
	if(world.time < next_move)
		return
	next_move = world.time + move_delay * misc_ratios["move"]

	return ..()

//Same thing but for rotations
/obj/vehicle/multitile/root/cm_armored/try_rotate(deg, mob/user, force = FALSE)
	if(world.time < next_move && !force)
		return
	next_move = world.time + move_delay * misc_ratios["move"] * (force ? 2 : 3) //3 for a 3 point turn, idk
	return ..()

/obj/vehicle/multitile/root/cm_armored/proc/can_use_hp(mob/M)
	return TRUE

//Used by the gunner to swap which module they are using
//e.g. from the minigun to the smoke launcher
//Only the active hardpoint module can be used
/obj/vehicle/multitile/root/cm_armored/verb/switch_active_hp()
	set name = "Change Active Weapon"
	set category = "Vehicle"
	set src in view(0)

	if(!can_use_hp(usr))
		return

	var/list/slots = get_activatable_hardpoints()

	if(!length(slots))
		to_chat(usr, "<span class='warning'>All of the modules can't be activated or are broken.</span>")
		return

	var/slot = input("Select a slot.") in slots

	var/obj/item/hardpoint/HP = hardpoints[slot]
	if(!(HP?.obj_integrity))
		to_chat(usr, "<span class='warning'>That module is either missing or broken.</span>")
		return

	active_hp = slot
	to_chat(usr, "<span class='notice'>You select the [slot] slot.</span>")
	if(isliving(usr))
		var/mob/living/M = usr
		M.set_interaction(src)

/obj/vehicle/multitile/root/cm_armored/verb/reload_hp()
	set name = "Reload Active Weapon"
	set category = "Vehicle"
	set src in view(0)

	if(!can_use_hp(usr))
		return

	//TODO: make this a proc so I don't keep repeating this code
	var/list/slots = get_activatable_hardpoints()

	if(!length(slots))
		to_chat(usr, "<span class='warning'>All of the modules can't be reloaded or are broken.</span>")
		return

	var/slot = input("Select a slot.") in slots

	var/obj/item/hardpoint/HP = hardpoints[slot]
	if(!length(HP?.backup_clips))
		to_chat(usr, "<span class='warning'>That module is either missing or has no remaining backup clips.</span>")
		return

	var/obj/item/ammo_magazine/A = HP.backup_clips[1] //LISTS START AT 1 REEEEEEEEEEEE
	if(!A)
		to_chat(usr, "<span class='danger'>Something went wrong! PM a staff member! Code: T_RHPN</span>")
		return

	to_chat(usr, "<span class='notice'>You begin reloading the [slot] module.</span>")

	addtimer(CALLBACK(src, .proc/finish_reloading_hp, usr, HP, A, slot), 2 SECONDS)

/obj/vehicle/multitile/root/cm_armored/proc/finish_reloading_hp(mob/living/user, obj/item/hardpoint/HP, obj/item/ammo_magazine/A, slot)
	if(!can_use_hp(usr))
		return

	HP.ammo.forceMove(get_turf(entrance))
	HP.ammo.update_icon()
	HP.ammo = A
	HP.backup_clips.Remove(A)

	to_chat(usr, "<span class='notice'>You reload the [slot] module.</span>")


/obj/vehicle/multitile/root/cm_armored/proc/get_activatable_hardpoints()
	var/list/slots = list()
	for(var/slot in hardpoints)
		var/obj/item/hardpoint/HP = hardpoints[slot]
		if(!(HP?.obj_integrity))
			continue
		if(!HP.is_activatable)
			continue
		slots += slot

	return slots

//Specialness for armored vics
/obj/vehicle/multitile/root/cm_armored/load_hitboxes(datum/coords/dimensions, datum/coords/root_pos)

	var/start_x = -1 * root_pos.x_pos
	var/start_y = -1 * root_pos.x_pos
	var/end_x = start_x + dimensions.x_pos - 1
	var/end_y = start_y + dimensions.y_pos - 1

	for(var/i = start_x to end_x)

		for(var/j = start_y to end_y)

			if(i == 0 && j == 0)
				continue

			var/datum/coords/C = new
			C.x_pos = i
			C.y_pos = j
			C.z_pos = 0

			var/obj/vehicle/multitile/hitbox/cm_armored/H = new(locate(x + C.x_pos, y + C.y_pos, z))
			H.setDir(dir)
			H.root = src
			linked_objs[C] = H

/obj/vehicle/multitile/root/cm_armored/load_entrance_marker(datum/coords/rel_pos)

	entrance = new(locate(x + rel_pos.x_pos, y + rel_pos.y_pos, z))
	entrance.master = src
	linked_objs[rel_pos] = entrance

//Normal examine() but tells the player what is installed and if it's broken
/obj/vehicle/multitile/root/cm_armored/examine(mob/user)
	..()
	for(var/i in hardpoints)
		var/obj/item/hardpoint/HP = hardpoints[i]
		if(!HP)
			to_chat(user, "There is nothing installed on the [i] hardpoint slot.")
			continue
		var/status = !HP.obj_integrity  ? "broken" : "functional"
		var/span_class = !HP.obj_integrity ? "<span class = 'danger'>" : "<span class = 'notice'>"
		if((user?.mind?.cm_skills && user.mind.cm_skills.engineer >= SKILL_ENGINEER_METAL) || isobserver(user))
			switch(PERCENT(HP.obj_integrity / HP.max_integrity))
				if(0.1 to 33)
					status = "heavily damaged"
					span_class = "<span class = 'warning'>"
				if(33.1 to 66)
					status = "damaged"
					span_class = "<span class = 'warning'>"
				if(66.1 to 90)
					status = "slighty damaged"
				if(90.1 to 100)
					status = "intact"
		to_chat(user, "[span_class]There is a [status] [HP] installed on the [i] slot.</span>")

//Special armored vic healthcheck that mainly updates the hardpoint states
/obj/vehicle/multitile/root/cm_armored/healthcheck()
	obj_integrity = max_integrity //The tank itself doesn't take damage
	var/i
	var/remove_person = TRUE //Whether or not to call handle_all_modules_broken()
	for(i in hardpoints)
		var/obj/item/hardpoint/H = hardpoints[i]
		if(!H)
			continue
		if(!H.obj_integrity)
			H.remove_buff()
		else
			remove_person = FALSE //if something exists but isnt broken

	if(remove_person)
		handle_all_modules_broken()

	update_icon()

//Since the vics are 3x4 we need to swap between the two files with different dimensions
//Also need to offset to center the tank about the root object
/obj/vehicle/multitile/root/cm_armored/update_icon()

	overlays.Cut()

	//Assuming 3x3 with half block overlaps in the tank's direction
	if(dir in list(NORTH, SOUTH))
		pixel_x = -32
		pixel_y = -48
		icon = 'icons/obj/tank_NS.dmi'

	else if(dir in list(EAST, WEST))
		pixel_x = -48
		pixel_y = -32
		icon = 'icons/obj/tank_EW.dmi'

	//Basic iteration that snags the overlay from the hardpoint module object
	for(var/i in hardpoints)
		var/obj/item/hardpoint/H = hardpoints[i]

		if((i == HDPT_TREADS && !H) || (H && !H.obj_integrity)) //Treads not installed or broken
			var/image/I = image(icon, icon_state = "damaged_hardpt_[i]")
			overlays += I

		if(H)
			var/image/I = H.get_icon_image(0, 0, dir)
			overlays += I

//Hitboxes but with new names
/obj/vehicle/multitile/hitbox/cm_armored
	name = "Armored Vehicle"
	desc = "Get inside to operate the vehicle."
	luminosity = 7
	throwpass = 1 //You can lob nades over tanks, and there's some dumb check somewhere that requires this
	var/lastsound = 0

//If something want to delete this, it's probably either an admin or the shuttle
//If it's an admin, they want to disable this
//If it's the shuttle, it should do damage
//If fully repaired and moves at least once, the broken hitboxes will respawn according to multitile.dm
/obj/vehicle/multitile/hitbox/cm_armored/Destroy()
	var/obj/vehicle/multitile/root/cm_armored/C = root
	C?.take_damage_type(1000000, "abstract")
	return ..()

//Tramplin' time, but other than that identical
/obj/vehicle/multitile/hitbox/cm_armored/Bump(atom/A)
	. = ..()
	var/facing = get_dir(src, A)
	var/turf/temp = loc
	var/turf/T = loc
	A.tank_collision(src, facing, T, temp)
	if(isliving(A))
		log_attack("[get_driver()] drove over [A] with [root]")


/obj/vehicle/multitile/hitbox/cm_armored/proc/get_driver()
	return "Someone"

/atom/proc/tank_collision(obj/vehicle/multitile/hitbox/cm_armored/C, facing, turf/T, turf/temp)
	return

/mob/living/tank_collision(obj/vehicle/multitile/hitbox/cm_armored/C, facing, turf/T, turf/temp)
	if(stat == DEAD) //We don't care about the dead
		return
	if(loc == C.loc) // treaded over.
		if(!knocked_down)
			KnockDown(1)
		var/target_dir = turn(C.dir, 180)
		temp = get_step(C.loc, target_dir)
		T = temp
		target_dir = turn(C.dir, 180)
		T = get_step(T, target_dir)
		face_atom(T)
		throw_at(T, 3, 2, C, 1)
		apply_damage(rand(5, 7.5), BRUTE)
		return
	if(!lying)
		temp = get_step(T, facing)
		T = temp
		T = get_step(T, pick(GLOB.cardinals))
		if(mob_size == MOB_SIZE_BIG)
			throw_at(T, 3, 2, C, 0)
		else
			throw_at(T, 3, 2, C, 1)
		if(!knocked_down)
			KnockDown(1)
		apply_damage(rand(10, 15), BRUTE)
		visible_message("<span class='danger'>[C] bumps into [src], throwing [p_them()] away!</span>", "<span class='danger'>[C] violently bumps into you!</span>")
	var/obj/vehicle/multitile/root/cm_armored/CA = C.root
	var/list/slots = CA.get_activatable_hardpoints()
	for(var/slot in slots)
		var/obj/item/hardpoint/H = CA.hardpoints[slot]
		H?.livingmob_interact(src)

/mob/living/carbon/xenomorph/queen/tank_collision(obj/vehicle/multitile/hitbox/cm_armored/C, facing, turf/T, turf/temp)
	if(lying || loc == C.loc)
		return ..()
	temp = get_step(T, facing)
	T = temp
	T = get_step(T, pick(GLOB.cardinals))
	throw_at(T, 2, 2, C, 0)
	visible_message("<span class='danger'>[C] bumps into [src], pushing [p_them()] away!</span>", "<span class='danger'>[C] bumps into you!</span>")

/mob/living/carbon/xenomorph/crusher/tank_collision(obj/vehicle/multitile/hitbox/cm_armored/C, facing, turf/T, turf/temp)
	if(lying || loc == C.loc)
		return ..()
	temp = get_step(T, facing)
	T = temp
	T = get_step(T, pick(GLOB.cardinals))
	throw_at(T, 2, 2, C, 0)
	visible_message("<span class='danger'>[C] bumps into [src], pushing [p_them()] away!</span>", "<span class='danger'>[C] bumps into you!</span>")

/mob/living/carbon/xenomorph/larva/tank_collision(obj/vehicle/multitile/hitbox/cm_armored/C, facing, turf/T, turf/temp)
	if(loc == C.loc) // treaded over.
		if(!knocked_down)
			KnockDown(1)
		apply_damage(rand(5, 7.5), BRUTE)
		return
	var/obj/vehicle/multitile/root/cm_armored/CA = C.root
	var/list/slots = CA.get_activatable_hardpoints()
	for(var/slot in slots)
		var/obj/item/hardpoint/H = CA.hardpoints[slot]
		H?.livingmob_interact(src)

/turf/closed/wall/tank_collision(obj/vehicle/multitile/hitbox/cm_armored/C, facing, turf/T, turf/temp)
	var/obj/vehicle/multitile/root/cm_armored/tank/CA = C.root
	var/damage = 30
	var/tank_damage = 2

	if(facing == CA.old_dir && istype(CA.hardpoints[HDPT_ARMOR], /obj/item/hardpoint/armor/snowplow) ) //Snowplow eliminates collision damage, and doubles damage dealt if we're facing the thing we're crushing
		var/obj/item/hardpoint/armor/snowplow/SP = CA.hardpoints[HDPT_ARMOR]
		if(SP.obj_integrity)
			damage = 45
			tank_damage = 1

	take_damage(damage)
	CA.take_damage_type(tank_damage, "blunt", src)
	if(world.time > C.lastsound + 1 SECONDS)
		playsound(src, 'sound/effects/metal_crash.ogg', 35)
		C.lastsound = world.time

/obj/machinery/tank_collision(obj/vehicle/multitile/hitbox/cm_armored/C, facing, turf/T, turf/temp)
	var/obj/vehicle/multitile/root/cm_armored/tank/CA = C.root
	var/damage = 30
	var/tank_damage = 2

	if(facing == CA.old_dir && istype(CA.hardpoints[HDPT_ARMOR], /obj/item/hardpoint/armor/snowplow) ) //Snowplow eliminates collision damage, and doubles damage dealt if we're facing the thing we're crushing
		var/obj/item/hardpoint/armor/snowplow/SP = CA.hardpoints[HDPT_ARMOR]
		if(SP.obj_integrity)
			damage = 60
			tank_damage = 0

	take_damage(damage)
	CA.take_damage_type(tank_damage, "blunt", src)
	if(world.time > C.lastsound + 1 SECONDS)
		visible_message("<span class='danger'>[CA] rams into \the [src]!</span>")
		playsound(src, 'sound/effects/metal_crash.ogg', 35)
		C.lastsound = world.time

/obj/structure/tank_collision(obj/vehicle/multitile/hitbox/cm_armored/C, facing, turf/T, turf/temp)
	var/obj/vehicle/multitile/root/cm_armored/tank/CA = C.root
	var/damage = 30
	var/tank_damage = 2

	if(facing == CA.old_dir && istype(CA.hardpoints[HDPT_ARMOR], /obj/item/hardpoint/armor/snowplow) ) //Snowplow eliminates collision damage, and doubles damage dealt if we're facing the thing we're crushing
		var/obj/item/hardpoint/armor/snowplow/SP = CA.hardpoints[HDPT_ARMOR]
		if(SP.obj_integrity)
			damage = 60
			tank_damage = 0

	take_damage(damage)
	CA.take_damage_type(tank_damage, "blunt", src)
	if(world.time > C.lastsound + 1 SECONDS)
		visible_message("<span class='danger'>[CA] crushes \the [src]!</span>")
		playsound(src, 'sound/effects/metal_crash.ogg', 35)
		C.lastsound = world.time

/obj/effect/alien/tank_collision(obj/vehicle/multitile/hitbox/cm_armored/C, facing, turf/T, turf/temp)
	take_damage(40)

/obj/effect/alien/weeds/tank_collision(obj/vehicle/multitile/hitbox/cm_armored/C, facing, turf/T, turf/temp)
	return

/obj/vehicle/multitile/hitbox/cm_armored/Move(atom/A, direction)

	for(var/mob/living/M in get_turf(src))
		M.tank_collision(src)

	. = ..()

	if(.)
		for(var/mob/living/M in get_turf(A))
			M.tank_collision(src)

//Can't hit yourself with your own bullet
/obj/vehicle/multitile/hitbox/cm_armored/get_projectile_hit_chance(obj/item/projectile/P)
	if(P.firer == root) //Don't hit our own hitboxes
		return FALSE

	return ..()

//For the next few, we're just tossing the handling up to the rot object
/obj/vehicle/multitile/hitbox/cm_armored/bullet_act(obj/item/projectile/P)
	return root.bullet_act(P)

/obj/vehicle/multitile/hitbox/cm_armored/ex_act(severity)
	return root.ex_act(severity)

/obj/vehicle/multitile/hitbox/cm_armored/attackby(obj/item/I, mob/user, params)
	return root.attackby(I, user, params)

/obj/vehicle/multitile/hitbox/cm_armored/attack_alien(mob/living/carbon/xenomorph/M, dam_bonus)
	return root.attack_alien(M, dam_bonus)

/obj/vehicle/multitile/hitbox/cm_armored/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_ACID))
		var/obj/vehicle/multitile/root/cm_armored/T = root
		T.take_damage_type(30, "acid")

//A bit icky, but basically if you're adjacent to the tank hitbox, you are then adjacent to the root object
/obj/vehicle/multitile/root/cm_armored/Adjacent(atom/A)
	for(var/i in linked_objs)
		var/obj/vehicle/multitile/hitbox/cm_armored/H = linked_objs[i]
		if(!H)
			continue
		if(get_dist(H, A) <= 1)
			return TRUE //Using get_dist() to avoid hidden code that recurs infinitely here
	return ..()

//Returns the ratio of damage to take, just a housekeeping thing
/obj/vehicle/multitile/root/cm_armored/proc/get_dmg_multi(type)
	if(!dmg_multipliers.Find(type))
		return 0
	return dmg_multipliers[type] * dmg_multipliers["all"]

//Generic proc for taking damage
//ALWAYS USE THIS WHEN INFLICTING DAMAGE TO THE VEHICLES
/obj/vehicle/multitile/root/cm_armored/proc/take_damage_type(damage, type, atom/attacker)
	for(var/i in hardpoints)
		var/obj/item/hardpoint/HP = hardpoints[i]
		if(HP)
			HP.obj_integrity = CLAMP(HP.obj_integrity - damage * dmg_distribs[i] * get_dmg_multi(type), 0, HP.max_integrity)

	healthcheck()

	if(istype(attacker, /mob))
		var/mob/M = attacker
		log_attack("[src] took [damage] [type] damage from [M] ([M.client ? M.client.ckey : "disconnected"]).")
	else
		log_attack("[src] took [damage] [type] damage from [attacker].")

/obj/vehicle/multitile/root/cm_armored/get_projectile_hit_chance(obj/item/projectile/P)
	if(P.firer == src) //Don't hit ourself.
		return FALSE

	return ..()

//Differentiates between damage types from different bullets
//Applies a linear transformation to bullet damage that will generally decrease damage done
/obj/vehicle/multitile/root/cm_armored/bullet_act(obj/item/projectile/P)

	var/dam_type = "bullet"

	if(P.ammo.flags_ammo_behavior & AMMO_XENO_ACID) dam_type = "acid"

	take_damage_type(P.damage * (0.75 + P.ammo.penetration/100), dam_type, P.firer)

//severity 1.0 explosions never really happen so we're gonna follow everyone else's example
/obj/vehicle/multitile/root/cm_armored/ex_act(severity)

	switch(severity)
		if(1)
			take_damage_type(rand(250, 350), "explosive") //Devastation level explosives are anti-tank and do real damage.
			take_damage_type(rand(20, 40), "slash")

		if(2)
			take_damage_type(rand(30, 40), "explosive") //Heavy explosions do some damage, but are largely deferred by the armour/bulk.
			take_damage_type(rand(10, 15), "slash")

//Honestly copies some code from the Xeno files, just handling some special cases
/obj/vehicle/multitile/root/cm_armored/attack_alien(mob/living/carbon/xenomorph/M, dam_bonus)

	if(M.loc == entrance.loc && M.a_intent == INTENT_HELP)
		handle_player_entrance(M) //will call the get out of tank proc on its own
		return

	var/damage = rand(M.xeno_caste.melee_damage_lower, M.xeno_caste.melee_damage_upper) + dam_bonus + FRENZY_DAMAGE_BONUS(M)

	M.animation_attack_on(src)

	//Somehow we will deal no damage on this attack
	if(!damage)
		playsound(M.loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
		M.animation_attack_on(src)
		M.visible_message("<span class='danger'>\The [M] lunges at [src]!</span>", \
		"<span class='danger'>You lunge at [src]!</span>")
		return FALSE

	else
		playsound(loc, "alien_claw_metal", 25, 1)

	SEND_SIGNAL(M, COMSIG_XENOMORPH_ATTACK_TANK)

	M.visible_message("<span class='danger'>\The [M] slashes [src]!</span>", \
	"<span class='danger'>You slash [src]!</span>")

	take_damage_type(damage * ( (isxenoravager(M)) ? 2 : 1 ), "slash", M) //Ravs do a bitchin double damage

//Special case for entering the vehicle without using the verb
/obj/vehicle/multitile/root/cm_armored/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(user.loc == entrance.loc)
		handle_player_entrance(user)
		return


/obj/vehicle/multitile/root/cm_armored/Entered(atom/movable/A)
	if(istype(A, /obj) && !istype(A, /obj/item/ammo_magazine/tank) && !istype(A, /obj/item/hardpoint))
		A.forceMove(loc)
		return

	return ..()

//Need to take damage from crushers, probably too little atm
/obj/vehicle/multitile/root/cm_armored/Bumped(atom/A)
	..()

	if(istype(A, /mob/living/carbon/xenomorph/crusher))

		var/mob/living/carbon/xenomorph/crusher/C = A

		if(C.charge_speed < CHARGE_SPEED_MAX/(1.1)) //Arbitrary ratio here, might want to apply a linear transformation instead
			return

		take_damage_type(C.charge_speed * CRUSHER_CHARGE_TANK_MULTI, "blunt", C)

//Redistributes damage ratios based off of what things are attached (no armor means the armor doesn't mitigate any damage)
/obj/vehicle/multitile/root/cm_armored/proc/update_damage_distribs()
	dmg_distribs = GLOB.armorvic_dmg_distributions.Copy() //Assume full installs
	for(var/slot in hardpoints)
		var/obj/item/hardpoint/HP = hardpoints[slot]
		if(!HP)
			dmg_distribs[slot] = 0.0 //Remove empty slots' damage mitigation
	var/acc = 0
	for(var/slot in dmg_distribs)
		var/ratio = dmg_distribs[slot]
		acc += ratio //Get total current ratio applications
	if(acc == 0)
		return
	for(var/slot in dmg_distribs)
		var/ratio = dmg_distribs[slot]
		dmg_distribs[slot] = ratio/acc //Redistribute according to previous ratios for full damage taking, but ignoring empty slots

//Special cases abound, handled below or in subclasses
/obj/vehicle/multitile/root/cm_armored/attackby(obj/item/O, mob/user)

	if(istype(O, /obj/item/hardpoint)) //Are we trying to install stuff?
		var/obj/item/hardpoint/HP = O
		install_hardpoint(HP, user)

	else if(istype(O, /obj/item/ammo_magazine)) //Are we trying to reload?
		var/obj/item/ammo_magazine/AM = O
		handle_ammomag_attackby(AM, user)

	else if(iswelder(O) || iswrench(O)) //Are we trying to repair stuff?
		handle_hardpoint_repair(O, user)
		update_damage_distribs()

	else if(iscrowbar(O)) //Are we trying to remove stuff?
		uninstall_hardpoint(O, user)

	else
		. = ..()
		if(!(O.flags_item & NOBLUDGEON))
			take_damage_type(O.force * 0.05, "blunt", user) //Melee weapons from people do very little damage


/obj/vehicle/multitile/root/cm_armored/proc/handle_hardpoint_repair(obj/item/O, mob/user)

	//Need to the what the hell you're doing
	if(user.mind?.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_MT)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out what to do with [O] on the [src].</span>",
		"<span class='notice'>You fumble around figuring out what to do with [O] on the [src].</span>")
		var/fumbling_time = 50 * (SKILL_ENGINEER_MT - user.mind.cm_skills.engineer)
		if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
			return

	//Pick what to repair
	var/slot = input("Select a slot to try and repair") in hardpoints
	var/obj/item/I = user.get_active_held_item()
	if(!Adjacent(user) || (!iswelder(I) && !iswrench(I)))
		return

	var/obj/item/hardpoint/old = hardpoints[slot] //Is there something there already?

	if(!old)
		to_chat(user, "<span class='warning'>There is nothing installed on that slot.</span>")
		return

	if(old.obj_integrity >= old.max_integrity)
		to_chat(user, "<span class='notice'>\the [old] is already in perfect conditions.</span>")
		return

	//Determine how many 3 second intervals to wait and if you have the right tool
	var/num_delays = 6
	switch(slot)
		if(HDPT_PRIMARY)
			num_delays = 5
			if(!iswelder(I))
				to_chat(user, "<span class='warning'>That's the wrong tool. Use a welder.</span>")
				return
			var/obj/item/tool/weldingtool/WT = I
			if(!WT.isOn())
				to_chat(user, "<span class='warning'>You need to light your [WT] first.</span>")
				return

		if(HDPT_SECDGUN)
			num_delays = 3
			if(!iswrench(I))
				to_chat(user, "<span class='warning'>That's the wrong tool. Use a wrench.</span>")
				return

		if(HDPT_SUPPORT)
			num_delays = 2
			if(!iswrench(I))
				to_chat(user, "<span class='warning'>That's the wrong tool. Use a wrench.</span>")
				return

		if(HDPT_ARMOR)
			num_delays = 10
			if(!iswelder(I))
				to_chat(user, "<span class='warning'>That's the wrong tool. Use a welder.</span>")
				return
			var/obj/item/tool/weldingtool/WT = I
			if(!WT.isOn())
				to_chat(user, "<span class='warning'>You need to light your [WT] first.</span>")
				return

		if(HDPT_TREADS)
			if(!iswelder(I))
				to_chat(user, "<span class='warning'>That's the wrong tool. Use a welder.</span>")
				return
			var/obj/item/tool/weldingtool/WT = I
			if(!WT.isOn())
				to_chat(user, "<span class='warning'>You need to light your [WT] first.</span>")
				return
			WT.remove_fuel(num_delays, user)

	user.visible_message("<span class='notice'>[user] starts repairing the [slot] slot on [src].</span>",
		"<span class='notice'>You start repairing the [slot] slot on the [src].</span>")

	if(!do_after(user, 30 * num_delays, TRUE, src, BUSY_ICON_BUILD, extra_checks = iswelder(O) ? CALLBACK(O, /obj/item/tool/weldingtool/proc/isOn) : null))
		user.visible_message("<span class='notice'>[user] stops repairing the [slot] slot on [src].</span>",
			"<span class='notice'>You stop repairing the [slot] slot on the [src].</span>")
		return

	if(iswelder(O))
		var/obj/item/tool/weldingtool/WT = O
		WT.remove_fuel(num_delays, user)

	user.visible_message("<span class='notice'>[user] repairs the [slot] slot on the [src].</span>",
		"<span class='notice'>You repair the [slot] slot on [src].</span>")

	old.obj_integrity = old.max_integrity //We repaired it, good job
	old.apply_buff()

	update_icon()

//Relaoding stuff, pretty bare-bones and basic
/obj/vehicle/multitile/root/cm_armored/proc/handle_ammomag_attackby(obj/item/ammo_magazine/AM, mob/user)

	//No skill checks for reloading
	//Maybe I should delineate levels of skill for reloading, installation, and repairs?
	//That would make it easier to differentiate between the two for skills
	//Instead of using MT skills for these procs and TC skills for operation
	//Oh but wait then the MTs would be able to drive fuck that
	var/slot = input("Select a slot to try and refill") in hardpoints
	if(!Adjacent(user) || user.get_active_held_item() != AM)
		return
	var/obj/item/hardpoint/HP = hardpoints[slot]

	if(!HP)
		to_chat(user, "<span class='warning'>There is nothing installed on that slot.</span>")
		return

	HP.try_add_clip(AM, user)

//Putting on hardpoints
//Similar to repairing stuff, down to the time delay
/obj/vehicle/multitile/root/cm_armored/proc/install_hardpoint(obj/item/hardpoint/HP, mob/user)

	if(user.mind?.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_MT)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out what to do with [HP] on the [src].</span>",
		"<span class='notice'>You fumble around figuring out what to do with [HP] on the [src].</span>")
		var/fumbling_time = 50 * ( SKILL_ENGINEER_MT - user.mind.cm_skills.engineer )
		if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
			return

	var/obj/item/hardpoint/occupied = hardpoints[HP.slot]

	if(occupied)
		to_chat(user, "<span class='warning'>Remove the previous hardpoint module first.</span>")
		return

	user.visible_message("<span class='notice'>[user] begins installing [HP] on the [HP.slot] hardpoint slot on the [src].</span>",
		"<span class='notice'>You begin installing [HP] on the [HP.slot] hardpoint slot on the [src].</span>")

	var/num_delays = 1

	switch(HP.slot)
		if(HDPT_PRIMARY)
			num_delays = 5
		if(HDPT_SECDGUN)
			num_delays = 3
		if(HDPT_SUPPORT)
			num_delays = 2
		if(HDPT_ARMOR)
			num_delays = 10
		if(HDPT_TREADS)
			num_delays = 7

	if(!do_after(user, 30 * num_delays, TRUE, src, BUSY_ICON_BUILD))
		user.visible_message("<span class='warning'>[user] stops installing \the [HP] on [src].</span>", "<span class='warning'>You stop installing \the [HP] on [src].</span>")
		return

	if(occupied)
		return

	user.visible_message("<span class='notice'>[user] installs \the [HP] on [src].</span>", "<span class='notice'>You install \the [HP] on [src].</span>")

	user.temporarilyRemoveItemFromInventory(HP, 0)

	add_hardpoint(HP, user)

//User-orientated proc for taking of hardpoints
//Again, similar to the above ones
/obj/vehicle/multitile/root/cm_armored/proc/uninstall_hardpoint(obj/item/O, mob/user)

	if(user.mind?.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_MT)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out what to do with [O] on the [src].</span>",
		"<span class='notice'>You fumble around figuring out what to do with [O] on the [src].</span>")
		var/fumbling_time = 50 * ( SKILL_ENGINEER_MT - user.mind.cm_skills.engineer )
		if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
			return

	var/slot = input("Select a slot to try and remove") in hardpoints
	if(!Adjacent(user) || !iscrowbar(user.get_active_held_item()))
		return

	var/obj/item/hardpoint/old = hardpoints[slot]

	if(!old)
		to_chat(user, "<span class='warning'>There is nothing installed there.</span>")
		return

	user.visible_message("<span class='notice'>[user] begins removing [old] on the [old.slot] hardpoint slot on [src].</span>",
		"<span class='notice'>You begin removing [old] on the [old.slot] hardpoint slot on [src].</span>")

	var/num_delays = 1

	switch(old.slot)
		if(HDPT_PRIMARY)
			num_delays = 5
		if(HDPT_SECDGUN)
			num_delays = 3
		if(HDPT_SUPPORT)
			num_delays = 2
		if(HDPT_ARMOR)
			num_delays = 10
		if(HDPT_TREADS)
			num_delays = 7

	if(!do_after(user, 30 * num_delays, TRUE, src, BUSY_ICON_BUILD))
		user.visible_message("<span class='warning'>[user] stops removing \the [old] on [src].</span>", "<span class='warning'>You stop removing \the [old] on [src].</span>")
		return
	if(QDELETED(old) || old != hardpoints[slot])
		return

	user.visible_message("<span class='notice'>[user] removes \the [old] on [src].</span>", "<span class='notice'>You remove \the [old] on [src].</span>")

	remove_hardpoint(old, user)

//General proc for putting on hardpoints
//ALWAYS CALL THIS WHEN ATTACHING HARDPOINTS
/obj/vehicle/multitile/root/cm_armored/proc/add_hardpoint(obj/item/hardpoint/HP, mob/user)
	if(!istype(HP))
		return
	HP.owner = src
	if(HP.obj_integrity)
		HP.apply_buff()
	HP.forceMove(src)

	hardpoints[HP.slot] = HP
	update_damage_distribs()
	update_icon()

//General proc for taking off hardpoints
//ALWAYS CALL THIS WHEN REMOVING HARDPOINTS
/obj/vehicle/multitile/root/cm_armored/proc/remove_hardpoint(obj/item/hardpoint/old, mob/user)
	old.forceMove(user ? user.loc : entrance.loc)
	old.remove_buff()
	old.owner = null

	hardpoints[old.slot] = null
	update_damage_distribs()
	update_icon()



/obj/vehicle/multitile/root/cm_armored/contents_explosion(severity, target)
	return