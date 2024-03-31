/obj/item/flashlight
	name = "flashlight"
	desc = ""
	custom_price = 10
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight"
	item_state = "flashlight"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = null
	slot_flags = ITEM_SLOT_BELT
	possible_item_intents = list(INTENT_GENERIC)
	custom_materials = list(/datum/material/iron=50, /datum/material/glass=20)
//	actions_types = list(/datum/action/item_action/toggle_light)
	var/on = FALSE
	var/brightness_on = 40 //range of light when on
	var/flashlight_power = 1 //strength of the light when on

/obj/item/flashlight/Initialize()
	. = ..()
	if(icon_state == "[initial(icon_state)]-on")
		on = TRUE
	update_brightness()

/obj/item/flashlight/proc/update_brightness(mob/user = null)
	if(on)
		icon_state = "[initial(icon_state)]-on"
		if(flashlight_power)
			set_light(l_range = brightness_on, l_power = flashlight_power)
		else
			set_light(brightness_on)
	else
		icon_state = initial(icon_state)
		set_light(0)

/obj/item/flashlight/attack_self(mob/user)
	on = !on
	update_brightness(user)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()
	return 1

/obj/item/flashlight/suicide_act(mob/living/carbon/human/user)
	if (user.eye_blind)
		user.visible_message("<span class='suicide'>[user] is putting [src] close to [user.p_their()] eyes and turning it on... but [user.p_theyre()] blind!</span>")
		return SHAME
	user.visible_message("<span class='suicide'>[user] is putting [src] close to [user.p_their()] eyes and turning it on! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (FIRELOSS)

/obj/item/flashlight/attack(mob/living/carbon/M, mob/living/carbon/human/user)
	add_fingerprint(user)
	return ..()
/*	if(istype(M) && on && user.zone_selected in list(BODY_ZONE_PRECISE_R_EYE, BODY_ZONE_PRECISE_MOUTH))

		if((HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB)) && prob(50))	//too dumb to use flashlight properly
			return ..()	//just hit them in the head

		if(!user.IsAdvancedToolUser())
			to_chat(user, "<span class='warning'>I don't have the dexterity to do this!</span>")
			return

		if(!M.get_bodypart(BODY_ZONE_HEAD))
			to_chat(user, "<span class='warning'>[M] doesn't have a head!</span>")
			return

		if(flashlight_power < 1)
			to_chat(user, "<span class='warning'>\The [src] isn't bright enough to see anything!</span> ")
			return

		switch(user.zone_selected)
			if(BODY_ZONE_PRECISE_R_EYE)
				if((M.head && M.head.flags_cover & HEADCOVERSEYES) || (M.wear_mask && M.wear_mask.flags_cover & MASKCOVERSEYES) || (M.glasses && M.glasses.flags_cover & GLASSESCOVERSEYES))
					to_chat(user, "<span class='warning'>You're going to need to remove that [(M.head && M.head.flags_cover & HEADCOVERSEYES) ? "helmet" : (M.wear_mask && M.wear_mask.flags_cover & MASKCOVERSEYES) ? "mask": "glasses"] first!</span>")
					return

				var/obj/item/organ/eyes/E = M.getorganslot(ORGAN_SLOT_EYES)
				if(!E)
					to_chat(user, "<span class='warning'>[M] doesn't have any eyes!</span>")
					return

				if(M == user)	//they're using it on themselves
					if(M.flash_act(visual = 1))
						M.visible_message("<span class='notice'>[M] directs [src] to [M.p_their()] eyes.</span>", "<span class='notice'>I wave the light in front of your eyes! Trippy!</span>")
					else
						M.visible_message("<span class='notice'>[M] directs [src] to [M.p_their()] eyes.</span>", "<span class='notice'>I wave the light in front of your eyes.</span>")
				else
					user.visible_message("<span class='warning'>[user] directs [src] to [M]'s eyes.</span>", \
										 "<span class='danger'>I direct [src] to [M]'s eyes.</span>")
					if(M.stat == DEAD || (HAS_TRAIT(M, TRAIT_BLIND)) || !M.flash_act(visual = 1)) //mob is dead or fully blind
						to_chat(user, "<span class='warning'>[M]'s pupils don't react to the light!</span>")
					else if(M.dna && M.dna.check_mutation(XRAY))	//mob has X-ray vision
						to_chat(user, "<span class='danger'>[M]'s pupils give an eerie glow!</span>")
					else //they're okay!
						to_chat(user, "<span class='notice'>[M]'s pupils narrow.</span>")

			if(BODY_ZONE_PRECISE_MOUTH)

				if(M.is_mouth_covered())
					to_chat(user, "<span class='warning'>You're going to need to remove that [(M.head && M.head.flags_cover & HEADCOVERSMOUTH) ? "helmet" : "mask"] first!</span>")
					return

				var/their = M.p_their()

				var/list/mouth_organs = new
				for(var/obj/item/organ/O in M.internal_organs)
					if(O.zone == BODY_ZONE_PRECISE_MOUTH)
						mouth_organs.Add(O)
				var/organ_list = ""
				var/organ_count = LAZYLEN(mouth_organs)
				if(organ_count)
					for(var/I in 1 to organ_count)
						if(I > 1)
							if(I == mouth_organs.len)
								organ_list += ", and "
							else
								organ_list += ", "
						var/obj/item/organ/O = mouth_organs[I]
						organ_list += (O.gender == "plural" ? O.name : "\an [O.name]")

				var/pill_count = 0
				for(var/datum/action/item_action/hands_free/activate_pill/AP in M.actions)
					pill_count++

				if(M == user)
					var/can_use_mirror = FALSE
					if(isturf(user.loc))
						var/obj/structure/mirror/mirror = locate(/obj/structure/mirror, user.loc)
						if(mirror)
							switch(user.dir)
								if(NORTH)
									can_use_mirror = mirror.pixel_y > 0
								if(SOUTH)
									can_use_mirror = mirror.pixel_y < 0
								if(EAST)
									can_use_mirror = mirror.pixel_x > 0
								if(WEST)
									can_use_mirror = mirror.pixel_x < 0

					M.visible_message("<span class='notice'>[M] directs [src] to [their] mouth.</span>", \
					"<span class='notice'>I point [src] into your mouth.</span>")
					if(!can_use_mirror)
						to_chat(user, "<span class='notice'>I can't see anything without a mirror.</span>")
						return
					if(organ_count)
						to_chat(user, "<span class='notice'>Inside your mouth [organ_count > 1 ? "are" : "is"] [organ_list].</span>")
					else
						to_chat(user, "<span class='notice'>There's nothing inside your mouth.</span>")
					if(pill_count)
						to_chat(user, "<span class='notice'>I have [pill_count] implanted pill[pill_count > 1 ? "s" : ""].</span>")

				else
					user.visible_message("<span class='notice'>[user] directs [src] to [M]'s mouth.</span>",\
										 "<span class='notice'>I direct [src] to [M]'s mouth.</span>")
					if(organ_count)
						to_chat(user, "<span class='notice'>Inside [their] mouth [organ_count > 1 ? "are" : "is"] [organ_list].</span>")
					else
						to_chat(user, "<span class='notice'>[M] doesn't have any organs in [their] mouth.</span>")
					if(pill_count)
						to_chat(user, "<span class='notice'>[M] has [pill_count] pill[pill_count > 1 ? "s" : ""] implanted in [their] teeth.</span>")

	else
		return ..()*/

/obj/item/flashlight/pen
	name = "penlight"
	desc = ""
	icon_state = "penlight"
	item_state = ""
	flags_1 = CONDUCT_1
	brightness_on = 2
	var/holo_cooldown = 0

/obj/item/flashlight/pen/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!proximity_flag)
		if(holo_cooldown > world.time)
			to_chat(user, "<span class='warning'>[src] is not ready yet!</span>")
			return
		var/T = get_turf(target)
		if(locate(/mob/living) in T)
			new /obj/effect/temp_visual/medical_holosign(T,user) //produce a holographic glow
			holo_cooldown = world.time + 100
			return

/obj/effect/temp_visual/medical_holosign
	name = "medical holosign"
	desc = ""
	icon_state = "medi_holo"
	duration = 30

/obj/effect/temp_visual/medical_holosign/Initialize(mapload, creator)
	. = ..()
	playsound(loc, 'sound/blank.ogg', 50, FALSE) //make some noise!
	if(creator)
		visible_message("<span class='danger'>[creator] created a medical hologram!</span>")


/obj/item/flashlight/seclite
	name = "seclite"
	desc = ""
	icon_state = "seclite"
	item_state = "seclite"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	force = 9 // Not as good as a stun baton.
	brightness_on = 5 // A little better than the standard flashlight.
	hitsound = 'sound/blank.ogg'

// the desk lamps are a bit special
/obj/item/flashlight/lamp
	name = "desk lamp"
	desc = ""
	icon_state = "lamp"
	item_state = "lamp"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	force = 10
	brightness_on = 5
	w_class = WEIGHT_CLASS_BULKY
	flags_1 = CONDUCT_1
	custom_materials = null
	on = TRUE


// green-shaded desk lamp
/obj/item/flashlight/lamp/green
	desc = ""
	icon_state = "lampgreen"
	item_state = "lampgreen"



/obj/item/flashlight/lamp/verb/toggle_light()
	set name = "Toggle light"
	set hidden = 1
	set src in oview(1)

	if(!usr.stat)
		attack_self(usr)

//Bananalamp
/obj/item/flashlight/lamp/bananalamp
	name = "banana lamp"
	desc = ""
	icon_state = "bananalamp"
	item_state = "bananalamp"

// FLARES

/obj/item/flashlight/flare
	name = "flare"
	desc = ""
	w_class = WEIGHT_CLASS_SMALL
	brightness_on = 7 // Pretty bright.
	icon_state = "flare"
	item_state = "flare"
	actions_types = list()
	var/fuel = 12000
	var/on_damage = 7
	var/produce_heat = 1500
	heat = 1000
	light_color = LIGHT_COLOR_FLARE
	grind_results = list(/datum/reagent/sulfur = 15)

/obj/item/flashlight/flare/process()
	open_flame(heat)
	fuel = max(fuel - 1, 0)
	if(!fuel || !on)
		turn_off()
		if(!fuel)
			icon_state = "[initial(icon_state)]-empty"
		STOP_PROCESSING(SSobj, src)

/obj/item/flashlight/flare/ignition_effect(atom/A, mob/user)
	if(fuel && on)
		. = "<span class='notice'>[user] lights [A] with [src] like a real \
			badass.</span>"
	else
		. = ""

/obj/item/flashlight/flare/proc/turn_off()
	on = FALSE
	force = initial(src.force)
	damtype = initial(src.damtype)
	if(ismob(loc))
		var/mob/U = loc
		update_brightness(U)
	else
		update_brightness(null)

/obj/item/flashlight/flare/update_brightness(mob/user = null)
	..()
	if(on)
		item_state = "[initial(item_state)]-on"
	else
		item_state = "[initial(item_state)]"

/obj/item/flashlight/flare/attack_self(mob/user)

	// Usual checks
	if(!fuel)
		to_chat(user, "<span class='warning'>[src] is out of fuel!</span>")
		return
	if(on)
		to_chat(user, "<span class='warning'>[src] is already on!</span>")
		return

	. = ..()
	// All good, turn it on.
	if(.)
		user.visible_message("<span class='notice'>[user] lights \the [src].</span>", "<span class='notice'>I light \the [src]!</span>")
		force = on_damage
//		damtype = "fire"
		START_PROCESSING(SSobj, src)

/obj/item/flashlight/flare/get_temperature()
	return on * heat

/obj/item/flashlight/flare/torch
	name = "torch"
	desc = ""
	w_class = WEIGHT_CLASS_NORMAL
	brightness_on = 6
	force = 10
	icon = 'icons/roguetown/items/lighting.dmi'
	icon_state = "torch"
	item_state = "torch"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	light_color = "#da8c45"
	on_damage = 10
	flags_1 = null
	possible_item_intents = list(/datum/intent/hit, /datum/intent/use)
	slot_flags = ITEM_SLOT_HIP
	var/datum/looping_sound/torchloop/soundloop
	max_integrity = 200
	fuel = 30 MINUTES
	light_depth = 0
	light_height = 0

/obj/item/flashlight/flare/torch/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.7,"sx" = -9,"sy" = 3,"nx" = 12,"ny" = 4,"wx" = -6,"wy" = 5,"ex" = 3,"ey" = 6,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 2,"sturn" = 2,"wturn" = -2,"eturn" = -2,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/flashlight/flare/torch/Initialize()
	. = ..()
	soundloop = new(list(src), FALSE)

/obj/item/flashlight/flare/torch/process()
	open_flame(heat)
	if(!fuel || !on)
		turn_off()
		STOP_PROCESSING(SSobj, src)
		if(!fuel)
			icon_state = "torch-empty"
		return
	if(!istype(loc,/obj/machinery/light/rogue/torchholder))
		if(!ismob(loc))
			if(prob(23))
				turn_off()
				STOP_PROCESSING(SSobj, src)
				return
		else
			var/mob/M = loc
			if(!(src in M.held_items))
				if(prob(23))
					turn_off()
					STOP_PROCESSING(SSobj, src)
					return
		fuel = max(fuel - 10, 0)

/obj/item/flashlight/flare/torch/attack_self(mob/user)

	// Usual checks
//	if(!fuel)
//		to_chat(user, "<span class='warning'>[src] doesn't have any pitch left!</span>")
//		return
	if(on)
		turn_off()

/obj/item/flashlight/flare/torch/extinguish()
	if(on)
		turn_off()

/obj/item/flashlight/flare/torch/turn_off()
	playsound(src.loc, 'sound/items/firesnuff.ogg', 100)
	soundloop.stop()
	STOP_PROCESSING(SSobj, src)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()
		M.update_inv_belt()

/obj/item/flashlight/flare/torch/fire_act(added, maxstacks)
	if(fuel)
		if(!on)
			playsound(src.loc, 'sound/items/firelight.ogg', 100)
			on = TRUE
			update_brightness()
			force = on_damage
			soundloop.start()
			if(ismob(loc))
				var/mob/M = loc
				M.update_inv_hands()
			START_PROCESSING(SSobj, src)
	..()

/obj/item/flashlight/flare/torch/afterattack(atom/movable/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(on)
		if(prob(50) || (user.used_intent.type == /datum/intent/use))
			if(ismob(A))
				A.spark_act()
			else
				A.fire_act(3,3)

/obj/item/flashlight/flare/torch/spark_act()
	fire_act()

/obj/item/flashlight/flare/torch/metal
	name = "torch"
	force = 15
	icon_state = "mtorch"
	brightness_on = 6
	fuel = 9999 MINUTES

/obj/item/flashlight/flare/torch/lantern
	name = "lamptern"
	icon_state = "lamp"
	desc = ""
	brightness_on = 7
	on = FALSE
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_HIP
	force = 15
	on_damage = 15
	fuel = 9999 MINUTES

/obj/item/flashlight/flare/torch/lantern/process()
	open_flame(heat)
	fuel = max(fuel - 1, 0)
	if(!fuel || !on)
		turn_off()
		STOP_PROCESSING(SSobj, src)

/obj/item/flashlight/flare/torch/lantern/extinguish()
	return

/obj/item/flashlight/flare/torch/lantern/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.4,
"sx" = -2,
"sy" = -4,
"nx" = 11,
"ny" = -4,
"wx" = 2,
"wy" = -4,
"ex" = 3,
"ey" = -4,
"northabove" = 0,
"southabove" = 1,
"eastabove" = 1,
"westabove" = 0,
"nturn" = 0,
"sturn" = 0,
"wturn" = 0,
"eturn" = 0,
"nflip" = 0,
"sflip" = 0,
"wflip" = 0,
"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)


/obj/item/flashlight/lantern
	name = "lantern"
	icon_state = "lantern"
	item_state = "lantern"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	desc = ""
	brightness_on = 6			// luminosity when on



/obj/item/flashlight/lantern/heirloom_moth
	name = "old lantern"
	desc = ""
	brightness_on = 4

/obj/item/flashlight/lantern/syndicate
	name = "suspicious lantern"
	desc = ""
	icon_state = "syndilantern"
	item_state = "syndilantern"
	brightness_on = 10

/obj/item/flashlight/slime
	gender = PLURAL
	name = "glowing slime extract"
	desc = ""
	icon = 'icons/obj/lighting.dmi'
	icon_state = "slime"
	item_state = "slime"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	custom_materials = null
	brightness_on = 6 //luminosity when on

/obj/item/flashlight/emp
	var/emp_max_charges = 4
	var/emp_cur_charges = 4
	var/charge_tick = 0

/obj/item/flashlight/emp/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/flashlight/emp/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/flashlight/emp/process()
	charge_tick++
	if(charge_tick < 10)
		return FALSE
	charge_tick = 0
	emp_cur_charges = min(emp_cur_charges+1, emp_max_charges)
	return TRUE

/obj/item/flashlight/emp/attack(mob/living/M, mob/living/user)
	if(on && user.zone_selected in list(BODY_ZONE_PRECISE_R_EYE, BODY_ZONE_PRECISE_MOUTH)) // call original attack when examining organs
		..()
	return

/obj/item/flashlight/emp/afterattack(atom/movable/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return

	if(emp_cur_charges > 0)
		emp_cur_charges -= 1

		if(ismob(A))
			var/mob/M = A
			log_combat(user, M, "attacked", "EMP-light")
			M.visible_message("<span class='danger'>[user] blinks \the [src] at \the [A].</span>", \
								"<span class='danger'>[user] blinks \the [src] at you.</span>")
		else
			A.visible_message("<span class='danger'>[user] blinks \the [src] at \the [A].</span>")
		to_chat(user, "<span class='notice'>\The [src] now has [emp_cur_charges] charge\s.</span>")
		A.emp_act(EMP_HEAVY)
	else
		to_chat(user, "<span class='warning'>\The [src] needs time to recharge!</span>")
	return

/obj/item/flashlight/emp/debug //for testing emp_act()
	name = "debug EMP flashlight"
	emp_max_charges = 100
	emp_cur_charges = 100

// Glowsticks, in the uncomfortable range of similar to flares,
// but not similar enough to make it worth a refactor
/obj/item/flashlight/glowstick
	name = "glowstick"
	desc = ""
	custom_price = 10
	w_class = WEIGHT_CLASS_SMALL
	brightness_on = 4
	color = LIGHT_COLOR_GREEN
	icon_state = "glowstick"
	item_state = "glowstick"
	grind_results = list(/datum/reagent/phenol = 15, /datum/reagent/hydrogen = 10, /datum/reagent/oxygen = 5) //Meth-in-a-stick
	var/fuel = 0

/obj/item/flashlight/glowstick/Initialize()
	fuel = rand(1600, 2000)
	light_color = color
	. = ..()

/obj/item/flashlight/glowstick/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/flashlight/glowstick/process()
	fuel = max(fuel - 1, 0)
	if(!fuel)
		turn_off()
		STOP_PROCESSING(SSobj, src)
		update_icon()

/obj/item/flashlight/glowstick/proc/turn_off()
	on = FALSE
	update_icon()

/obj/item/flashlight/glowstick/update_icon()
	item_state = "glowstick"
	cut_overlays()
	if(!fuel)
		icon_state = "glowstick-empty"
		cut_overlays()
		set_light(0)
	else if(on)
		var/mutable_appearance/glowstick_overlay = mutable_appearance(icon, "glowstick-glow")
		glowstick_overlay.color = color
		add_overlay(glowstick_overlay)
		item_state = "glowstick-on"
		set_light(brightness_on)
	else
		icon_state = "glowstick"
		cut_overlays()

/obj/item/flashlight/glowstick/attack_self(mob/user)
	if(!fuel)
		to_chat(user, "<span class='notice'>[src] is spent.</span>")
		return
	if(on)
		to_chat(user, "<span class='warning'>[src] is already lit!</span>")
		return

	. = ..()
	if(.)
		user.visible_message("<span class='notice'>[user] cracks and shakes [src].</span>", "<span class='notice'>I crack and shake [src], turning it on!</span>")
		START_PROCESSING(SSobj, src)

/obj/item/flashlight/glowstick/suicide_act(mob/living/carbon/human/user)
	if(!fuel)
		user.visible_message("<span class='suicide'>[user] is trying to squirt [src]'s fluids into [user.p_their()] eyes... but it's empty!</span>")
		return SHAME
	var/obj/item/organ/eyes/eyes = user.getorganslot(ORGAN_SLOT_EYES)
	if(!eyes)
		user.visible_message("<span class='suicide'>[user] is trying to squirt [src]'s fluids into [user.p_their()] eyes... but [user.p_they()] don't have any!</span>")
		return SHAME
	user.visible_message("<span class='suicide'>[user] is squirting [src]'s fluids into [user.p_their()] eyes! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	fuel = 0
	return (FIRELOSS)

/obj/item/flashlight/glowstick/red
	name = "red glowstick"
	color = LIGHT_COLOR_RED

/obj/item/flashlight/glowstick/blue
	name = "blue glowstick"
	color = LIGHT_COLOR_BLUE

/obj/item/flashlight/glowstick/cyan
	name = "cyan glowstick"
	color = LIGHT_COLOR_CYAN

/obj/item/flashlight/glowstick/orange
	name = "orange glowstick"
	color = LIGHT_COLOR_ORANGE

/obj/item/flashlight/glowstick/yellow
	name = "yellow glowstick"
	color = LIGHT_COLOR_YELLOW

/obj/item/flashlight/glowstick/pink
	name = "pink glowstick"
	color = LIGHT_COLOR_PINK

/obj/effect/spawner/lootdrop/glowstick
	name = "random colored glowstick"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "random_glowstick"

/obj/effect/spawner/lootdrop/glowstick/Initialize()
	loot = typesof(/obj/item/flashlight/glowstick)
	. = ..()

/obj/item/flashlight/spotlight //invisible lighting source
	name = "disco light"
	desc = ""
	icon_state = null
	light_color = null
	brightness_on = 0
	light_range = 0
	light_power = 10
	alpha = 0
	layer = 0
	on = TRUE
	anchored = TRUE
	var/range = null
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/flashlight/flashdark
	name = "flashdark"
	desc = ""
	icon_state = "flashdark"
	item_state = "flashdark"
	brightness_on = 2.5
	flashlight_power = -3

/obj/item/flashlight/eyelight
	name = "eyelight"
	desc = ""
	brightness_on = 15
	flashlight_power = 1
	flags_1 = CONDUCT_1
	item_flags = DROPDEL
	actions_types = list()
