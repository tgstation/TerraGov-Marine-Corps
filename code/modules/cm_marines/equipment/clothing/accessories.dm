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
	max_w_class = 3    //  Largest item that can be placed into the backpack
	max_combined_w_class = 21   //Capacity of the backpack

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
	name = "\improper USCM infantry satchel"
	desc = "A heavy-duty satchel carried by some USCM soldiers."
	icon_state = "marinesat"

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

/obj/item/weapon/storage/backpack/commando
	name = "commando bag"
	desc = "A heavy-duty bag carried by Weyland Yutani commandos."
	icon_state = "commandopack"
	item_state = "commandopack"
	storage_slots = 10
	max_combined_w_class = 30

/obj/item/weapon/storage/backpack/mcommander
	name = "marine commander backpack"
	desc = "The contents of this backpack are top secret."
	icon_state = "marinepack"

/obj/item/weapon/storage/backpack/gun
	name = "Rifle Holster"
	desc = "holster"
	use_sound = null
	w_class = 4
	storage_slots = 1
	max_combined_w_class = 7
	max_w_class = 5
	var/originalName = "m37_holster"
	//icon_state = originalName
	//item_state = originalName

	can_hold = list(
		)

	/obj/item/weapon/storage/backpack/gun/update_icon()
		var/mob/user = loc
		icon_state = "[originalName][contents.len]"
		item_state = "[originalName][contents.len]"
		if(istype(user)) user.update_inv_back()
		if(istype(user)) user.update_inv_s_store()
		return


/obj/item/weapon/storage/backpack/gun/m37
	name = "\improper L44 M37A2 Scabbard"
	desc = "A large leather holster allowing the storage of an M37A2 Shotgun. It contains harnesses that allow it to be secured to the back for easy storage"
	originalName = "m37_holster"
	icon_state = "m37_holster0"
	item_state = "m37_holster0"
	can_hold = list(
		"/obj/item/weapon/gun/shotgun/pump",
		"/obj/item/weapon/gun/shotgun/combat"
		)



/obj/item/weapon/storage/backpack/gun/m37/full/New()
	..()
	icon_state = "m37_holster1"
	item_state = "m37_holster1"
	new /obj/item/weapon/gun/shotgun/pump(src)

/obj/item/weapon/storage/backpack/gun/machete
	name = "\improper H5 pattern M2132 machete scabbard"
	desc = "A large leather scabbard used to carry a M2132 machete. It can be strapped to the back or the armor"
	originalName = "machete_holster"
	icon_state = "machete_holster0"
	item_state = "machete_holster0"
	can_hold = list(
		"/obj/item/weapon/claymore/mercsword/machete"
		)

/obj/item/weapon/storage/backpack/gun/machete/full/New()
	..()
	icon_state = "machete_holster1"
	item_state = "machete_holster1"
	new /obj/item/weapon/claymore/mercsword/machete(src)




//============================//BELTS\\==================================\\
//=======================================================================\\

/obj/item/weapon/storage/belt
	name = "belt"
	desc = "Can hold various things."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utilitybelt"
	item_state = "utility"
	flags_equip_slot = SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined")
	w_class = 4

/obj/item/weapon/storage/belt/utility
	name = "\improper M276 pattern toolbelt rig" //Carn: utility belt is nicer, but it bamboozles the text parsing.
	desc = "The M276 is the standard load-bearing equipment of the USCM. It conisists of a modular belt with various clips. This version lacks any combat functionality, and is commonly used by engineers to transport important tools."
	icon_state = "utilitybelt"
	item_state = "utility"
	can_hold = list(
		"/obj/item/weapon/crowbar",
		"/obj/item/weapon/screwdriver",
		"/obj/item/weapon/weldingtool",
		"/obj/item/weapon/wirecutters",
		"/obj/item/weapon/wrench",
		"/obj/item/device/multitool",
		"/obj/item/device/flashlight",
		"/obj/item/stack/cable_coil",
		"/obj/item/device/t_scanner",
		"/obj/item/device/analyzer",
		"/obj/item/taperoll/engineering")


/obj/item/weapon/storage/belt/utility/full/New()
	..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/stack/cable_coil(src,30,pick("red","yellow","orange"))


/obj/item/weapon/storage/belt/utility/atmostech/New()
	..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/device/t_scanner(src)

/obj/item/weapon/storage/belt/medical
	name = "\improper M276 pattern medical storage rig"
	desc = "The M276 is the standard load-bearing equipment of the USCM. It conisists of a modular belt with various clips. This version is an less common configuration, designed to transport medical supplies, and light pistol munitions."
	icon_state = "medicalbelt"
	item_state = "medical"
	can_hold = list(
		"/obj/item/device/healthanalyzer",
		"/obj/item/weapon/dnainjector",
		"/obj/item/weapon/reagent_containers/dropper",
		"/obj/item/weapon/reagent_containers/glass/beaker",
		"/obj/item/weapon/reagent_containers/glass/bottle",
		"/obj/item/weapon/reagent_containers/pill",
		"/obj/item/weapon/reagent_containers/syringe",
		"/obj/item/weapon/reagent_containers/glass/dispenser",
		"/obj/item/weapon/flame/lighter/zippo",
		"/obj/item/weapon/storage/fancy/cigarettes",
		"/obj/item/weapon/storage/pill_bottle",
		"/obj/item/stack/medical",
		"/obj/item/device/flashlight/pen",
		"/obj/item/clothing/mask/surgical",
		"/obj/item/clothing/gloves/latex",
		"/obj/item/weapon/storage/syringe_case",
		"/obj/item/ammo_magazine/pistol",
	    "/obj/item/weapon/reagent_containers/hypospray"
	)


/obj/item/weapon/storage/belt/medical/combatLifesaver
	name = "\improper M276 pattern lifesaver bag"
	desc = "The M276 is the standard load-bearing equipment of the USCM. This configuration mounts a duffel bag filled with a range of injectors and light medical supplies and is common among medics."
	icon_state = "medicalbag"
	item_state = "medicbag"
	storage_slots = 21 //can hold 3 "rows" of very limited medical equipment, but it *should* give a decent boost to squad medics.
	can_hold = list(
		"/obj/item/weapon/reagent_containers/glass/bottle",
		"/obj/item/weapon/reagent_containers/pill",
		"/obj/item/weapon/reagent_containers/syringe",
		"/obj/item/weapon/reagent_containers/glass/dispenser",
		"/obj/item/weapon/storage/pill_bottle",
		"/obj/item/clothing/gloves/latex",
		"/obj/item/weapon/storage/syringe_case",
		"/obj/item/weapon/reagent_containers/hypospray/autoinjector",
		"/obj/item/stack/medical"
	)
	max_combined_w_class = 42


/obj/item/weapon/storage/belt/medical/combatLifesaver/New()  //The belt, with all it's magic inside!
	..()
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/Dylovene(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/Dylovene(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/Bicard(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/Bicard(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/Kelo(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/Kelo(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/quickclot(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/quickclot(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/dexP(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/dexP(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/Oxycodone(src)
	new /obj/item/weapon/storage/pill_bottle/russianRed(src)

/obj/item/weapon/storage/belt/security
	name = "\improper M276 pattern security rig"
	desc = "The M276 is the standard load-bearing equipment of the USCM. It conisists of a modular belt with various clips. This configuration is commonly seen among USCM Military Police and peacekeepers, though it can hold some light munitions."
	icon_state = "securitybelt"
	item_state = "security"//Could likely use a better one.
	storage_slots = 7
	max_w_class = 3
	max_combined_w_class = 21
	can_hold = list(
		"/obj/item/weapon/grenade/flashbang",
		"/obj/item/weapon/reagent_containers/spray/pepper",
		"/obj/item/weapon/handcuffs",
		"/obj/item/device/flash",
		"/obj/item/clothing/glasses",
		"/obj/item/ammo_casing/shotgun",
		"/obj/item/ammo_magazine/pistol",
		"/obj/item/ammo_magazine",
		"/obj/item/weapon/reagent_containers/food/snacks/donut/normal",
		"/obj/item/weapon/reagent_containers/food/snacks/donut/jelly",
		"/obj/item/weapon/melee/baton",
		"/obj/item/weapon/gun/energy/taser",
		"/obj/item/weapon/flame/lighter/zippo",
		"/obj/item/weapon/cigpacket",
		"/obj/item/clothing/glasses/hud/security",
		"/obj/item/device/flashlight",
		"/obj/item/device/pda",
		"/obj/item/device/radio/headset",
		"/obj/item/weapon/melee",
		"/obj/item/taperoll/police"
		)

/obj/item/weapon/storage/belt/gun
	name = "pistol belt"
	desc = "A belt-holster assembly that allows one to hold a pistol and two magazines."
	icon_state = "m4a3_holster"
	item_state = "m4a3_holster"
	use_sound = null
	w_class = 4
	storage_slots = 4
	max_combined_w_class = 6
	max_w_class = 3
	var/holds_guns_now = 0 //Generic variable to determine if the holster already holds a gun.
	var/holds_guns_max = 1 //How many guns can it hold? I think this can be any thing from 1 to whatever. Should calculate properly.
	var/obj/item/weapon/gun/current_gun //The gun it holds, used for referencing later so we can update the icon.
	var/image/reusable/gun_underlay //The underlay we will use.
	can_hold = list(
		"/obj/item/weapon/gun/pistol",
		"/obj/item/ammo_magazine/pistol"
		)

	proc/update_gun_icon() //We do not want to use regular update_icon as it's called for every item inserted. Not worth the icon math.
		var/mob/user = loc
		if(holds_guns_now) //So it has a gun, let's make an icon.
			/*
			Have to use a workaround here, otherwise images won't display properly at all times.
			Reason being, transform is not displayed when right clicking/alt+clicking an object,
			so it's necessary to pre-load the potential states so the item actually shows up
			correctly without having to rotate anything. Preloading weapon icons also makes
			sure that we don't have to do any extra calculations.
			*/
			gun_underlay = rnew(/image/reusable,list(icon, src, current_gun.icon_state))
			icon_state += "_g"
			item_state = icon_state
			underlays += gun_underlay
		else
			underlays -= gun_underlay
			icon_state = copytext(icon_state,1,-2)
			item_state = icon_state
			cdel(gun_underlay)
			gun_underlay = null
		if(istype(user)) user.update_inv_belt()
		if(istype(user)) user.update_inv_s_store()

	//There are only two types here that can be inserted, and they are mutually exclusive. We only track the gun.
	can_be_inserted(obj/item/W, stop_messages) //We don't need to stop messages, but it can be left in.
		if( ..() ) //If the parent did their thing, this should be fine. It pretty much handles all the checks.
			if(istype(W,/obj/item/weapon/gun)) //Is it a gun?
				if(holds_guns_now == holds_guns_max) //Are we at our gun capacity?
					if(!stop_messages) usr << "<span class='warning'>[src] already holds a gun.</span>"
					return //Nothing else to do.
			else //Must be ammo.
			//We have slots open for the gun, so in total we should have storage_slots - guns_max in slots, plus whatever is already in the belt.
				if(( (storage_slots - holds_guns_max) + holds_guns_now) <= contents.len) // We're over capacity, and the space is reserved for a gun.
					if(!stop_messages) usr << "<span class='warning'>[src] can't hold any more magazines.</span>"
					return
			return 1

/obj/item/weapon/gun/on_enter_storage(obj/item/weapon/storage/belt/gun/gun_belt)
	if(istype(gun_belt))
		gun_belt.holds_guns_now++ //Slide it in.
		if(!gun_belt.current_gun)
			gun_belt.current_gun = src //If there's no active gun, we want to make this our icon.
			gun_belt.update_gun_icon()

/obj/item/weapon/gun/on_exit_storage(obj/item/weapon/storage/belt/gun/gun_belt)
	if(istype(gun_belt))
		gun_belt.holds_guns_now--
		if(gun_belt.current_gun == src)
			gun_belt.current_gun = null
			gun_belt.update_gun_icon()

/obj/item/weapon/storage/belt/gun/m4a3
	name = "\improper M276 pattern M4A3 holster rig"
	desc = "The M276 is the standard load-bearing equipment of the USCM. It conisists of a modular belt with various clips. This version has a holster assembly that allows one to carry the m4a3 comfortably secure. It also contains three side pouches that can store two spare 9mm magazines."
	can_hold = list(
		"/obj/item/weapon/gun/pistol/m4a3",
		"/obj/item/weapon/gun/pistol/m1911",
		"/obj/item/ammo_magazine/pistol",
		"/obj/item/ammo_magazine/pistol/hp",
		"/obj/item/ammo_magazine/pistol/ap",
		"/obj/item/ammo_magazine/pistol/incendiary",
		"/obj/item/ammo_magazine/pistol/extended",
		"/obj/item/ammo_magazine/pistol/m1911"
		)

	New()
		select_gamemode_skin(type)
		..()

/obj/item/weapon/storage/belt/gun/m4a3/full/New()
	..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/m4a3(src)
	new /obj/item/ammo_magazine/pistol/hp(src)
	new /obj/item/ammo_magazine/pistol/extended(src)
	new /obj/item/ammo_magazine/pistol/extended(src)
	new_gun.on_enter_storage(src)

/obj/item/weapon/storage/belt/gun/m44
	name = "\improper M276 pattern m44 holster rig"
	desc = "The M276 is the standard load-bearing equipment of the USCM. It conisists of a modular belt with various clips. This version is for the m44 magnum revolver, along with three pouches for speedloaders. It faintly smells of hay."
	icon_state = "m44_holster"
	item_state = "m44_holster"
	max_w_class = 6
	can_hold = list(
		"/obj/item/weapon/gun/revolver/m44",
		"/obj/item/ammo_magazine/revolver",
		"/obj/item/ammo_magazine/revolver/marksman",
		"/obj/item/ammo_magazine/revolver/heavy"
		)

/obj/item/weapon/storage/belt/gun/m44/full/New()
	..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/revolver/m44(src)
	new /obj/item/ammo_magazine/revolver/marksman(src)
	new /obj/item/ammo_magazine/revolver/marksman(src)
	new /obj/item/ammo_magazine/revolver/marksman(src)
	new_gun.on_enter_storage(src)

/obj/item/weapon/storage/belt/gun/m39
	name = "\improper M276 pattern M39 holster rig"
	desc = "The M276 is the standard load-bearing equipment of the USCM. It conisists of a modular belt with various clips. This version is designed for the m39 SMG, and features a larger frame to support the gun. Due to its unorthodox design, it isn't a very common sight, and is only specially issued."
	icon_state = "m39_holster"
	item_state = "m39_holster"
	storage_slots = 1
	max_combined_w_class = 4
	max_w_class = 4
	can_hold = list(
		"/obj/item/weapon/gun/smg/m39",
		"/obj/item/weapon/gun/smg/m39/elite",
		"/obj/item/ammo_magazine/smg/m39",
		"/obj/item/ammo_magazine/smg/m39/ap",
		"/obj/item/ammo_magazine/smg/m39/extended"
		)

/obj/item/weapon/storage/belt/gun/m39/full/New()
	..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/smg/m39(src)
	new_gun.on_enter_storage(src)

/obj/item/weapon/storage/belt/marine
	name = "\improper M276 pattern ammo load rig"
	desc = "The M276 is the standard load-bearing equipment of the USCM. It conisists of a modular belt with various clips. This version is the standard variant designed for bulk ammunition carrying operations."
	icon_state = "marinebelt"
	w_class = 4
	storage_slots = 6
	max_combined_w_class = 12
	can_hold = list(
		"/obj/item/weapon/combat_knife",
		"/obj/item/device/flashlight/flare",
		"/obj/item/ammo_magazine",
		"/obj/item/flareround_s",
		"/obj/item/flareround_sp",
		"/obj/item/weapon/grenade",
		"/obj/item/device/mine",
		"/obj/item/weapon/reagent_containers/food/snacks",
		"/obj/item/device/flashlight/flare"
		)
	New()
		select_gamemode_skin(type)
		..()

/obj/item/weapon/storage/belt/security/MP
	name = "\improper M276 pattern military police rig"
	desc = "The M276 is the standard load-bearing equipment of the USCM. It conisists of a modular belt with various clips. This version is filled with an array of small pouches, meant to carry non-lethal equipment and restraints."
	icon_state = "securitybelt"
	item_state = "security"
	storage_slots = 6
	max_w_class = 3
	max_combined_w_class = 30
	can_hold = list(
		"/obj/item/weapon/grenade/flashbang",
		"/obj/item/weapon/reagent_containers/spray/pepper",
		"/obj/item/weapon/handcuffs",
		"/obj/item/device/flash",
		"/obj/item/clothing/glasses",
		"/obj/item/weapon/gun/energy/taser",
		"/obj/item/ammo_magazine/pistol",
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
	new /obj/item/weapon/gun/energy/taser(src)
	new /obj/item/device/flash(src)
	new /obj/item/weapon/melee/baton(src)
	new /obj/item/weapon/handcuffs(src)

/obj/item/weapon/storage/belt/knifepouch
	name="\improper M276 pattern knife rig"
	desc="The M276 is the standard load-bearing equipment of the USCM. It conisists of a modular belt with various clips. This version is specially designed with four holsters to store throwing knives. Not commonly issued, but kept in service."
	icon_state="knifebelt"
	item_state="marine" // aslo temp, maybe somebody update these icons with better ones?
	w_class = 3
	storage_slots = 4
	max_w_class = 1
	max_combined_w_class=4

	can_hold=list("/obj/item/weapon/throwing_knife")
	New()
		select_gamemode_skin(type)
		..()
		item_state = "marinebelt" //PLACEHOLDER. Override, since it has no unique state.
		new /obj/item/weapon/throwing_knife(src)
		new /obj/item/weapon/throwing_knife(src)
		new /obj/item/weapon/throwing_knife(src)
		new /obj/item/weapon/throwing_knife(src)

/obj/item/weapon/storage/belt/grenade
	name="\improper M276 pattern M40 HEDP rig"
	desc="The M276 is the standard load-bearing equipment of the USCM. It conisists of a modular belt with various clips. This version is designed to carry bulk quantities of M40 HEDP Grenades."
	icon_state="grenadebelt" // temp
	item_state="s_marine"
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
	name="\improper G8 general utility pouch"
	desc="A small, lightweight pouch that can be clipped onto Armat Systems M3 Pattern armor to provide additional storage. Unfortunately, this pouch uses the same securing system as most Armat platform weaponry, and thus only one can be clipped to the M3 Pattern Armor."
	storage_slots = 3
	w_class = 4
	max_w_class = 3
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state="sparepouch"
	item_state="marine_s"

//============================//GOGGLES\\================================\\
//=======================================================================\\

///////////////////////////////////////////////////////////////////////
//Glasses
/*
SEE_SELF  // can see self, no matter what
SEE_MOBS  // can see all mobs, no matter what
SEE_OBJS  // can see all objs, no matter what
SEE_TURFS // can see all turfs (and areas), no matter what
SEE_PIXELS// if an object is located on an unlit area, but some of its pixels are
          // in a lit area (via pixel_x,y or smooth movement), can see those pixels
BLIND     // can't see anything
*/
/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	w_class = 2.0
	flags_inventory = COVEREYES
	flags_equip_slot = SLOT_EYES
	var/vision_flags = 0
	var/darkness_view = 0//Base human is 2
	var/invisa_view = 0
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/eyes.dmi')

/obj/item/clothing/glasses/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_glasses()

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