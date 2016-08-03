//==========================//ACCESSORIES\\==============================\\
//=======================================================================\\

/*Things like backpacks and belts should go in here. You know the drill.*/

//=======================================================================\\
//=======================================================================\\

//==========================//BACKPACKS\\================================\\
//=======================================================================\\

/obj/item/weapon/storage/backpack/marine
	name = "\improper USCM infantry backpack"
	desc = "The standard-issue backpack of the USCM forces."
	icon_state = "marinepack"
	item_state = "backpack"
	max_w_class = 3    //  Largest item that can be placed into the backpack
	max_combined_w_class = 21   //Capacity of the backpack
	New()
		..()
		if(ticker && istype(ticker.mode,/datum/game_mode/ice_colony)) //Snow camo
			if(icon_state == "marinepack") //Only change this one
				item_state = "backpack_s"
				icon_state = "marinepack_s"

/obj/item/weapon/storage/backpack/marine/medic
	name = "\improper USCM medic backpack"
	desc = "The standard-issue backpack worn by USCM Medics."
	icon_state = "marinepack-medic"
	item_state = "marinepack-medic"
	New()
		..()
		if(ticker && istype(ticker.mode,/datum/game_mode/ice_colony)) //Snow camo
			if(icon_state == "marinepack-medic") //Only change this one
				item_state = "marinepack-medic_s"
				icon_state = "marinepack-medic_s"


/obj/item/weapon/storage/backpack/marine/tech
	name = "\improper USCM technician backpack"
	desc = "The standard-issue backpack worn by USCM Technicians."
	icon_state = "marinepack-tech"
	item_state = "marinepack-tech"
	New()
		..()
		if(ticker && istype(ticker.mode,/datum/game_mode/ice_colony)) //Snow camo
			if(icon_state == "marinepack-tech") //Only change this one
				item_state = "marinepack-tech_s"
				icon_state = "marinepack-tech_s"

/obj/item/weapon/storage/backpack/marine/smock
	name = "\improper M3 Sniper's Smock"
	desc = "A specially designed smock with pockets for all your sniper needs."
	icon_state = "smock"
	item_state = "smock"
	New()
		..()
		if(ticker && istype(ticker.mode,/datum/game_mode/ice_colony)) //Snow camo
			if(icon_state == "smock") //Only change this one
				item_state = "smock_s"
				icon_state = "smock_s"

/obj/item/weapon/storage/backpack/marinesatchel
	name = "\improper USCM infantry satchel"
	desc = "A heavy-duty satchel carried by some USCM soldiers."
	icon_state = "marinepack2"
	item_state = "marinepack2"
	New()
		..()
		if(ticker && istype(ticker.mode,/datum/game_mode/ice_colony)) //Snow camo
			if(icon_state == "marinepack2") //Only change this one
				item_state = "marinepack2_s"
				icon_state = "marinepack2_s"

/obj/item/weapon/storage/backpack/medicsatchel
	name = "\improper USCM medic satchel"
	desc = "A heavy-duty satchel carried by some USCM Medics."
	icon_state = "marinepack2"
	item_state = "marinepackmedic2"
	New()
		..()
		if(ticker && istype(ticker.mode,/datum/game_mode/ice_colony)) //Snow camo
			if(icon_state == "marinepack2") //Only change this one
				item_state = "marinepackmedic2_s"
				icon_state = "marinepack2_s"

/obj/item/weapon/storage/backpack/techsatchel
	name = "\improper USCM technician satchel"
	desc = "A heavy-duty satchel carried by some USCM Technicians."
	icon_state = "marinepack2"
	item_state = "marinepacktech2"
	New()
		..()
		if(ticker && istype(ticker.mode,/datum/game_mode/ice_colony)) //Snow camo
			if(icon_state == "marinepack2") //Only change this one
				item_state = "marinepacktech2_s"
				icon_state = "marinepack2_s"

/obj/item/weapon/storage/backpack/marinesatchel/commando
	name = "\improper commando bag"
	desc = "A heavy-duty bag carried by Weyland Yutani Commandos."
	icon_state = "marinepack-tech3"
	item_state = "marinepack-tech3"

/obj/item/weapon/storage/backpack/mcommander
	name = "marine commander backpack"
	desc = "The contents of this backpack are top secret."
	icon_state = "marinepack"
	item_state = "marinepack" //Placeholder

//============================//BELTS\\==================================\\
//=======================================================================\\

/obj/item/weapon/storage/belt/gun
	name = "pistol belt"
	desc = "A belt-holster assembly that allows one to hold a pistol and two magazines."
	icon_state = "marinebelt"
	var/icon_closed = null //Empty for now.
	item_state = "holster0"
	use_sound = null
	w_class = 4
	storage_slots = 3
	max_combined_w_class = 6
	max_w_class = 2
	var/holds_guns_now = 0 //Generic variable to determine if the holster already holds a gun.
	var/holds_guns_max = 1 //How many guns can it hold? I think this can be any thing from 1 to whatever. Should calculate properly.
	var/obj/item/weapon/gun/current_gun //The gun it holds, used for referencing later so we can update the icon.
	can_hold = list(
		"/obj/item/weapon/gun/pistol",
		"/obj/item/ammo_magazine/pistol"
		)

	proc/update_icon_special() //Update icon is called from within the other storage procs, and we don't want that.
		if(holds_guns_now) //So it has a gun, let's make an icon.
			/*
			This is sort of a workaround; displaying an icon as an underlay doesn't properly display the
			the thing in all instances. Alt+click is one example where it fails. Same with right click.
			This is still pretty fast, might actually be better than creating a matrix then rotating.
			*/
			var/icon/I = new(current_gun.icon, current_gun.icon_state) //New icon object.
			var/image/I2 = new(initial(icon),icon_closed) //New image to serve as an overlay.
			I.Turn(90) //Clockwise.
			icon = I
			overlays += I2
			item_state = "holster1"
			//update_inv_belt()
		else
			overlays.Cut()
			icon = initial(icon)
			icon_state = initial(icon_state)
			item_state = initial(item_state)
			//update_inv_belt()

	//There are only two types here that can be inserted, and they are mutually exclusive. We only track the gun.
	can_be_inserted(obj/item/W as obj, stop_messages = 0) //We don't need to stop messages, but it can be left in.
		if( ..() ) //If the parent did their thing, this should be fine. It pretty much handles all the checks.
			if(istype(W,/obj/item/weapon/gun)) //Is it a gun?
				if(holds_guns_now == holds_guns_max) //Are we at our gun capacity?
					if(!stop_messages) usr << "<span class='notice'>\The [src] already holds a gun.<span>"
					return //Nothing else to do.
				holds_guns_now++ //Slide it in.
				if(!current_gun) //If there's no active gun, we want to make this our icon.
					current_gun = W
				update_icon_special()
			else //Must be ammo.
		//We have slots open for the gun, so in total we should have storage_slots - guns_max in slots, plus whatever is already in the belt.
				if(( (storage_slots - holds_guns_max) + holds_guns_now) <= contents.len) // We're over capacity, and the space is reserved for a gun.
					if(!stop_messages) usr << "<span class='notice'>\The [src] can't hold any more magazines.<span>"
					return
			return 1

	remove_from_storage(obj/item/W as obj)
		if(..() ) //Same deal, this will handle things.
			if(istype(W,/obj/item/weapon/gun)) //Is it a gun?
				holds_guns_now-- //Remove it.
				if(W == current_gun)
					current_gun = null
				update_icon_special() //Update.
			return 1

/obj/item/weapon/storage/belt/gun/revolver
	name = "pistol belt"
	desc = "A belt-holster assembly that allows one to hold a revolver and two magazines."
	can_hold = list(
		"/obj/item/weapon/gun/revolver",
		"/obj/item/ammo_magazine/revolver"
		)

/obj/item/weapon/storage/belt/gun/m4a3
	name = "\improper M276 Pattern M4a3 Holster Rig"
	desc = "The M276 is the standard load-bearing equipment of the USCM. It conisists of a modular belt with various clips. This version has a holster assembly that allows one to carry the m4a3 comfortably secure. It also contains two side pouches that can store two spare 9mm magazines."
	icon_state = "M4A3_holster_0"
	icon_closed = "M4A3_holster_1"
	can_hold = list(
		"/obj/item/weapon/gun/pistol/m4a3",
		"/obj/item/ammo_magazine/pistol",
		"/obj/item/ammo_magazine/pistol/hp",
		"/obj/item/ammo_magazine/pistol/ap",
		"/obj/item/ammo_magazine/pistol/incendiary",
		"/obj/item/ammo_magazine/pistol/extended"
		)
	/*
	New()
		..()
		if(ticker && istype(ticker.mode,/datum/game_mode/ice_colony)) //Snow camo
			if(icon_state == "M4A3_holster_0") //Only change this one
				icon_state = "M4A3_holster_0_s"
				icon_closed = "M4A3_holster_1_s"
				item_state = "holster1_s"
	*/

/obj/item/weapon/storage/belt/marine
	name = "\improper M276 Pattern Ammo Load Rig"
	desc = "The M276 is the standard load-bearing equipment of the USCM. It conisists of a modular belt with various clips. This version is the standard variant designed for bulk ammunition carrying operations."
	icon_state = "marinebelt"
	item_state = "marine"
	w_class = 4
	storage_slots = 6
	max_combined_w_class = 12
	can_hold = list(
		//"/obj/item/weapon/gun/pistol",
		"/obj/item/weapon/combat_knife",
		"/obj/item/device/flashlight/flare",
		"/obj/item/weapon/storage/box/m94",
		"/obj/item/device/flash",
		"/obj/item/ammo_magazine",
		"/obj/item/flareround_s",
		"/obj/item/flareround_sp",
		"/obj/item/weapon/grenade",
		"/obj/item/device/mine",
		"/obj/item/weapon/reagent_containers/food/snacks",
		"/obj/item/ammo_magazine/shotgun"
		)
	New()
		..()
		if(ticker && istype(ticker.mode,/datum/game_mode/ice_colony)) //Snow camo
			if(icon_state == "marinebelt") //Only change this one
				icon_state = "marinebelt_s"
				item_state = "marine_s"

/obj/item/weapon/storage/belt/security/MP
	name = "\improper M276 Pattern Military Police Rig"
	desc = "The M276 is the standard load-bearing equipment of the USCM. It conisists of a modular belt with various clips. This version is filled with an array of small pouches, meant to carry non-lethal equipment and restraints."
	icon_state = "securitybelt"
	item_state = "marine_s"
	storage_slots = 6
	max_w_class = 3
	max_combined_w_class = 30
	can_hold = list(
		"/obj/item/weapon/grenade/flashbang",
		"/obj/item/weapon/reagent_containers/spray/pepper",
		"/obj/item/weapon/handcuffs",
		"/obj/item/device/flash",
		"/obj/item/clothing/glasses",
		"/obj/item/weapon/gun/taser",
		"/obj/item/weapon/melee/baton",
		"/obj/item/weapon/handcuffs",
		"/obj/item/weapon/combat_knife",
		"/obj/item/device/flashlight/flare",
		"/obj/item/ammo_magazine",
		"/obj/item/weapon/reagent_containers/food/snacks/donut/normal",
		"/obj/item/weapon/reagent_containers/food/snacks/donut/jelly",
		"/obj/item/clothing/glasses/hud/security",
		"/obj/item/taperoll/police"
		)

/obj/item/weapon/storage/belt/security/MP/full/New()
	..()
	new /obj/item/weapon/gun/taser(src)
	new /obj/item/device/flash(src)
	new /obj/item/weapon/melee/baton(src)
	new /obj/item/weapon/handcuffs(src)

/obj/item/weapon/storage/belt/marine/full/New()
	..()
	new /obj/item/weapon/gun/pistol/m4a3(src)
	new /obj/item/ammo_magazine/pistol(src)

/obj/item/weapon/storage/belt/knifepouch
	name="\improper M276 Pattern Knife Rig"
	desc="The M276 is the standard load-bearing equipment of the USCM. It conisists of a modular belt with various clips. This version is specially designed with four holsters to store throwing knives. Not commonly issued, but kept in service."
	icon_state="knife-rig"
	item_state="marine" // aslo temp, maybe somebody update these icons with better ones?
	w_class = 3
	storage_slots = 4
	max_w_class = 1
	max_combined_w_class=3

	can_hold=list("/obj/item/weapon/throwing_knife")
	New()
		..()
		if(ticker && istype(ticker.mode,/datum/game_mode/ice_colony)) //Snow camo
			if(icon_state == "knife-rig") //Only change this one
				icon_state = "knife-rig_s"
				item_state = "marine_s"

/obj/item/weapon/storage/belt/knifepouch/New()
	..()
	new /obj/item/weapon/throwing_knife(src)
	new /obj/item/weapon/throwing_knife(src)
	new /obj/item/weapon/throwing_knife(src)
	new /obj/item/weapon/throwing_knife(src)

/obj/item/weapon/storage/belt/grenade
	name="\improper M276 Pattern M40 HEDP Rig"
	desc="The M276 is the standard load-bearing equipment of the USCM. It conisists of a modular belt with various clips. This version is designed to carry bulk quantities of M40 HEDP Grenades."
	icon_state="grenadebelt" // temp
	item_state="marine_s"
	w_class = 4
	storage_slots = 8
	max_w_class = 3
	max_combined_w_class = 24

	can_hold=list("/obj/item/weapon/grenade/explosive", "/obj/item/weapon/grenade/incendiary", "/obj/item/weapon/grenade/smokebomb","/obj/item/weapon/grenade/, /obj/item/weapon/grenade/phosphorus")

	New()
		..()
		spawn(1)
			new /obj/item/weapon/grenade/incendiary(src)
			new /obj/item/weapon/grenade/incendiary(src)
			new /obj/item/weapon/grenade/incendiary(src)
			new /obj/item/weapon/grenade/incendiary(src)
			new /obj/item/weapon/grenade/explosive(src)
			new /obj/item/weapon/grenade/explosive(src)
			new /obj/item/weapon/grenade/explosive(src)
			new /obj/item/weapon/grenade/explosive(src)

/obj/item/weapon/storage/sparepouch
	name="\improper G8 General Utility pouch"
	desc="A small, lightweight pouch that can be clipped onto Armat Systems M3 Pattern armor to provide additional storage. Unfortunately, this pouch uses the same securing system as most Armat platform weaponry, and thus only one can be clipped to the M3 Pattern Armor."
	storage_slots = 3
	w_class = 4
	max_w_class = 3
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state="sparepouch"
	item_state="marine_s"

//============================//GOGGLES\\================================\\
//=======================================================================\\

/obj/item/clothing/glasses/night/m56_goggles
	name = "\improper M56 head mounted sight"
	desc = "A headset and goggles system for the M56 Smartgun. Has a low-res short range imager, allowing for view of terrain."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "m56_goggles"
	item_state = "glasses"
	darkness_view = 5
	toggleable = 1
	icon_action_button = "action_meson"
	vision_flags = SEE_TURFS

	mob_can_equip(mob/user, slot)
		if(slot == slot_glasses)
			if(!ishuman(user)) return ..() //Doesn't matter, just pass it to the main proc
			var/mob/living/carbon/human/H = user
			if(istype(H))
				var/obj/item/smartgun_powerpack/P = H.back
				if(!P || !istype(P))
					user << "You must be wearing an M56 Powerpack on your back to wear these."
					return 0
		return ..(user, slot)


/obj/item/clothing/glasses/night/m56_goggles/New()
	..()
	overlay = global_hud.thermal

/obj/item/clothing/glasses/m42_goggles
	name = "\improper M42 scout sight"
	desc = "A headset and goggles system for the M42 Scout Rifle. Allows highlighted imaging of surroundings. Click it to toggle."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "m56_goggles"
	item_state = "m56_goggles"
	vision_flags = SEE_TURFS
	toggleable = 1
	icon_action_button = "action_meson"

	New()
		..()
		overlay = null  //Stops the overlay.