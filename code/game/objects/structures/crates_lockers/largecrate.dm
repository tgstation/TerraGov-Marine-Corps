/obj/structure/largecrate
	name = "large crate"
	desc = "A hefty wooden crate."
	icon = 'icons/obj/structures/crates.dmi'
	icon_state = "densecrate"
	density = TRUE
	anchored = FALSE
	resistance_flags = XENO_DAMAGEABLE
	max_integrity = 100
	hit_sound = 'sound/effects/woodhit.ogg'
	var/spawn_type
	var/spawn_amount


/obj/structure/largecrate/deconstruct(disassembled = TRUE)
	spawn_stuff()
	return ..()


/obj/structure/largecrate/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>You need a crowbar to pry this open!</span>")


/obj/structure/largecrate/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return TRUE

	if(istype(I, /obj/item/powerloader_clamp))
		return

	return attack_hand(user)


/obj/structure/largecrate/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	user.visible_message("<span class='notice'>[user] pries \the [src] open.</span>",
		"<span class='notice'>You pry open \the [src].</span>",
		"<span class='notice'>You hear splitting wood.</span>")
	new /obj/item/stack/sheet/wood(loc)
	deconstruct(TRUE)
	return TRUE


/obj/structure/largecrate/proc/spawn_stuff()
	var/turf/T = get_turf(src)
	if(spawn_type && spawn_amount)
		for(var/i in 1 to spawn_amount)
			new spawn_type(T)
	for(var/obj/O in contents)
		O.forceMove(loc)


/obj/structure/largecrate/mule
	icon_state = "mulecrate"

/obj/structure/largecrate/lisa
	icon_state = "lisacrate"
	spawn_type = /mob/living/simple_animal/corgi/Lisa
	spawn_amount = 1


/obj/structure/largecrate/cow
	name = "cow crate"
	icon_state = "lisacrate"
	spawn_type = /mob/living/simple_animal/cow
	spawn_amount = 1


/obj/structure/largecrate/goat
	name = "goat crate"
	icon_state = "lisacrate"
	spawn_type = /mob/living/simple_animal/hostile/retaliate/goat
	spawn_amount = 1


/obj/structure/largecrate/chick
	name = "chicken crate"
	icon_state = "lisacrate"
	spawn_type = /mob/living/simple_animal/chick
	spawn_amount = 4


///////////CM largecrates ///////////////////////



//Possibly the most generically named procs in history. congrats
/obj/structure/largecrate/random
	name = "supply crate"
	var/num_things = 0
	var/list/stuff = list(
						/obj/item/cell/high,
						/obj/item/storage/belt/utility/full,
						/obj/item/multitool,
						/obj/item/tool/crowbar,
						/obj/item/flashlight,
						/obj/item/reagent_containers/food/snacks/donkpocket,
						/obj/item/explosive/grenade/smokebomb,
						/obj/item/circuitboard/airlock,
						/obj/item/assembly/igniter,
						/obj/item/tool/weldingtool,
						/obj/item/tool/wirecutters,
						/obj/item/analyzer,
						/obj/item/clothing/under/marine/standard,
						/obj/item/clothing/shoes/marine
						)

/obj/structure/largecrate/random/Initialize()
	. = ..()
	if(!num_things) num_things = rand(0,3)

	while(num_things)
		if(!num_things)
			break
		num_things--
		var/obj/item/thing = pick(stuff)
		new thing(src)

/obj/structure/largecrate/random/case
	name = "storage case"
	desc = "A black storage case."
	icon_state = "case"

/obj/structure/largecrate/random/case/double
	name = "cases"
	desc = "A stack of black storage cases."
	icon_state = "case_double"

/obj/structure/largecrate/random/case/double/deconstruct(disassembled = TRUE)
	new /obj/structure/largecrate/random/case(loc)
	new /obj/structure/largecrate/random/case(loc)
	return ..()

/obj/structure/largecrate/random/case/small
	name = "small cases"
	desc = "Two small black storage cases."
	icon_state = "case_small"


/obj/structure/largecrate/random/barrel/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal/small_stack(src)
	return ..()


/obj/structure/largecrate/random/barrel/welder_act(mob/living/user, obj/item/tool/weldingtool/welder)
	if(!welder.isOn())
		return FALSE
	if(!do_after(user, 5 SECONDS, TRUE, src, BUSY_ICON_BUILD))
		return TRUE
	if(!welder.remove_fuel(1, user))
		return TRUE
	user.visible_message("<span class='notice'>[user] welds \the [src] open.</span>",
		"<span class='notice'>You weld open \the [src].</span>",
		"<span class='notice'>You hear loud hissing and the sound of metal falling over.</span>")
	playsound(loc, 'sound/items/welder2.ogg', 25, TRUE)
	deconstruct(TRUE)
	return TRUE


/obj/structure/largecrate/random/barrel/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>You need a blowtorch to weld this open!</span>")


/obj/structure/largecrate/random/barrel
	name = "blue barrel"
	desc = "A blue storage barrel"
	icon_state = "barrel_blue"
	hit_sound = 'sound/effects/metalhit.ogg'

/obj/structure/largecrate/random/barrel/blue
	name = "blue barrel"
	desc = "A blue storage barrel"
	icon_state = "barrel_blue"

/obj/structure/largecrate/random/barrel/red
	name = "red barrel"
	desc = "A red storage barrel"
	icon_state = "barrel_red"

/obj/structure/largecrate/random/barrel/green
	name = "green barrel"
	desc = "A green storage barrel"
	icon_state = "barrel_green"

/obj/structure/largecrate/random/barrel/yellow
	name = "yellow barrel"
	desc = "A yellow storage barrel"
	icon_state = "barrel_yellow"

/obj/structure/largecrate/random/barrel/white
	name = "white barrel"
	desc = "A white storage barrel"
	icon_state = "barrel_white"

/obj/structure/largecrate/random/secure
	name = "secure supply crate"
	desc = "A secure crate."
	icon_state = "secure_crate_strapped"
	var/strapped = 1


/obj/structure/largecrate/random/secure/crowbar_act(mob/living/user, obj/item/I)
	if(strapped)
		return FALSE
	return ..()


/obj/structure/largecrate/random/secure/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	to_chat(user, "<span class='notice'>You begin to cut the straps off \the [src]...</span>")
	if(!do_after(user, 1.5 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
		return TRUE
	playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
	to_chat(user, "<span class='notice'>You cut the straps away.</span>")
	icon_state = "secure_crate"
	strapped = FALSE
	return TRUE


/obj/structure/largecrate/random/barrel/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>You need something sharp to cut off the straps.</span>")

/obj/structure/largecrate/guns
	name = "\improper TGMC firearms crate (x3)"
	var/num_guns = 3
	var/num_mags = 3
	var/list/stuff = list(
					/obj/item/weapon/gun/pistol/m4a3 = /obj/item/ammo_magazine/pistol/hp,
					/obj/item/weapon/gun/pistol/m4a3 = /obj/item/ammo_magazine/pistol/ap,
					/obj/item/weapon/gun/revolver/m44 = /obj/item/ammo_magazine/revolver/marksman,
					/obj/item/weapon/gun/revolver/m44 = /obj/item/ammo_magazine/revolver/heavy,
					/obj/item/weapon/gun/shotgun/pump/t35 = /obj/item/ammo_magazine/shotgun,
					/obj/item/weapon/gun/shotgun/pump/t35 = /obj/item/ammo_magazine/shotgun/incendiary,
					/obj/item/weapon/gun/shotgun/combat = /obj/item/ammo_magazine/shotgun,
					/obj/item/weapon/gun/flamer = /obj/item/ammo_magazine/flamer_tank,
					/obj/item/weapon/gun/pistol/m4a3/custom = /obj/item/ammo_magazine/pistol/incendiary,
					/obj/item/weapon/gun/rifle/standard_assaultrifle = /obj/item/ammo_magazine/rifle/standard_assaultrifle,
					/obj/item/weapon/gun/rifle/standard_lmg = /obj/item/ammo_magazine/standard_lmg,
					/obj/item/weapon/gun/launcher/m81 = /obj/item/explosive/grenade/phosphorus
					)

/obj/structure/largecrate/guns/Initialize()
	. = ..()
	var/gun_type
	var/i = 0
	while(++i <= num_guns)
		gun_type = pick(stuff)
		new gun_type(src)
		var/obj/item/ammo_magazine/new_mag = stuff[gun_type]
		var/m = 0
		while(++m <= num_mags)
			new new_mag(src)

/obj/structure/largecrate/guns/russian
	num_guns = 1
	num_mags = 1
	name = "\improper Nagant-Yamasaki firearm crate"
	stuff = list(
					/obj/item/weapon/gun/revolver/upp = /obj/item/ammo_magazine/revolver/upp,
					/obj/item/weapon/gun/pistol/c99 = /obj/item/ammo_magazine/pistol/c99,
					/obj/item/weapon/gun/pistol/kt42 = /obj/item/ammo_magazine/pistol/automatic,
					/obj/item/weapon/gun/rifle/ak47 = /obj/item/ammo_magazine/rifle/ak47,
					/obj/item/weapon/gun/rifle/ak47/carbine = /obj/item/ammo_magazine/rifle/ak47/extended,
					/obj/item/weapon/gun/rifle/sniper/svd = /obj/item/ammo_magazine/sniper/svd,
					/obj/item/weapon/gun/smg/ppsh = /obj/item/ammo_magazine/smg/ppsh,
					/obj/item/weapon/gun/rifle/type71 = /obj/item/ammo_magazine/rifle/type71,
					/obj/item/weapon/gun/rifle/sniper/svd = /obj/item/ammo_magazine/sniper/svd
				)

/obj/structure/largecrate/guns/merc
	num_guns = 1
	num_mags = 1
	name = "\improper Black market firearm crate"
	stuff = list(
					/obj/item/weapon/gun/pistol/holdout = /obj/item/ammo_magazine/pistol/holdout,
					/obj/item/weapon/gun/pistol/highpower = /obj/item/ammo_magazine/pistol/highpower,
					/obj/item/weapon/gun/pistol/m1911 = /obj/item/ammo_magazine/pistol/m1911,
					/obj/item/weapon/gun/pistol/vp70 = /obj/item/ammo_magazine/pistol/vp70,
					/obj/item/weapon/gun/pistol/heavy = /obj/item/ammo_magazine/pistol/heavy,
					/obj/item/weapon/gun/revolver/small = /obj/item/ammo_magazine/revolver/small,
					/obj/item/weapon/gun/revolver/cmb = /obj/item/ammo_magazine/revolver/cmb,
					/obj/item/weapon/gun/shotgun/merc = /obj/item/ammo_magazine/shotgun/flechette,
					/obj/item/weapon/gun/shotgun/pump/cmb = /obj/item/ammo_magazine/shotgun/incendiary,
					/obj/item/weapon/gun/shotgun/double = /obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/weapon/gun/smg/mp5 = /obj/item/ammo_magazine/smg/mp5,
					/obj/item/weapon/gun/smg/mp7 = /obj/item/ammo_magazine/smg/mp7,
					/obj/item/weapon/gun/smg/skorpion = /obj/item/ammo_magazine/smg/skorpion,
					/obj/item/weapon/gun/smg/uzi = /obj/item/ammo_magazine/smg/uzi,
					/obj/item/weapon/gun/smg/p90 = /obj/item/ammo_magazine/smg/p90,
					/obj/item/weapon/gun/rifle/m16 = /obj/item/ammo_magazine/rifle/m16
				)
