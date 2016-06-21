/*
ERROR CODES AND WHAT THEY MEAN:


ERROR CODE A1: null.ammopath while reloading. <------------ Only appears when reloading a weapon and switching the .ammo. Somehow the argument passed a null.ammo.
ERROR CODE U1: in_chamber while unloading magazine. <------------ Somehow a bullet was stuck in the chamber AFTER the gun fired and we tried to unload it.
ERROR CODE I1: in_chamber malfunctioned while firing. <------------ Right before the bullet is fired, the actual bullet isn't present or isn't a bullet.
ERROR CODE R1: negative current_rounds on examine. <------------ Applies to ammunition only. Ammunition should never have negative rounds on spawn.

NOTES


if(burst_toggled && burst_firing) return
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
That should be on for most procs that deal with the gun doing some action. We do not want
the gun to suddenly begin to fire when you're doing something else to it that could mess it up.

Some of this stuff Abby took directly from the old gun system, but I've done my best to get rid of
the things that aren't actually used or were used poorly. For a basic overview of how it all comes together:

Guns have ammo.
	Some guns have internal ammo that is never ejected.
		Ammo has an actual ammo datum attached that has the brunt of the effects for the bullet.

Guns tries to fire.
	Gun checks if it has a mag, then checks the ammo datum in the mag.
		If both are present, it creates a projectile and copies over some settings from the ammo datum.
			Then it "fires" the projectile a number of times that it has to.
				Then it is possible some casings are ejected.

*/


/*
Also inspired by Baystation.
There are four main ways to reload a gun. The magazine, which is counted as the default,
the handful of shells/bullets and is a single click for single bullet, and the speedloader
method that only works if the gun is completely empty (kind of like a mag).
Integrated feed system have their own thing.
*/
#define MAGAZINE 		1	//Regular ammo mags, the default for all guns and the most common method.
#define SPEEDLOADER 	2	//The gun takes a speedloader. Revolvers do this, but they also take handfuls.
#define HANDFUL			4	//The gun only accepts handfuls. This is a shotgun and revolver thing.
#define INTEGRATED		8	//Smartgun, or anything else with an ammo belt feed system.

/obj/item/weapon/gun
	name = "gun"
	desc = "Its a gun. It's pretty terrible, though."
	icon = 'icons/obj/gun.dmi'
	icon_state = ""
	var/icon_wielded = null
	var/icon_empty = null
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

	var/can_pointblank = 1
	var/fire_sound = 'sound/weapons/Gunshot.ogg'
	var/reload_sound = 'sound/weapons/empty.ogg'
	var/obj/item/projectile/in_chamber = null //What is currently "loaded"? Sort of a generic term.
	var/datum/ammo/ammo = null //The default ammo datum when a round is chambered. Null means it probably does its own thing.
	var/obj/item/ammo_magazine/current_mag = null //What magazine is currently loaded?
	var/mag_type = null  //The default magazine loaded into a projectile weapon for reverse lookups. Leave this null to do your own thing.
	var/mag_type_internal = null //If the weapon has an internal magazine, this is the way to do it. This will be used on New() if it exists.
	var/default_ammo = "/datum/ammo" //For stuff that doesn't use mags. Just fire it.
	var/reload_type = MAGAZINE //What sort of reload does it use? Defaults to mags.

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
	var/wielded = 0 //Do not set this in gun defines

	var/obj/item/attachable/muzzle = null //Attachable slots. Only one item per slot.
	var/obj/item/attachable/rail = null
	var/obj/item/attachable/under = null
	var/obj/item/attachable/stock = null

	var/obj/item/attachable/active_attachable = null //This will link to one of the above four, or remain null.

	var/firing_from_slot = "muzzle"
	var/muzzle_pixel_y = 15 //These determine the position of the overlay relative to the gun.
	var/muzzle_pixel_x = 33 //Ie. where the overlay should be placed depending on the slot.
	var/rail_pixel_y = 19 //They can go above normal values.
	var/rail_pixel_x = 28  //These defaults are all for the m41a, and should be changed according to the weapon.
	var/under_pixel_y = 13
	var/under_pixel_x = 21
	//Stocks do not have their own offsets.

	var/flashlight_on = 0 //Mounted flashlight stuff.
	var/flash_lum = 0

	var/burst_amount = 0 //How many shots can the weapon shoot in burst? If 0, you cannot toggle burst.
	var/burst_toggled = 0 //Is the weapon set to burst mode?
	var/burst_firing = 0 //Are you burst firing or not?
	var/is_bursting = 0 //Sentries use this. Regular guns do not.
	var/burst_delay = 0 //The delay in between shots. Lower = faster.

	icon_action_button = null //Adds it to the quick-icon list
	var/accuracy = 0 //Flat bonus/penalty due to the gun itself.
	var/dam_bonus = 0 //Flat bonus/penalty to bullet damage due to the gun itself.
	var/ammo_counter = 0 //M39s and M41s have this.
	var/autoejector = 1 //Automatically ejects spent magazines. Defaults to yes.
	var/found_on_mercs = 0 //For the randomizer.
	var/found_on_russians = 0 //For the randomizer.
	var/muzzle_flash = 1 //1 : small, 2: big? <---- Potentially something to add in later, a bigger or different flash.
	var/one_shot = 1 //For alternate fire weapons, does it fire 1 then revert, or continue?

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

		unwield()

		return ..()

	examine()
		..()
		if(current_mag && current_mag.current_rounds > 0)
			if(ammo_counter || ( reload_type == INTEGRATED ) )
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

	mob_can_equip(M as mob, slot)
		//Cannot equip wielded items or items burst firing.
		if(is_bursting || burst_firing) return
		unwield()
		return ..()

	attack_hand(mob/user as mob)
		var/obj/item/weapon/gun/in_hand = user.get_inactive_hand()
		if( in_hand == src && twohanded ) //It has to be held if it's a two hander.
			unload(user)
		else ..()

/obj/item/weapon/gun/attack_self(mob/user as mob)
	if (target)
		lower_aim()
		return

	if(twohanded)
		if(wielded) //Trying to unwield it
			unwield()
			user << "<span class='notice'>You are now carrying the [name] with one hand.</span>"
			return

		else //Trying to wield it
			if(user.get_inactive_hand())
				user << "<span class='warning'>You need your other hand to be empty.</span>"
				return
			wield()
			user << "<span class='notice'>You grab the [initial(name)] with both hands.</span>"

			var/obj/item/weapon/twohanded/offhand/O = new(user) ////Let's reserve his other hand~
			O.wielded = 1
			O.name = "[initial(name)] - offhand"
			O.desc = "Your second grip on the [initial(name)]"
			user.put_in_inactive_hand(O)
			return

	if(istype(src,/obj/item/weapon/gun))
		return src:unload(user)

	return ..()

//Clicking stuff onto the gun.
//Attachables & Reloading
/obj/item/weapon/gun/attackby(obj/item/I as obj, mob/user as mob)
	if(burst_toggled && burst_firing) return

	if(istype(I,/obj/item/ammo_magazine))
		reload(user,I)
		return

	if(!istype(I,/obj/item/attachable)) return

	var/obj/item/weapon/gun/in_hand = user.get_inactive_hand()
	if( in_hand != src && twohanded) //It has to be held if it's a two hander.
		user << "\blue Try holding \the [src] before you attempt to modify it."
		return

	var/obj/item/attachable/A = I

	if(!(src.type in A.guns_allowed))
		user << "\The [A] doesn't fit on [src]."
		return

	//Checks if they can attach the thing in the first place, like with fixed attachments.
	var/can_attach = 1
	switch(A.slot)
		if("rail")
			if(rail && rail.can_be_removed == 0) can_attach = 0
		if("muzzle")
			if(muzzle && muzzle.can_be_removed == 0) can_attach = 0
		if("under")
			if(under && under.can_be_removed == 0) can_attach = 0
		if("stock")
			if(stock && stock.can_be_removed == 0) can_attach = 0

	if(!can_attach)
		user << "The attachment on [src]'s [A.slot] cannot be removed."
		return

	user.visible_message("\blue [user] begins field-modifying their [src]..","\blue You begin field modifying \the [src].")
	if(do_after(user,60))
		user.visible_message("\blue [user] attaches \the [A] to \the [src].","\blue You attach \the [A] to \the [src].")
		user.drop_item(A)
		A.Attach(src)
		update_attachables()
		if(reload_sound)
			playsound(user, reload_sound, 100, 1)

	return

//Quick helper proc to not copy paste this a billion times.
/obj/item/weapon/gun/proc/replace_ammo(var/mob/user = null, var/obj/item/ammo_magazine/magazine)
	var/ammopath = text2path(magazine.default_ammo)
	if(!ammopath || isnull(ammopath))
		if(user) user << "Something went horribly wrong. Ahelp the following: ERROR CODE A1: null.ammopath while reloading."
		return
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

	if(magazine.current_rounds == 0)
		if(user) user << "That [magazine.name] is empty!"
		return

	if(user)
		var/obj/item/ammo_magazine/in_hand = user.get_inactive_hand()
		if( in_hand != src ) //It has to be held.
			user << "You have to hold \the [src] to reload!"
			return

	//Adding returns so we don't update_icon() when we don't need to. Only update_icon() when something changes.
	switch(reload_type)
		if(MAGAZINE)
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
						replace_ammo(user,magazine)
						user.drop_from_inventory(magazine) //Click!
						magazine.loc = src //Jam that sucker in there.
						current_mag = magazine
						user << "\blue You load \the [magazine] into \the [src]!"
						if(reload_sound) playsound(user, reload_sound, 100, 1)
					else
						user << "Your reload was interrupted."
						return
				else
					replace_ammo(,magazine)
					magazine.loc = src
					current_mag = magazine

		if(SPEEDLOADER & HANDFUL)
			var/obj/item/ammo_magazine/revolver/internal/cylinder = current_mag
			if(istype(magazine, /obj/item/ammo_magazine/handful)) //Looks like we're loading via handful.
				//We need to determine a few things before running the reload itself. We normally wouldn't need to check on all of them, but handfuls can get deleted.
				if(!cylinder.cylinder_closed && magazine.current_rounds > 0  && cylinder.caliber == magazine.caliber )
					replace_ammo(user, magazine) //We are going to replace the ammo just in case.
					cylinder.transfer_ammo(magazine,cylinder,user,1) //Two conditions above are checked in this proc, but we have to run them anyway.
					cylinder.cylinder_closed = !cylinder.cylinder_closed //Close it up.
				//If bullets still remain in the gun, we want to check if the caliber matches and if the actual ammo matches.
				else if(cylinder.default_ammo == magazine.default_ammo) //Ammo datums match, let's see if they are compatible.
					if(cylinder.transfer_ammo(magazine,cylinder,user,1)) //Looks like it returned positive, so make casing.
						make_casing(1)
					else
						return //No go.
				else //Not the right kind of ammo.
					if(user) user << "\blue \The [cylinder] is already loaded with some other ammo. Better not mix them up."
					return
				if(reload_sound && user) playsound(user, 'sound/weapons/revolver_load3.ogg', 100, 1)//Reloading by hand.
			else //So if it's not a handful, it's an actual speedloader.
				if(!cylinder.cylinder_closed) //If the cylinder is exposed, we can load a speedloader.
					if(cylinder.transfer_ammo(magazine,cylinder,user,magazine.current_rounds))//Make sure we're successful.
						replace_ammo(user, magazine) //We want to replace the ammo ahead of time, but not necessary here.
						playsound(src, reload_sound, 100, 1) // Reloading via speedloader.
						cylinder.cylinder_closed = !cylinder.cylinder_closed //Success.
					else //If we failed to load it for whatever reason, cancel out.
						return
				else //Otherwise no go.
					if(user) user << "\red You can't load a speedloader when the cylinder is closed!"
					return

		if(HANDFUL) //DEBUG
			if(istype(magazine, /obj/item/ammo_magazine/handful))
				if( current_mag.current_rounds!=current_mag.max_rounds ) //We actually have some rounds to transfer.
					burst_firing = 0
					burst_toggled = 0
					is_bursting = 0
					active_attachable = null

					current_mag.transfer_ammo(magazine,current_mag,user,1)

					if(user) playsound(user, reload_sound, 100, 1)
				else
					user << "\blue \The [current_mag] is already full."

		if(INTEGRATED) //They have their own snowflake reload, don't take mags.
			return

	update_icon()
	return 1

//Drop out the magazine. Keep the ammo type for next time so we don't need to replace it every time.
/obj/item/weapon/gun/proc/unload(var/mob/user as mob, var/reload_override = 0) //Override for reloading mags after shooting.
	if(burst_toggled && burst_firing && !reload_override) return

	if(!current_mag || isnull(current_mag) || current_mag.loc != src)
		if(user) user << "It's already empty or doesn't need to be unloaded."
		return

	//Switches are far, far more efficient than if chains.
	switch(reload_type)
		if(MAGAZINE)
			if(!user.put_in_active_hand(current_mag) && !user.put_in_inactive_hand(current_mag))
				current_mag.loc = get_turf(src)
			playsound(src, 'sound/weapons/flipblade.ogg', 20, 1)
			if(user) user << "\blue You unload the magazine from \the [src]."
			make_casing(1) //override for ejecting the mag.
			current_mag = null

		if(SPEEDLOADER & HANDFUL) //Only revolvers use this.
			var/obj/item/ammo_magazine/revolver/internal/cylinder = current_mag
			if(cylinder.cylinder_closed) //If it's actually closed.
				playsound(src, 'sound/weapons/flipblade.ogg', 20, 1)
				if(user) user << "\blue You clear the cylinder of \the [src]."
				make_casing(1)
				current_mag.create_handful(current_mag, user)
				cylinder.cylinder_closed = !cylinder.cylinder_closed

		if(HANDFUL) //Only shotties will use this. //DEBUG
			//It will unload all the live ammo into a handful.
			playsound(src, 'sound/weapons/flipblade.ogg', 20, 1)
			if(user) user << "\blue You remove the shells from \the [src]."
			switch(current_mag.handle_casing)
				if(HOLD_CASINGS) //For the double shotty.
					make_casing(1)
					current_mag.create_handful(current_mag, user)

				if(CYCLE_CASINGS) //For the pump.
					return //DEBUG TO DO

				if(EJECT_CASINGS) //Everything else.
					if(current_mag.current_rounds > current_mag.handful_max_rounds) // Do it twice.
						current_mag.create_handful(current_mag, user)
					current_mag.create_handful(current_mag, user)

		if(INTEGRATED) //Can't unload these at all, so we just abort. Easy.
			return

	if(in_chamber)
		//del(in_chamber) <----- We don't want this. If there is an in_chamber, something has gone wrong and we must find out what it was.
		user << "Something went horribly wrong. Ahelp the following: ERROR CODE U1: in_chamber while unloading magazine."
	update_icon()
	return

//Since reloading and casings are closely related, placing this here ~N
/obj/item/weapon/gun/proc/make_casing(var/casing_override) //casing_override is for things like unload() instead of going through Fire().
	if(current_mag && ammo) //Just in case something somehow breaks.
		var/sound_to_play = pick('sound/weapons/bulletcasing_fall2.ogg','sound/weapons/bulletcasing_fall.ogg')
		//spawn(0) //Parallel processing. //DEBUG
		switch(current_mag.handle_casing) //No case for caseless ammo as nothing happens.
			if(EJECT_CASINGS)
				if(!casing_override)
					/*
					//This works, but it's also pretty slow in comparison to the updated method.
					var/turf/current_turf = get_turf(src)
					var/obj/item/ammo_casing/casing = locate() in current_turf
					var/icon/I = new( 'icons/obj/ammo.dmi', current_mag.icon_spent, pick(1,2,4,5,6,8,9,10) ) //Feeding dir is faster than doing Turn().
					I.Shift(pick(1,2,4,5,6,8,9,10),rand(0,11))
					if(casing) //If there is already something on the ground, takes the firs thing it finds. Can take a long time if there are a lot of things.
						//Still better than making a billion casings.
						if(casing.name != "spent casings")
							casing.name += "s"
						I.Blend(casing.icon,ICON_UNDERLAY) //We want to overlay it on top.
						casing.icon = I
					else //If not, make one.
						var/obj/item/ammo_casing/new_casing = new(current_turf)
						new_casing.icon = I
					playsound(current_turf, sound_to_play, 20, 1)
					*/
					//This is far, far faster.
					var/turf/current_turf = get_turf(src)
					var/obj/item/ammo_casing/bullet/casing = locate() in current_turf
					if(!casing)
						casing = new(current_turf) //Don't need to do anything else.
					else
						casing.casings += 1
						casing.update_icon()

			if(HOLD_CASINGS)
				/*
				//Leaving this here because I think it's excellent code in terms of something you can do. But it is not the
				//most efficient. Also, this particular example crashes the client upon Blend(). Not sure what is causing it,
				//but the code was entirely replaced so it's irrelevant now. ~N
				//If the gun has spent shells and we either have no ammo remaining or we're reloading it on the go.
				if(current_mag.casings_to_eject.len && casing_override) //We have some spent casings to eject.
					var/turf/current_turf = get_turf(src)
					var/obj/item/ammo_casing/casing = locate() in current_turf
					var/icon/G

					if(!casing)
						//Feeding dir is faster than doing Turn().
						G = new( 'icons/obj/ammo.dmi', current_mag.icon_spent, pick(1,2,4,5,6,8,9,10) ) //We make a new icon.
						G.Shift(pick(1,2,4,5,6,8,9,10),rand(0,11)) //Shift it randomy.
						var/obj/item/ammo_casing/new_casing = new(current_turf) //Then we create a new casing.
						new_casing.icon = G //We give this new casing the icon we just generated.
						casing = new_casing //Our casing from earlier is now this csaing.
						current_mag.casings_to_eject.Cut(1,2) //Cut the list so that it's one less.
						playsound(current_turf, sound_to_play, 20, 1) //Play the sound.

					G = casing.icon //Get the icon from the casing icon if it spawned or was there previously.
					var/i
					for(i = 1 to current_mag.casings_to_eject.len) //We want to run this for each item in the list.
						var/icon/I = new( 'icons/obj/ammo.dmi', current_mag.icon_spent, pick(1,2,4,5,6,8,9,10) )
						I.Shift(pick(1,2,4,5,6,8,9,10),rand(0,11))
						G.Blend(I,ICON_OVERLAY) //<---- Crashes the client. //Blend them two in, with I overlaying what's already there.
						playsound(current_turf, sound_to_play, 20, 1)

					G.Blend(casing.icon,ICON_UNDERLAY)
					casing.icon = G
					if(casing.name != "spent casings")
						casing.name += "s"
					current_mag.casings_to_eject = list() //Empty list.

				else if(!casing_override)//So we're not reloading/emptying, we're firing the gun.
					//I would add a check here for attachables, but you can't fit the masterkey on a revolver/shotgun.
					current_mag.casings_to_eject += ammo.casing_type //Other attachables are processed beforehand and don't matter here.
				*/
				//Hilariously faster than the example above and doesn't crash.
				if(current_mag.casings_to_eject.len && casing_override) //We have some spent casings to eject.
					var/turf/current_turf = get_turf(src) //Figure out the turf we're on.
					var/obj/item/ammo_casing/bullet/casing = locate() in current_turf //Could cause issues if there are a lot of objects.
					if(!casing) //If there is no casing, make one.
						casing = new(current_turf) //Don't need to do anything else.
						current_mag.casings_to_eject.Cut(1,2)
						playsound(current_turf, sound_to_play, 20, 1)
					//Then do the rest of the operation.
					casing.casings += current_mag.casings_to_eject.len
					casing.update_icon()
					current_mag.casings_to_eject = list()
					playsound(current_turf, sound_to_play, 20, 1)
				else if(!casing_override)
					//I would add a check here for attachables, but you can't fit the masterkey on a revolver/shotgun.
					current_mag.casings_to_eject += ammo.casing_type //Other attachables are processed beforehand and don't matter here.

			if(CYCLE_CASINGS) //DEBUG
				if(current_mag.casings_to_eject.len && casing_override) //We have a casing to eject and we're pumping it. Not just shooting.
					var/casingtype = text2path(current_mag.casings_to_eject[1]) //Get the path.
					new casingtype(get_turf(src))
					playsound(src, sound_to_play, 20, 1)
					current_mag.casings_to_eject = list() //Empty list.
	return

/obj/item/weapon/gun/proc/special_check(var/mob/M) //Placeholder for any special checks, like PREDATOR WEAPONZ
	return 1

/obj/item/weapon/gun/proc/ready_to_fire() // DEBUG
	if(world.time >= last_fired + fire_delay + extra_delay) //If not, check the last time it was fired.
		extra_delay = 0
		last_fired = world.time
		return 1
	else
		return 0

/obj/item/weapon/gun/proc/has_attachment(var/A)
	if(!A)
		return 0
	if(istype(muzzle,A)) return 1
	if(istype(under,A)) return 1
	if(istype(rail,A)) return 1
	if(istype(stock,A)) return 1
	return 0

/obj/item/weapon/gun/proc/unwield()
	if(!twohanded || !wielded) return //If we're not actually carrying it with both hands or it's a one handed weapon.
	wielded = 0
	name = "[initial(name)]"
	item_state = "[initial(item_state)]"
	if(usr && ishuman(usr))
		var/mob/living/carbon/human/wielder = usr
		wielder.update_inv_l_hand(0) //Updating invs is more efficient than updating the entire icon set.
		wielder.update_inv_r_hand()
		var/obj/item/weapon/twohanded/O = wielder.get_inactive_hand()
		if(istype(O))
			O.unwield()

/obj/item/weapon/gun/proc/wield()
	if(!twohanded) return
	wielded = 1
	name = "[initial(name)] (Wielded)"
	if(!isnull(icon_wielded))
		item_state = icon_wielded
	else
		item_state = "[initial(item_state)]-w"
	if(usr && ishuman(usr))
		usr:update_inv_l_hand(0)
		usr:update_inv_r_hand()

/*
Here we have throwing and dropping related procs.
This should fix some issues with throwing mag harnessed guns when
they're not supposed to be thrown. Either way, this fix
should be alright.
*/
/obj/item/weapon/gun/proc/harness_check(mob/user as mob)
	if(user && ishuman(user))
		var/mob/living/carbon/human/owner = user
		if(has_attachment(/obj/item/attachable/magnetic_harness) || istype(src,/obj/item/weapon/gun/smartgun))
			var/obj/item/I = owner.wear_suit
			if(istype(I,/obj/item/clothing/suit/storage/marine) || istype(I,/obj/item/clothing/suit/storage/marine_smartgun_armor))
				return 1
	return

/obj/item/weapon/gun/throw_at(atom/target, range, speed, thrower)
	if( harness_check(thrower) )
		usr << "\red The [src] clanks on the ground."
		return
	else ..()

/*
Note: pickup and dropped on weapons must have both the ..() to update zoom AND twohanded,
As sniper rifles have both and weapon mods can change them as well. ..() deals with zoom only.
*/
/obj/item/weapon/gun/dropped(mob/user as mob)
	..()

	stop_aim()
	if (user && user.client)
		user.client.remove_gun_icons()

	if(flashlight_on && src.loc != user)
		user.SetLuminosity(-flash_lum)
		SetLuminosity(flash_lum)

	if(harness_check(user))
		var/mob/living/carbon/human/owner = user
		unwield()
		spawn(3)
			if(isnull(owner.s_store) && isturf(src.loc))
				var/obj/item/I = owner.wear_suit
				owner.equip_to_slot_if_possible(src,slot_s_store)
				if(owner.s_store == src) user << "\red The [src] snaps into place on [I]."
				owner.update_inv_s_store()
		return

	unwield()

/obj/item/weapon/gun/pickup(mob/user)
	..()

	if(flashlight_on && src.loc != user)
		user.SetLuminosity(flash_lum)
		SetLuminosity(0)

	unwield()
	return

/obj/item/weapon/gun/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params)
	if(flag)	return ..() //It's adjacent, is the user, or is on the user's person
	if(!istype(A)) return

	if(burst_firing && burst_toggled) return

	if(user && user.client && user.client.gun_mode && !(A in target))
		PreFire(A,user,params) //They're using the new gun system, locate what they're aiming at.
	else
		Fire(A,user,params) //Otherwise, fire normally.
	return

/obj/item/weapon/gun/proc/load_into_chamber()

	if(in_chamber)
		usr << "load_into_chamber() returned 1"// DEBUG
		return 1 //Already set!

	var/datum/ammo/chambered = ammo //We're going to make a generic ammo datum in case we need to load from an alternative source.

	if(active_attachable)
		if(active_attachable.ammo_type)
			if(active_attachable.current_ammo <= 0)
				if(usr) usr << "\blue \The [active_attachable.name] is empty!"
				active_attachable = null
				return 0

			chambered = active_attachable.ammo
			chambered.current_gun = src
		else
			if(active_attachable.current_ammo <= 0 || active_attachable.passive) //It's something like a flashlight or zoom scope.
				active_attachable = null

	if(isnull(active_attachable)) //After all that, if we're not using an attachable, check for the magazine.
		if(!current_mag || isnull(current_mag) || current_mag.current_rounds <= 0) return 0 //If there is no active mag or it has negative rounds, somehow.


	if(!chambered || isnull(chambered)) return 0 //Our ammo datum is missing. We need one, and it should have set when we reloaded, so, abort.

	var/obj/item/projectile/P = new(src) //New bullet!
	P.ammo = chambered //Share the ammo type. This does all the heavy lifting.
	P.name = P.ammo.name
	P.icon_state = P.ammo.icon_state //Make it look fancy.
	P.damage = P.ammo.damage
	P.damage += src.dam_bonus
	P.damage_type = P.ammo.damage_type
	in_chamber = P
	return 1

/obj/item/weapon/gun/proc/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, atom/original_target as mob|obj|turf)
	set waitfor = 0

	if(burst_toggled && burst_firing) return

	if (!user.IsAdvancedToolUser())
		user << "\red You don't have the dexterity to do this!"
		return

	if(user)
		dir = user.dir //What?

	if(ishuman(user))
		var/obj/item/weapon/twohanded/offhand/O = user.get_inactive_hand()
		if(twohanded && !istype(O))
			user << "\red You need a more secure grip to fire this weapon!"
			return
		if(user:gloves)
			var/obj/item/clothing/gloves/yautja/Y = user:gloves
			if(istype(Y) && Y.cloaked)
				Y.decloak(user)
				return 0

		add_fingerprint(user)

	var/turf/curloc = get_turf(user)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return

	//DEBUG Check back on this. This shouldn't happen. I'm guessing it's for point blank.
	//Pretty sure this is for shooting yourself via point blanking only.
	if(targloc == curloc && in_chamber)
		target.bullet_act(in_chamber)
		sleep(-1)
		del(in_chamber)
		update_icon()
		return
	else if (targloc == curloc)
		return

	if (!ready_to_fire())
		if (world.time % 3) //to prevent spam
			user << "<span class='warning'>[src] is not ready to fire again!"
		return

	/*
	This is where the grenade launcher and flame thrower function as attachments.
	This is also a general check to see if the attachment can fire in the first place.
	*/
	if(active_attachable && !active_attachable.passive) //Attachment activated and isn't a flashlight or something.
		burst_toggled = 0 //We don't want to mess with burst while this is on.
		if(active_attachable.fire_attachment(target,src,user)) //If it actually fired properly.
		/*
		It'll return 0 if it's a Fire() proc instead, otherwise it will always return 1.
		So here we know it's either the grenade launcher or flamethrower.
		It doesn't really matter what it is, the result will be the same.
		*/
			if(active_attachable.current_ammo <= 0) click_empty(user) //If it's empty, let them know.
			active_attachable = null //Set it to null anyway, it's done.
			return
			//If there's more to the attachment, it will be processed farther down, through in_chamber and regular bullet act.

	/*
	This is where burst is established for the proceeding section. Which just means the proc loops around that many times.
	If burst = 1, you must null it if you ever return during the for() cycle. If for whatever reason burst is left on while
	the gun is not firing, it will break reloading.
	*/
	var/bullets_fired = 1
	if(burst_toggled && burst_amount > 0)
		bullets_fired = burst_amount
		burst_firing = 1

	var/i //Weirdly, this way is supposed to be less laggy. by 500%
	for(i = 1 to bullets_fired)
		if(isnull(src)) //Something disappeared/dropped in between.
			break
/*
		if(istype(user,/mob/living/carbon/human) && src.loc != user) //Had a human. dont need em anyway really
			click_empty(user)
			break
*/
		if(!load_into_chamber()) //This also checks for a null magazine, and loads the chamber with a round.
			click_empty(user)
			break

		if(!in_chamber) //Guns must have something in the chamber. It doesn't necessarily have to be a bullet.
			click_empty(user)
			break

		if(!target || isnull(target))
			target = targloc

		in_chamber.shot_from = src
		if(!isnull(original_target) && target != original_target) //Save the original thing that we shot at.
			in_chamber.original = original_target
		else
			in_chamber.original = target
		if(user)
			in_chamber.firer = user
			if(istype(user,/mob/living))
				in_chamber.def_zone = user.zone_sel.selecting
			in_chamber.dir = user.dir
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
						"You hear a [istype(in_chamber.ammo, /datum/ammo/bullet) ? "gunshot" : "blast"]!")
					else
						user.visible_message("<span class='warning'>[user] fires [src][reflex ? " by reflex":""]!</span>", \
						"<span class='warning'>You fire [src][reflex ? "by reflex":""]!</span>", \
						"You hear a [istype(in_chamber.ammo, /datum/ammo/bullet) ? "gunshot" : "blast"]!")

		if(rail)
			if(rail.ranged_dmg_mod) in_chamber.damage = round(in_chamber.damage * rail.ranged_dmg_mod / 100)
		if(muzzle)
			if(muzzle.ranged_dmg_mod) in_chamber.damage = round(in_chamber.damage * muzzle.ranged_dmg_mod / 100)
		if(stock)
			if(stock.ranged_dmg_mod) in_chamber.damage = round(in_chamber.damage * stock.ranged_dmg_mod / 100)
		if(under)
			if(under.ranged_dmg_mod) in_chamber.damage = round(in_chamber.damage * under.ranged_dmg_mod / 100)
			//BIPODS FUNCTION HERE
			if(istype(under,/obj/item/attachable/bipod) && prob(30))
				var/found = 0
				for(var/obj/structure/Q in range(1,user)) //This is probably inefficient as fuck <------ Yeah. It runs through this for every bullet on burst. DEBUG
					if(Q.throwpass == 1)
						found = 1
						break
				if(found)
					user << "\blue Your bipod keeps the weapon steady!"
					in_chamber.damage = round(5 * in_chamber.damage / 4) //Bipod gives a decent damage upgrade

		//Scatter chance is 20% by default, 10% flat with single shot.
		if(ammo && ammo.never_scatters == 0 && (prob(5) || (burst_amount > 1 && burst_toggled)))
			in_chamber.scatter_chance += (burst_amount * 3) //Much higher chance on a burst.

			if(prob(in_chamber.scatter_chance) && (ammo && ammo.never_scatters == 0)) //Scattered!
				var/scatter_x = rand(-1,1)
				var/scatter_y = rand(-1,1)
				var/turf/new_target = locate(targloc.x + round(scatter_x),targloc.y + round(scatter_y),targloc.z) //Locate an adjacent turf.
				if(istype(new_target) && !isnull(new_target))
					target = new_target
					targloc = target
					in_chamber.original = target

		if(params)
			var/list/mouse_control = params2list(params)
			if(mouse_control["icon-x"])
				in_chamber.p_x = text2num(mouse_control["icon-x"])
			if(mouse_control["icon-y"])
				in_chamber.p_y = text2num(mouse_control["icon-y"])

		if(recoil > 0 && ishuman(user))
			shake_camera(user, recoil + 1, recoil)

		//Finally, make with the pew pew!
		if(!in_chamber || !istype(in_chamber,/obj) || isnull(in_chamber))
			usr << "Your gun is malfunctioning. Ahelp the following: ERROR CODE I1: in_chamber malfunctioned while firing."
			burst_firing = 0
			return

		if(get_turf(target) != get_turf(user))
			//in_chamber.invisibility = 100 // Let's make it invisible when it actually leaves the gun, so it doesn't appear below the character.
			//var/obj/to_be_fired = in_chamber
			//spawn(0) //DEBUG
			//	if(to_be_fired) to_be_fired.invisibility = 0 // If it still exists, let's make it visible again.
//vvvvvvvvvvvvvvvvvvvvvv
			in_chamber.fire_at(target,user,src,ammo.max_range,ammo.shell_speed)
//^^^^^^^^^^^^^^^^^^^^^^
		else // This happens in very rare circumstances when you're moving a lot while burst firing, so I'm going to toss it up to guns jamming.
			click_empty(user)
			user << "The gun jammed! You'll need a second to get it fixed."
			burst_firing = 0 // Also want to turn off bursting, in case that was on. It probably was.
			del(in_chamber) // We want to get rid of this, otherwise the gun won't fire again.
			in_chamber = null // Just to be sure.
			extra_delay = 2 + (burst_delay + extra_delay)*2 // Some extra delay before firing again.
			break


		//>>POST PROCESSING AND CLEANUP BEGIN HERE.<<
		in_chamber = null //Now we absolve all knowledge of it. Its the targets problem now

		//Casing handling.
		make_casing() // Drop a casing if needed.
		//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

		if(target)
			var/angle = round(Get_Angle(user,target))
			muzzle_flash(angle)

		/*
		ATTACHMENT POST PROCESSING
		This should only apply to the masterkey, since it's the only attachment that shoots through Fire()
		instead of its own thing through fire_attachment(). If any other bullet attachments are added, they would fire here.
		*/
		if(active_attachable && active_attachable.current_ammo > 0) // If we fired, but still have ammo.
			active_attachable.current_ammo-- // Subtract ammo.
			if(!active_attachable.continuous) // Shouldn't be called on, but in case something that uses Fire() is added that is toggled.
				active_attachable = null // Set it to null for next activation. Again, this isn't really going to happen.

		//REGULAR MAGAZINE POST PROCESSING
		else //You fired a regular bullet from the magazine.
			if(current_mag)  //If there is a mag, as there should be.
				current_mag.current_rounds-- //Reduce ammo.
				current_mag.update_icon() //Update the icon if it's out of ammo, otherwise keep it the same.
				//This is where the magazine is auto-ejected.
				if(current_mag.current_rounds <= 0 && autoejector) //It shouldn't be possible to get negative rounds,but who knows.
					if(user)
						playsound(user, current_mag.sound_empty, 50, 1)
					else
						playsound(src.loc, current_mag.sound_empty, 50, 1)
					unload(user,1)

		if(i < bullets_fired) //We still have some bullets to fire.
			extra_delay = min(extra_delay+(burst_delay*2), fire_delay*3) // The more bullets you shoot, the more delay there is, but no more than thrice the regular delay.
			sleep(burst_delay)

	burst_firing = 0 //We always want to turn off burst when we're done.
	return

/obj/item/weapon/gun/proc/muzzle_flash(var/angle)
	if(silenced || !muzzle_flash || isnull(angle)) return
	var/mob/user = src.loc
	if(!istype(user) || !istype(user.loc,/turf)) return
	if(prob(65)) //Not all the time.
		var/layer = MOB_LAYER-0.1
		if(usr && usr.dir == SOUTH) //Sigh
			layer = MOB_LAYER+0.1

		var/image/flash = image('icons/obj/projectiles.dmi',user,"muzzle_flash",layer)

		var/matrix/rotate = matrix() //Change the flash angle.
		rotate.Translate(0,5)
		rotate.Turn(angle)
		flash.transform = rotate

		for(var/mob/M in viewers(user))
			M << flash

		spawn(3) //Worst that can happen is the flash not being deleted if the parent is null.
			del(flash)

/obj/item/weapon/gun/proc/click_empty(mob/user = null)
	if (user)
		user.visible_message("*click click*", "\red <b>*click*</b>")
		playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	else
		src.visible_message("*click click*")
		playsound(src.loc, 'sound/weapons/empty.ogg', 100, 1)

/obj/item/weapon/gun/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	//Suicide handling.
	if (M == user && user.zone_sel.selecting == "mouth" && !mouthshoot && can_pointblank)
		mouthshoot = 1
		M.visible_message("\red [user] sticks their gun in their mouth, ready to pull the trigger...")
		if(!do_after(user, 40))
			M.visible_message("\blue [user] decided life was worth living")
			mouthshoot = 0
			return
		if (load_into_chamber())
			user.visible_message("<span class = 'warning'>[user] pulls the trigger.</span>")
			if(silenced)
				playsound(user, fire_sound, 10, 1)
			else
				playsound(user, fire_sound, 50, 1)
			if (in_chamber.damage_type != HALLOSS)
				user.apply_damage(in_chamber.damage*2.5, in_chamber.damage_type, "head", used_weapon = "Point blank shot in the mouth with \a [in_chamber]", sharp=1)
				user.death()
			else
				user << "<span class = 'notice'>Ow...</span>"
				user.apply_effect(110,AGONY,0)
			del(in_chamber)
			make_casing()
			mouthshoot = 0
			return
		else
			click_empty(user)
			mouthshoot = 0
			return

	if (load_into_chamber())
		//Point blank shooting if on harm intent or target we were targeting.
		if(user.a_intent == "hurt" && can_pointblank)
			user.visible_message("\red <b> \The [user] fires \the [src] point blank at [M]!</b>")
			if(istype(in_chamber)) in_chamber.damage *= 1.1
			burst_toggled = 0 //NOPE.jpg
			burst_firing = 0
			Fire(M,user)
			return
//		else if(target && M in target)
//			Fire(M,user) ///Otherwise, shoot!
//			return
	else
		return ..() //Pistolwhippin'


/obj/item/weapon/gun/proc/update_attachables()
	overlays.Cut()
	if(rail)
		var/flash = 0
		var/image/I
		if(rail.light_mod) //Currently only rail-mounted flashlights.
			if(flashlight_on)
				I = new(rail.icon, "[rail.icon_state]-on")
				I.icon_state = "[rail.icon_state]-on"
				flash = 1
		if(!flash)
			I = new(rail.icon, rail.icon_state)
			I.icon_state = rail.icon_state
		I.pixel_x = src.rail_pixel_x - rail.pixel_shift_x
		I.pixel_y = src.rail_pixel_y - rail.pixel_shift_y
		overlays += I
	if(muzzle)
		var/image/I = new(muzzle.icon, muzzle.icon_state)
		I.icon_state = muzzle.icon_state
		I.pixel_x = src.muzzle_pixel_x - muzzle.pixel_shift_x
		I.pixel_y = src.muzzle_pixel_y - muzzle.pixel_shift_y
		overlays += I
	if(under)
		var/image/I = new(under.icon, under.icon_state)
		I.icon_state = under.icon_state
		I.pixel_x = src.under_pixel_x - under.pixel_shift_x
		I.pixel_y = src.under_pixel_y - under.pixel_shift_y
		overlays += I
	if(stock)
		var/image/I = new(stock.icon, stock.icon_state)
		I.icon_state = stock.icon_state
		I.pixel_x = src.under_pixel_x - stock.pixel_shift_x
		I.pixel_y = src.under_pixel_y - stock.pixel_shift_y
		overlays += I


//VERBS START HERE


/obj/item/weapon/gun/verb/field_strip()
	set category = "Weapons"
	set name = "Field Strip Weapon"
	set desc = "Remove all attachables from a weapon."
	set src in usr

	if(burst_toggled && burst_firing) return

	if(!usr.canmove || usr.stat || usr.restrained() || !usr.loc)
		usr << "Not right now."
		return

	if(!rail && !muzzle && !under && !stock)
		usr << "This weapon has no attachables. You can only field strip enhanced weapons."
		return

	usr.visible_message("\blue [usr] begins field stripping their [src].","\blue You begin field-stripping your [src].")
	if(!do_after(usr,40))
		return

	if(rail && rail.can_be_removed)
		usr << "You remove the weapon's [rail]."
		rail.Detach(src)
	if(muzzle && muzzle.can_be_removed)
		usr << "You remove the weapon's [muzzle]."
		muzzle.Detach(src)
	if(under && under.can_be_removed)
		usr << "You remove the weapon's [under]."
		under.Detach(src)
	if(stock && stock.can_be_removed)
		usr << "You remove the weapon's [stock]."
		stock.Detach(src)

	playsound(src,'sound/machines/click.ogg', 50, 1)
	update_attachables()

/obj/item/weapon/gun/verb/toggle_burst()
	set category = "Weapons"
	set name = "Toggle Burst Fire Mode"
	set desc = "Toggle on or off your weapon burst mode, if it has one. Greatly reduces accuracy."
	set src in usr

	if(burst_firing) return //We don't want to mess with this WHILE the gun is firing.

	if(!usr.canmove || usr.stat || usr.restrained() || !usr.loc)
		usr << "Not right now."
		return

	if(!burst_amount)
		usr << "This weapon does not have a burst fire mode."
		return

	playsound(src.loc,'sound/machines/click.ogg', 50, 1)
	burst_toggled = !burst_toggled
	if(burst_toggled)
		usr << "\icon[src] You <B>enable</b> the [src]'s burst fire mode."
	else
		usr << "\icon[src] You <B>disable</b> the [src]'s burst fire mode."

	return

/obj/item/weapon/gun/verb/empty_mag()
	set category = "Weapons"
	set name = "Unload Magazine"
	set desc = "Remove the magazine from your current gun and drop it on the ground."
	set src in usr

	if(burst_toggled && burst_firing) return

	if(!ishuman(usr)) return
	if(!usr.canmove || usr.stat || usr.restrained() || !usr.loc || !isturf(usr.loc))
		usr << "Not right now."
		return

	unload(usr)

	return

/obj/item/weapon/gun/verb/activate_attachment()
	set category = "Weapons"
	set name = "Load From Attachment"
	set desc = "Load from a gun attachment, such as a mounted grenade launcher, shotgun, or flamethrower."
	set src in usr

	if(burst_toggled && burst_firing) return //We don't want to mess with this when burst is on. //DEBUG

	if(!usr.canmove || usr.stat || usr.restrained() || !usr.loc || !isturf(usr.loc))
		usr << "Not right now."
		return

	var/list/usable_attachments = list() //Basic list of attachments to compare later.
	if(rail && rail.can_activate) usable_attachments[rail.name] = rail
	if(under && under.can_activate) usable_attachments[under.name] = under
	if(stock  && stock.can_activate) usable_attachments[stock.name] = stock
	if(muzzle && muzzle.can_activate) usable_attachments[muzzle.name] = muzzle

	if(usable_attachments.len <= 0) //No usable attachments.
		usr << "This weapon does not have any attachments."
		return

	if(usable_attachments.len == 1) //Activates the only attachment if there is only one.
		if(active_attachable && !active_attachable.passive) //In case the attach is passive like the flashlight/scope.
			usr << "You disable the [active_attachable.name]."
			playsound(src.loc,active_attachable.activation_sound, 50, 1)
			active_attachable = null
			return
		else
			var/activate_this = usable_attachments[1]
			active_attachable = usable_attachments[activate_this]

	else
		var/list/attachment_names = list() //Name list, since otherwise we would reference the object path itself in the choice menu.
		for(var/attachment_found in usable_attachments)
			attachment_names += attachment_found
		if(active_attachable)
			attachment_names += "Cancel Active"
		else
			attachment_names += "Cancel"

		//If you click on anything but the attachment name, it'll cancel anything active.
		var/choice = input("Which attachment to activate?") as null|anything in attachment_names

		if(src.loc != usr) //Dropped or something.
			return

		if(!choice || choice == "Cancel" || choice == "Cancel Active")
			if(active_attachable  && !active_attachable.passive)
				usr << "You disable the [active_attachable.name]."
				playsound(src.loc,active_attachable.activation_sound, 50, 1)
				active_attachable = null
				return

		var/obj/item/attachable/activate_this = usable_attachments[choice]
		if(activate_this && activate_this.loc == src) //If it still exists at all and held on the gun.
			active_attachable = activate_this

		if(!active_attachable)
			usr << "Nothing happened!"
			return

	usr << "You toggle the [active_attachable.name]."
	active_attachable.activate_attachment(src,usr)
	playsound(src.loc,active_attachable.activation_sound, 50, 1)
	return