//-------------------------------------------------------
//Generic shotgun magazines. Only three of them, since all shotguns can use the same ammo unless we add other gauges.

/*
Shotguns don't really use unique "ammo" like other guns. They just load from a pool of ammo and generate the projectile
on the go. There's also buffering involved. But, we do need the ammo to check handfuls type, and it's nice to have when
you're looking back on the different shotgun projectiles available. In short of it, it's not needed to have more than
one type of shotgun ammo, but I think it helps in referencing it. ~N
*/
/obj/item/ammo_magazine/shotgun
	name = "Box of Shotgun Slugs"
	desc = "A box filled with heavy shotgun shells. A timeless classic. 12 Gauge."
	icon_state = "shells"
	icon_spent = "gshell"
	default_ammo = "/datum/ammo/bullet/shotgun/slug"
	caliber = "12g" //All shotgun rounds are 12g right now.
	caliber_type = "slug"
	gun_type = "/obj/item/weapon/gun/shotgun"
	handful_type = "Slugs"
	icon_type = "shell_s"
	max_rounds = 25 // Real shotgun boxes are usually 5 or 25 rounds. This works with the new system, five handfuls.
	w_class = 3 // Can't throw it in your pocket, friend.
	handful_max_rounds = 5

/obj/item/ammo_magazine/shotgun/buckshot
	name = "Box of Buckshot Shells"
	desc = "A box filled with buckshot spread shotgun shells. 12 Gauge."
	icon_state = "beanbag"
	icon_spent = "bshell"
	default_ammo = "/datum/ammo/bullet/shotgun/buckshot"
	caliber_type = "buckshot"
	handful_type = "Buckshot"
	icon_type = "shell_b"

/obj/item/ammo_magazine/shotgun/incendiary
	name = "Box of Incendiary Slugs"
	desc = "A box filled with self-detonating incendiary shotgun rounds. 12 Gauge."
	icon_state = "incendiary"
	icon_spent = "ishell"
	default_ammo = "/datum/ammo/bullet/shotgun/incendiary"
	caliber_type = "islug"
	handful_type = "Incendiary Slugs"
	icon_type = "shell_i"

/*
Generic internal magazine. All shotguns will use this or a variation with different ammo number.
Since all shotguns share ammo types, the gun path is going to be the same for all of them. And it
also doesn't really matter. You can only reload them with handfuls.
*/
/obj/item/ammo_magazine/shotgun/internal
	name = "Shotgun Tube"
	desc = "An internal magazine. It is not supposed to be seen or removed."
	default_ammo = "/datum/ammo/bullet/shotgun"
	max_rounds = 8

//-------------------------------------------------------

/*
Shotguns always start with an ammo buffer and they work by alternating ammo and ammo_buffer1
in order to fire off projectiles. This is only done to enable burst fire for the shotgun.
Consequently, the shotgun should never fire more than three projectiles on burst as that
can cause issues with ammo types getting mixed up during the burst.
*/

/obj/item/weapon/gun/shotgun
	origin_tech = "combat=4;materials=3"
	w_class = 4
	mag_type_internal = "/obj/item/ammo_magazine/shotgun/internal"
	recoil = 2
	force = 14.0
	twohanded = 1
	fire_sound = 'sound/weapons/shotgun.ogg'
	reload_sound = 'sound/weapons/shotgun_shell_insert.ogg'
	cocked_sound = 'sound/weapons/gun_shotgun_reload.ogg'
	var/opened_sound = 'sound/weapons/shotgun_open2.ogg'
	accuracy = 10
	slot_flags = SLOT_BACK
	type_of_casings = "shell"
	eject_casings = 1
	autoejector = 0 // It doesn't do this.
	var/shotgun_alt_fire = 0


	New()
		..()
		replace_tube(current_mag.current_rounds) //Populate the chamber.
		ammo_buffer1 = new /datum/ammo/bullet/shotgun() //Load the buffer. Shotguns will always have a buffer.

	update_icon()
		if(isnull(icon_empty)) return
		if(!in_chamber) //If it doesn't have something chambered, it's empty.
			icon_state = icon_empty
		else
			icon_state = initial(icon_state)
		update_attachables() //This will cut existing overlays
		if(current_mag && !isnull(current_mag.bonus_overlay))
			var/image/I = new(current_mag.icon,current_mag.bonus_overlay) //Mag adds an overlay
			overlays += I

	proc/replace_tube(var/number_to_replace)
		current_mag.tube_contents = list()
		current_mag.tube_contents.len = current_mag.max_rounds
		var/i
		for(i = 1 to current_mag.max_rounds) //We want to make sure to populate the tube.
			if(i > number_to_replace)
				current_mag.tube_contents[i] = "empty"
			else
				current_mag.tube_contents[i] = current_mag.caliber_type
		current_mag.tube_position = current_mag.current_rounds //The position is always in the beginning (1). It can move from there.
		return

	proc/add_to_tube(var/mob/user as mob,var/selection) //Shells are added forward.

		current_mag.tube_position++ //We move the position up when loading ammo. New rounds are always fired next, in order loaded.
		current_mag.tube_contents[current_mag.tube_position] = selection //Just moves up one, unless the mag is full.

		if(current_mag.current_rounds == 1 && !in_chamber) //The previous proc in the reload() cycle adds ammo, so the best workaround here,
			update_icon()					//It was just loaded.
			ready_in_chamber()
			spawn(3)
				if(user && cocked_sound) playsound(user, cocked_sound, 100, 1)

		if(user) playsound(user, reload_sound, 100, 1)
		return 1

	/*
	This is how we actually select what the shotgun will fire.
	Just add if switches here if you need more ammo or something.
	Keep in mind you also need to mod retrieve_shell() and
	modify /datum/ammo/bullet/shotgun in ammo_datums.dm in order
	to do any special effects. Look for existing examples.
	*/
	proc/select_ammunition(var/selection, var/datum/ammo/buffer)
		switch(selection) //We're gonna grab the ammo type.
			if("slug")
				buffer.name = "slug"
				buffer.effect_type = "slug"
				buffer.damage = 65
				buffer.damage_bleed = 0
				buffer.accurate_range = 6
				buffer.max_range = 12
				buffer.icon_state = "bullet"
				buffer.armor_pen = 20
				buffer.bonus_projectiles = 0
				buffer.incendiary = 0
				buffer.damage_type = BRUTE

			if("islug")
				buffer.name = "incendiary slug"
				buffer.effect_type = "islug"
				buffer.damage = 50
				buffer.damage_bleed = 0
				buffer.accurate_range = 6
				buffer.max_range = 12
				buffer.icon_state = "bullet"
				buffer.armor_pen = 15
				buffer.bonus_projectiles = 0
				buffer.incendiary = 1
				buffer.damage_type = BURN

			if("buckshot")
				buffer.name = "buckshot"
				buffer.effect_type = "buckshot"
				buffer.damage = 100
				buffer.damage_bleed = 20
				buffer.accurate_range = 4
				buffer.max_range = 4
				buffer.icon_state = "buckshot"
				buffer.armor_pen = 0
				buffer.bonus_projectiles = 4
				buffer.incendiary = 0
				buffer.damage_type = BRUTE

			else
				return //If it's something else, it's empty, but this shouldn't happen.
		return 1

	proc/empty_chamber(var/mob/user)
		if(current_mag.current_rounds <= 0)
			if(user) user << "\The [src] is already empty."
			return

		unload_shell(user)

		if(!current_mag.current_rounds && !in_chamber)
			update_icon()

	proc/unload_shell(var/mob/user)
		var/obj/item/ammo_magazine/handful/new_handful = retrieve_shell(current_mag.tube_contents[current_mag.tube_position])

		if(!user)
			new_handful.loc = get_turf(src)
		else
			user.put_in_hands(new_handful)
			playsound(user, reload_sound, 60, 1)

		current_mag.current_rounds--
		current_mag.tube_contents[current_mag.tube_position] = "empty"
		current_mag.tube_position--
		return 1

		//While there is a much smaller way to do this,
		//this is the most resource efficient way to do it.
	proc/retrieve_shell(var/selection)
		var/obj/item/ammo_magazine/handful/new_handful = new()
		var/handful_t //handful_type, based on shell.
		var/handful_i //icon
		var/handful_a //default ammo

		switch(selection)
			if("slug")
				handful_t = "Slugs"
				handful_i = "shell_s"
				handful_a = "/datum/ammo/bullet/shotgun/slug"
			if("islug")
				handful_t = "Incendiary Slugs"
				handful_i = "shell_i"
				handful_a = "/datum/ammo/bullet/shotgun/incendiary"
			if("buckshot")
				handful_t = "Buckshot"
				handful_i = "shell_b"
				handful_a = "/datum/ammo/bullet/shotgun/buckshot"

		new_handful.name = "Handful of [handful_t]"
		new_handful.desc = "A handful of rounds to reload on the go."
		new_handful.icon_state = handful_i
		new_handful.caliber = "12g"
		new_handful.caliber_type = selection
		new_handful.max_rounds = 5
		new_handful.current_rounds = 1
		new_handful.default_ammo = handful_a
		new_handful.icon_type = handful_i
		new_handful.gun_type = "/obj/item/weapon/gun/shotgun"
		new_handful.handful_type = handful_t
		new_handful.update_icon() // Let's get it updated.

		return new_handful

	proc/check_tube_position()
		return 1

	reload(var/mob/user = null, var/obj/item/ammo_magazine/magazine)
		if(burst_toggled && burst_firing) return

		if(!magazine || !istype(magazine,/obj/item/ammo_magazine/handful)) //Can only reload with handfuls.
			if(user) user << "You can't use that to reload!"
			return

		if(user)
			var/obj/item/ammo_magazine/in_hand = user.get_inactive_hand()
			if( in_hand != src ) //It has to be held.
				user << "You have to hold \the [src] to reload!"
				return

		if(!check_tube_position()) //For the double barrel.
			if(user) user << "\The [src] has to be open!"
			return

		//From here we know they are using shotgun type ammo and reloading via handful.
		//Makes some of this a lot easier to determine.

		var/mag_caliber = magazine.caliber_type //Handfuls can get deleted, so we need to keep this on hand for later.
		if(current_mag.transfer_ammo(magazine,current_mag,user,1))
			add_to_tube(user,mag_caliber) //This will check the other conditions.
			update_icon()
		return

	unload(var/mob/user as mob)
		if(burst_toggled && burst_firing) return

		empty_chamber(user)

		return

	ready_in_chamber()
		var/datum/ammo/buffer = shotgun_alt_fire ? ammo_buffer1 : ammo
		if(current_mag && current_mag.current_rounds > 0)
			if( select_ammunition(current_mag.tube_contents[current_mag.tube_position],buffer) )
				in_chamber = create_bullet(buffer)
				current_mag.current_rounds-- //Subtract the round here, because we don't chamber rounds.
				current_mag.tube_contents[current_mag.tube_position] = "empty"
				current_mag.tube_position-- //Moves the position down.
				shotgun_alt_fire = !shotgun_alt_fire
				return in_chamber
		return

	reload_into_chamber(var/mob/user as mob)
		if(active_attachable)
			make_casing(active_attachable.type_of_casings, active_attachable.eject_casings)
		else
			make_casing(type_of_casings, eject_casings)
			in_chamber = null

		if(!active_attachable) //Time to move the tube position.
			ready_in_chamber() //We're going to try and reload. If we don't get anything, icon change.
			if(!current_mag.current_rounds && !in_chamber) //No rounds, nothing chambered.
				update_icon()
		else
			if(!active_attachable.continuous)
				active_attachable = null

		return 1

//-------------------------------------------------------

/obj/item/ammo_magazine/shotgun/internal/merc
	max_rounds = 5

/obj/item/weapon/gun/shotgun/merc
	name = "\improper Custom Built Shotgun"
	desc = "A cobbled-together pile of scrap and alien wood. Point end towards things you want to die. Has a burst fire feature, as if it needed it."
	icon_state = "rspshotgun"
	icon_empty = "rspshotgun0"
	item_state = "rspshotgun"
	origin_tech = "combat=4;materials=2"
	fire_sound = 'sound/weapons/shotgun_automatic.ogg'
	mag_type_internal = "/obj/item/ammo_magazine/shotgun/internal/merc"
	fire_delay = 10
	muzzle_pixel_x = 31
	muzzle_pixel_y = 19
	rail_pixel_x = 10
	rail_pixel_y = 21
	under_pixel_x = 17
	under_pixel_y = 14
	burst_amount = 2
	burst_delay = 2
	accuracy = -10
	found_on_mercs = 1
	twohanded = 0

	New()
		..()
		load_into_chamber()

	examine()
		..()

		if(in_chamber)
			usr << "It has a chambered round."

//-------------------------------------------------------

/obj/item/ammo_magazine/shotgun/internal/combat
	max_rounds = 6

/obj/item/weapon/gun/shotgun/combat
	name = "\improper MK221 Tactical Shotgun"
	desc = "The Weyland-Yutani MK221 Shotgun, a semi-automatic shotgun with a quick fire rate."
	icon_state = "cshotgun"
	icon_empty = "cshotgun"
	item_state = "cshotgun"
	icon_wielded = "cshotgun-w"
	origin_tech = "combat=5;materials=4"
	fire_sound = 'sound/weapons/shotgun_automatic.ogg'
	mag_type_internal = "/obj/item/ammo_magazine/shotgun/internal/combat"
	fire_delay = 12
	muzzle_pixel_x = 33
	muzzle_pixel_y = 19
	rail_pixel_x = 10
	rail_pixel_y = 21
	under_pixel_x = 14
	under_pixel_y = 16

	New()
		..()
		var/obj/item/attachable/grenade/G = new(src)
		G.can_be_removed = 0
		G.icon_state = "" //Gun already has a better one
		G.Attach(src)
		update_attachables()
		load_into_chamber()

	examine()
		..()

		if(in_chamber)
			usr << "It has a chambered round."

//-------------------------------------------------------

/obj/item/ammo_magazine/shotgun/internal/double //For a double barrel.
	caliber_type = "buckshot"
	max_rounds = 2
	tube_closed = 1 //Starts out with a closed tube.

/obj/item/weapon/gun/shotgun/double
	name = "\improper Double Barrel Shotgun"
	desc = "A double barreled shotgun of archaic, but sturdy design. Uses 12 Gauge Special slugs, but can only hold 2 at a time."
	icon_state = "dshotgun"
	icon_empty = "dshotgun0"
	item_state = "dshotgun"
	icon_wielded = "dshotgun-w"
	origin_tech = "combat=4;materials=2"
	mag_type_internal = "/obj/item/ammo_magazine/shotgun/internal/double"
	fire_sound = 'sound/weapons/shotgun_heavy.ogg'
	cocked_sound = null //We don't want this.
	fire_delay = 6
	muzzle_pixel_x = 33
	muzzle_pixel_y = 21
	rail_pixel_x = 15
	rail_pixel_y = 22
	under_pixel_x = 21
	under_pixel_y = 16
	found_on_mercs = 1


	examine()
		..()

		if(current_mag.tube_closed)
			usr << "It's closed."
		else
			usr << "It's open with [current_mag.current_rounds] shell\s loaded."

	//Turns out it has some attachments.
	update_icon()
		if(isnull(icon_empty)) return
		if(current_mag.tube_closed)
			icon_state = initial(icon_state)
		else
			icon_state = icon_empty
		update_attachables()

	check_tube_position()
		if(current_mag.tube_closed)
			return
		return 1

	add_to_tube(var/mob/user as mob,var/selection) //Load it on the go, nothing chambered.
		current_mag.tube_position++
		current_mag.tube_contents[current_mag.tube_position] = selection

		if(user) playsound(user, reload_sound, 100, 1)
		return 1

	able_to_fire(var/mob/user as mob)
		if(!current_mag.tube_closed)
			user << "\red Close the chamber!"
			return
		return ..()

	empty_chamber(var/mob/user)
		if(current_mag.tube_closed && current_mag.current_rounds)
			var/i
			for(i = 1 to current_mag.current_rounds)
				unload_shell(user)

		current_mag.tube_closed = !current_mag.tube_closed
		update_icon()
		if(user) playsound(user, reload_sound, 60, 1)
		return

	load_into_chamber()
		//Trimming down the unnecessary stuff.
		//This doesn't chamber, creates a bullet on the go.
		if(active_attachable && active_attachable.passive)
			active_attachable = null

		if(current_mag && current_mag.current_rounds > 0)
			var/datum/ammo/buffer = shotgun_alt_fire ? ammo_buffer1 : ammo

			if( select_ammunition(current_mag.tube_contents[current_mag.tube_position],buffer) )
				in_chamber = create_bullet(buffer)
				current_mag.current_rounds--
				return in_chamber

		return //We can't make a projectile without a mag or active attachable.

	delete_bullet(var/obj/item/projectile/projectile_to_fire, var/refund = 0)
		del(projectile_to_fire)
		if(refund)
			current_mag.current_rounds++
		return 1

	reload_into_chamber(var/mob/user as mob)
		make_casing(type_of_casings, eject_casings)
		in_chamber = null

		current_mag.tube_contents[current_mag.tube_position] = "empty"
		current_mag.tube_position--
		shotgun_alt_fire = !shotgun_alt_fire
		if(!current_mag.current_rounds)
			update_icon()

		return 1

/obj/item/weapon/gun/shotgun/double/sawn
	name = "\improper Sawn-Off Shotgun"
	desc = "A double barreled shotgun whose barrel has been artificially shortened to reduce range but increase damage and spread."
	icon_state = "sawnshotgun"
	icon_empty = "sawnshotgun0"
	item_state = "sawnshotgun"
	fire_delay = 3
	muzzle_pixel_x = 30
	muzzle_pixel_y = 20
	rail_pixel_x = 11
	rail_pixel_y = 22
	under_pixel_x = 18
	under_pixel_y = 16
	accuracy = -20
	twohanded = 0
	dam_bonus = 15
	slot_flags = SLOT_BELT

//-------------------------------------------------------
//Shotguns in this category will need to be pumped each shot.

/obj/item/ammo_magazine/shotgun/internal/pump
	max_rounds = 7

/obj/item/weapon/gun/shotgun/pump
	name = "\improper M37A2 Pump Shotgun"
	desc = "An Armat Battlefield Systems classic design, the M37A2 combines close-range firepower with long term reliability. Requires a pump, which is a Unique Action."
	icon_state = "m37"
	icon_empty = "m37" //Pump shotguns don't really have 'empty' states.
	icon_wielded = "m37-w"
	item_state = "m37"
	mag_type_internal = "/obj/item/ammo_magazine/shotgun/internal/pump"
	fire_sound = 'sound/weapons/shotgun.ogg'
	var/pump_sound = 'sound/weapons/shotgunpump.ogg'
	fire_delay = 20
	muzzle_pixel_x = 33
	muzzle_pixel_y = 18
	rail_pixel_x = 10
	rail_pixel_y = 21
	under_pixel_x = 20
	under_pixel_y = 14
	var/pump_delay = 15 //Higher means longer delay.
	var/recent_pump = 0

	New()
		..()
		del(ammo_buffer1) //No need for it.

	unique_action(var/mob/user as mob)
		pump_shotgun(user)

	ready_in_chamber() //If there wasn't a shell loaded through pump, this returns null.
		return

	//Same as double barrel. We don't want to do anything else here.
	add_to_tube(var/mob/user as mob,var/selection) //Load it on the go, nothing chambered.
		current_mag.tube_position++
		current_mag.tube_contents[current_mag.tube_position] = selection

		if(user) playsound(user, reload_sound, 100, 1)
		return 1

/*
Moves the ready_in_chamber to it's own proc.
If the Fire() cycle doesn't find a chambered round with no active attachable, it will return null.
Which is what we want, since the gun shouldn't fire unless something was chambered.
*/
	proc/ready_through_pump()
		if(current_mag && current_mag.current_rounds > 0)
			if( select_ammunition(current_mag.tube_contents[current_mag.tube_position],ammo) )
				in_chamber = create_bullet(ammo)
				current_mag.current_rounds--
				current_mag.tube_contents[current_mag.tube_position] = "empty"
				current_mag.tube_position--
				return in_chamber

	//More or less chambers the round instead of load_into_chamber(). Also ejects used casings.
	proc/pump_shotgun(var/mob/user as mob)	//We can't fire bursts with pumps, so no need for a buffer.
		if(recent_pump) return //Don't spam it.

		if(in_chamber) //We don't want them to pump out loaded rounds.
			if(user) user << "\red It's already chambered with a round!"
			return

		if(!in_chamber)
			ready_through_pump()

		if(current_mag.used_casings)
			current_mag.used_casings--
			make_casing(type_of_casings, eject_casings)

		playsound(user, pump_sound, 70, 1)
		spawn(pump_delay) //Spawn delays the next pump, so they're not spamming it.
			recent_pump = !recent_pump

		recent_pump = !recent_pump
		return //We can't make a projectile without a mag or active attachable.

	reload_into_chamber(var/mob/user as mob)
		if(active_attachable)
			make_casing(active_attachable.type_of_casings, active_attachable.eject_casings)
		else
			current_mag.used_casings++ //The shell was fired successfully. Add it to used.

		if(!active_attachable) //Time to move the tube position.
			if(!current_mag.current_rounds && !in_chamber) //No rounds, nothing chambered.
				update_icon()
		else
			if(!active_attachable.continuous)
				active_attachable = null

		return 1

//-------------------------------------------------------

/obj/item/ammo_magazine/shotgun/internal/pump/CMB //The only cycle method.
	caliber_type = "islug"
	max_rounds = 4

/obj/item/weapon/gun/shotgun/pump/cmb
	name = "\improper HG 37-12 Pump Shotgun"
	desc = "A four-round pump action shotgun with internal tube magazine allowing for quick reloading and highly accurate fire. Used exclusively by Colonial Marshals."
	icon_state = "CMBshotgun"
	icon_empty = "CMBshotgun"
	item_state = "CMBshotgun"
	icon_wielded = "CMBshotgun-w"
	mag_type_internal = "/obj/item/ammo_magazine/shotgun/internal/pump/CMB"
	fire_sound = 'sound/weapons/shotgun_small.ogg'
	fire_delay = 16
	muzzle_pixel_x = 30
	muzzle_pixel_y = 20
	rail_pixel_x = 10
	rail_pixel_y = 23
	under_pixel_x = 19
	under_pixel_y = 17

//-------------------------------------------------------