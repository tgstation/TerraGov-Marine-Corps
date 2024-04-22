////////////////////////////////////////////////////////////////////////////////
/// Pills.
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_containers/pill
	name = "pill"
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "pill1"
	item_state = "pill"
	possible_transfer_amounts = null
	amount_per_transfer_from_this = 15
	init_reagent_flags = AMOUNT_SKILLCHECK
	w_class = WEIGHT_CLASS_TINY
	volume = 60
	attack_speed = 1 //War against input locking while pill munching
	var/pill_desc = "An unknown pill." //the real description of the pill, shown when examined by a medically trained person
	var/pill_id

/obj/item/reagent_containers/pill/Initialize(mapload)
	. = ..()
	if(icon_state == "pill1")
		icon_state = pill_id ? GLOB.randomized_pill_icons[pill_id] : pick(GLOB.randomized_pill_icons)

/obj/item/reagent_containers/pill/attack_self(mob/user)
	. = ..()
	attack(user, user)

/obj/item/reagent_containers/pill/attack(mob/M, mob/user, def_zone)
	if(M == user)

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species.species_flags & ROBOTIC_LIMBS)
				to_chat(H, span_warning("You can't eat pills."))
				return

		to_chat(M, span_notice("You swallow [src]."))
		M.dropItemToGround(src) //icon update
		if(reagents.total_volume)
			record_reagent_consumption(reagents.total_volume, reagents.reagent_list, user)
			reagents.reaction(M, INGEST)
			reagents.trans_to(M, reagents.total_volume)

		qdel(src)
		return TRUE

	else if(ishuman(M) )

		var/mob/living/carbon/human/H = M
		if(H.species.species_flags & ROBOTIC_LIMBS)
			to_chat(user, span_warning("They have a monitor for a head, where do you think you're going to put that?"))
			return

		user.visible_message(span_warning("[user] attempts to force [M] to swallow [src]."))

		var/ingestion_time = max(1 SECONDS, 3 SECONDS - 1 SECONDS * user.skills.getRating(SKILL_MEDICAL))

		if(!do_after(user, ingestion_time, NONE, M, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
			return

		user.dropItemToGround(src) //icon update
		visible_message("<span class='warning'>[user] forces [M] to swallow [src].")

		var/rgt_list_text = get_reagent_list_text()

		log_combat(user, M, "fed", src, "Reagents: [rgt_list_text]")

		if(reagents.total_volume)
			record_reagent_consumption(reagents.total_volume, reagents.reagent_list, user, M)
			reagents.reaction(M, INGEST)
			reagents.trans_to(M, reagents.total_volume)
			qdel(src)
		else
			qdel(src)

			return TRUE

		return FALSE

/obj/item/reagent_containers/pill/afterattack(obj/target, mob/user, proximity)
	if(!proximity)
		return

	if(target.is_refillable())
		if(target.reagents.holder_full())
			to_chat(user, span_warning("[target] is full."))
			return

		var/obj/item/reagent_containers/R = null
		var/liquidate = null
		if(istype(target,/obj/item/reagent_containers))
			R = target
			if(R.liquifier)
				liquidate = TRUE

		if(target.is_drainable() && !target.reagents.total_volume)
			if(!R || !liquidate)
				to_chat(user, span_warning("[target] is empty! There's nothing to dissolve [src] in."))
				return
			to_chat(user, span_notice("[target]'s liquifier instantly reprocesses [src] upon insertion."))

		if(!R || !liquidate)
			to_chat(user, span_notice("You dissolve the pill in [target]."))

		var/rgt_list_text = get_reagent_list_text()

		log_combat(user, target, "spiked", src, "Reagents: [rgt_list_text]")

		reagents.trans_to(target, reagents.total_volume)
		visible_message("<span class='warning'>[user] puts something in \the [target].", null, null, 2)

		QDEL_IN(src, 5)

////////////////////////////////////////////////////////////////////////////////
/// Pills. END
////////////////////////////////////////////////////////////////////////////////

//Pills
/obj/item/reagent_containers/pill/dylovene
	pill_desc = "A dylovene pill. It neutralizes many common toxins."
	list_reagents = list(/datum/reagent/medicine/dylovene = 15)
	pill_id = 1

/obj/item/reagent_containers/pill/tox
	pill_desc = "A toxins pill. It's highly toxic."
	list_reagents = list(/datum/reagent/toxin = 50)
	pill_id = 2

/obj/item/reagent_containers/pill/cyanide
	desc = "A cyanide pill. Don't swallow this!"
	pill_desc = null//so even non medics can see what this pill is.
	list_reagents = list(/datum/reagent/toxin/cyanide = 50)
	pill_id = 2

/obj/item/reagent_containers/pill/adminordrazine
	pill_desc = "An adminordrazine pill. It's magic. We don't have to explain it."
	list_reagents = list(/datum/reagent/medicine/adminordrazine = 50)
	pill_id = 3

/obj/item/reagent_containers/pill/sleeptoxin
	pill_desc = "A sleeping pill commonly used to treat insomnia."
	list_reagents = list(/datum/reagent/toxin/sleeptoxin = 15)
	pill_id = 4

/obj/item/reagent_containers/pill/kelotane
	pill_desc = "A kelotane pill. Used to treat burns."
	list_reagents = list(/datum/reagent/medicine/kelotane = 15)
	pill_id = 5

/obj/item/reagent_containers/pill/dermaline
	pill_desc = "A dermaline pill. Heals burn damage at a higher rate than kelotane."
	list_reagents = list(/datum/reagent/medicine/dermaline = 7.5)
	pill_id = 5

/obj/item/reagent_containers/pill/paracetamol
	pill_desc = "A paracetamol pill. Painkiller for the ages."
	list_reagents = list(/datum/reagent/medicine/paracetamol = 15)
	pill_id = 6

/obj/item/reagent_containers/pill/tramadol
	pill_desc = "A tramadol pill. A simple painkiller."
	list_reagents = list(/datum/reagent/medicine/tramadol = 15)
	pill_id = 7

/obj/item/reagent_containers/pill/isotonic
	pill_desc = "A pill with an isotonic solution inside. Used to stimulate blood regeneration."
	list_reagents = list(/datum/reagent/medicine/saline_glucose = 15)
	pill_id = 4

/obj/item/reagent_containers/pill/inaprovaline
	pill_desc = "An inaprovaline pill. Used to stabilize patients."
	list_reagents = list(/datum/reagent/medicine/inaprovaline = 15)
	pill_id = 10

/obj/item/reagent_containers/pill/dexalin
	pill_desc = "A dexalin pill. Used to treat oxygen deprivation."
	list_reagents = list(/datum/reagent/medicine/dexalin = 15)
	pill_id = 11

/obj/item/reagent_containers/pill/spaceacillin
	pill_desc = "A spaceacillin pill. Used to treat infected wounds and slow down viral infections."
	list_reagents = list(/datum/reagent/medicine/spaceacillin = 10)
	pill_id = 12

/obj/item/reagent_containers/pill/happy
	pill_desc = "A Happy Pill! Happy happy joy joy!"
	list_reagents = list(/datum/reagent/space_drugs = 15, /datum/reagent/consumable/sugar = 15, /datum/reagent/consumable/laughter = 5)
	pill_id = 13

/obj/item/reagent_containers/pill/zoom
	pill_desc = "A Zoom pill! Gotta go fast!"
	list_reagents = list(/datum/reagent/medicine/synaptizine = 3, /datum/reagent/medicine/hyronalin = 5, /datum/reagent/consumable/nutriment = 3)
	pill_id = 14

/obj/item/reagent_containers/pill/russian_red
	pill_desc = "A Russian Red pill. A last-resort revival drug."
	list_reagents = list(/datum/reagent/medicine/russian_red = 10)
	pill_id = 15

/obj/item/reagent_containers/pill/ryetalyn
	pill_desc = "A Ryetalyn pill. A long-duration shield against toxic chemicals."
	list_reagents = list(/datum/reagent/medicine/ryetalyn = 15)
	pill_id = 14

/obj/item/reagent_containers/pill/imidazoline
	pill_desc = "An imidazoline pill. Heals eye damage."
	list_reagents = list(/datum/reagent/medicine/imidazoline = 10)
	pill_id = 17

/obj/item/reagent_containers/pill/alkysine
	pill_desc = "An Alkysine pill. Heals brain and ear damage."
	list_reagents = list(/datum/reagent/medicine/alkysine = 10)
	pill_id = 18

/obj/item/reagent_containers/pill/bicaridine
	pill_desc = "A bicaridine pill. Heals brute damage."
	list_reagents = list(/datum/reagent/medicine/bicaridine = 15)
	pill_id = 19

/obj/item/reagent_containers/pill/meralyne
	pill_desc = "A meralyne pill. Heals brute damage at a higher rate than bicaridine."
	list_reagents = list(/datum/reagent/medicine/meralyne = 7.5)
	pill_id = 19

/obj/item/reagent_containers/pill/quickclot
	pill_desc = "A quick-clot pill. Stabilizes internal bleeding temporarily."
	list_reagents = list(/datum/reagent/medicine/quickclot = 10)
	pill_id = 20

/obj/item/reagent_containers/pill/tricordrazine
	pill_desc = "A tricordrazine pill. Broad spectrum medication that slowly heals all damage types."
	list_reagents = list(/datum/reagent/medicine/tricordrazine = 15)
	pill_id = 9

/obj/item/reagent_containers/pill/leporazine
	pill_desc = "A leporazine pill. Helps handle extreme body temperatures rapidly."
	list_reagents = list(/datum/reagent/medicine/leporazine = 10)
	pill_id = 21

/obj/item/reagent_containers/pill/hypervene
	pill_desc = "A hypervene pill. A purge medication used to treat overdoses and rapidly remove toxins. Causes pain and vomiting."
	list_reagents = list(/datum/reagent/hypervene = 3)
	pill_id = 14

/obj/item/reagent_containers/pill/ultrazine
	//pill_desc = "An ultrazine pill. A highly-potent, long-lasting combination CNS and muscle stimulant. Extremely addictive."
	list_reagents = list(/datum/reagent/medicine/ultrazine = 5)
	pill_id = 21
