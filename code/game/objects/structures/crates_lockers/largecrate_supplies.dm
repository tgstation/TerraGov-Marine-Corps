/*SPAWNING LANDMARKS*/
//Check below to see what the crates contain, these landmarks will spawn in a bunch of crates at once, to make it easy to spawn in supplies.
/obj/effect/landmark/supplyspawner
	name = "supply spawner"
	var/list/supply = list()

/obj/effect/landmark/supplyspawner/Initialize(mapload)
	. = ..()
	if(/turf/open in range(1))
		var/list/T = list()
		for(var/turf/open/O in range(1))
			T += O
		if(length(supply))
			for(var/s in supply)
				var/amount = supply[s]
				for(var/i = 1, i <= amount, i++)
					new s (pick(T))
	return INITIALIZE_HINT_QDEL


/obj/effect/landmark/supplyspawner/weapons
	name = "weapon supplies"
	supply = list(
		/obj/structure/largecrate/supply/weapons/standard_carbine = 2,
		/obj/structure/largecrate/supply/weapons/shotgun = 2,
		/obj/structure/largecrate/supply/weapons/standard_smg = 2,
		/obj/structure/largecrate/supply/weapons/pistols = 2,
		/obj/structure/largecrate/supply/weapons/flamers = 2,
		/obj/structure/largecrate/supply/weapons/hpr = 2,
		/obj/structure/closet/crate/mortar_ammo/mortar_kit = 1,
		/obj/structure/largecrate/supply/explosives/mines = 2,
		/obj/structure/largecrate/supply/explosives/grenades = 2,
	)

/obj/effect/landmark/supplyspawner/ammo
	name = "ammunition supplies"
	supply = list(
		/obj/structure/largecrate/supply/ammo/m41a = 4,
		/obj/structure/largecrate/supply/ammo/m41a_box = 4,
		/obj/structure/largecrate/supply/ammo/shotgun = 4,
		/obj/structure/largecrate/supply/ammo/standard_smg = 4,
		/obj/structure/largecrate/supply/ammo/pistol = 4,
	)

/obj/effect/landmark/supplyspawner/engineering
	name = "engineering supplies"
	supply = list(
		/obj/structure/largecrate/supply/supplies/metal = 5,
		/obj/structure/largecrate/supply/supplies/plasteel = 3,
		/obj/structure/largecrate/supply/supplies/sandbags = 5,
		/obj/structure/largecrate/supply/generator = 1,
		/obj/structure/largecrate/supply/floodlights = 2,
		/obj/structure/largecrate/supply/supplies/flares = 3,
		/obj/structure/largecrate/supply/powerloader = 1,
	)

/obj/effect/landmark/supplyspawner/turrets
	name = "defensive gun emplacement supplies"
	supply = list(
		/obj/structure/largecrate/supply/weapons/sentries = 2,
		/obj/structure/largecrate/supply/weapons/standard_hmg = 2,
		/obj/structure/largecrate/supply/ammo/sentry = 1,
		/obj/structure/largecrate/supply/ammo/standard_hmg = 1,
	)

/obj/effect/landmark/supplyspawner/food
	name = "food crate supplies"
	supply = list(/obj/structure/largecrate/supply/supplies/mre = 3, /obj/structure/largecrate/supply/supplies/water = 2)

/obj/effect/landmark/supplyspawner/medical
	name = "medical supplies"
	supply = list(
		/obj/structure/largecrate/supply/medicine/medkits = 2,
		/obj/structure/largecrate/supply/medicine/blood = 2,
		/obj/structure/largecrate/supply/medicine/iv = 2,
		/obj/structure/largecrate/supply/medicine/medivend = 2,
		/obj/structure/largecrate/machine/autodoc = 3,
		/obj/structure/largecrate/machine/bodyscanner = 1,
		/obj/structure/largecrate/machine/sleeper = 2,
		/obj/structure/largecrate/supply/medicine/optable = 1,
		/obj/structure/largecrate/supply/supplies/tables_racks = 1,
	)
/*NEW SUPPLY CRATES*/
//Lotsocrates for lotsosupplies for events, meaning less setup time.
//Wooden crates and not metal ones so we don't have a ton of metal crates laying around
//SHOULD contain everything needed for events. Should.

/obj/structure/largecrate/supply
	name = "supply crate"
	var/list/supplies = list()

/obj/structure/largecrate/supply/Initialize(mapload)
	. = ..()
	if(length(supplies))
		for(var/s in supplies)
			var/amount = supplies[s]
			for(var/i = 1, i <= amount, i++)
				new s (src)

/obj/structure/largecrate/supply/weapons
	name = "weapons chest"
	icon_state = "chest"

/obj/structure/largecrate/supply/weapons/standard_carbine
	name = "\improper AR-18 Carbine weapons chest (x10)"
	desc = "A weapons chest containing ten AR-18 Carbines."
	supplies = list(/obj/item/weapon/gun/rifle/standard_carbine = 10)

/obj/structure/largecrate/supply/weapons/shotgun
	name = "\improper SH-35 pump action shotgun weapons chest (x10)"
	desc = "A weapons chest containing ten SH-35 pump shotguns."
	supplies = list(/obj/item/weapon/gun/shotgun/pump/t35 = 10)

/obj/structure/largecrate/supply/weapons/standard_smg
	name = "\improper SMG-90 sub machinegun weapons chest (x8)"
	desc = "A weapons chest containing eight SMG-90 submachine guns."
	supplies = list(/obj/item/weapon/gun/smg/standard_smg = 8)

/obj/structure/largecrate/supply/weapons/pistols
	name = "sidearm weapons chest (x20)"
	desc = "A weapons chest containing eight R-44 revolvers, and twelve P-14 service pistols."
	supplies = list(/obj/item/weapon/gun/revolver/standard_revolver = 6, /obj/item/weapon/gun/pistol/standard_pistol = 12)

/obj/structure/largecrate/supply/weapons/flamers
	name = "\improper FL-240 incinerator weapons chest (x4)"
	desc = "A weapons chest containing four FL-240 incinerator units."
	supplies = list(/obj/item/weapon/gun/flamer/big_flamer = 4)

/obj/structure/largecrate/supply/weapons/hpr
	name = "\improper MG-42 LMG weapons chest (x2)"
	desc = "A weapons chest containing two MG-42 LMG."
	supplies = list(/obj/item/weapon/gun/rifle/standard_lmg = 2)

/obj/structure/largecrate/supply/weapons/sentries
	name = "\improper ST-571 sentry chest (x2)"
	desc = "A supply crate containing two boxed ST-571 sentries."
	supplies = list(/obj/item/storage/box/crate/sentry = 2)

/obj/structure/largecrate/supply/weapons/standard_hmg
	name = "\improper HSG-102 mounted heavy smartgun chest (x2)"
	desc = "A supply crate containing two boxed HSG-102 mounted heavy smartguns."
	supplies = list(/obj/item/storage/box/tl102 = 2)

/obj/structure/largecrate/supply/weapons/standard_atgun
	name = "\improper AT-36 anti tank gun and ammo chest (x1, x10)"
	desc = "A supply crate containing a AT-36 and a full set of ammo to load into the sponson."
	supplies = list(
		/obj/item/weapon/gun/standard_atgun = 1,
		/obj/item/ammo_magazine/standard_atgun = 4,
		/obj/item/ammo_magazine/standard_atgun/apcr = 3,
		/obj/item/ammo_magazine/standard_atgun/he = 3,
	)

/obj/structure/largecrate/supply/weapons/standard_flakgun
	name = "\improper ATR-22 flak gun and ammo chest (x1, x6)"
	desc = "A supply crate containing a ATR-22 and a full set of ammo to load into the sponson."
	supplies = list(
		/obj/item/weapon/gun/standard_auto_cannon = 1,
		/obj/item/ammo_magazine/auto_cannon = 3,
		/obj/item/ammo_magazine/auto_cannon/flak = 3,
	)

/obj/structure/largecrate/supply/ammo
	name = "ammunition case"
	icon_state = "case"

/obj/structure/largecrate/supply/ammo/m41a
	name = "\improper PR-412 magazine case (x20)"
	desc = "An ammunition case containing 20 PR-412 magazines."
	supplies = list(/obj/item/ammo_magazine/rifle = 20)

/obj/structure/largecrate/supply/ammo/m41a_box
	name = "\improper PR-412 ammunition box case (x4)"
	desc = "An ammunition case containing four PR-412 600 round boxes of ammunition."
	supplies = list(/obj/item/big_ammo_box = 4)

/obj/structure/largecrate/supply/ammo/shotgun
	name = "12 Gauge ammunition crate (x20)"
	desc = "An ammunition case containing eight boxes of slugs, eight boxes of buckshot, and eight boxes of flechette rounds."
	supplies = list(/obj/item/ammo_magazine/shotgun = 8, /obj/item/ammo_magazine/shotgun/buckshot = 8, /obj/item/ammo_magazine/shotgun/flechette = 8)

/obj/structure/largecrate/supply/ammo/standard_smg
	name = "\improper SMG-90 magazine case (x16)"
	desc = "An ammunition case containing sixteen SMG-90 magazines."
	supplies = list(/obj/item/ammo_magazine/smg/standard_smg = 16)

/obj/structure/largecrate/supply/ammo/pistol
	name = "sidearm ammunition case (x40)"
	desc = "An ammunition case containing sixteen R-44 speedloaders, and twenty-four P-14 magazines."
	supplies = list(/obj/item/ammo_magazine/revolver/standard_revolver = 16, /obj/item/ammo_magazine/pistol/standard_pistol = 24)

/obj/structure/largecrate/supply/ammo/sentry
	name = "\improper ST-571 ammunition drum case (x6)"
	desc = "An ammunition case containing six ST-571 sentry ammunition drums."
	supplies = list(/obj/item/ammo_magazine/sentry = 6)

/obj/structure/largecrate/supply/ammo/standard_hmg
	name = "\improper HSG-102 ammunition box case (x6)"
	desc = "An ammunition case containing six HSG-102 ammunition boxes."
	supplies = list(/obj/item/ammo_magazine/tl102 = 6)

/obj/structure/largecrate/supply/ammo/standard_ammo
	name = "large surplus ammuniton crate"
	desc = "An ammunition case containing one box of each TGMC brand ammo type."
	icon_state = "chest"
	supplies = list(
		/obj/item/shotgunbox = 1,
		/obj/item/shotgunbox/buckshot = 1,
		/obj/item/shotgunbox/flechette = 1,
		/obj/item/shotgunbox/tracker = 1,
		/obj/item/storage/box/visual/magazine/compact/standard_pistol/full = 1,
		/obj/item/storage/box/visual/magazine/compact/standard_heavypistol/full = 1,
		/obj/item/storage/box/visual/magazine/compact/standard_revolver/full = 1,
		/obj/item/storage/box/visual/magazine/compact/standard_pocketpistol/full = 1,
		/obj/item/storage/box/visual/magazine/compact/vp70/full = 1,
		/obj/item/storage/box/visual/magazine/compact/plasma_pistol/full = 1,
		/obj/item/storage/box/visual/magazine/compact/standard_smg/full = 1,
		/obj/item/storage/box/visual/magazine/compact/standard_machinepistol/full = 1,
		/obj/item/storage/box/visual/magazine/compact/standard_assaultrifle/full = 1,
		/obj/item/storage/box/visual/magazine/compact/standard_carbine/full = 1,
		/obj/item/storage/box/visual/magazine/compact/standard_skirmishrifle/full = 1,
		/obj/item/storage/box/visual/magazine/compact/ar11/full = 1,
		/obj/item/storage/box/visual/magazine/compact/lasrifle/marine/full = 1,
		/obj/item/storage/box/visual/magazine/compact/sh15/flechette/full = 1,
		/obj/item/storage/box/visual/magazine/compact/sh15/slug/full = 1,
		/obj/item/storage/box/visual/magazine/compact/standard_dmr/full = 1,
		/obj/item/storage/box/visual/magazine/compact/standard_br/full = 1,
		/obj/item/storage/box/visual/magazine/compact/chamberedrifle/full = 1,
		/obj/item/storage/box/visual/magazine/compact/standard_lmg/full = 1,
		/obj/item/storage/box/visual/magazine/compact/standard_gpmg/full = 1,
		/obj/item/storage/box/visual/magazine/compact/standard_mmg/full = 1,
	)



/obj/structure/largecrate/supply/explosives
	name = "explosives supply crate"
	desc = "A case containing explosives."
	icon_state = "case_double"

/obj/structure/largecrate/supply/explosives/mines
	name = "\improper M20 claymore case (x20)"
	desc = "A case containing five four M20 claymore boxes."
	supplies = list(/obj/item/storage/box/explosive_mines = 5)

/obj/structure/largecrate/supply/explosives/grenades
	name = "\improper M40 HEDP grenade case (x50)"
	desc = "A case containing two twenty-five M40 HDEP grenade boxes."
	supplies = list(/obj/item/storage/box/visual/grenade/frag = 2)

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

/obj/structure/largecrate/supply/explosives/disposable
	name = "RL-72 disposable rocket launchers (x8)"
	desc = "A case containing eight RL-72 disposables."
	supplies = list(/obj/item/weapon/gun/launcher/rocket/oneuse = 8)

/obj/structure/largecrate/supply/supplies
	name = "supplies crate"
	icon_state = "secure_crate"

/obj/structure/largecrate/supply/supplies/flares
	name = "Flare supply crate (x100)"
	desc = "A supply crate containing twenty five-flare boxes."
	supplies = list(/obj/item/storage/box/m94 = 10)

/obj/structure/largecrate/supply/supplies/coifs
	name = "Heat absorbent coifs supply crate (x25)"
	desc = "A supply crate containing twenty five heat absorbent coifs."
	supplies = list(/obj/item/clothing/mask/rebreather/scarf = 25)

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
	supplies = list(/obj/vehicle/ridden/powerloader = 1)

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
	supplies = list(
		/obj/item/storage/firstaid/regular = 3,
		/obj/item/storage/firstaid/fire = 3,
		/obj/item/storage/firstaid/adv = 6,
		/obj/item/storage/firstaid/toxin = 2,
		/obj/item/storage/firstaid/o2 = 2,
		/obj/item/storage/firstaid/rad = 2,
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
	. = ..()
	if(unmovable)
		. += "<b>!!WARNING!! CONTENTS OF CRATE UNABLE TO BE MOVED ONCE UNPACKAGED!</b>"

/obj/structure/largecrate/machine/attackby(obj/item/I, mob/user, params)
	if(iscrowbar(I) && dir_needed)
		var/turf/next_turf = get_step(src, dir_needed)
		if(next_turf.density)
			to_chat(user, span_warning("You can't open the crate here, there's not enough room!"))
			return
		for(var/atom/movable/AM in next_turf.contents)
			if(AM.density)
				to_chat(user, span_warning("You can't open the crate here, [AM] blocks the way."))
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
		var/obj/machinery/computer/autodoc_console/C = new (T)
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
		var/obj/machinery/computer/body_scanconsole/C = new (T)
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
		var/obj/machinery/computer/sleep_console/C = new (T)
		C.loc = get_step(T, EAST)
		E.connected = C
		C.connected = E
