
//Uniform Storage.
/obj/item/armor_module/storage/uniform
	slot = ATTACHMENT_SLOT_UNIFORM
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_APPLY_ON_MOB|ATTACH_SEPERATE_MOB_OVERLAY|ATTACH_NO_HANDS
	icon = 'icons/obj/clothing/ties.dmi'
	attach_icon = 'icons/obj/clothing/ties_overlay.dmi'
	mob_overlay_icon = 'icons/mob/ties.dmi'

/obj/item/armor_module/storage/uniform/webbing
	name = "webbing"
	desc = "A sturdy mess of synthcotton belts and buckles, ready to share your burden."
	icon_state = "webbing"
	storage = /obj/item/storage/internal/webbing

/obj/item/storage/internal/webbing
	max_w_class = WEIGHT_CLASS_SMALL
	bypass_w_limit = list(
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/sniper,
		/obj/item/cell/lasgun,
	)
	cant_hold = list(
		/obj/item/stack/razorwire,
		/obj/item/stack/sheet,
		/obj/item/stack/sandbags,
		/obj/item/stack/snow,
	)

/obj/item/armor_module/storage/uniform/black_vest
	name = "black webbing vest"
	desc = "Robust black synthcotton vest with lots of pockets to hold whatever you need, but cannot hold in hands."
	icon_state = "vest_black"
	storage = /obj/item/storage/internal/vest

/obj/item/storage/internal/vest
	storage_slots = 5
	max_w_class = WEIGHT_CLASS_SMALL
	cant_hold = list(
		/obj/item/stack/razorwire,
		/obj/item/stack/sheet,
		/obj/item/stack/sandbags,
		/obj/item/stack/snow,
	)

/obj/item/armor_module/storage/uniform/brown_vest
	name = "brown webbing vest"
	desc = "Worn brownish synthcotton vest with lots of pockets to unload your hands."
	icon_state = "vest_brown"
	storage = /obj/item/storage/internal/vest

/obj/item/armor_module/storage/uniform/white_vest
	name = "white webbing vest"
	desc = "A clean white Nylon vest with large pockets specially designed for medical supplies"
	icon_state = "vest_white"
	storage = /obj/item/storage/internal/white_vest

/obj/item/storage/internal/white_vest
	storage_slots = 12
	max_storage_space = 24
	max_w_class = WEIGHT_CLASS_BULKY

	can_hold = list(
		/obj/item/stack/medical,
		/obj/item/stack/nanopaste,
	)

/obj/item/armor_module/storage/uniform/white_vest/surgery
	name = "surgical vest"
	desc = "A clean white Nylon vest with large pockets specially designed for holding surgical supplies."
	icon_state = "vest_white"
	storage = /obj/item/storage/internal/white_vest/surgery

/obj/item/storage/internal/white_vest/surgery
	can_hold = list(
		/obj/item/tool/surgery,
		/obj/item/stack/nanopaste,
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack,
		/obj/item/tweezers,
	)


/obj/item/storage/internal/white_vest/surgery/Initialize()
	. = ..()
	new /obj/item/tool/surgery/scalpel/manager(src)
	new /obj/item/tool/surgery/scalpel(src)
	new /obj/item/tool/surgery/hemostat(src)
	new /obj/item/tool/surgery/retractor(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/tool/surgery/cautery(src)
	new /obj/item/tool/surgery/circular_saw(src)
	new /obj/item/tool/surgery/suture(src)
	new /obj/item/tool/surgery/bonegel(src)
	new /obj/item/tool/surgery/bonesetter(src)
	new /obj/item/tool/surgery/FixOVein(src)
	new /obj/item/stack/nanopaste(src)


/obj/item/armor_module/storage/uniform/white_vest/medic
	name = "corpsman webbing"
	desc = "A clean white Nylon vest with large pockets specially designed for holding common medical supplies."
	storage = /obj/item/storage/internal/white_vest/medic

/obj/item/storage/internal/white_vest/medic
	storage_slots = 6 //one more than the brown webbing but you lose out on being able to hold non-medic stuff
	can_hold = list(
		/obj/item/stack/medical,
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/storage/pill_bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/bodybag,
		/obj/item/roller,
		/obj/item/clothing/glasses/hud/health,
		/obj/item/tweezers,
	)

/obj/item/armor_module/storage/uniform/knifeharness
	name = "decorated harness"
	desc = "A heavily decorated harness of sinew and leather with two knife-loops."
	icon_state = "unathiharness2"
	storage = /obj/item/storage/internal/knifeharness

/obj/item/storage/internal/knifeharness
	storage_slots = 2
	max_storage_space = 4
	can_hold = list(
		/obj/item/weapon/unathiknife,
		/obj/item/tool/kitchen/utensil/knife,
		/obj/item/tool/kitchen/utensil/pknife,
		/obj/item/tool/kitchen/knife,
		/obj/item/tool/kitchen/knife/ritual,
	)

/obj/item/armor_module/storage/uniform/knifeharness/Initialize()
	. = ..()
	new /obj/item/weapon/unathiknife(storage)
	new /obj/item/weapon/unathiknife(storage)

/obj/item/armor_module/storage/uniform/holster
	name = "shoulder holster"
	desc = "A handgun holster"
	icon_state = "holster"
	storage = /obj/item/storage/internal/holster

/obj/item/storage/internal/holster
	storage_slots = 1
	max_w_class = WEIGHT_CLASS_BULKY
	can_hold = list(
		/obj/item/weapon/gun/pistol,
		/obj/item/weapon/gun/revolver,
		/obj/item/weapon/gun/smg/standard_machinepistol,
	)

/obj/item/armor_module/storage/uniform/holster/armpit
	name = "shoulder holster"
	desc = "A worn-out handgun holster. Perfect for concealed carry"
	icon_state = "holster"

/obj/item/armor_module/storage/uniform/holster/waist
	name = "shoulder holster"
	desc = "A handgun holster. Made of expensive leather."
	icon_state = "holster"
	item_state = "holster_low"

/*
	Holobadges are worn on the belt or neck, and can be used to show that the holder is an authorized
	Security agent - the user details can be imprinted on the badge with a Security-access ID card
*/

/obj/item/armor_module/storage/uniform/holobadge

	name = "holobadge"
	desc = "This glowing blue badge marks the holder as THE LAW."
	icon_state = "holobadge"
	flags_equip_slot = ITEM_SLOT_BELT

	var/stored_name = null

/obj/item/armor_module/storage/uniform/holobadge/cord
	icon_state = "holobadge-cord"
	flags_equip_slot = ITEM_SLOT_MASK

/obj/item/armor_module/storage/uniform/holobadge/attack_self(mob/user as mob)
	if(!stored_name)
		to_chat(user, "Waving around a badge before swiping an ID would be pretty pointless.")
		return
	if(isliving(user))
		user.visible_message(span_warning(" [user] displays [user.p_their()] TGMC Internal Security Legal Authorization Badge.\nIt reads: [stored_name], TGMC Security."),span_warning(" You display your TGMC Internal Security Legal Authorization Badge.\nIt reads: [stored_name], TGMC Security."))

/obj/item/armor_module/storage/uniform/holobadge/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/card/id))
		var/obj/item/card/id/id_card = I

		if(!(ACCESS_MARINE_BRIG in id_card.access))
			to_chat(user, "[src] rejects your insufficient access rights.")
			return

		to_chat(user, "You imprint your ID details onto the badge.")
		stored_name = id_card.registered_name
		name = "holobadge ([stored_name])"
		desc = "This glowing blue badge marks [stored_name] as THE LAW."


/obj/item/armor_module/storage/uniform/holobadge/attack(mob/living/carbon/human/M, mob/living/user)
	if(isliving(user))
		user.visible_message(span_warning(" [user] invades [M]'s personal space, thrusting [src] into [M.p_their()] face insistently."),span_warning(" You invade [M]'s personal space, thrusting [src] into [M.p_their()] face insistently. You are the law."))

/obj/item/storage/box/holobadge
	name = "holobadge box"
	desc = "A box claiming to contain holobadges."

/obj/item/storage/box/holobadge/Initialize(mapload, ...)
	. = ..()
	new /obj/item/armor_module/storage/uniform/holobadge(src)
	new /obj/item/armor_module/storage/uniform/holobadge(src)
	new /obj/item/armor_module/storage/uniform/holobadge(src)
	new /obj/item/armor_module/storage/uniform/holobadge(src)
	new /obj/item/armor_module/storage/uniform/holobadge/cord(src)
	new /obj/item/armor_module/storage/uniform/holobadge/cord(src)
