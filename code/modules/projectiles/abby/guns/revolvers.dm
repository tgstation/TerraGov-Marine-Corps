//---------------------------------------------------
//Generic parent object.
/obj/item/weapon/gun/revolver
	slot_flags = SLOT_BELT
	w_class = 3
	origin_tech = "combat=3;materials=2"
	autoejector = 0 // Revolvers don't auto eject.
	fire_sound = 'sound/weapons/44mag.ogg'
	reload_sound = 'sound/weapons/revolver_cocked.ogg'
	cocked_sound = 'sound/weapons/revolver_spun.ogg'
	unload_sound = 'sound/weapons/revolver_unload.ogg'
	var/hand_reload_sound = 'sound/weapons/revolver_load3.ogg'
	var/spin_sound = 'sound/effects/spin.ogg'
	var/thud_sound = 'sound/effects/thud.ogg'

	New()
		..() //Do all that other stuff.
		replace_cylinder(current_mag.current_rounds)

	examine()
		..()

		if(current_mag.cylinder_closed)
			usr << "It's closed."
		else
			usr << "It's open with [current_mag.current_rounds] round\s loaded."

	update_icon() //Special snowflake update icon.
		if(isnull(icon_empty)) return
		if(current_mag.cylinder_closed)
			icon_state = initial(icon_state)
		else
			icon_state = icon_empty
		update_attachables() //This will cut existing overlays

	proc/rotate_cylinder(var/mob/user as mob) //Cylinder moves backward.
		current_mag.cylinder_position = ( current_mag.cylinder_position == 1 ? current_mag.max_rounds : current_mag.cylinder_position - 1 )

	proc/spin_cylinder(var/mob/user as mob)
		if(current_mag.cylinder_closed) //We're not spinning while it's open. Could screw up reloading.
			current_mag.cylinder_position = rand(1,current_mag.max_rounds)
			if(user)
				user << "\blue You spin the cylinder."
				playsound(user, cocked_sound, 70, 1)
		return

	proc/replace_cylinder(var/number_to_replace)
		current_mag.cylinder_contents = list()
		current_mag.cylinder_contents.len = current_mag.max_rounds
		var/i
		for(i = 1 to current_mag.max_rounds) //We want to make sure to populate the cylinder.
			if(i > number_to_replace)
				current_mag.cylinder_contents[i] = "empty"
			else
				current_mag.cylinder_contents[i] = "bullet"
		current_mag.cylinder_position = max(1,number_to_replace)
		return

	proc/empty_cylinder()
		var/i
		for(i = 1 to current_mag.max_rounds)
			current_mag.cylinder_contents[i] = "empty"

	//The cylinder is always emptied out before a reload takes place.
	proc/add_to_cylinder(var/mob/user as mob) //Bullets are added forward.
		//First we're going to try and replace the current bullet.
		if(!current_mag.current_rounds)
			current_mag.cylinder_contents[current_mag.cylinder_position] = "bullet"

		else//Failing that, we'll try to replace the next bullet in line.
			if( (current_mag.cylinder_position + 1) > current_mag.max_rounds)
				current_mag.cylinder_contents[1] = "bullet"
				current_mag.cylinder_position = 1
			else
				current_mag.cylinder_contents[current_mag.cylinder_position + 1] = "bullet"
				current_mag.cylinder_position++

		if(user) playsound(user, hand_reload_sound, 100, 1)
		return 1

	reload(var/mob/user = null, var/obj/item/ammo_magazine/magazine)
		if(burst_toggled && burst_firing)
			return

		if(!magazine || !istype(magazine))
			if(user) user << "That's not gonna work!"
			return

		if(magazine.current_rounds <= 0)
			if(user) user << "That [magazine.name] is empty!"
			return

		if(user)
			var/obj/item/ammo_magazine/in_hand = user.get_inactive_hand()
			if( in_hand != src )
				user << "You have to hold \the [src] to reload!"
				return
		if(current_mag.cylinder_closed)
			if(user) user << "You can't load anything when the cylinder is closed!"
			return

		if(current_mag.current_rounds == current_mag.max_rounds)
			if(user) user << "It's already full!"
			return

		if(istype(magazine, /obj/item/ammo_magazine/handful)) //Looks like we're loading via handful.
			if( !current_mag.current_rounds && current_mag.caliber == magazine.caliber) //Make sure nothing's loaded and the calibers match.
				replace_ammo(user, magazine) //We are going to replace the ammo just in case.
				current_mag.match_ammo(magazine,current_mag)
				current_mag.transfer_ammo(magazine,current_mag,user,1) //Handful can get deleted, so we can't check through it.
				add_to_cylinder(user)
			//If bullets still remain in the gun, we want to check if the actual ammo matches.
			else if(magazine.default_ammo == current_mag.default_ammo) //Ammo datums match, let's see if they are compatible.
				if(current_mag.transfer_ammo(magazine,current_mag,user,1)) //If the magazine is deleted, we're still fine.
					add_to_cylinder(user)
			else //Not the right kind of ammo.
				if(user) user << "\The [current_mag] is already loaded with some other ammo. Better not mix them up."
		else //So if it's not a handful, it's an actual speedloader.
			if(!current_mag.current_rounds) //We can't have rounds in the gun if it's a speeloader.
				if(current_mag.gun_type == magazine.gun_type) //Has to be the same gun type.
					if(current_mag.transfer_ammo(magazine,current_mag,user,magazine.current_rounds))//Make sure we're successful.
						replace_ammo(user, magazine) //We want to replace the ammo ahead of time, but not necessary here.
						current_mag.match_ammo(magazine,current_mag)
						replace_cylinder(current_mag.current_rounds)
						if(user) playsound(user, reload_sound, 80, 1) // Reloading via speedloader.
				else
					if(user) user << "That [magazine] doesn't fit!"
			else
				if(user) user << "You can't load a speedloader when there's something in the cylinder!"
		return

	unload(var/mob/user as mob)
		if(burst_toggled && burst_firing) return

		if(current_mag.cylinder_closed) //If it's actually closed.
			if(user) user << "\blue You clear the cylinder of \the [src]."
			make_casing()
			empty_cylinder()
			current_mag.create_handful(current_mag, user)
			current_mag.cylinder_closed = !current_mag.cylinder_closed
		else
			current_mag.cylinder_closed = !current_mag.cylinder_closed
		if(user) playsound(src, unload_sound, 40, 1)
		update_icon()
		return

	make_casing()
		var/sound_to_play = pick('sound/weapons/bulletcasing_fall2.ogg','sound/weapons/bulletcasing_fall.ogg')
		//Hilariously faster than the example above and doesn't crash.
		if(current_mag.used_casings) //We have some spent casings to eject.
			var/turf/current_turf = get_turf(src) //Figure out the turf we're on.
			var/obj/item/ammo_casing/bullet/casing = locate() in current_turf //Could cause issues if there are a lot of objects.
			if(!casing) //If there is no casing, make one.
				casing = new(current_turf) //Don't need to do anything else.
				current_mag.used_casings -= 1
				playsound(current_turf, sound_to_play, 20, 1)
			//Then do the rest of the operation.
			casing.casings += current_mag.used_casings
			casing.update_icon()
			current_mag.used_casings = 0 //Always dump out everything.
			playsound(current_turf, sound_to_play, 20, 1)
		return

	able_to_fire(var/mob/user as mob)
		if(!current_mag.cylinder_closed)
			user << "\red Close the cylinder!"
			return
		return ..()

	ready_in_chamber()
		if(current_mag.current_rounds > 0)
			if( current_mag.cylinder_contents[current_mag.cylinder_position] == "bullet")
				current_mag.current_rounds-- //Subtract the round from the mag.
				in_chamber = create_bullet(ammo)
				return in_chamber
		return

	load_into_chamber()
		if(active_attachable)
			active_attachable = null

		if(ready_in_chamber())
			return in_chamber

		//If we fail to return to chamber the round, we just move the firing pin some.
		rotate_cylinder()
		return

	reload_into_chamber(var/mob/user as mob)
		current_mag.cylinder_contents[current_mag.cylinder_position] = "blank" //We shot the bullet.
		current_mag.used_casings += 1 //We add this only if we actually fired the bullet.
		rotate_cylinder()
		return 1

	delete_bullet(var/obj/item/projectile/projectile_to_fire, var/refund = 0)
		del(projectile_to_fire)
		if(refund)
			current_mag.current_rounds++
		return 1

	unique_action(var/mob/living/carbon/human/user as mob)
		spin_cylinder(user)


	//HEAVILY WIP. Just something to mess around with.
	proc/revolver_trick(var/mob/living/carbon/human/user as mob)
		var/chance = -5
		chance = user.health < 6 ? 0 : user.health - 5

		//Pain is largely ignored, since it deals its own effects on the mob. We're just concerned with health.
		//And this proc will only deal with humans for now.

		if(prob(chance))
			switch(rand(1,8))
				if(1)
					playsound(user, spin_sound, 50, 1)
					user.visible_message("\The [user] deftly flicks and spins \the [src]!","\blue You flick and spin \the [src]!")
					animation_spin(src, "left", 1, 1)
					spawn(3)
						playsound(user, thud_sound, 50, 1)
				if(2)
					playsound(user, spin_sound, 50, 1)
					user.visible_message("\The [user] deftly flicks and spins \the [src]!","\blue You flick and spin \the [src]!")
					animation_spin(src, "right", 1, 1)
					spawn(3)
						playsound(user, thud_sound, 50, 1)
				if(3)
					var/layer = MOB_LAYER+0.1
					var/image/trick = image(icon,user,icon_state,layer)
					animation_flick(trick, 1)
					invisibility = 100
					for(var/mob/M in viewers(user))
						M << trick
					spawn(5)
						del(trick)
						invisibility = 0
						playsound(user, thud_sound, 50, 1)
					user.visible_message("\The [user] throws \the [src] in to the air and catches it!", "\blue You throw and catch \the [src]. Nice!")
				if(4)
					playsound(user, spin_sound, 50, 1)
					user.visible_message("\The [user] deftly flicks and spins \the [src]!","\blue You flick and spin \the [src]!")
					animation_spin(src, "right", 1, 1)
					spawn(1)
						animation_spin(src, "left", 1, 1)
						playsound(user, spin_sound, 50, 1)
					spawn(3)
						playsound(user, thud_sound, 50, 1)
				if(5)
					user.visible_message("\The [user] deftly flicks \the [src] and tosses it into the air!","\blue You flick and toss \the [src] into the air!")
					var/layer = MOB_LAYER+0.1
					var/image/trick = image(icon,user,icon_state,layer)
					animation_flick(trick, 1)
					invisibility = 100
					animation_spin(src, "right", 1, 1)
					for(var/mob/M in viewers(user))
						M << trick
					spawn(5)
						del(trick)
						invisibility = 0
						playsound(user, thud_sound, 50, 1)
						if(user.get_inactive_hand())
							user.visible_message("\The [user] catches \the [src] with the same hand!","\blue You catch \the [src] as it spins in to your hand!")
						else
							user.visible_message("\The [user] catches \the [src] with his other hand!","\blue You snatch \the [src] with your other hand! Awesome!")
							user.drop_from_inventory(src)
							user.put_in_inactive_hand(src)
							user.swap_hand()
							user.update_inv_l_hand(0)
							user.update_inv_r_hand()
				if(6)
					if(istype(user.get_inactive_hand(),/obj/item/weapon/gun/revolver) )
						var/obj/item/weapon/gun/revolver/double = user.get_inactive_hand()
						playsound(user, spin_sound, 50, 1)
						user.visible_message("\The [user] deftly flicks and spins \the [src] and \the [double]!","\blue You flick and spin \the [src] and \the [double]!")
						animation_spin(src, "left", 1, 1)
						animation_spin(double, "left", 1, 1)
						spawn(3)
							playsound(user, thud_sound, 50, 1)
					else
						playsound(user, spin_sound, 50, 1)
						user.visible_message("\The [user] deftly flicks and spins \the [src]!","\blue You flick and spin \the [src]!")
						animation_spin(src, "left", 1, 1)
						spawn(3)
							playsound(user, thud_sound, 50, 1)
				if(7)
					if(istype(user.get_inactive_hand(),/obj/item/weapon/gun/revolver) )
						var/obj/item/weapon/gun/revolver/double = user.get_inactive_hand()
						playsound(user, spin_sound, 50, 1)
						user.visible_message("\The [user] deftly flicks and spins \the [src] and \the [double]!","\blue You flick and spin \the [src] and \the [double]!")
						animation_spin(src, "right", 1, 1)
						animation_spin(double, "right", 1, 1)
						spawn(3)
							playsound(user, thud_sound, 50, 1)
					else
						playsound(user, spin_sound, 50, 1)
						user.visible_message("\The [user] deftly flicks and spins \the [src]!","\blue You flick and spin \the [src]!")
						animation_spin(src, "right", 1, 1)
						spawn(3)
							playsound(user, thud_sound, 50, 1)
				if(8)
					var/layer = MOB_LAYER+0.1
					if(istype(user.get_inactive_hand(),/obj/item/weapon/gun/revolver))
						var/obj/item/weapon/gun/revolver/double = user.get_inactive_hand()
						var/image/trick = image(double.icon,user,double.icon_state,layer)
						animation_flick(trick, 1)
						double.invisibility = 100
						for(var/mob/M in viewers(user))
							M << trick
						spawn(5)
							del(trick)
							double.invisibility = 0
							playsound(user, thud_sound, 50, 1)
						user.visible_message("\The [user] throws \the [double] in to the air and catches it!", "\blue You throw and catch \the [double]. Nice!")
					else
						var/image/trick = image(icon,user,icon_state,layer)
						animation_flick(trick, 1)
						invisibility = 100
						for(var/mob/M in viewers(user))
							M << trick
						spawn(5)
							del(trick)
							invisibility = 0
							playsound(user, thud_sound, 50, 1)
						user.visible_message("\The [user] throws \the [src] in to the air and catches it!", "\blue You throw and catch \the [src]. Nice!")


			//	if(9)
			//	if(10)
		else
			if(prob(30))
				user << "You fumble with \the [src] like an idiot... Uncool."
			else
				user.visible_message("<b> \The [user] fumbles with \the [src] like a huge idiot!</b>")
		return

//-------------------------------------------------------
//M44 MAGNUM REVOLVER

/obj/item/ammo_magazine/revolver
	name = "Revolver Speed Loader (.44)"
	default_ammo = "/datum/ammo/bullet/revolver"
	slot_flags = null
	caliber = ".44"
	icon_state = "38"
	icon_empty = "38-0"
	max_rounds = 7
	gun_type = "/obj/item/weapon/gun/revolver"
	handful_type = "Bullets (.44)"

/obj/item/ammo_magazine/revolver/marksman
	name = "Marksman Speed Loader (.44)"
	default_ammo = "/datum/ammo/bullet/revolver/marksman"
	caliber = ".44"
	handful_type = "Marksman Bullets (.44)"

/obj/item/ammo_magazine/revolver/internal
	name = "Revolver Cylinder"
	desc = "An internal magazine. It is not supposed to be seen or removed."
	default_ammo = "/datum/ammo/bullet/revolver"
	caliber = ".44"
	icon_state = "38"
	icon_empty = "38-0"
	gun_type = "/obj/item/weapon/gun/revolver"
	handful_type = "Bullets (.44)"
	max_rounds = 7

/obj/item/weapon/gun/revolver/m44
	name = "\improper M44 Combat Revolver"
	desc = "A bulky 44-calibre revolver, occasionally carried by assault troops and officers in the Colonial Marines. Uses 44 Magnum rounds."
	icon_state = "44"
	icon_empty = "44_dry"
	item_state = "44"
	mag_type = "/obj/item/ammo_magazine/revolver"
	mag_type_internal = "/obj/item/ammo_magazine/revolver/internal"
	fire_sound = 'sound/weapons/44mag.ogg'
	fire_delay = 8
	recoil = 1
	force = 8
	muzzle_pixel_x = 30
	muzzle_pixel_y = 21
	rail_pixel_x = 17
	rail_pixel_y = 23
	under_pixel_x = 22
	under_pixel_y = 19

//-------------------------------------------------------
//RUSSIAN REVOLVER

/obj/item/ammo_magazine/revolver/upp
	name = "Revolver Speed Loader (7.62mm)"
	default_ammo = "/datum/ammo/bullet/revolver"
	caliber = "7.62mm"
	icon_state = "T38"
	icon_empty = "T38-0"
	max_rounds = 8
	gun_type = "/obj/item/weapon/gun/revolver/upp"
	handful_type = "Bullets (7.62mm)"

/obj/item/ammo_magazine/revolver/internal/upp
	caliber = "7.62mm"
	max_rounds = 7
	gun_type = "/obj/item/weapon/gun/revolver/upp"
	handful_type = "Bullets (7.62mm)"

/obj/item/weapon/gun/revolver/upp
	name = "\improper N-Y 7.62mm Revolver"
	desc = "The Nagant-Yamasaki 7.62 is an effective killing machine designed by a consortion of shady Not-Americans. It is frequently found in the hands of criminals or mercenaries."
	icon_state = "revolver"
	icon_empty = "revolver_dry"
	item_state = "revolver"
	origin_tech = "combat=3;materials=1;syndicate=3"
	mag_type = "/obj/item/ammo_magazine/revolver/internal/upp"
	fire_sound = 'sound/weapons/pistol_medium.ogg'
	fire_delay = 8
	recoil = 1
	force = 10
	muzzle_pixel_x = 28
	muzzle_pixel_y = 21
	rail_pixel_x = 14
	rail_pixel_y = 23
	under_pixel_x = 24
	under_pixel_y = 19
	found_on_mercs = 1
	found_on_russians = 1

//-------------------------------------------------------
//357 REVOLVER

/obj/item/ammo_magazine/revolver/small
	name = "Revolver Speed Loader (.357)"
	default_ammo = "/datum/ammo/bullet/revolver/small"
	caliber = ".357"
	icon_state = "38"
	icon_empty = "38-0"
	max_rounds = 7
	gun_type = "/obj/item/weapon/gun/revolver/small"
	handful_type = "Bullets (.357)"

/obj/item/ammo_magazine/revolver/internal/small
	default_ammo = "/datum/ammo/bullet/revolver/small"
	caliber = ".357"
	max_rounds = 7
	gun_type = "/obj/item/weapon/gun/revolver/small"
	handful_type = "Bullets (.357)"

/obj/item/weapon/gun/revolver/small
	name = "\improper S&W .357 Revolver"
	desc = "A lean 357 made by Smith & Wesson. A timeless classic, from antiquity to the future."
	icon_state = "357"
	icon_empty = "357_dry"
	item_state = "revolver"
	mag_type = "/obj/item/ammo_magazine/revolver/small"
	mag_type_internal = "/obj/item/ammo_magazine/revolver/internal/small"
	fire_sound = 'sound/weapons/pistol_medium.ogg'
	fire_delay = 3
	recoil = 0
	force = 6
	muzzle_pixel_x = 30
	muzzle_pixel_y = 19
	rail_pixel_x = 12
	rail_pixel_y = 21
	under_pixel_x = 20
	under_pixel_y = 15
	found_on_mercs = 1

	unique_action(var/mob/user as mob)
		revolver_trick(user)

//-------------------------------------------------------
//BURST REVOLVER

/obj/item/ammo_magazine/revolver/mateba
	name = "Revolver Speed Loader (.454)"
	default_ammo = "/datum/ammo/bullet/revolver/heavy"
	caliber = ".454"
	icon_state = "T38"
	icon_empty = "T38-0"
	max_rounds = 8
	gun_type = "/obj/item/weapon/gun/revolver/mateba"
	handful_type = "Bullets (.454)"

/obj/item/ammo_magazine/revolver/internal/mateba
	default_ammo = "/datum/ammo/bullet/revolver/heavy"
	caliber = ".454"
	max_rounds = 8
	gun_type = "/obj/item/weapon/gun/revolver/mateba"
	handful_type = "Bullets (.454)"

/obj/item/weapon/gun/revolver/mateba
	name = "\improper Mateba Autorevolver"
	desc = "The Mateba is a powerful, fast-firing revolver that uses its own recoil to rotate the cylinders. It uses heavy .454 rounds."
	icon_state = "mateba"
	icon_empty = "mateba_dry"
	item_state = "mateba"
	origin_tech = "combat=4;materials=3"
	mag_type = "/obj/item/ammo_magazine/revolver/mateba"
	mag_type_internal = "/obj/item/ammo_magazine/revolver/internal/mateba"
	fire_sound = 'sound/weapons/mateba.ogg'
	fire_delay = 8
	burst_amount = 2
	burst_delay = 4
	recoil = 1
	force = 15
	muzzle_pixel_x = 28
	muzzle_pixel_y = 18
	rail_pixel_x = 12
	rail_pixel_y = 21
	under_pixel_x = 22
	under_pixel_y = 15
	found_on_russians = 1

//-------------------------------------------------------
//MARSHALS REVOLVER

/obj/item/ammo_magazine/revolver/cmb
	name = "Revolver Speed Loader (.357)"
	default_ammo = "/datum/ammo/bullet/revolver/small"
	caliber = ".357"
	icon_state = "38"
	icon_empty = "38-0"
	max_rounds = 6
	gun_type = "/obj/item/weapon/gun/revolver/cmb"
	handful_type = "Bullets (.357)"

/obj/item/ammo_magazine/revolver/internal/cmb
	default_ammo = "/datum/ammo/bullet/revolver/small"
	caliber = ".357"
	max_rounds = 6
	gun_type = "/obj/item/weapon/gun/revolver/cmb"
	handful_type = "Bullets (.357)"

/obj/item/weapon/gun/revolver/cmb
	name = "\improper CMB Spearhead Autorevolver"
	desc = "A powerful automatic revolver chambered in .357. Commonly issued to Colonial Marshals."
	icon_state = "CMB"
	icon_empty = "CMB_dry"
	item_state = "cmbpistol"
	mag_type = "/obj/item/ammo_magazine/revolver/cmb"
	mag_type_internal = "/obj/item/ammo_magazine/revolver/internal/cmb"
	fire_sound = 'sound/weapons/44mag2.ogg'
	fire_delay = 12
	burst_amount = 3
	burst_delay = 6
	recoil = 1
	force = 12
	muzzle_pixel_x = 29
	muzzle_pixel_y = 22
	rail_pixel_x = 11
	rail_pixel_y = 25
	under_pixel_x = 20
	under_pixel_y = 18