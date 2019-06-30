
//Not to be confused with /obj/item/reagent_container/food/drinks/bottle

/obj/item/reagent_container/glass/bottle
	name = "bottle"
	desc = "A small bottle."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = null
	item_state = "atoxinbottle"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,60)
	volume = 60
	attack_speed = 4

/obj/item/reagent_container/glass/bottle/on_reagent_change()
	update_icon()

/obj/item/reagent_container/glass/bottle/pickup(mob/user)
	..()
	update_icon()

/obj/item/reagent_container/glass/bottle/dropped(mob/user)
	..()
	update_icon()

/obj/item/reagent_container/glass/bottle/attack_hand()
	. = ..()
	if(.)
		return
	update_icon()

/obj/item/reagent_container/glass/bottle/New()
	..()
	if(!icon_state)
		icon_state = "bottle-[rand(1.4)]"

/obj/item/reagent_container/glass/bottle/update_icon()
	overlays.Cut()

	if(reagents.total_volume && (icon_state == "bottle-1" || icon_state == "bottle-2" || icon_state == "bottle-3" || icon_state == "bottle-4"))
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

/obj/item/reagent_container/glass/bottle/inaprovaline
	name = "\improper Inaprovaline bottle"
	desc = "A small bottle. Contains inaprovaline - used to stabilize patients."
	icon_state = "bottle19"
	list_reagents = list("inaprovaline" = 60)

/obj/item/reagent_container/glass/bottle/kelotane
	name = "\improper Kelotane bottle"
	desc = "A small bottle. Contains kelotane - used to treat burned areas."
	icon_state = "bottle16"
	list_reagents = list("kelotane" = 60)

/obj/item/reagent_container/glass/bottle/dexalin
	name = "\improper Dexaline bottle"
	desc = "A small bottle. Contains dexalin - used to supply blood with oxygen."
	icon_state = "bottle10"
	list_reagents = list("dexalin" = 60)

/obj/item/reagent_container/glass/bottle/spaceacillin
	name = "\improper Spaceacillin bottle"
	desc = "A small bottle. Contains spaceacillin - used to treat infected wounds."
	icon_state = "bottle8"
	list_reagents = list("spaceacillin" = 60)

/obj/item/reagent_container/glass/bottle/toxin
	name = "toxin bottle"
	desc = "A small bottle of toxins. Do not drink, it is poisonous."
	icon_state = "bottle12"
	list_reagents = list("toxin" = 60)

/obj/item/reagent_container/glass/bottle/cyanide
	name = "cyanide bottle"
	desc = "A small bottle of cyanide. Bitter almonds?"
	icon_state = "bottle12"
	list_reagents = list("cyanide" = 60)

/obj/item/reagent_container/glass/bottle/sleeptoxin
	name = "soporific bottle"
	desc = "A small bottle of soporific. Just the fumes make you sleepy."
	icon_state = "bottle20"
	list_reagents = list("sleeptoxin" = 60)

/obj/item/reagent_container/glass/bottle/chloralhydrate
	name = "chloral hydrate bottle"
	desc = "A small bottle of Choral Hydrate. Mickey's Favorite!"
	icon_state = "bottle20"
	list_reagents = list("chloralhydrate" = 60)

/obj/item/reagent_container/glass/bottle/dylovene
	name = "dylovene bottle"
	desc = "A small bottle of dylovene. Used to counter poisons. Basically an anti-toxin."
	icon_state = "bottle7"
	list_reagents = list("dylovene" = 60)

/obj/item/reagent_container/glass/bottle/mutagen
	name = "unstable mutagen bottle"
	desc = "A small bottle of unstable mutagen. Randomly changes the DNA structure of whoever comes in contact."
	icon_state = "bottle7"
	list_reagents = list("mutagen" = 60)

/obj/item/reagent_container/glass/bottle/ammonia
	name = "ammonia bottle"
	desc = "A small bottle of ammonia. A colourless gas with a pungent smell."
	icon_state = "bottle20"
	list_reagents = list("ammonia" = 60)

/obj/item/reagent_container/glass/bottle/diethylamine
	name = "diethylamine bottle"
	desc = "A small bottle of diethylamine. An organic compound obtained from ammonia and ethanol."
	icon_state = "bottle17"
	list_reagents = list("diethylamine" = 60)


/obj/item/reagent_container/glass/bottle/pacid
	name = "polytrinic acid bottle"
	desc = "A small bottle. Contains a small amount of Polytrinic Acid"
	icon_state = "bottle17"
	list_reagents = list("pacid" = 60)

/obj/item/reagent_container/glass/bottle/adminordrazine
	name = "\improper Adminordrazine bottle"
	desc = "A small bottle. Contains the liquid essence of the gods."
	icon_state = "holyflask"
	list_reagents = list("adminordrazine" = 60)

/obj/item/reagent_container/glass/bottle/capsaicin
	name = "\improper Capsaicin bottle"
	desc = "A small bottle. Contains hot sauce."
	icon_state = "bottle3"
	list_reagents = list("capsaicin" = 60)

/obj/item/reagent_container/glass/bottle/frostoil
	name = "\improper Frost Oil bottle"
	desc = "A small bottle. Contains cold sauce."
	icon_state = "bottle17"
	list_reagents = list("frostoil" = 60)

/obj/item/reagent_container/glass/bottle/bicaridine
	name = "\improper Bicaridine bottle"
	desc = "A small bottle. Contains Bicaridine - Used to treat brute damage by doctors."
	icon_state = "bottle17"
	list_reagents = list("bicaridine" = 60)

/obj/item/reagent_container/glass/bottle/peridaxon
	name = "\improper Peridaxon bottle"
	desc = "A small bottle. Contains Peridaxon - Used by lazy doctors to treat internal organ damage."
	icon_state = "bottle4"
	volume = 20
	list_reagents = list("peridaxon" = 20)

/obj/item/reagent_container/glass/bottle/tramadol
	name = "\improper Tramadol bottle"
	desc = "A small bottle. Contains Tramadol - Used as a basic painkiller."
	icon_state = "bottle1"
	volume = 20
	list_reagents = list("tramadol" = 20)

/obj/item/reagent_container/glass/bottle/oxycodone
	name = "\improper Oxycodone bottle"
	desc = "A very small bottle. Contains Oxycodone - Used as an Extreme Painkiller."
	icon_state = "bottle2"
	volume = 10
	list_reagents = list("oxycodone" = 10)

/obj/item/reagent_container/glass/bottle/hypervene
	name = "\improper Hypervene bottle"
	desc = "A very small bottle. Contains Hypervene - A purge chem for flushing toxins. Causes pain and vomiting."
	icon_state = "bottle3"
	volume = 10
	list_reagents = list("hypervene" = 10)

/obj/item/reagent_container/glass/bottle/tricordrazine
	name = "\improper Tricordrazine bottle"
	desc = "A small bottle. Contains tricordrazine - used as a generic treatment for injuries."
	icon_state = "bottle18"
	list_reagents = list("tricordrazine" = 60)

/obj/item/reagent_container/glass/bottle/dermaline
	name = "\improper Dermaline bottle"
	desc = "A small bottle. Contains dermaline - used as a potent treatment against burns."
	icon_state = "bottle14"
	list_reagents = list("dermaline" = 15)