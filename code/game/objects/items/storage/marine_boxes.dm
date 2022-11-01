/obj/item/storage/box/heavy_armor
	name = "\improper B-Series defensive armor crate"
	desc = "A large case containing an experiemental suit of B18 armor for the discerning specialist."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "armor_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 3
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

/obj/item/storage/box/heavy_armor/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/gloves/marine/specialist(src)
	new /obj/item/clothing/suit/storage/marine/specialist(src)
	new /obj/item/clothing/head/helmet/marine/specialist(src)

/obj/item/storage/box/m42c_system
	name = "\improper antimaterial scoped rifle system (recon set)"
	desc = "A large case containing your very own long-range sniper rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 12
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

/obj/item/storage/box/m42c_system/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/storage/marine/sniper(src)
	new /obj/item/clothing/head/helmet/marine/sniper(src)
	new /obj/item/clothing/glasses/night/m42_night_goggles(src)
	new /obj/item/ammo_magazine/sniper(src)
	new /obj/item/ammo_magazine/sniper/incendiary(src)
	new /obj/item/ammo_magazine/sniper/flak(src)
	new /obj/item/binoculars/tactical(src)
	new /obj/item/storage/backpack/marine/smock(src)
	new /obj/item/weapon/gun/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/weapon/gun/rifle/sniper/antimaterial(src)
	new /obj/item/bodybag/tarp(src)
	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new /obj/item/clothing/head/modular/marine/m10x(src)
	else
		new /obj/item/clothing/head/helmet/durag(src)
		new /obj/item/facepaint/sniper(src)

/obj/item/storage/box/m42c_system_Jungle
	name = "\improper antimaterial scoped rifle system (marksman set)"
	desc = "A large case containing your very own long-range sniper rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 9
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

/obj/item/storage/box/m42c_system_Jungle/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/storage/marine/sniper/jungle(src)
	new /obj/item/clothing/head/helmet/marine/sniper(src)
	new /obj/item/clothing/glasses/m42_goggles(src)
	new /obj/item/clothing/head/helmet/durag/jungle(src)
	new /obj/item/ammo_magazine/sniper(src)
	new /obj/item/ammo_magazine/sniper(src)
	new /obj/item/ammo_magazine/sniper/incendiary(src)
	new /obj/item/weapon/gun/rifle/sniper/antimaterial(src)
	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new /obj/item/clothing/under/marine/sniper(src)
		new /obj/item/storage/backpack/marine/satchel(src)
		new /obj/item/bodybag/tarp/snow(src)
	else
		new /obj/item/facepaint/sniper(src)
		new /obj/item/storage/backpack/marine/smock(src)
		new /obj/item/bodybag/tarp(src)

/obj/item/storage/box/grenade_system
	name = "\improper M92 grenade launcher case"
	desc = "A large case containing a heavy-duty multi-shot grenade launcher, the Armat Systems M92. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "grenade_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 2
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

/obj/item/storage/box/grenade_system/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/grenade_launcher/multinade_launcher(src)
	new /obj/item/storage/belt/grenade/b17(src)

/obj/item/storage/box/rocket_system
	name = "\improper M5 RPG crate"
	desc = "A large case containing a heavy-caliber antitank missile launcher and missiles. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "rocket_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 6
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

/obj/item/storage/box/rocket_system/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/launcher/rocket/sadar(src)
	new /obj/item/ammo_magazine/rocket/sadar(src)
	new /obj/item/ammo_magazine/rocket/sadar(src)
	new /obj/item/ammo_magazine/rocket/sadar/ap(src)
	new /obj/item/ammo_magazine/rocket/sadar/ap(src)
	new /obj/item/ammo_magazine/rocket/sadar/wp(src)

////////////////// new specialist systems ///////////////////////////:


/obj/item/storage/box/spec
	var/spec_set

/obj/item/storage/box/spec/demolitionist
	name = "\improper Demolitionist equipment crate"
	desc = "A large case containing light armor, a heavy-caliber antitank missile launcher, missiles, C4, detpacks, and claymore mines. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "rocket_case"
	spec_set = "demolitionist"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 16
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

/obj/item/storage/box/spec/demolitionist/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/storage/marine/M3T(src)
	new /obj/item/clothing/head/modular/marine/m10x(src)
	new /obj/item/weapon/gun/launcher/rocket/sadar(src)
	new /obj/item/ammo_magazine/rocket/sadar(src)
	new /obj/item/ammo_magazine/rocket/sadar(src)
	new /obj/item/ammo_magazine/rocket/sadar/ap(src)
	new /obj/item/ammo_magazine/rocket/sadar/ap(src)
	new /obj/item/ammo_magazine/rocket/sadar/wp(src)
	new /obj/item/ammo_magazine/rocket/sadar/wp(src)
	new /obj/item/explosive/mine(src)
	new /obj/item/explosive/mine(src)
	new /obj/item/detpack(src)
	new /obj/item/detpack(src)
	new /obj/item/detpack(src)
	new /obj/item/detpack(src)
	new /obj/item/assembly/signaler(src)



/obj/item/storage/box/spec/sniper
	name = "\improper Sniper equipment"
	desc = "A large case containing your very own long-range sniper rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 15
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null
	spec_set = "sniper"

/obj/item/storage/box/spec/sniper/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/storage/marine/sniper(src)
	new /obj/item/clothing/head/helmet/marine/sniper(src)
	new /obj/item/clothing/glasses/night/m42_night_goggles(src)
	new /obj/item/ammo_magazine/sniper(src)
	new /obj/item/ammo_magazine/sniper(src)
	new /obj/item/ammo_magazine/sniper/incendiary(src)
	new /obj/item/ammo_magazine/sniper/incendiary(src)
	new /obj/item/ammo_magazine/sniper/flak(src)
	new /obj/item/ammo_magazine/sniper/flak(src)
	new /obj/item/binoculars/tactical(src)
	new /obj/item/weapon/gun/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/storage/backpack/marine/satchel/scout_cloak/sniper(src)
	new /obj/item/weapon/gun/rifle/sniper/antimaterial(src)
	new /obj/item/explosive/grenade/smokebomb/cloak(src)
	new /obj/item/explosive/grenade/smokebomb/cloak(src)
	new /obj/item/explosive/grenade/smokebomb/cloak(src)
	new /obj/item/bodybag/tarp(src)
	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new /obj/item/clothing/head/modular/marine/m10x(src)
	else
		new /obj/item/clothing/head/helmet/durag(src)
		new /obj/item/facepaint/sniper(src)

/obj/item/storage/box/spec/scout
	name = "\improper Scout equipment"
	desc = "A large case containing Scout equipment; this one features the BR-8 battle rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 22
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null
	spec_set = "scout battle rifle"

/obj/item/storage/box/spec/scout/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/storage/marine/M3S(src)
	new /obj/item/clothing/head/helmet/marine/scout(src)
	new /obj/item/clothing/glasses/night/tx8(src)
	new /obj/item/ammo_magazine/rifle/tx8(src)
	new /obj/item/ammo_magazine/rifle/tx8(src)
	new /obj/item/ammo_magazine/rifle/tx8(src)
	new /obj/item/ammo_magazine/rifle/tx8(src)
	new /obj/item/ammo_magazine/rifle/tx8(src)
	new /obj/item/ammo_magazine/rifle/tx8(src)
	new /obj/item/ammo_magazine/rifle/tx8/incendiary(src)
	new /obj/item/ammo_magazine/rifle/tx8/incendiary(src)
	new /obj/item/ammo_magazine/rifle/tx8/impact(src)
	new /obj/item/ammo_magazine/rifle/tx8/impact(src)
	new /obj/item/binoculars/tactical/scout(src)
	new /obj/item/weapon/gun/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/weapon/gun/rifle/tx8(src)
	new /obj/item/storage/backpack/marine/satchel/scout_cloak/scout(src)
	new /obj/item/attachable/motiondetector(src)
	new /obj/item/explosive/grenade/smokebomb/cloak(src)
	new /obj/item/explosive/grenade/smokebomb/cloak(src)
	new /obj/item/explosive/grenade/smokebomb/cloak(src)
	new /obj/item/bodybag/tarp(src)


/obj/item/storage/box/spec/scoutshotgun
	name = "\improper Scout equipment"
	desc = "A large case containing Scout equipment; this one features the ZX-76 assault shotgun. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 21
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null
	spec_set = "scout shotgun"

/obj/item/storage/box/spec/scoutshotgun/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/storage/marine/M3S(src)
	new /obj/item/clothing/head/helmet/marine/scout(src)
	new /obj/item/clothing/glasses/night/tx8(src)
	new /obj/item/binoculars/tactical/scout(src)
	new /obj/item/weapon/gun/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/shotgun/incendiary(src)
	new /obj/item/ammo_magazine/shotgun/incendiary(src)
	new /obj/item/storage/backpack/marine/satchel/scout_cloak/scout(src)
	new /obj/item/attachable/motiondetector(src)
	new /obj/item/explosive/grenade/smokebomb/cloak(src)
	new /obj/item/explosive/grenade/smokebomb/cloak(src)
	new /obj/item/explosive/grenade/smokebomb/cloak(src)


/obj/item/storage/box/spec/tracker
	name = "\improper Scout equipment"
	desc = "A large case containing Tracker equipment; this one features the .410 lever action shotgun. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 21
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null
	spec_set = "scout shotgun"

/obj/item/storage/box/spec/tracker/Initialize(mapload, ...)
	. = ..()

	new /obj/item/clothing/suit/storage/marine/M3S(src)
	new /obj/item/clothing/head/helmet/marine/scout(src)
	new /obj/item/clothing/glasses/thermal/m64_thermal_goggles(src)
	new /obj/item/weapon/gun/shotgun/pump/lever/mbx900(src)
	new /obj/item/ammo_magazine/shotgun/mbx900/(src)
	new /obj/item/ammo_magazine/shotgun/mbx900/(src)
	new /obj/item/ammo_magazine/shotgun/mbx900/buckshot(src)
	new /obj/item/ammo_magazine/shotgun/mbx900/buckshot(src)
	new /obj/item/ammo_magazine/shotgun/mbx900/tracking(src)
	new /obj/item/binoculars/tactical/scout(src)
	new /obj/item/weapon/gun/pistol/m1911(src)
	new /obj/item/ammo_magazine/pistol/m1911(src)
	new /obj/item/ammo_magazine/pistol/m1911(src)
	new /obj/item/storage/backpack/marine/satchel/scout_cloak/scout(src)
	new /obj/item/attachable/motiondetector(src)
	new /obj/item/explosive/grenade/smokebomb/cloak(src)
	new /obj/item/explosive/grenade/smokebomb/cloak(src)
	new /obj/item/explosive/grenade/smokebomb/cloak(src)
	new /obj/item/bodybag/tarp(src)

/obj/item/storage/box/spec/pyro
	name = "\improper Pyrotechnician equipment"
	desc = "A large case containing Pyrotechnician equipment. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "armor_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 9
	slowdown = 1
	can_hold = list()
	foldable = null
	spec_set = "pyro"

/obj/item/storage/box/spec/pyro/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/storage/marine/M35(src)
	new /obj/item/clothing/head/helmet/marine/pyro(src)
	new /obj/item/clothing/shoes/marine/pyro(src)
	new /obj/item/ammo_magazine/flamer_tank/backtank(src)
	new /obj/item/weapon/gun/flamer/big_flamer/marinestandard(src)
	new /obj/item/ammo_magazine/flamer_tank/large(src)
	new /obj/item/ammo_magazine/flamer_tank/large(src)
	new /obj/item/ammo_magazine/flamer_tank/large/X(src)



/obj/item/storage/box/spec/heavy_grenadier
	name = "\improper Heavy Grenadier case"
	desc = "A large case containing B17 Heavy Armor and a heavy-duty multi-shot grenade launcher, the Armat Systems M92. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "grenade_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 6
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null
	spec_set = "heavy grenadier"

/obj/item/storage/box/spec/heavy_grenadier/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/grenade_launcher/multinade_launcher(src)
	new /obj/item/storage/belt/grenade/b17(src)
	new /obj/item/clothing/suit/storage/marine/B17(src)
	new /obj/item/clothing/head/helmet/marine/grenadier(src)
	new /obj/item/storage/box/visual/grenade/frag(src)
	new /obj/item/storage/box/visual/grenade/frag(src)
	new /obj/item/storage/box/visual/grenade/incendiary(src)

/obj/item/storage/box/spec/heavy_gunner
	name = "\improper Heavy Minigunner case"
	desc = "A large case containing B18 armor, munitions, and a goddamn minigun. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "rocket_case"
	spec_set = "heavy gunner"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 16
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

/obj/item/storage/box/spec/heavy_gunner/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/gloves/marine/specialist(src)
	new /obj/item/clothing/suit/storage/marine/specialist(src)
	new /obj/item/clothing/head/helmet/marine/specialist(src)
	new /obj/item/weapon/gun/minigun(src)
	new /obj/item/belt_harness/marine(src)
	new /obj/item/ammo_magazine/minigun_powerpack(src)


/obj/item/spec_kit //For events/WO, allowing the user to choose a specalist kit
	name = "specialist kit"
	desc = "A paper box. Open it and get a specialist kit."
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "deliverycrate"

/obj/item/spec_kit/attack_self(mob/user as mob)
	var/choice = tgui_input_list(user, "Please pick a specalist kit!","Selection", list("Pyro","Heavy Armor (Grenadier)","Heavy Armor (Minigun)","Sniper","Scout (Battle Rifle)","Scout (Shotgun)","Demo"))
	if(!choice)
		return
	var/obj/item/storage/box/spec/S = null
	switch(choice)
		if("Pyro")
			S = /obj/item/storage/box/spec/pyro
		if("Heavy Armor (Grenadier)")
			S = /obj/item/storage/box/spec/heavy_grenadier
		if("Heavy Armor (Minigun)")
			S = /obj/item/storage/box/spec/heavy_gunner
		if("Sniper")
			S = /obj/item/storage/box/spec/sniper
		if("Scout (Battle Rifle)")
			S = /obj/item/storage/box/spec/scout
		if("Demo")
			S = /obj/item/storage/box/spec/demolitionist
		if("Scout (Shotgun)")
			S = /obj/item/storage/box/spec/tracker
	new S(loc)
	user.put_in_hands(S)
	qdel()

/obj/item/spec_kit/attack_self(mob/user)
	var/selection = tgui_input_list(user, "Pick your equipment", "Specialist Kit Selection", list("Pyro","Grenadier","Sniper","Scout","Scout (Shotgun)","Demo"))
	if(!selection)
		return
	var/turf/T = get_turf(loc)
	switch(selection)
		if("Pyro")
			new /obj/item/storage/box/spec/pyro (T)
		if("Grenadier")
			new /obj/item/storage/box/spec/heavy_grenadier (T)
		if("Sniper")
			new /obj/item/storage/box/spec/sniper (T)
		if("Scout")
			new /obj/item/storage/box/spec/scout (T)
		if("Demo")
			new /obj/item/storage/box/spec/demolitionist (T)
		if("Scout (Shotgun)")
			new /obj/item/storage/box/spec/tracker (T)
	qdel(src)


////////////////// portable marine kits ///////////////////////////:


/obj/item/storage/box/squadmarine
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "armor_case"
	w_class = WEIGHT_CLASS_HUGE
	slowdown = 1
	can_hold = list()
	foldable = null

/obj/item/storage/box/squadmarine/rifleman
	name = "\improper Rifleman equipment crate"
	desc = "A large case containing the AR-12 assault rifle, medium armor and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 11

/obj/item/storage/box/squadmarine/rifleman/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/storage/marine(src)
	new /obj/item/clothing/head/modular/marine/m10x(src)
	new /obj/item/storage/belt/marine/t12(src)
	new /obj/item/storage/pouch/explosive/full(src)
	new /obj/item/weapon/gun/rifle/standard_assaultrifle/rifleman(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/armor_module/storage/uniform/webbing(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

/obj/item/storage/box/squadmarine/pointman
	name = "\improper Pointman equipment crate"
	desc = "A large case containing the AR-18 carbine, SH-35 shotgun, light armor and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 13


/obj/item/storage/box/squadmarine/pointman/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/shotgun/pump/t35/pointman(src)
	new /obj/item/clothing/suit/storage/marine/M3LB(src)
	new /obj/item/clothing/head/modular/marine/m10x(src)
	new /obj/item/storage/belt/marine/t18(src)
	new /obj/item/storage/pouch/shotgun(src)
	new /obj/item/weapon/gun/rifle/standard_carbine/pointman(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/ammo_magazine/shotgun/buckshot(src)
	new /obj/item/ammo_magazine/shotgun/buckshot(src)
	new /obj/item/armor_module/storage/uniform/webbing(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

/obj/item/storage/box/squadmarine/autorifleman
	name = "\improper Automatic Rifleman equipment crate"
	desc = "A large case containing the MG-42 light machine gun, P-14 pistol, heavy armor and helmet as well as equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 12

/obj/item/storage/box/squadmarine/autorifleman/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/storage/marine/M3HB(src)
	new /obj/item/clothing/head/modular/marine/m10x/heavy(src)
	new /obj/item/weapon/gun/rifle/standard_lmg/autorifleman(src)
	new /obj/item/storage/belt/gun/pistol/m4a3/full(src)
	new /obj/item/storage/pouch/flare/full(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/attachable/bipod(src)
	new /obj/item/attachable/magnetic_harness(src)
	new /obj/item/ammo_magazine/standard_lmg(src)
	new /obj/item/ammo_magazine/standard_lmg(src)
	new /obj/item/ammo_magazine/standard_lmg(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

/obj/item/storage/box/squadmarine/marksman
	name = "\improper Designated Marksman equipment crate"
	desc = "A large case containing the DMR-37 designated marksman rifle, BR-64 battle rifle, integrated storage armor as well as equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 18

/obj/item/storage/box/squadmarine/marksman/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/storage/marine/M3IS(src)
	new /obj/item/clothing/head/modular/marine/m10x(src)
	new /obj/item/weapon/gun/rifle/standard_br(src)
	new /obj/item/belt_harness/marine(src)
	new /obj/item/storage/pouch/flare/full(src)
	new /obj/item/weapon/gun/rifle/standard_dmr/marksman(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/ammo_magazine/rifle/standard_dmr(src)
	new /obj/item/ammo_magazine/rifle/standard_dmr(src)
	new /obj/item/ammo_magazine/rifle/standard_dmr(src)
	new /obj/item/ammo_magazine/rifle/standard_dmr(src)
	new /obj/item/ammo_magazine/rifle/standard_dmr(src)
	new /obj/item/armor_module/storage/uniform/webbing(src)
	new /obj/item/ammo_magazine/rifle/standard_br(src)
	new /obj/item/ammo_magazine/rifle/standard_br(src)
	new /obj/item/ammo_magazine/rifle/standard_br(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

/obj/item/storage/box/squadmarine/breacher
	name = "\improper Breacher equipment crate"
	desc = "A large case containing the SMG-90 submachinegun, light armor, heavy helmet as well as equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 11

/obj/item/storage/box/squadmarine/breacher/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/storage/marine/M3LB(src)
	new /obj/item/clothing/head/helmet/marine/heavy(src)
	new /obj/item/weapon/gun/smg/standard_smg/breacher(src)
	new /obj/item/storage/belt/marine/t90(src)
	new /obj/item/storage/pouch/explosive/detpack(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/explosive/plastique(src)
	new /obj/item/explosive/plastique(src)
	new /obj/item/storage/holster/blade/machete/full(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

/obj/item/storage/box/squadmarine/engineert12
	name = "\improper AR-12 equipment crate"
	desc = "A large case containing the AR-12 assault rifle and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 13

/obj/item/storage/box/squadmarine/engineert12/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/rifle/standard_assaultrifle/engineer(src)
	new /obj/item/clothing/head/modular/marine/m10x(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/armor_module/storage/uniform/webbing(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)
	new /obj/item/tool/shovel/etool(src)
	new /obj/item/explosive/plastique(src)
	new /obj/item/explosive/plastique(src)
	new /obj/item/cell/high(src)
	new /obj/item/cell/high(src)

/obj/item/storage/box/squadmarine/engineert18
	name = "\improper AR-18 equipment crate"
	desc = "A large case containing the AR-18 carbine and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 13

/obj/item/storage/box/squadmarine/engineert18/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/rifle/standard_carbine/engineer(src)
	new /obj/item/clothing/head/helmet/marine/tech(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/armor_module/storage/uniform/webbing(src)
	new /obj/item/ammo_magazine/rifle/standard_carbine(src)
	new /obj/item/ammo_magazine/rifle/standard_carbine(src)
	new /obj/item/ammo_magazine/rifle/standard_carbine(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)
	new /obj/item/tool/shovel/etool(src)
	new /obj/item/explosive/plastique(src)
	new /obj/item/explosive/plastique(src)
	new /obj/item/cell/high(src)
	new /obj/item/cell/high(src)

/obj/item/storage/box/squadmarine/engineert90
	name = "\improper SMG-90 equipment crate"
	desc = "A large case containing the SMG-90 submachinegun and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 15

/obj/item/storage/box/squadmarine/engineert90/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/smg/standard_smg/nonstandard(src)
	new /obj/item/clothing/head/helmet/marine/heavy(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/armor_module/storage/uniform/brown_vest(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)
	new /obj/item/tool/shovel/etool(src)
	new /obj/item/explosive/plastique(src)
	new /obj/item/explosive/plastique(src)
	new /obj/item/cell/high(src)
	new /obj/item/cell/high(src)

/obj/item/storage/box/squadmarine/engineert35
	name = "\improper SH-35 equipment crate"
	desc = "A large case containing the SH-35 shotgun and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 11

/obj/item/storage/box/squadmarine/engineert35/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/shotgun/pump/t35/nonstandard(src)
	new /obj/item/clothing/head/helmet/marine/heavy(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/armor_module/storage/uniform/brown_vest(src)
	new /obj/item/ammo_magazine/shotgun/buckshot(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)
	new /obj/item/tool/shovel/etool(src)
	new /obj/item/explosive/plastique(src)
	new /obj/item/explosive/plastique(src)
	new /obj/item/cell/high(src)
	new /obj/item/cell/high(src)

/obj/item/storage/box/squadmarine/corpsmant90
	name = "\improper SMG-90 equipment crate"
	desc = "A large case containing the SMG-90 submachinegun and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 8

/obj/item/storage/box/squadmarine/corpsmant90/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/smg/standard_smg/nonstandard(src)
	new /obj/item/armor_module/storage/uniform/brown_vest(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

/obj/item/storage/box/squadmarine/corpsmant35
	name = "\improper SH-35 equipment crate"
	desc = "A large case containing the SH-35 shotgun and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 4

/obj/item/storage/box/squadmarine/corpsmant35/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/shotgun/pump/t35/nonstandard(src)
	new /obj/item/armor_module/storage/uniform/brown_vest(src)
	new /obj/item/ammo_magazine/shotgun/buckshot(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

/obj/item/storage/box/squadmarine/smartgunnert19
	name = "\improper MP-19 equipment crate"
	desc = "A large case containing the MP-19 machine pistol and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 8

/obj/item/storage/box/squadmarine/smartgunnert19/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/smg/standard_machinepistol(src)
	new /obj/item/storage/pouch/magazine/smgfull(src)
	new /obj/item/armor_module/storage/uniform/brown_vest(src)
	new /obj/item/ammo_magazine/smg/standard_machinepistol(src)
	new /obj/item/ammo_magazine/smg/standard_machinepistol(src)
	new /obj/item/ammo_magazine/smg/standard_machinepistol(src)
	new /obj/item/ammo_magazine/smg/standard_machinepistol(src)
	new /obj/item/ammo_magazine/smg/standard_machinepistol(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

/obj/item/storage/box/squadmarine/smartgunnerm4a3
	name = "\improper M4A3 equipment crate"
	desc = "A large case containing the M4A3 pistol and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 10

/obj/item/storage/box/squadmarine/smartgunnerm4a3/Initialize(mapload, ...)
	. = ..()
	new /obj/item/storage/belt/gun/pistol/m4a3/full(src)
	new /obj/item/storage/pouch/magazine/pistol/large/full(src)
	new /obj/item/armor_module/storage/uniform/brown_vest(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

// Equipped Squad marine roles' version of specialist kits

/obj/item/storage/box/squadmarine/demolitionist
	name = "\improper Demolitionist equipment crate"
	desc = "A large case containing light armor, a heavy-caliber antitank missile launcher, missiles, C4, detpacks, and claymore mines. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon_state = "rocket_case"
	storage_slots = 24

/obj/item/storage/box/squadmarine/demolitionist/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/storage/marine/M3T(src)
	new /obj/item/clothing/head/helmet/marine/standard(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/weapon/gun/launcher/rocket/sadar(src)
	new /obj/item/storage/holster/t19/full(src)
	new /obj/item/weapon/gun/smg/standard_smg/nonstandard(src)
	new /obj/item/ammo_magazine/rocket/sadar(src)
	new /obj/item/ammo_magazine/rocket/sadar/(src)
	new /obj/item/ammo_magazine/rocket/sadar/ap(src)
	new /obj/item/ammo_magazine/rocket/sadar/ap(src)
	new /obj/item/ammo_magazine/rocket/sadar/wp(src)
	new /obj/item/ammo_magazine/rocket/sadar/wp(src)
	new /obj/item/storage/pouch/explosive/detpack(src)
	new /obj/item/explosive/mine(src)
	new /obj/item/explosive/mine(src)
	new /obj/item/armor_module/storage/uniform/brown_vest(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

/obj/item/storage/box/squadmarine/sniper
	name = "\improper Sniper equipment"
	desc = "A large case containing your very own long-range sniper rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon_state = "sniper_case"
	storage_slots = 22

/obj/item/storage/box/squadmarine/sniper/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/storage/marine/sniper(src)
	new /obj/item/clothing/head/helmet/marine/sniper(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/clothing/glasses/night/m42_night_goggles(src)
	new /obj/item/weapon/gun/rifle/sniper/antimaterial(src)
	new /obj/item/storage/belt/marine/antimaterial(src)
	new /obj/item/ammo_magazine/sniper(src)
	new /obj/item/storage/pouch/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/storage/backpack/marine/satchel/scout_cloak/sniper(src)
	new /obj/item/bodybag/tarp(src)
	new /obj/item/binoculars/tactical(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/armor_module/storage/uniform/webbing(src)
	new /obj/item/explosive/grenade/smokebomb/cloak(src)
	new /obj/item/explosive/grenade/smokebomb/cloak(src)
	new /obj/item/explosive/grenade/smokebomb/cloak(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

/obj/item/storage/box/squadmarine/scout
	name = "\improper Scout equipment"
	desc = "A large case containing Scout equipment; this one features the T-45 battle rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon_state = "sniper_case"
	storage_slots = 23

/obj/item/storage/box/squadmarine/scout/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/storage/marine/M3S(src)
	new /obj/item/clothing/head/helmet/marine/scout(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/clothing/glasses/night/tx8(src)
	new /obj/item/weapon/gun/rifle/tx8(src)
	new /obj/item/storage/pouch/magazine/large/tx8full(src)
	new /obj/item/storage/belt/marine/tx8(src)
	new /obj/item/ammo_magazine/rifle/tx8(src)
	new /obj/item/ammo_magazine/rifle/tx8(src)
	new /obj/item/storage/backpack/marine/satchel/scout_cloak/scout(src)
	new /obj/item/binoculars/tactical/scout(src)
	new /obj/item/weapon/gun/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/attachable/motiondetector(src)
	new /obj/item/bodybag/tarp(src)
	new /obj/item/armor_module/storage/uniform/webbing(src)
	new /obj/item/explosive/grenade/smokebomb/cloak(src)
	new /obj/item/explosive/grenade/smokebomb/cloak(src)
	new /obj/item/explosive/grenade/smokebomb/cloak(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

/obj/item/storage/box/squadmarine/tracker
	name = "\improper Scout equipment"
	desc = "A large case containing Tracker equipment; this one features the .410 lever action shotgun. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon_state = "sniper_case"
	storage_slots = 25

/obj/item/storage/box/squadmarine/tracker/Initialize(mapload, ...)
	. = ..()

	new /obj/item/clothing/suit/storage/marine/M3S(src)
	new /obj/item/clothing/head/helmet/marine/scout(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/clothing/glasses/thermal/m64_thermal_goggles(src)
	new /obj/item/weapon/gun/shotgun/pump/lever/mbx900(src)
	new /obj/item/storage/belt/shotgun(src)
	new /obj/item/storage/pouch/shotgun(src)
	new /obj/item/ammo_magazine/shotgun/mbx900/(src)
	new /obj/item/ammo_magazine/shotgun/mbx900/(src)
	new /obj/item/ammo_magazine/shotgun/mbx900/buckshot(src)
	new /obj/item/ammo_magazine/shotgun/mbx900/buckshot(src)
	new /obj/item/ammo_magazine/shotgun/mbx900/tracking(src)
	new /obj/item/ammo_magazine/pistol/m1911(src)
	new /obj/item/ammo_magazine/pistol/m1911(src)
	new /obj/item/storage/backpack/marine/satchel/scout_cloak/scout(src)
	new /obj/item/binoculars/tactical/scout(src)
	new /obj/item/weapon/gun/pistol/m1911(src)
	new /obj/item/attachable/motiondetector(src)
	new /obj/item/explosive/grenade/smokebomb/cloak(src)
	new /obj/item/explosive/grenade/smokebomb/cloak(src)
	new /obj/item/explosive/grenade/smokebomb/cloak(src)
	new /obj/item/bodybag/tarp(src)
	new /obj/item/armor_module/storage/uniform/brown_vest(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

/obj/item/storage/box/squadmarine/pyro
	name = "\improper Pyrotechnician equipment"
	desc = "A large case containing Pyrotechnician equipment. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 22

/obj/item/storage/box/squadmarine/pyro/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/storage/marine/M35(src)
	new /obj/item/clothing/head/helmet/marine/pyro(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/clothing/shoes/marine/pyro(src)
	new /obj/item/ammo_magazine/flamer_tank/backtank(src)
	new /obj/item/weapon/gun/flamer/big_flamer/marinestandard(src)
	new /obj/item/attachable/magnetic_harness(src)
	new /obj/item/storage/holster/t19/full(src)
	new /obj/item/weapon/gun/smg/standard_smg/nonstandard(src)
	new /obj/item/storage/pouch/magazine/large/t19full(src)
	new /obj/item/ammo_magazine/flamer_tank/large(src)
	new /obj/item/ammo_magazine/flamer_tank/large(src)
	new /obj/item/ammo_magazine/flamer_tank/large(src)
	new /obj/item/ammo_magazine/flamer_tank/large/X(src)
	new /obj/item/armor_module/storage/uniform/brown_vest(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

/obj/item/storage/box/squadmarine/heavy_grenadier
	name = "\improper Heavy Grenadier case"
	desc = "A large case containing B17 Heavy Armor and a heavy-duty multi-shot grenade launcher, the Armat Systems M92. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 18

/obj/item/storage/box/squadmarine/heavy_grenadier/Initialize(mapload, ...)
	. = ..()
	new /obj/item/storage/belt/grenade/b17(src)
	new /obj/item/clothing/suit/storage/marine/B17(src)
	new /obj/item/weapon/gun/grenade_launcher/multinade_launcher(src)
	new /obj/item/attachable/magnetic_harness(src)
	new /obj/item/clothing/head/helmet/marine/grenadier(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/storage/box/visual/grenade/frag(src)
	new /obj/item/storage/box/visual/grenade/frag(src)
	new /obj/item/storage/box/visual/grenade/incendiary(src)
	new /obj/item/storage/backpack/marine/standard(src)
	new /obj/item/storage/backpack/marine/standard(src)
	new /obj/item/storage/backpack/marine/standard(src)
	new /obj/item/storage/backpack/marine/standard(src)
	new /obj/item/storage/backpack/marine/standard(src)
	new /obj/item/storage/pouch/explosive(src)
	new /obj/item/armor_module/storage/uniform/brown_vest(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

/obj/item/storage/box/squadmarine/heavy_gunner
	name = "\improper Heavy Minigunner case"
	desc = "A large case containing B18 armor, munitions, and a goddamn minigun. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 19

/obj/item/storage/box/squadmarine/heavy_gunner/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/gloves/marine/specialist(src)
	new /obj/item/clothing/suit/storage/marine/specialist(src)
	new /obj/item/clothing/head/helmet/marine/specialist(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/weapon/gun/minigun(src)
	new /obj/item/belt_harness/marine(src)
	new /obj/item/ammo_magazine/minigun_powerpack(src)
	new /obj/item/ammo_magazine/minigun_powerpack(src)
	new /obj/item/ammo_magazine/minigun_powerpack(src)
	new /obj/item/attachable/flashlight(src)
	new /obj/item/storage/pouch/pistol/rt3(src)
	new /obj/item/armor_module/storage/uniform/brown_vest(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

/obj/item/storage/box/squadmarine/squadleader
	name = "\improper Squad Leadeer equipment crate"
	desc = "A large case containing the AR-12 assault rifle and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 7

/obj/item/storage/box/squadmarine/squadleader/Initialize(mapload, ...)
	. = ..()
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/armor_module/storage/uniform/webbing(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

// engineer Kits

/obj/item/storage/box/engikit
	name = "\improper Engineer kit"
	desc = "A large case containing specialist engineering kit"
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "armor_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 2

/obj/item/storage/box/engikit/logistics
	name = "\improper Logistical Engineering Kit"
	desc = "A large case containing a pair of teleporters and dispenser. Sentry and batteries not included."
	storage_slots = 3

/obj/item/storage/box/engikit/logistics/Initialize(mapload, ...)
	. = ..()
	new /obj/effect/teleporter_linker(src)
	new /obj/item/storage/backpack/dispenser(src)

/obj/item/storage/box/engikit/forwardsupport
	name = "\improper Forward Support Kit"
	desc = "A large case containing a radio backpack, a pair of fultons and a range finder."
	storage_slots = 4

/obj/item/storage/box/engikit/forwardsupport/Initialize(mapload, ...)
	. = ..()
	new /obj/item/storage/backpack/marine/radiopack(src)
	new /obj/item/fulton_extraction_pack(src)
	new /obj/item/fulton_extraction_pack(src)
	new /obj/item/binoculars/tactical/range(src)

/obj/item/storage/box/engikit/breacher
	name = "\improper Breacher kit"
	desc = "A large case containing a plasma cutter and four C4"
	storage_slots = 5

/obj/item/storage/box/engikit/breacher/Initialize(mapload, ...)
	. = ..()
	new /obj/item/tool/pickaxe/plasmacutter(src)
	new /obj/item/explosive/plastique(src)
	new /obj/item/explosive/plastique(src)
	new /obj/item/explosive/plastique(src)
	new /obj/item/explosive/plastique(src)
