/datum/ammo
	var/name = "generic bullet"
	var/caliber = "none"
	var/stun = 0
	var/weaken = 0
	var/paralyze = 0
	var/irradiate = 0
	var/stutter = 0
	var/eyeblur = 0
	var/drowsy = 0
	var/agony = 0
	var/embed = 0
	var/skips_marines = 0
	var/skips_xenos = 0
	var/accuracy = 0
	var/damage = 0
	var/damage_type = BRUTE
	var/armor_pen = 0
	var/incendiary = 0
	var/reverse_accuracy = 0
	var/damage_falloff = 0
	var/range_falloff = 0
	var/silenced = 0
	var/shrapnel_chance = 0

/datum/ammo/bullet
	damage_type = BRUTE
	shrapnel_chance = 10
	embed = 1 //Can embed itself in the target.

/datum/ammo/bullet/45pistol
	name = "pistol bullet"
	caliber = ".45"
	damage = 24
	accuracy = -5 //Not very accurate.

/datum/ammo/bullet/45pistol/hollow
	name = "hollowpoint pistol bullet"
	damage = 20
	accuracy = -10
	shrapnel_chance = 50 //50% likely to generate shrapnel on impact.

/datum/ammo/bullet/45pistol/ap
	name = "AP pistol bullet"
	armor_pen = 10

/datum/ammo/bullet/45pistol/incendiary
	name = "incendiary bullet"
	armor_pen = -5
	incendiary = 1
	accuracy = -15
	damage = 16


//Boxes of ammo
/obj/item/ammo_magazine
	name = "generic ammo"
	desc = "A box of ammo"
	icon = 'icons/obj/ammo.dmi'
	icon_state = "357"
	var/icon_empty = "357-0"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	item_state = "syringe_kit"
	matter = list("metal" = 50000)
	throwforce = 2
	w_class = 1.0
	throw_speed = 2
	throw_range = 6
	var/list/stored_ammo = list() //What ammo is it currently storing? This can be overridden.
	var/default_ammo = /datum/ammo //What ammo does it spawn with by default? Set this to null to make it empty.
	var/max_ammo = 7 //How many rounds can it hold?
	var/gun_type = /obj/item/weapon/gun //What type of gun does it fit in?
	var/fits_in_subtypes = 0 //Does it fit in less generic types? Currently, all guns require a specific magazine.

	New()
		if(!stored_ammo.len && start_ammo > 0 && max_ammo > 0) //Fill the ammo up.
			stored_ammo["[default_ammo]"] = max_ammo

	proc/update_icon()
		if(!stored_ammo.len)
			icon_state = icon_empty
		else
			icon_state = initial(icon_state)

/obj/item/ammo_magazine/pistol_45
	name = "M4A3 Pistol Magazine (.45)"
	icon_state = ".45a"
	icon_empty = ".45a0
	max_ammo = 12
	default_ammo = "/datum/ammo/bullet/45pistol"
	gun_type = "/obj/item/weapon/gun/projectile/m4a3"

/obj/item/ammo_magazine/pistol_45/hp
	name = "M4A3 HP Magazine (.45)"
	default_ammo = "/datum/ammo/bullet/45pistol/hollow"



//Doesn't do anything or hold anything anymore.
/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "s-casing"
	flags = FPRINT | TABLEPASS | CONDUCT
	throwforce = 1
	w_class = 1.0

	New()
		..()
		pixel_x = rand(-10.0, 10)
		pixel_y = rand(-10.0, 10)
		dir = pick(NORTH,EAST,SOUTH,WEST)
		return
