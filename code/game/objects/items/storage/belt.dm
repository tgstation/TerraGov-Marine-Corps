
/obj/item/storage/belt
	name = "belt"
	desc = "Can hold various things."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utilitybelt"
	item_state = "utility"
	item_state_worn = TRUE
	flags_equip_slot = ITEM_SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined")
	w_class = WEIGHT_CLASS_BULKY
	flags_storage = STORAGE_FLAG_DRAWMODE_ALLOWED

/obj/item/storage/belt/equipped(mob/user, slot)
	if(slot == SLOT_BELT)
		mouse_opacity = 2 //so it's easier to click when properly equipped.
	..()

/obj/item/storage/belt/dropped(mob/user)
	mouse_opacity = initial(mouse_opacity)
	..()

/obj/item/storage/belt/champion
	name = "championship belt"
	desc = "Proves to the world that you are the strongest!"
	icon_state = "championbelt"
	item_state = "champion"
	storage_slots = 1
	can_hold = list(
		/obj/item/clothing/mask/luchador,
	)

/*============================//MARINE BELTS\\==================================
=======================================================================*/

/obj/item/storage/belt/utility
	name = "\improper M276 pattern toolbelt rig" //Carn: utility belt is nicer, but it bamboozles the text parsing.
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version lacks any combat functionality, and is commonly used by engineers to transport important tools."
	icon_state = "utilitybelt"
	item_state = "utility"
	can_hold = list(
		/obj/item/tool/crowbar,
		/obj/item/tool/screwdriver,
		/obj/item/tool/weldingtool,
		/obj/item/tool/wirecutters,
		/obj/item/tool/wrench,
		/obj/item/multitool,
		/obj/item/flashlight,
		/obj/item/stack/cable_coil,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/tool/taperoll/engineering,
	)

/obj/item/storage/belt/utility/full
	spawns_with = list(
		/obj/item/tool/screwdriver,
		/obj/item/tool/wrench,
		/obj/item/tool/weldingtool,
		/obj/item/tool/crowbar,
		/obj/item/tool/wirecutters,
		/obj/item/multitool,
	)

/obj/item/storage/belt/utility/full/PopulateContents()
	. = ..()
	new /obj/item/stack/cable_coil(src, 30)

/obj/item/storage/belt/utility/atmostech
	spawns_with = list(
		/obj/item/tool/screwdriver,
		/obj/item/tool/wrench,
		/obj/item/tool/weldingtool,
		/obj/item/tool/crowbar,
		/obj/item/tool/wirecutters,
		/obj/item/t_scanner,
	)

/obj/item/storage/belt/medical
	name = "\improper M276 pattern medical storage rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is a less common configuration, designed to transport medical supplies, and light ammunitions."
	icon_state = "medicalbelt"
	item_state = "medical"
	storage_slots = 14 //can hold 2 "rows" of very limited medical equipment and ammo.
	max_w_class = 3
	max_storage_space = 29

	can_hold = list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/tool/lighter,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/flashlight/pen,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/gloves/latex,
		/obj/item/storage/syringe_case,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/smg/m25,
		/obj/item/ammo_magazine/smg/standard_smg,
		/obj/item/ammo_magazine/smg/standard_machinepistol,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/handful,
		/obj/item/flashlight/flare,
		/obj/item/explosive/grenade/flare,
		/obj/item/reagent_containers/hypospray,
		/obj/item/bodybag,
		/obj/item/defibrillator,
		/obj/item/storage/pill_bottle/packet,
		/obj/item/roller,
	)

/obj/item/storage/belt/medical
	spawns_with = list(
		/obj/item/defibrillator,
		/obj/item/bodybag/cryobag,
		/obj/item/roller,
		/obj/item/storage/pill_bottle/bicaridine,
		/obj/item/storage/pill_bottle/kelotane,
		/obj/item/storage/pill_bottle/tramadol,
		/obj/item/storage/pill_bottle/dylovene,
		/obj/item/storage/pill_bottle/inaprovaline,
		/obj/item/storage/pill_bottle/dexalin,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus,
		/obj/item/storage/pill_bottle/spaceacillin,
		/obj/item/storage/pill_bottle/hypervene,
		/obj/item/healthanalyzer,
	)

/obj/item/storage/belt/combatLifesaver
	name = "\improper M276 pattern lifesaver bag"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. This configuration mounts a duffel bag filled with a range of injectors and light medical supplies and is common among medics."
	icon_state = "medicalbag"
	item_state = "medicbag"
	storage_slots = 21 //can hold 3 "rows" of very limited medical equipment, but it *should* give a decent boost to squad medics.
	max_storage_space = 42
	max_w_class = 2
	can_hold = list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/storage/pill_bottle,
		/obj/item/storage/syringe_case,
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/storage/pill_bottle/packet,
		/obj/item/stack/medical,
	)

/obj/item/storage/belt/combatLifesaver
	spawns_with = list(
		/obj/item/stack/medical/advanced/bruise_pack = 2,
		/obj/item/stack/medical/advanced/ointment = 2,
		/obj/item/stack/medical/splint = 2,
		/obj/item/storage/pill_bottle/bicaridine = 1,
		/obj/item/storage/pill_bottle/kelotane = 1,
		/obj/item/storage/pill_bottle/dylovene = 1,
		/obj/item/storage/pill_bottle/tramadol = 1,
		/obj/item/storage/pill_bottle/inaprovaline = 1,
		/obj/item/storage/pill_bottle/peridaxon = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat = 3,
		/obj/item/storage/syringe_case/combat = 3,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dexalinplus = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/hypervene = 1,
	)

/obj/item/storage/belt/medicLifesaver
	name = "\improper M276 pattern lifesaver medic bag"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. This configuration mounts a duffel bag filled with a range of injectors and light medical supplies and is common among medics."
	icon_state = "medicalbag"
	item_state = "medicbag"
	storage_slots = 21 //can hold 3 "rows" of very limited medical equipment, but it *should* give a decent boost to squad medics.
	max_storage_space = 42
	max_w_class = 2
	can_hold = list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/storage/pill_bottle,
		/obj/item/storage/syringe_case,
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/storage/pill_bottle/packet,
		/obj/item/stack/medical,
	)

/obj/item/storage/belt/medicLifesaver
	spawns_with = list(
		/obj/item/stack/medical/advanced/bruise_pack = 3,
		/obj/item/stack/medical/advanced/ointment = 3,
		/obj/item/stack/medical/splint = 3,
		/obj/item/storage/pill_bottle/bicaridine = 1,
		/obj/item/storage/pill_bottle/kelotane = 1,
		/obj/item/storage/pill_bottle/dylovene = 1,
		/obj/item/storage/pill_bottle/tramadol = 1,
		/obj/item/storage/pill_bottle/inaprovaline = 1,
		/obj/item/storage/pill_bottle/peridaxon = 1,
		/obj/item/storage/pill_bottle/quickclot = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat = 3,
		/obj/item/reagent_containers/hypospray/autoinjector/dexalinplus = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/hypervene = 1,
	)

/obj/item/storage/belt/combatLifesaver/upp
	name ="\improper Type 41 pattern lifesaver bag"
	desc = "The Type 41 load rig is the standard-issue LBE of the UPP military. This configuration mounts a satchel filled with a range of injectors and light medical supplies, common among medics and partisans."
	icon_state = "medicalbag_u"
	item_state = "medicbag_u"

/obj/item/storage/belt/combatLifesaver/som
	name = "\improper S17 lifesaver bag"
	desc = "A belt with heavy origins from the belt used by paramedics and doctors in the old mining colonies."
	icon_state = "medicbag_som"
	item_state = "medicbag_som"

/obj/item/storage/belt/security
	name = "\improper M276 pattern security rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This configuration is commonly seen among TGMC Military Police and peacekeepers, though it can hold some light munitions."
	icon_state = "securitybelt"
	item_state = "security"//Could likely use a better one.
	storage_slots = 7
	max_w_class = 3
	max_storage_space = 21
	can_hold = list(
		/obj/item/explosive/grenade/flashbang,
		/obj/item/explosive/grenade/chem_grenade/teargas,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/clothing/glasses,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/handful,
		/obj/item/reagent_containers/food/snacks/donut,
		/obj/item/weapon/baton,
		/obj/item/weapon/gun/energy/taser,
		/obj/item/tool/lighter/zippo,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/clothing/glasses/hud/security,
		/obj/item/flashlight,
		/obj/item/radio/headset,
		/obj/item/weapon,
		/obj/item/tool/taperoll/police,
	)

/obj/item/storage/belt/security/tactical
	name = "combat belt"
	desc = "Can hold security gear like handcuffs and flashes, with more pouches for more storage."
	icon_state = "swatbelt"
	item_state = "swatbelt"
	storage_slots = 9
	max_w_class = 3
	max_storage_space = 21

/obj/item/storage/belt/security/marine_police
	name = "\improper M276 pattern military police rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is filled with an array of small pouches, meant to carry non-lethal equipment and restraints."
	storage_slots = 6
	max_w_class = 3
	max_storage_space = 30

/obj/item/storage/belt/security/marine_police/full
	spawns_with = list(
		/obj/item/weapon/gun/energy/taser,
		/obj/item/flash,
		/obj/item/weapon/baton,
		/obj/item/restraints/handcuffs,
	)

/obj/item/storage/belt/marine
	name = "\improper M276 pattern ammo load rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is the standard variant designed for bulk ammunition-carrying operations."
	icon_state = "marinebelt"
	item_state = "marinebelt"
	w_class = WEIGHT_CLASS_BULKY
	storage_slots = 5
	max_w_class = 3
	max_storage_space = 15
	can_hold = list(
		/obj/item/weapon/combat_knife,
		/obj/item/attachable/bayonetknife,
		/obj/item/flashlight/flare,
		/obj/item/explosive/grenade/flare,
		/obj/item/ammo_magazine/rifle,
		/obj/item/cell/lasgun,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/handful,
		/obj/item/explosive/grenade,
		/obj/item/explosive/mine,
		/obj/item/reagent_containers/food/snacks,
	)

/obj/item/storage/belt/marine/t18
	spawns_with = list(/obj/item/ammo_magazine/rifle/standard_carbine = 5)

/obj/item/storage/belt/marine/t12
	spawns_with = list(/obj/item/ammo_magazine/rifle/standard_assaultrifle = 5)

/obj/item/storage/belt/marine/t90
	spawns_with = list(/obj/item/ammo_magazine/smg/standard_smg = 5)

/obj/item/storage/belt/marine/antimaterial
	spawns_with = list(
		/obj/item/ammo_magazine/sniper/flak,
		/obj/item/ammo_magazine/sniper/flak,
		/obj/item/ammo_magazine/sniper/incendiary,
		/obj/item/ammo_magazine/sniper/incendiary,
		/obj/item/ammo_magazine/sniper,
	)

/obj/item/storage/belt/marine/tx8
	spawns_with = list(
		/obj/item/ammo_magazine/rifle/tx8/impact,
		/obj/item/ammo_magazine/rifle/tx8/impact,
		/obj/item/ammo_magazine/rifle/tx8/incendiary,
		/obj/item/ammo_magazine/rifle/tx8/incendiary,
		/obj/item/ammo_magazine/rifle/tx8,
	)

/obj/item/storage/belt/marine/upp
	name = "\improper Type 41 pattern load rig"
	desc = "The Type 41 load rig is the standard-issue LBE of the USL pirates. The primary function of this belt is to provide easy access to mags for the Type 71 during operations. Despite being designed for the Type 71 weapon system, the pouches are modular enough to fit other types of ammo and equipment."
	icon_state = "upp_belt"
	item_state = "upp_belt"

//version full of type 71 mags
/obj/item/storage/belt/marine/upp/full
	spawns_with = list(
		/obj/item/ammo_magazine/rifle/type71 = 5,
	)

/obj/item/storage/belt/marine/som
	name = "\improper S18 ammo belt"
	desc = "A belt with origins traced to the M276 ammo belt and some old colony security."
	icon_state = "som_belt"
	item_state = "som_belt"

/obj/item/storage/belt/marine/sectoid
	name = "\improper strange ammo belt"
	desc = "A belt made of a strong but unusual fabric, with clips to hold your equipment."
	icon_state = "swatbelt"
	item_state = "swatbelt"
	can_hold = list(
		/obj/item/weapon/combat_knife,
		/obj/item/attachable/bayonetknife,
		/obj/item/explosive/grenade,
		/obj/item/ammo_magazine/rifle,
		/obj/item/cell/lasgun,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/handful,
		/obj/item/explosive/grenade,
		/obj/item/tool/crowbar,
	)

/obj/item/storage/belt/shotgun
	name = "\improper shotgun shell load rig"
	desc = "An ammunition belt designed to hold shotgun shells or individual bullets."
	icon_state = "shotgunbelt"
	item_state = "shotgunbelt"
	w_class = WEIGHT_CLASS_BULKY
	storage_slots = 14
	max_w_class = 2
	max_storage_space = 28
	can_hold = list(/obj/item/ammo_magazine/handful)

/obj/item/storage/belt/shotgun/attackby(obj/item/attackedby, mob/user, params)
	if(istype(attackedby, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/magazine = attackedby

		if(magazine.flags_magazine & AMMUNITION_REFILLABLE)
			if(!magazine.current_rounds)
				to_chat(user, "<span class='warning'>[magazine] is empty.</span>")
				return

			if(length(contents) >= storage_slots)
				to_chat(user, "<span class='warning'>[src] is full.</span>")
				return

			to_chat(user, "<span class='notice'>You start refilling [src] with [magazine].</span>")
			if(!do_after(user, 1.5 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
				return

			for(var/x in 1 to (storage_slots - length(contents)))
				var/cont = handle_item_insertion(magazine.create_handful(), user, TRUE)
				if(!cont)
					break

			playsound(user.loc, "rustle", 15, TRUE, 6)
			to_chat(user, "<span class='notice'>You refill [src] with [magazine].</span>")
			return TRUE

	return ..()

/obj/item/storage/belt/shotgun/martini
	name = "martini henry ammo belt"
	desc = "A belt good enough for holding all your .577/400 ball rounds."
	icon_state = ".557_belt"
	storage_slots = 12
	max_storage_space = 24

	flags_storage = STORAGE_FLAG_DRAWMODE_TOGGLED|STORAGE_FLAG_DRAWMODE_ALLOWED

	flags_atom = DIRLOCK

/obj/item/storage/belt/shotgun/martini/update_icon()
	if(!contents.len)
		icon_state = initial(icon_state) + "_e"
		return
	icon_state = initial(icon_state)

	var/holding = round((contents.len + 1) / 2)
	setDir(holding + round(holding/3))

/obj/item/storage/belt/shotgun/martini/attackby(obj/item/attackedby, mob/user, params)
	if(istype(attackedby, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/new_mag = attackedby
		if(new_mag.caliber != CALIBER_557)
			to_chat(user, "<span class='notice'>[src] can only be filled with .557/440 ball rifle rounds.</span>")
			return
	. = ..()
	update_icon()

/obj/item/storage/belt/shotgun/martini/attack_hand(mob/living/user)
	if (loc != user)
		. = ..()
		close_watchers()

	if(!(flags_storage & STORAGE_FLAG_DRAWMODE_TOGGLED) || !ishuman(user) && !contents.len)
		open(user)

	if(!length(contents))
		return

	var/obj/item/item = contents[contents.len]
	if(!istype(item, /obj/item/ammo_magazine/handful))
		return

	var/obj/item/ammo_magazine/handful/existing_handful = item

	if(existing_handful.current_rounds == 1)
		user.put_in_hands(existing_handful)
		return

	existing_handful.create_handful(user, 1)
	update_icon()

/obj/item/storage/belt/knifepouch
	name="\improper M276 pattern knife rig"
	desc="The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is specially designed with four holsters to store throwing knives. Not commonly issued, but kept in service."
	icon_state="knifebelt"
	item_state="knifebelt"
	w_class = WEIGHT_CLASS_NORMAL
	storage_slots = 6
	max_w_class = 1
	max_storage_space = 6

	can_hold = list(/obj/item/weapon/throwing_knife)

/obj/item/storage/belt/knifepouch
	spawns_with = list(/obj/item/weapon/throwing_knife = 6)

/obj/item/storage/belt/grenade
	name="\improper M276 pattern M40 HEDP rig"
	desc="The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is designed to carry bulk quantities of M40 HEDP Grenades."
	icon_state="grenadebelt" // temp
	item_state="grenadebelt"
	w_class = WEIGHT_CLASS_BULKY
	storage_slots = 9
	max_w_class = 3
	max_storage_space = 27
	can_hold = list(/obj/item/explosive/grenade)

/obj/item/storage/belt/grenade/standard
	spawns_with = list(
		/obj/item/explosive/grenade/incendiary = 4,
		/obj/item/explosive/grenade/frag = 4,
	)

/obj/item/storage/belt/grenade/b17
	name = "\improper M276 pattern M40 HEDP rig Mk II"
	w_class = WEIGHT_CLASS_BULKY
	storage_slots = 16
	max_w_class = 3
	max_storage_space = 48
	can_hold = list(/obj/item/explosive/grenade)

/obj/item/storage/belt/grenade/b17
	spawns_with = list(
		/obj/item/explosive/grenade/incendiary = 8,
		/obj/item/explosive/grenade/frag = 8,
	)

/obj/item/storage/belt/sparepouch
	name= "\improper G8 general utility pouch"
	desc= "A small, lightweight pouch that can be clipped onto Armat Systems M3 Pattern armor or your belt to provide additional storage for miscellaneous gear or box and drum magazines."
	storage_slots = 3
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = 3
	icon_state= "sparepouch"
	item_state= "sparepouch"

////////////////////////////// GUN BELTS /////////////////////////////////////

/obj/item/storage/belt/gun
	name = "pistol belt"
	desc = "A belt-holster assembly that allows one to hold a pistol and two magazines."
	icon_state = "m4a3_holster"
	item_state = "m4a3_holster"
	use_sound = null
	w_class = WEIGHT_CLASS_BULKY
	storage_slots = 7
	max_storage_space = 15
	max_w_class = 3
	///Generic variable to determine if the holster already holds a gun.
	var/holds_guns_now = FALSE
	///How many guns can it hold? I think this can be any thing from 1 to whatever. Should calculate properly.
	var/holds_guns_max = 1
	///The gun it holds, used for referencing later so we can update the icon.
	var/obj/item/weapon/gun/current_gun
	///Cache of the gun image to be drawn
	var/image/gun_underlay
	///Sound to play when the gun is returned to the belt
	var/sheatheSound = 'sound/weapons/guns/misc/pistol_sheathe.ogg'
	///Sound to play when the gun is drawn from the belt
	var/drawSound = 'sound/weapons/guns/misc/pistol_draw.ogg'
	can_hold = list(
		/obj/item/weapon/gun/pistol,
		/obj/item/ammo_magazine/pistol,
	)

/obj/item/storage/belt/gun/Destroy()
	if(gun_underlay)
		qdel(gun_underlay)
		gun_underlay = null
	if(current_gun)
		qdel(current_gun)
		current_gun = null
	. = ..()

/obj/item/storage/belt/gun/attack_hand(mob/living/user)
	if(current_gun && ishuman(user) && loc == user)
		current_gun.attack_hand(user)
	else
		return ..()

///Update our icon when our contents change from gun insertion/removal
/obj/item/storage/belt/gun/proc/update_gun_icon() //We do not want to use regular update_icon as it's called for every item inserted. Not worth the icon math.
	var/mob/user = loc
	if(holds_guns_now) //So it has a gun, let's make an icon.
		/*
		Have to use a workaround here, otherwise images won't display properly at all times.
		Reason being, transform is not displayed when right clicking/alt+clicking an object,
		so it's necessary to pre-load the potential states so the item actually shows up
		correctly without having to rotate anything. Preloading weapon icons also makes
		sure that we don't have to do any extra calculations.
		*/
		playsound(src,drawSound, 15, 1)
		gun_underlay = image(icon, src, current_gun.icon_state)
		icon_state += "_g"
		item_state = icon_state
		underlays += gun_underlay
	else
		playsound(src,sheatheSound, 15, 1)
		underlays -= gun_underlay
		icon_state = copytext(icon_state,1,-2)
		item_state = icon_state
		qdel(gun_underlay)
		gun_underlay = null
	if(istype(user)) user.update_inv_belt()
	if(istype(user)) user.update_inv_s_store()

//There are only two types here that can be inserted, and they are mutually exclusive. We only track the gun.
/obj/item/storage/belt/gun/can_be_inserted(obj/item/item, mob/user, warning) //We don't need to stop messages, but it can be left in.
	. = ..()
	if(!.) //If the parent did their thing, this should be fine. It pretty much handles all the checks.
		return
	if(istype(item,/obj/item/weapon/gun)) //Is it a gun?
		if(holds_guns_now == holds_guns_max) //Are we at our gun capacity?
			if(warning)
				to_chat(user, "<span class='warning'>[src] already holds a gun.</span>")
			return FALSE
	else //Must be ammo.
	//We have slots open for the gun, so in total we should have storage_slots - guns_max in slots, plus whatever is already in the belt.
		if(((storage_slots - holds_guns_max) + holds_guns_now) <= length(contents)) // We're over capacity, and the space is reserved for a gun.
			if(warning)
				to_chat(user, "<span class='warning'>[src] can't hold any more magazines.</span>")
			return FALSE
	return TRUE

//This deliniates between belt/gun/pistol and belt/gun/revolver
/obj/item/storage/belt/gun/pistol
	name = "generic pistol belt"
	desc = "A pistol belt that is not a revolver belt"
	icon_state = "m4a3_holster"
	item_state = "m4a3_holster"

/obj/item/storage/belt/gun/pistol/attackby_alternate(obj/item/item, mob/user, params)
	if(!istype(item, /obj/item/weapon/gun/pistol))
		return ..()
	var/obj/item/weapon/gun/pistol/gun = item
	for(var/obj/item/ammo_magazine/mag in contents)
		if(!istype(gun, mag.gun_type))
			continue
		if(user.l_hand && user.r_hand || gun.current_mag)
			gun.tactical_reload(mag, user)
		else
			gun.reload(user, mag)
		orient2hud()
		return

/obj/item/storage/belt/gun/pistol/examine(mob/user, distance, infix, suffix)
	. = ..()
	to_chat(user, "<span class='notice'>To perform a reload with the amunition inside, disable right click and right click on the belt with an empty pistol.</span>")

/obj/item/storage/belt/gun/pistol/m4a3
	name = "\improper M4A3 holster rig"
	desc = "The M4A3 is a common holster belt. It consists of a modular belt with various clips. This version has a holster assembly that allows one to carry a handgun. It also contains side pouches that can store 9mm or .45 magazines."
	can_hold = list(
		/obj/item/weapon/gun/pistol,
		/obj/item/ammo_magazine/pistol,
	)

/obj/item/storage/belt/gun/pistol/m4a3/full
	spawns_with = list(
		/obj/item/weapon/gun/pistol/rt3,
		/obj/item/ammo_magazine/pistol/ap,
		/obj/item/ammo_magazine/pistol/hp,
		/obj/item/ammo_magazine/pistol/extended,
		/obj/item/ammo_magazine/pistol/extended,
		/obj/item/ammo_magazine/pistol/extended,
		/obj/item/ammo_magazine/pistol/extended,
	)

/obj/item/storage/belt/gun/pistol/m4a3/officer
	spawns_with = list(
		/obj/item/weapon/gun/pistol/rt3 = 1,
		/obj/item/ammo_magazine/pistol/hp = 2,
		/obj/item/ammo_magazine/pistol/ap = 4,
	)

/obj/item/storage/belt/gun/pistol/m4a3/fieldcommander
	spawns_with = list(
		/obj/item/weapon/gun/pistol/m1911/custom = 1,
		/obj/item/ammo_magazine/pistol/m1911 = 6,
	)

/obj/item/storage/belt/gun/pistol/m4a3/vp70
	spawns_with = list(
		/obj/item/weapon/gun/pistol/vp70 = 1,
		/obj/item/ammo_magazine/pistol/vp70 = 6,
	)

/obj/item/storage/belt/gun/pistol/m4a3/vp78
	spawns_with = list(
		/obj/item/weapon/gun/pistol/vp78 = 1,
		/obj/item/ammo_magazine/pistol/vp78 = 6,
	)

/obj/item/storage/belt/gun/pistol/m4a3/som
	name = "\improper S19 holster rig"
	desc = "A belt with origins to old colony security holster rigs."
	icon_state = "som_belt_pistol"
	item_state = "som_belt_pistol"

/obj/item/storage/belt/gun/pistol/stand
	name = "\improper M276 pattern M4A3 holster rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version has a holster assembly that allows one to carry the M4A3 comfortably secure. It also contains side pouches that can store 9mm or .45 magazines."
	can_hold = list(
		/obj/item/weapon/gun/pistol,
		/obj/item/ammo_magazine/pistol,
	)

/obj/item/storage/belt/gun/pistol/standard_pistol
	name = "\improper T457 pattern pistol holster rig"
	desc = "The T457 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips."
	icon_state = "tp14_holster"
	item_state = "tp14_holster"

/obj/item/storage/belt/gun/revolver/standard_revolver
	name = "\improper T457 pattern revolver holster rig"
	desc = "The T457 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips."
	icon_state = "tp44_holster"
	item_state = "tp44_holster"
	bypass_w_limit = list(
		/obj/item/weapon/gun/revolver,
	)
	can_hold = list(
		/obj/item/weapon/gun/revolver,
		/obj/item/ammo_magazine/revolver,
	)

/obj/item/storage/belt/gun/m44
	name = "\improper M276 pattern M44 holster rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is for the M44 magnum revolver, along with three pouches for speedloaders."
	icon_state = "m44_holster"
	item_state = "m44_holster"
	can_hold = list(
		/obj/item/weapon/gun/revolver,
		/obj/item/ammo_magazine/revolver,
	)

/obj/item/storage/belt/gun/m44/full
	spawns_with = list(
		/obj/item/weapon/gun/revolver/m44 = 1,
		/obj/item/ammo_magazine/revolver/heavy = 1,
		/obj/item/ammo_magazine/revolver/marksman = 1,
		/obj/item/ammo_magazine/revolver = 4,
	)

/obj/item/storage/belt/gun/mateba
	name = "\improper M276 pattern Mateba holster rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is for the powerful Mateba magnum revolver, along with three pouches for speedloaders."
	icon_state = "mateba_holster"
	item_state = "mateba_holster"
	bypass_w_limit = list(
		/obj/item/weapon/gun/revolver/mateba,
	)
	can_hold = list(
		/obj/item/weapon/gun/revolver/mateba,
		/obj/item/ammo_magazine/revolver/mateba,
	)

/obj/item/storage/belt/gun/mateba/full
	spawns_with = list(
		/obj/item/weapon/gun/revolver/mateba = 1,
		/obj/item/ammo_magazine/revolver/mateba = 6,
	)

/obj/item/storage/belt/gun/mateba/captain
	icon_state = "c_mateba_holster"
	item_state = "c_mateba_holster"

/obj/item/storage/belt/gun/mateba/captain/full
	spawns_with = list(
		/obj/item/weapon/gun/revolver/mateba/captain = 1,
		/obj/item/ammo_magazine/revolver/mateba = 6,
	)

/obj/item/storage/belt/gun/mateba/notmarine
	icon_state = "a_mateba_holster"
	item_state = "a_mateba_holster"
	spawns_with = list(
		/obj/item/weapon/gun/revolver/mateba = 1,
		/obj/item/ammo_magazine/revolver/mateba = 6,
	)

/obj/item/storage/belt/gun/korovin
	name = "\improper Type 41 pistol holster rig"
	desc = "A modification of the standard UPP pouch rig to carry a single Korovin PK-9 pistol. It also contains side pouches that can store .22 magazines, either hollowpoints or tranquilizers."
	icon_state = "korovin_holster"
	item_state = "korovin_holster"
	can_hold = list(
		/obj/item/weapon/gun/pistol/c99,
		/obj/item/ammo_magazine/pistol/c99,
		/obj/item/ammo_magazine/pistol/c99t,
	)

/obj/item/storage/belt/gun/korovin/standard
	spawns_with = list(
		/obj/item/weapon/gun/pistol/c99 = 1,
		/obj/item/ammo_magazine/pistol/c99 = 6,
	)

/obj/item/storage/belt/gun/korovin/tranq
	spawns_with = list(
		/obj/item/weapon/gun/pistol/c99/tranq = 1,
		/obj/item/ammo_magazine/pistol/c99t = 3,
		/obj/item/ammo_magazine/pistol/c99 = 3,
	)

/obj/item/storage/belt/gun/ts34
	name = "\improper M276 pattern TS-34 shotgun holster rig"
	desc = "A purpose built belt-holster assembly that holds a TS-34 shotgun and one shell box or 2 handfuls."
	icon_state = "ts34_holster"
	item_state = "ts34_holster"
	max_w_class = 4 //So it can hold the shotgun.
	w_class = WEIGHT_CLASS_BULKY
	storage_slots = 3
	max_storage_space = 8
	can_hold = list(
		/obj/item/weapon/gun/shotgun/double/marine,
		/obj/item/ammo_magazine/shotgun,
		/obj/item/ammo_magazine/handful,
	)

/obj/item/storage/belt/gun/ts34/full
	spawns_with = list(/obj/item/weapon/gun/shotgun/double/marine, /obj/item/ammo_magazine/shotgun)
