

/obj/item/storage/belt
	name = "belt"
	desc = "Can hold various things."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utilitybelt"
	item_state = "utility"
	flags_equip_slot = SLOT_WAIST
	attack_verb = list("whipped", "lashed", "disciplined")
	w_class = 4
	allow_drawing_method = TRUE



/obj/item/storage/belt/equipped(mob/user, slot)
	if(slot == WEAR_WAIST)
		mouse_opacity = 2 //so it's easier to click when properly equipped.
	..()

/obj/item/storage/belt/dropped(mob/user)
	mouse_opacity = initial(mouse_opacity)
	..()




/obj/item/storage/belt/soulstone
	name = "soul stone belt"
	desc = "Designed for ease of access to the shards during a fight, as to not let a single enemy spirit slip away"
	icon_state = "soulstonebelt"
	item_state = "soulstonebelt"
	storage_slots = 6
	can_hold = list(
		"/obj/item/device/soulstone"
		)


/obj/item/storage/belt/champion
	name = "championship belt"
	desc = "Proves to the world that you are the strongest!"
	icon_state = "championbelt"
	item_state = "champion"
	storage_slots = 1
	can_hold = list(
		"/obj/item/clothing/mask/luchador"
		)






//============================//MARINE BELTS\\==================================\\
//=======================================================================\\


/obj/item/storage/belt/utility
	name = "\improper M276 pattern toolbelt rig" //Carn: utility belt is nicer, but it bamboozles the text parsing.
	desc = "The M276 is the standard load-bearing equipment of the USCM. It consists of a modular belt with various clips. This version lacks any combat functionality, and is commonly used by engineers to transport important tools."
	icon_state = "utilitybelt"
	item_state = "utility"
	can_hold = list(
		"/obj/item/tool/crowbar",
		"/obj/item/tool/screwdriver",
		"/obj/item/tool/weldingtool",
		"/obj/item/tool/wirecutters",
		"/obj/item/tool/wrench",
		"/obj/item/device/multitool",
		"/obj/item/device/flashlight",
		"/obj/item/stack/cable_coil",
		"/obj/item/device/t_scanner",
		"/obj/item/device/analyzer",
		"/obj/item/tool/taperoll/engineering")


/obj/item/storage/belt/utility/full/New()
	..()
	new /obj/item/tool/screwdriver(src)
	new /obj/item/tool/wrench(src)
	new /obj/item/tool/weldingtool(src)
	new /obj/item/tool/crowbar(src)
	new /obj/item/tool/wirecutters(src)
	new /obj/item/stack/cable_coil(src,30,pick("red","yellow","orange"))
	new /obj/item/device/multitool(src)


/obj/item/storage/belt/utility/atmostech/New()
	..()
	new /obj/item/tool/screwdriver(src)
	new /obj/item/tool/wrench(src)
	new /obj/item/tool/weldingtool(src)
	new /obj/item/tool/crowbar(src)
	new /obj/item/tool/wirecutters(src)
	new /obj/item/device/t_scanner(src)

/obj/item/storage/belt/medical
	name = "\improper M276 pattern medical storage rig"
	desc = "The M276 is the standard load-bearing equipment of the USCM. It consists of a modular belt with various clips. This version is a less common configuration, designed to transport medical supplies, and light ammunitions."
	icon_state = "medicalbelt"
	item_state = "medical"
	storage_slots = 14 //can hold 2 "rows" of very limited medical equipment and ammo.
	max_w_class = 3
	max_storage_space = 28

	can_hold = list(
		"/obj/item/device/healthanalyzer",
		"/obj/item/dnainjector",
		"/obj/item/reagent_container/dropper",
		"/obj/item/reagent_container/glass/beaker",
		"/obj/item/reagent_container/glass/bottle",
		"/obj/item/reagent_container/pill",
		"/obj/item/reagent_container/syringe",
		"/obj/item/tool/lighter",
		"/obj/item/storage/fancy/cigarettes",
		"/obj/item/storage/pill_bottle",
		"/obj/item/stack/medical",
		"/obj/item/device/flashlight/pen",
		"/obj/item/clothing/mask/surgical",
		"/obj/item/clothing/gloves/latex",
		"/obj/item/storage/syringe_case",
		"/obj/item/ammo_magazine/pistol",
		"/obj/item/ammo_magazine/revolver",
		"/obj/item/ammo_magazine/handful",
		"/obj/item/device/flashlight/flare",
	    "/obj/item/reagent_container/hypospray",
	    "/obj/item/bodybag",
	    "/obj/item/device/defibrillator",
	    "/obj/item/roller"
	)

/obj/item/storage/belt/medical/New()
	..()
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/storage/pill_bottle/bicaridine(src)
	new /obj/item/storage/pill_bottle/dexalin(src)
	new /obj/item/storage/pill_bottle/antitox(src)
	new /obj/item/storage/pill_bottle/kelotane(src)
	new /obj/item/storage/pill_bottle/spaceacillin(src)
	new /obj/item/storage/pill_bottle/inaprovaline(src)
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/storage/pill_bottle/peridaxon(src)
	new /obj/item/storage/pill_bottle/quickclot(src)


/obj/item/storage/belt/combatLifesaver
	name = "\improper M276 pattern lifesaver bag"
	desc = "The M276 is the standard load-bearing equipment of the USCM. This configuration mounts a duffel bag filled with a range of injectors and light medical supplies and is common among medics."
	icon_state = "medicalbag"
	item_state = "medicbag"
	storage_slots = 21 //can hold 3 "rows" of very limited medical equipment, but it *should* give a decent boost to squad medics.
	max_storage_space = 42
	max_w_class = 2
	can_hold = list(
		"/obj/item/reagent_container/glass/bottle",
		"/obj/item/reagent_container/pill",
		"/obj/item/reagent_container/syringe",
		"/obj/item/storage/pill_bottle",
		"/obj/item/clothing/gloves/latex",
		"/obj/item/reagent_container/hypospray/autoinjector",
		"/obj/item/stack/medical"
	)

/obj/item/storage/belt/combatLifesaver/New()  //The belt, with all it's magic inside!
	..()
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/storage/pill_bottle/bicaridine(src)
	new /obj/item/storage/pill_bottle/dexalin(src)
	new /obj/item/storage/pill_bottle/antitox(src)
	new /obj/item/storage/pill_bottle/kelotane(src)
	new /obj/item/storage/pill_bottle/spaceacillin(src)
	new /obj/item/storage/pill_bottle/inaprovaline(src)
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/storage/pill_bottle/peridaxon(src)
	new /obj/item/storage/pill_bottle/quickclot(src)
	new /obj/item/reagent_container/hypospray/autoinjector/quickclot(src)
	new /obj/item/reagent_container/hypospray/autoinjector/dexP(src)
	new /obj/item/reagent_container/hypospray/autoinjector/dexP(src)
	new /obj/item/reagent_container/hypospray/autoinjector/Oxycodone(src)

/obj/item/storage/belt/combatLifesaver/upp
	icon_state = "medicalbag_u"
	item_state = "medicbag_u"

/obj/item/storage/belt/combatLifesaver/upp/New()  //The belt, with all it's magic inside!
	..()
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/storage/pill_bottle/bicaridine/skillless(src)
	new /obj/item/storage/pill_bottle/dexalin/skillless(src)
	new /obj/item/storage/pill_bottle/antitox/skillless(src)
	new /obj/item/storage/pill_bottle/kelotane/skillless(src)
	new /obj/item/storage/pill_bottle/spaceacillin/skillless(src)
	new /obj/item/storage/pill_bottle/inaprovaline/skillless(src)
	new /obj/item/storage/pill_bottle/tramadol/skillless(src)
	new /obj/item/storage/pill_bottle/peridaxon/skillless(src)
	new /obj/item/reagent_container/hypospray/autoinjector/quickclot(src)
	new /obj/item/reagent_container/hypospray/autoinjector/quickclot(src)
	new /obj/item/reagent_container/hypospray/autoinjector/dexP(src)
	new /obj/item/reagent_container/hypospray/autoinjector/dexP(src)
	new /obj/item/reagent_container/hypospray/autoinjector/Oxycodone(src)

/obj/item/storage/belt/security
	name = "\improper M276 pattern security rig"
	desc = "The M276 is the standard load-bearing equipment of the USCM. It consists of a modular belt with various clips. This configuration is commonly seen among USCM Military Police and peacekeepers, though it can hold some light munitions."
	icon_state = "securitybelt"
	item_state = "security"//Could likely use a better one.
	storage_slots = 7
	max_w_class = 3
	max_storage_space = 21
	can_hold = list(
		"/obj/item/explosive/grenade/flashbang",
		"/obj/item/explosive/grenade/chem_grenade/teargas",
		"/obj/item/reagent_container/spray/pepper",
		"/obj/item/handcuffs",
		"/obj/item/device/flash",
		"/obj/item/clothing/glasses",
		"/obj/item/ammo_magazine/pistol",
		"/obj/item/ammo_magazine/handful",
		"/obj/item/reagent_container/food/snacks/donut/normal",
		"/obj/item/reagent_container/food/snacks/donut/jelly",
		"/obj/item/weapon/baton",
		"/obj/item/weapon/gun/energy/taser",
		"/obj/item/tool/lighter/zippo",
		"/obj/item/cigpacket",
		"/obj/item/clothing/glasses/hud/security",
		"/obj/item/device/flashlight",
		"/obj/item/device/pda",
		"/obj/item/device/radio/headset",
		"/obj/item/weapon",
		"/obj/item/tool/taperoll/police"
		)



/obj/item/storage/belt/security/tactical
	name = "combat belt"
	desc = "Can hold security gear like handcuffs and flashes, with more pouches for more storage."
	icon_state = "swatbelt"
	item_state = "swatbelt"
	storage_slots = 9
	max_w_class = 3
	max_storage_space = 21


/obj/item/storage/belt/security/MP
	name = "\improper M276 pattern military police rig"
	desc = "The M276 is the standard load-bearing equipment of the USCM. It consists of a modular belt with various clips. This version is filled with an array of small pouches, meant to carry non-lethal equipment and restraints."
	storage_slots = 6
	max_w_class = 3
	max_storage_space = 30


/obj/item/storage/belt/security/MP/full/New()
	..()
	new /obj/item/weapon/gun/energy/taser(src)
	new /obj/item/device/flash(src)
	new /obj/item/weapon/baton(src)
	new /obj/item/handcuffs(src)



/obj/item/storage/belt/marine
	name = "\improper M276 pattern ammo load rig"
	desc = "The M276 is the standard load-bearing equipment of the USCM. It consists of a modular belt with various clips. This version is the standard variant designed for bulk ammunition-carrying operations."
	icon_state = "marinebelt"
	w_class = 4
	storage_slots = 5
	max_w_class = 3
	max_storage_space = 15
	can_hold = list(
		"/obj/item/weapon/combat_knife",
		"/obj/item/device/flashlight/flare",
		"/obj/item/ammo_magazine/rifle",
		"/obj/item/ammo_magazine/smg",
		"/obj/item/ammo_magazine/pistol",
		"/obj/item/ammo_magazine/revolver",
		"/obj/item/ammo_magazine/sniper",
		"/obj/item/ammo_magazine/handful",
		"/obj/item/flareround_s",
		"/obj/item/flareround_sp",
		"/obj/item/explosive/grenade",
		"/obj/item/explosive/mine",
		"/obj/item/reagent_container/food/snacks"
		)
	var/has_gamemode_skin = TRUE //whether it has a sprite for each gamemode.

	New()
		if(has_gamemode_skin)
			select_gamemode_skin(type)
		..()

/obj/item/storage/belt/marine/upp
	name = "\improper Type 41 pattern load rig"
	desc = "The Type 41 load rig is the standard-issue LBE of the UPP military. The primary function of this belt is to provide easy access to mags for the Type 71 during operations. Despite being designed for the Type 71 weapon system, the pouches are modular enough to fit other types of ammo and equipment."
	icon_state = "upp_belt"
	item_state = "upp_belt"
	has_gamemode_skin = FALSE

//version full of type 71 mags
/obj/item/storage/belt/marine/upp/full/New()
	..()
	new /obj/item/ammo_magazine/rifle/type71(src)
	new /obj/item/ammo_magazine/rifle/type71(src)
	new /obj/item/ammo_magazine/rifle/type71(src)
	new /obj/item/ammo_magazine/rifle/type71(src)
	new /obj/item/ammo_magazine/rifle/type71(src)



/obj/item/storage/belt/shotgun
	name = "\improper shotgun shell load rig"
	desc = "An ammunition belt designed to hold shotgun shells or individual bullets."
	icon_state = "shotgunbelt"
	w_class = 4
	storage_slots = 10
	max_w_class = 2
	max_storage_space = 20
	can_hold = list("/obj/item/ammo_magazine/handful")

	New()
		select_gamemode_skin(type)
		..()


/obj/item/storage/belt/knifepouch
	name="\improper M276 pattern knife rig"
	desc="The M276 is the standard load-bearing equipment of the USCM. It consists of a modular belt with various clips. This version is specially designed with four holsters to store throwing knives. Not commonly issued, but kept in service."
	icon_state="knifebelt"
	item_state="marine" // aslo temp, maybe somebody update these icons with better ones?
	w_class = 3
	storage_slots = 6
	max_w_class = 1
	max_storage_space = 6

	can_hold=list("/obj/item/weapon/throwing_knife")
	New()
		select_gamemode_skin(type)
		..()
		item_state = "marinebelt" //PLACEHOLDER. Override, since it has no unique state.
		new /obj/item/weapon/throwing_knife(src)
		new /obj/item/weapon/throwing_knife(src)
		new /obj/item/weapon/throwing_knife(src)
		new /obj/item/weapon/throwing_knife(src)
		new /obj/item/weapon/throwing_knife(src)
		new /obj/item/weapon/throwing_knife(src)

/obj/item/storage/belt/grenade
	name="\improper M276 pattern M40 HEDP rig"
	desc="The M276 is the standard load-bearing equipment of the USCM. It consists of a modular belt with various clips. This version is designed to carry bulk quantities of M40 HEDP Grenades."
	icon_state="grenadebelt" // temp
	item_state="s_marine"
	w_class = 4
	storage_slots = 8
	max_w_class = 3
	max_storage_space = 24
	can_hold = list("/obj/item/explosive/grenade")


/obj/item/storage/belt/grenade/New()
	..()
	spawn(1)
		new /obj/item/explosive/grenade/incendiary(src)
		new /obj/item/explosive/grenade/incendiary(src)
		new /obj/item/explosive/grenade/incendiary(src)
		new /obj/item/explosive/grenade/incendiary(src)
		new /obj/item/explosive/grenade/frag(src)
		new /obj/item/explosive/grenade/frag(src)
		new /obj/item/explosive/grenade/frag(src)
		new /obj/item/explosive/grenade/frag(src)



/obj/item/storage/sparepouch
	name="\improper G8 general utility pouch"
	desc="A small, lightweight pouch that can be clipped onto Armat Systems M3 Pattern armor to provide additional storage. Unfortunately, this pouch uses the same securing system as most Armat platform weaponry, and thus only one can be clipped to the M3 Pattern Armor."
	storage_slots = 3
	w_class = 4
	max_w_class = 3
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state="sparepouch"
	item_state="marine_s"




////////////////////////////// GUN BELTS /////////////////////////////////////

/obj/item/storage/belt/gun
	name = "pistol belt"
	desc = "A belt-holster assembly that allows one to hold a pistol and two magazines."
	icon_state = "m4a3_holster"
	item_state = "m4a3_holster"
	use_sound = null
	w_class = 4
	storage_slots = 5
	max_storage_space = 11
	max_w_class = 3
	var/holds_guns_now = 0 //Generic variable to determine if the holster already holds a gun.
	var/holds_guns_max = 1 //How many guns can it hold? I think this can be any thing from 1 to whatever. Should calculate properly.
	var/obj/item/weapon/gun/current_gun //The gun it holds, used for referencing later so we can update the icon.
	var/image/reusable/gun_underlay //The underlay we will use.
	var/sheatheSound = 'sound/weapons/gun_pistol_sheathe.ogg'
	var/drawSound = 'sound/weapons/gun_pistol_draw.ogg'
	can_hold = list(
		"/obj/item/weapon/gun/pistol",
		"/obj/item/ammo_magazine/pistol"
		)

/obj/item/storage/belt/gun/Dispose()
	if(gun_underlay)
		cdel(gun_underlay)
		gun_underlay = null
	if(current_gun)
		cdel(current_gun)
		current_gun = null
	. = ..()


/obj/item/storage/belt/gun/attack_hand(mob/user)
	if(current_gun && ishuman(user) && loc == user)
		current_gun.attack_hand(user)
	else
		..()


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
		gun_underlay = rnew(/image/reusable,list(icon, src, current_gun.icon_state))
		icon_state += "_g"
		item_state = icon_state
		underlays += gun_underlay
	else
		playsound(src,sheatheSound, 15, 1)
		underlays -= gun_underlay
		icon_state = copytext(icon_state,1,-2)
		item_state = icon_state
		cdel(gun_underlay)
		gun_underlay = null
	if(istype(user)) user.update_inv_belt()
	if(istype(user)) user.update_inv_s_store()


//There are only two types here that can be inserted, and they are mutually exclusive. We only track the gun.
/obj/item/storage/belt/gun/can_be_inserted(obj/item/W, stop_messages) //We don't need to stop messages, but it can be left in.
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

/obj/item/weapon/gun/on_enter_storage(obj/item/storage/belt/gun/gun_belt)
	if(istype(gun_belt))
		gun_belt.holds_guns_now++ //Slide it in.
		if(!gun_belt.current_gun)
			gun_belt.current_gun = src //If there's no active gun, we want to make this our icon.
			gun_belt.update_gun_icon()

/obj/item/weapon/gun/on_exit_storage(obj/item/storage/belt/gun/gun_belt)
	if(istype(gun_belt))
		gun_belt.holds_guns_now--
		if(gun_belt.current_gun == src)
			gun_belt.current_gun = null
			gun_belt.update_gun_icon()

/obj/item/storage/belt/gun/m4a3
	name = "\improper M276 pattern M4A3 holster rig"
	desc = "The M276 is the standard load-bearing equipment of the USCM. It consists of a modular belt with various clips. This version has a holster assembly that allows one to carry the M4A3 comfortably secure. It also contains side pouches that can store 9mm or .45 magazines."
	can_hold = list(
		"/obj/item/weapon/gun/pistol",
		"/obj/item/ammo_magazine/pistol"
		)

	New()
		select_gamemode_skin(type)
		..()

/obj/item/storage/belt/gun/m4a3/full/New()
	..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/m4a3(src)
	new /obj/item/ammo_magazine/pistol/hp(src)
	new /obj/item/ammo_magazine/pistol/extended(src)
	new /obj/item/ammo_magazine/pistol/extended(src)
	new /obj/item/ammo_magazine/pistol/extended(src)
	new_gun.on_enter_storage(src)

/obj/item/storage/belt/gun/m4a3/commander/New()
	..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/m4a3/custom(src)
	new /obj/item/ammo_magazine/pistol/hp(src)
	new /obj/item/ammo_magazine/pistol/ap(src)
	new /obj/item/ammo_magazine/pistol/ap(src)
	new /obj/item/ammo_magazine/pistol/ap(src)
	new_gun.on_enter_storage(src)

/obj/item/storage/belt/gun/m4a3/vp70/New()
	..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new_gun.on_enter_storage(src)

/obj/item/storage/belt/gun/m4a3/vp78/New()
	..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new_gun.on_enter_storage(src)

/obj/item/storage/belt/gun/m44
	name = "\improper M276 pattern M44 holster rig"
	desc = "The M276 is the standard load-bearing equipment of the USCM. It consists of a modular belt with various clips. This version is for the M44 magnum revolver, along with three pouches for speedloaders. It faintly smells of hay."
	icon_state = "m44_holster"
	item_state = "m44_holster"
	max_w_class = 7
	can_hold = list(
		"/obj/item/weapon/gun/revolver/m44",
		"/obj/item/ammo_magazine/revolver"
		)
	New()
		..()
		select_gamemode_skin(type)

/obj/item/storage/belt/gun/m44/full/New()
	..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/revolver/m44(src)
	new /obj/item/ammo_magazine/revolver/marksman(src)
	new /obj/item/ammo_magazine/revolver/marksman(src)
	new /obj/item/ammo_magazine/revolver/marksman(src)
	new /obj/item/ammo_magazine/revolver/marksman(src)
	new_gun.on_enter_storage(src)

/obj/item/storage/belt/gun/mateba
	name = "\improper M276 pattern Mateba holster rig"
	desc = "The M276 is the standard load-bearing equipment of the USCM. It consists of a modular belt with various clips. This version is for the powerful Mateba magnum revolver, along with three pouches for speedloaders. This one is aging poorly, and seems to be surplus equipment. This one is stamped '3rd 'Dust Raiders' Battalion'."
	icon_state = "s_cmateba_holster"
	item_state = "s_cmateba_holster"
	max_w_class = 7
	can_hold = list(
		"/obj/item/weapon/gun/revolver/mateba",
		"/obj/item/ammo_magazine/revolver/mateba"
		)

/obj/item/storage/belt/gun/mateba/full/New()
	..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new_gun.on_enter_storage(src)

/obj/item/storage/belt/gun/mateba/cmateba
	name = "\improper M276 pattern Mateba holster rig"
	desc = "The M276 is the standard load-bearing equipment of the USCM. It consists of a modular belt with various clips. This version is for the powerful Mateba magnum revolver, along with three pouches for speedloaders. Was included with the mail-in order for the USCM edition of the Mateba autorevolver in the early 2170s."
	icon_state = "cmateba_holster"
	item_state = "cmateba_holster"
	New()
		..()
		select_gamemode_skin(type)

/obj/item/storage/belt/gun/mateba/cmateba/full/New()
	..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/revolver/mateba/cmateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new_gun.on_enter_storage(src)

/obj/item/storage/belt/gun/mateba/admiral/New()
	..()
	icon_state = "amateba_holster"
	item_state = "amateba_holster"
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/revolver/mateba/admiral(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new_gun.on_enter_storage(src)

/obj/item/storage/belt/gun/korovin
	name = "\improper Type 41 pistol holster rig"
	desc = "A modification of the standard UPP pouch rig to carry a single Korovin PK-9 pistol. It also contains side pouches that can store .22 magazines, either hollowpoints or tranquilizers."
	icon_state = "korovin_holster"
	item_state = "korovin_holster"
	can_hold = list(
		"/obj/item/weapon/gun/pistol/c99",
		"/obj/item/ammo_magazine/pistol/c99",
		"/obj/item/ammo_magazine/pistol/c99t"
		)

/obj/item/storage/belt/gun/korovin/standard/New()
	..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/c99/upp(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new_gun.on_enter_storage(src)

/obj/item/storage/belt/gun/korovin/tranq/New()
	..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/c99/upp/tranq(src)
	new /obj/item/ammo_magazine/pistol/c99t(src)
	new /obj/item/ammo_magazine/pistol/c99t(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new_gun.on_enter_storage(src)
