

//NOT bitflags, just global constant values
#define HDPT_PRIMARY "primary"
#define HDPT_SECDGUN "secondary"
#define HDPT_SUPPORT "support"
#define HDPT_ARMOR "armor"
#define HDPT_TREADS "treads"

//Percentages of what hardpoints take what damage, e.g. armor takes 37.5% of the damage
var/list/armorvic_dmg_distributions = list(
	HDPT_PRIMARY = 0.15,
	HDPT_SECDGUN = 0.125,
	HDPT_SUPPORT = 0.075,
	HDPT_ARMOR = 0.5,
	HDPT_TREADS = 0.15)

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

	//Which hardpoints need to be repaired before the module can be replaced
	var/list/damaged_hps = list()

	//Placeholders
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "cargo_engine"

/obj/vehicle/multitile/root/cm_armored/Destroy()
	for(var/i in linked_objs)
		var/obj/O = linked_objs[i]
		if(O == src) continue
		qdel(O, 1) //Delete all of the hitboxes etc

	. = ..()

//What to do if all ofthe installed modules have been broken
/obj/vehicle/multitile/root/cm_armored/proc/handle_all_modules_broken()
	return

/obj/vehicle/multitile/root/cm_armored/proc/deactivate_all_hardpoints()
	var/list/slots = get_activatable_hardpoints()
	for(var/slot in slots)
		var/obj/item/hardpoint/HP = hardpoints[slot]
		if(!HP) continue
		HP.deactivate()

/obj/vehicle/multitile/root/cm_armored/proc/remove_all_players()
	return

//The basic vehicle code that moves the tank, with movement delay implemented
/obj/vehicle/multitile/root/cm_armored/relaymove(var/mob/user, var/direction)
	if(world.time < next_move) return
	next_move = world.time + move_delay * misc_ratios["move"]

	return ..()

//Same thing but for rotations
/obj/vehicle/multitile/root/cm_armored/try_rotate(var/deg, var/mob/user, var/force = 0)
	if(world.time < next_move && !force) return
	next_move = world.time + move_delay * misc_ratios["move"] * (force ? 2 : 3) //3 for a 3 point turn, idk
	return ..()

/obj/vehicle/multitile/root/cm_armored/proc/can_use_hp(var/mob/M)
	return 1

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

	if(!slots.len)
		to_chat(usr, "<span class='warning'>All of the modules can't be activated or are broken.</span>")
		return

	var/slot = input("Select a slot.") in slots

	var/obj/item/hardpoint/HP = hardpoints[slot]
	if(!HP)
		to_chat(usr, "<span class='warning'>There's nothing installed on that hardpoint.</span>")
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

	if(!slots.len)
		to_chat(usr, "<span class='warning'>All of the modules can't be reloaded or are broken.</span>")
		return

	var/slot = input("Select a slot.") in slots

	var/obj/item/hardpoint/HP = hardpoints[slot]
	if(!HP.backup_clips.len)
		to_chat(usr, "<span class='warning'>That module has no remaining backup clips.</span>")
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

	HP.ammo.Move(entrance.loc)
	HP.ammo.update_icon()
	HP.ammo = A
	HP.backup_clips.Remove(A)

	to_chat(usr, "<span class='notice'>You reload the [slot] module.</span>")


/obj/vehicle/multitile/root/cm_armored/proc/get_activatable_hardpoints()
	var/list/slots = list()
	for(var/slot in hardpoints)
		var/obj/item/hardpoint/HP = hardpoints[slot]
		if(!HP?.health > 0)
			continue
		if(!HP.is_activatable)
			continue
		slots += slot

	return slots

//Specialness for armored vics
/obj/vehicle/multitile/root/cm_armored/load_hitboxes(var/datum/coords/dimensions, var/datum/coords/root_pos)

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

			var/obj/vehicle/multitile/hitbox/cm_armored/H = new(locate(src.x + C.x_pos, src.y + C.y_pos, src.z))
			H.setDir(dir)
			H.root = src
			linked_objs[C] = H

/obj/vehicle/multitile/root/cm_armored/load_entrance_marker(var/datum/coords/rel_pos)

	entrance = new(locate(src.x + rel_pos.x_pos, src.y + rel_pos.y_pos, src.z))
	entrance.master = src
	linked_objs[rel_pos] = entrance

//Returns 1 or 0 if the slot in question has a broken installed hardpoint or not
/obj/vehicle/multitile/root/cm_armored/proc/is_slot_damaged(var/slot)
	var/obj/item/hardpoint/HP = hardpoints[slot]
	if(HP?.health <= 0)
		return TRUE
	return FALSE

//Normal examine() but tells the player what is installed and if it's broken
/obj/vehicle/multitile/root/cm_armored/examine(var/mob/user)
	..()
	for(var/i in hardpoints)
		var/obj/item/hardpoint/HP = hardpoints[i]
		if(!HP)
			to_chat(user, "There is nothing installed on the [i] hardpoint slot.")
		else
			if((user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer >= SKILL_ENGINEER_METAL) || isobserver(user))
				switch(PERCENT(HP.health / HP.maxhealth))
					if(0)
						to_chat(user, "There is a broken [HP] installed on [i] hardpoint slot.")
					if(1 to 33)
						to_chat(user, "There is a heavily damaged [HP] installed on [i] hardpoint slot.")
					if(34 to 66)
						to_chat(user, "There is a damaged [HP] installed on [i] hardpoint slot.")
					if(67 to 90)
						to_chat(user, "There is a lightly damaged [HP] installed on [i] hardpoint slot.")
					if(91 to 100)
						to_chat(user, "There is a non-damaged [HP] installed on [i] hardpoint slot.")
			else
				to_chat(user, "There is a [HP.health <= 0 ? "broken" : "working"] [HP] installed on the [i] hardpoint slot.")

//Special armored vic healthcheck that mainly updates the hardpoint states
/obj/vehicle/multitile/root/cm_armored/healthcheck()
	health = maxhealth //The tank itself doesn't take damage
	var/i
	var/remove_person = TRUE //Whether or not to call handle_all_modules_broken()
	for(i in hardpoints)
		var/obj/item/hardpoint/H = hardpoints[i]
		if(!H)
			continue
		if(H.health <= 0)
			H.remove_buff()
			if(H.slot != HDPT_TREADS)
				damaged_hps |= H.slot //Not treads since their broken module overlay is the same as the broken hardpoint overlay
		else remove_person = FALSE //if something exists but isnt broken

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
	var/i
	for(i in hardpoints)
		var/obj/item/hardpoint/H = hardpoints[i]

		if(i == HDPT_TREADS && (!H || H.health <= 0)) //Treads not installed or broken
			var/image/I = image(icon, icon_state = "damaged_hardpt_[i]")
			overlays += I
			continue

		if(H)
			var/image/I = H.get_icon_image(0, 0, dir)
			overlays += I

		if(damaged_hps.Find(i))
			var/image/I = image(icon, icon_state = "damaged_hardpt_[i]")
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
	..()

//Tramplin' time, but other than that identical
/obj/vehicle/multitile/hitbox/cm_armored/Bump(var/atom/A)
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
		T = get_step(T, pick(cardinal))
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

/mob/living/carbon/Xenomorph/Queen/tank_collision(obj/vehicle/multitile/hitbox/cm_armored/C, facing, turf/T, turf/temp)
	if(lying || loc == C.loc)
		return ..()
	temp = get_step(T, facing)
	T = temp
	T = get_step(T, pick(cardinal))
	throw_at(T, 2, 2, C, 0)
	visible_message("<span class='danger'>[C] bumps into [src], pushing [p_them()] away!</span>", "<span class='danger'>[C] bumps into you!</span>")

/mob/living/carbon/Xenomorph/Crusher/tank_collision(obj/vehicle/multitile/hitbox/cm_armored/C, facing, turf/T, turf/temp)
	if(lying || loc == C.loc)
		return ..()
	temp = get_step(T, facing)
	T = temp
	T = get_step(T, pick(cardinal))
	throw_at(T, 2, 2, C, 0)
	visible_message("<span class='danger'>[C] bumps into [src], pushing [p_them()] away!</span>", "<span class='danger'>[C] bumps into you!</span>")

/mob/living/carbon/Xenomorph/Larva/tank_collision(obj/vehicle/multitile/hitbox/cm_armored/C, facing, turf/T, turf/temp)
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
		if(SP.health > 0)
			damage = 60
			tank_damage = 0

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
		if(SP.health > 0)
			damage = 60
			tank_damage = 0

	take_damage(damage)
	CA.take_damage_type(tank_damage, "blunt", src)
	if(world.time > C.lastsound + 1 SECONDS)
		visible_message("<span class='danger'>[C.root] rams into \the [src]!</span>")
		playsound(src, 'sound/effects/metal_crash.ogg', 35)
		C.lastsound = world.time

/obj/structure/tank_collision(obj/vehicle/multitile/hitbox/cm_armored/C, facing, turf/T, turf/temp)
	var/obj/vehicle/multitile/root/cm_armored/tank/CA = C.root
	var/damage = 30
	var/tank_damage = 2

	if(facing == CA.old_dir && istype(CA.hardpoints[HDPT_ARMOR], /obj/item/hardpoint/armor/snowplow) ) //Snowplow eliminates collision damage, and doubles damage dealt if we're facing the thing we're crushing
		var/obj/item/hardpoint/armor/snowplow/SP = CA.hardpoints[HDPT_ARMOR]
		if(SP.health > 0)
			damage = 60
			tank_damage = 0

	take_damage(damage)
	CA.take_damage_type(tank_damage, "blunt", src)
	if(world.time > C.lastsound + 1 SECONDS)
		visible_message("<span class='danger'>[C.root] crushes \the [src]!</span>")
		playsound(src, 'sound/effects/metal_crash.ogg', 35)
		C.lastsound = world.time


/obj/vehicle/multitile/hitbox/cm_armored/Move(atom/A, direction)

	for(var/mob/living/M in get_turf(src))
		M.tank_collision(src)

	. = ..()

	if(.)
		for(var/mob/living/M in get_turf(A))
			M.tank_collision(src)

//Can't hit yourself with your own bullet
/obj/vehicle/multitile/hitbox/cm_armored/get_projectile_hit_chance(var/obj/item/projectile/P)
	if(P.firer == root) //Don't hit our own hitboxes
		return 0

	. = ..(P)

//For the next few, we're just tossing the handling up to the rot object
/obj/vehicle/multitile/hitbox/cm_armored/bullet_act(var/obj/item/projectile/P)
	return root.bullet_act(P)

/obj/vehicle/multitile/hitbox/cm_armored/ex_act(var/severity)
	return root.ex_act(severity)

/obj/vehicle/multitile/hitbox/cm_armored/attackby(var/obj/item/O, var/mob/user)
	return root.attackby(O, user)

/obj/vehicle/multitile/hitbox/cm_armored/attack_alien(var/mob/living/carbon/Xenomorph/M, var/dam_bonus)
	return root.attack_alien(M, dam_bonus)

//A bit icky, but basically if you're adjacent to the tank hitbox, you are then adjacent to the root object
/obj/vehicle/multitile/root/cm_armored/Adjacent(var/atom/A)
	for(var/i in linked_objs)
		var/obj/vehicle/multitile/hitbox/cm_armored/H = linked_objs[i]
		if(!H) continue
		if(get_dist(H, A) <= 1) return 1 //Using get_dist() to avoid hidden code that recurs infinitely here
	. = ..()

//Returns the ratio of damage to take, just a housekeeping thing
/obj/vehicle/multitile/root/cm_armored/proc/get_dmg_multi(var/type)
	if(!dmg_multipliers.Find(type))
		return 0
	return dmg_multipliers[type] * dmg_multipliers["all"]

//Generic proc for taking damage
//ALWAYS USE THIS WHEN INFLICTING DAMAGE TO THE VEHICLES
/obj/vehicle/multitile/root/cm_armored/proc/take_damage_type(damage, type, atom/attacker)
	for(var/i in hardpoints)
		var/obj/item/hardpoint/HP = hardpoints[i]
		if(!istype(HP))
			continue
		HP.health -= damage * dmg_distribs[i] * get_dmg_multi(type)

	if(istype(attacker, /mob))
		var/mob/M = attacker
		log_attack("[src] took [damage] [type] damage from [M] ([M.client ? M.client.ckey : "disconnected"]).")
	else
		log_attack("[src] took [damage] [type] damage from [attacker].")

/obj/vehicle/multitile/root/cm_armored/get_projectile_hit_chance(var/obj/item/projectile/P)
	if(P.firer == src) //Don't hit our own hitboxes
		return 0

	. = ..(P)

//Differentiates between damage types from different bullets
//Applies a linear transformation to bullet damage that will generally decrease damage done
/obj/vehicle/multitile/root/cm_armored/bullet_act(var/obj/item/projectile/P)

	var/dam_type = "bullet"

	if(P.ammo.flags_ammo_behavior & AMMO_XENO_ACID) dam_type = "acid"

	take_damage_type(P.damage * (0.75 + P.ammo.penetration/100), dam_type, P.firer)

	healthcheck()

//severity 1.0 explosions never really happen so we're gonna follow everyone else's example
/obj/vehicle/multitile/root/cm_armored/ex_act(var/severity)

	switch(severity)
		if(1.0)
			take_damage_type(rand(250, 350), "explosive") //Devastation level explosives are anti-tank and do real damage.
			take_damage_type(rand(20, 40), "slash")

		if(2.0)
			take_damage_type(rand(30, 40), "explosive") //Heavy explosions do some damage, but are largely deferred by the armour/bulk.
			take_damage_type(rand(10, 15), "slash")

	healthcheck() //Tanks/armoured vehicles don't really take damage from light explosions, such as frag grenades. Also makes using the LTB more viable due to crush/stun chaining being removed.

//Honestly copies some code from the Xeno files, just handling some special cases
/obj/vehicle/multitile/root/cm_armored/attack_alien(mob/living/carbon/Xenomorph/M, dam_bonus)

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
		return 0

	else
		playsound(loc, "alien_claw_metal", 25, 1)

	if(M.stealth_router(HANDLE_STEALTH_CHECK)) //Cancel stealth if we have it due to aggro.
		M.stealth_router(HANDLE_STEALTH_CODE_CANCEL)

	M.visible_message("<span class='danger'>\The [M] slashes [src]!</span>", \
	"<span class='danger'>You slash [src]!</span>")

	take_damage_type(damage * ( (isxenoravager(M)) ? 2 : 1 ), "slash", M) //Ravs do a bitchin double damage

	healthcheck()

//Special case for entering the vehicle without using the verb
/obj/vehicle/multitile/root/cm_armored/attack_hand(var/mob/user)

	if(user.loc == entrance.loc)
		handle_player_entrance(user)
		return

	. = ..()

/obj/vehicle/multitile/root/cm_armored/Entered(var/atom/movable/A)
	if(istype(A, /obj) && !istype(A, /obj/item/ammo_magazine/tank))
		A.forceMove(src.loc)
		return

	return ..()

//Need to take damage from crushers, probably too little atm
/obj/vehicle/multitile/root/cm_armored/Bumped(var/atom/A)
	..()

	if(istype(A, /mob/living/carbon/Xenomorph/Crusher))

		var/mob/living/carbon/Xenomorph/Crusher/C = A

		if(C.charge_speed < CHARGE_SPEED_MAX/(1.1)) //Arbitrary ratio here, might want to apply a linear transformation instead
			return

		take_damage_type(C.charge_speed * CRUSHER_CHARGE_TANK_MULTI, "blunt", C)

//Redistributes damage ratios based off of what things are attached (no armor means the armor doesn't mitigate any damage)
/obj/vehicle/multitile/root/cm_armored/proc/update_damage_distribs()
	dmg_distribs = armorvic_dmg_distributions.Copy() //Assume full installs
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
/obj/vehicle/multitile/root/cm_armored/attackby(var/obj/item/O, var/mob/user)
	. = ..()

	if(istype(O, /obj/item/hardpoint)) //Are we trying to install stuff?
		var/obj/item/hardpoint/HP = O
		install_hardpoint(HP, user)
		return

	if(istype(O, /obj/item/ammo_magazine)) //Are we trying to reload?
		var/obj/item/ammo_magazine/AM = O
		handle_ammomag_attackby(AM, user)
		return

	if(iswelder(O) || iswrench(O)) //Are we trying to repair stuff?
		handle_hardpoint_repair(O, user)
		update_damage_distribs()
		return

	if(iscrowbar(O)) //Are we trying to remove stuff?
		uninstall_hardpoint(O, user)
		return

	if(!(O.flags_item & NOBLUDGEON))
		take_damage_type(O.force * 0.05, "blunt", user) //Melee weapons from people do very little damage


/obj/vehicle/multitile/root/cm_armored/proc/handle_hardpoint_repair(var/obj/item/O, var/mob/user)

	//Need to the what the hell you're doing
	if(user.mind?.cm_skills?.engineer && user.mind.cm_skills.engineer < SKILL_ENGINEER_MT)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out what to do with [O] on the [src].</span>",
		"<span class='notice'>You fumble around figuring out what to do with [O] on the [src].</span>")
		var/fumbling_time = 50 * (SKILL_ENGINEER_MT - user.mind.cm_skills.engineer)
		if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD))
			return

	if(!damaged_hps.len)
		to_chat(user, "<span class='notice'>All of the hardpoints are in working order.</span>")
		return

	//Pick what to repair
	var/slot = input("Select a slot to try and repair") in damaged_hps

	var/obj/item/hardpoint/old = hardpoints[slot] //Is there something there already?

	if(old) //If so, fuck you get it outta here
		to_chat(user, "<span class='warning'>Please remove the attached hardpoint module first.</span>")
		return

	//Determine how many 3 second intervals to wait and if you have the right tool
	var/num_delays = 1
	switch(slot)
		if(HDPT_PRIMARY)
			num_delays = 5
			if(!iswelder(O))
				to_chat(user, "<span class='warning'>That's the wrong tool. Use a welder.</span>")
				return
			var/obj/item/tool/weldingtool/WT = O
			if(!WT.isOn())
				to_chat(user, "<span class='warning'>You need to light your [WT] first.</span>")
				return
			WT.remove_fuel(num_delays, user)

		if(HDPT_SECDGUN)
			num_delays = 3
			if(!iswrench(O))
				to_chat(user, "<span class='warning'>That's the wrong tool. Use a wrench.</span>")
				return

		if(HDPT_SUPPORT)
			num_delays = 2
			if(!iswrench(O))
				to_chat(user, "<span class='warning'>That's the wrong tool. Use a wrench.</span>")
				return

		if(HDPT_ARMOR)
			num_delays = 10
			if(!iswelder(O))
				to_chat(user, "<span class='warning'>That's the wrong tool. Use a welder.</span>")
				return
			var/obj/item/tool/weldingtool/WT = O
			if(!WT.isOn())
				to_chat(user, "<span class='warning'>You need to light your [WT] first.</span>")
				return
			WT.remove_fuel(num_delays, user)

	user.visible_message("<span class='notice'>[user] starts repairing the [slot] slot on [src].</span>",
		"<span class='notice'>You start repairing the [slot] slot on the [src].</span>")

	if(!do_after(user, 30*num_delays, TRUE, num_delays, BUSY_ICON_FRIENDLY))
		user.visible_message("<span class='notice'>[user] stops repairing the [slot] slot on [src].</span>",
			"<span class='notice'>You stop repairing the [slot] slot on the [src].</span>")
		return

	if(!Adjacent(user))
		user.visible_message("<span class='notice'>[user] stops repairing the [slot] slot on [src].</span>",
			"<span class='notice'>You stop repairing the [slot] slot on the [src].</span>")
		return

	user.visible_message("<span class='notice'>[user] repairs the [slot] slot on the [src].</span>",
		"<span class='notice'>You repair the [slot] slot on [src].</span>")

	damaged_hps -= slot //We repaired it, good job

	update_icon()

//Relaoding stuff, pretty bare-bones and basic
/obj/vehicle/multitile/root/cm_armored/proc/handle_ammomag_attackby(var/obj/item/ammo_magazine/AM, var/mob/user)

	//No skill checks for reloading
	//Maybe I should delineate levels of skill for reloading, installation, and repairs?
	//That would make it easier to differentiate between the two for skills
	//Instead of using MT skills for these procs and TC skills for operation
	//Oh but wait then the MTs would be able to drive fuck that
	var/slot = input("Select a slot to try and refill") in hardpoints

	var/obj/item/hardpoint/HP = hardpoints[slot]

	if(!HP)
		to_chat(user, "<span class='warning'>There is nothing installed on that slot.</span>")
		return

	HP.try_add_clip(AM, user)

//Putting on hardpoints
//Similar to repairing stuff, down to the time delay
/obj/vehicle/multitile/root/cm_armored/proc/install_hardpoint(obj/item/hardpoint/HP, mob/user)

	if(user.mind?.cm_skills?.engineer < SKILL_ENGINEER_MT)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out what to do with [HP] on the [src].</span>",
		"<span class='notice'>You fumble around figuring out what to do with [HP] on the [src].</span>")
		var/fumbling_time = 50 * ( SKILL_ENGINEER_MT - user.mind.cm_skills.engineer )
		if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD)) return

	if(damaged_hps.Find(HP.slot))
		to_chat(user, "<span class='warning'>You need to fix the hardpoint first.</span>")
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

	if(!do_after(user, 30*num_delays, TRUE, num_delays, BUSY_ICON_FRIENDLY))
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

	if(user.mind?.cm_skills?.engineer < SKILL_ENGINEER_MT)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out what to do with [O] on the [src].</span>",
		"<span class='notice'>You fumble around figuring out what to do with [O] on the [src].</span>")
		var/fumbling_time = 50 * ( SKILL_ENGINEER_MT - user.mind.cm_skills.engineer )
		if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD))
			return

	var/slot = input("Select a slot to try and remove") in hardpoints

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

	if(!do_after(user, 30*num_delays, TRUE, num_delays, BUSY_ICON_FRIENDLY))
		user.visible_message("<span class='warning'>[user] stops removing \the [old] on [src].</span>", "<span class='warning'>You stop removing \the [old] on [src].</span>")
		return
	if(!old)
		return

	user.visible_message("<span class='notice'>[user] removes \the [old] on [src].</span>", "<span class='notice'>You remove \the [old] on [src].</span>")

	remove_hardpoint(old, user)

//General proc for putting on hardpoints
//ALWAYS CALL THIS WHEN ATTACHING HARDPOINTS
/obj/vehicle/multitile/root/cm_armored/proc/add_hardpoint(var/obj/item/hardpoint/HP, var/mob/user)
	if(!istype(HP))
		return
	HP.owner = src
	if(HP.health > 0)
		HP.apply_buff()
	HP.loc = src

	hardpoints[HP.slot] = HP
	update_damage_distribs()
	update_icon()

//General proc for taking off hardpoints
//ALWAYS CALL THIS WHEN REMOVING HARDPOINTS
/obj/vehicle/multitile/root/cm_armored/proc/remove_hardpoint(var/obj/item/hardpoint/old, var/mob/user)
	old.loc = user ? user.loc : entrance.loc
	old.remove_buff()
	if(old.health <= 0)
		qdel(old)

	hardpoints[old.slot] = null
	update_damage_distribs()
	update_icon()
