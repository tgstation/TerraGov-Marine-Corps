
/*
CONTAINS:
CANDLES
MATCHES
CIGARETTES
CIGARS
SMOKING PIPES
CHEAP LIGHTERS
ZIPPO

CIGARETTE PACKETS ARE IN FANCY.DM
*/




/*
	candle, match, lighter
*/


/obj/item/tool/candle
	name = "red candle"
	desc = "a candle"
	icon = 'icons/obj/items/candle.dmi'
	icon_state = "candle1"
	item_state = "candle1"
	w_class = 1

	var/wax = 800

/obj/item/tool/candle/update_icon()
	var/i
	if(wax>150)
		i = 1
	else if(wax>80)
		i = 2
	else i = 3
	icon_state = "candle[i][heat_source ? "_lit" : ""]"

/obj/item/tool/candle/Dispose()
	if(heat_source)
		processing_objects.Remove(src)
	if(ismob(src.loc))
		src.loc.SetLuminosity(-CANDLE_LUM)
	else
		SetLuminosity(0)
	. = ..()

/obj/item/tool/candle/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/tool/weldingtool))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.isOn()) //Badasses dont get blinded by lighting their candle with a blowtorch
			light("<span class ='notice'>[user] casually lights [src] with [W].</span>")
	else if(W.heat_source > 400)
		light()
	else
		return ..()

/obj/item/tool/candle/proc/light(flavor_text)
	if(!heat_source)
		heat_source = 1000
		if(!flavor_text)
			flavor_text = "<span class ='notice'>[usr] lights [src].</span>"
		for(var/mob/O in viewers(usr, null))
			O.show_message(flavor_text, 1)
		SetLuminosity(CANDLE_LUM)
		update_icon()
		processing_objects.Add(src)

/obj/item/tool/candle/process()
	if(!heat_source)
		processing_objects.Remove(src)
		return
	wax--
	if(!wax)
		new/obj/item/trash/candle(src.loc)
		cdel(src)
		return
	update_icon()



/obj/item/tool/candle/attack_self(mob/user as mob)
	if(heat_source)
		heat_source = 0
		update_icon()
		SetLuminosity(0)
		user.SetLuminosity(-CANDLE_LUM)
		processing_objects.Remove(src)


/obj/item/tool/candle/pickup(mob/user)
	if(heat_source && src.loc != user)
		SetLuminosity(0)
		user.SetLuminosity(CANDLE_LUM)


/obj/item/tool/candle/dropped(mob/user)
	..()
	if(heat_source && src.loc != user)
		user.SetLuminosity(-CANDLE_LUM)
		SetLuminosity(CANDLE_LUM)



///////////
//MATCHES//
///////////
/obj/item/tool/match
	name = "match"
	desc = "A simple match stick, used for lighting fine smokables."
	icon = 'icons/obj/items/cigarettes.dmi'
	icon_state = "match_unlit"
	var/burnt = 0
	var/smoketime = 5
	w_class = 1.0
	origin_tech = "materials=1"
	attack_verb = list("burnt", "singed")

/obj/item/tool/match/process()
	smoketime--
	if(smoketime < 1)
		burn_out()
		return



/obj/item/tool/match/Dispose()
	if(heat_source)
		processing_objects.Remove(src)
	. = ..()

/obj/item/tool/match/dropped(mob/user)
	if(heat_source)
		burn_out(user)
	return ..()

/obj/item/tool/match/proc/light_match()
	if(heat_source) return
	heat_source = 1000
	damtype = "burn"
	icon_state = "match_lit"
	if(ismob(loc))
		loc.SetLuminosity(2)
	else
		SetLuminosity(2)
	processing_objects.Add(src)
	update_icon()

/obj/item/tool/match/proc/burn_out(mob/user)
	heat_source = 0
	burnt = 1
	damtype = "brute"
	icon_state = "match_burnt"
	item_state = "cigoff"
	if(user && loc != user)
		user.SetLuminosity(-2)
	SetLuminosity(0)
	name = "burnt match"
	desc = "A match. This one has seen better days."
	processing_objects.Remove(src)

/obj/item/tool/lighter/dropped(mob/user)
	if(heat_source && src.loc != user)
		user.SetLuminosity(-2)
		SetLuminosity(2)
	return ..()
//////////////////
//FINE SMOKABLES//
//////////////////
/obj/item/clothing/mask/cigarette
	name = "cigarette"
	desc = "A roll of tobacco and nicotine."
	icon_state = "cigoff"
	throw_speed = 0.5
	item_state = "cigoff"
	w_class = 1
	flags_armor_protection = 0
	attack_verb = list("burnt", "singed")
	var/icon_on = "cigon"  //Note - these are in masks.dmi not in cigarette.dmi
	var/icon_off = "cigoff"
	var/type_butt = /obj/item/trash/cigbutt
	var/lastHolder = null
	var/smoketime = 300
	var/chem_volume = 15
	flags_armor_protection = 0

/obj/item/clothing/mask/cigarette/New()
	..()
	flags_atom |= NOREACT // so it doesn't react until you light it
	create_reagents(chem_volume) // making the cigarrete a chemical holder with a maximum volume of 15

/obj/item/clothing/mask/cigarette/attackby(obj/item/W, mob/user)
	..()
	if(istype(W, /obj/item/tool/weldingtool))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.isOn())//Badasses dont get blinded while lighting their cig with a blowtorch
			light("<span class='notice'>[user] casually lights the [name] with [W].</span>")

	else if(istype(W, /obj/item/tool/lighter/zippo))
		var/obj/item/tool/lighter/zippo/Z = W
		if(Z.heat_source)
			light("<span class='rose'>With a flick of their wrist, [user] lights their [name] with [W].</span>")

	else if(istype(W, /obj/item/device/flashlight/flare))
		var/obj/item/device/flashlight/flare/FL = W
		if(FL.heat_source)
			light("<span class='notice'>[user] lights their [name] with [W].</span>")

	else if(istype(W, /obj/item/tool/lighter))
		var/obj/item/tool/lighter/L = W
		if(L.heat_source)
			light("<span class='notice'>[user] manages to light their [name] with [W].</span>")

	else if(istype(W, /obj/item/tool/match))
		var/obj/item/tool/match/M = W
		if(M.heat_source)
			light("<span class='notice'>[user] lights their [name] with their [W].</span>")

	else if(istype(W, /obj/item/weapon/energy/sword))
		var/obj/item/weapon/energy/sword/S = W
		if(S.active)
			light("<span class='warning'>[user] swings their [W], barely missing their nose. They light their [name] in the process.</span>")

	else if(istype(W, /obj/item/device/assembly/igniter))
		light("<span class='notice'>[user] fiddles with [W], and manages to light their [name].</span>")

	else if(istype(W, /obj/item/attachable/attached_gun/flamer))
		light("<span class='notice'>[user] lights their [src] with the [W].</span>")

	else if(istype(W, /obj/item/weapon/gun/flamer))
		var/obj/item/weapon/gun/flamer/F = W
		if(F.lit)
			light("<span class='notice'>[user] lights their [src] with the pilot light of the [F].</span>")
		else
			user << "<span class='warning'>Turn on the pilot light first!</span>"

	else if(istype(W, /obj/item/weapon/gun))
		var/obj/item/weapon/gun/G = W
		if(istype(G.under, /obj/item/attachable/attached_gun/flamer))
			light("<span class='notice'>[user] lights their [src] with the underbarrel [G.under].</span>")

	else if(istype(W, /obj/item/tool/surgery/cautery))
		light("<span class='notice'>[user] lights their [src] with the [W].</span>")

	else if(istype(W, /obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/C = W
		if(C.item_state == icon_on)
			light("<span class='notice'>[user] lights their [src] with the [C] after a few attempts.</span>")

	else if(istype(W, /obj/item/tool/candle))
		if(W.heat_source > 200)
			light("<span class='notice'>[user] lights their [src] with the [W] after a few attempts.</span>")

	return


/obj/item/clothing/mask/cigarette/afterattack(atom/target, mob/living/user, proximity)
	..()
	if(!proximity) return
	if(istype(target, /obj/item/reagent_container/glass))	//you can dip cigarettes into beakers
		var/obj/item/reagent_container/glass/glass = target
		var/transfered = glass.reagents.trans_to(src, chem_volume)
		if(transfered)	//if reagents were transfered, show the message
			user << "<span class='notice'>You dip \the [src] into \the [glass].</span>"
		else			//if not, either the beaker was empty, or the cigarette was full
			if(!glass.reagents.total_volume)
				user << "<span class='notice'>[glass] is empty.</span>"
			else
				user << "<span class='notice'>[src] is full.</span>"

	else if(isturf(target))
		var/turf/T = target
		if(locate(/obj/flamer_fire) in T.contents)
			light("<span class='notice'>[user] lights their [src] with the burning ground.</span>")

	else if(isliving(target))
		var/mob/living/M = target
		if(M.on_fire)
			if(user == M)
				light("<span class='notice'>[user] lights their [src] from their own burning body, that's crazy!</span>")
			else
				light("<span class='notice'>[user] lights their [src] from the burning body of [M], that's stone cold.</span>")

	else if(istype(target, /obj/machinery/light))
		var/obj/machinery/light/fixture = target
		if(fixture.is_broken())
			light("<span class='notice'>[user] lights their [src] from the broken light.</span>")

/obj/item/clothing/mask/cigarette/proc/light(flavor_text)
	if(!heat_source)
		heat_source = 1000
		damtype = "fire"
		if(reagents.get_reagent_amount("phoron")) // the phoron explodes when exposed to fire
			var/datum/effect_system/reagents_explosion/e = new()
			e.set_up(round(reagents.get_reagent_amount("phoron") / 2.5, 1), get_turf(src), 0, 0)
			e.start()
			cdel(src)
			return
		if(reagents.get_reagent_amount("fuel")) // the fuel explodes, too, but much less violently
			var/datum/effect_system/reagents_explosion/e = new()
			e.set_up(round(reagents.get_reagent_amount("fuel") / 5, 1), get_turf(src), 0, 0)
			e.start()
			cdel(src)
			return
		flags_atom &= ~NOREACT // allowing reagents to react after being lit
		reagents.handle_reactions()
		icon_state = icon_on
		item_state = icon_on
		if(iscarbon(loc))
			var/mob/living/carbon/C = loc
			if(C.r_hand == src)
				C.update_inv_r_hand()
			else if(C.l_hand == src)
				C.update_inv_l_hand()
			else if(ishuman(loc))
				var/mob/living/carbon/human/H = loc
				if(H.wear_mask == src)
					H.update_inv_wear_mask()
		if(flavor_text)
			var/turf/T = get_turf(src)
			T.visible_message(flavor_text)
		processing_objects.Add(src)

/obj/item/clothing/mask/cigarette/process()
	var/mob/living/M = loc
	if(isliving(loc))
		M.IgniteMob()
	smoketime--
	if(smoketime < 1)
		die()
		return

	if(reagents && reagents.total_volume)	//	check if it has any reagents at all
		if(iscarbon(loc) && (src == loc:wear_mask)) // if it's in the human/monkey mouth, transfer reagents to the mob
			if(istype(loc, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = loc
				if(H.species.flags & IS_SYNTHETIC)
					return
			var/mob/living/carbon/C = loc

			if(prob(15)) // so it's not an instarape in case of acid
				reagents.reaction(C, INGEST)
			reagents.trans_to(C, REAGENTS_METABOLISM)
		else // else just remove some of the reagents
			reagents.remove_any(REAGENTS_METABOLISM)
	return


/obj/item/clothing/mask/cigarette/attack_self(mob/user)
	if(heat_source)
		user.visible_message("<span class='notice'>[user] calmly drops and treads on the lit [src], putting it out instantly.</span>")
		die()
	return ..()


/obj/item/clothing/mask/cigarette/proc/die()
	var/turf/T = get_turf(src)
	var/obj/item/butt = new type_butt(T)
	transfer_fingerprints_to(butt)
	if(ismob(loc))
		var/mob/living/M = loc
		M << "<span class='notice'>Your [name] goes out.</span>"
		M.temp_drop_inv_item(src)	//un-equip it so the overlays can update
		M.update_inv_wear_mask()
	processing_objects.Remove(src)
	cdel(src)

////////////
// CIGARS //
////////////
/obj/item/clothing/mask/cigarette/cigar
	name = "premium cigar"
	desc = "A brown roll of tobacco and... well, you're not quite sure. This thing's huge!"
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"
	type_butt = /obj/item/trash/cigbutt/cigarbutt
	throw_speed = 0.5
	item_state = "cigar2off"
	smoketime = 1500
	chem_volume = 20

/obj/item/clothing/mask/cigarette/cigar/cohiba
	name = "\improper Cohiba Robusto cigar"
	desc = "There's little more you could want from a cigar."

/obj/item/clothing/mask/cigarette/cigar/havana
	name = "premium Havanian cigar"
	desc = "A cigar fit for only the best of the best."
	smoketime = 7200
	chem_volume = 30


/obj/item/clothing/mask/cigarette/cigar/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/tool/weldingtool))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.isOn())
			light("<span class='notice'>[user] insults [name] by lighting it with [W].</span>")

	else if(istype(W, /obj/item/tool/lighter/zippo))
		var/obj/item/tool/lighter/zippo/Z = W
		if(Z.heat_source)
			light("<span class='rose'>With a flick of their wrist, [user] lights their [name] with their [W].</span>")

	else if(istype(W, /obj/item/device/flashlight/flare))
		var/obj/item/device/flashlight/flare/FL = W
		if(FL.heat_source)
			light("<span class='notice'>[user] lights their [name] with [W].</span>")

	else if(istype(W, /obj/item/tool/lighter))
		var/obj/item/tool/lighter/L = W
		if(L.heat_source)
			light("<span class='notice'>[user] manages to offend their [name] by lighting it with [W].</span>")

	else if(istype(W, /obj/item/tool/match))
		var/obj/item/tool/match/M = W
		if(M.heat_source)
			light("<span class='notice'>[user] lights their [name] with their [W].</span>")

	else if(istype(W, /obj/item/weapon/energy/sword))
		var/obj/item/weapon/energy/sword/S = W
		if(S.active)
			light("<span class='warning'>[user] swings their [W], barely missing their nose. They light their [name] in the process.</span>")

	else if(istype(W, /obj/item/device/assembly/igniter))
		light("<span class='notice'>[user] fiddles with [W], and manages to light their [name] with the power of science.</span>")

	else if(istype(W, /obj/item/attachable/attached_gun/flamer))
		light("<span class='notice'>[user] lights their [src] with the [W], bet that would have looked cooler if it was attached to something first!</span>")

	else if(istype(W, /obj/item/weapon/gun/flamer))
		var/obj/item/weapon/gun/flamer/F = W
		if(F.lit)
			light("<span class='notice'>[user] lights their [src] with the pilot light of the [F], the glint of pyromania in their eye.</span>")
		else
			user << "<span class='warning'>Turn on the pilot light first!</span>"

	else if(istype(W, /obj/item/weapon/gun))
		var/obj/item/weapon/gun/G = W
		if(istype(G.under, /obj/item/attachable/attached_gun/flamer))
			light("<span class='notice'>[user] lights their [src] with the underbarrel [G.under] like a complete badass.</span>")

	else if(istype(W, /obj/item/tool/surgery/cautery))
		light("<span class='notice'>[user] lights their [src] with the [W], that can't be sterile!.</span>")

	else if(istype(W, /obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/C = W
		if(C.item_state == icon_on)
			light("<span class='notice'>[user] lights their [src] with the [C] after a few attempts.</span>")

	else if(istype(W, /obj/item/tool/candle))
		if(W.heat_source > 200)
			light("<span class='notice'>[user] lights their [src] with the [W] after a few attempts.</span>")

/////////////////
//SMOKING PIPES//
/////////////////
/obj/item/clothing/mask/cigarette/pipe
	name = "smoking pipe"
	desc = "A pipe, for smoking. Probably made of meershaum or something."
	icon_state = "pipeoff"
	item_state = "pipeoff"
	icon_on = "pipeon"  //Note - these are in masks.dmi
	icon_off = "pipeoff"
	smoketime = 100

/obj/item/clothing/mask/cigarette/pipe/process()
	var/turf/location = get_turf(src)
	smoketime--
	if(smoketime < 1)
		new /obj/effect/decal/cleanable/ash(location)
		if(ismob(loc))
			var/mob/living/M = loc
			M << "<span class='notice'>Your [name] goes out, and you empty the ash.</span>"
			heat_source = 0
			icon_state = icon_off
			item_state = icon_off
			M.update_inv_wear_mask(0)
		processing_objects.Remove(src)
		return

/obj/item/clothing/mask/cigarette/pipe/attack_self(mob/user as mob) //Refills the pipe. Can be changed to an attackby later, if loose tobacco is added to vendors or something.
	if(heat_source)
		user.visible_message("<span class='notice'>[user] puts out [src].</span>")
		heat_source = 0
		icon_state = icon_off
		item_state = icon_off
		processing_objects.Remove(src)
		return
	if(smoketime <= 0)
		user << "<span class='notice'>You refill the pipe with tobacco.</span>"
		smoketime = initial(smoketime)
	return

/obj/item/clothing/mask/cigarette/pipe/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/tool/weldingtool))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.isOn())//
			light("<span class='notice'>[user] recklessly lights [name] with [W].</span>")

	else if(istype(W, /obj/item/tool/lighter/zippo))
		var/obj/item/tool/lighter/zippo/Z = W
		if(Z.heat_source)
			light("<span class='rose'>With much care, [user] lights their [name] with their [W].</span>")

	else if(istype(W, /obj/item/device/flashlight/flare))
		var/obj/item/device/flashlight/flare/FL = W
		if(FL.heat_source)
			light("<span class='notice'>[user] lights their [name] with [W].</span>")

	else if(istype(W, /obj/item/tool/lighter))
		var/obj/item/tool/lighter/L = W
		if(L.heat_source)
			light("<span class='notice'>[user] manages to light their [name] with [W].</span>")

	else if(istype(W, /obj/item/tool/match))
		var/obj/item/tool/match/M = W
		if(M.heat_source)
			light("<span class='notice'>[user] lights their [name] with their [W].</span>")

	else if(istype(W, /obj/item/device/assembly/igniter))
		light("<span class='notice'>[user] fiddles with [W], and manages to light their [name] with the power of science.</span>")

/obj/item/clothing/mask/cigarette/pipe/cobpipe
	name = "corn cob pipe"
	desc = "A nicotine delivery system popularized by folksy backwoodsmen, kept popular in the modern age and beyond by space hipsters."
	icon_state = "cobpipeoff"
	item_state = "cobpipeoff"
	icon_on = "cobpipeon"  //Note - these are in masks.dmi
	icon_off = "cobpipeoff"
	smoketime = 400



/////////
//ZIPPO//
/////////
/obj/item/tool/lighter
	name = "cheap lighter"
	desc = "A cheap-as-free lighter."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "lighter-g"
	item_state = "lighter-g"
	var/icon_on = "lighter-g-on"
	var/icon_off = "lighter-g"
	var/clr = "g"
	w_class = 1
	throwforce = 4
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_WAIST
	attack_verb = list("burnt", "singed")

/obj/item/tool/lighter/zippo
	name = "\improper Zippo lighter"
	desc = "The zippo."
	icon_state = "zippo"
	item_state = "zippo"
	icon_on = "zippoon"
	icon_off = "zippo"

/obj/item/tool/lighter/random
	New()
		clr = pick("r","c","y","g")
		icon_on = "lighter-[clr]-on"
		icon_off = "lighter-[clr]"
		icon_state = icon_off

/obj/item/tool/lighter/Dispose()
	if(ismob(src.loc))
		src.loc.SetLuminosity(-2)
	else
		SetLuminosity(0)
	. = ..()

/obj/item/tool/lighter/attack_self(mob/living/user)
	if(user.r_hand == src || user.l_hand == src)
		if(!heat_source)
			heat_source = 1500
			icon_state = icon_on
			item_state = icon_on
			if(istype(src, /obj/item/tool/lighter/zippo) )
				user.visible_message("<span class='rose'>Without even breaking stride, [user] flips open and lights [src] in one smooth movement.</span>")
			else
				if(prob(95))
					user.visible_message("<span class='notice'>After a few attempts, [user] manages to light the [src].</span>")
				else
					user << "<span class='warning'>You burn yourself while lighting the lighter.</span>"
					if (user.l_hand == src)
						user.apply_damage(2,BURN,"l_hand")
					else
						user.apply_damage(2,BURN,"r_hand")
					user.visible_message("<span class='notice'>After a few attempts, [user] manages to light the [src], they however burn their finger in the process.</span>")

			user.SetLuminosity(2)
			processing_objects.Add(src)
		else
			turn_off(user, 0)
	else
		return ..()
	return

/obj/item/tool/lighter/proc/turn_off(mob/living/bearer, var/silent = 1)
	if(heat_source)
		heat_source = 0
		icon_state = icon_off
		item_state = icon_off
		if(!silent)
			if(istype(src, /obj/item/tool/lighter/zippo) )
				bearer.visible_message("<span class='rose'>You hear a quiet click, as [bearer] shuts off [src] without even looking at what they're doing.")
			else
				bearer.visible_message("<span class='notice'>[bearer] quietly shuts off the [src].")

		bearer.SetLuminosity(-2)
		processing_objects.Remove(src)
		return 1
	return 0

/obj/item/tool/lighter/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!isliving(M))
		return
	M.IgniteMob()
	if(!istype(M, /mob))
		return

	if(istype(M.wear_mask, /obj/item/clothing/mask/cigarette) && user.zone_selected == "mouth" && heat_source)
		var/obj/item/clothing/mask/cigarette/cig = M.wear_mask
		if(M == user)
			cig.attackby(src, user)
		else
			if(istype(src, /obj/item/tool/lighter/zippo))
				cig.light("<span class='rose'>[user] whips the [name] out and holds it for [M].</span>")
			else
				cig.light("<span class='notice'>[user] holds the [name] out for [M], and lights the [cig.name].</span>")
	else
		..()

/obj/item/tool/lighter/process()


/obj/item/tool/lighter/pickup(mob/user)
	if(heat_source && src.loc != user)
		SetLuminosity(0)
		user.SetLuminosity(2)
	return


/obj/item/tool/lighter/dropped(mob/user)
	if(heat_source && src.loc != user)
		user.SetLuminosity(-2)
		SetLuminosity(2)
	return ..()
