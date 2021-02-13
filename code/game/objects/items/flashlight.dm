/obj/item/flashlight
	name = "flashlight"
	desc = "A hand-held emergency light."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight"
	item_state = "flashlight"
	w_class = WEIGHT_CLASS_SMALL
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	materials = list(/datum/material/metal = 50, /datum/material/glass = 20)
	actions_types = list(/datum/action/item_action)
	light_system = MOVABLE_LIGHT
	light_on = FALSE
	light_range = 5
	light_power = 3 //luminosity when on
	var/raillight_compatible = TRUE //Can this be turned into a rail light ?
	var/activation_sound = 'sound/items/flashlight.ogg'

/obj/item/flashlight/Initialize()
	. = ..()
	if(light_on)
		update_brightness()


/obj/item/flashlight/proc/update_brightness(mob/user = null)
	if(!user && ismob(loc))
		user = loc
	if(!light_on)
		icon_state = "[initial(icon_state)]-on"
		set_light_on(TRUE)
	else
		icon_state = initial(icon_state)
		set_light_on(FALSE)

/obj/item/flashlight/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "You cannot turn the light on while in [user.loc].")
		return FALSE
	if(activation_sound)
		playsound(get_turf(src), activation_sound, 15, 1)
	update_brightness()
	update_action_button_icons()
	return TRUE

/obj/item/flashlight/proc/turn_off_light(mob/bearer)
	if(light_on)
		update_brightness(bearer)
		update_action_button_icons()
		return TRUE
	return FALSE

/obj/item/flashlight/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/screwdriver))
		if(!raillight_compatible) //No fancy messages, just no
			return

		if(light_on)
			to_chat(user, "<span class='warning'>Turn off [src] first.</span>")
			return

		if(loc == user)
			user.dropItemToGround(src) //This part is important to make sure our light sources update, as it calls dropped()

		var/obj/item/attachable/flashlight/F = new(loc)
		user.put_in_hands(F) //This proc tries right, left, then drops it all-in-one.
		to_chat(user, "<span class='notice'>You modify [src]. It can now be mounted on a weapon.</span>")
		to_chat(user, "<span class='notice'>Use a screwdriver on [F] to change it back.</span>")
		qdel(src) //Delete da old flashlight


/obj/item/flashlight/attack(mob/living/M, mob/living/user)
	if(light_on && user.zone_selected == BODY_ZONE_PRECISE_EYES)

		if((user.getBrainLoss() >= 60) && prob(50))	//too dumb to use flashlight properly
			return ..()	//just hit them in the head


		var/mob/living/carbon/human/H = M	//mob has protective eyewear
		if(ishuman(M) && ((H.head && H.head.flags_inventory & COVEREYES) || (H.wear_mask && H.wear_mask.flags_inventory & COVEREYES) || (H.glasses && H.glasses.flags_inventory & COVEREYES)))
			to_chat(user, "<span class='notice'>You're going to need to remove that [(H.head && H.head.flags_inventory & COVEREYES) ? "helmet" : (H.wear_mask && H.wear_mask.flags_inventory & COVEREYES) ? "mask": "glasses"] first.</span>")
			return

		if(M == user)	//they're using it on themselves
			M.flash_act()
			M.visible_message("<span class='notice'>[M] directs [src] to [M.p_their()] eyes.</span>", \
								"<span class='notice'>You wave the light in front of your eyes! Trippy!</span>")
			return

		user.visible_message("<span class='notice'>[user] directs [src] to [M]'s eyes.</span>", \
							"<span class='notice'>You direct [src] to [M]'s eyes.</span>")

		if(ishuman(M) || ismonkey(M))	//robots and aliens are unaffected
			var/mob/living/carbon/C = M
			if(C.stat == DEAD || C.disabilities & BLIND)	//mob is dead or fully blind
				to_chat(user, "<span class='notice'>[C] pupils does not react to the light!</span>")
			else	//they're okay!
				C.flash_act()
				to_chat(user, "<span class='notice'>[C]'s pupils narrow.</span>")
	else
		return ..()


/obj/item/flashlight/pen
	name = "penlight"
	desc = "A pen-sized light, used by medical staff."
	icon_state = "penlight"
	item_state = ""
	flags_atom = CONDUCT
	light_range = 2
	w_class = WEIGHT_CLASS_TINY
	raillight_compatible = FALSE

/obj/item/flashlight/drone
	name = "low-power flashlight"
	desc = "A miniature lamp, that might be used by small robots."
	icon_state = "penlight"
	item_state = ""
	light_range = 2
	w_class = WEIGHT_CLASS_TINY
	raillight_compatible = FALSE

//The desk lamps are a bit special
/obj/item/flashlight/lamp
	name = "desk lamp"
	desc = "A desk lamp with an adjustable mount."
	icon_state = "lamp"
	item_state = "lamp"
	light_range = 5
	w_class = WEIGHT_CLASS_BULKY
	light_on = FALSE
	raillight_compatible = FALSE

//Menorah!
/obj/item/flashlight/lamp/menorah
	name = "Menorah"
	desc = "For celebrating Chanukah."
	icon_state = "menorah"
	item_state = "menorah"
	light_range = 2
	w_class = WEIGHT_CLASS_BULKY

//Green-shaded desk lamp
/obj/item/flashlight/lamp/green
	desc = "A classic green-shaded desk lamp."
	icon_state = "lampgreen"
	item_state = "lampgreen"
	light_range = 5

/obj/item/flashlight/lamp/verb/toggle_light()
	set name = "Toggle light"
	set category = "Object"
	set src in oview(1)

	if(istype(usr, /mob/living/carbon/xenomorph)) //Sneaky xenos turning off the lights
		attack_alien(usr)
		return

	if(!usr.stat)
		attack_self(usr)

/obj/item/flashlight/lamp/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	X.do_attack_animation(src, ATTACK_EFFECT_SMASH)
	playsound(loc, 'sound/effects/metalhit.ogg', 20, TRUE)
	X.visible_message("<span class='danger'>\The [X] smashes [src]!</span>", \
	"<span class='danger'>We smash [src]!</span>", null, 5)
	deconstruct(FALSE)

// FLARES

/obj/item/flashlight/flare
	name = "flare"
	desc = "A NT standard emergency flare. There are instructions on the side, it reads 'pull cord, make light'."
	w_class = WEIGHT_CLASS_SMALL
	light_power = 6 //As bright as a flashlight, but more disposable. Doesn't burn forever though
	icon_state = "flare"
	item_state = "flare"
	actions = list()	//just pull it manually, neckbeard.
	raillight_compatible = FALSE
	activation_sound = 'sound/items/flare.ogg'
	var/fuel = 0
	var/on_damage = 7

/obj/item/flashlight/flare/Initialize()
	. = ..()
	fuel = rand(800, 1000) // Sorry for changing this so much but I keep under-estimating how long X number of ticks last in seconds.

/obj/item/flashlight/flare/proc/turn_off()
	fuel = 0 //Flares are one way; if you turn them off, you're snuffing them out.
	light_on = TRUE
	heat = 0
	force = initial(force)
	damtype = initial(damtype)
	if(ismob(loc))
		var/mob/U = loc
		update_brightness(U)
	else
		update_brightness(null)
	icon_state = "[initial(icon_state)]-empty"

/obj/item/flashlight/flare/attack_self(mob/user)

	// Usual checks
	if(!fuel)
		to_chat(user, "<span class='notice'>It's out of fuel.</span>")
		return
	if(light_on)
		return

	. = ..()
	// All good, turn it on.
	if(.)
		user.visible_message("<span class='notice'>[user] activates the flare.</span>", "<span class='notice'>You pull the cord on the flare, activating it!</span>")
		force = on_damage
		heat = 1500
		damtype = "fire"
		addtimer(CALLBACK(src, .proc/turn_off), fuel)
		if(iscarbon(user))
			var/mob/living/carbon/C = usr
			C.toggle_throw_mode()

/obj/item/flashlight/flare/on/Initialize()
	. = ..()
	light_on = TRUE
	heat = 1500
	update_brightness()
	force = on_damage
	damtype = "fire"
	addtimer(CALLBACK(src, .proc/turn_off), fuel)

/obj/item/flashlight/slime
	gender = PLURAL
	name = "glowing slime"
	desc = "A glowing ball of what appears to be amber."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "floor1" //not a slime extract sprite but... something close enough!
	item_state = "slime"
	w_class = WEIGHT_CLASS_TINY
	light_range = 6
	light_on = TRUE //Bio-luminesence has one setting, on.
	raillight_compatible = FALSE


/obj/item/flashlight/slime/attack_self(mob/user)
	return //Bio-luminescence does not toggle.

/******************************Lantern*******************************/

/obj/item/flashlight/lantern
	name = "lantern"
	icon_state = "lantern"
	desc = "A mining lantern."
	light_range = 6			// luminosity when on
	raillight_compatible = FALSE
