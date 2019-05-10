/obj/structure/largecrate
	name = "large crate"
	desc = "A hefty wooden crate."
	icon = 'icons/obj/structures/crates.dmi'
	icon_state = "densecrate"
	density = 1
	anchored = 0

/obj/structure/largecrate/attack_alien(mob/living/carbon/Xenomorph/M)
	M.animation_attack_on(src)
	playsound(src, 'sound/effects/woodhit.ogg', 25, 1)
	new /obj/item/stack/sheet/wood(src)
	var/turf/T = get_turf(src)
	for(var/obj/O in contents)
		O.loc = T
	M.visible_message("<span class='danger'>\The [M] smashes \the [src] apart!</span>", \
	"<span class='danger'>You smash \the [src] apart!</span>", \
	"<span class='danger'>You hear splitting wood!</span>", 5)
	qdel(src)

/obj/structure/largecrate/attack_hand(mob/user as mob)
	to_chat(user, "<span class='notice'>You need a crowbar to pry this open!</span>")
	return FALSE

/obj/structure/largecrate/attackby(obj/item/W as obj, mob/user as mob)
	if(iscrowbar(W))
		new /obj/item/stack/sheet/wood(src)
		var/turf/T = get_turf(src)
		for(var/obj/O in contents)
			O.loc = T
		user.visible_message("<span class='notice'>[user] pries \the [src] open.</span>", \
							 "<span class='notice'>You pry open \the [src].</span>", \
							 "<span class='notice'>You hear splitting wood.</span>")
		qdel(src)
	else
		return attack_hand(user)

/obj/structure/largecrate/mule
	icon_state = "mulecrate"

/obj/structure/largecrate/lisa
	icon_state = "lisacrate"

/obj/structure/largecrate/lisa/attackby(obj/item/W as obj, mob/user as mob)	//ugly but oh well
	if(iscrowbar(W))
		new /mob/living/simple_animal/corgi/Lisa(loc)
	..()

/obj/structure/largecrate/cow
	name = "cow crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/cow/attackby(obj/item/W as obj, mob/user as mob)
	if(iscrowbar(W))
		new /mob/living/simple_animal/cow(loc)
	..()

/obj/structure/largecrate/goat
	name = "goat crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/goat/attackby(obj/item/W as obj, mob/user as mob)
	if(iscrowbar(W))
		new /mob/living/simple_animal/hostile/retaliate/goat(loc)
	..()

/obj/structure/largecrate/chick
	name = "chicken crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/chick/attackby(obj/item/W as obj, mob/user as mob)
	if(iscrowbar(W))
		var/num = rand(4, 6)
		for(var/i = 0, i < num, i++)
			new /mob/living/simple_animal/chick(loc)
	..()

/obj/structure/largecrate/hoverpod
	name = "Hoverpod assembly crate"
	desc = "It comes in a box for the fabricator's sake. Where does the wood come from? ... And why is it lighter?"
	icon_state = "mulecrate"

/obj/structure/largecrate/hoverpod/attackby(obj/item/W as obj, mob/user as mob)
	if(iscrowbar(W))
		new /obj/mecha/hoverpod(loc)
	..()



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
						/obj/item/reagent_container/food/snacks/donkpocket,
						/obj/item/explosive/grenade/smokebomb,
						/obj/item/circuitboard/airlock,
						/obj/item/assembly/igniter,
						/obj/item/tool/weldingtool,
						/obj/item/tool/wirecutters,
						/obj/item/analyzer,
						/obj/item/clothing/under/marine,
						/obj/item/clothing/shoes/marine
						)

/obj/structure/largecrate/random/New()
	..()
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

/obj/structure/largecrate/random/case/double/Del()
	new /obj/structure/largecrate/random/case(loc)
	..()

/obj/structure/largecrate/random/case/small
	name = "small cases"
	desc = "Two small black storage cases."
	icon_state = "case_small"

/obj/structure/largecrate/random/barrel/attackby(obj/item/tool/weldingtool/W, mob/user as mob)
	if(istype(W) && W.isOn())
		if(do_after(user, 50, TRUE, src, BUSY_ICON_GENERIC, extra_checks = CALLBACK(W, /obj/item/tool/weldingtool/proc/isOn)))
			new /obj/item/stack/sheet/metal/small_stack(src)
			W.remove_fuel(1,user)
			var/turf/T = get_turf(src)
			for(var/obj/O in contents)
				O.loc = T
			user.visible_message("<span class='notice'>[user] welds \the [src] open.</span>", \
								 "<span class='notice'>You weld open \the [src].</span>", \
								 "<span class='notice'>You hear loud hissing and the sound of metal falling over.</span>")
			playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)
			qdel(src)
		else
			return FALSE
	else
		return attack_hand(user)

/obj/structure/largecrate/random/barrel/attack_hand(mob/user)
	to_chat(user, "<span class='notice'>You need a blowtorch to weld this open!</span>")
	return FALSE

/obj/structure/largecrate/random/barrel
	name = "blue barrel"
	desc = "A blue storage barrel"
	icon_state = "barrel_blue"

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

/obj/structure/largecrate/random/secure/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if (!strapped)
		return ..()

	if (!W.sharp)
		return attack_hand(user)

	to_chat(user, "<span class='notice'>You begin to cut the straps off \the [src]...</span>")

	if (do_after(user, 15, TRUE, src, BUSY_ICON_GENERIC))
		playsound(loc, 'sound/items/Wirecutter.ogg', 25, 1)
		to_chat(user, "<span class='notice'>You cut the straps away.</span>")
		icon_state = "secure_crate"
		strapped = 0

/obj/structure/largecrate/random/barrel/attack_hand(mob/user)
	to_chat(user, "<span class='notice'>You need something sharp to cut off the straps.</span>")
	return FALSE

/obj/structure/largecrate/guns
	name = "\improper TGMC firearms crate (x3)"
	var/num_guns = 3
	var/num_mags = 3
	var/list/stuff = list(
					/obj/item/weapon/gun/pistol/m4a3 = /obj/item/ammo_magazine/pistol/hp,
					/obj/item/weapon/gun/pistol/m4a3 = /obj/item/ammo_magazine/pistol/ap,
					/obj/item/weapon/gun/revolver/m44 = /obj/item/ammo_magazine/revolver/marksman,
					/obj/item/weapon/gun/revolver/m44 = /obj/item/ammo_magazine/revolver/heavy,
					/obj/item/weapon/gun/rifle/m41a = /obj/item/ammo_magazine/rifle/extended,
					/obj/item/weapon/gun/rifle/m41a = /obj/item/ammo_magazine/rifle/ap,
					/obj/item/weapon/gun/shotgun/pump = /obj/item/ammo_magazine/shotgun,
					/obj/item/weapon/gun/shotgun/pump = /obj/item/ammo_magazine/shotgun/incendiary,
					/obj/item/weapon/gun/shotgun/combat = /obj/item/ammo_magazine/shotgun/beanbag,
					/obj/item/weapon/gun/smg/m39 = /obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/weapon/gun/smg/m39 = /obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/weapon/gun/smg/m39/elite = /obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/weapon/gun/flamer = /obj/item/ammo_magazine/flamer_tank,
					/obj/item/weapon/gun/pistol/m4a3/custom = /obj/item/ammo_magazine/pistol/incendiary,
					/obj/item/weapon/gun/rifle/m41aMK1 = /obj/item/ammo_magazine/rifle/m41aMK1,
					/obj/item/weapon/gun/rifle/lmg = /obj/item/ammo_magazine/rifle/lmg,
					/obj/item/weapon/gun/launcher/m81 = /obj/item/explosive/grenade/phosphorus
					)

/obj/structure/largecrate/guns/New()
	..()
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
					/obj/item/weapon/gun/rifle/mar40 = /obj/item/ammo_magazine/rifle/mar40,
					/obj/item/weapon/gun/rifle/mar40/carbine = /obj/item/ammo_magazine/rifle/mar40/extended,
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


/obj/structure/largecrate/hunter_games_construction
	name = "construction crate"

/obj/structure/largecrate/hunter_games_construction/New()
	..()
	new /obj/item/stack/sheet/metal(src, 50)
	new /obj/item/stack/sheet/glass(src, 50)
	new /obj/item/stack/sheet/plasteel(src, 50)
	new /obj/item/stack/sheet/wood(src, 50)
	new /obj/item/stack/sandbags_empty(src, 50)
	new /obj/item/storage/toolbox/mechanical(src)
	new /obj/item/storage/toolbox/mechanical(src)
	new /obj/item/storage/toolbox/electrical(src)
	new /obj/item/storage/belt/utility/full(src)
	new /obj/item/storage/belt/utility/full(src)
	new /obj/item/clothing/gloves/yellow(src)
	new /obj/item/clothing/gloves/yellow(src)
	new /obj/item/clothing/head/welding(src)
	new /obj/item/clothing/head/welding(src)
	new /obj/item/circuitboard/airlock(src)
	new /obj/item/cell/high(src)
	new /obj/item/cell/high(src)
	new /obj/item/storage/pouch/tools(src)


/obj/structure/largecrate/hunter_games_medical
	name = "medical crate"

/obj/structure/largecrate/hunter_games_medical/New()
	..()
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/healthanalyzer(src)
	new /obj/item/healthanalyzer(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/storage/belt/combatLifesaver(src)
	new /obj/item/storage/firstaid/regular(src)
	new /obj/item/storage/firstaid/adv(src)
	new /obj/item/storage/firstaid/o2(src)
	new /obj/item/storage/firstaid/toxin(src)
	new /obj/item/storage/firstaid/fire(src)
	new /obj/item/storage/firstaid/rad(src)
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/storage/pill_bottle/inaprovaline(src)
	new /obj/item/storage/pouch/medical(src)
	new /obj/item/storage/pouch/firstaid/full(src)
	new /obj/item/storage/box/quickclot(src)


/obj/structure/largecrate/hunter_games_surgery
	name = "surgery crate"

/obj/structure/largecrate/hunter_games_surgery/New()
	..()
	new /obj/item/tool/surgery/cautery(src)
	new /obj/item/tool/surgery/surgicaldrill(src)
	new /obj/item/clothing/mask/breath/medical(src)
	new /obj/item/tank/anesthetic(src)
	new /obj/item/tool/surgery/FixOVein(src)
	new /obj/item/tool/surgery/hemostat(src)
	new /obj/item/tool/surgery/scalpel(src)
	new /obj/item/tool/surgery/bonegel(src)
	new /obj/item/tool/surgery/retractor(src)
	new /obj/item/tool/surgery/bonesetter(src)
	new /obj/item/tool/surgery/circular_saw(src)
	new /obj/item/tool/surgery/scalpel/manager(src)


/obj/structure/largecrate/hunter_games_supplies
	name = "supplies crate"

/obj/structure/largecrate/hunter_games_supplies/New()
	..()
	new /obj/item/storage/box/m94(src)
	new /obj/item/storage/box/m94(src)
	new /obj/item/storage/pouch/general/medium(src)
	new /obj/item/storage/pouch/survival(src)
	new /obj/item/flashlight (src)
	new /obj/item/flashlight (src)
	new /obj/item/tool/crowbar/red (src)
	new /obj/item/tool/crowbar/red (src)
	new /obj/item/storage/pouch/pistol(src)
	new /obj/item/storage/pouch/magazine(src)
	new /obj/item/storage/pouch/flare(src)
	new /obj/item/storage/backpack(src)
	new /obj/item/storage/backpack/satchel(src)
	new /obj/item/storage/backpack(src)
	new /obj/item/radio(src)
	new /obj/item/radio(src)
	new /obj/item/weapon/combat_knife(src)
	new /obj/item/weapon/combat_knife(src)
	new /obj/item/weapon/throwing_knife(src)
	new /obj/item/weapon/throwing_knife(src)
	new /obj/item/storage/box/uscm_mre(src)
	new /obj/item/storage/box/donkpockets(src)
	new /obj/item/storage/box/MRE(src)
	new /obj/item/storage/box/MRE(src)
	new /obj/item/storage/box/pizza(src)


/obj/structure/largecrate/hunter_games_guns
	name = "weapons crate"

/obj/structure/largecrate/hunter_games_guns/mediocre/New()
	..()
	new /obj/item/weapon/gun/pistol/holdout(src)
	new /obj/item/ammo_magazine/pistol/holdout(src)
	new /obj/item/ammo_magazine/pistol/holdout(src)
	new /obj/item/weapon/gun/pistol/m4a3(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/weapon/gun/shotgun/double(src)
	new /obj/item/ammo_magazine/shotgun(src)
	new /obj/item/weapon/gun/revolver/small(src)
	new /obj/item/ammo_magazine/revolver/small(src)
	new /obj/item/ammo_magazine/revolver/small(src)


/obj/structure/largecrate/hunter_games_guns/decent/New()
	..()
	new /obj/item/weapon/gun/pistol/m4a3(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/ammo_magazine/pistol(src)
	if(prob(50))
		new /obj/item/weapon/gun/smg/m39(src)
		new /obj/item/ammo_magazine/smg/m39(src)
		new /obj/item/ammo_magazine/smg/m39(src)
	else
		new /obj/item/weapon/gun/smg/uzi(src)
		new /obj/item/ammo_magazine/smg/uzi(src)
		new /obj/item/ammo_magazine/smg/uzi(src)
	new /obj/item/weapon/gun/shotgun/pump/cmb(src)
	new /obj/item/ammo_magazine/shotgun(src)
	new /obj/item/ammo_magazine/shotgun/buckshot(src)
	new /obj/item/weapon/gun/revolver/m44(src)
	new /obj/item/ammo_magazine/revolver(src)
	new /obj/item/ammo_magazine/revolver(src)
	new /obj/item/weapon/gun/rifle/m16(src)
	new /obj/item/ammo_magazine/rifle/m16(src)
	new /obj/item/ammo_magazine/rifle/m16(src)


/obj/structure/largecrate/hunter_games_guns/good/New()
	..()
	new /obj/item/weapon/gun/pistol/highpower(src)
	new /obj/item/ammo_magazine/pistol/highpower(src)
	new /obj/item/ammo_magazine/pistol/highpower(src)
	if(prob(50))
		new /obj/item/weapon/gun/rifle/m41a(src)
		new /obj/item/ammo_magazine/rifle(src)
		new /obj/item/ammo_magazine/rifle(src)
	else
		new /obj/item/weapon/gun/rifle/mar40(src)
		new /obj/item/ammo_magazine/rifle/mar40(src)
		new /obj/item/ammo_magazine/rifle/mar40(src)
	new /obj/item/weapon/gun/smg/skorpion(src)
	new /obj/item/ammo_magazine/smg/skorpion(src)
	new /obj/item/ammo_magazine/smg/skorpion(src)
	new /obj/item/weapon/gun/shotgun/combat(src)
	new /obj/item/ammo_magazine/shotgun(src)
	new /obj/item/ammo_magazine/shotgun/buckshot(src)


/obj/structure/largecrate/hunter_games_ammo
	name = "ammo crate"

/obj/structure/largecrate/hunter_games_ammo/mediocre/New()
	..()
	new /obj/item/ammo_magazine/pistol/holdout(src)
	new /obj/item/ammo_magazine/pistol/holdout(src)
	new /obj/item/ammo_magazine/pistol/holdout(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/ammo_magazine/shotgun(src)
	new /obj/item/ammo_magazine/revolver/small(src)
	new /obj/item/ammo_magazine/revolver/small(src)

/obj/structure/largecrate/hunter_games_ammo/decent/New()
	..()
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/ammo_magazine/smg/m39(src)
	new /obj/item/ammo_magazine/smg/m39(src)
	new /obj/item/ammo_magazine/smg/uzi(src)
	new /obj/item/ammo_magazine/smg/uzi(src)
	new /obj/item/ammo_magazine/shotgun(src)
	new /obj/item/ammo_magazine/shotgun/buckshot(src)
	new /obj/item/ammo_magazine/revolver(src)
	new /obj/item/ammo_magazine/revolver(src)
	new /obj/item/ammo_magazine/rifle/m16(src)
	new /obj/item/ammo_magazine/rifle/m16(src)

/obj/structure/largecrate/hunter_games_ammo/good/New()
	..()
	new /obj/item/ammo_magazine/pistol/highpower(src)
	new /obj/item/ammo_magazine/pistol/highpower(src)
	new /obj/item/ammo_magazine/rifle(src)
	new /obj/item/ammo_magazine/rifle(src)
	new /obj/item/ammo_magazine/rifle/mar40(src)
	new /obj/item/ammo_magazine/rifle/mar40(src)
	new /obj/item/ammo_magazine/smg/skorpion(src)
	new /obj/item/ammo_magazine/smg/skorpion(src)
	new /obj/item/ammo_magazine/shotgun(src)
	new /obj/item/ammo_magazine/shotgun/buckshot(src)





/obj/structure/largecrate/hunter_games_armors
	name = "armors crate"

/obj/structure/largecrate/hunter_games_armors/New()
	..()
	new /obj/item/clothing/gloves/marine(src)
	new /obj/item/clothing/gloves/marine(src)
	new /obj/item/clothing/gloves/marine(src)
	new /obj/item/clothing/head/helmet(src)
	new /obj/item/clothing/head/helmet(src)
	new /obj/item/clothing/head/helmet/riot(src)
	new /obj/item/clothing/shoes/combat(src)
	new /obj/item/clothing/shoes/combat(src)
	new /obj/item/clothing/shoes/combat(src)
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/clothing/suit/armor/bulletproof(src)
	new /obj/item/weapon/shield/riot(src)
