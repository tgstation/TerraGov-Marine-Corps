

/obj/item/storage/box/t29_system
	name = "\improper T-29 smart machinegun system"
	desc = "A large case containing the full T-29 Machinegun System. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "smartgun_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 5
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

/obj/item/storage/box/t29_system/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/glasses/night/m56_goggles(src)
	new /obj/item/weapon/gun/rifle/standard_smartmachinegun(src)
	new /obj/item/ammo_magazine/standard_smartmachinegun(src)
	new /obj/item/ammo_magazine/standard_smartmachinegun(src)
	new /obj/item/ammo_magazine/standard_smartmachinegun(src)

/obj/item/storage/box/t25_system
	name = "\improper T25 smart rifle system"
	desc = "A large case containing the full T-25 Rifle System. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "smartgun_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 5
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

/obj/item/storage/box/t25_system/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/glasses/night/m56_goggles(src)
	new /obj/item/weapon/gun/rifle/standard_smartrifle(src)
	new /obj/item/storage/belt/marine/t25(src)
	new /obj/item/ammo_magazine/rifle/standard_smartrifle(src)

/obj/item/minigun_powerpack
	name = "\improper T-100 powerpack"
	desc = "A heavy reinforced backpack with support equipment, power cells, and spare rounds for the T-100 Minigun System.\nClick the icon in the top left to reload your M56."
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "powerpack"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	var/obj/item/cell/pcell = null
	var/rounds_remaining = 500
	var/rounds_max = 500
	actions_types = list(/datum/action/item_action/toggle)
	var/reloading = FALSE
	flags_item_map_variant = (ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_PRISON_VARIANT)

/obj/item/minigun_powerpack/Initialize()
	. = ..()
	pcell = new /obj/item/cell(src)

/obj/item/minigun_powerpack/attack_self(mob/living/carbon/human/user, automatic = FALSE)
	if(!istype(user) || user.incapacitated())
		return FALSE

	var/obj/item/weapon/gun/minigun/mygun = user.get_active_held_item()

	if(!istype(mygun))
		to_chat(user, "You must be holding an T-100 Minigun to begin the reload process.")
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
		user.visible_message("[user.name] begins feeding an ammo belt into the T-100 Minigun.","You begin feeding a fresh ammo belt into the T-100 Minigun. Don't move or you'll be interrupted.")
	else
		user.visible_message("[user.name]'s powerpack servos begin automatically feeding an ammo belt into the T-100 Minigun.","The powerpack servos begin automatically feeding a fresh ammo belt into the T-100 Minigun.")
	var/reload_duration = 5 SECONDS
	if(automatic)
		if(!autoload_check(user, reload_duration, mygun, src) || !pcell)
			to_chat(user, "The automated reload process was interrupted!")
			playsound(src,'sound/machines/buzz-two.ogg', 25, TRUE)
			reloading = FALSE
			return TRUE
		reload(user, mygun, TRUE)
		user.hud_used.update_ammo_hud(user, src)
		return TRUE
	if(user.skills.getRating("firearms") > 0)
		reload_duration = max(reload_duration - 1 SECONDS * user.skills.getRating("firearms"), 3 SECONDS)
	if(!do_after(user, reload_duration, TRUE, src, BUSY_ICON_GENERIC) || !pcell)
		to_chat(user, "Your reloading was interrupted!")
		playsound(src,'sound/machines/buzz-two.ogg', 25, TRUE)
		reloading = FALSE
		return TRUE
	reload(user, mygun)
	user.hud_used.update_ammo_hud(user, src)
	return TRUE

/obj/item/minigun_powerpack/attack_hand(mob/living/user)
	if(user.get_inactive_held_item() != src)
		return ..()
	if(QDELETED(pcell))
		to_chat(user, "There is no cell in the [src].")
		return
	user.put_in_hands(pcell)
	playsound(src,'sound/machines/click.ogg', 25, 1)
	to_chat(user, "You take out the [pcell] out of the [src].")
	pcell = null

/obj/item/minigun_powerpack/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/cell))
		var/obj/item/cell/C = I

		if(!QDELETED(pcell))
			to_chat(user, "There already is a cell in the [src].")
			return

		if(!user.transferItemToLoc(C, src))
			return

		pcell = C
		user.visible_message("[user] puts a new power cell in the [src].", "You put a new power cell in the [src] containing [pcell.charge] charge.")
		playsound(src,'sound/machines/click.ogg', 25, 1)

/obj/item/minigun_powerpack/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 1)
		to_chat(user, "A small gauge in the corner reads: Ammo: [rounds_remaining] / [rounds_max]. [pcell ? "Charge: [pcell.charge] / [pcell.maxcharge].":""]")

/obj/item/minigun_powerpack/proc/reload(mob/user, obj/item/weapon/gun/minigun/mygun, automatic = FALSE)
	pcell.charge -= 50
	if(!mygun.current_mag)
		var/obj/item/ammo_magazine/internal/minigun/A = new(mygun)
		mygun.current_mag = A

	var/rounds_to_reload = min(rounds_remaining, (mygun.current_mag.max_rounds - mygun.current_mag.current_rounds)) //Get the smaller value.

	mygun.current_mag.current_rounds += rounds_to_reload
	rounds_remaining -= rounds_to_reload

	if(!automatic)
		to_chat(user, "You finish loading [rounds_to_reload] shells into the T-100 Minigun. Ready to rumble!")
	else
		to_chat(user, "The powerpack servos finish loading [rounds_to_reload] shells into the T-100 Minigun. Ready to rumble!")
	playsound(user, 'sound/weapons/guns/interact/minigun_unload.ogg', 25, 1)

	reloading = FALSE
	return TRUE

/obj/item/minigun_powerpack/proc/autoload_check(mob/user, delay, obj/item/weapon/gun/minigun/mygun, obj/item/minigun_powerpack/powerpack, numticks = 5)
	if(!istype(user) || delay <= 0) return FALSE

	var/mob/living/carbon/human/L
	if(ishuman(user)) L = user

	var/delayfraction = round(delay/numticks)
	. = TRUE
	for(var/i = 0 to numticks)
		sleep(delayfraction)
		if(!user)
			. = FALSE
			break
		if(!(L.s_store == mygun) && !(user.get_active_held_item() == mygun) && !(user.get_inactive_held_item() == mygun) || !(L.back == powerpack)) //power pack and gun aren't where they should be.
			. = FALSE
			break

/obj/item/minigun_powerpack/snow
	icon_state = "s_powerpack"

/obj/item/minigun_powerpack/fancy
	icon_state = "powerpackw"

/obj/item/minigun_powerpack/merc
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

/obj/item/storage/box/recoilless_system/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/launcher/rocket/recoillessrifle(src)
	new /obj/item/ammo_magazine/rocket/recoilless(src)
	new /obj/item/ammo_magazine/rocket/recoilless(src)
	new /obj/item/ammo_magazine/rocket/recoilless/light(src)
	new /obj/item/ammo_magazine/rocket/recoilless/light(src)
	new /obj/item/storage/backpack/rpg(src)






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
	desc = "A large case containing Scout equipment; this one features the TX-8 battle rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
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
	new /obj/item/minigun_powerpack(src)


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
	desc = "A large case containing the T-12 assault rifle, medium armor and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
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
	new /obj/item/clothing/tie/storage/webbing(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

/obj/item/storage/box/squadmarine/pointman
	name = "\improper Pointman equipment crate"
	desc = "A large case containing the T-18 carbine, T-35 shotgun, light armor and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
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
	new /obj/item/clothing/tie/storage/webbing(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

/obj/item/storage/box/squadmarine/autorifleman
	name = "\improper Automatic Rifleman equipment crate"
	desc = "A large case containing the T-42 light machine gun, TP-14 pistol, heavy armor and helmet as well as equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
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
	desc = "A large case containing the T-37 designated marksman rifle, T-64 battle rifle, integrated storage armor as well as equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
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
	new /obj/item/clothing/tie/storage/webbing(src)
	new /obj/item/ammo_magazine/rifle/standard_br(src)
	new /obj/item/ammo_magazine/rifle/standard_br(src)
	new /obj/item/ammo_magazine/rifle/standard_br(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

/obj/item/storage/box/squadmarine/breacher
	name = "\improper Breacher equipment crate"
	desc = "A large case containing the T-90 submachinegun, light armor, heavy helmet as well as equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
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
	new /obj/item/storage/large_holster/blade/machete/full(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

/obj/item/storage/box/squadmarine/engineert12
	name = "\improper T-12 equipment crate"
	desc = "A large case containing the T-12 assault rifle and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 13

/obj/item/storage/box/squadmarine/engineert12/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/rifle/standard_assaultrifle/engineer(src)
	new /obj/item/clothing/head/modular/marine/m10x(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/clothing/tie/storage/webbing(src)
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
	name = "\improper T-18 equipment crate"
	desc = "A large case containing the T-18 carbine and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 13

/obj/item/storage/box/squadmarine/engineert18/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/rifle/standard_carbine/engineer(src)
	new /obj/item/clothing/head/helmet/marine/tech(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/clothing/tie/storage/webbing(src)
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
	name = "\improper T-90 equipment crate"
	desc = "A large case containing the T-90 submachinegun and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 15

/obj/item/storage/box/squadmarine/engineert90/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/smg/standard_smg/nonstandard(src)
	new /obj/item/clothing/head/helmet/marine/heavy(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/clothing/tie/storage/brown_vest(src)
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
	name = "\improper T-35 equipment crate"
	desc = "A large case containing the T-35 shotgun and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 11

/obj/item/storage/box/squadmarine/engineert35/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/shotgun/pump/t35/nonstandard(src)
	new /obj/item/clothing/head/helmet/marine/heavy(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/reagent_containers/food/snacks/enrg_bar(src)
	new /obj/item/clothing/tie/storage/brown_vest(src)
	new /obj/item/ammo_magazine/shotgun/buckshot(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)
	new /obj/item/tool/shovel/etool(src)
	new /obj/item/explosive/plastique(src)
	new /obj/item/explosive/plastique(src)
	new /obj/item/cell/high(src)
	new /obj/item/cell/high(src)

/obj/item/storage/box/squadmarine/corpsmant90
	name = "\improper T-90 equipment crate"
	desc = "A large case containing the T-90 submachinegun and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 8

/obj/item/storage/box/squadmarine/corpsmant90/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/smg/standard_smg/nonstandard(src)
	new /obj/item/clothing/tie/storage/brown_vest(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

/obj/item/storage/box/squadmarine/corpsmant35
	name = "\improper T-35 equipment crate"
	desc = "A large case containing the T-35 shotgun and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 4

/obj/item/storage/box/squadmarine/corpsmant35/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/shotgun/pump/t35/nonstandard(src)
	new /obj/item/clothing/tie/storage/brown_vest(src)
	new /obj/item/ammo_magazine/shotgun/buckshot(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

/obj/item/storage/box/squadmarine/smartgunnert19
	name = "\improper T-19 equipment crate"
	desc = "A large case containing the T-19 machine pistol and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 8

/obj/item/storage/box/squadmarine/smartgunnert19/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/smg/standard_machinepistol(src)
	new /obj/item/storage/pouch/magazine/smgfull(src)
	new /obj/item/clothing/tie/storage/brown_vest(src)
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
	new /obj/item/clothing/tie/storage/brown_vest(src)
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
	new /obj/item/storage/large_holster/t19(src)
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
	new /obj/item/clothing/tie/storage/brown_vest(src)
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
	new /obj/item/clothing/tie/storage/webbing(src)
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
	new /obj/item/clothing/tie/storage/webbing(src)
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
	new /obj/item/clothing/tie/storage/brown_vest(src)
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
	new /obj/item/storage/large_holster/t19(src)
	new /obj/item/weapon/gun/smg/standard_smg/nonstandard(src)
	new /obj/item/storage/pouch/magazine/large/t19full(src)
	new /obj/item/ammo_magazine/flamer_tank/large(src)
	new /obj/item/ammo_magazine/flamer_tank/large(src)
	new /obj/item/ammo_magazine/flamer_tank/large(src)
	new /obj/item/ammo_magazine/flamer_tank/large/X(src)
	new /obj/item/clothing/tie/storage/brown_vest(src)
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
	new /obj/item/clothing/tie/storage/brown_vest(src)
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
	new /obj/item/minigun_powerpack(src)
	new /obj/item/minigun_powerpack(src)
	new /obj/item/minigun_powerpack(src)
	new /obj/item/attachable/flashlight(src)
	new /obj/item/storage/pouch/pistol/rt3(src)
	new /obj/item/clothing/tie/storage/brown_vest(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)

/obj/item/storage/box/squadmarine/squadleader
	name = "\improper Squad Leadeer equipment crate"
	desc = "A large case containing the T-12 assault rifle and equipment relating to it. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 7

/obj/item/storage/box/squadmarine/squadleader/Initialize(mapload, ...)
	. = ..()
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/clothing/tie/storage/webbing(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/clothing/mask/rebreather/scarf(src)
