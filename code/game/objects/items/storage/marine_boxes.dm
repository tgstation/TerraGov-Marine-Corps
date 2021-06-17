
/obj/item/storage/box/t26_system
	name = "\improper T26 smart machinegun system"
	desc = "A large case containing the full T-26 Machinegun System. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "smartgun_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 4
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null
	spawns_with = list(
		/obj/item/clothing/glasses/night/m56_goggles,
		/obj/item/weapon/gun/rifle/standard_smartmachinegun,
		/obj/item/ammo_magazine/standard_smartmachinegun,
		/obj/item/ammo_magazine/standard_smartmachinegun,
	)

/obj/item/smartgun_powerpack
	name = "\improper M56 powerpack"
	desc = "A heavy reinforced backpack with support equipment, power cells, and spare rounds for the M56 Smartgun System.\nClick the icon in the top left to reload your M56."
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "powerpack"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE

	///Our power cell
	var/obj/item/cell/pcell = null

	///How many rounds do we have left
	var/rounds_remaining = 500

	///How many rounds are we allowed to store
	var/rounds_max = 500
	actions_types = list(/datum/action/item_action/toggle)

	///Are we currently reloading
	var/reloading = FALSE
	flags_item_map_variant = (ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_PRISON_VARIANT)

/obj/item/smartgun_powerpack/Initialize()
	. = ..()
	pcell = new /obj/item/cell(src)

/obj/item/smartgun_powerpack/attack_self(mob/living/carbon/human/user, automatic = FALSE)
	if(!istype(user) || user.incapacitated())
		return FALSE

	var/obj/item/weapon/gun/smartgun/mygun = user.get_active_held_item()

	if(!istype(mygun))
		to_chat(user, "You must be holding an M56 Smartgun to begin the reload process.")
		return TRUE
	if(rounds_remaining < 1)
		to_chat(user, "Your powerpack is completely devoid of spare ammo belts! Looks like you're up shit creek, maggot!")
		return TRUE
	if(!pcell)
		to_chat(user, "Your powerpack doesn't have a battery! Slap one in there!")
		return TRUE

	mygun.shells_fired_now = 0 //If you attempt a reload, the shells reset. Also prevents double reload if you fire off another 20 bullets while it's loading.

	if(reloading)
		return TRUE
	if(pcell.charge <= 50)
		to_chat(user, "Your powerpack's battery is too drained! Get a new battery and install it!")
		return TRUE

	reloading = TRUE
	if(!automatic)
		user.visible_message("[user.name] begins feeding an ammo belt into the M56 Smartgun.","You begin feeding a fresh ammo belt into the M56 Smartgun. Don't move or you'll be interrupted.")
	else
		user.visible_message("[user.name]'s powerpack servos begin automatically feeding an ammo belt into the M56 Smartgun.","The powerpack servos begin automatically feeding a fresh ammo belt into the M56 Smartgun.")
	var/reload_duration = 5 SECONDS
	var/obj/screen/ammo/ammo = user.hud_used.ammo
	if(automatic)
		if(!autoload_check(user, reload_duration, mygun, src) || !pcell)
			to_chat(user, "The automated reload process was interrupted!")
			playsound(src,'sound/machines/buzz-two.ogg', 25, TRUE)
			reloading = FALSE
			return TRUE
		reload(user, mygun, TRUE)
		ammo.update_hud(user)
		return TRUE
	if(user.skills.getRating("smartgun") > 0)
		reload_duration = max(reload_duration - 1 SECONDS * user.skills.getRating("smartgun"), 3 SECONDS)
	if(!do_after(user, reload_duration, TRUE, src, BUSY_ICON_GENERIC) || !pcell)
		to_chat(user, "Your reloading was interrupted!")
		playsound(src,'sound/machines/buzz-two.ogg', 25, TRUE)
		reloading = FALSE
		return TRUE
	reload(user, mygun)
	ammo.update_hud(user)
	return TRUE

/obj/item/smartgun_powerpack/attack_hand(mob/living/user)
	if(user.get_inactive_held_item() != src)
		return ..()
	if(QDELETED(pcell))
		to_chat(user, "There is no cell in the [src].")
		return
	user.put_in_hands(pcell)
	playsound(src,'sound/machines/click.ogg', 25, 1)
	to_chat(user, "You take out the [pcell] out of the [src].")
	pcell = null

/obj/item/smartgun_powerpack/attackby(obj/item/item, mob/user, params)
	. = ..()
	if(istype(item, /obj/item/cell))
		var/obj/item/cell/cell = item

		if(!QDELETED(pcell))
			to_chat(user, "There already is a cell in the [src].")
			return

		if(!user.transferItemToLoc(item, src))
			return

		pcell = cell
		user.visible_message("[user] puts a new power cell in the [src].", "You put a new power cell in the [src] containing [pcell.charge] charge.")
		playsound(src,'sound/machines/click.ogg', 25, 1)

/obj/item/smartgun_powerpack/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 1)
		to_chat(user, "A small gauge in the corner reads: Ammo: [rounds_remaining] / [rounds_max]. [pcell ? "Charge: [pcell.charge] / [pcell.maxcharge].":""]")

///Uses charge from the internal powercell to instantly reload; doesn't verify we actually have the charge though
/obj/item/smartgun_powerpack/proc/reload(mob/user, obj/item/weapon/gun/smartgun/mygun, automatic = FALSE)
	pcell.charge -= 50
	if(!mygun.current_mag)
		var/obj/item/ammo_magazine/internal/smartgun/mag = new(mygun)
		mygun.current_mag = mag

	var/rounds_to_reload = min(rounds_remaining, (mygun.current_mag.max_rounds - mygun.current_mag.current_rounds)) //Get the smaller value.

	mygun.current_mag.current_rounds += rounds_to_reload
	rounds_remaining -= rounds_to_reload

	if(!automatic)
		to_chat(user, "You finish loading [rounds_to_reload] shells into the M56 Smartgun. Ready to rumble!")
	else
		to_chat(user, "The powerpack servos finish loading [rounds_to_reload] shells into the M56 Smartgun. Ready to rumble!")
	playsound(user, 'sound/weapons/guns/interact/smartgun_unload.ogg', 25, 1)

	reloading = FALSE
	return TRUE

/obj/item/smartgun_powerpack/proc/autoload_check(mob/user, delay, obj/item/weapon/gun/smartgun/mygun, obj/item/smartgun_powerpack/powerpack, numticks = 5)
	if(!istype(user) || delay <= 0) return FALSE

	var/mob/living/carbon/human/human_user
	if(ishuman(user))
		human_user = user

	var/delayfraction = round(delay/numticks)
	. = TRUE
	for(var/i = 0 to numticks)
		sleep(delayfraction)
		if(!user)
			. = FALSE
			break
		if(!(human_user.s_store == mygun) && !(user.get_active_held_item() == mygun) && !(user.get_inactive_held_item() == mygun) || !(human_user.back == powerpack)) //power pack and gun aren't where they should be.
			. = FALSE
			break

/obj/item/smartgun_powerpack/snow
	icon_state = "s_powerpack"

/obj/item/smartgun_powerpack/fancy
	icon_state = "powerpackw"

/obj/item/smartgun_powerpack/merc
	icon_state = "powerpackp"

/obj/item/storage/box/heavy_armor
	name = "\improper B-Series defensive armor crate"
	desc = "A large case containing an experiemental suit of B18 armor for the discerning specialist."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "armor_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 3
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null
	spawns_with = list(
		/obj/item/clothing/gloves/marine/specialist,
		/obj/item/clothing/suit/storage/marine/specialist,
		/obj/item/clothing/head/helmet/marine/specialist,
	)

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
	spawns_with = list(
		/obj/item/clothing/suit/storage/marine/sniper,
		/obj/item/clothing/head/helmet/marine/sniper,
		/obj/item/clothing/glasses/night/m42_night_goggles,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/sniper/incendiary,
		/obj/item/ammo_magazine/sniper/flak,
		/obj/item/binoculars/tactical,
		/obj/item/storage/backpack/marine/smock,
		/obj/item/weapon/gun/pistol/vp70,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/weapon/gun/rifle/sniper/antimaterial,
		/obj/item/bodybag/tarp,
	)

/obj/item/storage/box/m42c_system/PopulateContents()
	. = ..()
	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new /obj/item/clothing/head/helmet/marine/standard(src)
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
	spawns_with = list(
		/obj/item/clothing/suit/storage/marine/sniper/jungle,
		/obj/item/clothing/head/helmet/marine/sniper,
		/obj/item/clothing/glasses/m42_goggles,
		/obj/item/clothing/head/helmet/durag/jungle,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/sniper/incendiary,
		/obj/item/weapon/gun/rifle/sniper/antimaterial,
	)

/obj/item/storage/box/m42c_system_Jungle/PopulateContents()
	. = ..()
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
	spawns_with = list(/obj/item/weapon/gun/launcher/m92, /obj/item/storage/belt/grenade/b17)

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
	spawns_with = list(
		/obj/item/weapon/gun/launcher/rocket/sadar,
		/obj/item/ammo_magazine/rocket/sadar,
		/obj/item/ammo_magazine/rocket/sadar,
		/obj/item/ammo_magazine/rocket/sadar/ap,
		/obj/item/ammo_magazine/rocket/sadar/ap,
		/obj/item/ammo_magazine/rocket/sadar/wp,
	)

/obj/item/storage/box/recoilless_system
	name = "\improper T-160 crate"
	desc = "A large case containing a recoilless launcher and it's payload. Aswell as a specailized bag for carrying the ammo. Has a huge warning sign on the back Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "rocket_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 6
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null
	spawns_with = list(
		/obj/item/weapon/gun/launcher/rocket/recoillessrifle,
		/obj/item/ammo_magazine/rocket/recoilless,
		/obj/item/ammo_magazine/rocket/recoilless,
		/obj/item/ammo_magazine/rocket/recoilless/light,
		/obj/item/ammo_magazine/rocket/recoilless/light,
		/obj/item/storage/backpack/rpg,
	)

////////////////// new specialist systems ///////////////////////////:

/obj/item/storage/box/spec
	///Our chosen speciality
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
	spawns_with = list(
		/obj/item/clothing/suit/storage/marine/M3T,
		/obj/item/clothing/head/helmet/marine/standard,
		/obj/item/weapon/gun/launcher/rocket/sadar,
		/obj/item/ammo_magazine/rocket/sadar,
		/obj/item/ammo_magazine/rocket/sadar,
		/obj/item/ammo_magazine/rocket/sadar/ap,
		/obj/item/ammo_magazine/rocket/sadar/ap,
		/obj/item/ammo_magazine/rocket/sadar/wp,
		/obj/item/ammo_magazine/rocket/sadar/wp,
		/obj/item/explosive/mine,
		/obj/item/explosive/mine,
		/obj/item/detpack,
		/obj/item/detpack,
		/obj/item/detpack,
		/obj/item/detpack,
		/obj/item/assembly/signaler,
	)

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
	spawns_with = list(
		/obj/item/clothing/suit/storage/marine/sniper,
		/obj/item/clothing/head/helmet/marine/sniper,
		/obj/item/clothing/glasses/night/m42_night_goggles,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/sniper/incendiary,
		/obj/item/ammo_magazine/sniper/incendiary,
		/obj/item/ammo_magazine/sniper/flak,
		/obj/item/ammo_magazine/sniper/flak,
		/obj/item/binoculars/tactical,
		/obj/item/weapon/gun/pistol/vp70,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/storage/backpack/marine/satchel/scout_cloak/sniper,
		/obj/item/weapon/gun/rifle/sniper/antimaterial,
		/obj/item/explosive/grenade/cloakbomb,
		/obj/item/explosive/grenade/cloakbomb,
		/obj/item/explosive/grenade/cloakbomb,
		/obj/item/bodybag/tarp,
	)

/obj/item/storage/box/spec/sniper/PopulateContents()
	. = ..()
	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new /obj/item/clothing/head/helmet/marine/standard(src)
	else
		new /obj/item/clothing/head/helmet/durag(src)
		new /obj/item/facepaint/sniper(src)

/obj/item/storage/box/spec/scout
	name = "\improper Scout equipment"
	desc = "A large case containing Scout equipment; this one features the TX-8 battle rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 22
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null
	spec_set = "scout battle rifle"
	spawns_with = list(
		/obj/item/clothing/suit/storage/marine/M3S,
		/obj/item/clothing/head/helmet/marine/scout,
		/obj/item/clothing/glasses/night/tx8,
		/obj/item/ammo_magazine/rifle/tx8,
		/obj/item/ammo_magazine/rifle/tx8,
		/obj/item/ammo_magazine/rifle/tx8,
		/obj/item/ammo_magazine/rifle/tx8,
		/obj/item/ammo_magazine/rifle/tx8,
		/obj/item/ammo_magazine/rifle/tx8,
		/obj/item/ammo_magazine/rifle/tx8/incendiary,
		/obj/item/ammo_magazine/rifle/tx8/incendiary,
		/obj/item/ammo_magazine/rifle/tx8/impact,
		/obj/item/ammo_magazine/rifle/tx8/impact,
		/obj/item/binoculars/tactical/scout,
		/obj/item/weapon/gun/pistol/vp70,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/weapon/gun/rifle/tx8,
		/obj/item/storage/backpack/marine/satchel/scout_cloak/scout,
		/obj/item/motiondetector/scout,
		/obj/item/explosive/grenade/cloakbomb,
		/obj/item/explosive/grenade/cloakbomb,
		/obj/item/explosive/grenade/cloakbomb,
		/obj/item/bodybag/tarp,
	)

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
	spawns_with = list(
		/obj/item/clothing/suit/storage/marine/M3S,
		/obj/item/clothing/head/helmet/marine/scout,
		/obj/item/clothing/glasses/night/tx8,
		/obj/item/binoculars/tactical/scout,
		/obj/item/weapon/gun/pistol/vp70,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/ammo_magazine/shotgun/incendiary,
		/obj/item/ammo_magazine/shotgun/incendiary,
		/obj/item/storage/backpack/marine/satchel/scout_cloak/scout,
		/obj/item/motiondetector/scout,
		/obj/item/explosive/grenade/cloakbomb,
		/obj/item/explosive/grenade/cloakbomb,
		/obj/item/explosive/grenade/cloakbomb,
	)

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
	spawns_with = list(
		/obj/item/clothing/suit/storage/marine/M3S,
		/obj/item/clothing/head/helmet/marine/scout,
		/obj/item/clothing/glasses/thermal/m64_thermal_goggles,
		/obj/item/weapon/gun/shotgun/pump/lever/mbx900,
		/obj/item/ammo_magazine/shotgun/mbx900/,
		/obj/item/ammo_magazine/shotgun/mbx900/,
		/obj/item/ammo_magazine/shotgun/mbx900/buckshot,
		/obj/item/ammo_magazine/shotgun/mbx900/buckshot,
		/obj/item/ammo_magazine/shotgun/mbx900/tracking,
		/obj/item/binoculars/tactical/scout,
		/obj/item/weapon/gun/pistol/m1911,
		/obj/item/ammo_magazine/pistol/m1911,
		/obj/item/ammo_magazine/pistol/m1911,
		/obj/item/storage/backpack/marine/satchel/scout_cloak/scout,
		/obj/item/motiondetector/scout,
		/obj/item/explosive/grenade/cloakbomb,
		/obj/item/explosive/grenade/cloakbomb,
		/obj/item/explosive/grenade/cloakbomb,
		/obj/item/bodybag/tarp,
	)

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
	spawns_with = list(
		/obj/item/clothing/suit/storage/marine/M35,
		/obj/item/clothing/head/helmet/marine/pyro,
		/obj/item/clothing/shoes/marine/pyro,
		/obj/item/ammo_magazine/flamer_tank/backtank,
		/obj/item/weapon/gun/flamer/marinestandard,
		/obj/item/ammo_magazine/flamer_tank/large,
		/obj/item/ammo_magazine/flamer_tank/large,
		/obj/item/ammo_magazine/flamer_tank/large/B,
		/obj/item/ammo_magazine/flamer_tank/large/X,
	)

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
	spawns_with = list(
		/obj/item/weapon/gun/launcher/m92,
		/obj/item/storage/belt/grenade/b17,
		/obj/item/clothing/suit/storage/marine/B17,
		/obj/item/clothing/head/helmet/marine/grenadier,
		/obj/item/storage/box/visual/grenade/frag,
		/obj/item/storage/box/visual/grenade/frag,
		/obj/item/storage/box/visual/grenade/incendiary,
	)

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
	spawns_with = list(
		/obj/item/clothing/gloves/marine/specialist,
		/obj/item/clothing/suit/storage/marine/specialist,
		/obj/item/clothing/head/helmet/marine/specialist,
		/obj/item/weapon/gun/minigun,
		/obj/item/belt_harness/marine,
		/obj/item/ammo_magazine/minigun,
		/obj/item/ammo_magazine/minigun,
		/obj/item/ammo_magazine/minigun,
	)

/obj/item/spec_kit //For events/WO, allowing the user to choose a specalist kit
	name = "specialist kit"
	desc = "A paper box. Open it and get a specialist kit."
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "deliverycrate"

/obj/item/spec_kit/attack_self(mob/user)
	var/choice = tgui_input_list(user, "Please pick a specalist kit!","Selection", list("Pyro","Heavy Armor (Grenadier)","Heavy Armor (Minigun)","Sniper","Scout (Battle Rifle)","Scout (Shotgun)","Demo"))
	if(!choice)
		return
	var/obj/item/storage/box/spec/chosen = null
	switch(choice)
		if("Pyro")
			chosen = /obj/item/storage/box/spec/pyro
		if("Heavy Armor (Grenadier)")
			chosen = /obj/item/storage/box/spec/heavy_grenadier
		if("Heavy Armor (Minigun)")
			chosen = /obj/item/storage/box/spec/heavy_gunner
		if("Sniper")
			chosen = /obj/item/storage/box/spec/sniper
		if("Scout (Battle Rifle)")
			chosen = /obj/item/storage/box/spec/scout
		if("Demo")
			chosen = /obj/item/storage/box/spec/demolitionist
		if("Scout (Shotgun)")
			chosen = /obj/item/storage/box/spec/tracker
	var/chosen_new = new chosen(loc)
	user.put_in_hands(chosen_new)
	qdel(src)

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
	desc = "A large case containing the T-12 assault rifle, medium armor and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 11
	spawns_with = list(
		/obj/item/clothing/suit/storage/marine,
		/obj/item/clothing/head/helmet/marine/standard,
		/obj/item/storage/belt/marine/t12,
		/obj/item/storage/pouch/explosive/full,
		/obj/item/weapon/gun/rifle/standard_assaultrifle/rifleman,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/explosive/grenade/frag,
		/obj/item/explosive/grenade/frag,
		/obj/item/clothing/tie/storage/webbing,
		/obj/item/ammo_magazine/rifle/standard_assaultrifle,
		/obj/item/ammo_magazine/rifle/standard_assaultrifle,
		/obj/item/ammo_magazine/rifle/standard_assaultrifle,
		/obj/item/clothing/mask/rebreather/scarf,
	)

/obj/item/storage/box/squadmarine/pointman
	name = "\improper Pointman equipment crate"
	desc = "A large case containing the T-18 carbine, T-35 shotgun, light armor and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 13

/obj/item/storage/box/squadmarine/pointman
	spawns_with = list(
		/obj/item/weapon/gun/shotgun/pump/t35/pointman,
		/obj/item/clothing/suit/storage/marine/M3LB,
		/obj/item/clothing/head/helmet/marine/standard,
		/obj/item/storage/belt/marine/t18,
		/obj/item/storage/pouch/shotgun,
		/obj/item/weapon/gun/rifle/standard_carbine/pointman,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/explosive/grenade/frag,
		/obj/item/explosive/grenade/frag,
		/obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/clothing/tie/storage/webbing,
		/obj/item/clothing/mask/rebreather/scarf,
	)

/obj/item/storage/box/squadmarine/autorifleman
	name = "\improper Automatic Rifleman equipment crate"
	desc = "A large case containing the T-42 light machine gun, TP-14 pistol, heavy armor and helmet as well as equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 12

/obj/item/storage/box/squadmarine/autorifleman
	spawns_with = list(
		/obj/item/clothing/suit/storage/marine/M3HB,
		/obj/item/clothing/head/helmet/marine/heavy,
		/obj/item/weapon/gun/rifle/standard_lmg/autorifleman,
		/obj/item/storage/belt/gun/pistol/m4a3/full,
		/obj/item/storage/pouch/flare/full,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/attachable/bipod,
		/obj/item/attachable/magnetic_harness,
		/obj/item/ammo_magazine/standard_lmg,
		/obj/item/ammo_magazine/standard_lmg,
		/obj/item/ammo_magazine/standard_lmg,
		/obj/item/clothing/mask/rebreather/scarf,
	)

/obj/item/storage/box/squadmarine/marksman
	name = "\improper Designated Marksman equipment crate"
	desc = "A large case containing the T-37 designated marksman rifle, T-64 battle rifle, integrated storage armor as well as equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 18

/obj/item/storage/box/squadmarine/marksman
	spawns_with = list(
		/obj/item/clothing/suit/storage/marine/M3IS,
		/obj/item/clothing/head/helmet/marine/standard,
		/obj/item/weapon/gun/rifle/standard_br,
		/obj/item/belt_harness/marine,
		/obj/item/storage/pouch/flare/full,
		/obj/item/weapon/gun/rifle/standard_dmr/marksman,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/ammo_magazine/rifle/standard_dmr,
		/obj/item/ammo_magazine/rifle/standard_dmr,
		/obj/item/ammo_magazine/rifle/standard_dmr,
		/obj/item/ammo_magazine/rifle/standard_dmr,
		/obj/item/ammo_magazine/rifle/standard_dmr,
		/obj/item/clothing/tie/storage/webbing,
		/obj/item/ammo_magazine/rifle/standard_br,
		/obj/item/ammo_magazine/rifle/standard_br,
		/obj/item/ammo_magazine/rifle/standard_br,
		/obj/item/clothing/mask/rebreather/scarf,
	)

/obj/item/storage/box/squadmarine/breacher
	name = "\improper Breacher equipment crate"
	desc = "A large case containing the T-90 submachinegun, light armor, heavy helmet as well as equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 11

/obj/item/storage/box/squadmarine/breacher
	spawns_with = list(
		/obj/item/clothing/suit/storage/marine/M3LB,
		/obj/item/clothing/head/helmet/marine/heavy,
		/obj/item/weapon/gun/smg/standard_smg/breacher,
		/obj/item/storage/belt/marine/t90,
		/obj/item/storage/pouch/explosive/detpack,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/explosive/plastique,
		/obj/item/explosive/plastique,
		/obj/item/storage/large_holster/machete/full,
		/obj/item/clothing/mask/rebreather/scarf,
	)

/obj/item/storage/box/squadmarine/engineert12
	name = "\improper T-12 equipment crate"
	desc = "A large case containing the T-12 assault rifle and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 13

/obj/item/storage/box/squadmarine/engineert12
	spawns_with = list(
		/obj/item/weapon/gun/rifle/standard_assaultrifle/engineer,
		/obj/item/clothing/head/helmet/marine/tech,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/clothing/tie/storage/webbing,
		/obj/item/ammo_magazine/rifle/standard_assaultrifle,
		/obj/item/ammo_magazine/rifle/standard_assaultrifle,
		/obj/item/ammo_magazine/rifle/standard_assaultrifle,
		/obj/item/clothing/mask/rebreather/scarf,
		/obj/item/tool/shovel/etool,
		/obj/item/explosive/plastique,
		/obj/item/explosive/plastique,
		/obj/item/cell/high,
		/obj/item/cell/high,
	)

/obj/item/storage/box/squadmarine/engineert18
	name = "\improper T-18 equipment crate"
	desc = "A large case containing the T-18 carbine and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 13

/obj/item/storage/box/squadmarine/engineert18
	spawns_with = list(
		/obj/item/weapon/gun/rifle/standard_carbine/engineer,
		/obj/item/clothing/head/helmet/marine/tech,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/clothing/tie/storage/webbing,
		/obj/item/ammo_magazine/rifle/standard_carbine,
		/obj/item/ammo_magazine/rifle/standard_carbine,
		/obj/item/ammo_magazine/rifle/standard_carbine,
		/obj/item/clothing/mask/rebreather/scarf,
		/obj/item/tool/shovel/etool,
		/obj/item/explosive/plastique,
		/obj/item/explosive/plastique,
		/obj/item/cell/high,
		/obj/item/cell/high,
	)

/obj/item/storage/box/squadmarine/engineert90
	name = "\improper T-90 equipment crate"
	desc = "A large case containing the T-90 submachinegun and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 15

/obj/item/storage/box/squadmarine/engineert90
	spawns_with = list(
		/obj/item/weapon/gun/smg/standard_smg/nonstandard,
		/obj/item/clothing/head/helmet/marine/heavy,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/clothing/tie/storage/brown_vest,
		/obj/item/ammo_magazine/smg/standard_smg,
		/obj/item/ammo_magazine/smg/standard_smg,
		/obj/item/ammo_magazine/smg/standard_smg,
		/obj/item/ammo_magazine/smg/standard_smg,
		/obj/item/ammo_magazine/smg/standard_smg,
		/obj/item/clothing/mask/rebreather/scarf,
		/obj/item/tool/shovel/etool,
		/obj/item/explosive/plastique,
		/obj/item/explosive/plastique,
		/obj/item/cell/high,
		/obj/item/cell/high,
	)

/obj/item/storage/box/squadmarine/engineert35
	name = "\improper T-35 equipment crate"
	desc = "A large case containing the T-35 shotgun and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 11

/obj/item/storage/box/squadmarine/engineert35
	spawns_with = list(
		/obj/item/weapon/gun/shotgun/pump/t35/nonstandard,
		/obj/item/clothing/head/helmet/marine/heavy,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/clothing/tie/storage/brown_vest,
		/obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/clothing/mask/rebreather/scarf,
		/obj/item/tool/shovel/etool,
		/obj/item/explosive/plastique,
		/obj/item/explosive/plastique,
		/obj/item/cell/high,
		/obj/item/cell/high,
	)

/obj/item/storage/box/squadmarine/corpsmant90
	name = "\improper T-90 equipment crate"
	desc = "A large case containing the T-90 submachinegun and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 8

/obj/item/storage/box/squadmarine/corpsmant90
	spawns_with = list(
		/obj/item/weapon/gun/smg/standard_smg/nonstandard,
		/obj/item/clothing/tie/storage/brown_vest,
		/obj/item/ammo_magazine/smg/standard_smg,
		/obj/item/ammo_magazine/smg/standard_smg,
		/obj/item/ammo_magazine/smg/standard_smg,
		/obj/item/ammo_magazine/smg/standard_smg,
		/obj/item/ammo_magazine/smg/standard_smg,
		/obj/item/clothing/mask/rebreather/scarf,
	)

/obj/item/storage/box/squadmarine/corpsmant35
	name = "\improper T-35 equipment crate"
	desc = "A large case containing the T-35 shotgun and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 4

/obj/item/storage/box/squadmarine/corpsmant35
	spawns_with = list(
		/obj/item/weapon/gun/shotgun/pump/t35/nonstandard,
		/obj/item/clothing/tie/storage/brown_vest,
		/obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/clothing/mask/rebreather/scarf,
	)

/obj/item/storage/box/squadmarine/smartgunnert19
	name = "\improper T-19 equipment crate"
	desc = "A large case containing the T-19 machine pistol and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 8

/obj/item/storage/box/squadmarine/smartgunnert19
	spawns_with = list(
		/obj/item/weapon/gun/smg/standard_machinepistol,
		/obj/item/storage/pouch/magazine/smgfull,
		/obj/item/clothing/tie/storage/brown_vest,
		/obj/item/ammo_magazine/smg/standard_machinepistol,
		/obj/item/ammo_magazine/smg/standard_machinepistol,
		/obj/item/ammo_magazine/smg/standard_machinepistol,
		/obj/item/ammo_magazine/smg/standard_machinepistol,
		/obj/item/ammo_magazine/smg/standard_machinepistol,
		/obj/item/clothing/mask/rebreather/scarf,
	)

/obj/item/storage/box/squadmarine/smartgunnerm4a3
	name = "\improper M4A3 equipment crate"
	desc = "A large case containing the M4A3 pistol and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 10

/obj/item/storage/box/squadmarine/smartgunnerm4a3
	spawns_with = list(
		/obj/item/storage/belt/gun/pistol/m4a3/full,
		/obj/item/storage/pouch/magazine/pistol/large/full,
		/obj/item/clothing/tie/storage/brown_vest,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/pistol,
		/obj/item/clothing/mask/rebreather/scarf,
	)

// Equipped Squad marine roles' version of specialist kits

/obj/item/storage/box/squadmarine/demolitionist
	name = "\improper Demolitionist equipment crate"
	desc = "A large case containing light armor, a heavy-caliber antitank missile launcher, missiles, C4, detpacks, and claymore mines. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon_state = "rocket_case"
	storage_slots = 24

/obj/item/storage/box/squadmarine/demolitionist
	spawns_with = list(
		/obj/item/clothing/suit/storage/marine/M3T,
		/obj/item/clothing/head/helmet/marine/standard,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/weapon/gun/launcher/rocket/sadar,
		/obj/item/storage/large_holster/t19,
		/obj/item/weapon/gun/smg/standard_smg/nonstandard,
		/obj/item/ammo_magazine/rocket/sadar,
		/obj/item/ammo_magazine/rocket/sadar/,
		/obj/item/ammo_magazine/rocket/sadar/ap,
		/obj/item/ammo_magazine/rocket/sadar/ap,
		/obj/item/ammo_magazine/rocket/sadar/wp,
		/obj/item/ammo_magazine/rocket/sadar/wp,
		/obj/item/storage/pouch/explosive/detpack,
		/obj/item/explosive/mine,
		/obj/item/explosive/mine,
		/obj/item/clothing/tie/storage/brown_vest,
		/obj/item/ammo_magazine/smg/standard_smg,
		/obj/item/ammo_magazine/smg/standard_smg,
		/obj/item/ammo_magazine/smg/standard_smg,
		/obj/item/ammo_magazine/smg/standard_smg,
		/obj/item/ammo_magazine/smg/standard_smg,
		/obj/item/clothing/mask/rebreather/scarf,
	)

/obj/item/storage/box/squadmarine/sniper
	name = "\improper Sniper equipment"
	desc = "A large case containing your very own long-range sniper rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon_state = "sniper_case"
	storage_slots = 22

/obj/item/storage/box/squadmarine/sniper
	spawns_with = list(
		/obj/item/clothing/suit/storage/marine/sniper,
		/obj/item/clothing/head/helmet/marine/sniper,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/clothing/glasses/night/m42_night_goggles,
		/obj/item/weapon/gun/rifle/sniper/antimaterial,
		/obj/item/storage/belt/marine/antimaterial,
		/obj/item/ammo_magazine/sniper,
		/obj/item/storage/pouch/pistol/vp70,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/storage/backpack/marine/satchel/scout_cloak/sniper,
		/obj/item/bodybag/tarp,
		/obj/item/binoculars/tactical,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/clothing/tie/storage/webbing,
		/obj/item/explosive/grenade/cloakbomb,
		/obj/item/explosive/grenade/cloakbomb,
		/obj/item/explosive/grenade/cloakbomb,
		/obj/item/clothing/mask/rebreather/scarf,
	)

/obj/item/storage/box/squadmarine/scout
	name = "\improper Scout equipment"
	desc = "A large case containing Scout equipment; this one features the T-45 battle rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon_state = "sniper_case"
	storage_slots = 23

/obj/item/storage/box/squadmarine/scout
	spawns_with = list(
		/obj/item/clothing/suit/storage/marine/M3S,
		/obj/item/clothing/head/helmet/marine/scout,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/clothing/glasses/night/tx8,
		/obj/item/weapon/gun/rifle/tx8,
		/obj/item/storage/pouch/magazine/large/tx8full,
		/obj/item/storage/belt/marine/tx8,
		/obj/item/ammo_magazine/rifle/tx8,
		/obj/item/ammo_magazine/rifle/tx8,
		/obj/item/storage/backpack/marine/satchel/scout_cloak/scout,
		/obj/item/binoculars/tactical/scout,
		/obj/item/weapon/gun/pistol/vp70,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/motiondetector/scout,
		/obj/item/bodybag/tarp,
		/obj/item/clothing/tie/storage/webbing,
		/obj/item/explosive/grenade/cloakbomb,
		/obj/item/explosive/grenade/cloakbomb,
		/obj/item/explosive/grenade/cloakbomb,
		/obj/item/clothing/mask/rebreather/scarf,
	)

/obj/item/storage/box/squadmarine/tracker
	name = "\improper Scout equipment"
	desc = "A large case containing Tracker equipment; this one features the .410 lever action shotgun. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon_state = "sniper_case"
	storage_slots = 25

/obj/item/storage/box/squadmarine/tracker
	spawns_with = list(

		/obj/item/clothing/suit/storage/marine/M3S,
		/obj/item/clothing/head/helmet/marine/scout,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/clothing/glasses/thermal/m64_thermal_goggles,
		/obj/item/weapon/gun/shotgun/pump/lever/mbx900,
		/obj/item/storage/belt/shotgun,
		/obj/item/storage/pouch/shotgun,
		/obj/item/ammo_magazine/shotgun/mbx900/,
		/obj/item/ammo_magazine/shotgun/mbx900/,
		/obj/item/ammo_magazine/shotgun/mbx900/buckshot,
		/obj/item/ammo_magazine/shotgun/mbx900/buckshot,
		/obj/item/ammo_magazine/shotgun/mbx900/tracking,
		/obj/item/ammo_magazine/pistol/m1911,
		/obj/item/ammo_magazine/pistol/m1911,
		/obj/item/storage/backpack/marine/satchel/scout_cloak/scout,
		/obj/item/binoculars/tactical/scout,
		/obj/item/weapon/gun/pistol/m1911,
		/obj/item/motiondetector/scout,
		/obj/item/explosive/grenade/cloakbomb,
		/obj/item/explosive/grenade/cloakbomb,
		/obj/item/explosive/grenade/cloakbomb,
		/obj/item/bodybag/tarp,
		/obj/item/clothing/tie/storage/brown_vest,
		/obj/item/clothing/mask/rebreather/scarf,
	)

/obj/item/storage/box/squadmarine/pyro
	name = "\improper Pyrotechnician equipment"
	desc = "A large case containing Pyrotechnician equipment. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 22

/obj/item/storage/box/squadmarine/pyro
	spawns_with = list(
		/obj/item/clothing/suit/storage/marine/M35,
		/obj/item/clothing/head/helmet/marine/pyro,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/clothing/shoes/marine/pyro,
		/obj/item/ammo_magazine/flamer_tank/backtank,
		/obj/item/weapon/gun/flamer/marinestandard,
		/obj/item/attachable/magnetic_harness,
		/obj/item/storage/large_holster/t19,
		/obj/item/weapon/gun/smg/standard_smg/nonstandard,
		/obj/item/storage/pouch/magazine/large/t19full,
		/obj/item/ammo_magazine/flamer_tank/large,
		/obj/item/ammo_magazine/flamer_tank/large,
		/obj/item/ammo_magazine/flamer_tank/large,
		/obj/item/ammo_magazine/flamer_tank/large/B,
		/obj/item/ammo_magazine/flamer_tank/large/X,
		/obj/item/clothing/tie/storage/brown_vest,
		/obj/item/ammo_magazine/smg/standard_smg,
		/obj/item/ammo_magazine/smg/standard_smg,
		/obj/item/ammo_magazine/smg/standard_smg,
		/obj/item/ammo_magazine/smg/standard_smg,
		/obj/item/ammo_magazine/smg/standard_smg,
		/obj/item/clothing/mask/rebreather/scarf,
	)

/obj/item/storage/box/squadmarine/heavy_grenadier
	name = "\improper Heavy Grenadier case"
	desc = "A large case containing B17 Heavy Armor and a heavy-duty multi-shot grenade launcher, the Armat Systems M92. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 18

/obj/item/storage/box/squadmarine/heavy_grenadier
	spawns_with = list(
		/obj/item/storage/belt/grenade/b17,
		/obj/item/clothing/suit/storage/marine/B17,
		/obj/item/weapon/gun/launcher/m92,
		/obj/item/attachable/magnetic_harness,
		/obj/item/clothing/head/helmet/marine/grenadier,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/storage/box/visual/grenade/frag,
		/obj/item/storage/box/visual/grenade/frag,
		/obj/item/storage/box/visual/grenade/incendiary,
		/obj/item/storage/backpack/marine/standard,
		/obj/item/storage/backpack/marine/standard,
		/obj/item/storage/backpack/marine/standard,
		/obj/item/storage/backpack/marine/standard,
		/obj/item/storage/backpack/marine/standard,
		/obj/item/storage/pouch/explosive,
		/obj/item/clothing/tie/storage/brown_vest,
		/obj/item/clothing/mask/rebreather/scarf,
	)

/obj/item/storage/box/squadmarine/heavy_gunner
	name = "\improper Heavy Minigunner case"
	desc = "A large case containing B18 armor, munitions, and a goddamn minigun. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 19

/obj/item/storage/box/squadmarine/heavy_gunner
	spawns_with = list(
		/obj/item/clothing/gloves/marine/specialist,
		/obj/item/clothing/suit/storage/marine/specialist,
		/obj/item/clothing/head/helmet/marine/specialist,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/weapon/gun/minigun,
		/obj/item/belt_harness/marine,
		/obj/item/ammo_magazine/minigun,
		/obj/item/ammo_magazine/minigun,
		/obj/item/ammo_magazine/minigun,
		/obj/item/attachable/flashlight,
		/obj/item/storage/pouch/pistol/rt3,
		/obj/item/clothing/tie/storage/brown_vest,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/pistol,
		/obj/item/clothing/mask/rebreather/scarf,
	)

/obj/item/storage/box/squadmarine/squadleader
	name = "\improper Squad Leadeer equipment crate"
	desc = "A large case containing the T-12 assault rifle and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 7

/obj/item/storage/box/squadmarine/squadleader
	spawns_with = list(
		/obj/item/explosive/grenade/frag,
		/obj/item/explosive/grenade/frag,
		/obj/item/clothing/tie/storage/webbing,
		/obj/item/ammo_magazine/rifle/standard_assaultrifle,
		/obj/item/ammo_magazine/rifle/standard_assaultrifle,
		/obj/item/ammo_magazine/rifle/standard_assaultrifle,
		/obj/item/clothing/mask/rebreather/scarf,
	)
