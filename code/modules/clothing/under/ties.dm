/obj/item/clothing/tie
	name = "tie"
	desc = "A neosilk clip-on tie."
	icon = 'icons/obj/clothing/ties.dmi'
	icon_state = "bluetie"
	flags_equip_slot = NONE
	w_class = WEIGHT_CLASS_SMALL
	var/obj/item/clothing/under/has_suit = null		//the suit the tie may be attached to
	var/image/inv_overlay = null	//overlay used when attached to clothing.

/obj/item/clothing/tie/Initialize()
	. = ..()
	inv_overlay = image("icon" = 'icons/obj/clothing/ties_overlay.dmi', "icon_state" = "[item_state? "[item_state]" : "[icon_state]"]")


/obj/item/clothing/tie/Destroy()
	if(has_suit)
		has_suit.remove_accessory()
	if(inv_overlay)
		qdel(inv_overlay)
		inv_overlay = null
	return ..()

//when user attached an accessory to S
/obj/item/clothing/tie/proc/on_attached(obj/item/clothing/under/S, mob/living/user)
	if(!istype(S))
		return
	has_suit = S
	loc = has_suit
	has_suit.overlays += inv_overlay

	if(user)
		to_chat(user, span_notice("You attach [src] to [has_suit]."))

/obj/item/clothing/tie/proc/on_removed()
	if(!has_suit)
		return FALSE
	has_suit.overlays -= inv_overlay
	has_suit = null
	return TRUE


//for special checks if we want some to allow pinning onto a uniform.
/obj/item/clothing/tie/proc/tie_check(obj/item/clothing/under/U, mob/user)
	return TRUE




/obj/item/clothing/tie/blue
	name = "blue tie"
	icon_state = "bluetie"

/obj/item/clothing/tie/red
	name = "red tie"
	icon_state = "redtie"

/obj/item/clothing/tie/horrible
	name = "horrible tie"
	desc = "A neosilk clip-on tie. This one is disgusting."
	icon_state = "horribletie"

/obj/item/clothing/tie/stethoscope
	name = "stethoscope"
	desc = "An outdated medical apparatus for listening to the sounds of the human body. It also makes you look like you know what you're doing."
	icon_state = "stethoscope"

/obj/item/clothing/tie/stethoscope/attack(mob/living/carbon/human/M, mob/living/user)
	if(ishuman(M) && isliving(user))
		if(user.a_intent == INTENT_HELP)
			var/body_part = parse_zone(user.zone_selected)
			if(body_part)
				var/sound = "pulse"
				var/sound_strength

				if(M.stat == DEAD || HAS_TRAIT(M, TRAIT_FAKEDEATH))
					sound_strength = "cannot hear"
					sound = "anything"
				else
					sound_strength = "hear a weak"
					switch(body_part)
						if("chest")
							if(M.oxyloss < 50)
								sound_strength = "hear a healthy"
							sound = "pulse and respiration"
						if("eyes","mouth")
							sound_strength = "cannot hear"
							sound = "anything"
						else
							sound_strength = "hear a weak"

				user.visible_message("[user] places [src] against [M]'s [body_part] and listens attentively.", "You place [src] against [M.p_their()] [body_part]. You [sound_strength] [sound].")
				return
	return ..(M,user)


//Medals
/obj/item/clothing/tie/medal
	name = "bronze medal"
	desc = "A bronze medal."
	icon_state = "bronze"
	var/recipient_name //name of the person this is awarded to.
	var/recipient_rank
	var/medal_citation

/obj/item/clothing/tie/medal/tie_check(obj/item/clothing/under/U, mob/user)
	if(!ishuman(U.loc))
		to_chat(user, span_warning("[U] must be worn to apply [src]."))
	else
		var/mob/living/carbon/human/H = U.loc
		if(H.w_uniform != U)
			to_chat(user, span_warning("[U] must be worn to apply [src]."))
		else
			if(recipient_name != H.real_name)
				to_chat(user, span_warning("[src] isn't awarded to [H]."))
			else
				return TRUE

/obj/item/clothing/tie/medal/attack(mob/living/carbon/human/H, mob/living/carbon/human/user)
	if(istype(H) && istype(user) && user.a_intent == INTENT_HELP)
		if(H.w_uniform)
			var/obj/item/clothing/under/U = H.w_uniform
			if(U.hastie)
				to_chat(user, span_warning("There's already something attached to [H]'s [U.name]."))
				return
			else
				if(recipient_name != H.real_name)
					to_chat(user, span_warning("[src] isn't awarded to [H]."))
					return
				if(user != H)
					user.visible_message("[user] starts pinning [src] on [H]'s [U.name].", \
					span_notice("You start pinning [src] on [H]'s [U.name]."))
					if(user.do_actions)
						return
					if(!do_mob(user, H, 20, BUSY_ICON_FRIENDLY))
						return
				user.drop_held_item()
				U.hastie = src
				on_attached(U, user)
				H.update_inv_w_uniform()
				if(user == H)
					user.visible_message(span_notice("[user] pins [src] to [user.p_their()] [U.name]."),
					span_notice("You pin [src] to your [U.name]."))
				else
					user.visible_message("[user] pins [src] on [H]'s [U.name].", \
					span_notice("You pin [src] on [H]'s [U.name]."))
		else
			to_chat(user, span_warning("[src] needs a uniform to be pinned to."))
	else
		return ..()


/obj/item/clothing/tie/medal/examine(mob/user)
	..()
	to_chat(user, "Awarded to: \'[recipient_rank] [recipient_name]\'. The citation reads \'[medal_citation]\'.")

/obj/item/clothing/tie/medal/conduct
	name = "distinguished conduct medal"
	desc = "A bronze medal awarded for distinguished conduct. Whilst a great honor, this is the most basic award given by the TGMC"

/obj/item/clothing/tie/medal/bronze_heart
	name = "bronze heart medal"
	desc = "A bronze heart-shaped medal awarded for sacrifice. It is often awarded posthumously or for severe injury in the line of duty."
	icon_state = "bronze_heart"

/obj/item/clothing/tie/medal/nobel_science
	name = "nobel sciences award"
	desc = "A bronze medal which represents significant contributions to the field of science or engineering."

/obj/item/clothing/tie/medal/silver
	name = "silver medal"
	desc = "A silver medal."
	icon_state = "silver"

/obj/item/clothing/tie/medal/silver/valor
	name = "medal of valor"
	desc = "A silver medal awarded for acts of exceptional valor."

/obj/item/clothing/tie/medal/silver/security
	name = "robust security award"
	desc = "An award for distinguished combat and sacrifice in defence of TGMC's interests. Often awarded to security staff."

/obj/item/clothing/tie/medal/gold
	name = "gold medal"
	desc = "A prestigious golden medal."
	icon_state = "gold"

/obj/item/clothing/tie/medal/gold/captain
	name = "medal of captaincy"
	desc = "A golden medal awarded exclusively to those promoted to the rank of captain. It signifies the codified responsibilities of a captain to TGMC, and their undisputable authority over their crew."

/obj/item/clothing/tie/medal/gold/heroism
	name = "medal of exceptional heroism"
	desc = "An extremely rare golden medal awarded only by the TGMC. To recieve such a medal is the highest honor and as such, very few exist."

/obj/item/clothing/tie/medal/letter/commendation
	name = "letter of commendation"
	desc = "A letter printed on cardstock often filled with praise for the person it is intended for."
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "commendation"

//Armbands
/obj/item/clothing/tie/armband
	name = "red armband"
	desc = "A fancy red armband!"
	icon_state = "red"

/obj/item/clothing/tie/armband/cargo
	name = "cargo armband"
	desc = "An armband, worn by the crew to display which department they're assigned to. This one is brown."
	icon_state = "cargo"

/obj/item/clothing/tie/armband/engine
	name = "engineering armband"
	desc = "An armband, worn by the crew to display which department they're assigned to. This one is orange with a reflective strip!"
	icon_state = "engie"

/obj/item/clothing/tie/armband/science
	name = "science armband"
	desc = "An armband, worn by the crew to display which department they're assigned to. This one is purple."
	icon_state = "rnd"

/obj/item/clothing/tie/armband/hydro
	name = "hydroponics armband"
	desc = "An armband, worn by the crew to display which department they're assigned to. This one is green and blue."
	icon_state = "hydro"

/obj/item/clothing/tie/armband/med
	name = "medical armband"
	desc = "An armband, worn by the crew to display which department they're assigned to. This one is white."
	icon_state = "med"

/obj/item/clothing/tie/armband/medgreen
	name = "EMT armband"
	desc = "An armband, worn by the crew to display which department they're assigned to. This one is white and green."
	icon_state = "medgreen"

//Ties that can store stuff

/obj/item/clothing/tie/storage
	name = "load bearing equipment"
	desc = "Used to hold things when you don't have enough hands."
	icon_state = "webbing"
	w_class = WEIGHT_CLASS_BULKY
	var/obj/item/storage/internal/hold = /obj/item/storage/internal/tie

/obj/item/storage/internal/tie
	storage_slots = 3

/obj/item/clothing/tie/storage/Initialize()
	. = ..()
	hold = new hold(src)

/obj/item/clothing/tie/storage/Destroy()
	if(hold)
		qdel(hold)
		hold = null
	return ..()

/obj/item/clothing/tie/storage/on_attached(obj/item/clothing/under/S, mob/user)
	. = ..()
	has_suit.verbs += /obj/item/clothing/tie/storage/verb/toggle_draw_mode

/obj/item/clothing/tie/storage/on_removed()
	has_suit.verbs -= /obj/item/clothing/tie/storage/verb/toggle_draw_mode
	return ..()

/obj/item/clothing/tie/storage/verb/toggle_draw_mode()
	set name = "Switch Storage Drawing Method"
	set category = "Object"
	set src in usr
	if(!isliving(usr))
		return
	if(usr.stat)
		return

	var/obj/item/clothing/tie/storage/H = src
	if(istype(src, /obj/item/clothing/under))
		var/obj/item/clothing/under/S = src
		if (S.hastie)
			H = S.hastie

	if(H.hold)
		H.hold.draw_mode = !H.hold.draw_mode
		if(H.hold.draw_mode)
			to_chat(usr, "Clicking [H] with an empty hand now puts the last stored item in your hand.")
		else
			to_chat(usr, "Clicking [H] with an empty hand now opens the pouch storage menu.")


/obj/item/clothing/tie/storage/attack_hand(mob/living/user)
	if(has_suit)
		if(has_suit.loc == user && hold.draw_mode && hold.contents.len)
			var/obj/item/I = hold.contents[hold.contents.len]
			I.attack_hand(user)
			return
		else
			hold.open(user)
			return

	else if(hold.handle_attack_hand(user))
		return ..()

/obj/item/clothing/tie/storage/MouseDrop(obj/over_object as obj)
	if (has_suit)
		return

	if (hold.handle_mousedrop(usr, over_object))
		..(over_object)

/obj/item/clothing/tie/storage/attackby(obj/item/I, mob/user, params)
	return hold.attackby(I, user, params)

/obj/item/clothing/tie/storage/emp_act(severity)
	hold.emp_act(severity)
	..()

/obj/item/clothing/tie/storage/attack_self(mob/user as mob)
	to_chat(user, span_notice("You empty [src]."))
	var/turf/T = get_turf(src)
	hold.hide_from(usr)
	for(var/obj/item/I in hold.contents)
		hold.remove_from_storage(I, T, user)

/obj/item/clothing/tie/storage/webbing
	name = "webbing"
	desc = "A sturdy mess of synthcotton belts and buckles, ready to share your burden."
	icon_state = "webbing"
	hold = /obj/item/storage/internal/tie/webbing

/obj/item/storage/internal/tie/webbing
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

/obj/item/clothing/tie/storage/black_vest
	name = "black webbing vest"
	desc = "Robust black synthcotton vest with lots of pockets to hold whatever you need, but cannot hold in hands."
	icon_state = "vest_black"
	hold = /obj/item/storage/internal/tie/vest

/obj/item/storage/internal/tie/vest
	storage_slots = 5
	max_w_class = WEIGHT_CLASS_SMALL
	cant_hold = list(
		/obj/item/stack/razorwire,
		/obj/item/stack/sheet,
		/obj/item/stack/sandbags,
		/obj/item/stack/snow,
	)

/obj/item/clothing/tie/storage/brown_vest
	name = "brown webbing vest"
	desc = "Worn brownish synthcotton vest with lots of pockets to unload your hands."
	icon_state = "vest_brown"
	hold = /obj/item/storage/internal/tie/vest

/obj/item/clothing/tie/storage/white_vest
	name = "white webbing vest"
	desc = "A clean white Nylon vest with large pockets specially designed for medical supplies"
	icon_state = "vest_white"
	hold = /obj/item/storage/internal/tie/white_vest

/obj/item/storage/internal/tie/white_vest
	storage_slots = 12
	max_storage_space = 24
	max_w_class = WEIGHT_CLASS_BULKY

	can_hold = list(
		/obj/item/stack/medical,
		/obj/item/stack/nanopaste,
	)

/obj/item/clothing/tie/storage/white_vest/surgery
	name = "surgical vest"
	desc = "A clean white Nylon vest with large pockets specially designed for holding surgical supplies."
	icon_state = "vest_white"
	hold = /obj/item/storage/internal/tie/white_vest/surgery

/obj/item/storage/internal/tie/white_vest/surgery
	can_hold = list(
		/obj/item/tool/surgery,
		/obj/item/stack/nanopaste,
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/tweezers,
	)

/obj/item/storage/internal/tie/white_vest/surgery/Initialize()
	. = ..()
	new /obj/item/tool/surgery/scalpel/manager(src)
	new /obj/item/tool/surgery/scalpel(src)
	new /obj/item/tool/surgery/hemostat(src)
	new /obj/item/tool/surgery/retractor(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/tool/surgery/cautery(src)
	new /obj/item/tool/surgery/circular_saw(src)
	new /obj/item/tool/surgery/suture(src)
	new /obj/item/tool/surgery/bonegel(src)
	new /obj/item/tool/surgery/bonesetter(src)
	new /obj/item/tool/surgery/FixOVein(src)
	new /obj/item/stack/nanopaste(src)

/obj/item/clothing/tie/storage/white_vest/medic
	name = "corpsman webbing"
	desc = "A clean white Nylon vest with large pockets specially designed for holding common medical supplies."
	hold = /obj/item/storage/internal/tie/white_vest/medic

/obj/item/storage/internal/tie/white_vest/medic
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

/obj/item/clothing/tie/storage/knifeharness
	name = "decorated harness"
	desc = "A heavily decorated harness of sinew and leather with two knife-loops."
	icon_state = "unathiharness2"
	hold = /obj/item/storage/internal/tie/knifeharness

/obj/item/storage/internal/tie/knifeharness
	storage_slots = 2
	max_storage_space = 4
	can_hold = list(
		/obj/item/weapon/unathiknife,
		/obj/item/tool/kitchen/utensil/knife,
		/obj/item/tool/kitchen/utensil/pknife,
		/obj/item/tool/kitchen/knife,
		/obj/item/tool/kitchen/knife/ritual,
	)

/obj/item/clothing/tie/storage/knifeharness/Initialize()
	. = ..()
	new /obj/item/weapon/unathiknife(hold)
	new /obj/item/weapon/unathiknife(hold)

/obj/item/clothing/tie/storage/holster
	name = "shoulder holster"
	desc = "A handgun holster"
	icon_state = "holster"
	hold = /obj/item/storage/internal/tie/holster

/obj/item/storage/internal/tie/holster
	storage_slots = 1
	max_w_class = WEIGHT_CLASS_BULKY
	can_hold = list(
		/obj/item/weapon/gun/pistol,
		/obj/item/weapon/gun/revolver,
		/obj/item/weapon/gun/smg/standard_machinepistol,
	)

/obj/item/clothing/tie/storage/holster/armpit
	name = "shoulder holster"
	desc = "A worn-out handgun holster. Perfect for concealed carry"
	icon_state = "holster"

/obj/item/clothing/tie/storage/holster/waist
	name = "shoulder holster"
	desc = "A handgun holster. Made of expensive leather."
	icon_state = "holster"
	item_state = "holster_low"







/*
	Holobadges are worn on the belt or neck, and can be used to show that the holder is an authorized
	Security agent - the user details can be imprinted on the badge with a Security-access ID card
*/

/obj/item/clothing/tie/holobadge

	name = "holobadge"
	desc = "This glowing blue badge marks the holder as THE LAW."
	icon_state = "holobadge"
	flags_equip_slot = ITEM_SLOT_BELT

	var/stored_name = null

/obj/item/clothing/tie/holobadge/cord
	icon_state = "holobadge-cord"
	flags_equip_slot = ITEM_SLOT_MASK

/obj/item/clothing/tie/holobadge/attack_self(mob/user as mob)
	if(!stored_name)
		to_chat(user, "Waving around a badge before swiping an ID would be pretty pointless.")
		return
	if(isliving(user))
		user.visible_message(span_warning(" [user] displays [user.p_their()] TGMC Internal Security Legal Authorization Badge.\nIt reads: [stored_name], TGMC Security."),span_warning(" You display your TGMC Internal Security Legal Authorization Badge.\nIt reads: [stored_name], TGMC Security."))

/obj/item/clothing/tie/holobadge/attackby(obj/item/I, mob/user, params)
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


/obj/item/clothing/tie/holobadge/attack(mob/living/carbon/human/M, mob/living/user)
	if(isliving(user))
		user.visible_message(span_warning(" [user] invades [M]'s personal space, thrusting [src] into [M.p_their()] face insistently."),span_warning(" You invade [M]'s personal space, thrusting [src] into [M.p_their()] face insistently. You are the law."))

/obj/item/storage/box/holobadge
	name = "holobadge box"
	desc = "A box claiming to contain holobadges."

/obj/item/storage/box/holobadge/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/tie/holobadge(src)
	new /obj/item/clothing/tie/holobadge(src)
	new /obj/item/clothing/tie/holobadge(src)
	new /obj/item/clothing/tie/holobadge(src)
	new /obj/item/clothing/tie/holobadge/cord(src)
	new /obj/item/clothing/tie/holobadge/cord(src)
