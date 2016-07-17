//==========================//ACCESSORIES\\==============================\\
//=======================================================================\\

/*Things like backpacks and belts should go in here. You know the drill.*/

//=======================================================================\\
//=======================================================================\\

//==========================//BACKPACKS\\================================\\
//=======================================================================\\

/obj/item/weapon/storage/backpack/marine
	name = "USCM Infantry Backpack"
	desc = "The standard-issue backpack of the USCM forces."
	icon_state = "marinepack"
	item_state = "backpack"
	max_w_class = 3    //  Largest item that can be placed into the backpack
	max_combined_w_class = 21   //Capacity of the backpack

/obj/item/weapon/storage/backpack/marine/medic
	name = "USCM Medic Backpack"
	desc = "The standard-issue backpack worn by USCM Medics."
	icon_state = "marinepack-medic"
	item_state = "marinepack-medic"

/obj/item/weapon/storage/backpack/marine/tech
	name = "USCM Technician Backpack"
	desc = "The standard-issue backpack worn by USCM Technicians."
	icon_state = "marinepack-tech"
	item_state = "marinepack-tech"

/obj/item/weapon/storage/backpack/marine/smock
	name = "Sniper's Smock"
	desc = "A specially designed smock with pockets for all your sniper needs."
	icon_state = "smock"
	item_state = "smock"

/obj/item/weapon/storage/backpack/marinesatchel
	name = "USCM Infantry Satchel"
	desc = "A heavy-duty satchel carried by some USCM soldiers."
	icon_state = "marinepack2"
	item_state = "marinepack2"

/obj/item/weapon/storage/backpack/marinesatchel/medic
	name = "USCM Medic Satchel"
	desc = "A heavy-duty satchel carried by some USCM Medics."
	icon_state = "marinepack-medic2"
	item_state = "marinepack-medic"

/obj/item/weapon/storage/backpack/marinesatchel/tech
	name = "USCM Technician Satchel"
	desc = "A heavy-duty satchel carried by some USCM Technicians."
	icon_state = "marinepack-tech2"
	item_state = "marinepack-tech2"

/obj/item/weapon/storage/backpack/marinesatchel/commando
	name = "Commando Bag"
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
		else
			overlays.Cut()
			icon = initial(icon)
			icon_state = initial(icon_state)
			item_state = initial(item_state)

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
	name = "m4a3 duty belt"
	desc = "A belt-holster assembly that allows one to carry the m4a3 comfortably secure with two magazines of ammunition."
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

//Probably want to remove the gun from the marine belt.
/obj/item/weapon/storage/belt/marine
	name = "m276 load belt"
	desc = "A standard issue toolbelt for USCM military forces. Put your ammo in here."
	icon_state = "marinebelt"
	item_state = "marine"//Could likely use a better one.
	w_class = 4
	storage_slots = 8
	max_combined_w_class = 9
	can_hold = list(
		"/obj/item/weapon/gun/pistol",
		"/obj/item/weapon/combat_knife",
		"/obj/item/device/flashlight/flare",
		"/obj/item/device/flash",
		"/obj/item/ammo_magazine",
		"/obj/item/flareround_s",
		"/obj/item/flareround_sp",
		"/obj/item/weapon/grenade",
		"/obj/item/device/mine"
		)

/obj/item/weapon/storage/belt/security/MP
	name = "MP Belt"
	desc = "Can hold Military Police Equipment."
	icon_state = "securitybelt"
	item_state = "security"//Could likely use a better one.
	storage_slots = 7
	max_w_class = 3
	max_combined_w_class = 30
	can_hold = list(
		"/obj/item/weapon/grenade/flashbang",
		"/obj/item/weapon/reagent_containers/spray/pepper",
		"/obj/item/weapon/handcuffs",
		"/obj/item/device/flash",
		"/obj/item/clothing/glasses",
		"/obj/item/weapon/gun/taser",
		"/obj/item/weapon/gun/pistol",
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
	name="Knife Rig"
	desc="Storage for your sharp toys"
	icon_state="securitybelt" // temp
	item_state="security" // aslo temp, maybe somebody update these icons with better ones?
	w_class = 3
	storage_slots = 3
	max_w_class = 1
	max_combined_w_class=3

	can_hold=list("/obj/item/weapon/throwing_knife")

/obj/item/weapon/storage/belt/grenade
	name="grenade bandolier"
	desc="Storage for your exploding toys."
	icon_state="grenadebelt" // temp
	item_state="security" // aslo temp, maybe somebody update these icons with better ones?
	w_class = 4
	storage_slots = 8
	max_w_class = 3
	max_combined_w_class = 24

	can_hold=list("/obj/item/weapon/grenade/explosive", "/obj/item/weapon/grenade/incendiary", "/obj/item/weapon/grenade/smokebomb","/obj/item/weapon/grenade/")

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

/obj/item/weapon/storage/belt/knifepouch/New()
	..()
	new /obj/item/weapon/throwing_knife(src)
	new /obj/item/weapon/throwing_knife(src)
	new /obj/item/weapon/throwing_knife(src)

//============================//GOGGLES\\================================\\
//=======================================================================\\

/obj/item/clothing/glasses/night/m56_goggles
	name = "M56 head mounted sight"
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
	name = "M42 Scout Sight"
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