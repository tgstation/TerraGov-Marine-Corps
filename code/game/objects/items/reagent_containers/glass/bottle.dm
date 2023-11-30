
//Not to be confused with /obj/item/reagent_containers/food/drinks/bottle

/obj/item/reagent_containers/glass/bottle
	name = "bottle"
	desc = "A small bottle."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = null
	item_state = "bottle"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,60)
	volume = 60
	attack_speed = 4

/obj/item/reagent_containers/glass/bottle/on_reagent_change()
	update_icon()

/obj/item/reagent_containers/glass/bottle/pickup(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/glass/bottle/dropped(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/glass/bottle/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	update_icon()

/obj/item/reagent_containers/glass/bottle/Initialize(mapload)
	. = ..()
	if(!icon_state)
		icon_state = "bottle-[rand(1, 5)]"

/obj/item/reagent_containers/glass/bottle/update_icon()
	overlays.Cut()

	if(reagents.total_volume && (icon_state == "bottle-1" || icon_state == "bottle-2" || icon_state == "bottle-3" || icon_state == "bottle-4")) //only for those who have reagentfillings icons
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)		filling.icon_state = "[icon_state]--10"
			if(10 to 24) 	filling.icon_state = "[icon_state]-10"
			if(25 to 49)	filling.icon_state = "[icon_state]-25"
			if(50 to 74)	filling.icon_state = "[icon_state]-50"
			if(75 to 79)	filling.icon_state = "[icon_state]-75"
			if(80 to 90)	filling.icon_state = "[icon_state]-80"
			if(91 to INFINITY)	filling.icon_state = "[icon_state]-100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

	if (!is_open_container())
		var/image/lid = image(icon, src, "lid_bottle")
		overlays += lid

/obj/item/reagent_containers/glass/bottle/empty //Because the parent has RNG icon_state
	icon_state = "bottle-1" //Same one when you make a bottle in the chem master

/obj/item/reagent_containers/glass/bottle/inaprovaline
	name = "\improper Inaprovaline bottle"
	desc = "A small bottle. Contains inaprovaline - used to stabilize patients."
	icon_state = "bottle19"
	list_reagents = list(/datum/reagent/medicine/inaprovaline = 60)

/obj/item/reagent_containers/glass/bottle/kelotane
	name = "\improper Kelotane bottle"
	desc = "A small bottle. Contains kelotane - used to treat burned areas."
	icon_state = "bottle15"
	list_reagents = list(/datum/reagent/medicine/kelotane = 60)

/obj/item/reagent_containers/glass/bottle/dexalin
	name = "\improper Dexalin bottle"
	desc = "A small bottle. Contains dexalin - used to supply blood with oxygen."
	icon_state = "bottle10"
	list_reagents = list(/datum/reagent/medicine/dexalin = 60)

/obj/item/reagent_containers/glass/bottle/spaceacillin
	name = "\improper Spaceacillin bottle"
	desc = "A small bottle. Contains spaceacillin - used to treat infected wounds."
	icon_state = "bottle8"
	list_reagents = list(/datum/reagent/medicine/spaceacillin = 60)

/obj/item/reagent_containers/glass/bottle/toxin
	name = "toxin bottle"
	desc = "A small bottle of toxins. Do not drink, it is poisonous."
	icon_state = "bottle12"
	list_reagents = list(/datum/reagent/toxin = 60)

/obj/item/reagent_containers/glass/bottle/cyanide
	name = "cyanide bottle"
	desc = "A small bottle of cyanide. Bitter almonds?"
	icon_state = "bottle12"
	list_reagents = list(/datum/reagent/toxin/cyanide = 60)

/obj/item/reagent_containers/glass/bottle/sleeptoxin
	name = "soporific bottle"
	desc = "A small bottle of soporific. Just the fumes make you sleepy."
	icon_state = "bottle20"
	list_reagents = list(/datum/reagent/toxin/sleeptoxin = 60)

/obj/item/reagent_containers/glass/bottle/chloralhydrate
	name = "chloral hydrate bottle"
	desc = "A small bottle of Choral Hydrate. Mickey's Favorite!"
	icon_state = "bottle20"
	list_reagents = list(/datum/reagent/toxin/chloralhydrate = 60)

/obj/item/reagent_containers/glass/bottle/dylovene
	name = "dylovene bottle"
	desc = "A small bottle of dylovene. Used to counter poisons. Basically an anti-toxin."
	icon_state = "bottle16"
	list_reagents = list(/datum/reagent/medicine/dylovene = 60)

/obj/item/reagent_containers/glass/bottle/mutagen
	name = "unstable mutagen bottle"
	desc = "A small bottle of unstable mutagen. Randomly changes the DNA structure of whoever comes in contact."
	icon_state = "bottle7"
	list_reagents = list(/datum/reagent/toxin/mutagen = 60)

/obj/item/reagent_containers/glass/bottle/ammonia
	name = "ammonia bottle"
	desc = "A small bottle of ammonia. A colourless gas with a pungent smell."
	icon_state = "bottle20"
	list_reagents = list(/datum/reagent/ammonia = 60)

/obj/item/reagent_containers/glass/bottle/diethylamine
	name = "diethylamine bottle"
	desc = "A small bottle of diethylamine. An organic compound obtained from ammonia and ethanol."
	icon_state = "bottle17"
	list_reagents = list(/datum/reagent/diethylamine = 60)


/obj/item/reagent_containers/glass/bottle/pacid
	name = "polytrinic acid bottle"
	desc = "A small bottle. Contains a small amount of Polytrinic Acid"
	icon_state = "bottle17"
	list_reagents = list(/datum/reagent/toxin/acid/polyacid = 60)

/obj/item/reagent_containers/glass/bottle/adminordrazine
	name = "\improper Adminordrazine bottle"
	desc = "A small bottle. Contains the liquid essence of the gods."
	icon = 'icons/obj/items/drinks.dmi'
	icon_state = "holyflask"
	list_reagents = list(/datum/reagent/medicine/adminordrazine = 60)

/obj/item/reagent_containers/glass/bottle/capsaicin
	name = "\improper Capsaicin bottle"
	desc = "A small bottle. Contains hot sauce."
	icon_state = "bottle3"
	list_reagents = list(/datum/reagent/consumable/capsaicin = 60)

/obj/item/reagent_containers/glass/bottle/frostoil
	name = "\improper Frost Oil bottle"
	desc = "A small bottle. Contains cold sauce."
	icon_state = "bottle17"
	list_reagents = list(/datum/reagent/consumable/frostoil = 60)

/obj/item/reagent_containers/glass/bottle/bicaridine
	name = "\improper Bicaridine bottle"
	desc = "A small bottle. Contains Bicaridine - Used to treat brute damage by doctors."
	icon_state = "bottle3"
	list_reagents = list(/datum/reagent/medicine/bicaridine = 60)

/obj/item/reagent_containers/glass/bottle/tramadol
	name = "\improper Tramadol bottle"
	desc = "A small bottle. Contains Tramadol - Used as a basic painkiller."
	icon_state = "bottle18"
	volume = 60
	list_reagents = list(/datum/reagent/medicine/tramadol = 60)

/obj/item/reagent_containers/glass/bottle/oxycodone
	name = "\improper Oxycodone bottle"
	desc = "A very small bottle. Contains Oxycodone - Used as an Extreme Painkiller."
	icon_state = "bottle2"
	volume = 60
	list_reagents = list(/datum/reagent/medicine/oxycodone = 60)

/obj/item/reagent_containers/glass/bottle/hypervene
	name = "\improper Hypervene bottle"
	desc = "A very small bottle. Contains Hypervene - A purge chem for flushing toxins. Causes pain and vomiting."
	icon_state = "bottle3"
	volume = 10
	list_reagents = list(/datum/reagent/hypervene = 10)

/obj/item/reagent_containers/glass/bottle/tricordrazine
	name = "\improper Tricordrazine bottle"
	desc = "A small bottle. Contains tricordrazine - used as a generic treatment for injuries."
	icon_state = "bottle-5"
	list_reagents = list(/datum/reagent/medicine/tricordrazine = 60)

/obj/item/reagent_containers/glass/bottle/paracetamol
	name = "\improper Paracetamol bottle"
	desc = "A small bottle. Contains paracetamol - a mild, simple painkiller, good for enduring heavy labor."
	icon_state = "bottle-1"
	list_reagents = list(/datum/reagent/medicine/paracetamol = 60)

/obj/item/reagent_containers/glass/bottle/isotonic
	name = "\improper Saline-Glucose bottle"
	desc = "A small bottle. Contains saline-glucose, also known as isotonic - used to aid the body in blood restoration."
	icon_state = "bottle-1"
	list_reagents = list(/datum/reagent/medicine/saline_glucose = 60)

/obj/item/reagent_containers/glass/bottle/meralyne
	name = "\improper Meralyne bottle"
	desc = "A small bottle. Contains meralyne - used as a potent treatment against brute damage."
	icon_state = "bottle14"
	list_reagents = list(/datum/reagent/medicine/meralyne = 60)

/obj/item/reagent_containers/glass/bottle/dermaline
	name = "\improper Dermaline bottle"
	desc = "A small bottle. Contains dermaline - used as a potent treatment against burns."
	icon_state = "bottle15"
	list_reagents = list(/datum/reagent/medicine/dermaline = 60)

/obj/item/reagent_containers/glass/bottle/meraderm
	name = "\improper Meraderm bottle"
	desc = "A small bottle. Contains meralylne and dermaline - used as a potent treatment against physical injuries."
	icon_state = "bottle19"
	list_reagents = list(/datum/reagent/medicine/dermaline = 30, /datum/reagent/medicine/meralyne = 30)

/obj/item/reagent_containers/glass/bottle/nanoblood
	name = "\improper Nanoblood bottle"
	desc = "A small bottle. Contains nanoblood - used as a treatment for large amounts of blood loss."
	icon_state = "bottle3"
	list_reagents = list(/datum/reagent/medicine/nanoblood = 60)

/obj/item/reagent_containers/glass/bottle/polyhexanide
	name = "\improper Polyhexanide bottle"
	desc = "A small bottle. Contains polyhexanide - Used as a powerful sterilizer for internal surgical use."
	icon_state = "bottle2"
	list_reagents = list(/datum/reagent/medicine/polyhexanide = 60)

/obj/item/reagent_containers/glass/bottle/lemoline
	name = "\improper Lemoline bottle"
	desc = "A small bottle. Contains 10 units of lemoline, a reagent used in the creation of advanced medicine."
	icon_state = "bottle-5"
	list_reagents = list(/datum/reagent/medicine/lemoline = 10)

/obj/item/reagent_containers/glass/bottle/lemoline/doctor
	desc = "A small bottle. Contains 30 units of lemoline, a reagent used in the creation of advanced medicine."
	list_reagents = list(/datum/reagent/medicine/lemoline = 30)

/obj/item/reagent_containers/glass/bottle/doctor_delight
	name = "\improper Doctor's Delight bottle"
	desc = "A small bottle. Contains Doctor's Delight."
	icon_state = "bottle3"
	list_reagents = list(/datum/reagent/consumable/drink/doctor_delight = 60)
