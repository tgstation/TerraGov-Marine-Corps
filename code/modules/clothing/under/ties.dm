/obj/item/clothing/tie
	name = "tie"
	desc = "A neosilk clip-on tie."
	icon = 'icons/obj/clothing/ties.dmi'
	icon_state = "bluetie"
	flags_equip_slot = NONE
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/tie/Initialize()
	. = ..()
	AddElement(/datum/element/attachment, ATTACHMENT_SLOT_UNIFORM_TIE, 'icons/obj/clothing/ties_overlay.dmi', flags_attach_features = (ATTACH_REMOVABLE|ATTACH_APPLY_ON_MOB), mob_overlay_icon = 'icons/mob/ties.dmi')

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

/obj/item/clothing/tie/medal/examine(mob/user)
	. = ..()
	. += "Awarded to: \'[recipient_rank] [recipient_name]\'. The citation reads \'[medal_citation]\'."

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
