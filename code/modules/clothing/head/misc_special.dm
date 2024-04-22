/*
 * Contents:
 *		Welding mask
 *		Cakehat
 *		Ushanka
 *		Pumpkin head
 *		Kitty ears
 *		Cardborg disguise
 *		Wig
 *		Bronze hat
 */

/*
 * Welding mask
 */
/obj/item/clothing/head/welding
	name = "welding helmet"
	desc = ""
	icon_state = "welding"
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	item_state = "welding"
	custom_materials = list(/datum/material/iron=1750, /datum/material/glass=400)
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 60)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	actions_types = list(/datum/action/item_action/toggle)
	visor_flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	visor_flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	resistance_flags = FIRE_PROOF
	clothing_flags = SNUG_FIT

/obj/item/clothing/head/welding/attack_self(mob/user)
	weldingvisortoggle(user)


/*
 * Cakehat
 */
/obj/item/clothing/head/hardhat/cakehat
	name = "cakehat"
	desc = ""
	icon_state = "hardhat0_cakehat"
	item_state = "hardhat0_cakehat"
	hat_type = "cakehat"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	hitsound = 'sound/blank.ogg'
	var/hitsound_on = 'sound/blank.ogg' //so we can differentiate between cakehat and energyhat
	var/hitsound_off = 'sound/blank.ogg'
	var/force_on = 15
	var/throwforce_on = 15
	var/damtype_on = BURN
	flags_inv = HIDEEARS|HIDEHAIR
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	light_range = 2 //luminosity when on
	flags_cover = HEADCOVERSEYES
	heat = 999

	dog_fashion = /datum/dog_fashion/head

/obj/item/clothing/head/hardhat/cakehat/process()
	var/turf/location = src.loc
	if(ishuman(location))
		var/mob/living/carbon/human/M = location
		if(M.is_holding(src) || M.head == src)
			location = M.loc

	if(isturf(location))
		location.hotspot_expose(700, 1)

/obj/item/clothing/head/hardhat/cakehat/turn_on(mob/living/user)
	..()
	force = force_on
	throwforce = throwforce_on
	damtype = damtype_on
	hitsound = hitsound_on
	START_PROCESSING(SSobj, src)

/obj/item/clothing/head/hardhat/cakehat/turn_off(mob/living/user)
	..()
	force = 0
	throwforce = 0
	damtype = BRUTE
	hitsound = hitsound_off
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/head/hardhat/cakehat/get_temperature()
	return on * heat

/obj/item/clothing/head/hardhat/cakehat/energycake
	name = "energy cake"
	desc = ""
	icon_state = "hardhat0_energycake"
	item_state = "hardhat0_energycake"
	hat_type = "energycake"
	hitsound = 'sound/blank.ogg'
	hitsound_on = 'sound/blank.ogg'
	hitsound_off = 'sound/blank.ogg'
	damtype_on = BRUTE
	force_on = 18 //same as epen (but much more obvious)
	light_range = 3 //ditto
	heat = 0

/obj/item/clothing/head/hardhat/cakehat/energycake/turn_on(mob/living/user)
	playsound(user, 'sound/blank.ogg', 5, TRUE)
	to_chat(user, "<span class='warning'>I turn on \the [src].</span>")
	..()

/obj/item/clothing/head/hardhat/cakehat/energycake/turn_off(mob/living/user)
	playsound(user, 'sound/blank.ogg', 5, TRUE)
	to_chat(user, "<span class='warning'>I turn off \the [src].</span>")
	..()

/*
 * Ushanka
 */
/obj/item/clothing/head/ushanka
	name = "ushanka"
	desc = ""
	icon_state = "ushankadown"
	item_state = "ushankadown"
	flags_inv = HIDEEARS|HIDEHAIR
	var/earflaps = 1
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT

	dog_fashion = /datum/dog_fashion/head/ushanka

/obj/item/clothing/head/ushanka/attack_self(mob/user)
	if(earflaps)
		src.icon_state = "ushankaup"
		src.item_state = "ushankaup"
		earflaps = 0
		to_chat(user, "<span class='notice'>I raise the ear flaps on the ushanka.</span>")
	else
		src.icon_state = "ushankadown"
		src.item_state = "ushankadown"
		earflaps = 1
		to_chat(user, "<span class='notice'>I lower the ear flaps on the ushanka.</span>")

/*
 * Pumpkin head
 */
/obj/item/clothing/head/hardhat/pumpkinhead
	name = "carved pumpkin"
	desc = ""
	icon_state = "hardhat0_pumpkin"
	item_state = "hardhat0_pumpkin"
	hat_type = "pumpkin"
	clothing_flags = SNUG_FIT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	light_range = 2 //luminosity when on
	flags_cover = HEADCOVERSEYES

/*
 * Kitty ears
 */
/obj/item/clothing/head/kitty
	name = "kitty ears"
	desc = ""
	icon_state = "kitty"
	color = "#999999"
	dynamic_hair_suffix = ""

	dog_fashion = /datum/dog_fashion/head/kitty

/obj/item/clothing/head/kitty/equipped(mob/living/carbon/human/user, slot)
	if(ishuman(user) && slot == SLOT_HEAD)
		update_icon(user)
		user.update_inv_head() //Color might have been changed by update_icon.
	..()

/obj/item/clothing/head/kitty/update_icon(mob/living/carbon/human/user)
	if(ishuman(user))
		add_atom_colour("#[user.hair_color]", FIXED_COLOUR_PRIORITY)

/obj/item/clothing/head/kitty/genuine
	desc = ""


/obj/item/clothing/head/hardhat/reindeer
	name = "novelty reindeer hat"
	desc = ""
	icon_state = "hardhat0_reindeer"
	item_state = "hardhat0_reindeer"
	hat_type = "reindeer"
	flags_inv = 0
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	light_range = 1 //luminosity when on
	dynamic_hair_suffix = ""

	dog_fashion = /datum/dog_fashion/head/reindeer

/obj/item/clothing/head/cardborg
	name = "cardborg helmet"
	desc = ""
	icon_state = "cardborg_h"
	item_state = "cardborg_h"
	clothing_flags = SNUG_FIT
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR

	dog_fashion = /datum/dog_fashion/head/cardborg

/obj/item/clothing/head/cardborg/equipped(mob/living/user, slot)
	..()
	if(ishuman(user) && slot == SLOT_HEAD)
		var/mob/living/carbon/human/H = user
		if(istype(H.wear_armor, /obj/item/clothing/suit/cardborg))
			var/obj/item/clothing/suit/cardborg/CB = H.wear_armor
			CB.disguise(user, src)

/obj/item/clothing/head/cardborg/dropped(mob/living/user)
	..()
	user.remove_alt_appearance("standard_borg_disguise")



/obj/item/clothing/head/wig
	name = "wig"
	desc = ""
	icon = 'icons/mob/human_face.dmi'	  // default icon for all hairs
	icon_state = "hair_vlong"
	item_state = "pwig"
	flags_inv = HIDEHAIR
	color = "#000"
	var/hairstyle = "Very Long Hair"
	var/adjustablecolor = TRUE //can color be changed manually?

/obj/item/clothing/head/wig/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/clothing/head/wig/update_icon()
	var/datum/sprite_accessory/S = GLOB.hairstyles_list[hairstyle]
	if(!S)
		icon = 'icons/obj/clothing/hats.dmi'
		icon_state = "pwig"
	else
		icon = S.icon
		icon_state = S.icon_state

/obj/item/clothing/head/wig/worn_overlays(isinhands = FALSE, file2use)
	. = list()
	if(!isinhands)
		var/datum/sprite_accessory/S = GLOB.hairstyles_list[hairstyle]
		if(!S)
			return
		var/mutable_appearance/M = mutable_appearance(S.icon, S.icon_state,layer = -HAIR_LAYER)
		M.appearance_flags |= RESET_COLOR
		M.color = color
		. += M

/obj/item/clothing/head/wig/attack_self(mob/user)
	var/new_style = input(user, "Select a hairstyle", "Wig Styling")  as null|anything in (GLOB.hairstyles_list - "Bald")
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(new_style && new_style != hairstyle)
		hairstyle = new_style
		user.visible_message("<span class='notice'>[user] changes \the [src]'s hairstyle to [new_style].</span>", "<span class='notice'>I change \the [src]'s hairstyle to [new_style].</span>")
	if(adjustablecolor)
		color = input(usr,"","Choose Color",color) as color|null
	update_icon()

/obj/item/clothing/head/wig/random/Initialize(mapload)
	hairstyle = pick(GLOB.hairstyles_list - "Bald") //Don't want invisible wig
	color = "#[random_short_color()]"
	. = ..()

/obj/item/clothing/head/wig/natural
	name = "natural wig"
	desc = ""
	color = "#FFF"
	adjustablecolor = FALSE
	custom_price = 25

/obj/item/clothing/head/wig/natural/Initialize(mapload)
	hairstyle = pick(GLOB.hairstyles_list - "Bald")
	. = ..()

/obj/item/clothing/head/wig/natural/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(ishuman(user) && slot == SLOT_HEAD)
		color = "#[user.hair_color]"
		update_icon()
		user.update_inv_head()

/obj/item/clothing/head/bronze
	name = "bronze hat"
	desc = ""
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_helmet_old"
	clothing_flags = SNUG_FIT
	flags_inv = HIDEEARS|HIDEHAIR
	armor = list("melee" = 5, "bullet" = 0, "laser" = -5, "energy" = 0, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 20)

/obj/item/clothing/head/foilhat
	name = "tinfoil hat"
	desc = ""
	icon_state = "foilhat"
	item_state = "foilhat"
	armor = list("melee" = 0, "bullet" = 0, "laser" = -5,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = -5, "fire" = 0, "acid" = 0)
	equip_delay_other = 140
	clothing_flags = ANTI_TINFOIL_MANEUVER
	var/datum/brain_trauma/mild/phobia/conspiracies/paranoia
	var/warped = FALSE

/obj/item/clothing/head/foilhat/Initialize(mapload)
	. = ..()
	if(!warped)
		AddComponent(/datum/component/anti_magic, FALSE, FALSE, TRUE, ITEM_SLOT_HEAD,  6, TRUE, null, CALLBACK(src, PROC_REF(warp_up)))
	else
		warp_up()

/obj/item/clothing/head/foilhat/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot != SLOT_HEAD || warped)
		return
	if(paranoia)
		QDEL_NULL(paranoia)
	paranoia = new()
	paranoia.clonable = FALSE

	user.gain_trauma(paranoia, TRAUMA_RESILIENCE_MAGIC)
	to_chat(user, "<span class='warning'>As you don the foiled hat, an entire world of conspiracy theories and seemingly insane ideas suddenly rush into my mind. What you once thought unbelievable suddenly seems.. undeniable. Everything is connected and nothing happens just by accident. You know too much and now they're out to get you. </span>")


/obj/item/clothing/head/foilhat/MouseDrop(atom/over_object)
	//God Im sorry
	if(!warped && iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(src == C.head)
			to_chat(C, "<span class='danger'>Why would you want to take this off? Do you want them to get into my mind?!</span>")
			return
	return ..()

/obj/item/clothing/head/foilhat/dropped(mob/user)
	. = ..()
	if(paranoia)
		QDEL_NULL(paranoia)

/obj/item/clothing/head/foilhat/proc/warp_up()
	name = "scorched tinfoil hat"
	desc = ""
	warped = TRUE
	clothing_flags &= ~ANTI_TINFOIL_MANEUVER
	if(!isliving(loc) || !paranoia)
		return
	var/mob/living/target = loc
	if(target.get_item_by_slot(SLOT_HEAD) != src)
		return
	QDEL_NULL(paranoia)
	if(!target.IsUnconscious())
		to_chat(target, "<span class='warning'>My zealous conspirationism rapidly dissipates as the donned hat warps up into a ruined mess. All those theories starting to sound like nothing but a ridicolous fanfare.</span>")

/obj/item/clothing/head/foilhat/attack_hand(mob/user)
	if(!warped && iscarbon(user))
		var/mob/living/carbon/C = user
		if(src == C.head)
			to_chat(user, "<span class='danger'>Why would you want to take this off? Do you want them to get into my mind?!</span>")
			return
	return ..()

/obj/item/clothing/head/foilhat/microwave_act(obj/machinery/microwave/M)
	. = ..()
	if(!warped)
		warp_up()
