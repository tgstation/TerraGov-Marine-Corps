

/obj/item/weapon/gun
	name = "gun"
	desc = "Its a gun. It's pretty terrible, though."
	icon = 'icons/obj/gun.dmi'
	icon_state = ""
	var/icon_wielded = null
	var/icon_empty = null
	item_state = "gun"
	flags =  FPRINT | TABLEPASS | CONDUCT
	matter = list("metal" = 2000)
	w_class = 3.0
	throwforce = 5
	throw_speed = 4
	throw_range = 5
	force = 5.0
	origin_tech = "combat=1"
	attack_verb = list("struck", "hit", "bashed")

	var/can_pointblank = 1
	var/fire_sound = 'sound/weapons/Gunshot.ogg'
	var/reload_sound = 'sound/weapons/empty.ogg'
	var/obj/item/projectile/in_chamber = null //What is currently "loaded"? Sort of a generic term.
	var/datum/ammo/ammo = null //The default ammo datum when a round is chambered. Null means it probably does its own thing.
	var/obj/item/ammo_magazine/current_mag = null //What magazine is currently loaded?
	var/mag_type = null  //The default magazine loaded into a projectile weapon for reverse lookups. Leave this null to do your own thing.
	var/default_ammo = "/datum/ammo" //For stuff that doesn't use mags. Just fire it.

	var/silenced = 0
	var/recoil = 0
	var/ejectshell = 1
	var/clumsy_check = 1
	var/tmp/list/mob/living/target //List of who yer targeting.
	var/tmp/lock_time = -100
	var/tmp/mouthshoot = 0 ///To stop people from suiciding twice... >.>
	var/automatic = 0 //Used to determine if you can target multiple people.
	var/tmp/mob/living/last_moved_mob //Used to fire faster at more than one person.
	var/tmp/told_cant_shoot = 0 //So that it doesn't spam them with the fact they cannot hit them.
	var/firerate = 0 	//0 for keep shooting until aim is lowered
						// 1 for one bullet after tarrget moves and aim is lowered
	var/fire_delay = 6 // For regular shots, how long to wait before firing again.
	var/extra_delay = 0 // When burst-firing, this number is extra before the weapon can fire again. Depends on number of rounds fired.
	var/last_fired = 0 // When it was last fired, related to world.time.

	var/twohanded = 0
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
	var/flashlight_on = 0 //Mounted flashlight stuff.
	var/flash_lum = 0
	var/burst_amount = 0
	var/burst_toggled = 0
	var/burst_firing = 0
	var/burst_delay = 0 //The delay in between shots. Lower = faster.
	icon_action_button = null //Adds it to the quick-icon list
	var/accuracy = 0 //Flat bonus/penalty due to the gun itself.
	var/dam_bonus = 0 //Flat bonus/penalty to bullet damage due to the gun itself.
	var/is_bursting = 0 //Sentries use this.
	var/ammo_counter = 0 //M39s and M41s have this.
	var/autoejector = 1 //Automatically ejects spent magazines. Defaults to yes.
	var/integrated_assembly = 0 //For the smartgun checking, might eventually make its way elsewhere.
	var/internal_magazine = 0 //For weapons that do not eject their magazine when empty, or eject casings, like pump shotguns or revolvers.
	var/found_on_mercs = 0 //For the randomizer.
	var/found_on_russians = 0 //For the randomizer.
	var/muzzle_flash = 1 //1 : small, 2: big?
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
		var/magpath = text2path(mag_type)
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
		..()

	emp_act(severity)
		for(var/obj/O in contents)
			O.emp_act(severity)

	equipped(mob/user, slot)
		if (slot != slot_l_hand && slot != slot_r_hand)
			stop_aim()
			if (user.client)
				user.client.remove_gun_icons()
		if(wielded)
			unwield()

		return ..()

	examine()
		..()
		if(current_mag && current_mag.current_rounds > 0)
			if(ammo_counter || integrated_assembly)
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
		//Cannot equip wielded items.
		if(wielded)
			M << "<span class='warning'>Unwield the [initial(name)] first!</span>"
			return 0

		return ..()

	proc/snowflake_reload(var/obj/item/ammo_magazine/A)
		return 1

//Clicking stuff onto the gun.
//Attachables & Reloading
/obj/item/weapon/gun/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I,/obj/item/ammo_magazine) && !integrated_assembly) //Can't reload integrated assemblies.
		src.reload(user,I)
		return

	if(!istype(I,/obj/item/attachable)) return
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

	user.visible_message("\blue [user] begins field-modifying their [src]..","\blue You begin field modifying \the [src]..")
	if(do_after(user,60))
		user.visible_message("\blue [user] attaches \the [A] to \the [src].","\blue You attach \the [A] to \the [src].")
		user.drop_item(A)
		A.Attach(src)
		update_attachables()
		if(reload_sound)
			playsound(user, reload_sound, 100, 1)

	return

/*
Reload a gun using a magazine.
This sets all the initial datum's stuff. The bullet does the rest.
User can be passed as null, (a gun reloading itself for instance), so we need to watch for that constantly.
*/
/obj/item/weapon/gun/proc/reload(var/mob/user = null, var/obj/item/ammo_magazine/magazine)
	if(!magazine || !istype(magazine))
		if(user) user << "That's not a magazine!"
		return 0

	if(!istype(src,text2path(magazine.gun_type)))
		if(user) user << "That magazine doesn't fit in there!"
		return

	if(magazine.current_rounds == 0)
		if(user) user << "That [magazine.name] is empty!"
		return 0

	//DEBUG HERE
	//speshul snowflake shotgun code (say that 10 times fast)
	if(istype(src,/obj/item/weapon/gun/shotgun/pump) && current_mag && current_mag.current_rounds > 0)
		snowflake_reload(magazine)
		return
	//DEBUG HERE

	if(!isnull(current_mag) && current_mag.loc == src)
		if(user) user << "It's still got something loaded."
		return

	/*
	Current rounds are set to -1 by default.
	When the magazine spawns in with New(), the -1 tell it to fill to full.
	This doesn't honestly make a lot of sense, since you would in most circumstances
	want a fresh mag to start with max_rounds, but this doesn't impact
	anything. You may, potentially, want to have the mag spawn with
	less than full rounds, for scavenging or Hunter Games.
	So I'm leaving it like it is. ~N.
	*/
	if(magazine.current_rounds == -1)
		magazine.current_rounds = magazine.max_rounds

	var/ammopath = text2path(magazine.default_ammo)
	if(!ammopath || isnull(ammopath))
		if(user) user << "Something went horribly wrong. Tell a coder."
		return 0

	burst_firing = 0
	burst_toggled = 0
	is_bursting = 0
	active_attachable = null

	if(user)
		user << "You begin reloading \the [src.name]. Hold still!"
		if(do_after(user,magazine.reload_delay))
			current_mag = magazine
			user.drop_from_inventory(magazine) //Click!
			user << "\blue You load \the [magazine] into \the [src]!"
			if(reload_sound) playsound(user, reload_sound, 100, 1)
			magazine.loc = src //Jam that sucker in there.
			update_icon()
			if(ammo) del(ammo)
			ammo = new ammopath()
			ammo.current_gun = src
		else
			user << "Your reload was interrupted."
			return 0
	else
		current_mag = magazine
		if(ammo) del(ammo)
		ammo = new ammopath()
		ammo.current_gun = src

	return 1

//Drop out the magazine. Keep the ammo type for next time so we don't need to replace it every time.
/obj/item/weapon/gun/proc/unload(var/mob/user as mob)
	if(!current_mag || isnull(current_mag) || current_mag.loc != src)
		if(user) user << "It's already empty or doesn't need to be unloaded."
		return

	if(integrated_assembly)
		if(user) user << "\The [name] has an integrated ammo feed and cannot be unloaded."
		return

	current_mag.loc = get_turf(src)
	playsound(src, 'sound/weapons/flipblade.ogg', 20, 1)
	if(user) user << "\blue You unload the magazine from \the [src]."
//	if(in_chamber) del(in_chamber)
	current_mag = null
	update_icon()
	return

/obj/item/weapon/gun/proc/load_into_chamber()

	if(in_chamber)
		usr << "load_into_chamber() returned 1"// DEBUG
		return 1 //Already set!

	if(active_attachable)
		if(active_attachable.ammo_type)
			if(active_attachable.current_ammo <= 0)
				if(usr) usr << "\blue \The [active_attachable.name] is empty!"
				active_attachable = null
				return 0
			if(ammo) del(ammo)
			ammo = new active_attachable.ammo_type()
			ammo.current_gun = src
		else
			if(active_attachable.current_ammo <= 0 || active_attachable.passive) //It's something like a flashlight or zoom scope.
				active_attachable = null

	if(isnull(active_attachable)) //After all that, if we're not using an attachable, check for the magazine.
		if(!current_mag || isnull(current_mag)) return 0
		if(current_mag.current_rounds <= 0) return 0 //Nope

	if(!ammo || isnull(ammo)) return 0 //Our ammo datum is missing. We need one, and it should have set when we reloaded, so, abort.

	var/obj/item/projectile/P = new(src) //New bullet!
	P.ammo = src.ammo //Share the ammo type. This does all the heavy lifting.
	P.name = P.ammo.name
	P.icon_state = P.ammo.icon_state //Make it look fancy.
	P.damage = P.ammo.damage
	P.damage += src.dam_bonus
	P.damage_type = P.damage_type
	in_chamber = P
	return 1

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
	return 0

/obj/item/weapon/gun/proc/unwield()
	if(!twohanded) return
	wielded = 0
	name = "[initial(name)]"
	item_state = "[initial(item_state)]"
	if(usr && ishuman(usr))
		usr:update_inv_l_hand(0) //Updating invs is more efficient than updating the entire icon set.
		usr:update_inv_r_hand()
		var/obj/item/weapon/twohanded/O = usr:get_inactive_hand()
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

/obj/item/weapon/gun/mob_can_equip(M as mob, slot)
	//Cannot equip wielded items.
	if(wielded)
		M << "<span class='warning'>Unwield the [initial(name)] first!</span>"
		return 0

	return ..()

/obj/item/weapon/gun/Del()
	if(flashlight_on && ismob(src.loc))
		src.loc.SetLuminosity(-flash_lum)
	else
		SetLuminosity(0)

	src.contents = null
	..()

/*
Note: pickup and dropped on weapons must have both the ..() to update zoom, AND twohanded,
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

	if(ishuman(user))
		if(has_attachment(/obj/item/attachable/magnetic_harness) || istype(src,/obj/item/weapon/gun/smartgun))
			var/obj/item/I = user:wear_suit
			if(istype(I,/obj/item/clothing/suit/storage/marine) || istype(I,/obj/item/clothing/suit/storage/marine_smartgun_armor))
				spawn(5)
					if(isnull(user:s_store) && isturf(src.loc))
						if(wielded)	unwield()
						var/obj/item/weapon/twohanded/O = user.get_inactive_hand()
						if(istype(O)) O.unwield()
						user:equip_to_slot_if_possible(src,slot_s_store)
						if(user:s_store == src) user << "\red The [src] snaps into place on [I]."
						user.update_inv_s_store()

	//handles unwielding a twohanded weapon when dropped as well as clearing up the offhand
	if(twohanded && wielded)
		if(user)
			var/obj/item/weapon/twohanded/O = user.get_inactive_hand()
			if(istype(O))
				O.unwield()
		unwield()


/obj/item/weapon/gun/pickup(mob/user)
	..()

	if(flashlight_on && src.loc != user)
		user.SetLuminosity(flash_lum)
		SetLuminosity(0)

	if(twohanded && wielded)
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

/obj/item/weapon/gun/proc/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, atom/original_target as mob|obj|turf)
	set waitfor = 0

	if (!user.IsAdvancedToolUser())
		user << "\red You don't have the dexterity to do this!"
		return

	if(user)
		dir = user.dir

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

	if(targloc == curloc && in_chamber)
		usr << "if(targloc == curloc && in_chamber) triggered."//DEBUG
		target.bullet_act(in_chamber)
		sleep(-1)
		usr << "if(targloc == curloc && in_chamber) triggered and sleep(-1) worked."//DEBUG
		del(in_chamber)
		update_icon()
		return
	else if (targloc == curloc)
		usr << "else if (targloc == curloc) triggered."//DEBUG
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

	//This is where burst is established for the proceeding section. Which just means the proc loops around that many times.
	var/bullets_fired = 1
	if(burst_toggled && burst_amount > 0)
		bullets_fired = burst_amount
		burst_firing = 1

	var/i //Weirdly, this way is supposed to be less laggy. by 500% <---- weird indeed.
	for(i = 1 to bullets_fired) //I wonder why this is not a while proc. I'm not messing with it, since I don't know if it will make it more efficient. ~N.
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
				for(var/obj/structure/Q in range(1,user)) //This is probably inefficient as fuck <------ Yeah. It runs through this for every bullet on burst.
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
			usr << "Your gun is malfunctioning. Tell a coder! (don't forget to say exactly how you got this message)"
			burst_firing = 0
			return

		if(get_turf(target) != get_turf(user))
			//in_chamber.invisibility = 100 // Let's make it invisible when it actually leaves the gun, so it doesn't appear below the character.
			var/obj/to_be_fired = in_chamber
			spawn(1)
				if(to_be_fired) to_be_fired.invisibility = 0 // If it still exists, let's make it visible again.
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
		make_casing() // Drop a casing if needed.

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
					current_mag.loc = get_turf(src)
					current_mag = null //Get rid of it. But not till the bullet is fired.
					update_icon() //Update icon to reflect this.

		if(i < bullets_fired) //We still have some bullets to fire.
			extra_delay = min(extra_delay+(burst_delay*2), fire_delay*3) // The more bullets you shoot, the more delay there is, but no more than thrice the regular delay.
			sleep(burst_delay)
		else if(i == bullets_fired) //We're on our last bullet, or there was only one bullet.
			burst_firing = 0

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

/obj/item/weapon/gun/proc/make_casing(casing_override = 0) // In case we need to make a casing anyway.
	if(casing_override || (!ammo.caseless && !internal_magazine) ) // If it's not caseless and the thing doesn't have an internal mag.
		var/casingtype = text2path(ammo.casing_type) //Get the path.
		if(casingtype)
			new casingtype(get_turf(src)) //Drop a spent casing.

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


/obj/item/weapon/gun/verb/field_strip()
	set category = "Weapons"
	set name = "Field Strip Weapon"
	set desc = "Remove all attachables from a weapon."
	set src in usr

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
/*
/obj/item/weapon/gun/verb/toggle_light()
	set category = "Weapons"
	set name = "Toggle Weapon Light"
	set desc = "Toggle on or off your weapon's flashlight, if it has one."
	set src in usr

	if(!usr.canmove || usr.stat || usr.restrained() || !usr.loc)
		usr << "Not right now."
		return

	if(!flash_lum)
		usr << "This weapon has no flashlight installed. To install one, find or build a mountable flashlight."
		return

	playsound(src.loc,'sound/machines/click.ogg', 50, 1)
	flashlight_on = !flashlight_on
	if(flashlight_on)
		if(loc == usr)
			usr.SetLuminosity(flash_lum)
		else if(isturf(loc))
			SetLuminosity(flash_lum)
	else
		if(loc == usr)
			usr.SetLuminosity(-flash_lum)
		else if(isturf(loc))
			SetLuminosity(0)
	update_attachables()
*/
/obj/item/weapon/gun/attack_self(mob/user as mob)
	if (target)
		lower_aim()
		return

	if(twohanded)
		if(wielded) //Trying to unwield it
			unwield()
			user << "<span class='notice'>You are now carrying the [name] with one hand.</span>"

			var/obj/item/weapon/twohanded/offhand/O = user.get_inactive_hand()
			if(O && istype(O))
				O.unwield()
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

/obj/item/weapon/gun/verb/toggle_burst()
	set category = "Weapons"
	set name = "Toggle Burst Fire Mode"
	set desc = "Toggle on or off your weapon burst mode, if it has one. Greatly reduces accuracy."
	set src in usr

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