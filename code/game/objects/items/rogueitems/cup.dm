/obj/item/reagent_containers/glass/cup
	name = "metal cup"
	icon_state = "iron"
	icon = 'icons/roguetown/items/cooking.dmi'
	force = 5
	throwforce = 10
	reagent_flags = OPENCONTAINER
	amount_per_transfer_from_this = 6
	possible_transfer_amounts = list(6)
	dropshrink = 0.8
	w_class = WEIGHT_CLASS_NORMAL
	volume = 24
	obj_flags = CAN_BE_HIT
	sellprice = 1
	drinksounds = list('sound/items/drink_cup (1).ogg','sound/items/drink_cup (2).ogg','sound/items/drink_cup (3).ogg','sound/items/drink_cup (4).ogg','sound/items/drink_cup (5).ogg')
	fillsounds = list('sound/items/fillcup.ogg')

/obj/item/reagent_containers/glass/cup/update_icon(dont_fill=FALSE)
	testing("cupupdate")

	cut_overlays()

	if(reagents.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/roguetown/items/cooking.dmi', "[icon_state]filling")

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		filling.alpha = mix_alpha_from_reagents(reagents.reagent_list)
		add_overlay(filling)

/obj/item/reagent_containers/glass/cup/wooden
	name = "wooden cup"
	resistance_flags = FLAMMABLE
	icon_state = "wooden"
	drop_sound = 'sound/foley/dropsound/wooden_drop.ogg'

/obj/item/reagent_containers/glass/cup/steel
	name = "goblet"
	icon_state = "steel"
	sellprice = 10

/obj/item/reagent_containers/glass/cup/silver
	name = "silver goblet"
	icon_state = "silver"
	sellprice = 30

/obj/item/reagent_containers/glass/cup/silver/funny_attack_effects(mob/living/target, mob/living/user, nodmg)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.dna && H.dna.species)
			if(istype(H.dna.species, /datum/species/werewolf))
				target.Knockdown(30)
				target.Stun(30)
	if(target.mind && target.mind.has_antag_datum(/datum/antagonist/vampirelord))
		var/datum/antagonist/vampirelord/VD = target.mind.has_antag_datum(/datum/antagonist/vampirelord)
		if(!VD.disguised)
			target.Knockdown(30)
			target.Stun(30)

/obj/item/reagent_containers/glass/cup/silver/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.dna && H.dna.species)
			if(istype(H.dna.species, /datum/species/werewolf))
				return FALSE
	if(M.mind && M.mind.has_antag_datum(/datum/antagonist/vampirelord))
		return FALSE

/obj/item/reagent_containers/glass/cup/golden
	name = "golden goblet"
	icon_state = "golden"
	sellprice = 50

/obj/item/reagent_containers/glass/cup/skull
	name = "skull goblet"
	icon_state = "skull"
