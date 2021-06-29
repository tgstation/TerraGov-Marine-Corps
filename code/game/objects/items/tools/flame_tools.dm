
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
	w_class = WEIGHT_CLASS_TINY
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 0.6
	light_color = LIGHT_COLOR_FIRE
	var/wax = 800

/obj/item/tool/candle/update_icon_state()
	var/i
	if(wax>150)
		i = 1
	else if(wax>80)
		i = 2
	else
		i = 3
	icon_state = "candle[i][heat ? "_lit" : ""]"

/obj/item/tool/candle/Destroy()
	if(heat)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/tool/candle/attackby(obj/item/W as obj, mob/user as mob)
	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.isOn()) //Badasses dont get blinded by lighting their candle with a blowtorch
			light("<span class ='notice'>[user] casually lights [src] with [W].</span>")
	else if(W.heat > 400)
		light()
	else
		return ..()

/obj/item/tool/candle/proc/light(flavor_text)
	if(!heat)
		heat = 1000
		if(!flavor_text)
			flavor_text = "<span class ='notice'>[usr] lights [src].</span>"
		visible_message(flavor_text)
		set_light_on(TRUE)
		update_icon()
		START_PROCESSING(SSobj, src)

/obj/item/tool/candle/process()
	if(!heat)
		STOP_PROCESSING(SSobj, src)
		return
	wax--
	if(!wax)
		new/obj/item/trash/candle(src.loc)
		qdel(src)
		return
	update_icon()



/obj/item/tool/candle/attack_self(mob/user as mob)
	if(heat)
		heat = 0
		update_icon()
		set_light(0)
		STOP_PROCESSING(SSobj, src)


///////////
//MATCHES//
///////////
/obj/item/tool/match
	name = "match"
	desc = "A simple match stick, used for lighting fine smokables."
	icon = 'icons/obj/items/cigarettes.dmi'
	icon_state = "match_unlit"
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 0.6
	light_color = LIGHT_COLOR_FIRE
	var/burnt = FALSE
	var/smoketime = 5
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("burnt", "singed")

/obj/item/tool/match/process()
	smoketime--
	if(smoketime < 1)
		burn_out()
		return



/obj/item/tool/match/Destroy()
	if(heat)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/tool/match/dropped(mob/user)
	if(heat)
		burn_out(user)
	return ..()

/obj/item/tool/match/proc/light_match()
	if(heat)
		return
	heat = 1000
	damtype = "burn"
	icon_state = "match_lit"
	set_light_on(TRUE)

	START_PROCESSING(SSobj, src)
	update_icon()

/obj/item/tool/match/proc/burn_out(mob/user)
	heat = 0
	burnt = TRUE
	damtype = "brute"
	icon_state = "match_burnt"
	item_state = "cigoff"
	set_light_on(FALSE)
	name = "burnt match"
	desc = "A match. This one has seen better days."
	STOP_PROCESSING(SSobj, src)


//////////////////
//FINE SMOKABLES//
//////////////////
/obj/item/clothing/mask/cigarette
	name = "cigarette"
	desc = "A roll of tobacco and nicotine."
	icon_state = "cigoff"
	throw_speed = 0.5
	item_state = "cigoff"
	w_class = WEIGHT_CLASS_TINY
	flags_armor_protection = NONE
	var/lit = FALSE
	var/icon_on = "cigon"  //Note - these are in masks.dmi not in cigarette.dmi
	var/icon_off = "cigoff"
	var/type_butt = /obj/item/trash/cigbutt
	var/lastHolder = null
	var/smoketime = 300
	var/chem_volume = 30
	var/list/list_reagents = list(/datum/reagent/nicotine = 15)
	/// the quantity that will be transmited each 2 seconds
	var/transquantity = 0.1
	flags_armor_protection = NONE

/obj/item/clothing/mask/cigarette/Initialize()
	. = ..()
	create_reagents(chem_volume, INJECTABLE|NO_REACT, list_reagents) // making the cigarrete a chemical holder with a maximum volume of 30

/obj/item/clothing/mask/cigarette/attackby(obj/item/W, mob/user, params)
	if(lit || smoketime <= 0)
		return

	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.isOn())//Badasses dont get blinded while lighting their cig with a blowtorch
			light("<span class='notice'>[user] casually lights the [name] with [W].</span>")

	else if(istype(W, /obj/item/tool/lighter/zippo))
		var/obj/item/tool/lighter/zippo/Z = W
		if(Z.heat)
			light("<span class='rose'>With a flick of their wrist, [user] lights their [name] with [W].</span>")

	else if(istype(W, /obj/item/flashlight/flare))
		var/obj/item/flashlight/flare/FL = W
		if(FL.heat)
			light("<span class='notice'>[user] lights their [name] with [W].</span>")

	else if(istype(W, /obj/item/explosive/grenade/flare))
		var/obj/item/explosive/grenade/flare/FL2 = W
		if(FL2.heat)
			light("<span class='notice'>[user] lights their [name] with [W].</span>")

	else if(istype(W, /obj/item/tool/lighter))
		var/obj/item/tool/lighter/L = W
		if(L.heat)
			light("<span class='notice'>[user] manages to light their [name] with [W].</span>")

	else if(istype(W, /obj/item/tool/match))
		var/obj/item/tool/match/M = W
		if(M.heat)
			light("<span class='notice'>[user] lights their [name] with their [W].</span>")

	else if(istype(W, /obj/item/weapon/energy/sword))
		var/obj/item/weapon/energy/sword/S = W
		if(S.active)
			light("<span class='warning'>[user] swings their [W], barely missing their nose. They light their [name] in the process.</span>")

	else if(istype(W, /obj/item/assembly/igniter))
		light("<span class='notice'>[user] fiddles with [W], and manages to light their [name].</span>")

	else if(istype(W, /obj/item/attachable/attached_gun/flamer))
		light("<span class='notice'>[user] lights their [src] with the [W].</span>")

	else if(istype(W, /obj/item/weapon/gun/flamer))
		light("<span class='notice'>[user] lights their [src] with the pilot light of the [W].</span>")

	else if(istype(W, /obj/item/weapon/gun))
		var/obj/item/weapon/gun/G = W
		if(istype(G, /obj/item/weapon/gun/energy/lasgun))
			var/obj/item/weapon/gun/energy/lasgun/L = G
			if(L.cell.charge)
				light("<span class='notice'>[user] deftly lights their [src] with the [L]'s low power setting.</span>")
			else
				to_chat(user, "<span class='warning'>You try to light your [src] with the [L] but your power cell has no charge!</span>")
		else if(istype(LAZYACCESS(G.attachments, ATTACHMENT_SLOT_UNDER), /obj/item/attachable/attached_gun/flamer))
			light("<span class='notice'>[user] lights their [src] with the underbarrel [LAZYACCESS(G.attachments, ATTACHMENT_SLOT_UNDER)].</span>")


	else if(istype(W, /obj/item/tool/surgery/cautery))
		light("<span class='notice'>[user] lights their [src] with the [W].</span>")

	else if(istype(W, /obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/C = W
		if(C.lit)
			light("<span class='notice'>[user] lights their [src] with the [C] after a few attempts.</span>")

	else if(istype(W, /obj/item/tool/candle))
		if(W.heat > 200)
			light("<span class='notice'>[user] lights their [src] with the [W] after a few attempts.</span>")

	else
		return ..()


/obj/item/clothing/mask/cigarette/afterattack(obj/item/reagent_containers/glass/glass, mob/living/user, proximity)
	. = ..()
	if(!proximity || lit) //can't dip if cigarette is lit
		return
	if(istype(glass))	//you can dip cigarettes into beakers
		if(glass.reagents.trans_to(src, chem_volume))	//if reagents were transfered, show the message
			to_chat(user, "<span class='notice'>You dip \the [src] into \the [glass].</span>")
		else			//if not, either the beaker was empty, or the cigarette was full
			if(!glass.reagents.total_volume)
				to_chat(user, "<span class='notice'>[glass] is empty.</span>")
			else
				to_chat(user, "<span class='notice'>[src] is full.</span>")

/obj/item/clothing/mask/cigarette/proc/light(flavor_text = null)
	if(lit)
		return

	lit = TRUE
	heat = 1000
	name = "lit [name]"
	attack_verb = list("burnt", "singed")
	damtype = "fire"
	if(reagents.get_reagent_amount(/datum/reagent/toxin/phoron)) // the phoron explodes when exposed to fire
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount(/datum/reagent/toxin/phoron) * 0.4, 1), get_turf(src))
		e.start()
		qdel(src)
		return
	if(reagents.get_reagent_amount(/datum/reagent/fuel)) // the fuel explodes, too, but much less violently
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount(/datum/reagent/fuel) * 0.2, 1), get_turf(src))
		e.start()
		qdel(src)
		return
	DISABLE_BITFIELD(reagents.reagent_flags, NO_REACT)
	reagents.handle_reactions()
	icon_state = icon_on
	item_state = icon_on
	if(flavor_text)
		var/turf/T = get_turf(src)
		T.visible_message(flavor_text)
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
	playsound(src, 'sound/items/cig_light.ogg', 15, 1)
	START_PROCESSING(SSobj, src)

/obj/item/clothing/mask/cigarette/process()
	var/mob/living/M = loc
	if(isliving(loc))
		M.IgniteMob()
	smoketime--
	if(smoketime < 1)
		if(ismob(loc))
			to_chat(M, "<span class='notice'>Your [name] goes out.</span>")
			playsound(src, 'sound/items/cig_snuff.ogg', 15, 1)
		die()
		return

	if(reagents && reagents.total_volume)	//	check if it has any reagents at all
		if(iscarbon(loc) && (src == loc:wear_mask)) // if it's in the human/monkey mouth, transfer reagents to the mob //TODO WHAT BAYCODER USED A : UNIRONICALLY
			if(ishuman(loc))
				var/mob/living/carbon/human/H = loc
				if(H.species.species_flags & IS_SYNTHETIC)
					return
			var/mob/living/carbon/C = loc

			if(prob(15)) // so it's not an instarape in case of acid
				reagents.reaction(C, INGEST)
			reagents.trans_to(C, transquantity)
		else // else just remove some of the reagents
			reagents.remove_any(REAGENTS_METABOLISM)



/obj/item/clothing/mask/cigarette/attack_self(mob/user)
	if(lit)
		user.visible_message("<span class='notice'>[user] calmly drops and treads on the lit [src], putting it out instantly.</span>")
		playsound(src, 'sound/items/cig_snuff.ogg', 15, 1)
		die()
	return ..()

/obj/item/clothing/mask/cigarette/attack(atom/target, mob/living/user)
	if(!lit)
		if(isturf(target))
			var/turf/T = target
			if(locate(/obj/flamer_fire) in T.contents)
				light("<span class='notice'>[user] lights their [src] with the burning ground.</span>")
				return

		if(isliving(target) && user.a_intent == INTENT_HELP)
			var/mob/living/M = target
			if(M.on_fire)
				if(user == M)
					light("<span class='notice'>[user] lights their [src] from their own burning body, that's crazy!</span>")
				else
					light("<span class='notice'>[user] lights their [src] from the burning body of [M], that's stone cold.</span>")
				return

		if(istype(target, /obj/machinery/light))
			var/obj/machinery/light/fixture = target
			if(fixture.is_broken())
				light("<span class='notice'>[user] lights their [src] from the broken light.</span>")
				return
	return ..()

/obj/item/clothing/mask/cigarette/proc/die()
	var/turf/T = get_turf(src)
	new type_butt(T)
	if(ismob(loc))
		var/mob/living/M = loc
		M.temporarilyRemoveItemFromInventory(src)	//un-equip it so the overlays can update
		M.update_inv_wear_mask()
	STOP_PROCESSING(SSobj, src)
	qdel(src)

/obj/item/clothing/mask/cigarette/antitox
	name = "Neurokiller cigarette"
	desc = "A new type of cigarette, made to fend off toxic gasses, might still tire you."
	icon_state = "anticigoff"
	item_state = "anticigoff"
	icon_on = "anticigon"
	smoketime = 30
	chem_volume = 60
	transquantity = 2 // one of each for the whole duration
	list_reagents = list(/datum/reagent/medicine/ryetalyn = 30, /datum/reagent/water = 30)  //some water so it purges the rye too

/obj/item/clothing/mask/cigarette/emergency
	name = "Red Comrade"
	desc = "A red cigarrete. With some writings in it. Some of it is in russian, but,the Red Russian warning, is in indistinguishable."
	icon_state = "rrcigoff"
	item_state = "rrcigoff"
	icon_on = "rrcigon"
	smoketime = 10
	transquantity = 1
	list_reagents = list(/datum/reagent/medicine/russian_red = 10)  //same ammount as a pill

/obj/item/clothing/mask/cigarette/bica
	name = "strawberry flavored cigarette"
	desc = "Red tipped. Has got a single word stamped on the side: \"(BICARDINE)\"."
	icon_state = "bicacigoff"
	item_state = "bicacigoff"
	icon_on = "bicaigon"
	smoketime = 30
	transquantity = 5 // one of each for the whole duration
	list_reagents = list(/datum/reagent/medicine/bicaridine = 15)

/obj/item/clothing/mask/cigarette/kelo
	name = "lemon flavored cigarette"
	desc = "Yellow tipped. has got a single word stamped on the side: \"(KELOTANE)\"."
	icon_state = "kelocigoff"
	item_state = "kelocigoff"
	icon_on = "kelocigon"
	smoketime = 30
	transquantity = 5 // one of each for the whole duration
	list_reagents = list(/datum/reagent/medicine/kelotane = 15)

/obj/item/clothing/mask/cigarette/tram
	name = "poppy flavored cigarette"
	desc = "TerraGov opioid alternative, diluted in water to skirt the 2112 Opioid Control act."
	icon_state = "tramcigoff"
	item_state = "tramcigoff"
	icon_on = "tramcigon"
	smoketime = 15  //so half a minute
	chem_volume = 60
	transquantity = 2 // one of each for the whole duration
	list_reagents = list(/datum/reagent/medicine/tramadol = 30, /datum/reagent/water = 30)

////////////
// CIGARS //
////////////
/obj/item/clothing/mask/cigarette/cigar
	name = "premium cigar"
	desc = "A brown roll of tobacco and... well, you're not quite sure. This thing's huge!"
	icon_state = "cigaroff"
	icon_on = "cigaron"
	icon_off = "cigaroff"
	type_butt = /obj/item/trash/cigbutt/cigarbutt
	throw_speed = 0.5
	item_state = "cigaroff"
	smoketime = 1500
	chem_volume = 40
	list_reagents = list(/datum/reagent/nicotine = 10)

/obj/item/clothing/mask/cigarette/cigar/cohiba
	name = "\improper Cohiba Robusto cigar"
	desc = "There's little more you could want from a cigar."
	smoketime = 2000
	chem_volume = 80
	list_reagents = list(/datum/reagent/nicotine = 15)

/obj/item/clothing/mask/cigarette/cigar/havana
	name = "premium Havanian cigar"
	desc = "A cigar fit for only the best of the best."
	smoketime = 7200
	chem_volume = 50
	list_reagents = list(/datum/reagent/nicotine = 20)

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
			to_chat(M, "<span class='notice'>Your [name] goes out, and you empty the ash.</span>")
			heat = 0
			lit = FALSE
			icon_state = icon_off
			item_state = icon_off
			M.update_inv_wear_mask(0)
		STOP_PROCESSING(SSobj, src)
		return

/obj/item/clothing/mask/cigarette/pipe/attack_self(mob/user as mob) //Refills the pipe. Can be changed to an attackby later, if loose tobacco is added to vendors or something.
	if(lit)
		user.visible_message("<span class='notice'>[user] puts out [src].</span>")
		heat = 0
		lit = FALSE
		icon_state = icon_off
		item_state = icon_off
		STOP_PROCESSING(SSobj, src)
		return
	if(smoketime <= 0)
		to_chat(user, "<span class='notice'>You refill the pipe with tobacco.</span>")
		smoketime = initial(smoketime)


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
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 0.6
	light_color = LIGHT_COLOR_FIRE
	w_class = WEIGHT_CLASS_TINY
	throwforce = 4
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	attack_verb = list("burnt", "singed")

/obj/item/tool/lighter/zippo
	name = "\improper Zippo lighter"
	desc = "The zippo."
	icon_state = "zippo"
	item_state = "zippo"
	icon_on = "zippoon"
	icon_off = "zippo"

/obj/item/tool/lighter/random/Initialize()
	. = ..()
	clr = pick("r","c","y","g")
	icon_on = "lighter-[clr]-on"
	icon_off = "lighter-[clr]"
	icon_state = icon_off

/obj/item/tool/lighter/attack_self(mob/living/user)
	if(user.r_hand == src || user.l_hand == src)
		if(!heat)
			heat = 1500
			icon_state = icon_on
			item_state = icon_on
			if(istype(src, /obj/item/tool/lighter/zippo) )
				user.visible_message("<span class='rose'>Without even breaking stride, [user] flips open and lights [src] in one smooth movement.</span>")
				playsound(loc, 'sound/items/zippo_on.ogg', 15, 1)
			else
				if(prob(95))
					user.visible_message("<span class='notice'>After a few attempts, [user] manages to light the [src].</span>")
				else
					to_chat(user, "<span class='warning'>You burn yourself while lighting the lighter.</span>")
					if (user.l_hand == src)
						user.apply_damage(2,BURN,"l_hand")
					else
						user.apply_damage(2,BURN,"r_hand")
					user.visible_message("<span class='notice'>After a few attempts, [user] manages to light the [src], they however burn their finger in the process.</span>")
				playsound(loc, 'sound/items/lighter_on.ogg', 15, 1)
			set_light_on(TRUE)
		else
			turn_off(user, FALSE)
	else
		return ..()

/obj/item/tool/lighter/proc/turn_off(mob/living/bearer, silent = TRUE)
	if(heat)
		heat = 0
		icon_state = icon_off
		item_state = icon_off
		if(!silent)
			if(istype(src, /obj/item/tool/lighter/zippo) )
				bearer.visible_message("<span class='rose'>You hear a quiet click, as [bearer] shuts off [src] without even looking at what they're doing.")
				playsound(loc, 'sound/items/zippo_off.ogg', 15, 1)
			else
				bearer.visible_message("<span class='notice'>[bearer] quietly shuts off the [src].")
				playsound(loc, 'sound/items/lighter_off.ogg', 15, 1)
		set_light_on(FALSE)
		return TRUE
	return FALSE

/obj/item/tool/lighter/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!isliving(M))
		return
	M.IgniteMob()
	if(!istype(M, /mob))
		return

	if(istype(M.wear_mask, /obj/item/clothing/mask/cigarette) && user.zone_selected == "mouth" && heat)
		var/obj/item/clothing/mask/cigarette/cig = M.wear_mask
		if(M == user)
			cig.attackby(src, user)
		else
			if(istype(src, /obj/item/tool/lighter/zippo))
				cig.light("<span class='rose'>[user] whips the [name] out and holds it for [M].</span>")
			else
				cig.light("<span class='notice'>[user] holds the [name] out for [M], and lights the [cig.name].</span>")
	else
		return ..()
