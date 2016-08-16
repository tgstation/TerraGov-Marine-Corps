//-------------------------------------------------------
//ENERGY GUNS/ETC
/obj/item/weapon/gun/energy/taser
	name = "taser gun"
	desc = "An advanced stun device capable of firing balls of ionized electricity. Used for nonlethal takedowns."
	icon_state = "taser"
	item_state = "taser"
	muzzle_flash = null //TO DO.
	fire_sound = 'sound/weapons/Taser.ogg'
	origin_tech = "combat=1;materials=1"
	matter = list("metal" = 40000)
	ammo = /datum/ammo/energy/taser
	var/obj/item/weapon/cell/high/cell //10000 power.
	var/charge_cost = 100 //100 shots.
	gun_features = GUN_UNUSUAL_DESIGN

	New()
		..()
		fire_delay = config.high_fire_delay * 2
		cell = new /obj/item/weapon/cell/high(src)

	update_icon()
		icon_state = (!cell || cell.charge - charge_cost < 0) ? icon_state + "_e" : initial(icon_state)

	emp_act(severity)
		cell.use(round(cell.maxcharge / severity))
		update_icon()
		..()

	able_to_fire(var/mob/living/carbon/human/user as mob)
		if(..()) //Let's check all that other stuff first.
			if(istype(user))
				var/obj/item/weapon/card/id/card = user.wear_id
				if(istype(card) && card.assignment == "Military Police") return 1//We can check for access, but only MPs have access to it.
				else user << "<span class='warning'>[src] is ID locked!</span>"

	load_into_chamber()
		if(!cell || cell.charge - charge_cost < 0) return

		cell.charge -= charge_cost
		in_chamber = create_bullet(ammo)
		return in_chamber

	reload_into_chamber()
		update_icon()
		return 1

	delete_bullet(var/obj/item/projectile/projectile_to_fire, refund = 0)
		cdel(projectile_to_fire)
		if(refund) cell.charge += charge_cost
		return 1

//-------------------------------------------------------
//The first rule of monkey pistol is we don't talk about monkey pistol.
/obj/item/ammo_magazine/pistol/chimp
	name = "\improper CHIMP70 magazine (.70M)"
	default_ammo = /datum/ammo/bullet/pistol/mankey
	caliber = ".70M"
	icon_state = "c70" //PLACEHOLDER
	origin_tech = "combat=8;materials=8;syndicate=8;bluespace=8"
	matter = list("metal" = 100000)
	max_rounds = 300
	gun_type = /obj/item/weapon/gun/pistol/chimp

/obj/item/weapon/gun/pistol/chimp
	name = "\improper CHIMP70 pistol"
	desc = "A powerful sidearm issed mainly to highly trained elite assassin necro-cyber-agents."
	icon_state = "c70"
	item_state = "c70"
	origin_tech = "combat=8;materials=8;syndicate=8;bluespace=8"
	current_mag = /obj/item/ammo_magazine/pistol/chimp
	fire_sound = 'sound/weapons/chimp70.ogg'
	w_class = 3
	force = 8
	type_of_casings = null
	attachable_allowed = list()
	gun_features = GUN_AUTO_EJECTOR | GUN_WY_RESTRICTED

	New()
		..()
		fire_delay = config.low_fire_delay
		burst_delay = config.mlow_fire_delay
		burst_amount = config.low_burst_value

//-------------------------------------------------------

/obj/item/weapon/gun/flare
	name = "flare gun"
	desc = "A gun that fires flares. Replace with flares. Simple!"
	icon_state = "flaregun" //REPLACE THIS
	item_state = "gun" //YUCK
	fire_sound = 'sound/weapons/flaregun.ogg'
	origin_tech = "combat=1;materials=2"
	ammo = /datum/ammo/flare
	var/num_flares = 1
	var/max_flares = 1
	gun_features = GUN_UNUSUAL_DESIGN

	examine()
		..()
		fire_delay = config.low_fire_delay*3
		if(num_flares)
			usr << "<span class='warning'>It has a flare loaded!</span>"

	update_icon()
		icon_state = num_flares ? initial(icon_state) : icon_state + "_e"

	load_into_chamber()
		if(num_flares)
			in_chamber = create_bullet(ammo)
			in_chamber.SetLuminosity(4)
			num_flares--
			return in_chamber

	reload_into_chamber()
		update_icon()
		return 1

	delete_bullet(var/obj/item/projectile/projectile_to_fire, refund = 0)
		cdel(projectile_to_fire)
		if(refund) num_flares++
		return 1

	attackby(obj/item/I as obj, mob/user as mob)
		if(istype(I,/obj/item/device/flashlight/flare))
			var/obj/item/device/flashlight/flare/flare = I
			if(num_flares >= max_flares)
				user << "It's already full."
				return

			if(flare.on)
				user << "<span class='warning'>[flare] is already active. Can't load it now!</span>"
				return

			num_flares++
			user.remove_from_mob(flare)
			sleep(-1)
			del(flare)
			user << "<span class='notice'>You insert the flare.</span>"
			update_icon()
			return

		return ..()

	unload(var/mob/user)
		if(num_flares)
			var/obj/item/device/flashlight/flare/new_flare = new()
			if(user) user.put_in_hands(new_flare)
			else new_flare.loc = get_turf(src)
			num_flares--
			if(user) user << "<span class='notice'>You unload a flare from [src].</span>"
			update_icon()
		else user << "<span class='warning'>It's empty!</span>"

//-------------------------------------------------------
//This gun is very powerful, but also has a kick.

/obj/item/ammo_magazine/minigun
	name = "rotating ammo drum (7.62x51mm)"
	desc = "A huge ammo drum for a huge gun."
	caliber = "7.62×51mm"
	icon_state = "painless" //PLACEHOLDER
	origin_tech = "combat=3;materials=3"
	matter = list("metal" = 100000)
	default_ammo = /datum/ammo/bullet/minigun
	max_rounds = 300
	reload_delay = 24 //Hard to reload.
	gun_type = /obj/item/weapon/gun/minigun

/obj/item/weapon/gun/minigun
	name = "\improper Ol' Painless"
	desc = "An enormous multi-barreled rotating gatling gun. This thing will no doubt pack a punch."
	icon_state = "painless"
	item_state = "painless"
	origin_tech = "combat=7;materials=5"
	fire_sound = 'sound/weapons/minigun.ogg'
	cocked_sound = 'sound/weapons/gun_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/minigun
	type_of_casings = "cartridge"
	w_class = 5
	force = 20
	flags = FPRINT | CONDUCT | TWOHANDED
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK | GUN_BURST_ON

	New()
		..()
		recoil = config.med_recoil_value
		accuracy -= config.med_hit_accuracy_mult
		burst_amount = config.max_burst_value
		fire_delay = config.low_fire_delay
		burst_delay = config.min_fire_delay
		load_into_chamber()

	toggle_burst()
		usr << "<span class='warning'>This weapon can only fire in bursts!</span>"

//-------------------------------------------------------
//Toy rocket launcher.

/obj/item/weapon/gun/launcher/rocket/nobugs //Fires dummy rockets, like a toy gun
	name = "\improper BUG ROCKER rocket launcher"
	desc = "Where did this come from? <b>NO BUGS</b>"
	current_mag = /obj/item/ammo_magazine/internal/launcher/rocket/nobugs

/obj/item/ammo_magazine/rocket/nobugs
	name = "\improper BUG ROCKER rocket tube"
	desc = "Where did this come from? <b>NO BUGS</b>"
	default_ammo = /datum/ammo/rocket/nobugs
	caliber = "toy rocket"

/obj/item/ammo_magazine/internal/launcher/rocket/nobugs
	default_ammo = /datum/ammo/rocket/nobugs
	gun_type = /obj/item/weapon/gun/launcher/rocket/nobugs

/datum/ammo/rocket/nobugs
	name = "\improper NO BUGS rocket"
	damage = 1

	on_hit_mob(mob/M,obj/item/projectile/P)
		M << "<font size=6 color=red>NO BUGS</font>"

	on_hit_obj(obj/O,obj/item/projectile/P)
		return

	on_hit_turf(turf/T,obj/item/projectile/P)
		return

	do_at_max_range(obj/item/projectile/P)
		return