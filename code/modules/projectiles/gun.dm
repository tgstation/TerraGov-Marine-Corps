/obj/item/weapon/gun
	name = "gun"
	desc = "Its a gun. It's pretty terrible, though."
	icon = 'icons/obj/gun.dmi'
	icon_state = "detective"
	item_state = "gun"
	flags =  FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	matter = list("metal" = 2000)
	w_class = 3.0
	throwforce = 5
	throw_speed = 4
	throw_range = 5
	force = 5.0
	origin_tech = "combat=1"
	attack_verb = list("struck", "hit", "bashed")

	var/fire_sound = 'sound/weapons/Gunshot.ogg'
	var/obj/item/projectile/in_chamber = null
	var/caliber = ""
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
	var/fire_delay = 6
	var/last_fired = 0

	var/twohanded = 0
	var/wielded = 0 //Do not set this in gun defines

	var/obj/item/attachable/muzzle = null //Attachable slots. Only one item per slot.
	var/obj/item/attachable/rail = null
	var/obj/item/attachable/under = null
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
	icon_action_button = null //Adds it to the quick-icon list

	proc/ready_to_fire()
		if(world.time >= last_fired + fire_delay)
			last_fired = world.time
			return 1
		else
			return 0

	proc/load_into_chamber()
		return 0

	proc/special_check(var/mob/M) //Placeholder for any special checks, like detective's revolver.
		return 1

	emp_act(severity)
		for(var/obj/O in contents)
			O.emp_act(severity)

	examine()
		..()
		if(rail)
			usr << "It has \icon[rail] [rail.name] mounted on the top."
		if(muzzle)
			usr << "It has \icon[muzzle] [muzzle.name] mounted on the front."
		if(under)
			usr << "It has \icon[under] [under.name] mounted underneath."

	proc/has_attachment(var/A)
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

/obj/item/weapon/gun/proc/wield()
	if(!twohanded) return
	wielded = 1
	name = "[initial(name)] (Wielded)"
	if(istype(src,/obj/item/weapon/gun/projectile/automatic/m41) \
			|| istype(src,/obj/item/weapon/gun/projectile/shotgun/pump/m37) \
			|| istype(src,/obj/item/weapon/gun/projectile/automatic/mar40) \
			|| istype(src,/obj/item/weapon/gun/projectile/M56_Smartgun)) //Ugh
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
	if(ismob(src.loc))
		src.loc.SetLuminosity(-flash_lum)
	else
		SetLuminosity(0)

	src.contents = null
	..()

//Note: pickup and dropped on weapons must have both the ..() to update zoom, AND twohanded,
//As sniper rifles have both and weapon mods can change them as well. ..() deals with zoom only.
/obj/item/weapon/gun/dropped(mob/user as mob)
	..()

	if(flashlight_on && src.loc != user)
		user.SetLuminosity(-flash_lum)
		SetLuminosity(flash_lum)

	if(ishuman(user))
		if(user:wear_suit && istype(user:wear_suit,/obj/item/clothing/suit/storage/marine) && !istype(src,/obj/item/weapon/gun/projectile/M56_Smartgun))
			if(has_attachment(/obj/item/attachable/magnetic_harness))
				var/obj/item/clothing/suit/storage/marine/I = user:wear_suit
				if(isnull(user:s_store))
					if(wielded)	unwield()
					spawn(0)
						user:equip_to_slot_if_possible(src,slot_s_store)
						if(user:s_store == src) user << "\red The [src] snaps into place on [I]."
						user.update_inv_s_store()


	//handles unwielding a twohanded weapon when dropped as well as clearing up the offhand
	if(twohanded)
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

	if(twohanded)
		unwield()

/obj/item/weapon/gun/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params)
	if(flag)	return //It's adjacent, is the user, or is on the user's person
	if(istype(target, /obj/machinery/recharger) && istype(src, /obj/item/weapon/gun/energy))	return//Shouldnt flag take care of this?
	if(user && user.client && user.client.gun_mode && !(A in target))
		PreFire(A,user,params) //They're using the new gun system, locate what they're aiming at.
	else
		if(!burst_toggled)
			Fire(A,user,params) //Otherwise, fire normally.
		else
			if(burst_amount < 2) burst_amount = 2

			for(var/i = 1 to burst_amount)
				if(A)
					Fire(A,user,params)
					if(fire_delay <= 1)
						sleep(1)
					else
						sleep((fire_delay/2))

/obj/item/weapon/gun/proc/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0)//TODO: go over this
	//Exclude lasertag guns from the CLUMSY check.
	if(clumsy_check)
		if(istype(user, /mob/living))
			var/mob/living/M = user
			if ((CLUMSY in M.mutations) && prob(50))
				M << "<span class='danger'>[src] blows up in your face.</span>"
				M.take_organ_damage(0,20)
				M.drop_item()
				del(src)
				return

	if (!user.IsAdvancedToolUser())
		user << "\red You don't have the dexterity to do this!"
		return
	var/obj/item/weapon/twohanded/offhand/O = user.get_inactive_hand()
	if(twohanded && !istype(O))
		user << "\red You need a more secure grip to fire this weapon!"
		return

	if(istype(user, /mob/living))
		var/mob/living/M = user
		if (HULK in M.mutations)
			M << "\red Your meaty finger is much too large for the trigger guard!"
			return
	if(ishuman(user))
		if(user.dna && user.dna.mutantrace == "adamantine")
			user << "\red Your metal fingers don't fit in the trigger guard!"
			return

	if(isYautja(user))
		if(istype(user.hands,/obj/item/clothing/gloves/yautja))
			var/obj/item/clothing/gloves/yautja/G = user.hands
			if(G.cloaked)
				G.decloak(user)

	add_fingerprint(user)

	var/turf/curloc = get_turf(user)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return

	if(!special_check(user))
		return

	if (!ready_to_fire())
		if (world.time % 3) //to prevent spam
			user << "<span class='warning'>[src] is not ready to fire again!"
		return

	if(!load_into_chamber()) //CHECK
		return click_empty(user)

	if(!in_chamber)
		return

	in_chamber.firer = user
	in_chamber.def_zone = user.zone_sel.selecting
	if(targloc == curloc)
		target.bullet_act(in_chamber)
		del(in_chamber)
		update_icon()
		return

	if(recoil)
		spawn()
			shake_camera(user, recoil + 1, recoil)

	if(silenced)
		playsound(user, fire_sound, 8, 1)
	else
		playsound(user, fire_sound, 50, 1)
		if(istype(src,/obj/item/weapon/gun/projectile/automatic/m41) || istype(src,/obj/item/weapon/gun/projectile/automatic/m39))
			var/obj/item/weapon/gun/projectile/automatic/Q = src
			user.visible_message("<span class='warning'>[user] fires [src][reflex ? " by reflex":""]!</span>", \
			"<span class='warning'>You fire [src][reflex ? "by reflex":""]! \[[Q.loaded.len]/[Q.max_shells]\]</span>", \
			"You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!")
		else
			user.visible_message("<span class='warning'>[user] fires [src][reflex ? " by reflex":""]!</span>", \
			"<span class='warning'>You fire [src][reflex ? "by reflex":""]!</span>", \
			"You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!")

	if(rail)
		if(rail.ranged_dmg_mod) in_chamber.damage = round(in_chamber.damage * rail.ranged_dmg_mod / 100)
	if(muzzle)
		if(muzzle.ranged_dmg_mod) in_chamber.damage = round(in_chamber.damage * muzzle.ranged_dmg_mod / 100)
	if(under)
		if(under.ranged_dmg_mod) in_chamber.damage = round(in_chamber.damage * under.ranged_dmg_mod / 100)
		if(istype(under,/obj/item/attachable/bipod) && prob(30))
			var/found = 0
			for(var/obj/structure/Q in range(user,1)) //This is probably inefficient as fuck
				if(Q.throwpass == 1)
					found = 1
					break
			if(found)
				user << "\blue Your bipod keeps the weapon steady!"
				in_chamber.damage = round(5 * in_chamber.damage / 4) //Bipod gives a decent damage upgrade
	in_chamber.original = target
	in_chamber.loc = get_turf(user)
	in_chamber.starting = get_turf(user)
	in_chamber.shot_from = src
	user.next_move = world.time + 4
	in_chamber.silenced = silenced
	in_chamber.current = curloc
	in_chamber.yo = targloc.y - curloc.y
	in_chamber.xo = targloc.x - curloc.x
	if(istype(user, /mob/living/carbon))
		var/mob/living/carbon/mob = user
		if(mob.shock_stage > 120)
			in_chamber.yo += rand(-2,2)
			in_chamber.xo += rand(-2,2)
		else if(mob.shock_stage > 70)
			in_chamber.yo += rand(-1,1)
			in_chamber.xo += rand(-1,1)

		if(burst_toggled)
			var/scatter_chance = 50 // Base chance of scatter on burst fire.
			scatter_chance -= in_chamber.accuracy
			if(rail)
				if(rail.accuracy_mod) scatter_chance -= rail.accuracy_mod
			if(muzzle)
				if(muzzle.accuracy_mod) scatter_chance -= muzzle.accuracy_mod
			if(under)
				if(under.accuracy_mod) scatter_chance -= under.accuracy_mod
			if(scatter_chance < 5) scatter_chance = 5
			scatter_chance += (burst_amount * 5)
			if(prob(scatter_chance))
				in_chamber.yo += rand(-1,1)
				in_chamber.xo += rand(-1,1)

	if(params)
		var/list/mouse_control = params2list(params)
		if(mouse_control["icon-x"])
			in_chamber.p_x = text2num(mouse_control["icon-x"])
		if(mouse_control["icon-y"])
			in_chamber.p_y = text2num(mouse_control["icon-y"])

	spawn()
		if(in_chamber)
			in_chamber.process()
	sleep(1)
	in_chamber = null

	update_icon()

	if(user.hand)
		user.update_inv_l_hand()
	else
		user.update_inv_r_hand()

/obj/item/weapon/gun/proc/can_fire()
	return load_into_chamber()

/obj/item/weapon/gun/proc/can_hit(var/mob/living/target as mob, var/mob/living/user as mob)
	return in_chamber.check_fire(target,user)

/obj/item/weapon/gun/proc/click_empty(mob/user = null)
	if (user)
		user.visible_message("*click click*", "\red <b>*click*</b>")
		playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	else
		src.visible_message("*click click*")
		playsound(src.loc, 'sound/weapons/empty.ogg', 100, 1)

/obj/item/weapon/gun/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	//Suicide handling.
	if (M == user && user.zone_sel.selecting == "mouth" && !mouthshoot)
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
			if(istype(in_chamber, /obj/item/projectile/beam/lastertag))
				user.show_message("<span class = 'warning'>You feel rather silly, trying to commit suicide with a toy.</span>")
				mouthshoot = 0
				return

			in_chamber.on_hit(M)
			if (in_chamber.damage_type != HALLOSS)
				user.apply_damage(in_chamber.damage*2.5, in_chamber.damage_type, "head", used_weapon = "Point blank shot in the mouth with \a [in_chamber]", sharp=1)
				user.death()
			else
				user << "<span class = 'notice'>Ow...</span>"
				user.apply_effect(110,AGONY,0)
			del(in_chamber)
			mouthshoot = 0
			return
		else
			click_empty(user)
			mouthshoot = 0
			return

	if (load_into_chamber())
		//Point blank shooting if on harm intent or target we were targeting.
		if(user.a_intent == "hurt")
			user.visible_message("\red <b> \The [user] fires \the [src] point blank at [M]!</b>")
			if(istype(in_chamber)) in_chamber.damage *= 1.1
			Fire(M,user)
			return
//		else if(target && M in target)
//			Fire(M,user) ///Otherwise, shoot!
//			return
	else
		return ..() //Pistolwhippin'


//Attachables!
/obj/item/weapon/gun/attackby(obj/item/I as obj, mob/user as mob)
	..()

	if(!istype(I,/obj/item/attachable)) return
	var/obj/item/attachable/A = I

	if(!(src.type in A.guns_allowed))
		user << "\The [A] doesn't fit on [src]."
		return

	//First, deal with the slot in question.
	var/nope = 0
	if(A.slot == "rail" && src.rail) nope = 1
	if(A.slot == "muzzle" && src.muzzle) nope = 1
	if(A.slot == "under" && src.under) nope = 1
	if(nope)
		user << "There's already something attached in that weapon slot. Field strip your weapon first."
		return

	user.visible_message("\blue [user] begins field-modifying their [src]..","\blue You begin field modifying \the [src]..")
	if(do_after(user,60))
		user.visible_message("\blue [user] attaches \the [A] to \the [src].","\blue You attach \the [A] to \the [src].")
		user.drop_item()
		A.loc = src
		A.Attach(src)
		update_attachables()
		playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	return

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

/obj/item/weapon/gun/projectile/verb/field_strip()
	set category = "Weapons"
	set name = "Field Strip Weapon"
	set desc = "Remove all attachables from a weapon."
	set src in usr

	if(!usr.canmove || usr.stat || usr.restrained() || !usr.loc)
		usr << "Not right now."
		return

	if(!rail && !muzzle && !under)
		usr << "This weapon has no attachables. You can only field strip enhanced weapons."
		return

	usr.visible_message("\blue [usr] begins field stripping their [src].","\blue You begin field-stripping your [src].")
	if(!do_after(usr,40))
		return

	if(rail)
		usr << "You remove the weapon's [rail]."
		rail.loc = get_turf(usr)
		rail.Detach(src)
	if(muzzle)
		usr << "You remove the weapon's [muzzle]."
		muzzle.loc = get_turf(usr)
		muzzle.Detach(src)
	if(under)
		usr << "You remove the weapon's [under]."
		under.loc = get_turf(usr)
		under.Detach(src)

	playsound(src,'sound/machines/click.ogg', 50, 1)
	update_attachables()

/obj/item/weapon/gun/projectile/verb/toggle_light()
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

	if(istype(src,/obj/item/weapon/gun/projectile))
		return src:unload(user)

	return ..()

/obj/item/weapon/gun/projectile/verb/toggle_burst()
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