/obj/item/weapon/gun
	name = "gun"
	desc = "Its a gun. It's pretty terrible, though."
	icon = 'icons/obj/gun.dmi'
	icon_state = ""
	var/icon_wielded = null
	var/icon_empty = null
	var/muzzle_flash = "muzzle_flash"
	item_state = "gun"
	flags =  FPRINT | TABLEPASS | CONDUCT
	matter = list("metal" = 75000)
	origin_tech = "combat=1" //Guns generally have their own unique levels.
	w_class = 3.0
	throwforce = 5
	throw_speed = 4
	throw_range = 5
	force = 5.0
	attack_verb = list("struck", "hit", "bashed")

	var/fire_sound = 'sound/weapons/Gunshot.ogg'
	var/reload_sound = null //We don't want these for guns that don't have them.
	var/cocked_sound = null
	var/unload_sound = 'sound/weapons/flipblade.ogg'
	var/empty_sound = 'sound/weapons/smg_empty_alarm.ogg'

	var/can_pointblank = 1
	var/obj/item/projectile/in_chamber = null //What is currently in the chamber. Most guns will want something in the chamber upon creation.

	/*
	Ammo is used by the majority of weapons to tell the bullet what to do once it leaves the chamber. The problem
	here is that ammo can be deleted or replaced, so bullets leaving the chamber may sometimes have no ammo to call
	up, even though they had it when the bullet was placed in the chamber. To get around the issue, ammo buffers are used.
	The idea is that once that final bullet is in the chamber and the magazine is unloaded, the user may fire it.
	They may, instead reload the magazine and buffer the ammo for use by that final bullet. The buffer is deleted upon reload
	when it's no longer needed.
	*/
	var/datum/ammo/ammo = null //The default ammo datum when a round is chambered. Null means it probably does its own thing.
	var/datum/ammo/ammo_buffer1 = null
	var/datum/ammo/ammo_buffer2 = null

	var/obj/item/ammo_magazine/current_mag = null //What magazine is currently loaded?
	var/mag_type = null  //The default magazine loaded into a projectile weapon for reverse lookups. Leave this null to do your own thing.
	var/mag_type_internal = null //If the weapon has an internal magazine, this is the way to do it. This will be used on New() if it exists.
	var/default_ammo = "/datum/ammo" //For stuff that doesn't use mags. Just fire it.
	var/trigger_safety = 0 //Off by default. If it's on, you can't fire.
	var/energy_based = 0 //Off by default. If the gun doesn't use ammo but recharges somehow, toggle this on.
	var/eject_casings = 0 //Off by default.

	var/silenced = 0
	var/recoil = 0

	var/tmp/list/mob/living/target //List of who yer targeting.
	var/tmp/lock_time = -100
	var/tmp/mouthshoot = 0 ///To stop people from suiciding twice... >.>
	var/automatic = 0 //Used to determine if you can target multiple people.
	var/tmp/mob/living/last_moved_mob //Used to fire faster at more than one person.
	var/tmp/told_cant_shoot = 0 //So that it doesn't spam them with the fact they cannot hit them.
	var/firerate = 0 	//0 for keep shooting until aim is lowered
						// 1 for one bullet after tarrget moves and aim is lowered
	var/fire_delay = 6 // For regular shots, how long to wait before firing again.
	var/extra_delay = 0 // When burst-firing, this number is extra time before the weapon can fire again. Depends on number of rounds fired.
	var/last_fired = 0 // When it was last fired, related to world.time.

	var/twohanded = 0 //0 for one handed, 1 for two.
	var/wielded = 0 //Do not set this in gun defines. Only used when the gun is wielded in two hands.

	var/obj/item/attachable/muzzle = null //Attachable slots. Only one item per slot.
	var/obj/item/attachable/rail = null
	var/obj/item/attachable/under = null
	var/obj/item/attachable/stock = null

	var/obj/item/attachable/active_attachable = null //This will link to one of the above four, or remain null.

	var/muzzle_pixel_y = 15 //These determine the position of the overlay relative to the gun.
	var/muzzle_pixel_x = 33 //Ie. where the overlay should be placed depending on the slot.
	var/rail_pixel_y = 19 //They can go above normal values.
	var/rail_pixel_x = 28  //These defaults are all for the m41a, and should be changed according to the weapon.
	var/under_pixel_y = 13
	var/under_pixel_x = 21
	//Stocks do not have their own offsets, use under instead. I could change this in the future, for now it's not needed. ~N.

	var/flashlight_on = 0 //Mounted flashlight stuff.
	var/flash_lum = 0

	var/burst_amount = 0 //How many shots can the weapon shoot in burst? If 0, you cannot toggle burst.
	var/burst_toggled = 0 //Is the weapon set to burst mode?
	var/burst_firing = 0 //Are you burst firing or not?
	var/is_bursting = 0 //Sentries use this. Regular guns do not.
	var/burst_delay = 0 //The delay in between shots. Lower = less delay = faster.

	icon_action_button = null //Adds it to the quick-icon list
	var/accuracy = 0 //Flat bonus/penalty due to the gun itself.
	var/dam_bonus = 0 //Flat bonus/penalty to bullet damage due to the gun itself.
	var/ammo_counter = 0 //M39s and M41s have this. True or false.
	var/autoejector = 1 //Automatically ejects spent magazines. Defaults to yes. True or false.
	var/found_on_mercs = 0 //For the randomizer. True or false.
	var/found_on_russians = 0 //For the randomizer. True or false.
	var/one_shot = 1 //For alternate fire weapons, does it fire 1 then revert, or continue?

//----------------------------------------------------------
				//				    \\
				// NECESSARY PROCS  \\
				//					\\
				//					\\
//----------------------------------------------------------

	New()
		..()
		var/magpath

		if(mag_type_internal)
			magpath = text2path(mag_type_internal)
		else if(mag_type)
			magpath = text2path(mag_type)

		if(magpath)
			current_mag = new magpath(src)
			current_mag.current_rounds = current_mag.max_rounds //Eh. For now they can always start full.
			var/ammopath = text2path(current_mag.default_ammo)
			if(ispath(ammopath))
				ammo = new ammopath()
			else
				ammo = new default_ammo() //Just force it.

		if(burst_delay == 0 && burst_amount > 0) //Okay.
			burst_delay = round(2 * fire_delay / 3) //2/3rds of single shot firing rate.

	Del()
		if(flashlight_on && ismob(src.loc))
			src.loc.SetLuminosity(-flash_lum)
		else
			SetLuminosity(0)

		if(current_mag) del(current_mag)
		current_mag = null
		if(muzzle) del(muzzle)
		muzzle = null
		if(rail) del(rail)
		rail = null
		if(under) del(under)
		under = null
		if(in_chamber) del(in_chamber)
		in_chamber = null
		if(ammo) del(ammo)
		ammo = null
		if(ammo_buffer1) del(ammo_buffer1)
		ammo_buffer1 = null
		if(ammo_buffer2) del(ammo_buffer2)
		ammo = ammo_buffer2
		contents = null
		..()

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
		if(isnull(icon_empty)) return
		if(!current_mag || current_mag.current_rounds <= 0)
			icon_state = icon_empty
		else
			icon_state = initial(icon_state)
		update_attachables() //This will cut existing overlays
		if(current_mag && !isnull(current_mag.bonus_overlay))
			var/image/I = new(current_mag.icon,current_mag.bonus_overlay) //Mag adds an overlay
			overlays += I

	examine()
		..() //Might need to do a better check in the future.
		if(!energy_based)
			if(current_mag && current_mag.current_rounds > 0)
				if(ammo_counter || istype(src, /obj/item/weapon/gun/smartgun)) //Quick adjustment for smartguns.
					usr << "Ammo counter shows [current_mag.current_rounds] round\s remaining."
				else
					usr << "It's loaded."
			else
				usr << "It's unloaded."

			if(rail)
				usr << "It has \icon[rail] [rail.name] mounted on the top."
			if(muzzle)
				usr << "It has \icon[muzzle] [muzzle.name] mounted on the front."
			if(under)
				usr << "It has \icon[under] [under.name] mounted underneath."
			if(stock)
				usr << "It has \icon[stock] [stock.name] for a stock."

//----------------------------------------------------------
			//							        \\
			// LOADING, RELOADING, AND CASINGS  \\
			//							        \\
			//						   	        \\
//----------------------------------------------------------

/*
Quick helper proc to not copy paste this a billion times.
Convenietly it also handles ammo buffering, so it's all around useful.
If the gun has an ammo being replaced, it will buffer the last ammo it had
unless that ammo is the same as what it is getting replaced with.
*/
/obj/item/weapon/gun/proc/replace_ammo(var/mob/user = null, var/obj/item/ammo_magazine/magazine)
	var/ammopath = text2path(magazine.default_ammo)
	if(!ammopath || isnull(ammopath))
		if(user) user << "Something went horribly wrong. Ahelp the following: ERROR CODE A1: null.ammopath while reloading."
		return

	if(in_chamber) //We really only care about that chambered bullet when reloading.
		if(in_chamber.ammo == ammo)
			ammo_buffer1 = ammo
		else if(in_chamber.ammo == ammo_buffer1)
			del(ammo) //So now we replace the ammo proper.
	else //No bullet in the chamber? Delete both as we don't need them anymore.
		del(ammo_buffer1)
		del(ammo)
	ammo = new ammopath()
	ammo.current_gun = src
	return 1

/*
Reload a gun using a magazine.
This sets all the initial datum's stuff. The bullet does the rest.
User can be passed as null, (a gun reloading itself for instance), so we need to watch for that constantly.
*/
/obj/item/weapon/gun/proc/reload(var/mob/user = null, var/obj/item/ammo_magazine/magazine)
	if(burst_toggled && burst_firing) return

	if(!magazine || !istype(magazine))
		if(user) user << "That's not a magazine!"
		return

	if(magazine.current_rounds <= 0)
		if(user) user << "That [magazine.name] is empty!"
		return

	if(user)
		var/obj/item/ammo_magazine/in_hand = user.get_inactive_hand()
		if( in_hand != src ) //It has to be held.
			user << "You have to hold \the [src] to reload!"
			return

	if(!istype(src,text2path(magazine.gun_type)))
		if(user) user << "That magazine doesn't fit in there!"
		return

	if(!isnull(current_mag) && current_mag.loc == src)
		if(user) user << "It's still got something loaded."
		return

	else
		if(user)
			user << "You begin reloading \the [src.name]. Hold still!"
			if(do_after(user,magazine.reload_delay))
				user.drop_from_inventory(magazine) //Click!
				current_mag = magazine
				magazine.loc = src //Jam that sucker in there.
				replace_ammo(user,magazine)
				if(!in_chamber)
					load_into_chamber()
					if(cocked_sound)
						spawn(3)
							playsound(user, cocked_sound, 100, 1)
				user << "\blue You load \the [magazine] into \the [src]!"
				if(reload_sound) playsound(user, reload_sound, 100, 1)
			else
				user << "Your reload was interrupted."
				return
		else
			current_mag = magazine
			magazine.loc = src
			replace_ammo(,magazine)
			if(!in_chamber)
				load_into_chamber(1)

	update_icon()
	return 1

//Drop out the magazine. Keep the ammo type for next time so we don't need to replace it every time.
//This can be passed with a null user, so we need to check for that as well.
/obj/item/weapon/gun/proc/unload(var/mob/user as mob, var/reload_override = 0) //Override for reloading mags after shooting.
	if(burst_toggled && burst_firing && !reload_override) return

	if(!current_mag || isnull(current_mag) || current_mag.loc != src)
		if(user) user << "It's already empty or doesn't need to be unloaded."
		return

	if(user)
		if(!user.put_in_active_hand(current_mag) && !user.put_in_inactive_hand(current_mag))
			current_mag.loc = get_turf(src)
	else
		current_mag.loc = get_turf(src)
	playsound(src, unload_sound, 20, 1)
	if(user) user << "\blue You unload the magazine from \the [src]."
	make_casing(1) //override for ejecting the mag.
	current_mag.update_icon()
	current_mag = null

	update_icon()
	return

//Since reloading and casings are closely related, placing this here ~N
/obj/item/weapon/gun/proc/make_casing(var/casing_override) //casing_override is for things like unload() instead of going through Fire().
	var/sound_to_play = pick('sound/weapons/bulletcasing_fall2.ogg','sound/weapons/bulletcasing_fall.ogg')

	if(eject_casings)
		//This is far, far faster.
		var/turf/current_turf = get_turf(src)
		var/obj/item/ammo_casing/bullet/casing = locate() in current_turf
		if(!casing)
			casing = new(current_turf) //Don't need to do anything else.
		else
			casing.casings += 1
			casing.update_icon()
		playsound(current_turf, sound_to_play, 20, 1)
	return

//----------------------------------------------------------
			//							    \\
			// AFTER ATTACK AND CHAMBERING  \\
			//							    \\
			//						   	    \\
//----------------------------------------------------------

/obj/item/weapon/gun/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params)
	if(flag)	return ..() //It's adjacent, is the user, or is on the user's person
	if(!istype(A)) return

	if(burst_toggled && burst_firing) return

	if(user && user.client && user.client.gun_mode && !(A in target))
		PreFire(A,user,params) //They're using the new gun system, locate what they're aiming at.
	else
		Fire(A,user,params) //Otherwise, fire normally.
	return
/*
load_into_chamber(), reload_into_chamber(), and clear_jam() do all of the heavy lifting.
If you need to change up how a gun fires, just change these procs for that subtype
and you're good to go.
*/
/obj/item/weapon/gun/proc/load_into_chamber()
	//The workhorse of the bullet procs.
	//If it's something like a flashlight, we turn it off. If it's an actual fire and forget one, we need to keep going.
	if(active_attachable && active_attachable.passive)
		active_attachable = null

	if(in_chamber && !active_attachable) //If we have a round chambered and no attachable, we're good to go.
		return in_chamber //Already set!

	//Let's check on the active attachable. It loads ammo on the go, so it never chambers anything
	if(active_attachable)
		if(active_attachable.ammo_type && active_attachable.current_ammo > 0) //If it's still got ammo and stuff.
			active_attachable.current_ammo--
			return create_bullet(active_attachable.ammo)
		else
			if(usr) usr << "\red \The [active_attachable.name] is empty!"
			active_attachable = null
			return

	else //We're not using the active attachable, we must use the active mag if there is one.
		if(current_mag && current_mag.current_rounds > 0)
			current_mag.current_rounds-- //Subtract the round from the mag.
			in_chamber = create_bullet(ammo)
			return in_chamber

	return //We can't make a projectile without a mag or active attachable.

/obj/item/weapon/gun/proc/create_bullet(var/datum/ammo/chambered)
	if(!chambered || isnull(chambered))
		usr << "Something has gone horribly wrong. Ahelp the following: ERROR CODE I2: null ammo while create_bullet()"
		return //Our ammo datum is missing. We need one, and it should have set when we reloaded, so, abort.

	var/obj/item/projectile/P = new(src) //New bullet!
	P.ammo = chambered //Share the ammo type. This does all the heavy lifting.
	P.ammo.current_gun = src
	P.name = P.ammo.name
	P.icon_state = P.ammo.icon_state //Make it look fancy.
	P.damage = P.ammo.damage
	P.damage += dam_bonus
	P.damage_type = P.ammo.damage_type
	return P

//This proc is needed for firearms that chamber rounds after firing.
/obj/item/weapon/gun/proc/reload_into_chamber(var/mob/user as mob)
	/*
	ATTACHMENT POST PROCESSING
	This should only apply to the masterkey, since it's the only attachment that shoots through Fire()
	instead of its own thing through fire_attachment(). If any other bullet attachments are added, they would fire here.
	*/
	if(active_attachable)
		make_casing() // Attachables can drop their own casings.
	else
		make_casing() // Drop a casing if needed.
		in_chamber = null //If we didn't fire from attachable, let's set this so the next pass doesn't think it still exists.

	if(!active_attachable) //We don't need to check for the mag if an attachment was used to shoot.
		if(current_mag) //If there is no mag, we can't reload.
			if(current_mag.current_rounds > 0) //We can't load more rounds into the chamber without a mag.
				current_mag.current_rounds-- //Subtract the round from the mag.
				in_chamber = create_bullet(ammo)
			if(current_mag.current_rounds <= 0 && autoejector) // This is where the magazine is auto-ejected.
				if(user)
					playsound(user, empty_sound, 50, 1)
				else
					playsound(src.loc, empty_sound, 50, 1)
				unload(user,1) // We want to quickly autoeject the magazine. This proc does the rest based on magazine type. User can be passed as null.
	else
		if(!active_attachable.continuous) // Shouldn't be called on, but in case something that uses Fire() is added that is toggled.
			active_attachable = null // Set it to null for next activation. Again, this isn't really going to happen.

	return in_chamber //Returns the projectile if it's actually successful.

/obj/item/weapon/gun/proc/delete_bullet(var/obj/item/projectile/projectile_to_fire, var/refund = 0)
	if(active_attachable) //Attachables don't chamber rounds, so we want to delete it right away.
		del(projectile_to_fire) //Getting rid of it. Attachables only use ammo after the cycle is over.
		if(refund)
			active_attachable.current_ammo++ //Refund the bullet.
		return 1
	return

/obj/item/weapon/gun/proc/clear_jam(var/obj/item/projectile/projectile_to_fire, var/mob/user as mob) //Guns jamming, great.
	delete_bullet(projectile_to_fire,1) //We're going to clear up anything inside if we need to.
	//If it's a regular bullet, we're just going to keep it chambered.
	extra_delay = 2 + (burst_delay + extra_delay)*2 // Some extra delay before firing again.
	burst_firing = 0 // Also want to turn off bursting, in case that was on. It probably was.
	if(user)
		user << "\red \The [src] jammed! You'll need a second to get it fixed!"
		click_empty(user)
	return

//----------------------------------------------------------
		//									   \\
		// FIRE BULLET AND POINT BLANK/SUICIDE \\
		//									   \\
		//						   			   \\
//----------------------------------------------------------

/obj/item/weapon/gun/proc/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, atom/original_target as mob|obj|turf)
	set waitfor = 0

	if(!able_to_fire(user))
		return

	var/turf/curloc = get_turf(user)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc)) //If there is no location for target or us.
		return

	/*
	This is where the grenade launcher and flame thrower function as attachments.
	This is also a general check to see if the attachment can fire in the first place.
	*/
	if(active_attachable && !active_attachable.passive) //Attachment activated and isn't a flashlight or something.
		burst_toggled = 0 //We don't want to mess with burst while this is on.
		if(!active_attachable.projectile_based) //If it's unique projectile, this is where we fire it.
			active_attachable.fire_attachment(target,src,user) //Fire it.
			if(active_attachable.current_ammo <= 0) click_empty(user) //If it's empty, let them know.
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
	if(burst_toggled && burst_amount > 0)
		bullets_fired = burst_amount
		burst_firing = 1

	var/i //Weirdly, this way is supposed to be less laggy. by 500%
	for(i = 1 to bullets_fired)
		//Since the proc runs off src, it wouldn't run if the src is null. Not point in checking.
		if(src.loc != user) //If you drop it while bursting, for example.
			break

		//The gun should return the bullet that it already loaded from the end cycle of the last Fire().
		var/obj/item/projectile/projectile_to_fire = load_into_chamber() //Load a bullet in or check for existing one.

		if(!projectile_to_fire) //If there is nothing to fire, click.
			click_empty(user)
			break

		projectile_to_fire.shot_from = src

		if(!target || isnull(target))
			target = targloc

		if(!isnull(original_target) && target != original_target) //Save the original thing that we shot at.
			projectile_to_fire.original = original_target
		else
			projectile_to_fire.original = target

		apply_bullet_effects(projectile_to_fire, user, i, reflex) //User can be passed as null.

		//Scatter chance is 20% by default, 10% flat with single shot.
		if(ammo && ammo.never_scatters == 0 && (prob(5) || (burst_toggled && burst_amount > 1)))
			projectile_to_fire.scatter_chance += (burst_amount * 3) //Much higher chance on a burst.

			if(prob(projectile_to_fire.scatter_chance) && (ammo && ammo.never_scatters == 0)) //Scattered!
				var/scatter_x = rand(-1,1)
				var/scatter_y = rand(-1,1)
				var/turf/new_target = locate(targloc.x + round(scatter_x),targloc.y + round(scatter_y),targloc.z) //Locate an adjacent turf.
				if(istype(new_target) && !isnull(new_target))
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
			burst_firing = 0
			return

		if(get_turf(target) != get_turf(user))
			if(recoil > 0 && ishuman(user))
				shake_camera(user, recoil + 1, recoil)
			spawn(1) ////This is to make the projectile not appear underneath the character when fired.
				projectile_to_fire.invisibility = 0 // If it still exists, let's make it visible again.

			//This is where the projectile leave the barrel and deals with projectile code only.
			//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
			projectile_to_fire.fire_at(target,user,src,ammo.max_range,ammo.shell_speed)
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

	burst_firing = 0 // We always want to turn off bursting when we're done.
	return

/obj/item/weapon/gun/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	if(can_pointblank) // If it can't point blank, you can't suicide and such.
		if(mouthshoot)
			return

		if(M == user && user.zone_sel.selecting == "mouth")
			if(able_to_fire(user))
				mouthshoot = 1
				M.visible_message("\red [user] sticks their gun in their mouth, ready to pull the trigger...")
				if(do_after(user, 40))
					if(active_attachable && !active_attachable.projectile_based)
						active_attachable = null //We're not firing off a nade into our mouth.
					var/obj/item/projectile/projectile_to_fire = load_into_chamber()
					if(projectile_to_fire) //We actually have a projectile, let's move on.
						user.visible_message("<span class = 'warning'>[user] pulls the trigger.</span>")
						if(silenced)
							playsound(user, fire_sound, 10, 1)
						else
							playsound(user, fire_sound, 50, 1)

						shake_camera(user, recoil + 2, recoil + 1) //Give it some shake.

						if (projectile_to_fire.damage_type != HALLOSS)
							user.apply_damage(projectile_to_fire.damage*2.5, projectile_to_fire.damage_type, "head", used_weapon = "Point blank shot in the mouth with \a [projectile_to_fire]", sharp=1)
							user.death()
						else
							user << "<span class = 'notice'>Ow...</span>"
							user.apply_effect(110,AGONY,0)

						if(!delete_bullet(projectile_to_fire)) del(projectile_to_fire) //If this proc DIDN'T delete the bullet, we're going to do so here.
						reload_into_chamber(user) //Reload the sucker.

					else //If there's no projectile, we can't do much.
						click_empty(user)
				else
					M.visible_message("\blue [user] decided life was worth living.")
				mouthshoot = !mouthshoot
			return

		else if(user.a_intent == "hurt") //Point blanking doesn't actually fire the projectile. No reason to.
			burst_firing = 0
			//Point blanking simulates firing the bullet proper but without actually firing it.
			if(able_to_fire(user)) //If you can't fire the gun in the first place, we're just going to hit them with it.
				if(active_attachable && !active_attachable.projectile_based) //No way.
					active_attachable = null
				var/obj/item/projectile/projectile_to_fire = load_into_chamber()
				if(projectile_to_fire) //We actually have a projectile, let's move on. We're going to simulate the fire cycle.
					projectile_to_fire.damage *= 1.1 //Multiply the damage for point blank.
					user.visible_message("\red <b>\The [user] fires \the [src] point blank at [M]!</b>")
					apply_bullet_effects(projectile_to_fire, user) //We add any damage effects that we need.
					shake_camera(user, recoil + 1, recoil) //Shake the camera from recoil.

					M.bullet_act(projectile_to_fire) //Just apply the effects manually.
					projectile_to_fire.ammo.on_hit_mob(M,projectile_to_fire)

					if(!delete_bullet(projectile_to_fire)) del(projectile_to_fire)
					reload_into_chamber(user) //Reload into the chamber if the gun supports it.
					return
				else
					click_empty(user) //We want to return here, since they're trying to point blank them, not hit them.
					return
	return ..() //Pistolwhippin'

//----------------------------------------------------------
				//							\\
				// FIRE CYCLE RELATED PROCS \\
				//							\\
				//						   	\\
//----------------------------------------------------------

/obj/item/weapon/gun/proc/able_to_fire(var/mob/user as mob)
	/*
	Removed ishuman() check. There is no reason for it, as it just eats up more processing, and adding fingerprints during the fire cycle is silly.
	Consequently, predators are able to fire while cloaked.
	*/
	if(burst_toggled && burst_firing)
		return

	if(!user.IsAdvancedToolUser())
		user << "\red You don't have the dexterity to do this!"
		return

	if(trigger_safety)
		user << "\red The safety is on!"
		return

	if(world.time >= last_fired + fire_delay + extra_delay) //If not, check the last time it was fired.
		extra_delay = 0
		last_fired = world.time
	else
		if (world.time % 3) //to prevent spam
			user << "<span class='warning'>[src] is not ready to fire again!"
		return

	//I pray an object doesn't fire off a two handed weapon, since that would be...problematic.
	if(twohanded) //If we're not holding the weapon with both hands when we should.
		var/obj/item/weapon/twohanded/offhand/O = user.get_inactive_hand() //We have to check for this though, since the offhand can drop due to arm malfs, etc.
		if(!istype(O))
			unwield(user)
			user << "\red You need a more secure grip to fire this weapon!"
			return

	return 1

/obj/item/weapon/gun/proc/click_empty(mob/user = null)
	if (user)
		user.visible_message("*click click*", "\red <b>*click*</b>")
		playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	else
		src.visible_message("*click click*")
		playsound(src.loc, 'sound/weapons/empty.ogg', 100, 1)

//This proc applies some bonus effects to the shot/makes the message when a bullet is actually fired.
/obj/item/weapon/gun/proc/apply_bullet_effects(var/obj/item/projectile/projectile_to_fire, var/mob/user, var/i = 1, var/reflex = 0)
	if(user)
		projectile_to_fire.firer = user
		if(istype(user,/mob/living))
			projectile_to_fire.def_zone = user.zone_sel.selecting
		projectile_to_fire.dir = user.dir
		var/actual_sound = fire_sound
		if(active_attachable && !active_attachable.passive && active_attachable.shoot_sound)
		 //If we're firing from an attachment, use that noise instead.
			actual_sound = active_attachable.shoot_sound

		if(silenced)
			if((ammo && ammo.bonus_projectiles == 0) || i == 1) playsound(user, actual_sound, 8, 1)
		else
			if((ammo && ammo.bonus_projectiles == 0) || i == 1) playsound(user, actual_sound, 50, 1)
			if(i == 1)
				if(ammo_counter && current_mag)
					user.visible_message("<span class='warning'>[user] fires [src][reflex ? " by reflex":""]!</span>", \
					"<span class='warning'>You fire [src][reflex ? "by reflex":""]! \[<B>[current_mag.current_rounds-1]</b>/[current_mag.max_rounds]\]</span>", \
					"You hear a [istype(projectile_to_fire.ammo, /datum/ammo/bullet) ? "gunshot" : "blast"]!")
				else
					user.visible_message("<span class='warning'>[user] fires [src][reflex ? " by reflex":""]!</span>", \
					"<span class='warning'>You fire [src][reflex ? "by reflex":""]!</span>", \
					"You hear a [istype(projectile_to_fire.ammo, /datum/ammo/bullet) ? "gunshot" : "blast"]!")

	if(rail)
		if(rail.ranged_dmg_mod) projectile_to_fire.damage = round(projectile_to_fire.damage * rail.ranged_dmg_mod / 100)
	if(muzzle)
		if(muzzle.ranged_dmg_mod) projectile_to_fire.damage = round(projectile_to_fire.damage * muzzle.ranged_dmg_mod / 100)
	if(stock)
		if(stock.ranged_dmg_mod) projectile_to_fire.damage = round(projectile_to_fire.damage * stock.ranged_dmg_mod / 100)
	if(under)
		if(under.ranged_dmg_mod) projectile_to_fire.damage = round(projectile_to_fire.damage * under.ranged_dmg_mod / 100)
		/*BIPODS FUNCTION HERE
		if(istype(under,/obj/item/attachable/bipod) && prob(30))
			var/found = 0
			for(var/obj/structure/Q in range(1,user)) //This is probably inefficient as fuck <------ Yeah. It runs through this for every bullet on burst. DEBUG
				if(Q.throwpass == 1)
					found = 1
					break
			if(found)
				user << "\blue Your bipod keeps the weapon steady!"
				projectile_to_fire.damage = round(5 * projectile_to_fire.damage / 4) //Bipod gives a decent damage upgrade
		//Commenting this out until I can fix it. DEBUG DEBUG
		*/
	return 1

/obj/item/weapon/gun/proc/muzzle_flash(var/angle,var/mob/user as mob|obj)
	if(silenced || !muzzle_flash || isnull(angle)) return

	if(!istype(user) || !istype(user.loc,/turf)) return

	if(prob(65)) //Not all the time.
		var/layer = MOB_LAYER-0.1
		if(user && user.dir == SOUTH) //Sigh
			layer = MOB_LAYER+0.1

		var/image/flash = image('icons/obj/projectiles.dmi',user,muzzle_flash,layer)

		var/matrix/rotate = matrix() //Change the flash angle.
		rotate.Translate(0,5)
		rotate.Turn(angle)
		flash.transform = rotate

		for(var/mob/M in viewers(user))
			M << flash

		spawn(3) //Worst that can happen is the flash not being deleted if the parent is null.
			del(flash)