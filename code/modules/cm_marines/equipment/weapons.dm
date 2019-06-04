

/obj/item/storage/box/m56_system
	name = "\improper M56 smartgun system"
	desc = "A large case containing the full M56 Smartgun System. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "smartgun_case"
	w_class = 5
	storage_slots = 4
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

/obj/item/storage/box/m56_system/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/glasses/night/m56_goggles(src)
	new /obj/item/weapon/gun/smartgun(src)
	new /obj/item/smartgun_powerpack(src)
	new /obj/item/clothing/suit/storage/marine/smartgunner(src)

/obj/item/smartgun_powerpack
	name = "\improper M56 powerpack"
	desc = "A heavy reinforced backpack with support equipment, power cells, and spare rounds for the M56 Smartgun System.\nClick the icon in the top left to reload your M56."
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "powerpack"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = 5.0
	var/obj/item/cell/pcell = null
	var/rounds_remaining = 500
	var/rounds_max = 500
	actions_types = list(/datum/action/item_action/toggle)
	var/reloading = FALSE

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
	var/reload_duration = 50
	var/obj/screen/ammo/A = user.hud_used.ammo
	if(!automatic)
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.smartgun>0)
			reload_duration = max(reload_duration - 10*user.mind.cm_skills.smartgun,30)
		if(do_after(user,reload_duration, TRUE, src, BUSY_ICON_GENERIC))
			reload(user, mygun)
			A.update_hud(user)
		else
			to_chat(user, "Your reloading was interrupted!")
			playsound(src,'sound/machines/buzz-two.ogg', 25, 1)
			reloading = FALSE
	else
		if(autoload_check(user, reload_duration, mygun, src))
			reload(user, mygun, TRUE)
			A.update_hud(user)
		else
			to_chat(user, "The automated reload process was interrupted!")
			playsound(src,'sound/machines/buzz-two.ogg', 25, 1)
			reloading = FALSE
	return TRUE

/obj/item/smartgun_powerpack/attack_hand(mob/user)
	if(user.get_inactive_held_item() != src)
		return ..()
	if(QDELETED(pcell))
		to_chat(user, "There is no cell in the [src].")
		return
	user.put_in_hands(pcell)
	playsound(src,'sound/machines/click.ogg', 25, 1)
	to_chat(user, "You take out the [pcell] out of the [src].")
	pcell = null

/obj/item/smartgun_powerpack/attackby(obj/item/I, mob/user, params)
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

/obj/item/smartgun_powerpack/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 1)
		to_chat(user, "A small gauge in the corner reads: Ammo: [rounds_remaining] / [rounds_max]. [pcell ? "Charge: [pcell.charge] / [pcell.maxcharge].":""]")

/obj/item/smartgun_powerpack/proc/reload(mob/user, obj/item/weapon/gun/smartgun/mygun, automatic = FALSE)
	pcell.charge -= 50
	if(!mygun.current_mag)
		var/obj/item/ammo_magazine/internal/smartgun/A = new(mygun)
		mygun.current_mag = A

	var/rounds_to_reload = min(rounds_remaining, (mygun.current_mag.max_rounds - mygun.current_mag.current_rounds)) //Get the smaller value.

	mygun.current_mag.current_rounds += rounds_to_reload
	rounds_remaining -= rounds_to_reload

	if(!automatic)
		to_chat(user, "You finish loading [rounds_to_reload] shells into the M56 Smartgun. Ready to rumble!")
	else
		to_chat(user, "The powerpack servos finish loading [rounds_to_reload] shells into the M56 Smartgun. Ready to rumble!")
	playsound(user, 'sound/weapons/unload.ogg', 25, 1)

	reloading = FALSE
	return TRUE

/obj/item/smartgun_powerpack/proc/autoload_check(mob/user, delay, obj/item/weapon/gun/smartgun/mygun, obj/item/smartgun_powerpack/powerpack, numticks = 5)
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
	w_class = 5
	storage_slots = 3
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

/obj/item/storage/box/heavy_armor/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/gloves/marine/specialist(src)
	new /obj/item/clothing/suit/storage/marine/specialist(src)
	new /obj/item/clothing/head/helmet/marine/specialist(src)

/obj/item/storage/box/m42c_system
	name = "\improper M42A scoped rifle system (recon set)"
	desc = "A large case containing your very own long-range sniper rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = 5
	storage_slots = 12
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

/obj/item/storage/box/m42c_system/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/storage/marine/sniper(src)
	new /obj/item/clothing/glasses/night/m42_night_goggles(src)
	new /obj/item/ammo_magazine/sniper(src)
	new /obj/item/ammo_magazine/sniper/incendiary(src)
	new /obj/item/ammo_magazine/sniper/flak(src)
	new /obj/item/binoculars/tactical(src)
	new /obj/item/storage/backpack/marine/smock(src)
	new /obj/item/weapon/gun/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/weapon/gun/rifle/sniper/M42A(src)
	new /obj/item/bodybag/tarp(src)
	switch(SSmapping.config.map_name)
		if(MAP_ICE_COLONY)
			new /obj/item/clothing/head/helmet/marine(src)
		else
			new /obj/item/clothing/head/helmet/durag(src)
			new /obj/item/facepaint/sniper(src)

/obj/item/storage/box/m42c_system_Jungle
	name = "\improper M42A scoped rifle system (marksman set)"
	desc = "A large case containing your very own long-range sniper rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = 5
	storage_slots = 9
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

/obj/item/storage/box/m42c_system_Jungle/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/storage/marine/sniper/jungle(src)
	new /obj/item/clothing/glasses/m42_goggles(src)
	new /obj/item/clothing/head/helmet/durag/jungle(src)
	new /obj/item/ammo_magazine/sniper(src)
	new /obj/item/ammo_magazine/sniper(src)
	new /obj/item/ammo_magazine/sniper/incendiary(src)
	new /obj/item/weapon/gun/rifle/sniper/M42A/jungle(src)
	switch(SSmapping.config.map_name)
		if(MAP_ICE_COLONY)
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
	w_class = 5
	storage_slots = 2
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

/obj/item/storage/box/grenade_system/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/launcher/m92(src)
	new /obj/item/storage/belt/grenade/b18(src)


/obj/item/storage/box/rocket_system
	name = "\improper M5 RPG crate"
	desc = "A large case containing a heavy-caliber antitank missile launcher and missiles. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "rocket_case"
	w_class = 5
	storage_slots = 6
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

/obj/item/storage/box/rocket_system/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/launcher/rocket(src)
	new /obj/item/ammo_magazine/rocket(src)
	new /obj/item/ammo_magazine/rocket(src)
	new /obj/item/ammo_magazine/rocket/ap(src)
	new /obj/item/ammo_magazine/rocket/ap(src)
	new /obj/item/ammo_magazine/rocket/wp(src)





////////////////// new specialist systems ///////////////////////////:


/obj/item/storage/box/spec
	var/spec_set

/obj/item/storage/box/spec/demolitionist
	name = "\improper Demolitionist equipment crate"
	desc = "A large case containing light armor, a heavy-caliber antitank missile launcher, missiles, C4, detpacks, and claymore mines. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "rocket_case"
	spec_set = "demolitionist"
	w_class = 5
	storage_slots = 16
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

/obj/item/storage/box/spec/demolitionist/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/storage/marine/M3T(src)
	new /obj/item/clothing/head/helmet/marine(src)
	new /obj/item/weapon/gun/launcher/rocket(src)
	new /obj/item/ammo_magazine/rocket(src)
	new /obj/item/ammo_magazine/rocket(src)
	new /obj/item/ammo_magazine/rocket/ap(src)
	new /obj/item/ammo_magazine/rocket/ap(src)
	new /obj/item/ammo_magazine/rocket/wp(src)
	new /obj/item/ammo_magazine/rocket/wp(src)
	new /obj/item/explosive/mine(src)
	new /obj/item/explosive/mine(src)
	new /obj/item/radio/detpack(src)
	new /obj/item/radio/detpack(src)
	new /obj/item/radio/detpack(src)
	new /obj/item/radio/detpack(src)
	new /obj/item/assembly/signaler(src)



/obj/item/storage/box/spec/sniper
	name = "\improper Sniper equipment"
	desc = "A large case containing your very own long-range sniper rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = 5
	storage_slots = 15
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null
	spec_set = "sniper"

/obj/item/storage/box/spec/sniper/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/storage/marine/sniper(src)
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
	new /obj/item/weapon/gun/rifle/sniper/M42A(src)
	new /obj/item/explosive/grenade/cloakbomb(src)
	new /obj/item/explosive/grenade/cloakbomb(src)
	new /obj/item/explosive/grenade/cloakbomb(src)
	new /obj/item/bodybag/tarp(src)
	switch(SSmapping.config.map_name)
		if(MAP_ICE_COLONY)
			new /obj/item/clothing/head/helmet/marine(src)
		else
			new /obj/item/clothing/head/helmet/durag(src)
			new /obj/item/facepaint/sniper(src)

/obj/item/storage/box/spec/scout
	name = "\improper Scout equipment"
	desc = "A large case containing Scout equipment; this one features the M4RA battle rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = 5
	storage_slots = 22
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null
	spec_set = "scout battle rifle"

/obj/item/storage/box/spec/scout/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/storage/marine/M3S(src)
	new /obj/item/clothing/head/helmet/marine/scout(src)
	new /obj/item/clothing/glasses/night/M4RA(src)
	new /obj/item/ammo_magazine/rifle/m4ra(src)
	new /obj/item/ammo_magazine/rifle/m4ra(src)
	new /obj/item/ammo_magazine/rifle/m4ra(src)
	new /obj/item/ammo_magazine/rifle/m4ra(src)
	new /obj/item/ammo_magazine/rifle/m4ra/incendiary(src)
	new /obj/item/ammo_magazine/rifle/m4ra/incendiary(src)
	new /obj/item/ammo_magazine/rifle/m4ra/impact(src)
	new /obj/item/ammo_magazine/rifle/m4ra/impact(src)
	new /obj/item/binoculars/tactical/scout(src)
	new /obj/item/weapon/gun/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/weapon/gun/rifle/m4ra(src)
	new /obj/item/storage/backpack/marine/satchel/scout_cloak/scout(src)
	new /obj/item/motiondetector/scout(src)
	new /obj/item/explosive/grenade/cloakbomb(src)
	new /obj/item/explosive/grenade/cloakbomb(src)
	new /obj/item/explosive/grenade/cloakbomb(src)
	new /obj/item/bodybag/tarp(src)


/obj/item/storage/box/spec/scoutshotgun
	name = "\improper Scout equipment"
	desc = "A large case containing Scout equipment; this one features the ZX-76 assault shotgun. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = 5
	storage_slots = 21
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null
	spec_set = "scout shotgun"

/obj/item/storage/box/spec/scoutshotgun/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/storage/marine/M3S(src)
	new /obj/item/clothing/head/helmet/marine/scout(src)
	new /obj/item/clothing/glasses/night/M4RA(src)
	new /obj/item/binoculars/tactical/scout(src)
	new /obj/item/weapon/gun/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/weapon/gun/shotgun/merc/scout(src)
	new /obj/item/ammo_magazine/shotgun/incendiary(src)
	new /obj/item/ammo_magazine/shotgun/incendiary(src)
	new /obj/item/storage/backpack/marine/satchel/scout_cloak/scout(src)
	new /obj/item/motiondetector/scout(src)
	new /obj/item/explosive/grenade/cloakbomb(src)
	new /obj/item/explosive/grenade/cloakbomb(src)
	new /obj/item/explosive/grenade/cloakbomb(src)


/obj/item/storage/box/spec/pyro
	name = "\improper Pyrotechnician equipment"
	desc = "A large case containing Pyrotechnician equipment. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "armor_case"
	w_class = 5
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
	new /obj/item/storage/backpack/marine/engineerpack/flamethrower(src)
	new /obj/item/weapon/gun/flamer/M240T(src)
	new /obj/item/ammo_magazine/flamer_tank/large(src)
	new /obj/item/ammo_magazine/flamer_tank/large(src)
	new /obj/item/ammo_magazine/flamer_tank/large/B(src)
	new /obj/item/ammo_magazine/flamer_tank/large/X(src)



/obj/item/storage/box/spec/heavy_grenadier
	name = "\improper Heavy Grenadier case"
	desc = "A large case containing B18 Heavy Armor and a heavy-duty multi-shot grenade launcher, the Armat Systems M92. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "grenade_case"
	w_class = 5
	storage_slots = 6
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null
	spec_set = "heavy gunner"

/obj/item/storage/box/spec/heavy_grenadier/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/launcher/m92(src)
	new /obj/item/storage/belt/grenade/b18(src)
	new /obj/item/clothing/gloves/marine/specialist(src)
	new /obj/item/clothing/suit/storage/marine/specialist(src)
	new /obj/item/clothing/head/helmet/marine/specialist(src)


/obj/item/storage/box/spec/heavy_gunner
	name = "\improper Heavy Minigunner case"
	desc = "A large case containing B18 armor, munitions, and a goddamn minigun. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "rocket_case"
	spec_set = "heavy grenadier"
	w_class = 5
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
	new /obj/item/ammo_magazine/minigun(src)
	new /obj/item/ammo_magazine/minigun(src)
	new /obj/item/ammo_magazine/minigun(src)

/obj/item/spec_kit //For events/WO, allowing the user to choose a specalist kit
	name = "specialist kit"
	desc = "A paper box. Open it and get a specialist kit."
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "deliverycrate"

/obj/item/spec_kit/attack_self(mob/user as mob)
	var/choice = input(user, "Please pick a specalist kit!","Selection") in list("Pyro","Heavy Armor (Grenadier)","Heavy Armor (Minigun)","Sniper","Scout (Battle Rifle)","Scout (Shotgun)","Demo")
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
		if("Scout (Shotgun)")
			S = /obj/item/storage/box/spec/scoutshotgun
		if("Demo")
			S = /obj/item/storage/box/spec/demolitionist
	new S(loc)
	user.put_in_hands(S)
	qdel()

/obj/item/spec_kit/attack_self(mob/user)
	var/selection = input(user, "Pick your equipment", "Specialist Kit Selection") as null|anything in list("Pyro","Grenadier","Sniper","Scout","Demo")
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
	qdel(src)


