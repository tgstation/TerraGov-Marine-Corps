
/*
 * Backpack
 */

/obj/item/weapon/storage/backpack
	name = "backpack"
	desc = "You wear this on your back and put items into it."
	icon_state = "backpack"
	item_state = "backpack"
	w_class = 4.0
	flags_equip_slot = SLOT_BACK	//ERROOOOO
	max_w_class = 3
	storage_slots = null
	max_storage_space = 21
	var/worn_accessible = FALSE //whether you can access its content while worn on the back

/obj/item/weapon/storage/backpack/attack_hand(mob/user)
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

/obj/item/weapon/storage/backpack/attackby(obj/item/weapon/W, mob/user)
/*	if(!worn_accessible && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.back == src)
			H << "<span class='notice'>You can't access [src] while it's on your back.</span>"
			return TRUE
*/
	if (use_sound)
		playsound(src.loc, src.use_sound, 15, 1, 6)
	..()

/obj/item/weapon/storage/backpack/equipped(mob/user, slot)
	if(slot == WEAR_BACK)
		mouse_opacity = 2 //so it's easier to click when properly equipped.
		if(use_sound)
			playsound(loc, use_sound, 15, 1, 6)
		if(!worn_accessible)
			close(user)
	..()

/obj/item/weapon/storage/backpack/dropped(mob/user)
	mouse_opacity = initial(mouse_opacity)
	..()


/obj/item/weapon/storage/backpack/open(mob/user)
	if(!worn_accessible && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.back == src)
			H << "<span class='notice'>You can't access [src] while it's on your back.</span>"
			return
	..()

/*
 * Backpack Types
 */

/obj/item/weapon/storage/backpack/holding
	name = "bag of holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	origin_tech = "bluespace=4"
	icon_state = "holdingpack"
	item_state = "holdingpack"
	max_w_class = 4
	max_storage_space = 28

	New()
		..()
		return

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(crit_fail)
			user << "\red The Bluespace generator isn't working."
			return
		if(istype(W, /obj/item/weapon/storage/backpack/holding) && !W.crit_fail)
			user << "\red The Bluespace interfaces of the two devices conflict and malfunction."
			cdel(W)
			return
			/* //BoH+BoH=Singularity, commented out.
		if(istype(W, /obj/item/weapon/storage/backpack/holding) && !W.crit_fail)
			investigate_log("has become a singularity. Caused by [user.key]","singulo")
			user << "\red The Bluespace interfaces of the two devices catastrophically malfunction!"
			cdel(W)
			var/obj/machinery/singularity/singulo = new /obj/machinery/singularity (get_turf(src))
			singulo.energy = 300 //should make it a bit bigger~
			message_admins("[key_name_admin(user)] detonated a bag of holding")
			log_game("[key_name(user)] detonated a bag of holding")
			cdel(src)
			return
			*/
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


/obj/item/weapon/storage/backpack/santabag
	name = "Santa's Gift Bag"
	desc = "Space Santa uses this to deliver toys to all the nice children in space in Christmas! Wow, it's pretty big!"
	icon_state = "giftbag0"
	item_state = "giftbag"
	w_class = 4.0
	storage_slots = null
	max_w_class = 3
	max_storage_space = 400 // can store a ton of shit!

/obj/item/weapon/storage/backpack/cultpack
	name = "trophy rack"
	desc = "It's useful for both carrying extra gear and proudly declaring your insanity."
	icon_state = "cultpack"
	item_state = "cultpack"

/obj/item/weapon/storage/backpack/clown
	name = "Giggles von Honkerton"
	desc = "It's a backpack made by Honk! Co."
	icon_state = "clownpack"
	item_state = "clownpack"

/obj/item/weapon/storage/backpack/medic
	name = "medical backpack"
	desc = "It's a backpack especially designed for use in a sterile environment."
	icon_state = "medicalpack"
	item_state = "medicalpack"

/obj/item/weapon/storage/backpack/security
	name = "security backpack"
	desc = "It's a very robust backpack."
	icon_state = "securitypack"
	item_state = "securitypack"

/obj/item/weapon/storage/backpack/captain
	name = "captain's backpack"
	desc = "It's a special backpack made exclusively for officers."
	icon_state = "captainpack"
	item_state = "captainpack"

/obj/item/weapon/storage/backpack/industrial
	name = "industrial backpack"
	desc = "It's a tough backpack for the daily grind of station life."
	icon_state = "engiepack"
	item_state = "engiepack"

/obj/item/weapon/storage/backpack/toxins
	name = "laboratory backpack"
	desc = "It's a light backpack modeled for use in laboratories and other scientific institutions."
	icon_state = "toxpack"
	item_state = "toxpack"

/obj/item/weapon/storage/backpack/hydroponics
	name = "herbalist's backpack"
	desc = "It's a green backpack with many pockets to store plants and tools in."
	icon_state = "hydpack"
	item_state = "hydpack"

/obj/item/weapon/storage/backpack/genetics
	name = "geneticist backpack"
	desc = "It's a backpack fitted with slots for diskettes and other workplace tools."
	icon_state = "genpack"
	item_state = "genpack"

/obj/item/weapon/storage/backpack/virology
	name = "sterile backpack"
	desc = "It's a sterile backpack able to withstand different pathogens from entering its fabric."
	icon_state = "viropack"
	item_state = "viropack"

/obj/item/weapon/storage/backpack/chemistry
	name = "chemistry backpack"
	desc = "It's an orange backpack which was designed to hold beakers, pill bottles and bottles."
	icon_state = "chempack"
	item_state = "chempack"

/*
 * Satchel Types
 */

/obj/item/weapon/storage/backpack/satchel
	name = "leather satchel"
	desc = "It's a very fancy satchel made with fine leather."
	icon_state = "satchel"
	item_state = "satchel"
	worn_accessible = TRUE
	storage_slots = null
	max_storage_space = 15

/obj/item/weapon/storage/backpack/satchel/withwallet
	New()
		..()
		new /obj/item/weapon/storage/wallet/random( src )

/obj/item/weapon/storage/backpack/satchel/norm
	name = "satchel"
	desc = "A trendy looking satchel."
	icon_state = "satchel-norm"
	item_state = "satchel-norm"

/obj/item/weapon/storage/backpack/satchel/eng
	name = "industrial satchel"
	desc = "A tough satchel with extra pockets."
	icon_state = "satchel-eng"
	item_state = "satchel-eng"

/obj/item/weapon/storage/backpack/satchel/med
	name = "medical satchel"
	desc = "A sterile satchel used in medical departments."
	icon_state = "satchel-med"
	item_state = "satchel-med"

/obj/item/weapon/storage/backpack/satchel/vir
	name = "virologist satchel"
	desc = "A sterile satchel with virologist colours."
	icon_state = "satchel-vir"
	item_state = "satchel-vir"

/obj/item/weapon/storage/backpack/satchel/chem
	name = "chemist satchel"
	desc = "A sterile satchel with chemist colours."
	icon_state = "satchel-chem"
	item_state = "satchel-chem"

/obj/item/weapon/storage/backpack/satchel/gen
	name = "geneticist satchel"
	desc = "A sterile satchel with geneticist colours."
	icon_state = "satchel-gen"
	item_state = "satchel-gen"

/obj/item/weapon/storage/backpack/satchel/tox
	name = "scientist satchel"
	desc = "Useful for holding research materials."
	icon_state = "satchel-tox"
	item_state = "satchel-tox"

/obj/item/weapon/storage/backpack/satchel/sec
	name = "security satchel"
	desc = "A robust satchel for security related needs."
	icon_state = "satchel-sec"
	item_state = "satchel-sec"

/obj/item/weapon/storage/backpack/satchel/hyd
	name = "hydroponics satchel"
	desc = "A green satchel for plant related work."
	icon_state = "satchel_hyd"
	item_state = "satchel_hyd"

/obj/item/weapon/storage/backpack/satchel/cap
	name = "captain's satchel"
	desc = "An exclusive satchel for officers."
	icon_state = "satchel-cap"
	item_state = "satchel-cap"

//ERT backpacks.
/obj/item/weapon/storage/backpack/ert
	name = "emergency response team backpack"
	desc = "A spacious backpack with lots of pockets, used by members of the Emergency Response Team."
	icon_state = "ert_commander"
	item_state = "ert_commander"

//Commander
/obj/item/weapon/storage/backpack/ert/commander
	name = "emergency response team commander backpack"
	desc = "A spacious backpack with lots of pockets, worn by the commander of a Emergency Response Team."

//Security
/obj/item/weapon/storage/backpack/ert/security
	name = "emergency response team security backpack"
	desc = "A spacious backpack with lots of pockets, worn by security members of a Emergency Response Team."
	icon_state = "ert_security"
	item_state = "ert_security"

//Engineering
/obj/item/weapon/storage/backpack/ert/engineer
	name = "emergency response team engineer backpack"
	desc = "A spacious backpack with lots of pockets, worn by engineering members of a Emergency Response Team."
	icon_state = "ert_engineering"
	item_state = "ert_engineering"

//Medical
/obj/item/weapon/storage/backpack/ert/medical
	name = "emergency response team medical backpack"
	desc = "A spacious backpack with lots of pockets, worn by medical members of a Emergency Response Team."
	icon_state = "ert_medical"
	item_state = "ert_medical"





//==========================// MARINE BACKPACKS\\================================\\
//=======================================================================\\

/obj/item/weapon/storage/backpack/marine
	name = "\improper lightweight IMP backpack"
	desc = "The standard-issue pack of the USCM forces. Designed to slug gear into the battlefield."
	icon_state = "marinepack"

	New()
		select_gamemode_skin(type)
		..()

/obj/item/weapon/storage/backpack/marine/medic
	name = "\improper USCM medic backpack"
	desc = "The standard-issue backpack worn by USCM medics."
	icon_state = "marinepackm"

/obj/item/weapon/storage/backpack/marine/tech
	name = "\improper USCM technician backpack"
	desc = "The standard-issue backpack worn by USCM technicians."
	icon_state = "marinepackt"

/obj/item/weapon/storage/backpack/marine/satchel
	name = "\improper USCM satchel"
	desc = "A heavy-duty satchel carried by some USCM soldiers and support personnel."
	icon_state = "marinesat"
	worn_accessible = TRUE
	storage_slots = null
	max_storage_space = 15


/obj/item/weapon/storage/backpack/marine/satchel/medic
	name = "\improper USCM medic satchel"
	desc = "A heavy-duty satchel carried by some USCM medics."
	icon_state = "marinesatm"

/obj/item/weapon/storage/backpack/marine/satchel/tech
	name = "\improper USCM technician satchel"
	desc = "A heavy-duty satchel carried by some USCM technicians."
	icon_state = "marinesatt"

/obj/item/weapon/storage/backpack/marine/smock
	name = "\improper M3 sniper's smock"
	desc = "A specially designed smock with pockets for all your sniper needs."
	icon_state = "smock"
	worn_accessible = TRUE



// Welder Backpacks //

/obj/item/weapon/storage/backpack/marine/engineerpack
	name = "\improper USCM technician welderpack"
	desc = "A specialized backpack worn by USCM technicians. It carries a fueltank for quick welder refueling and use,"
	icon_state = "engineerpack"
	item_state = "engineerpack"
	var/max_fuel = 260
	max_storage_space = 15
	storage_slots = null

/obj/item/weapon/storage/backpack/marine/engineerpack/New()
	var/datum/reagents/R = new/datum/reagents(max_fuel) //Lotsa refills
	reagents = R
	R.my_atom = src
	R.add_reagent("fuel", max_fuel)
	..()
	return

/obj/item/weapon/storage/backpack/marine/engineerpack/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/T = W
		if(T.welding)
			user << "\red That was close! However you realized you had the welder on and prevented disaster"
			return
		src.reagents.trans_to(W, T.max_fuel)
		user << "\blue Welder refilled!"
		playsound(src.loc, 'sound/effects/refill.ogg', 25, 1, 3)
		return
	. = ..()

/obj/item/weapon/storage/backpack/marine/engineerpack/afterattack(obj/O as obj, mob/user as mob, proximity)
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

/obj/item/weapon/storage/backpack/marine/engineerpack/examine(mob/user)
	..()
	user << "[reagents.total_volume] units of fuel left!"





/obj/item/weapon/storage/backpack/lightpack
	name = "\improper lightweight combat pack"
	desc = "A small lightweight pack for expeditions and short-range operations."
	icon_state = "ERT_satchel"
	item_state = "ERT_satchel"

/obj/item/weapon/storage/backpack/commando
	name = "commando bag"
	desc = "A heavy-duty bag carried by Weyland Yutani commandos."
	icon_state = "commandopack"
	item_state = "commandopack"
	storage_slots = null
	max_storage_space = 30

/obj/item/weapon/storage/backpack/mcommander
	name = "marine commander backpack"
	desc = "The contents of this backpack are top secret."
	icon_state = "marinepack"
	storage_slots = null
	max_storage_space = 30