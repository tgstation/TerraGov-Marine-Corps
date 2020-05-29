/*SPAWNING LANDMARKS*/
//Check below to see what the crates contain, these landmarks will spawn in a bunch of crates at once, to make it easy to spawn in supplies.
/obj/effect/landmark/supplyspawner
	name = "supply spawner"
	var/list/supply = list()

/obj/effect/landmark/supplyspawner/Initialize()
	. = ..()
	if(/turf/open in range(1))
		var/list/T = list()
		for(var/turf/open/O in range(1))
			T += O
		if(supply.len)
			for(var/s in supply)
				var/amount = supply[s]
				for(var/i = 1, i <= amount, i++)
					new s (pick(T))
	return INITIALIZE_HINT_QDEL


/obj/effect/landmark/supplyspawner/weapons
	name = "weapon supplies"
	supply = list(/obj/structure/largecrate/supply/weapons/standard_carbine = 2,
				/obj/structure/largecrate/supply/weapons/shotgun = 2,
				/obj/structure/largecrate/supply/weapons/standard_smg = 2,
				/obj/structure/largecrate/supply/weapons/pistols = 2,
				/obj/structure/largecrate/supply/weapons/flamers = 2,
				/obj/structure/largecrate/supply/weapons/hpr = 2,
				/obj/structure/closet/crate/mortar_ammo/mortar_kit = 1,
				/obj/structure/largecrate/supply/explosives/mines = 2,
				/obj/structure/largecrate/supply/explosives/grenades = 2
				)

/obj/effect/landmark/supplyspawner/ammo
	name = "ammunition supplies"
	supply = list(/obj/structure/largecrate/supply/ammo/m41a = 4,
				/obj/structure/largecrate/supply/ammo/m41a_box = 4,
				/obj/structure/largecrate/supply/ammo/shotgun = 4,
				/obj/structure/largecrate/supply/ammo/standard_smg = 4,
				/obj/structure/largecrate/supply/ammo/pistol = 4
				)

/obj/effect/landmark/supplyspawner/engineering
	name = "engineering supplies"
	supply = list(/obj/structure/largecrate/supply/supplies/metal = 5,
				/obj/structure/largecrate/supply/supplies/plasteel = 3,
				/obj/structure/largecrate/supply/supplies/sandbags = 5,
				/obj/structure/largecrate/supply/generator = 1,
				/obj/structure/largecrate/supply/floodlights = 2,
				/obj/structure/largecrate/supply/supplies/flares = 3,
				/obj/structure/largecrate/supply/powerloader = 1
				)

/obj/effect/landmark/supplyspawner/turrets
	name = "defensive gun emplacement supplies"
	supply = list(/obj/structure/largecrate/supply/weapons/sentries = 2,
				/obj/structure/largecrate/supply/weapons/m56d = 2,
				/obj/structure/largecrate/supply/ammo/sentry = 1,
				/obj/structure/largecrate/supply/ammo/m56d = 1
				)

/obj/effect/landmark/supplyspawner/food
	name = "food crate supplies"
	supply = list(/obj/structure/largecrate/supply/supplies/mre = 3, /obj/structure/largecrate/supply/supplies/water = 2)

/obj/effect/landmark/supplyspawner/medical
	name = "medical supplies"
	supply = list(/obj/structure/largecrate/supply/medicine/medkits = 2,
				/obj/structure/largecrate/supply/medicine/blood = 2,
				/obj/structure/largecrate/supply/medicine/iv = 2,
				/obj/structure/largecrate/supply/medicine/medivend = 2,
				/obj/structure/largecrate/machine/autodoc = 3,
				/obj/structure/largecrate/machine/bodyscanner = 1,
				/obj/structure/largecrate/machine/sleeper = 2,
				/obj/structure/largecrate/supply/medicine/optable = 1,
				/obj/structure/largecrate/supply/supplies/tables_racks = 1
				)
/*NEW SUPPLY CRATES*/
//Lotsocrates for lotsosupplies for events, meaning less setup time.
//Wooden crates and not metal ones so we don't have a ton of metal crates laying around
//SHOULD contain everything needed for events. Should.

/obj/structure/largecrate/supply
	name = "supply crate"
	var/list/supplies = list()

/obj/structure/largecrate/supply/Initialize()
	. = ..()
	if(supplies.len)
		for(var/s in supplies)
			var/amount = supplies[s]
			for(var/i = 1, i <= amount, i++)
				new s (src)

/obj/structure/largecrate/supply/weapons
	name = "weapons chest"
	icon_state = "chest"

/obj/structure/largecrate/supply/weapons/standard_carbine
	name = "\improper T-18 Carbine weapons chest (x10)"
	desc = "A weapons chest containing ten T-18 Carbines."
	supplies = list(/obj/item/weapon/gun/rifle/standard_carbine = 10)

/obj/structure/largecrate/supply/weapons/shotgun
	name = "\improper T-35 pump action shotgun weapons chest (x10)"
	desc = "A weapons chest containing ten T-35 pump shotguns."
	supplies = list(/obj/item/weapon/gun/shotgun/pump/t35 = 10)

/obj/structure/largecrate/supply/weapons/standard_smg
	name = "\improper T-90 sub machinegun weapons chest (x8)"
	desc = "A weapons chest containing eight T-90 submachine guns."
	supplies = list(/obj/item/weapon/gun/smg/standard_smg = 8)

/obj/structure/largecrate/supply/weapons/pistols
	name = "sidearm weapons chest (x20)"
	desc = "A weapons chest containing eight TP-44 revolvers, and twelve TP-14 service pistols."
	supplies = list(/obj/item/weapon/gun/revolver/standard_revolver = 6, /obj/item/weapon/gun/pistol/standard_pistol = 12)

/obj/structure/largecrate/supply/weapons/flamers
	name = "\improper M240A1 incinerator weapons chest (x4)"
	desc = "A weapons chest containing four M240A1 incinerator units."
	supplies = list(/obj/item/weapon/gun/flamer = 4)

/obj/structure/largecrate/supply/weapons/hpr
	name = "\improper T-42 LMG weapons chest (x2)"
	desc = "A weapons chest containing two T-42 LMG."
	supplies = list(/obj/item/weapon/gun/rifle/standard_lmg = 2)

/obj/structure/largecrate/supply/weapons/sentries
	name = "\improper UA 571-C sentry chest (x2)"
	desc = "A supply crate containing two boxed UA 571-C sentries."
	supplies = list(/obj/item/storage/box/sentry = 2)

/obj/structure/largecrate/supply/weapons/m56d
	name = "\improper M56D mounted smartgun chest (x2)"
	desc = "A supply crate containing two boxed M56D mounted smartguns."
	supplies = list(/obj/item/storage/box/m56d_hmg = 2)



/obj/structure/largecrate/supply/ammo
	name = "ammunition case"
	icon_state = "case"

/obj/structure/largecrate/supply/ammo/m41a
	name = "\improper M41A1 magazine case (x20)"
	desc = "An ammunition case containing 20 M41A1 magazines."
	supplies = list(/obj/item/ammo_magazine/rifle = 20)

/obj/structure/largecrate/supply/ammo/m41a_box
	name = "\improper M41A1 ammunition box case (x4)"
	desc = "An ammunition case containing four M41A1 600 round boxes of ammunition."
	supplies = list(/obj/item/big_ammo_box = 4)

/obj/structure/largecrate/supply/ammo/shotgun
	name = "12 Gauge ammunition crate (x20)"
	desc = "An ammunition case containing eight boxes of slugs, eight boxes of buckshot, and eight boxes of flechette rounds."
	supplies = list(/obj/item/ammo_magazine/shotgun = 8, /obj/item/ammo_magazine/shotgun/buckshot = 8, /obj/item/ammo_magazine/shotgun/flechette = 8)

/obj/structure/largecrate/supply/ammo/standard_smg
	name = "\improper T-90 magazine case (x16)"
	desc = "An ammunition case containing sixteen T-90 magazines."
	supplies = list(/obj/item/ammo_magazine/smg/standard_smg = 16)

/obj/structure/largecrate/supply/ammo/pistol
	name = "sidearm ammunition case (x40)"
	desc = "An ammunition case containing sixteen TP-44 speedloaders, and twenty-four TP-14 magazines."
	supplies = list(/obj/item/ammo_magazine/revolver/standard_revolver = 16, /obj/item/ammo_magazine/pistol/standard_pistol = 24)

/obj/structure/largecrate/supply/ammo/sentry
	name = "\improper UA 571-C ammunition drum case (x6)"
	desc = "An ammunition case containing six UA 571-C sentry ammunition drums."
	supplies = list(/obj/item/ammo_magazine/sentry = 6)

/obj/structure/largecrate/supply/ammo/m56d
	name = "\improper M56D ammunition drum case (x6)"
	desc = "An ammunition case containing six M56D ammunition drums."
	supplies = list(/obj/item/ammo_magazine/m56d = 6)



/obj/structure/largecrate/supply/explosives
	name = "explosives supply crate"
	desc = "A case containing explosives."
	icon_state = "case_double"

/obj/structure/largecrate/supply/explosives/mines
	name = "\improper M20 claymore case (x20)"
	desc = "A case containing five four M20 claymore boxes."
	supplies = list(/obj/item/storage/box/explosive_mines = 5)

/obj/structure/largecrate/supply/explosives/grenades
	name = "\improper M40 HDEP grenade case (x50)"
	desc = "A case containing two twenty-five M40 HDEP grenade boxes."
	supplies = list(/obj/item/storage/box/nade_box = 2)

/obj/structure/largecrate/supply/explosives/mortar_he
	name = "80mm HE mortar shell case (x25)"
	desc = "A case containing twenty five 80mm HE mortar shells."
	supplies = list(/obj/item/mortal_shell/he = 25)

/obj/structure/largecrate/supply/explosives/mortar_incend
	name = "80mm incendiary mortar shell case (x25)"
	desc = "A case containing twenty five 80mm incendiary mortar shells."
	supplies = list(/obj/item/mortal_shell/incendiary = 25)

/obj/structure/largecrate/supply/explosives/mortar_flare
	name = "80mm flare mortar shell case (x25)"
	desc = "A case containing twenty five 80mm flare mortar shells."
	supplies = list(/obj/item/mortal_shell/flare = 25)


/obj/structure/largecrate/supply/supplies
	name = "supplies crate"
	icon_state = "secure_crate"

/obj/structure/largecrate/supply/supplies/flares
	name = "Flare supply crate (x100)"
	desc = "A supply crate containing twenty five-flare boxes."
	supplies = list(/obj/item/storage/box/m94 = 10)

/obj/structure/largecrate/supply/supplies/metal
	name = "metal sheets supply crate (x200)"
	desc = "A supply crate containing four fifty stacks of metal sheets."
	supplies = list(/obj/item/stack/sheet/metal/large_stack = 4)

/obj/structure/largecrate/supply/supplies/plasteel
	name = "plasteel supply crate (x60)"
	desc = "A supply crate containing two stacks of 30 plasteel sheets."
	supplies = list(/obj/item/stack/sheet/plasteel/medium_stack = 2)

/obj/structure/largecrate/supply/supplies/sandbags
	name = "sandbag supply crate (x100)"
	desc = "A supply crate containing four piles of twenty-five sandbags."
	supplies = list(/obj/item/stack/sandbags/large_stack = 4)

/obj/structure/largecrate/supply/supplies/tables_racks
	name = "storage solutions crate (x10, x10)"
	desc = "A crate containing ten table parts, and ten rack parts, for easy storage setup."
	supplies = list(/obj/item/frame/table = 10, /obj/item/frame/rack = 10)

/obj/structure/largecrate/supply/supplies/mre
	name = "\improper TGMC MRE crate (x50)"
	desc = "A supply crate containing fifty TGMC MRE packets."
	supplies = list(/obj/item/storage/box/MRE = 50)

/obj/structure/largecrate/supply/supplies/water
	name = "\improper NT Bottled Water crate (x50)"
	desc = "A crate containing fifty Nanotrasen Bottled Spring Water bottles."
	supplies = list(/obj/item/reagent_containers/food/drinks/cans/waterbottle = 50)

/obj/structure/largecrate/supply/powerloader
	name = "\improper Caterpillar P-5000 Work Loader crate"
	desc = "A crate containing one folded, but fully assembled, Caterpillar P-5000 Work Loader."
	supplies = list(/obj/vehicle/powerloader = 1)

/obj/structure/largecrate/supply/floodlights
	name = "floodlight crate (x4)"
	desc = "A crate containing four floodlights."
	supplies = list(/obj/machinery/floodlight = 4)

/obj/structure/largecrate/supply/generator
	name = "\improper P.A.C.M.A.N. crate"
	desc = "A crate containing a P.A.C.M.A.N. generator, some fuel, and some cable coil to get your power up and going."
	supplies = list(/obj/machinery/power/port_gen/pacman = 1, /obj/item/stack/sheet/mineral/phoron/medium_stack = 1, /obj/item/stack/cable_coil = 3)

/obj/structure/largecrate/supply/medicine
	name = "medical crate"
	desc = "A crate containing medical supplies."
	icon_state = "chest_white"

/obj/structure/largecrate/supply/medicine/medkits
	name = "first aid supply crate (x20)"
	desc = "A medical supply crate containing six advanced, three standard, three burn, two toxin, two oxygen, and two radiation first aid kits."
	supplies = list(/obj/item/storage/firstaid/regular = 3,
					/obj/item/storage/firstaid/fire = 3,
					/obj/item/storage/firstaid/adv = 6,
					/obj/item/storage/firstaid/toxin = 2,
					/obj/item/storage/firstaid/o2 = 2,
					/obj/item/storage/firstaid/rad = 2
					)

/obj/structure/largecrate/supply/medicine/blood
	name = "blood supply crate (x12)"
	desc = "A medical supply crate containing twelve bags of type O- blood."
	supplies = list(/obj/item/reagent_containers/blood/OMinus = 12)

/obj/structure/largecrate/supply/medicine/iv
	name = "\improper IV stand crate (x3)"
	desc = "A medical supply crate containing three IV drips."
	supplies = list(/obj/machinery/iv_drip = 3)

/obj/structure/largecrate/supply/medicine/optable
	name = "medical operation crate (x1)"
	desc = "A crate containing an operating table, two tanks of anasthetic, a surgery kit, some anasthetic injectors, and some space cleaner."
	supplies = list(/obj/machinery/optable = 1, /obj/item/storage/surgical_tray = 1, /obj/item/tank/anesthetic = 2, /obj/item/reagent_containers/spray/cleaner = 1)

/obj/structure/largecrate/supply/medicine/medivend
	name = "\improper NanotrasenMed Plus crate (x1)"
	desc = "A crate containing one Nanotrasen Plus medical vendor."
	supplies = list(/obj/machinery/vending/medical = 1)


/obj/structure/largecrate/machine
	name = "machine crate"
	desc = "A crate containing a pre-assembled machine."
	icon_state = "secure_crate_strapped"
	var/dir_needed = EAST //If set to anything but 0, will check that space before spawning in.
	var/unmovable = 1 //If set to 1, then on examine, the user will see a warning that states the contents cannot be moved after opened.

/obj/structure/largecrate/machine/examine(mob/user)
	..()
	if(unmovable)
		to_chat(user, "<b>!!WARNING!! CONTENTS OF CRATE UNABLE TO BE MOVED ONCE UNPACKAGED!</b>")

/obj/structure/largecrate/machine/attackby(obj/item/I, mob/user, params)
	if(iscrowbar(I) && dir_needed)
		var/turf/next_turf = get_step(src, dir_needed)
		if(next_turf.density)
			to_chat(user, "<span class='warning'>You can't open the crate here, there's not enough room!</span>")
			return
		for(var/atom/movable/AM in next_turf.contents)
			if(AM.density)
				to_chat(user, "<span class='warning'>You can't open the crate here, [AM] blocks the way.</span>")
				return
		return TRUE
	return ..()


/obj/structure/largecrate/machine/autodoc
	name = "autodoctor machine crate (x1)"
	desc = "A crate containing one autodoc."

/obj/structure/largecrate/machine/autodoc/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!.)
		return

	if(iscrowbar(I))
		var/turf/T = get_turf(loc)
		if(!isopenturf(T))
			return

		var/obj/machinery/autodoc/event/E = new (T)
		var/obj/machinery/autodoc_console/C = new (T)
		C.loc = get_step(T, EAST)
		E.connected = C
		C.connected = E

/obj/structure/largecrate/machine/bodyscanner
	name = "bodyscanner machine crate (x1)"
	desc = "A crate containing one medical bodyscanner."

/obj/structure/largecrate/supply/machine/bodyscanner/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!.)
		return

	if(iscrowbar(I))
		var/turf/T = get_turf(loc)
		if(!isopenturf(T))
			return

		var/obj/machinery/bodyscanner/E = new (T)
		var/obj/machinery/body_scanconsole/C = new (T)
		C.loc = get_step(T, EAST)
		C.connected = E

/obj/structure/largecrate/machine/sleeper
	name = "sleeper machine crate (x1)"
	desc = "A crate containing one medical sleeper."

/obj/structure/largecrate/machine/sleeper/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!.)
		return

	if(iscrowbar(I))
		var/turf/T = get_turf(loc)
		if(!isopenturf(T))
			return

		var/obj/machinery/sleeper/E = new (T)
		var/obj/machinery/sleep_console/C = new (T)
		C.loc = get_step(T, EAST)
		E.connected = C
		C.connected = E
