
/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/clothing/glasses_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/clothing/glasses_right.dmi',
	)
	w_class = WEIGHT_CLASS_SMALL
	var/prescription = FALSE
	var/toggleable = FALSE
	active = TRUE
	inventory_flags = COVEREYES
	equip_slot_flags = ITEM_SLOT_EYES
	armor_protection_flags = EYES
	var/deactive_state = "degoggles"
	var/vision_flags = NONE
	var/invis_view = SEE_INVISIBLE_LIVING
	var/invis_override = 0 //Override to allow glasses to set higher than normal see_invis
	/// A percentage of how much rgb to "max" on the lighting plane
	/// This lets us brighten darkness without washing out bright color
	var/lighting_cutoff = null
	/// Similar to lighting_cutoff, except it has individual r g and b components in the same 0-100 scale
	var/list/color_cutoffs = null
	var/goggles = FALSE
	///Sound played on activate() when turning on
	var/activation_sound = 'sound/items/googles_on.ogg'
	///Sound played on activate() when turning off
	var/deactivation_sound = 'sound/items/googles_off.ogg'
	///Color to use for the HUD tint; leave null if no tint
	var/tint

/obj/item/clothing/glasses/examine_descriptor(mob/user)
	return "eyewear"

/obj/item/clothing/glasses/examine_tags(mob/user)
	. = ..()
	if(prescription)
		.["prescription"] = "It will help reduce symptoms of nearsightedness when worn."

/obj/item/clothing/glasses/Initialize(mapload)
	. = ..()
	if(active && toggleable)	//For glasses that spawn active
		active = FALSE
		activate()

/obj/item/clothing/glasses/update_icon_state()
	. = ..()
	icon_state = active ? initial(icon_state) : deactive_state

/obj/item/clothing/glasses/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_glasses()

//Glasses can still be toggled if held in the hand if the player wishes to
/obj/item/clothing/glasses/attack_self(mob/user)
	if(can_interact(user))
		activate(user)

//Just call the activate() directly instead of needing to call attack_self()
/obj/item/clothing/glasses/ui_action_click(mob/user, datum/action/item_action/action)
	//In case someone in the future adds a non-toggle action to a child type
	if(istype(action, /datum/action/item_action/toggle))
		activate(user)
		//Always return TRUE for toggles so that the UI button icon updates
		return TRUE

	return activate(user)

///Toggle the functions of the glasses
/obj/item/clothing/glasses/proc/activate(mob/user)
	SIGNAL_HANDLER
	if(!toggleable)
		return
	active = !active

	if(active && activation_sound)
		playsound(get_turf(src), activation_sound, 15)
	else if(!active && deactivation_sound)
		playsound(get_turf(src), deactivation_sound, 15)

	update_icon()	//Found out the hard way this has to be before update_inv_glasses()
	user?.update_inv_glasses()
	user?.update_sight()

	return active	//For the UI button update

/obj/item/clothing/glasses/science
	name = "science goggles"
	desc = "The goggles do nothing! Can be used as safety googles."
	icon_state = "purple"
	worn_icon_state = "glasses"

/obj/item/clothing/glasses/eyepatch
	name = "eyepatch"
	desc = "Yarr."
	icon_state = "eyepatch"
	worn_icon_state = "eyepatch"
	armor_protection_flags = NONE

/obj/item/clothing/glasses/eyepatch/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(istype(I, /obj/item/clothing/glasses/hud/health))
		var/obj/item/clothing/glasses/hud/medpatch/P = new
		to_chat(user, span_notice("You fasten the medical hud projector to the inside of the eyepatch."))
		qdel(I)
		qdel(src)
		user.put_in_hands(P)
	else if(istype(I, /obj/item/clothing/glasses/meson))
		var/obj/item/clothing/glasses/meson/eyepatch/P = new
		to_chat(user, span_notice("You fasten the meson projector to the inside of the eyepatch."))
		qdel(I)
		qdel(src)
		user.put_in_hands(P)

		update_icon()


/obj/item/clothing/glasses/monocle
	name = "monocle"
	desc = "Such a dapper eyepiece!"
	icon_state = "monocle"
	armor_protection_flags = NONE

/obj/item/clothing/glasses/material
	name = "optical material scanner"
	desc = "Very confusing glasses."
	icon_state = "material"
	worn_icon_state = "glasses"
	actions_types = list(/datum/action/item_action/toggle)
	toggleable = 1
	vision_flags = SEE_OBJS

/obj/item/clothing/glasses/regular
	name = "\improper regulation prescription glasses"
	desc = "The Corps may call them Regulation Prescription Glasses but you know them as Rut Prevention Glasses."
	icon_state = "glasses"
	worn_icon_state = "glasses"
	prescription = TRUE

/obj/item/clothing/glasses/regular/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(istype(I, /obj/item/clothing/glasses/hud/health))
		var/obj/item/clothing/glasses/hud/medglasses/P = new
		to_chat(user, span_notice("You fasten the medical hud projector to the inside of the glasses."))
		qdel(I)
		qdel(src)
		user.put_in_hands(P)

		update_icon()

/obj/item/clothing/glasses/regular/hipster
	name = "prescription glasses"
	desc = "Made by Uncool. Co."
	icon_state = "hipster_glasses"
	worn_icon_state = "hipster_glasses"

/obj/item/clothing/glasses/threedglasses
	desc = "A long time ago, people used these glasses to makes images from screens threedimensional."
	name = "3D glasses"
	icon_state = "3d"
	worn_icon_state = "3d"
	armor_protection_flags = NONE

/obj/item/clothing/glasses/gglasses
	name = "green glasses"
	desc = "Forest green glasses, like the kind you'd wear when hatching a nasty scheme."
	icon_state = "gglasses"
	worn_icon_state = "gglasses"
	armor_protection_flags = NONE

/obj/item/clothing/glasses/mgoggles
	name = "marine ballistic goggles"
	desc = "Standard issue TGMC goggles. Mostly used to decorate one's helmet."
	icon_state = "mgoggles"
	worn_icon_state = "mgoggles"
	soft_armor = list(MELEE = 40, BULLET = 40, LASER = 0, ENERGY = 15, BOMB = 35, BIO = 10, FIRE = 30, ACID = 30)
	equip_slot_flags = ITEM_SLOT_EYES|ITEM_SLOT_MASK
	goggles = TRUE
	w_class = WEIGHT_CLASS_TINY


/obj/item/clothing/glasses/mgoggles/prescription
	name = "prescription marine ballistic goggles"
	desc = "Standard issue TGMC goggles. Mostly used to decorate one's helmet. Contains prescription lenses in case you weren't sure if they were lame or not."
	prescription = TRUE

/obj/item/clothing/glasses/mgoggles/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(istype(I, /obj/item/clothing/glasses/hud/health))
		if(prescription)
			var/obj/item/clothing/glasses/hud/medgoggles/prescription/P = new
			to_chat(user, span_notice("You fasten the medical hud projector to the inside of the goggles."))
			qdel(I)
			qdel(src)
			user.put_in_hands(P)
		else
			var/obj/item/clothing/glasses/hud/medgoggles/S = new
			to_chat(user, span_notice("You fasten the medical hud projector to the inside of the goggles."))
			qdel(I)
			qdel(src)
			user.put_in_hands(S)
	else if(istype(I, /obj/item/clothing/glasses/meson))
		if(prescription)
			var/obj/item/clothing/glasses/meson/enggoggles/prescription/P = new
			to_chat(user, span_notice("You fasten the optical meson scanner to the inside of the goggles."))
			qdel(I)
			qdel(src)
			user.put_in_hands(P)
		else
			var/obj/item/clothing/glasses/meson/enggoggles/S = new
			to_chat(user, span_notice("You fasten the optical meson scanner to the inside of the goggles."))
			qdel(I)
			qdel(src)
			user.put_in_hands(S)

		update_icon()

/obj/item/clothing/glasses/m42_goggles
	name = "\improper M42 scout sight"
	desc = "A headset and goggles system for the M42 Scout Rifle. Allows highlighted imaging of surroundings. Click it to toggle."
	icon = 'icons/obj/clothing/glasses.dmi'
	icon_state = "m56_goggles"
	deactive_state = "m56_goggles_0"
	vision_flags = SEE_TURFS
	toggleable = 1
	actions_types = list(/datum/action/item_action/toggle)



//welding goggles

/obj/item/clothing/glasses/welding
	name = "welding goggles"
	desc = "Protects the eyes from welders, approved by the mad scientist association."
	icon_state = "welding-g"
	worn_icon_state = "welding-g"
	actions_types = list(/datum/action/item_action/toggle)
	inventory_flags = COVEREYES
	eye_protection = 2
	activation_sound = null
	deactivation_sound = null
	toggleable = TRUE

/obj/item/clothing/glasses/welding/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/clothing_tint, TINT_5, TRUE)

/obj/item/clothing/glasses/welding/verb/verbtoggle()
	set category = "IC.Object"
	set name = "Adjust welding goggles"
	set src in usr

	if(!usr.incapacitated())
		activate(usr)

/obj/item/clothing/glasses/welding/activate(mob/user)
	. = ..()
	if(active)
		flip_down(user)
	else
		flip_up(user)

	//This sends a signal that toggles the tint component's effects
	toggle_item_state(user)

///Toggle the welding goggles on
/obj/item/clothing/glasses/welding/proc/flip_up(mob/user)
	DISABLE_BITFIELD(inventory_flags, COVEREYES)
	DISABLE_BITFIELD(armor_protection_flags, EYES)
	eye_protection = 0
	update_icon()
	if(user)
		to_chat(user, "You push [src] up out of your face.")

///Toggle the welding goggles off
/obj/item/clothing/glasses/welding/proc/flip_down(mob/user)
	ENABLE_BITFIELD(inventory_flags, COVEREYES)
	ENABLE_BITFIELD(armor_protection_flags, EYES)
	eye_protection = initial(eye_protection)
	update_icon()
	if(user)
		to_chat(user, "You flip [src] down to protect your eyes.")

/obj/item/clothing/glasses/welding/update_icon_state()
	icon_state = "[initial(icon_state)][!active ? "up" : ""]"

/obj/item/clothing/glasses/welding/flipped/Initialize(mapload)	//spawn in flipped up.
	. = ..()
	activate()
	AddComponent(/datum/component/clothing_tint, TINT_5, FALSE)

/obj/item/clothing/glasses/welding/superior
	name = "superior welding goggles"
	desc = "Welding goggles made from more expensive materials, strangely smells like potatoes."
	icon_state = "rwelding-g"
	worn_icon_state = "rwelding-g"

/obj/item/clothing/glasses/welding/superior/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/clothing_tint, TINT_4)

//sunglasses

/obj/item/clothing/glasses/sunglasses
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
	name = "sunglasses"
	icon_state = "sun"
	worn_icon_state = "sunglasses"
	eye_protection = 1

/obj/item/clothing/glasses/sunglasses/Initialize(mapload)
	. = ..()
	if(eye_protection)
		AddComponent(/datum/component/clothing_tint, TINT_3)

/obj/item/clothing/glasses/sunglasses/blindfold
	name = "blindfold"
	desc = "Covers the eyes, preventing sight."
	icon_state = "blindfold"
	worn_icon_state = "blindfold"
	eye_protection = 2

/obj/item/clothing/glasses/sunglasses/blindfold/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/clothing_tint, TINT_BLIND)

/obj/item/clothing/glasses/sunglasses/prescription
	name = "prescription sunglasses"
	prescription = TRUE

/obj/item/clothing/glasses/sunglasses/big
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Larger than average enhanced shielding blocks many flashes."
	icon_state = "bigsunglasses"
	worn_icon_state = "bigsunglasses"

/obj/item/clothing/glasses/sunglasses/big/prescription
	name = "prescription sunglasses"
	prescription = TRUE

/obj/item/clothing/glasses/sunglasses/fake
	desc = "A pair of designer sunglasses. Doesn't seem like it'll block flashes."
	eye_protection = 0

/obj/item/clothing/glasses/sunglasses/fake/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(istype(I, /obj/item/clothing/glasses/hud/health))
		var/obj/item/clothing/glasses/hud/medsunglasses/P = new
		to_chat(user, span_notice("You fasten the medical hud projector to the inside of the glasses."))
		qdel(I)
		qdel(src)
		user.put_in_hands(P)
	else if(istype(I, /obj/item/clothing/glasses/meson))
		var/obj/item/clothing/glasses/meson/sunglasses/P = new
		to_chat(user, span_notice("You fasten the optical meson scaner to the inside of the glasses."))
		qdel(I)
		qdel(src)
		user.put_in_hands(P)
	else if(istype(I, /obj/item/clothing/glasses/night/m56_goggles))
		var/obj/item/clothing/glasses/night/sunglasses/P = new
		to_chat(user, span_notice("You fasten the KTLD sight to the inside of the glasses."))
		qdel(I)
		qdel(src)
		user.put_in_hands(P)

		update_icon()

/obj/item/clothing/glasses/sunglasses/fake/prescription
	name = "prescription sunglasses"
	prescription = TRUE

/obj/item/clothing/glasses/sunglasses/fake/big
	name = "big sunglasses"
	desc = "A pair of larger than average designer sunglasses. Doesn't seem like it'll block flashes."
	icon_state = "bigsunglasses"
	worn_icon_state = "bigsunglasses"

/obj/item/clothing/glasses/sunglasses/fake/big/prescription
	name = "big prescription sunglasses"
	prescription = TRUE

/obj/item/clothing/glasses/sunglasses/sechud
	name = "HUDSunglasses"
	desc = "Sunglasses with a HUD."
	icon_state = "sunhud"
	var/hud_type = DATA_HUD_SECURITY_ADVANCED

/obj/item/clothing/glasses/sunglasses/sechud/eyepiece
	name = "Security HUD Sight"
	desc = "A standard eyepiece, but modified to display security information to the user visually. This makes it commonplace among military police, though other models exist."
	icon_state = "securityhud"
	worn_icon_state = "securityhud"


/obj/item/clothing/glasses/sunglasses/sechud/equipped(mob/living/carbon/human/user, slot)
	if(slot == SLOT_GLASSES)
		var/datum/atom_hud/H = GLOB.huds[hud_type]
		H.add_hud_to(user)
	..()

/obj/item/clothing/glasses/sunglasses/sechud/dropped(mob/living/carbon/human/user)
	if(istype(user))
		if(src == user.glasses) //dropped is called before the inventory reference is updated.
			var/datum/atom_hud/H = GLOB.huds[hud_type]
			H.remove_hud_from(user)
	..()


/obj/item/clothing/glasses/sunglasses/sechud/tactical
	name = "tactical HUD"
	desc = "Flash-resistant goggles with inbuilt combat and security information."
	icon_state = "swatgoggles"

/obj/item/clothing/glasses/sunglasses/aviator
	name = "aviator sunglasses"
	desc = "A pair of aviator sunglasses."
	icon_state = "aviator"
	worn_icon_state = "aviator"

/obj/item/clothing/glasses/sunglasses/aviator/yellow
	name = "aviator sunglasses"
	desc = "A pair of aviator sunglasses. Comes with yellow lens."
	icon_state = "aviator_yellow"
	worn_icon_state = "aviator_yellow"

//todo rename this typepath so its not confused with glasses/night
/obj/item/clothing/glasses/night_vision
	name = "\improper BE-47 night vision goggles"
	desc = "Goggles for seeing clearer in low light conditions and maintaining sight of the surrounding environment."
	icon_state = "night_vision"
	deactive_state = "night_vision_off"
	worn_layer = COLLAR_LAYER	//The sprites are designed to render over helmets
	worn_item_state_slots = list()
	// Red with a tint of green
	color_cutoffs = list(40, 15, 10)
	vision_flags = SEE_TURFS
	toggleable = TRUE
	goggles = TRUE
	active = FALSE
	actions_types = list(/datum/action/item_action/toggle)
	activation_sound = 'sound/effects/nightvision.ogg'
	deactivation_sound = 'sound/machines/click.ogg'
	///The battery inside
	var/obj/item/cell/night_vision_battery/battery
	///How much energy this module needs when activated
	var/active_energy_cost = 4	//Little over 4 minutes of use
	///Looping sound to play
	var/datum/looping_sound/active_sound = /datum/looping_sound/scan_pulse
	///How loud the looping sound should be
	var/looping_sound_volume = 25

/obj/item/clothing/glasses/night_vision/Initialize(mapload)
	. = ..()
	//Start with a charged battery
	battery = new /obj/item/cell/night_vision_battery(src)
	active_sound = new active_sound()
	active_sound.volume = looping_sound_volume
	update_worn_state()

/obj/item/clothing/glasses/night_vision/examine(mob/user)
	. = ..()
	. += span_notice("This model drains [active_energy_cost] energy when active.")
	. += battery_status()
	. += "To eject the battery, [span_bold("[user.get_inactive_held_item() == src ? "click" : "ALT-click"]")] [src] with an empty hand. To insert a battery, [span_bold("click")] [src] with a compatible cell."

///Info regarding battery status; separate proc so that it can be displayed when examining the parent object
/obj/item/clothing/glasses/night_vision/proc/battery_status()
	if(battery)
		return span_notice("Battery: [battery.charge]/[battery.maxcharge]")
	return span_warning("No battery installed!")

/obj/item/clothing/glasses/night_vision/attack_hand(mob/living/user)
	if(user.get_inactive_held_item() == src && eject_battery(user))
		return
	return ..()

/obj/item/clothing/glasses/night_vision/AltClick(mob/user)
	if(!eject_battery(user))
		return ..()

/obj/item/clothing/glasses/night_vision/attackby(obj/item/I, mob/user, params)
	. = ..()
	insert_battery(I, user)

///Insert a battery, if checks pass
/obj/item/clothing/glasses/night_vision/proc/insert_battery(obj/item/I, mob/user)
	if(!istype(I, /obj/item/cell/night_vision_battery))
		return

	if(battery && (battery.charge > battery.maxcharge / 2))
		balloon_alert(user, "battery already installed!")
		return
	//Hot swap!
	eject_battery()

	user.temporarilyRemoveItemFromInventory(I)
	I.forceMove(src)
	battery = I
	return TRUE

///Eject the internal battery, if there is one
/obj/item/clothing/glasses/night_vision/proc/eject_battery(mob/user)
	if(user?.get_active_held_item() || !battery)
		return

	if(user)
		user.put_in_active_hand(battery)
	else
		battery.forceMove(get_turf(src))
	battery = null

	if(active)
		activate(user)

	return TRUE

/obj/item/clothing/glasses/night_vision/activate(mob/user)
	if(active)
		STOP_PROCESSING(SSobj, src)
		active_sound.stop(src)
	else
		if(!battery || battery.charge < active_energy_cost)
			if(user)
				balloon_alert(user, "no power!")
			return FALSE	//Don't activate
		START_PROCESSING(SSobj, src)
		active_sound.start(src)

	update_worn_state(!active)	//The active var has not been toggled yet, so pass the opposite value
	return ..()

/obj/item/clothing/glasses/night_vision/process()
	if(!battery?.use(active_energy_cost))
		if(ismob(loc))	//If it's deactivated while being worn, pass on the reference to activate() so that the user's sight is updated
			activate(loc)
		else
			activate()
		return PROCESS_KILL

///Simple proc to update the worn state of the glasses; will use the active value by default if no argument passed
/obj/item/clothing/glasses/night_vision/proc/update_worn_state(state = active)
	worn_item_state_slots[slot_glasses_str] = initial(icon_state) + (state ? "" : "_off")

/obj/item/clothing/glasses/night_vision/unequipped(mob/unequipper, slot)
	. = ..()
	if(active)
		activate(unequipper)

/obj/item/clothing/glasses/night_vision/Destroy()
	QDEL_NULL(active_sound)
	return ..()

//So that the toggle button is only given when in the eyes slot
/obj/item/clothing/glasses/night_vision/item_action_slot_check(mob/user, slot)
	return CHECK_BITFIELD(slot, ITEM_SLOT_EYES)

/obj/item/clothing/glasses/night_vision/mounted
	name = "\improper BE-35 night vision goggles"
	desc = "Goggles for seeing clearer in low light conditions. Must remain attached to a helmet."
	icon_state = "night_vision_mounted"
	tint = COLOR_BLUE
	vision_flags = NONE
	active_energy_cost = 2	//A little over 7 minutes of use
	looping_sound_volume = 50

/obj/item/clothing/glasses/night_vision/mounted/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, NIGHT_VISION_GOGGLES_TRAIT)

