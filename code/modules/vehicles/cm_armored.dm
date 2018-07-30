

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

/client/proc/remove_players_from_vic()
	set name = "Remove All From Tank"
	set category = "Admin"

	for(var/obj/vehicle/multitile/root/cm_armored/CA in view())
		CA.remove_all_players()
		log_admin("[src] forcibly removed all players from [CA]")
		message_admins("[src] forcibly removed all players from [CA]")

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

/obj/vehicle/multitile/root/cm_armored/Dispose()
	for(var/i in linked_objs)
		var/obj/O = linked_objs[i]
		if(O == src) continue
		cdel(O, 1) //Delete all of the hitboxes etc

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

//No one but the gunner can gun
//And other checks to make sure you aren't breaking the law
/obj/vehicle/multitile/root/cm_armored/tank/handle_click(var/mob/living/user, var/atom/A, var/list/mods)

	if(!can_use_hp(user)) return

	if(!hardpoints.Find(active_hp))
		user << "<span class='warning'>Please select an active hardpoint first.</span>"
		return

	var/obj/item/hardpoint/HP = hardpoints[active_hp]

	if(!HP)
		return

	if(!HP.is_ready())
		return

	if(!HP.firing_arc(A))
		user << "<span class='warning'>The target is not within your firing arc.</span>"
		return

	HP.active_effect(get_turf(A))

//Used by the gunner to swap which module they are using
//e.g. from the minigun to the smoke launcher
//Only the active hardpoint module can be used
/obj/vehicle/multitile/root/cm_armored/verb/switch_active_hp()
	set name = "Change Active Weapon"
	set category = "Object"
	set src in view(0)

	if(!can_use_hp(usr))
		return

	var/list/slots = get_activatable_hardpoints()

	if(!slots.len)
		usr << "<span class='warning'>All of the modules can't be activated or are broken.</span>"
		return

	var/slot = input("Select a slot.") in slots

	var/obj/item/hardpoint/HP = hardpoints[slot]
	if(!HP)
		usr << "<span class='warning'>There's nothing installed on that hardpoint.</span>"

	active_hp = slot
	usr << "<span class='notice'>You select the [slot] slot.</span>"
	if(isliving(usr))
		var/mob/living/M = usr
		M.set_interaction(src)

/obj/vehicle/multitile/root/cm_armored/verb/reload_hp()
	set name = "Reload Active Weapon"
	set category = "Object"
	set src in view(0)

	if(!can_use_hp(usr)) return

	//TODO: make this a proc so I don't keep repeating this code
	var/list/slots = get_activatable_hardpoints()

	if(!slots.len)
		usr << "<span class='warning'>All of the modules can't be reloaded or are broken.</span>"
		return

	var/slot = input("Select a slot.") in slots

	var/obj/item/hardpoint/HP = hardpoints[slot]
	if(!HP.backup_clips.len)
		usr << "<span class='warning'>That module has no remaining backup clips.</span>"
		return

	var/obj/item/ammo_magazine/A = HP.backup_clips[1] //LISTS START AT 1 REEEEEEEEEEEE
	if(!A)
		usr << "<span class='danger'>Something went wrong! PM a staff member! Code: T_RHPN</span>"
		return

	usr << "<span class='notice'>You begin reloading the [slot] module.</span>"

	sleep(20)

	HP.ammo.Move(entrance.loc)
	HP.ammo.update_icon()
	HP.ammo = A
	HP.backup_clips.Remove(A)

	usr << "<span class='notice'>You reload the [slot] module.</span>"


/obj/vehicle/multitile/root/cm_armored/proc/get_activatable_hardpoints()
	var/list/slots = list()
	for(var/slot in hardpoints)
		var/obj/item/hardpoint/HP = hardpoints[slot]
		if(!HP) continue
		if(HP.health <= 0) continue
		if(!HP.is_activatable) continue
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
			H.dir = dir
			H.root = src
			linked_objs[C] = H

/obj/vehicle/multitile/root/cm_armored/load_entrance_marker(var/datum/coords/rel_pos)

	entrance = new(locate(src.x + rel_pos.x_pos, src.y + rel_pos.y_pos, src.z))
	entrance.master = src
	linked_objs[rel_pos] = entrance

//Returns 1 or 0 if the slot in question has a broken installed hardpoint or not
/obj/vehicle/multitile/root/cm_armored/proc/is_slot_damaged(var/slot)
	var/obj/item/hardpoint/HP = hardpoints[slot]

	if(!HP) return 0

	if(HP.health <= 0) return 1

//Normal examine() but tells the player what is installed and if it's broken
/obj/vehicle/multitile/root/cm_armored/examine(var/mob/user)
	..()
	for(var/i in hardpoints)
		var/obj/item/hardpoint/HP = hardpoints[i]
		if(!HP)
			user << "There is nothing installed on the [i] hardpoint slot."
		else
			user << "There is a [HP.health <= 0 ? "broken" : "working"] [HP] installed on the [i] hardpoint slot."

//Special armored vic healthcheck that mainly updates the hardpoint states
/obj/vehicle/multitile/root/cm_armored/healthcheck()
	health = maxhealth //The tank itself doesn't take damage
	var/i
	var/remove_person = 1 //Whether or not to call handle_all_modules_broken()
	for(i in hardpoints)
		var/obj/item/hardpoint/H = hardpoints[i]
		if(!H) continue
		if(H.health <= 0)
			H.remove_buff()
			if(H.slot != HDPT_TREADS) damaged_hps |= H.slot //Not treads since their broken module overlay is the same as the broken hardpoint overlay
		else remove_person = 0 //if something exists but isnt broken

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

//If something want to delete this, it's probably either an admin or the shuttle
//If it's an admin, they want to disable this
//If it's the shuttle, it should do damage
//If fully repaired and moves at least once, the broken hitboxes will respawn according to multitile.dm
/obj/vehicle/multitile/hitbox/cm_armored/Dispose()
	var/obj/vehicle/multitile/root/cm_armored/C = root
	if(C) C.take_damage_type(1000000, "abstract")
	..()

//Tramplin' time, but other than that identical
/obj/vehicle/multitile/hitbox/cm_armored/Bump(var/atom/A)
	. = ..()
	if(isliving(A))
		if (isXenoDefender(A))
			var/mob/living/carbon/Xenomorph/X = A
			if (X.fortify)
				return

		var/mob/living/M = A
		M.KnockDown(10, 1)
		M.apply_damage(7 + rand(0, 5), BRUTE)
		M.visible_message("<span class='danger'>[src] runs over [M]!</span>", "<span class='danger'>[src] runs you over! Get out of the way!</span>")
		var/obj/vehicle/multitile/root/cm_armored/CA = root
		var/list/slots = CA.get_activatable_hardpoints()
		for(var/slot in slots)
			var/obj/item/hardpoint/H = CA.hardpoints[slot]
			if(!H) continue
			H.livingmob_interact(M)
	else if(istype(A, /obj/structure/fence))
		var/obj/structure/fence/F = A
		F.visible_message("<span class='danger'>[root] smashes through [F]!</span>")
		F.health = 0
		F.healthcheck()
	else if(istype(A, /turf/closed/wall))
		var/turf/closed/wall/W = A
		W.take_damage(30)
		var/obj/vehicle/multitile/root/cm_armored/CA = root
		CA.take_damage_type(10, "blunt", W)
		playsound(W, 'sound/effects/metal_crash.ogg', 35)
	else if(istype(A, /obj/structure/mineral_door/resin))
		var/obj/structure/mineral_door/resin/R = A
		R.health = 0
		R.healthcheck()
	else if(istype(A, /obj/structure/table))
		var/obj/structure/table/T = A
		T.visible_message("<span class='danger'>[root] crushes [T]!</span>")
		T.destroy(1)
	else if(istype(A, /obj/structure/girder))
		var/obj/structure/girder/G = A
		G.dismantle()
		var/obj/vehicle/multitile/root/cm_armored/CA = root
		CA.take_damage_type(10, "blunt", G)
		playsound(G, 'sound/effects/metal_crash.ogg', 35)

/obj/vehicle/multitile/hitbox/cm_armored/Move(var/atom/A, var/direction)

	for(var/mob/living/M in get_turf(src))
		M.sleeping = 5 //Not 0, they just got driven over by a giant ass whatever and that hurts

	. = ..()

	if(.)
		for(var/mob/living/M in get_turf(A))
			//I don't call Bump() otherwise that would encourage trampling for infinite unpunishable damage
			M.sleeping = 1e7 //Maintain their lying-down-ness

/obj/vehicle/multitile/hitbox/cm_armored/Uncrossed(var/atom/movable/A)
	if(isliving(A))
		var/mob/living/M = A
		M.sleeping = 5

	return ..()

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
	if(!dmg_multipliers.Find(type)) return 0
	return dmg_multipliers[type] * dmg_multipliers["all"]

//Generic proc for taking damage
//ALWAYS USE THIS WHEN INFLICTING DAMAGE TO THE VEHICLES
/obj/vehicle/multitile/root/cm_armored/proc/take_damage_type(var/damage, var/type, var/atom/attacker)
	var/i
	for(i in hardpoints)
		var/obj/item/hardpoint/HP = hardpoints[i]
		if(!istype(HP)) continue
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
			take_damage_type(rand(100, 150), "explosive")
			take_damage_type(rand(20, 40), "slash")

		if(2.0)
			take_damage_type(rand(60,80), "explosive")
			take_damage_type(rand(10, 15), "slash")

		if(3.0)
			take_damage_type(rand(20, 25), "explosive")

	healthcheck()

//Honestly copies some code from the Xeno files, just handling some special cases
/obj/vehicle/multitile/root/cm_armored/attack_alien(var/mob/living/carbon/Xenomorph/M, var/dam_bonus)

	var/damage = rand(M.melee_damage_lower, M.melee_damage_upper) + dam_bonus

	//Frenzy auras stack in a way, then the raw value is multipled by two to get the additive modifier
	if(M.frenzy_aura > 0)
		damage += (M.frenzy_aura * 2)

	M.animation_attack_on(src)

	//Somehow we will deal no damage on this attack
	if(!damage)
		playsound(M.loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
		M.animation_attack_on(src)
		M.visible_message("<span class='danger'>\The [M] lunges at [src]!</span>", \
		"<span class='danger'>You lunge at [src]!</span>")
		return 0

	M.visible_message("<span class='danger'>\The [M] slashes [src]!</span>", \
	"<span class='danger'>You slash [src]!</span>")

	take_damage_type(damage * ( (M.caste == "Ravager") ? 2 : 1 ), "slash", M) //Ravs do a bitchin double damage

	healthcheck()

//Special case for entering the vehicle without using the verb
/obj/vehicle/multitile/root/cm_armored/attack_hand(var/mob/user)

	if(user.a_intent == "hurt")
		handle_harm_attack(user)
		return

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

		if(C.charge_speed < C.charge_speed_max/(1.1)) //Arbitrary ratio here, might want to apply a linear transformation instead
			return

		take_damage_type(100, "blunt", C)

//Redistributes damage ratios based off of what things are attached (no armor means the armor doesn't mitigate any damage)
/obj/vehicle/multitile/root/cm_armored/proc/update_damage_distribs()
	dmg_distribs = armorvic_dmg_distributions.Copy() //Assume full installs
	for(var/slot in hardpoints)
		var/obj/item/hardpoint/HP = hardpoints[slot]
		if(!HP) dmg_distribs[slot] = 0.0 //Remove empty slots' damage mitigation
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

	if(istype(O, /obj/item/hardpoint)) //Are we trying to install stuff?
		var/obj/item/hardpoint/HP = O
		install_hardpoint(HP, user)
		update_damage_distribs()
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
		update_damage_distribs()
		return

	take_damage_type(O.force * 0.05, "blunt", user) //Melee weapons from people do very little damage

	. = ..()

/obj/vehicle/multitile/root/cm_armored/proc/handle_hardpoint_repair(var/obj/item/O, var/mob/user)

	//Need to the what the hell you're doing
	if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_MT)
		user << "<span class='warning'>You don't know what to do with [O] on [src].</span>"
		return

	if(!damaged_hps.len)
		user << "<span class='notice'>All of the hardpoints are in working order.</span>"
		return

	//Pick what to repair
	var/slot = input("Select a slot to try and repair") in damaged_hps

	var/obj/item/hardpoint/old = hardpoints[slot] //Is there something there already?

	if(old) //If so, fuck you get it outta here
		user << "<span class='warning'>Please remove the attached hardpoint module first.</span>"
		return

	//Determine how many 3 second intervals to wait and if you have the right tool
	var/num_delays = 1
	switch(slot)
		if(HDPT_PRIMARY)
			num_delays = 5
			if(!iswelder(O))
				user << "<span class='warning'>That's the wrong tool. Use a welder.</span>"
				return
			var/obj/item/tool/weldingtool/WT = O
			if(!WT.isOn())
				user << "<span class='warning'>You need to light your [WT] first.</span>"
				return
			WT.remove_fuel(num_delays, user)

		if(HDPT_SECDGUN)
			num_delays = 3
			if(!iswrench(O))
				user << "<span class='warning'>That's the wrong tool. Use a wrench.</span>"
				return

		if(HDPT_SUPPORT)
			num_delays = 2
			if(!iswrench(O))
				user << "<span class='warning'>That's the wrong tool. Use a wrench.</span>"
				return

		if(HDPT_ARMOR)
			num_delays = 10
			if(!iswelder(O))
				user << "<span class='warning'>That's the wrong tool. Use a welder.</span>"
				return
			var/obj/item/tool/weldingtool/WT = O
			if(!WT.isOn())
				user << "<span class='warning'>You need to light your [WT] first.</span>"
				return
			WT.remove_fuel(num_delays, user)

	user.visible_message("<span class='notice'>[user] starts repairing the [slot] slot on [src].</span>",
		"<span class='notice'>You start repairing the [slot] slot on [src].</span>")

	if(!do_after(user, 30*num_delays, TRUE, num_delays, BUSY_ICON_FRIENDLY))
		user.visible_message("<span class='notice'>[user] stops repairing the [slot] slot on [src].</span>",
			"<span class='notice'>You stop repairing the [slot] slot on [src].</span>")
		return

	if(!Adjacent(user))
		user.visible_message("<span class='notice'>[user] stops repairing the [slot] slot on [src].</span>",
			"<span class='notice'>You stop repairing the [slot] slot on [src].</span>")
		return

	user.visible_message("<span class='notice'>[user] repairs the [slot] slot on [src].</span>",
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
		user << "<span class='warning'>There is nothing installed on that slot.</span>"
		return

	HP.try_add_clip(AM, user)

//Putting on hardpoints
//Similar to repairing stuff, down to the time delay
/obj/vehicle/multitile/root/cm_armored/proc/install_hardpoint(var/obj/item/hardpoint/HP, var/mob/user)

	if(!user.mind || !(!user.mind.cm_skills || user.mind.cm_skills.engineer >= SKILL_ENGINEER_MT))
		user << "<span class='warning'>You don't know what to do with [HP] on [src].</span>"
		return

	if(damaged_hps.Find(HP.slot))
		user << "<span class='warning'>You need to fix the hardpoint first.</span>"
		return

	var/obj/item/hardpoint/old = hardpoints[HP.slot]

	if(old)
		user << "<span class='warning'>Remove the previous hardpoint module first.</span>"
		return

	user.visible_message("<span class='notice'>[user] begins installing [HP] on the [HP.slot] hardpoint slot on [src].</span>",
		"<span class='notice'>You begin installing [HP] on the [HP.slot] hardpoint slot on [src].</span>")

	var/num_delays = 1

	switch(HP.slot)
		if(HDPT_PRIMARY) num_delays = 5
		if(HDPT_SECDGUN) num_delays = 3
		if(HDPT_SUPPORT) num_delays = 2
		if(HDPT_ARMOR) num_delays = 10
		if(HDPT_TREADS) num_delays = 7

	if(!do_after(user, 30*num_delays, TRUE, num_delays, BUSY_ICON_FRIENDLY))
		user.visible_message("<span class='warning'>[user] stops installing \the [HP] on [src].</span>", "<span class='warning'>You stop installing \the [HP] on [src].</span>")
		return

	user.visible_message("<span class='notice'>[user] installs \the [HP] on [src].</span>", "<span class='notice'>You install \the [HP] on [src].</span>")

	user.temp_drop_inv_item(HP, 0)

	add_hardpoint(HP, user)

//User-orientated proc for taking of hardpoints
//Again, similar to the above ones
/obj/vehicle/multitile/root/cm_armored/proc/uninstall_hardpoint(var/obj/item/O, var/mob/user)

	if(!user.mind || !(!user.mind.cm_skills || user.mind.cm_skills.engineer >= SKILL_ENGINEER_MT))
		user << "<span class='warning'>You don't know what to do with [O] on [src].</span>"
		return

	var/slot = input("Select a slot to try and remove") in hardpoints

	var/obj/item/hardpoint/old = hardpoints[slot]

	if(!old)
		user << "<span class='warning'>There is nothing installed there.</span>"
		return

	user.visible_message("<span class='notice'>[user] begins removing [old] on the [old.slot] hardpoint slot on [src].</span>",
		"<span class='notice'>You begin removing [old] on the [old.slot] hardpoint slot on [src].</span>")

	var/num_delays = 1

	switch(slot)
		if(HDPT_PRIMARY) num_delays = 5
		if(HDPT_SECDGUN) num_delays = 3
		if(HDPT_SUPPORT) num_delays = 2
		if(HDPT_ARMOR) num_delays = 10
		if(HDPT_TREADS) num_delays = 7

	if(!do_after(user, 30*num_delays, TRUE, num_delays, BUSY_ICON_FRIENDLY))
		user.visible_message("<span class='warning'>[user] stops removing \the [old] on [src].</span>", "<span class='warning'>You stop removing \the [old] on [src].</span>")
		return

	user.visible_message("<span class='notice'>[user] removes \the [old] on [src].</span>", "<span class='notice'>You remove \the [old] on [src].</span>")

	remove_hardpoint(old, user)

//General proc for putting on hardpoints
//ALWAYS CALL THIS WHEN ATTACHING HARDPOINTS
/obj/vehicle/multitile/root/cm_armored/proc/add_hardpoint(var/obj/item/hardpoint/HP, var/mob/user)

	HP.owner = src
	HP.apply_buff()
	HP.loc = src

	hardpoints[HP.slot] = HP

	update_icon()

//General proc for taking off hardpoints
//ALWAYS CALL THIS WHEN REMOVING HARDPOINTS
/obj/vehicle/multitile/root/cm_armored/proc/remove_hardpoint(var/obj/item/hardpoint/old, var/mob/user)
	if(user)
		old.loc = user.loc
	else
		old.loc = entrance.loc
	old.remove_buff()
	if(old.health <= 0)
		cdel(old)

	hardpoints[old.slot] = null
	update_icon()
