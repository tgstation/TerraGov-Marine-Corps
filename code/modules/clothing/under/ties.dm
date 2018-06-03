/obj/item/clothing/tie
	name = "tie"
	desc = "A neosilk clip-on tie."
	icon = 'icons/obj/clothing/ties.dmi'
	icon_state = "bluetie"
	flags_equip_slot = NOFLAGS
	w_class = 2.0
	var/obj/item/clothing/under/has_suit = null		//the suit the tie may be attached to
	var/image/inv_overlay = null	//overlay used when attached to clothing.

/obj/item/clothing/tie/New()
	..()
	inv_overlay = image("icon" = 'icons/obj/clothing/ties_overlay.dmi', "icon_state" = "[item_state? "[item_state]" : "[icon_state]"]")


/obj/item/clothing/tie/Dispose()
	if(has_suit)
		has_suit.remove_accessory()
	if(inv_overlay)
		cdel(inv_overlay)
		inv_overlay = null
	. = ..()

//when user attached an accessory to S
/obj/item/clothing/tie/proc/on_attached(obj/item/clothing/under/S, mob/living/user)
	if(!istype(S))
		return
	has_suit = S
	loc = has_suit
	has_suit.overlays += inv_overlay

	if(user)
		user << "<span class='notice'>You attach [src] to [has_suit].</span>"
		src.add_fingerprint(user)

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
		if(user.a_intent == "help")
			var/body_part = parse_zone(user.zone_selected)
			if(body_part)
				var/their = "their"
				switch(M.gender)
					if(MALE)	their = "his"
					if(FEMALE)	their = "her"

				var/sound = "pulse"
				var/sound_strength

				if(M.stat == DEAD || (M.status_flags&FAKEDEATH))
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

				user.visible_message("[user] places [src] against [M]'s [body_part] and listens attentively.", "You place [src] against [their] [body_part]. You [sound_strength] [sound].")
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
		user << "<span class='warning'>[U] must be worn to apply [src].</span>"
	else
		var/mob/living/carbon/human/H = U.loc
		if(H.w_uniform != U)
			user << "<span class='warning'>[U] must be worn to apply [src].</span>"
		else
			if(recipient_name != H.real_name)
				user << "<span class='warning'>[src] isn't awarded to [H].</span>"
			else
				return TRUE

/obj/item/clothing/tie/medal/attack(mob/living/carbon/human/H, mob/living/carbon/human/user)
	if(istype(H) && istype(user) && user.a_intent == "help")
		if(H.w_uniform)
			var/obj/item/clothing/under/U = H.w_uniform
			if(U.hastie)
				user << "<span class='warning'>There's already something attached to [H]'s [U.name].</span>"
				return
			else
				if(recipient_name != H.real_name)
					user << "<span class='warning'>[src] isn't awarded to [H].</span>"
					return
				if(user != H)
					user.visible_message("[user] starts pinning [src] on [H]'s [U.name].", \
					"<span class='notice'>You start pinning [src] on [H]'s [U.name].</span>")
					if(user.action_busy)
						return
					if(!do_mob(user, H, 20, BUSY_ICON_FRIENDLY))
						return
				user.drop_held_item()
				U.hastie = src
				on_attached(U, user)
				H.update_inv_w_uniform()
				if(user == H)
					user.visible_message("<span class='notice'>[user] pins [src] to \his [U.name].</span>",
					"<span class='notice'>You pin [src] to your [U.name].</span>")
				else
					user.visible_message("[user] pins [src] on [H]'s [U.name].", \
					"<span class='notice'>You pin [src] on [H]'s [U.name].</span>")
		else
			user << "<span class='warning'>[src] needs a uniform to be pinned to.</span>"
	else
		return ..()


/obj/item/clothing/tie/medal/examine(mob/user)
	..()
	user << "Awarded to: \'[recipient_rank] [recipient_name]\'. The citation reads \'[medal_citation]\'."

/obj/item/clothing/tie/medal/conduct
	name = "distinguished conduct medal"
	desc = "A bronze medal awarded for distinguished conduct. Whilst a great honor, this is the most basic award given by the USCM"

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
	desc = "An award for distinguished combat and sacrifice in defence of W-Y's commercial interests. Often awarded to security staff."

/obj/item/clothing/tie/medal/gold
	name = "gold medal"
	desc = "A prestigious golden medal."
	icon_state = "gold"

/obj/item/clothing/tie/medal/gold/captain
	name = "medal of captaincy"
	desc = "A golden medal awarded exclusively to those promoted to the rank of captain. It signifies the codified responsibilities of a captain to W-Y, and their undisputable authority over their crew."

/obj/item/clothing/tie/medal/gold/heroism
	name = "medal of exceptional heroism"
	desc = "An extremely rare golden medal awarded only by the USCM. To recieve such a medal is the highest honor and as such, very few exist."

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




//holsters
/obj/item/clothing/tie/holster
	name = "shoulder holster"
	desc = "A handgun holster."
	icon_state = "holster"
	var/obj/item/weapon/gun/holstered = null

/obj/item/clothing/tie/holster/Dispose()
	if(holstered)
		cdel(holstered)
		holstered = null
	. = ..()

//subtypes can override this to specify what can be holstered
/obj/item/clothing/tie/holster/proc/can_holster(obj/item/weapon/gun/W)
	if(W.w_class <= 3) return 1
	return 0

/obj/item/clothing/tie/holster/proc/holster(obj/item/I, mob/user as mob)
	if(holstered)
		user << "\red There is already a [holstered] holstered here!"
		return

	if (!istype(I, /obj/item/weapon/gun))
		user << "\red Only guns can be holstered!"
		return

	var/obj/item/weapon/gun/W = I
	if (!can_holster(W))
		user << "\red This [W] won't fit in the [src]!"
		return

	holstered = W
	user.drop_inv_item_to_loc(holstered, src)
	holstered.add_fingerprint(user)
	user.visible_message("\blue [user] holsters the [holstered].", "You holster the [holstered].")

/obj/item/clothing/tie/holster/proc/unholster(mob/user as mob)
	if(!holstered)
		return

	if(user.get_active_hand() && user.get_inactive_hand())
		user << "<span class='warning'>You need an empty hand to draw the [holstered]!</span>"
	else
		if(user.a_intent == "hurt")
			usr.visible_message("<span class='danger'>[user] draws the [holstered], ready to shoot!</span>", \
			"<span class='danger'>You draw [holstered], ready to shoot!</span>")
		else
			user.visible_message("<span class='notice'>[user] draws the [holstered], pointing it at the ground.</span>", \
			"<span class='notice'>You draw the [holstered], pointing it at the ground.</span>")
		user.put_in_hands(holstered)
		holstered.add_fingerprint(user)
		holstered = null

/obj/item/clothing/tie/holster/attack_hand(mob/user as mob)
	if (has_suit)	//if we are part of a suit
		if (holstered)
			unholster(user)
		return

	..(user)

/obj/item/clothing/tie/holster/attackby(obj/item/W as obj, mob/user as mob)
	holster(W, user)

/obj/item/clothing/tie/holster/emp_act(severity)
	if (holstered)
		holstered.emp_act(severity)
	..()

/obj/item/clothing/tie/holster/examine(mob/user)
	..()
	if (holstered)
		user << "A [holstered] is holstered here."
	else
		user << "It is empty."

/obj/item/clothing/tie/holster/on_attached(obj/item/clothing/under/S, mob/user as mob)
	..()
	has_suit.verbs += /obj/item/clothing/tie/holster/verb/holster_verb

/obj/item/clothing/tie/holster/on_removed()
	has_suit.verbs -= /obj/item/clothing/tie/holster/verb/holster_verb
	..()

//For the holster hotkey
/obj/item/clothing/tie/holster/verb/holster_verb()
	set name = "Holster"
	set category = "Object"
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.stat) return

	var/obj/item/clothing/tie/holster/H = null
	if (istype(src, /obj/item/clothing/tie/holster))
		H = src
	else if (istype(src, /obj/item/clothing/under))
		var/obj/item/clothing/under/S = src
		if (S.hastie)
			H = S.hastie

	if (!H)
		usr << "/red Something is very wrong."

	if(!H.holstered)
		if(!istype(usr.get_active_hand(), /obj/item/weapon/gun))
			usr << "\blue You need your gun equiped to holster it."
			return
		var/obj/item/weapon/gun/W = usr.get_active_hand()
		H.holster(W, usr)
	else
		H.unholster(usr)

/obj/item/clothing/tie/holster/armpit
	name = "shoulder holster"
	desc = "A worn-out handgun holster. Perfect for concealed carry"
	icon_state = "holster"

/obj/item/clothing/tie/holster/waist
	name = "shoulder holster"
	desc = "A handgun holster. Made of expensive leather."
	icon_state = "holster"
	item_state = "holster_low"





//Ties that can store stuff

/obj/item/clothing/tie/storage
	name = "load bearing equipment"
	desc = "Used to hold things when you don't have enough hands."
	icon_state = "webbing"
	w_class = 3
	var/slots = 3
	var/obj/item/storage/internal/hold

/obj/item/clothing/tie/storage/New()
	..()
	hold = new/obj/item/storage/internal(src)
	hold.storage_slots = slots

/obj/item/clothing/tie/storage/Dispose()
	if(hold)
		cdel(hold)
		hold = null
	. = ..()

/obj/item/clothing/tie/storage/attack_hand(mob/user as mob)
	if (has_suit)	//if we are part of a suit
		hold.open(user)
		return

	if (hold.handle_attack_hand(user))	//otherwise interact as a regular storage item
		..(user)

/obj/item/clothing/tie/storage/MouseDrop(obj/over_object as obj)
	if (has_suit)
		return

	if (hold.handle_mousedrop(usr, over_object))
		..(over_object)

/obj/item/clothing/tie/storage/attackby(obj/item/W as obj, mob/user as mob)
	return hold.attackby(W, user)

/obj/item/clothing/tie/storage/emp_act(severity)
	hold.emp_act(severity)
	..()

/obj/item/clothing/tie/storage/hear_talk(mob/M, var/msg)
	hold.hear_talk(M, msg)
	..()

/obj/item/clothing/tie/storage/attack_self(mob/user as mob)
	user << "<span class='notice'>You empty [src].</span>"
	var/turf/T = get_turf(src)
	hold.hide_from(usr)
	for(var/obj/item/I in hold.contents)
		hold.remove_from_storage(I, T)
	src.add_fingerprint(user)

/obj/item/clothing/tie/storage/webbing
	name = "webbing"
	desc = "A sturdy mess of synthcotton belts and buckles, ready to share your burden."
	icon_state = "webbing"
	slots = 3

/obj/item/clothing/tie/storage/webbing/New()
	..()
	hold.bypass_w_limit = list(
		"/obj/item/ammo_magazine/rifle",
		"/obj/item/ammo_magazine/smg",
		"/obj/item/ammo_magazine/sniper",
		 )

/obj/item/clothing/tie/storage/black_vest
	name = "black webbing vest"
	desc = "Robust black synthcotton vest with lots of pockets to hold whatever you need, but cannot hold in hands."
	icon_state = "vest_black"
	slots = 5

/obj/item/clothing/tie/storage/brown_vest
	name = "brown webbing vest"
	desc = "Worn brownish synthcotton vest with lots of pockets to unload your hands."
	icon_state = "vest_brown"
	slots = 5


/obj/item/clothing/tie/storage/knifeharness
	name = "decorated harness"
	desc = "A heavily decorated harness of sinew and leather with two knife-loops."
	icon_state = "unathiharness2"
	slots = 2

/obj/item/clothing/tie/storage/knifeharness/New()
	..()
	hold.max_storage_space = 4
	hold.can_hold = list("/obj/item/weapon/unathiknife",\
	"/obj/item/tool/kitchen/utensil/knife",\
	"/obj/item/tool/kitchen/utensil/pknife",\
	"/obj/item/tool/kitchen/knife",\
	"/obj/item/tool/kitchen/knife/ritual")

	new /obj/item/weapon/unathiknife(hold)
	new /obj/item/weapon/unathiknife(hold)









/*
	Holobadges are worn on the belt or neck, and can be used to show that the holder is an authorized
	Security agent - the user details can be imprinted on the badge with a Security-access ID card,
	or they can be emagged to accept any ID for use in disguises.
*/

/obj/item/clothing/tie/holobadge

	name = "holobadge"
	desc = "This glowing blue badge marks the holder as THE LAW."
	icon_state = "holobadge"
	flags_equip_slot = SLOT_WAIST

	var/emagged = 0 //Emagging removes Sec check.
	var/stored_name = null

/obj/item/clothing/tie/holobadge/cord
	icon_state = "holobadge-cord"
	flags_equip_slot = SLOT_FACE

/obj/item/clothing/tie/holobadge/attack_self(mob/user as mob)
	if(!stored_name)
		user << "Waving around a badge before swiping an ID would be pretty pointless."
		return
	if(isliving(user))
		user.visible_message("\red [user] displays their W-Y Internal Security Legal Authorization Badge.\nIt reads: [stored_name], W-Y Security.","\red You display your W-Y Internal Security Legal Authorization Badge.\nIt reads: [stored_name], W-Y Security.")

/obj/item/clothing/tie/holobadge/attackby(var/obj/item/O as obj, var/mob/user as mob)

	if (istype(O, /obj/item/card/emag))
		if (emagged)
			user << "\red [src] is already cracked."
			return
		else
			emagged = 1
			user << "\red You swipe [O] and crack the holobadge security checks."
			return

	else if(istype(O, /obj/item/card/id) || istype(O, /obj/item/device/pda))

		var/obj/item/card/id/id_card = null

		if(istype(O, /obj/item/card/id))
			id_card = O
		else
			var/obj/item/device/pda/pda = O
			id_card = pda.id

		if(ACCESS_MARINE_BRIG in id_card.access || emagged)
			user << "You imprint your ID details onto the badge."
			stored_name = id_card.registered_name
			name = "holobadge ([stored_name])"
			desc = "This glowing blue badge marks [stored_name] as THE LAW."
		else
			user << "[src] rejects your insufficient access rights."
		return
	..()

/obj/item/clothing/tie/holobadge/attack(mob/living/carbon/human/M, mob/living/user)
	if(isliving(user))
		user.visible_message("\red [user] invades [M]'s personal space, thrusting [src] into their face insistently.","\red You invade [M]'s personal space, thrusting [src] into their face insistently. You are the law.")

/obj/item/storage/box/holobadge
	name = "holobadge box"
	desc = "A box claiming to contain holobadges."
	New()
		new /obj/item/clothing/tie/holobadge(src)
		new /obj/item/clothing/tie/holobadge(src)
		new /obj/item/clothing/tie/holobadge(src)
		new /obj/item/clothing/tie/holobadge(src)
		new /obj/item/clothing/tie/holobadge/cord(src)
		new /obj/item/clothing/tie/holobadge/cord(src)
		..()
		return