/*
 * Backpack
 */

/obj/item/storage/backpack
	name = "backpack"
	desc = "You wear this on your back and put items into it."
	icon_state = "backpack"
	w_class = 4
	flags_equip_slot = SLOT_BACK	//ERROOOOO
	max_w_class = 3
	storage_slots = null
	max_storage_space = 21
	var/worn_accessible = FALSE //whether you can access its content while worn on the back

/obj/item/storage/backpack/attack_hand(mob/user)
	if(!worn_accessible && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.back == src)
/*			if(user.drop_inv_item_on_ground(src))
				pickup(user)
				add_fingerprint(user)
				if(!user.put_in_active_hand(src))
					dropped(user)
*/
			H << "<span class='notice'>You can't look in [src] while it's on your back.</span>"
			return
	..()

/obj/item/storage/backpack/attackby(obj/item/W, mob/user)
/*	if(!worn_accessible && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.back == src)
			H << "<span class='notice'>You can't access [src] while it's on your back.</span>"
			return TRUE
*/
	if (use_sound)
		playsound(src.loc, src.use_sound, 15, 1, 6)
	..()

/obj/item/storage/backpack/mob_can_equip(M as mob, slot)
	if (!..())
		return 0

	if (!uniform_restricted)
		return 1

	if (!ishuman(M))
		return 0

	var/mob/living/carbon/human/H = M
	var/list/equipment = list(H.wear_suit, H.w_uniform, H.shoes, H.belt, H.gloves, H.glasses, H.head, H.wear_ear, H.wear_id, H.r_store, H.l_store, H.s_store)

	for (var/type in uniform_restricted)
		if (!(locate(type) in equipment))
			H << "<span class='warning'>You must be wearing [initial(type:name)] to equip [name]!"
			return 0
	return 1

/obj/item/storage/backpack/equipped(mob/user, slot)
	if(slot == WEAR_BACK)
		mouse_opacity = 2 //so it's easier to click when properly equipped.
		if(use_sound)
			playsound(loc, use_sound, 15, 1, 6)
		if(!worn_accessible && user.s_active == src) //currently looking into the backpack
			close(user)
	..()

/obj/item/storage/backpack/dropped(mob/user)
	mouse_opacity = initial(mouse_opacity)
	..()


/obj/item/storage/backpack/open(mob/user)
	if(!worn_accessible && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.back == src)
			H << "<span class='notice'>You can't access [src] while it's on your back.</span>"
			return
	..()

/*
 * Backpack Types
 */

/obj/item/storage/backpack/holding
	name = "bag of holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	origin_tech = "bluespace=4"
	icon_state = "holdingpack"
	max_w_class = 4
	max_storage_space = 28

	attackby(obj/item/W as obj, mob/user as mob)
		if(crit_fail)
			user << "\red The Bluespace generator isn't working."
			return
		if(istype(W, /obj/item/storage/backpack/holding) && !W.crit_fail)
			user << "\red The Bluespace interfaces of the two devices conflict and malfunction."
			cdel(W)
			return
		..()

	proc/failcheck(mob/user as mob)
		if (prob(src.reliability)) return 1 //No failure
		if (prob(src.reliability))
			user << "\red The Bluespace portal resists your attempt to add another item." //light failure
		else
			user << "\red The Bluespace generator malfunctions!"
			for (var/obj/O in src.contents) //it broke, delete what was in it
				cdel(O)
			crit_fail = 1
			icon_state = "brokenpack"


/obj/item/storage/backpack/santabag
	name = "Santa's Gift Bag"
	desc = "Space Santa uses this to deliver toys to all the nice children in space in Christmas! Wow, it's pretty big!"
	icon_state = "giftbag0"
	item_state = "giftbag"
	w_class = 4.0
	storage_slots = null
	max_w_class = 3
	max_storage_space = 400 // can store a ton of shit!

/obj/item/storage/backpack/cultpack
	name = "trophy rack"
	desc = "It's useful for both carrying extra gear and proudly declaring your insanity."
	icon_state = "cultpack"

/obj/item/storage/backpack/clown
	name = "Giggles von Honkerton"
	desc = "It's a backpack made by Honk! Co."
	icon_state = "clownpack"

/obj/item/storage/backpack/medic
	name = "medical backpack"
	desc = "It's a backpack especially designed for use in a sterile environment."
	icon_state = "medicalpack"

/obj/item/storage/backpack/security
	name = "security backpack"
	desc = "It's a very robust backpack."
	icon_state = "securitypack"

/obj/item/storage/backpack/captain
	name = "captain's backpack"
	desc = "It's a special backpack made exclusively for officers."
	icon_state = "captainpack"

/obj/item/storage/backpack/industrial
	name = "industrial backpack"
	desc = "It's a tough backpack for the daily grind of station life."
	icon_state = "engiepack"

/obj/item/storage/backpack/toxins
	name = "laboratory backpack"
	desc = "It's a light backpack modeled for use in laboratories and other scientific institutions."
	icon_state = "toxpack"

/obj/item/storage/backpack/hydroponics
	name = "herbalist's backpack"
	desc = "It's a green backpack with many pockets to store plants and tools in."
	icon_state = "hydpack"

/obj/item/storage/backpack/genetics
	name = "geneticist backpack"
	desc = "It's a backpack fitted with slots for diskettes and other workplace tools."
	icon_state = "genpack"

/obj/item/storage/backpack/virology
	name = "sterile backpack"
	desc = "It's a sterile backpack able to withstand different pathogens from entering its fabric."
	icon_state = "viropack"

/obj/item/storage/backpack/chemistry
	name = "chemistry backpack"
	desc = "It's an orange backpack which was designed to hold beakers, pill bottles and bottles."
	icon_state = "chempack"

/*
 * Satchel Types
 */

/obj/item/storage/backpack/satchel
	name = "leather satchel"
	desc = "It's a very fancy satchel made with fine leather."
	icon_state = "satchel"
	worn_accessible = TRUE
	storage_slots = null
	max_storage_space = 15

/obj/item/storage/backpack/satchel/withwallet
	New()
		..()
		new /obj/item/storage/wallet/random( src )

/obj/item/storage/backpack/satchel/norm
	name = "satchel"
	desc = "A trendy looking satchel."
	icon_state = "satchel-norm"

/obj/item/storage/backpack/satchel/eng
	name = "industrial satchel"
	desc = "A tough satchel with extra pockets."
	icon_state = "satchel-eng"

/obj/item/storage/backpack/satchel/med
	name = "medical satchel"
	desc = "A sterile satchel used in medical departments."
	icon_state = "satchel-med"

/obj/item/storage/backpack/satchel/vir
	name = "virologist satchel"
	desc = "A sterile satchel with virologist colours."
	icon_state = "satchel-vir"

/obj/item/storage/backpack/satchel/chem
	name = "chemist satchel"
	desc = "A sterile satchel with chemist colours."
	icon_state = "satchel-chem"

/obj/item/storage/backpack/satchel/gen
	name = "geneticist satchel"
	desc = "A sterile satchel with geneticist colours."
	icon_state = "satchel-gen"

/obj/item/storage/backpack/satchel/tox
	name = "scientist satchel"
	desc = "Useful for holding research materials."
	icon_state = "satchel-tox"

/obj/item/storage/backpack/satchel/sec
	name = "security satchel"
	desc = "A robust satchel for security related needs."
	icon_state = "satchel-sec"

/obj/item/storage/backpack/satchel/hyd
	name = "hydroponics satchel"
	desc = "A green satchel for plant related work."
	icon_state = "satchel_hyd"

/obj/item/storage/backpack/satchel/cap
	name = "captain's satchel"
	desc = "An exclusive satchel for officers."
	icon_state = "satchel-cap"

//ERT backpacks.
/obj/item/storage/backpack/ert
	name = "emergency response team backpack"
	desc = "A spacious backpack with lots of pockets, used by members of the Emergency Response Team."
	icon_state = "ert_commander"

//Commander
/obj/item/storage/backpack/ert/commander
	name = "emergency response team commander backpack"
	desc = "A spacious backpack with lots of pockets, worn by the commander of a Emergency Response Team."

//Security
/obj/item/storage/backpack/ert/security
	name = "emergency response team security backpack"
	desc = "A spacious backpack with lots of pockets, worn by security members of a Emergency Response Team."
	icon_state = "ert_security"

//Engineering
/obj/item/storage/backpack/ert/engineer
	name = "emergency response team engineer backpack"
	desc = "A spacious backpack with lots of pockets, worn by engineering members of a Emergency Response Team."
	icon_state = "ert_engineering"

//Medical
/obj/item/storage/backpack/ert/medical
	name = "emergency response team medical backpack"
	desc = "A spacious backpack with lots of pockets, worn by medical members of a Emergency Response Team."
	icon_state = "ert_medical"





//==========================// MARINE BACKPACKS\\================================\\
//=======================================================================\\

/obj/item/storage/backpack/marine
	name = "\improper lightweight IMP backpack"
	desc = "The standard-issue pack of the USCM forces. Designed to slug gear into the battlefield."
	icon_state = "marinepack"
	var/has_gamemode_skin = TRUE

	New()
		if(has_gamemode_skin)
			select_gamemode_skin(type)
		..()

/obj/item/storage/backpack/marine/medic
	name = "\improper USCM medic backpack"
	desc = "The standard-issue backpack worn by USCM medics."
	icon_state = "marinepackm"

/obj/item/storage/backpack/marine/tech
	name = "\improper USCM technician backpack"
	desc = "The standard-issue backpack worn by USCM technicians."
	icon_state = "marinepackt"

/obj/item/storage/backpack/marine/satchel
	name = "\improper USCM satchel"
	desc = "A heavy-duty satchel carried by some USCM soldiers and support personnel."
	icon_state = "marinesat"
	worn_accessible = TRUE
	storage_slots = null
	max_storage_space = 15


/obj/item/storage/backpack/marine/satchel/medic
	name = "\improper USCM medic satchel"
	desc = "A heavy-duty satchel carried by some USCM medics."
	icon_state = "marinesatm"

/obj/item/storage/backpack/marine/satchel/tech
	name = "\improper USCM technician satchel"
	desc = "A heavy-duty satchel carried by some USCM technicians."
	icon_state = "marinesatt"

/obj/item/storage/backpack/marine/smock
	name = "\improper M3 sniper's smock"
	desc = "A specially designed smock with pockets for all your sniper needs."
	icon_state = "smock"
	worn_accessible = TRUE

#define SCOUT_CLOAK_COOLDOWN 100
#define SCOUT_CLOAK_TIMER 50
// Scout Cloak
/obj/item/storage/backpack/marine/satchel/scout_cloak
	name = "\improper M68 Thermal Cloak"
	desc = "The lightweight thermal dampeners and optical camouflage provided by this cloak are weaker than those found in standard USCM ghillie suits. In exchange, the cloak can be worn over combat armor and offers the wearer high manueverability and adaptability to many environments."
	icon_state = "scout_cloak"
	uniform_restricted = list(/obj/item/clothing/suit/storage/marine/M3S, /obj/item/clothing/head/helmet/marine/scout) //Need to wear Scout armor and helmet to equip this.
	has_gamemode_skin = FALSE //same sprite for all gamemode.
	var/camo_active = 0
	var/camo_active_timer = 0
	var/camo_cooldown_timer = 0
	var/camo_ready = 1

/obj/item/storage/backpack/marine/satchel/scout_cloak/verb/camouflage()
	set name = "Toggle M68 Thermal Camouflage"
	set desc = "Activate your cloak's camouflage."
	set category = "Scout"

	if (!usr || usr.is_mob_incapacitated(TRUE))
		return

	var/mob/living/carbon/human/M = usr
	if (!istype(M))
		return

	if(M.species.name == "Zombie")
		return

	if (M.back != src)
		M << "<span class='warning'>You must be wearing the cloak to activate it!"
		return

	if (camo_active)
		camo_off(usr)
		return

	if (!camo_ready)
		M << "<span class='warning'>Your thermal dampeners are still recharging!"
		return

	camo_ready = 0
	camo_active = 1
	M << "<span class='notice'>You activate your cloak's camouflage.</span>"

	for (var/mob/O in oviewers(M))
		O.show_message("[M] vanishes into thin air!", 1)
	playsound(M.loc,'sound/effects/cloak_scout_on.ogg', 15, 1)

	M.alpha = 10

	var/datum/mob_hud/security/advanced/SA = huds[MOB_HUD_SECURITY_ADVANCED]
	SA.remove_from_hud(M)
	var/datum/mob_hud/xeno_infection/XI = huds[MOB_HUD_XENO_INFECTION]
	XI.remove_from_hud(M)

	spawn(1)
		anim(M.loc,M,'icons/mob/mob.dmi',,"cloak",,M.dir)

	camo_active_timer = world.timeofday + SCOUT_CLOAK_TIMER
	process_active_camo(usr)
	return 1

/obj/item/storage/backpack/marine/satchel/scout_cloak/proc/camo_off(var/mob/user)
	if (!user)
		return 0

	user << "<span class='warning'>Your cloak's camouflage has deactivated!</span>"
	camo_active = 0

	for (var/mob/O in oviewers(user))
		O.show_message("[user.name] shimmers into existence!",1)
	playsound(user.loc,'sound/effects/cloak_scout_off.ogg', 15, 1)
	user.alpha = initial(user.alpha)

	var/datum/mob_hud/security/advanced/SA = huds[MOB_HUD_SECURITY_ADVANCED]
	SA.add_to_hud(user)
	var/datum/mob_hud/xeno_infection/XI = huds[MOB_HUD_XENO_INFECTION]
	XI.add_to_hud(user)

	spawn(1)
		anim(user.loc,user,'icons/mob/mob.dmi',,"uncloak",,user.dir)

	camo_cooldown_timer = world.timeofday + SCOUT_CLOAK_COOLDOWN
	process_camo_cooldown(user)

/obj/item/storage/backpack/marine/satchel/scout_cloak/proc/process_camo_cooldown(var/mob/user)
	set background = 1

	spawn while (!camo_ready && !camo_active)
		if (world.timeofday > camo_cooldown_timer)
			user << "<span class='notice'>Your cloak's thermal dampeners have recharged!"
			camo_ready = 1

		sleep(10)	// Process every second.

/obj/item/storage/backpack/marine/satchel/scout_cloak/proc/process_active_camo(var/mob/user)
	set background = 1

	spawn while (camo_active)
		if (world.timeofday > camo_active_timer)
			camo_active = 0
			camo_off(user)

		sleep(10)	// Process every second.



// Welder Backpacks //

/obj/item/storage/backpack/marine/engineerpack
	name = "\improper USCM technician welderpack"
	desc = "A specialized backpack worn by USCM technicians. It carries a fueltank for quick welder refueling and use,"
	icon_state = "engineerpack"
	var/max_fuel = 260
	max_storage_space = 15
	storage_slots = null
	has_gamemode_skin = FALSE //same sprites for all gamemodes

/obj/item/storage/backpack/marine/engineerpack/New()
	var/datum/reagents/R = new/datum/reagents(max_fuel) //Lotsa refills
	reagents = R
	R.my_atom = src
	R.add_reagent("fuel", max_fuel)
	..()


/obj/item/storage/backpack/marine/engineerpack/attackby(obj/item/W, mob/living/user)
	if(istype(W, /obj/item/tool/weldingtool))
		var/obj/item/tool/weldingtool/T = W
		if(T.welding)
			user << "<span class='warning'>That was close! However you realized you had the welder on and prevented disaster.</span>"
			return
		if(!(T.get_fuel()==T.max_fuel) && reagents.total_volume)
			reagents.trans_to(W, T.max_fuel)
			user << "<span class='notice'>Welder refilled!</span>"
			playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
			return
	else if(istype(W, /obj/item/ammo_magazine/flamer_tank))
		var/obj/item/ammo_magazine/flamer_tank/FT = W
		if(!FT.current_rounds && reagents.total_volume)
			var/fuel_available = reagents.total_volume < FT.max_rounds ? reagents.total_volume : FT.max_rounds
			reagents.remove_reagent("fuel", fuel_available)
			FT.current_rounds = fuel_available
			playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
			FT.caliber = "Fuel"
			user << "<span class='notice'>You refill [FT] with [lowertext(FT.caliber)].</span>"
			FT.update_icon()
			return
	. = ..()

/obj/item/storage/backpack/marine/engineerpack/afterattack(obj/O as obj, mob/user as mob, proximity)
	if(!proximity) // this replaces and improves the get_dist(src,O) <= 1 checks used previously
		return
	if (istype(O, /obj/structure/reagent_dispensers/fueltank) && src.reagents.total_volume < max_fuel)
		O.reagents.trans_to(src, max_fuel)
		user << "\blue You crack the cap off the top of the pack and fill it back up again from the tank."
		playsound(src.loc, 'sound/effects/refill.ogg', 25, 1, 3)
		return
	else if (istype(O, /obj/structure/reagent_dispensers/fueltank) && src.reagents.total_volume == max_fuel)
		user << "\blue The pack is already full!"
		return
	..()

/obj/item/storage/backpack/marine/engineerpack/examine(mob/user)
	..()
	user << "[reagents.total_volume] units of fuel left!"

// Pyrotechnician Spec backpack fuel tank
/obj/item/storage/backpack/marine/engineerpack/flamethrower
	name = "\improper USCM Pyrotechnician fueltank"
	desc = "A specialized fueltank worn by USCM Pyrotechnicians for use with the M240-T incinerator unit. A small general storage compartment is installed."
	icon_state = "flamethrower_tank"
	max_fuel = 500

/obj/item/storage/backpack/marine/engineerpack/flamethrower/attackby(obj/item/W, mob/living/user)
	if (istype(W, /obj/item/ammo_magazine/flamer_tank))
		var/obj/item/ammo_magazine/flamer_tank/large/FTL = W
		if(!FTL.current_rounds && reagents.total_volume)
			var/fuel_available = reagents.total_volume < FTL.max_rounds ? reagents.total_volume : FTL.max_rounds
			reagents.remove_reagent("fuel", fuel_available)
			FTL.current_rounds = fuel_available
			playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
			FTL.caliber = "UT-Napthal Fuel"
			user << "<span class='notice'>You refill [FTL] with [lowertext(FTL.caliber)].</span>"
			FTL.update_icon()
	. = ..()

/obj/item/storage/backpack/lightpack
	name = "\improper lightweight combat pack"
	desc = "A small lightweight pack for expeditions and short-range operations."
	icon_state = "ERT_satchel"
	worn_accessible = TRUE

/obj/item/storage/backpack/commando
	name = "commando bag"
	desc = "A heavy-duty bag carried by Weyland Yutani commandos."
	icon_state = "commandopack"
	storage_slots = null
	max_storage_space = 30

/obj/item/storage/backpack/mcommander
	name = "marine commander backpack"
	desc = "The contents of this backpack are top secret."
	icon_state = "marinepack"
	storage_slots = null
	max_storage_space = 30
