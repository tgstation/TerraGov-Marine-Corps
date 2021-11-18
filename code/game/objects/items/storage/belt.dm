

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
	allow_drawing_method = TRUE



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
		/obj/item/tool/surgery/solderingtool,
	)


/obj/item/storage/belt/utility/full/Initialize()
	. = ..()
	new /obj/item/tool/screwdriver(src)
	new /obj/item/tool/wrench(src)
	new /obj/item/tool/weldingtool(src)
	new /obj/item/tool/crowbar(src)
	new /obj/item/tool/wirecutters(src)
	new /obj/item/stack/cable_coil(src,30,pick("red","yellow","orange"))
	new /obj/item/multitool(src)


/obj/item/storage/belt/utility/atmostech/Initialize()
	. = ..()
	new /obj/item/tool/screwdriver(src)
	new /obj/item/tool/wrench(src)
	new /obj/item/tool/weldingtool(src)
	new /obj/item/tool/crowbar(src)
	new /obj/item/tool/wirecutters(src)
	new /obj/item/t_scanner(src)

/obj/item/storage/belt/lifesaver
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
		/obj/item/stack/medical,
	)

/obj/item/storage/belt/lifesaver/full/Initialize()  //The belt, with all it's magic inside!
	. = ..()
	new /obj/item/storage/pill_bottle/bicaridine(src)
	new /obj/item/storage/pill_bottle/kelotane(src)
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/storage/pill_bottle/tricordrazine(src)
	new /obj/item/storage/pill_bottle/dylovene(src)
	new /obj/item/storage/pill_bottle/inaprovaline(src)
	new /obj/item/storage/pill_bottle/dexalin(src)
	new /obj/item/storage/pill_bottle/spaceacillin(src)
	new /obj/item/storage/pill_bottle/alkysine(src)
	new /obj/item/storage/pill_bottle/imidazoline(src)
	new /obj/item/storage/pill_bottle/quickclot(src)
	new /obj/item/storage/pill_bottle/hypervene(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/healthanalyzer(src)

/obj/item/storage/belt/lifesaver/full/upp
	name ="\improper Type 41 pattern lifesaver bag"
	desc = "The Type 41 load rig is the standard-issue LBE of the UPP military. This configuration mounts a satchel filled with a range of injectors and light medical supplies, common among medics and partisans."
	icon_state = "medicalbag_u"
	item_state = "medicbag_u"


/obj/item/storage/belt/lifesaver/som
	name = "\improper S17 lifesaver bag"
	desc = "A belt with heavy origins from the belt used by paramedics and doctors in the old mining colonies."
	icon_state = "medicbag_som"
	item_state = "medicbag_som"

/obj/item/storage/belt/lifesaver/som/ert/Initialize()
	. = ..()
	new /obj/item/storage/pill_bottle/bicaridine(src)
	new /obj/item/storage/pill_bottle/kelotane(src)
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/storage/pill_bottle/tricordrazine(src)
	new /obj/item/storage/pill_bottle/dylovene(src)
	new /obj/item/storage/pill_bottle/inaprovaline(src)
	new /obj/item/storage/pill_bottle/dexalin(src)
	new /obj/item/storage/pill_bottle/quickclot(src)
	new /obj/item/storage/pill_bottle/hypervene(src)
	new /obj/item/storage/pill_bottle/meralyne(src)
	new /obj/item/storage/pill_bottle/dermaline(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/healthanalyzer(src)

/obj/item/storage/belt/lifesaver/quick/Initialize()  //quick load for combat patrol
	. = ..()
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/storage/pill_bottle/bicaridine(src)
	new /obj/item/storage/pill_bottle/kelotane(src)
	new /obj/item/storage/pill_bottle/dylovene(src)
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/storage/pill_bottle/tricordrazine(src)
	new /obj/item/storage/pill_bottle/inaprovaline(src)
	new /obj/item/storage/pill_bottle/quickclot(src)
	new /obj/item/storage/pill_bottle/alkysine(src)
	new /obj/item/storage/pill_bottle/imidazoline(src)
	new /obj/item/storage/pill_bottle/meralyne(src)
	new /obj/item/storage/pill_bottle/dermaline(src)
	new /obj/item/storage/pill_bottle/hypervene(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/dexalinplus(src)
	new /obj/item/healthanalyzer(src)

/obj/item/storage/belt/rig
	name = "\improper M276 pattern medical storage rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is a less common configuration, designed to transport medical supplies and heavier medical tools."
	icon_state = "medicalbelt"
	item_state = "medical"
	storage_slots = 16
	max_w_class = 3
	max_storage_space = 42

	can_hold = list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/hypospray,
		/obj/item/storage/pill_bottle,
		/obj/item/storage/syringe_case,
		/obj/item/stack/medical,
		/obj/item/bodybag,
		/obj/item/defibrillator,
		/obj/item/roller,
		/obj/item/tool/research,
	)

/obj/item/storage/belt/rig/medical/Initialize()  //The belt, with all it's magic inside!
	. = ..()
	new /obj/item/storage/pill_bottle/bicaridine(src)
	new /obj/item/storage/pill_bottle/kelotane(src)
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/storage/pill_bottle/tricordrazine(src)
	new /obj/item/storage/pill_bottle/dylovene(src)
	new /obj/item/storage/pill_bottle/inaprovaline(src)
	new /obj/item/storage/pill_bottle/dexalin(src)
	new /obj/item/storage/pill_bottle/spaceacillin(src)
	new /obj/item/storage/pill_bottle/alkysine(src)
	new /obj/item/storage/pill_bottle/imidazoline(src)
	new /obj/item/storage/pill_bottle/quickclot(src)
	new /obj/item/storage/pill_bottle/hypervene(src)
	new /obj/item/bodybag/cryobag(src)
	new /obj/item/roller(src)
	new /obj/item/defibrillator(src)
	new /obj/item/healthanalyzer(src)

/obj/item/storage/belt/rig/research/Initialize()  //The belt, with all it's magic inside!
	. = ..()
	new /obj/item/storage/pill_bottle/bicaridine(src)
	new /obj/item/storage/pill_bottle/kelotane(src)
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/storage/pill_bottle/tricordrazine(src)
	new /obj/item/storage/pill_bottle/dylovene(src)
	new /obj/item/storage/pill_bottle/inaprovaline(src)
	new /obj/item/storage/pill_bottle/dexalin(src)
	new /obj/item/storage/pill_bottle/spaceacillin(src)
	new /obj/item/storage/pill_bottle/alkysine(src)
	new /obj/item/storage/pill_bottle/imidazoline(src)
	new /obj/item/storage/pill_bottle/quickclot(src)
	new /obj/item/storage/pill_bottle/hypervene(src)
	new /obj/item/defibrillator(src)
	new /obj/item/tool/research/excavation_tool(src)
	new /obj/item/tool/research/xeno_analyzer(src)
	new /obj/item/healthanalyzer(src)

/obj/item/storage/belt/hypospraybelt
	name = "\improper M276 pattern hypospray belt"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is a less common configuration, designed to transport hyposprays and reagent containers."
	icon_state = "hypospraybelt"
	item_state = "medicbag"
	storage_slots = 18
	max_storage_space = 42
	max_w_class = 2
	can_hold = list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/hypospray,
	)

/obj/item/storage/belt/hypospraybelt/Initialize()  //The belt, with all it's magic inside!
	. = ..()
	new /obj/item/reagent_containers/hypospray/advanced/big/bicaridine(src)
	new /obj/item/reagent_containers/glass/bottle/bicaridine(src)
	new /obj/item/reagent_containers/hypospray/advanced/big/kelotane(src)
	new /obj/item/reagent_containers/glass/bottle/kelotane(src)
	new /obj/item/reagent_containers/hypospray/advanced/big/tramadol(src)
	new /obj/item/reagent_containers/glass/bottle/tramadol(src)
	new /obj/item/reagent_containers/hypospray/advanced/big/tricordrazine(src)
	new /obj/item/reagent_containers/glass/bottle/tricordrazine(src)
	new /obj/item/reagent_containers/hypospray/advanced/big/dylovene(src)
	new /obj/item/reagent_containers/hypospray/advanced/big/inaprovaline(src)
	new /obj/item/reagent_containers/hypospray/advanced/big/dexalin(src)
	new /obj/item/reagent_containers/hypospray/advanced/big/spaceacillin(src)
	new /obj/item/reagent_containers/hypospray/advanced/big/imialky(src)
	new /obj/item/reagent_containers/hypospray/advanced/big/quickclot(src)
	new /obj/item/reagent_containers/hypospray/advanced/hypervene(src)
	new /obj/item/healthanalyzer(src)

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
		/obj/item/tool/taperoll/police,
	)

	cant_hold = list(
		/obj/item/weapon/gun,
	)



/obj/item/storage/belt/security/tactical
	name = "combat belt"
	desc = "Can hold security gear like handcuffs and flashes, with more pouches for more storage."
	icon_state = "swatbelt"
	item_state = "swatbelt"
	storage_slots = 9
	max_w_class = 3
	max_storage_space = 21

/obj/item/storage/belt/marine
	name = "\improper M276 pattern ammo load rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is the standard variant designed for bulk ammunition-carrying operations."
	icon_state = "marinebelt"
	item_state = "marinebelt"
	w_class = WEIGHT_CLASS_BULKY
	storage_slots = 6
	max_w_class = 3
	max_storage_space = 18
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

/obj/item/storage/belt/marine/t18/Initialize()
	. = ..()
	new /obj/item/ammo_magazine/rifle/standard_carbine(src)
	new /obj/item/ammo_magazine/rifle/standard_carbine(src)
	new /obj/item/ammo_magazine/rifle/standard_carbine(src)
	new /obj/item/ammo_magazine/rifle/standard_carbine(src)
	new /obj/item/ammo_magazine/rifle/standard_carbine(src)

/obj/item/storage/belt/marine/t12/Initialize()
	. = ..()
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)

/obj/item/storage/belt/marine/t90/Initialize()
	. = ..()
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)
	new /obj/item/ammo_magazine/smg/standard_smg(src)

/obj/item/storage/belt/marine/antimaterial/Initialize()
	. = ..()
	new /obj/item/ammo_magazine/sniper/flak(src)
	new /obj/item/ammo_magazine/sniper/flak(src)
	new /obj/item/ammo_magazine/sniper/incendiary(src)
	new /obj/item/ammo_magazine/sniper/incendiary(src)
	new /obj/item/ammo_magazine/sniper(src)

/obj/item/storage/belt/marine/tx8/Initialize()
	. = ..()
	new /obj/item/ammo_magazine/rifle/tx8/impact(src)
	new /obj/item/ammo_magazine/rifle/tx8/impact(src)
	new /obj/item/ammo_magazine/rifle/tx8/incendiary(src)
	new /obj/item/ammo_magazine/rifle/tx8/incendiary(src)
	new /obj/item/ammo_magazine/rifle/tx8(src)

/obj/item/storage/belt/marine/upp
	name = "\improper Type 41 pattern load rig"
	desc = "The Type 41 load rig is the standard-issue LBE of the USL pirates. The primary function of this belt is to provide easy access to mags for the Type 71 during operations. Despite being designed for the Type 71 weapon system, the pouches are modular enough to fit other types of ammo and equipment."
	icon_state = "upp_belt"
	item_state = "upp_belt"

//version full of type 71 mags
/obj/item/storage/belt/marine/upp/full/Initialize()
	. = ..()
	new /obj/item/ammo_magazine/rifle/type71(src)
	new /obj/item/ammo_magazine/rifle/type71(src)
	new /obj/item/ammo_magazine/rifle/type71(src)
	new /obj/item/ammo_magazine/rifle/type71(src)
	new /obj/item/ammo_magazine/rifle/type71(src)


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


/obj/item/storage/belt/shotgun/attackby(obj/item/I, mob/user, params)

	if(istype(I, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/M = I
		if(CHECK_BITFIELD(M.flags_magazine, MAGAZINE_HANDFUL))
			return ..()
		if(M.flags_magazine & MAGAZINE_REFILLABLE)
			if(!M.current_rounds)
				to_chat(user, span_warning("[M] is empty."))
				return

			if(length(contents) >= storage_slots)
				to_chat(user, span_warning("[src] is full."))
				return


			to_chat(user, span_notice("You start refilling [src] with [M]."))
			if(!do_after(user, 1.5 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
				return

			for(var/x in 1 to (storage_slots - length(contents)))
				var/cont = handle_item_insertion(M.create_handful(), 1, user)
				if(!cont)
					break

			playsound(user.loc, "rustle", 15, TRUE, 6)
			to_chat(user, span_notice("You refill [src] with [M]."))
			return TRUE

	return ..()

/obj/item/storage/belt/shotgun/som
	desc = "An ammunition belt designed to hold shotgun shells or individual bullets. Made with traditional SOM leather."
	icon_state = "shotgunbelt_som"

/obj/item/storage/belt/shotgun/martini
	name = "martini henry ammo belt"
	desc = "A belt good enough for holding all your .577/400 ball rounds."
	icon_state = ".557_belt"
	storage_slots = 12
	max_storage_space = 24

	draw_mode = 1

	flags_atom = DIRLOCK

/obj/item/storage/belt/shotgun/martini/Initialize(mapload, ...)
	. = ..()
	update_icon()

/obj/item/storage/belt/shotgun/martini/update_icon()
	if(!contents.len)
		icon_state = initial(icon_state) + "_e"
		return
	icon_state = initial(icon_state)

	var/holding = round((contents.len + 1) / 2)
	setDir(holding + round(holding/3))

/obj/item/storage/belt/shotgun/martini/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/new_mag = I
		if(new_mag.caliber != CALIBER_557)
			to_chat(user, span_notice("[src] can only be filled with .557/440 ball rifle rounds."))
			return
	. = ..()
	update_icon()

/obj/item/storage/belt/shotgun/martini/attack_hand(mob/living/user)
	if (loc != user)
		. = ..()
		for(var/mob/M in content_watchers)
			close(M)

	if(!draw_mode || !ishuman(user) && !contents.len)
		open(user)

	if(!length(contents))
		return

	var/obj/item/I = contents[contents.len]
	if(!istype(I, /obj/item/ammo_magazine/handful))
		return

	var/obj/item/ammo_magazine/handful/existing_handful = I

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
	draw_mode = TRUE
	can_hold = list(/obj/item/stack/throwing_knife)

/obj/item/storage/belt/knifepouch/Initialize()
	. = ..()
	new /obj/item/stack/throwing_knife(src)
	new /obj/item/stack/throwing_knife(src)
	new /obj/item/stack/throwing_knife(src)
	new /obj/item/stack/throwing_knife(src)
	new /obj/item/stack/throwing_knife(src)
	new /obj/item/stack/throwing_knife(src)

/obj/item/storage/belt/grenade
	name="\improper M276 pattern M40 HEDP rig"
	desc="The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is designed to carry bulk quantities of M40 HEDP Grenades."
	icon_state="grenadebelt"
	item_state="grenadebelt"
	w_class = WEIGHT_CLASS_BULKY
	storage_slots = 9
	max_w_class = 3
	max_storage_space = 27
	can_hold = list(/obj/item/explosive/grenade)

/obj/item/storage/belt/grenade/som
	name="\improper S16 pattern grenade rig"
	desc="A simple harness system available in many configurations. This version is designed to carry bulk quantities of grenades."
	icon_state="grenadebelt_som"

/obj/item/storage/belt/grenade/standard/Initialize()
	. = ..()
	new /obj/item/explosive/grenade/incendiary(src)
	new /obj/item/explosive/grenade/incendiary(src)
	new /obj/item/explosive/grenade/incendiary(src)
	new /obj/item/explosive/grenade/incendiary(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)

/obj/item/storage/belt/grenade/b17
	name = "\improper M276 pattern M40 HEDP rig Mk II"
	w_class = WEIGHT_CLASS_BULKY
	storage_slots = 16
	max_w_class = 3
	max_storage_space = 48
	can_hold = list(/obj/item/explosive/grenade)

/obj/item/storage/belt/grenade/b17/Initialize()
	. = ..()
	new /obj/item/explosive/grenade/incendiary(src)
	new /obj/item/explosive/grenade/incendiary(src)
	new /obj/item/explosive/grenade/incendiary(src)
	new /obj/item/explosive/grenade/incendiary(src)
	new /obj/item/explosive/grenade/incendiary(src)
	new /obj/item/explosive/grenade/incendiary(src)
	new /obj/item/explosive/grenade/incendiary(src)
	new /obj/item/explosive/grenade/incendiary(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)
	new /obj/item/explosive/grenade(src)

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
	storage_type_limits = list(
		/obj/item/weapon/gun = 1,
	)
	storage_slots = 7
	max_storage_space = 15
	max_w_class = 3
	///The gun it holds, used for referencing later so we can update the icon.
	var/obj/item/weapon/gun/current_gun
	var/image/gun_underlay
	var/sheatheSound = 'sound/weapons/guns/misc/pistol_sheathe.ogg'
	var/drawSound = 'sound/weapons/guns/misc/pistol_draw.ogg'
	can_hold = list(
		/obj/item/weapon/gun/pistol,
		/obj/item/ammo_magazine/pistol,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol,
		/obj/item/cell/lasgun/lasrifle,
	)

/obj/item/storage/belt/gun/Destroy()
	if(gun_underlay)
		qdel(gun_underlay)
		gun_underlay = null
	if(current_gun)
		qdel(current_gun)
		current_gun = null
	return ..()


/obj/item/storage/belt/gun/attack_hand(mob/living/user)
	if(current_gun && ishuman(user) && loc == user)
		current_gun.attack_hand(user)
	else
		return ..()

//Will only draw the specific holstered item, not ammo etc.
/obj/item/storage/belt/gun/do_quick_equip()
	if(!current_gun)
		return FALSE
	var/obj/item/W = current_gun
	remove_from_storage(W, user = src)
	return W

/obj/item/storage/belt/gun/proc/update_gun_icon() //We do not want to use regular update_icon as it's called for every item inserted. Not worth the icon math.
	var/mob/user = loc
	if(current_gun) //So it has a gun, let's make an icon.
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
		icon_state = copytext_char(icon_state,1,-2)
		item_state = icon_state
		qdel(gun_underlay)
		gun_underlay = null
	if(istype(user)) user.update_inv_belt()
	if(istype(user)) user.update_inv_s_store()

//This deliniates between belt/gun/pistol and belt/gun/revolver
/obj/item/storage/belt/gun/pistol
	name = "generic pistol belt"
	desc = "A pistol belt that is not a revolver belt"
	icon_state = "m4a3_holster"
	item_state = "m4a3_holster"

/obj/item/storage/belt/gun/pistol/attackby_alternate(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/weapon/gun/pistol))
		return ..()
	var/obj/item/weapon/gun/pistol/gun = I
	for(var/obj/item/ammo_magazine/mag in contents)
		if(!(mag.type in gun.allowed_ammo_types))
			continue
		if(user.l_hand && user.r_hand || length(gun.chamber_items))
			gun.tactical_reload(mag, user)
		else
			gun.reload(mag, user)
		orient2hud()
		return

/obj/item/storage/belt/gun/pistol/examine(mob/user, distance, infix, suffix)
	. = ..()
	. += span_notice("To perform a reload with the amunition inside, disable right click and right click on the belt with an empty pistol.")

/obj/item/storage/belt/gun/pistol/m4a3
	name = "\improper M4A3 holster rig"
	desc = "The M4A3 is a common holster belt. It consists of a modular belt with various clips. This version has a holster assembly that allows one to carry a handgun. It also contains side pouches that can store 9mm or .45 magazines."
	can_hold = list(
		/obj/item/weapon/gun/pistol,
		/obj/item/ammo_magazine/pistol,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol,
		/obj/item/cell/lasgun/lasrifle,
	)

/obj/item/storage/belt/gun/pistol/m4a3/full/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/rt3(src)
	new /obj/item/ammo_magazine/pistol/ap(src)
	new /obj/item/ammo_magazine/pistol/hp(src)
	new /obj/item/ammo_magazine/pistol/extended(src)
	new /obj/item/ammo_magazine/pistol/extended(src)
	new /obj/item/ammo_magazine/pistol/extended(src)
	new /obj/item/ammo_magazine/pistol/extended(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_gun)

/obj/item/storage/belt/gun/pistol/m4a3/officer/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/rt3(src)
	new /obj/item/ammo_magazine/pistol/hp(src)
	new /obj/item/ammo_magazine/pistol/hp(src)
	new /obj/item/ammo_magazine/pistol/ap(src)
	new /obj/item/ammo_magazine/pistol/ap(src)
	new /obj/item/ammo_magazine/pistol/ap(src)
	new /obj/item/ammo_magazine/pistol/ap(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_gun)

/obj/item/storage/belt/gun/pistol/m4a3/fieldcommander/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/m1911/custom(src)
	new /obj/item/ammo_magazine/pistol/m1911(src)
	new /obj/item/ammo_magazine/pistol/m1911(src)
	new /obj/item/ammo_magazine/pistol/m1911(src)
	new /obj/item/ammo_magazine/pistol/m1911(src)
	new /obj/item/ammo_magazine/pistol/m1911(src)
	new /obj/item/ammo_magazine/pistol/m1911(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_gun)

/obj/item/storage/belt/gun/pistol/m4a3/vp70/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_gun)

/obj/item/storage/belt/gun/pistol/m4a3/vp78/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_gun)

/obj/item/storage/belt/gun/pistol/m4a3/som
	name = "\improper S19 holster rig"
	desc = "A belt with origins dating back to old colony security holster rigs."
	icon_state = "som_belt_pistol"
	item_state = "som_belt_pistol"

//No overlays, sprite not positioned to allow for it
/obj/item/storage/belt/gun/pistol/m4a3/som/update_gun_icon()
	if(current_gun)
		playsound(src,drawSound, 15, 1)
	else
		playsound(src,sheatheSound, 15, 1)

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
	max_storage_space = 16
	max_w_class = 4
	can_hold = list(
		/obj/item/weapon/gun/revolver,
		/obj/item/ammo_magazine/revolver,
	)

/obj/item/storage/belt/gun/m44/full/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/revolver/single_action/m44(src)
	new /obj/item/ammo_magazine/revolver/heavy(src)
	new /obj/item/ammo_magazine/revolver/marksman(src)
	new /obj/item/ammo_magazine/revolver(src)
	new /obj/item/ammo_magazine/revolver(src)
	new /obj/item/ammo_magazine/revolver(src)
	new /obj/item/ammo_magazine/revolver(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_gun)

/obj/item/storage/belt/gun/mateba
	name = "\improper M276 pattern Mateba holster rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is for the powerful Mateba magnum revolver, along with three pouches for speedloaders."
	icon_state = "mateba_holster"
	item_state = "mateba_holster"
	max_storage_space = 16
	bypass_w_limit = list(
		/obj/item/weapon/gun/revolver/mateba,
	)
	can_hold = list(
		/obj/item/weapon/gun/revolver/mateba,
		/obj/item/ammo_magazine/revolver/mateba,
	)

/obj/item/storage/belt/gun/mateba/full/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_gun)

/obj/item/storage/belt/gun/mateba/officer
	icon_state = "c_mateba_holster"
	item_state = "c_mateba_holster"

/obj/item/storage/belt/gun/mateba/officer/full/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/revolver/mateba/custom(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_gun)

/obj/item/storage/belt/gun/mateba/notmarine/Initialize()
	. = ..()
	icon_state = "a_mateba_holster"
	item_state = "a_mateba_holster"
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/revolver/mateba/(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_gun)

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

/obj/item/storage/belt/gun/korovin/standard/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_gun)

/obj/item/storage/belt/gun/korovin/tranq/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/c99/tranq(src)
	new /obj/item/ammo_magazine/pistol/c99t(src)
	new /obj/item/ammo_magazine/pistol/c99t(src)
	new /obj/item/ammo_magazine/pistol/c99t(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_gun)

/obj/item/storage/belt/gun/ts34
	name = "\improper M276 pattern SH-34 shotgun holster rig"
	desc = "A purpose built belt-holster assembly that holds a SH-34 shotgun and one shell box or 2 handfuls."
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

/obj/item/storage/belt/gun/ts34/full/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/shotgun/double/marine(src)
	new /obj/item/ammo_magazine/shotgun/buckshot(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_gun)


/obj/item/storage/belt/gun/pistol/m4a3/officer/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/rt3(src)
	new /obj/item/ammo_magazine/pistol/hp(src)
	new /obj/item/ammo_magazine/pistol/hp(src)
	new /obj/item/ammo_magazine/pistol/ap(src)
	new /obj/item/ammo_magazine/pistol/ap(src)
	new /obj/item/ammo_magazine/pistol/ap(src)
	new /obj/item/ammo_magazine/pistol/ap(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_gun)

/obj/item/storage/belt/gun/pistol/smart_pistol
	name = "\improper SP-13 holster rig"
	desc = "A holster belt, which holds SP-13 smartpistol and magazines for it."
	can_hold = list(
		/obj/item/weapon/gun/pistol/smart_pistol,
		/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol,
	)

/obj/item/storage/belt/gun/pistol/smart_pistol/full/Initialize()
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/smart_pistol(src)
	new /obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol(src)
	new /obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol(src)
	new /obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol(src)
	new /obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol(src)
	new /obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol(src)
	new /obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol(src)
	INVOKE_ASYNC(src, .proc/handle_item_insertion, new_gun)
