/obj/item/weapon/gun
	name = "gun"
	desc = "Its a gun. It's pretty terrible, though."
	icon = 'icons/obj/gun.dmi'
	icon_state = ""
	var/icon_wielded 	= null
	var/icon_empty 		= null
	var/muzzle_flash 	= "muzzle_flash"
	item_state = "gun"
	matter = list("metal" = 75000)
	origin_tech = "combat=1" //Guns generally have their own unique levels.
	w_class 	= 3.0
	throwforce 	= 5
	throw_speed = 4
	throw_range = 5
	force 		= 5.0
	attack_verb = list("struck", "hit", "bashed")
	icon_action_button = null //Adds it to the quick-icon list

	var/fire_sound 		= 'sound/weapons/Gunshot.ogg'
	var/unload_sound 	= 'sound/weapons/flipblade.ogg'
	var/empty_sound 	= 'sound/weapons/smg_empty_alarm.ogg'
	var/reload_sound 	= null //We don't want these for guns that don't have them.
	var/cocked_sound 	= null

	var/datum/ammo/ammo = null //How the bullet will behave once it leaves the gun, also used for basic bullet damage and effects, etc.
	var/default_ammo 	= null //For stuff that doesn't use mags, we default to this.
	var/obj/item/projectile/in_chamber = null //What is currently in the chamber. Most guns will want something in the chamber upon creation.
	/*Ammo mags may or may not be internal, though the difference is a few additional variables. If they are not internal, don't call
	on those unique vars. This is done for quicker pathing. Just keep in mind most mags aren't internal, though some are.*/
	var/obj/item/ammo_magazine/internal/current_mag = null
	var/mag_type 		= null  //The default magazine path loaded into a projectile weapon for reverse lookups. Leave this null to do your own thing.
	var/type_of_casings = "bullet" //bullets by default, but can be "shell"
	var/eject_casings 	= 0 //Does not by default.

	//Basic stats.
	var/accuracy 		= 0 //This is applied to the bullet when fired, since attachments can influence it.
	var/damage 			= 0 //Flat bonus/penalty to bullet damage due to the gun itself. Applied when the bullet is created. Attachment bonuses are applied when fired.
	var/recoil 			= 0 //Screen shake when the weapon is fired.
	var/fire_delay 		= 6 //For regular shots, how long to wait before firing again.
	var/last_fired 		= 0 //When it was last fired, related to world.time.

	//Burst fire.
	var/burst_amount 	= 1 //How many shots can the weapon shoot in burst? Anything less than 2 and you cannot toggle burst.
	var/burst_delay 	= 0 //The delay in between shots. Lower = less delay = faster.
	var/extra_delay 	= 0 //When burst-firing, this number is extra time before the weapon can fire again. Depends on number of rounds fired.

	//Targeting.
	var/tmp/list/mob/living/target //List of who yer targeting.
	var/tmp/mob/living/last_moved_mob //Used to fire faster at more than one person.
	var/tmp/lock_time 		= -100
	var/automatic 			= 0 //Used to determine if you can target multiple people.
	var/tmp/told_cant_shoot = 0 //So that it doesn't spam them with the fact they cannot hit them.
	var/firerate 			= 0 	//0 for keep shooting until aim is lowered
						//1 for one bullet after tarrget moves and aim is lowered
	//Attachments.
	var/obj/item/attachable/muzzle 	= null //Attachable slots. Only one item per slot.
	var/obj/item/attachable/rail 	= null
	var/obj/item/attachable/under 	= null
	var/obj/item/attachable/stock 	= null
	//Stocks do not have their own offsets, use under instead. I could change this in the future, for now it's not needed. ~N.
	var/attachable_offset[] = null //Is a list, see examples of from the other filse. Initiated on New() because lists don't initial() properly.
	var/obj/item/attachable/active_attachable = null //This will link to one of the above four, or remain null.

	flags 			 = FPRINT | CONDUCT
	var/gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK


//----------------------------------------------------------
				//				    \\
				// NECESSARY PROCS  \\
				//					\\
				//					\\
//----------------------------------------------------------

	New()
		..()
		var/magpath = mag_type ? mag_type : null
		if(magpath)
			current_mag = new magpath(src)
			if(current_mag.default_ammo) ammo = ammo_list[current_mag.default_ammo]
			else 						 ammo = ammo_list["default bullet"] //This should never happen, adding is a precaution.
		else							 ammo = ammo_list[default_ammo] //If they don't have a mag, they fire off their own thing.

		if(burst_delay == 0 && burst_amount > 0) burst_delay = round(2 * fire_delay / 3) //2/3rds of single shot firing rate.
		update_force_list() //This gives the gun some unique verbs for attacking.

	Dispose()
		. = ..()
		in_chamber = null
		ammo = null
		current_mag = null
		target = null
		last_moved_mob = null
		muzzle = null
		if( (gun_features & GUN_FLASHLIGHT_ON) && ismob(loc) ) loc.SetLuminosity(-rail.light_mod) //Handle flashlight.
		rail = null
		under = null
		stock = null

	emp_act(severity)
		for(var/obj/O in contents)
			O.emp_act(severity)

	equipped(mob/user, slot)
		if (slot != slot_l_hand && slot != slot_r_hand)
			stop_aim()
			if (user.client)
				user.client.remove_gun_icons()

		unwield(user)

		return ..()

	update_icon()
		if(isnull(icon_empty)) 								return
		if(!current_mag || current_mag.current_rounds <= 0) icon_state = icon_empty
		else 												icon_state = initial(icon_state)
		update_attachables() //This will cut existing overlays
		if(current_mag && !isnull(current_mag.bonus_overlay))
			var/image/I = new(current_mag.icon,current_mag.bonus_overlay) //Mag adds an overlay
			overlays += I

	examine()
		..() //Might need to do a better check in the future.
		if( !(gun_features & GUN_UNUSUAL_DESIGN) ) //If they don't follow standard gun rules, all of this doesn't apply.

			if(rail) 	usr << "It has \icon[rail] [rail.name] mounted on the top."
			if(muzzle) 	usr << "It has \icon[muzzle] [muzzle.name] mounted on the front."
			if(under) 	usr << "It has \icon[under] [under.name] mounted underneath."
			if(stock) 	usr << "It has \icon[stock] [stock.name] for a stock."

			if(!istype(current_mag)) //Internal mags and the like have their own stuff set.
				if(current_mag && current_mag.current_rounds > 0)
					if(gun_features & GUN_AMMO_COUNTER) usr << "Ammo counter shows [current_mag.current_rounds] round\s remaining."
					else 								usr << "It's loaded."
				else 									usr << "It's unloaded."


//----------------------------------------------------------
			//							        \\
			// LOADING, RELOADING, AND CASINGS  \\
			//							        \\
			//						   	        \\
//----------------------------------------------------------

/obj/item/weapon/gun/proc/replace_ammo(mob/user = null, var/obj/item/ammo_magazine/magazine)
	if(!magazine.default_ammo)
		user << "Something went horribly wrong. Ahelp the following: ERROR CODE A1: null ammo while reloading."
		log_debug("ERROR CODE A1: null ammo while reloading. User: <b>[user]</b>")
		ammo = ammo_list["default bullet"] //Looks like we're defaulting it.
	else ammo = ammo_list[magazine.default_ammo]

/obj/item/weapon/gun/proc/cock_gun(mob/user)
	set waitfor = 0
	if(cocked_sound)
		sleep(3)
		if(user && loc) playsound(user, cocked_sound, 100, 1)

/*
Reload a gun using a magazine.
This sets all the initial datum's stuff. The bullet does the rest.
User can be passed as null, (a gun reloading itself for instance), so we need to watch for that constantly.
*/
/obj/item/weapon/gun/proc/reload(mob/user, var/obj/item/ammo_magazine/magazine)
	if(gun_features & GUN_BURST_ON & GUN_BURST_FIRING) return

	if(!magazine || !istype(magazine))
		user << "That's not a magazine!"
		return

	if(magazine.current_rounds <= 0)
		user << "That [magazine.name] is empty!"
		return

	if(!istype(src, magazine.gun_type))
		user << "That magazine doesn't fit in there!"
		return

	if(!isnull(current_mag) && current_mag.loc == src)
		user << "It's still got something loaded."
		return

	else
		if(user)
			user << "<span class='notice'>You begin reloading \the [src.name]. Hold still...</span>"
			if(do_after(user,magazine.reload_delay))
				user.remove_from_mob(magazine) //Click!
				current_mag = magazine
				magazine.loc = src //Jam that sucker in there.
				replace_ammo(user,magazine)
				if(!in_chamber)
					ready_in_chamber()
					cock_gun(user)
				user << "<span class='notice'>You load \the [magazine] into \the [src]!</span>"
				if(reload_sound) playsound(user, reload_sound, 100, 1)
			else
				user << "<span class='warning'>Your reload was interrupted!</span>"
				return
		else
			current_mag = magazine
			magazine.loc = src
			replace_ammo(,magazine)
			if(!in_chamber) load_into_chamber(user)

	update_icon()
	return 1

//Drop out the magazine. Keep the ammo type for next time so we don't need to replace it every time.
//This can be passed with a null user, so we need to check for that as well.
/obj/item/weapon/gun/proc/unload(mob/user, reload_override = 0) //Override for reloading mags after shooting, so it doesn't interrupt burst.
	if( (gun_features & GUN_BURST_ON & GUN_BURST_FIRING) && !reload_override) return

	if(!current_mag || isnull(current_mag) || current_mag.loc != src)
		user << "<span class='warning'>It's already empty or doesn't need to be unloaded!</span>"
		return

	if(current_mag.current_rounds <= 0 || !user) //If it's empty or there's no user,
		current_mag.loc = get_turf(src) //Drop it on the ground.
	else
		user.put_in_hands(current_mag)

	playsound(user, unload_sound, 20, 1)
	user << "<span class='notice'>You unload the magazine from \the [src].</span>"
	current_mag.update_icon()
	current_mag = null

	update_icon()

//Since reloading and casings are closely related, placing this here ~N
/obj/item/weapon/gun/proc/make_casing(casing_type = "bullet", handle_casings = 0) //Bullets are the default, handle casings is set to discard them.
	if(handle_casings)
		var/num_of_casings = (current_mag && current_mag.used_casings) ? current_mag.used_casings : 1
		var/sound_to_play = pick('sound/weapons/bulletcasing_fall2.ogg','sound/weapons/bulletcasing_fall.ogg')
		if(casing_type == "shell") sound_to_play = 'sound/weapons/shotgun_shell.ogg'
		var/turf/current_turf = get_turf(src)
		var/new_casing = text2path("/obj/item/ammo_casing/[casing_type]")
		var/obj/item/ammo_casing/casing = locate(new_casing) in current_turf
		if(!casing) //No casing on the ground?
			casing = new new_casing(current_turf)
			num_of_casings--
			playsound(current_turf, sound_to_play, 20, 1) //Played again if necessary.
		if(num_of_casings) //Still have some.
			casing.casings += num_of_casings
			casing.update_icon()
			playsound(current_turf, sound_to_play, 20, 1)

//----------------------------------------------------------
			//							    \\
			// AFTER ATTACK AND CHAMBERING  \\
			//							    \\
			//						   	    \\
//----------------------------------------------------------

/obj/item/weapon/gun/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params)
	if(flag)	return ..() //It's adjacent, is the user, or is on the user's person
	if(!istype(A)) return
	if(gun_features & GUN_BURST_ON & GUN_BURST_FIRING) return

	if(user && user.client && user.client.gun_mode && !(A in target)) PreFire(A,user,params) //They're using the new gun system, locate what they're aiming at.
	else															  Fire(A,user,params) //Otherwise, fire normally.

/*
load_into_chamber(), reload_into_chamber(), and clear_jam() do all of the heavy lifting.
If you need to change up how a gun fires, just change these procs for that subtype
and you're good to go.
*/
/obj/item/weapon/gun/proc/load_into_chamber(mob/user)
	//The workhorse of the bullet procs.
	//If it's something like a flashlight, we turn it off. If it's an actual fire and forget one, we need to keep going.
	if(active_attachable && (active_attachable.attach_features & ATTACH_PASSIVE) ) active_attachable = null
 	//If we have a round chambered and no attachable, we're good to go.
	if(in_chamber && !active_attachable) return in_chamber //Already set!

	//Let's check on the active attachable. It loads ammo on the go, so it never chambers anything
	if(active_attachable)
		if(active_attachable.current_rounds > 0) //If it's still got ammo and stuff.
			active_attachable.current_rounds--
			return create_bullet(active_attachable.ammo)
		else
			user << "<span class='warning'>\The [active_attachable.name] is empty!</span>"
			active_attachable = null
	else return ready_in_chamber()//We're not using the active attachable, we must use the active mag if there is one.


/obj/item/weapon/gun/proc/ready_in_chamber()
	if(current_mag && current_mag.current_rounds > 0)
		in_chamber = create_bullet(ammo)
		current_mag.current_rounds-- //Subtract the round from the mag.
		return in_chamber

/obj/item/weapon/gun/proc/create_bullet(datum/ammo/chambered)
	if(!chambered || isnull(chambered))
		usr << "Something has gone horribly wrong. Ahelp the following: ERROR CODE I2: null ammo while create_bullet()"
		log_debug("ERROR CODE I2: null ammo while create_bullet(). User: <b>[usr]</b>")
		chambered = ammo_list["default bullet"] //Slap on a default bullet if somehow ammo wasn't passed.

	var/obj/item/projectile/P = rnew(/obj/item/projectile,src) //New bullet!
	P.ammo = chambered //Share the ammo type. This does all the heavy lifting.
	P.name = P.ammo.name
	P.icon_state = P.ammo.icon_state //Make it look fancy.
	P.damage = P.ammo.damage
	P.damage += damage
	P.accuracy += P.ammo.accuracy
	return P

//This proc is needed for firearms that chamber rounds after firing.
/obj/item/weapon/gun/proc/reload_into_chamber(mob/user)
	/*
	ATTACHMENT POST PROCESSING
	This should only apply to the masterkey, since it's the only attachment that shoots through Fire()
	instead of its own thing through fire_attachment(). If any other bullet attachments are added, they would fire here.
	*/
	if(active_attachable) make_casing(active_attachable.type_of_casings, active_attachable.eject_casings) // Attachables can drop their own casings.
	else
		make_casing(type_of_casings, eject_casings) // Drop a casing if needed.
		in_chamber = null //If we didn't fire from attachable, let's set this so the next pass doesn't think it still exists.

	if(!active_attachable) //We don't need to check for the mag if an attachment was used to shoot.
		if(current_mag) //If there is no mag, we can't reload.
			ready_in_chamber()
			if(current_mag.current_rounds <= 0 && gun_features & GUN_AUTO_EJECTOR) // This is where the magazine is auto-ejected.
				unload(user,1) // We want to quickly autoeject the magazine. This proc does the rest based on magazine type. User can be passed as null.
				var/current_loc = user ? user : get_turf(src)
				playsound(current_loc, empty_sound, 50, 1)

	// Shouldn't be called on, but in case something that uses Fire() is added that is toggled.
	else if( !(active_attachable.attach_features & ATTACH_CONTINUOUS) ) active_attachable = null // Set it to null for next activation. Again, this isn't really going to happen.

	return in_chamber //Returns the projectile if it's actually successful.

/obj/item/weapon/gun/proc/delete_bullet(var/obj/item/projectile/projectile_to_fire, var/refund = 0)
	if(active_attachable) //Attachables don't chamber rounds, so we want to delete it right away.
		cdel(projectile_to_fire) //Getting rid of it. Attachables only use ammo after the cycle is over.
		if(refund) active_attachable.current_rounds++ //Refund the bullet.
		return 1

/obj/item/weapon/gun/proc/clear_jam(var/obj/item/projectile/projectile_to_fire, mob/user as mob) //Guns jamming, great.
	gun_features &= ~GUN_BURST_FIRING // Also want to turn off bursting, in case that was on. It probably was.
	delete_bullet(projectile_to_fire,1) //We're going to clear up anything inside if we need to.
	//If it's a regular bullet, we're just going to keep it chambered.
	extra_delay = 2 + (burst_delay + extra_delay)*2 // Some extra delay before firing again.
	user << "<span class='warning'>\The [src] jammed! You'll need a second to get it fixed!</span>"
	click_empty(user)

//----------------------------------------------------------
		//									   \\
		// FIRE BULLET AND POINT BLANK/SUICIDE \\
		//									   \\
		//						   			   \\
//----------------------------------------------------------

/obj/item/weapon/gun/proc/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, atom/original_target as mob|obj|turf)
	set waitfor = 0

	if(!able_to_fire(user)) return

	var/turf/curloc = get_turf(user)
	var/turf/targloc = get_turf(target)
	if (!targloc || !curloc) return //Something has gone wrong...

	/*
	This is where the grenade launcher and flame thrower function as attachments.
	This is also a general check to see if the attachment can fire in the first place.
	*/
	if(active_attachable && !(active_attachable.attach_features & ATTACH_PASSIVE) ) //Attachment activated and isn't a flashlight or something.
		gun_features &= ~GUN_BURST_ON //We don't want to mess with burst while this is on.
		if( !(active_attachable.attach_features & ATTACH_PROJECTILE) ) //If it's unique projectile, this is where we fire it.
			active_attachable.fire_attachment(target,src,user) //Fire it.
			if(active_attachable.current_rounds <= 0) click_empty(user) //If it's empty, let them know.
			active_attachable = null //Set it to null anyway, it's done.
			return
			//If there's more to the attachment, it will be processed farther down, through in_chamber and regular bullet act.

	/*
	This is where burst is established for the proceeding section. Which just means the proc loops around that many times.
	If burst = 1, you must null it if you ever RETURN during the for() cycle. If for whatever reason burst is left on while
	the gun is not firing, it will break a lot of stuff. BREAK is fine, as it will null it.
	*/

	//Number of bullets based on burst. If an active attachable is shooting, bursting is always zero.
	var/bullets_fired = 1
	if(gun_features & GUN_BURST_ON && burst_amount > 0)
		bullets_fired = burst_amount
		gun_features |= GUN_BURST_FIRING

	var/i //Weirdly, this way is supposed to be less laggy. by 500%
	for(i = 1 to bullets_fired)
		if(src.loc != user) break //If you drop it while bursting, for example.

		//The gun should return the bullet that it already loaded from the end cycle of the last Fire().
		var/obj/item/projectile/projectile_to_fire = load_into_chamber(user) //Load a bullet in or check for existing one.

		if(!projectile_to_fire) //If there is nothing to fire, click.
			click_empty(user)
			break

		projectile_to_fire.shot_from = src
		if(!target || isnull(target)) target = targloc
		if(!isnull(original_target) && target != original_target) projectile_to_fire.original = original_target//Save the original thing that we shot at.
		else projectile_to_fire.original = target

		apply_bullet_effects(projectile_to_fire, user, i, reflex) //User can be passed as null.

		//BIPODS BEGINS HERE
		var/recoil_comp = 0 //If we're using a bipod properly, this will change.
		//They decrease scatter chance and increase accuracy a tad. Can also increase damage.
		if(user && under && under.firing_support) //Let's get to work on the bipod. I'm not really concerned if they are the same person as the previous user. It doesn't matter.
			if(under.check_position(src, user))
				//Passive accuracy and recoil buff, but only when firing in position.
				projectile_to_fire.accuracy += 30 //More accuracy.
				recoil_comp-- //Less recoil.
				if(prob(65)) projectile_to_fire.scatter_chance = max(1, projectile_to_fire.scatter_chance - 15)//Lowers scatter chance.
				if(prob(30)) projectile_to_fire.damage = round(5 * projectile_to_fire.damage / 4)//Lower chance of a damage buff.
				if(i == 1) user << "<span class='notice'>Your bipod keeps \the [src] steady!</span>"
		//End of bipods.

		//Scatter chance is 20% by default, 10% flat with single shot.
		if( !(projectile_to_fire.ammo.ammo_behavior & AMMO_NO_SCATTER) ) //Not if it doesn't scatter at all.
			if( prob(5) || (gun_features & GUN_BURST_ON && burst_amount > 1) ) //Only 5% chance to scatter, and then still unlikely, on single fire.
				projectile_to_fire.scatter_chance += (burst_amount * 3) //Much higher chance on a burst.

				if(prob(projectile_to_fire.scatter_chance)) //Scattered!
					var/scatter_x = rand(-1,1)
					var/scatter_y = rand(-1,1)
					var/turf/new_target = locate(targloc.x + round(scatter_x),targloc.y + round(scatter_y),targloc.z) //Locate an adjacent turf.
					if(new_target) //Looks like we found a turf.
						target = new_target
						targloc = target
						projectile_to_fire.original = target

		if(params)
			var/list/mouse_control = params2list(params)
			if(mouse_control["icon-x"])
				projectile_to_fire.p_x = text2num(mouse_control["icon-x"])
			if(mouse_control["icon-y"])
				projectile_to_fire.p_y = text2num(mouse_control["icon-y"])

		//Finally, make with the pew pew!
		if(!projectile_to_fire || !istype(projectile_to_fire,/obj) || isnull(projectile_to_fire))
			user << "Your gun is malfunctioning. Ahelp the following: ERROR CODE I1: projectile malfunctioned while firing."
			log_debug("ERROR CODE I1: projectile malfunctioned while firing. User: <b>[user]</b>")
			gun_features &= ~GUN_BURST_FIRING
			return

		if(get_turf(target) != get_turf(user))
			simulate_recoil(recoil+recoil_comp, user, target)

			//This is where the projectile leaves the barrel and deals with projectile code only.
			//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
			projectile_to_fire.fire_at(target,user,src,projectile_to_fire.ammo.max_range,projectile_to_fire.ammo.shell_speed)
			//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

		else // This happens in very rare circumstances when you're moving a lot while burst firing, so I'm going to toss it up to guns jamming.
			clear_jam(projectile_to_fire,user)
			break

		//>>POST PROCESSING AND CLEANUP BEGIN HERE.<<
		if(target) //If we had a target, let's do a muzzle flash.
			var/angle = round(Get_Angle(user,target))
			muzzle_flash(angle,user)

		//This is where we load the next bullet in the chamber. We check for attachments too, since we don't want to load anything if an attachment is active.
		if(!reload_into_chamber(user)) // It has to return a bullet, otherwise it's empty.
			click_empty(user)
			break //Nothing else to do here, time to cancel out.

		if(i < bullets_fired) // We still have some bullets to fire.
			extra_delay = min(extra_delay+(burst_delay*2), fire_delay*3) // The more bullets you shoot, the more delay there is, but no more than thrice the regular delay.
			sleep(burst_delay)

	gun_features &= ~GUN_BURST_FIRING // We always want to turn off bursting when we're done.

/obj/item/weapon/gun/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	if(gun_features & GUN_CAN_POINTBLANK) // If it can't point blank, you can't suicide and such.
		if(M == user && user.zone_sel.selecting == "mouth")
			if(able_to_fire(user))
				gun_features ^= GUN_CAN_POINTBLANK //If they try to click again, they're going to hit themselves.
				M.visible_message("<span class='warning'>[user] sticks their gun in their mouth, ready to pull the trigger...</span>")
				if(do_after(user, 40))
					if(active_attachable && !(active_attachable.attach_features & ATTACH_PROJECTILE))
						active_attachable = null //We're not firing off a nade into our mouth.
					var/obj/item/projectile/projectile_to_fire = load_into_chamber(user)
					if(projectile_to_fire) //We actually have a projectile, let's move on.
						user.visible_message("<span class = 'warning'>[user] pulls the trigger!</span>")
						var/actual_sound = (active_attachable && active_attachable.fire_sound) ? active_attachable.fire_sound : fire_sound
						var/sound_volume = (gun_features & GUN_SILENCED && !active_attachable) ? 20 : 50
						playsound(user, actual_sound, sound_volume, 1)

						shake_camera(user, recoil + 2, recoil + 1) //Give it some shake.

						var/obj/item/weapon/gun/revolver/current_revolver = src
						if(istype(current_revolver) && current_revolver.russian_roulette) //If it's a revolver set to Russian Roulette.
							user.apply_damage(projectile_to_fire.damage*3, projectile_to_fire.ammo.damage_type, "head", used_weapon = "An unlucky pull of the trigger during Russian Roulette!", sharp=1)
							user.apply_damage(200, OXY) //In case someone tried to defib them. Won't work.
							user.death()
							user << "<span class='highdanger'>Your life flashes before you as your spirit is torn from your body!</span>"
							var/mob/dead/observer/ghost = user.ghostize(0) //No return.
							if(ghost) ghost.timeofdeath = world.time	//For respawn purposes, even if unused.
						else
							if (projectile_to_fire.ammo.damage_type == HALLOSS)
								user << "<span class = 'notice'>Ow...</span>"
								user.apply_effect(110,AGONY,0)
							else
								user.apply_damage(projectile_to_fire.damage*2.5, projectile_to_fire.ammo.damage_type, "head", used_weapon = "Point blank shot in the mouth with \a [projectile_to_fire]", sharp=1)
								user.apply_damage(100, OXY)
								user.death()

						if(!delete_bullet(projectile_to_fire)) cdel(projectile_to_fire) //If this proc DIDN'T delete the bullet, we're going to do so here.
						reload_into_chamber(user) //Reload the sucker.

					else click_empty(user)//If there's no projectile, we can't do much.
				else M.visible_message("<span class='notice'>[user] decided life was worth living.</span>")
				gun_features ^= GUN_CAN_POINTBLANK //Reset this.
			return

		else if(user.a_intent == "hurt") //Point blanking doesn't actually fire the projectile. No reason to.
			gun_features &= ~GUN_BURST_FIRING
			//Point blanking simulates firing the bullet proper but without actually firing it.
			if(able_to_fire(user)) //If you can't fire the gun in the first place, we're just going to hit them with it.
				if(active_attachable && !(active_attachable.attach_features & ATTACH_PROJECTILE)) active_attachable = null//No way.
				var/obj/item/projectile/projectile_to_fire = load_into_chamber(user)
				if(projectile_to_fire) //We actually have a projectile, let's move on. We're going to simulate the fire cycle.
					projectile_to_fire.damage *= 1.1 //Multiply the damage for point blank.
					user.visible_message("<span class='danger'>\The [user] fires \the [src] point blank at [M]!</span>")
					apply_bullet_effects(projectile_to_fire, user) //We add any damage effects that we need.
					if(recoil > 0) shake_camera(user, recoil + 1, recoil) //Shake the camera from recoil

					M.bullet_act(projectile_to_fire) //Just apply the effects manually.
					projectile_to_fire.ammo.on_hit_mob(M,projectile_to_fire)
					if(!delete_bullet(projectile_to_fire)) cdel(projectile_to_fire)
					reload_into_chamber(user) //Reload into the chamber if the gun supports it.
				else
					click_empty(user) //We want to return here, since they're trying to point blank them, not hit them with the gun.
				return
	return ..() //Pistolwhippin'

//----------------------------------------------------------
				//							\\
				// FIRE CYCLE RELATED PROCS \\
				//							\\
				//						   	\\
//----------------------------------------------------------

/obj/item/weapon/gun/proc/able_to_fire(mob/user)
	/*
	Removed ishuman() check. There is no reason for it, as it just eats up more processing, and adding fingerprints during the fire cycle is silly.
	Consequently, predators are able to fire while cloaked.
	*/
	if(ismob(user)) //Could be an object firing the gun.
		if(gun_features & GUN_BURST_ON & GUN_BURST_FIRING) return

		if(!user.IsAdvancedToolUser())
			user << "<span class='warning'>You don't have the dexterity to do this!</span>"
			return

		if(gun_features & GUN_TRIGGER_SAFETY)
			user << "<span class='warning'>The safety is on!</span>"
			return

		if(flags & TWOHANDED) //If we're not holding the weapon with both hands when we should.
			var/obj/item/weapon/twohanded/offhand/O = user.get_inactive_hand() //We have to check for this though, since the offhand can drop due to arm malfs, etc.
			if(!istype(O))
				unwield(user)
				user << "<span class='warning'>You need a more secure grip to fire this weapon!"
				return

		if( (gun_features & GUN_WY_RESTRICTED) && !wy_allowed_check(user) ) return

		//Has to be on the bottom of the stack to prevent delay when failing to fire the weapon for the first time.
		//Can also set last_fired through New(), but honestly there's not much point to it.
		if(world.time >= last_fired + fire_delay + extra_delay) //If not, check the last time it was fired.
			extra_delay = 0
			last_fired = world.time
		else
			if (world.time % 3) user << "<span class='warning'>[src] is not ready to fire again!</span>" //to prevent spam
			return

	return 1

/obj/item/weapon/gun/proc/click_empty(mob/user)
	if(user)
		user.visible_message("*click click*", "<span class='warning'><b>*click*</b></span>")
		playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	else
		src.visible_message("*click click*")
		playsound(get_turf(src), 'sound/weapons/empty.ogg', 100, 1)

//This proc applies some bonus effects to the shot/makes the message when a bullet is actually fired.
/obj/item/weapon/gun/proc/apply_bullet_effects(var/obj/item/projectile/projectile_to_fire, mob/user, var/i = 1, var/reflex = 0)
	var/actual_sound = fire_sound
	var/sound_volume = gun_features & GUN_SILENCED ? 20 : 50
	projectile_to_fire.accuracy += accuracy //We're going to throw in the gun's accuracy.
	if(!active_attachable || (active_attachable.attach_features & ATTACH_PASSIVE) ) //We don't want all of these to affect attachables.
		//Various bonuses begin here.
		if(rail && rail.ranged_dmg_mod) projectile_to_fire.damage = round(projectile_to_fire.damage * rail.ranged_dmg_mod / 100)
		if(muzzle && muzzle.ranged_dmg_mod) projectile_to_fire.damage = round(projectile_to_fire.damage * muzzle.ranged_dmg_mod / 100)
		if(stock && stock.ranged_dmg_mod) projectile_to_fire.damage = round(projectile_to_fire.damage * stock.ranged_dmg_mod / 100)
		if(under && under.ranged_dmg_mod) projectile_to_fire.damage = round(projectile_to_fire.damage * under.ranged_dmg_mod / 100)
	else //Looks like we have an active attachable being used to shoot with if we got to this step.
		if(active_attachable.fire_sound) actual_sound = active_attachable.fire_sound //If we're firing from an attachment, use that noise instead.
		sound_volume = 50 //Since we're using an attachable, the silencer doesn't matter.

	if(user) //The gun only messages when fired by a user.
		projectile_to_fire.firer = user
		if(isliving(user)) projectile_to_fire.def_zone = user.zone_sel.selecting
		projectile_to_fire.dir = user.dir
		playsound(user, actual_sound, sound_volume, 1)
		if(i == 1)
			if(!(gun_features & GUN_SILENCED))
				user.visible_message(
				"<span class='danger'>[user] fires [src][reflex ? " by reflex":""]!</span>", \
				"<span class='warning'>You fire [src][reflex ? "by reflex":""]! [gun_features & GUN_AMMO_COUNTER && current_mag ? "<B>[current_mag.current_rounds-1]</b>/[current_mag.max_rounds]" : ""]</span>", \
				"<span class='warning'>You hear a [istype(projectile_to_fire.ammo, /datum/ammo/bullet) ? "gunshot" : "blast"]!</span>"
				)
			else
				user << "<span class='warning'>You fire [src][reflex ? "by reflex":""]! [gun_features & GUN_AMMO_COUNTER && current_mag ? "<B>[current_mag.current_rounds-1]</b>/[current_mag.max_rounds]" : ""]</span>"
	return 1

/obj/item/weapon/gun/proc/simulate_recoil(var/total_recoil = 0, mob/user, atom/target)
	if(total_recoil > 0 && ishuman(user))
		shake_camera(user, total_recoil + 1, total_recoil)
		return 1

/obj/item/weapon/gun/proc/muzzle_flash(angle,mob/user as mob|obj)
	set waitfor = 0 //No need to wait on this one.
	if(!muzzle_flash || gun_features & GUN_SILENCED || isnull(angle)) return
	if(!istype(user) || !istype(user.loc,/turf)) return
	if(prob(65)) //Not all the time.
		var/layer = (user && user.dir == SOUTH) ? MOB_LAYER+0.1 : MOB_LAYER-0.1
		var/image/flash = image('icons/obj/projectiles.dmi',user,muzzle_flash,layer)

		var/matrix/rotate = matrix() //Change the flash angle.
		rotate.Translate(0,5)
		rotate.Turn(angle)
		flash.transform = rotate

		for(var/mob/M in viewers(user))
			M << flash

		cdel(flash,,3)