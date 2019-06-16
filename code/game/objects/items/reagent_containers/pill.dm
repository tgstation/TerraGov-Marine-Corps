////////////////////////////////////////////////////////////////////////////////
/// Pills.
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_container/pill
	name = "pill"
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = null
	item_state = "pill"
	possible_transfer_amounts = null
	init_reagent_flags = AMOUNT_SKILLCHECK
	w_class = 1
	volume = 60
	var/pill_desc = "An unknown pill." //the real description of the pill, shown when examined by a medically trained person
	var/pill_id

/obj/item/reagent_container/pill/Initialize()
	. = ..()
	if(!icon_state)
		icon_state = pill_id ? GLOB.randomized_pill_icons[pill_id] : pick(GLOB.randomized_pill_icons)

/obj/item/reagent_container/pill/attack_self(mob/user as mob)
	return

/obj/item/reagent_container/pill/attack(mob/M, mob/user, def_zone)

	if(M == user)

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species.species_flags & IS_SYNTHETIC)
				to_chat(H, "<span class='warning'>You can't eat pills.</span>")
				return

		to_chat(M, "<span class='notice'>You swallow [src].</span>")
		M.dropItemToGround(src) //icon update
		if(reagents.total_volume)
			reagents.trans_to(M, reagents.total_volume)

		qdel(src)
		return TRUE

	else if(ishuman(M) )

		var/mob/living/carbon/human/H = M
		if(H.species.species_flags & IS_SYNTHETIC)
			to_chat(user, "<span class='warning'>They have a monitor for a head, where do you think you're going to put that?</span>")
			return

		user.visible_message("<span class='warning'>[user] attempts to force [M] to swallow [src].</span>")

		var/ingestion_time = 30
		if(user.mind && user.mind.cm_skills)
			ingestion_time = max(10, 30 - 10*user.mind.cm_skills.medical)

		if(!do_mob(user, M, ingestion_time, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
			return

		user.dropItemToGround(src) //icon update
		for(var/mob/O in viewers(world.view, user))
			O.show_message("<span class='warning'>[user] forces [M] to swallow [src].", 1)

		var/rgt_list_text = get_reagent_list_text()

		log_combat(user, M, "fed", src, "Reagents: [rgt_list_text]")
		msg_admin_attack("[ADMIN_TPMONTY(usr)] fed [ADMIN_TPMONTY(M)] with [src.name] Reagents: [rgt_list_text].")

		if(reagents.total_volume)
			reagents.reaction(M, INGEST)
			reagents.trans_to(M, reagents.total_volume)
			qdel(src)
		else
			qdel(src)

			return TRUE

		return FALSE

/obj/item/reagent_container/pill/afterattack(obj/target, mob/user, proximity)
	if(!proximity)
		return

	if(target.is_refillable())
		if(target.reagents.holder_full())
			to_chat(user, "<span class='warning'>[target] is full.</span>")
			return

		var/obj/item/reagent_container/R = null
		var/liquidate = null
		if(istype(target,/obj/item/reagent_container))
			R = target
			if(R.liquifier)
				liquidate = TRUE

		if(target.is_drainable() && !target.reagents.total_volume)
			if(!R || !liquidate)
				to_chat(user, "<span class='warning'>[target] is empty! There's nothing to dissolve [src] in.</span>")
				return
			to_chat(user, "<span class='notice'>[target]'s liquifier instantly reprocesses [src] upon insertion.</span>")

		if(!R || !liquidate)
			to_chat(user, "<span class='notice'>You dissolve the pill in [target].</span>")

		var/rgt_list_text = get_reagent_list_text()

		log_combat(user, target, "spiked", src, "Reagents: [rgt_list_text]")
		msg_admin_attack("[ADMIN_TPMONTY(usr)] spiked \a [target] with a pill. Reagents: [rgt_list_text].")

		reagents.trans_to(target, reagents.total_volume)
		for(var/mob/O in viewers(2, user))
			O.show_message("<span class='warning'>[user] puts something in \the [target].", 1)

		spawn(5)
			qdel(src)

	return

////////////////////////////////////////////////////////////////////////////////
/// Pills. END
////////////////////////////////////////////////////////////////////////////////

//Pills
/obj/item/reagent_container/pill/dylovene
	pill_desc = "A dylovene pill. It neutralizes many common toxins."
	list_reagents = list("dylovene" = 15)
	pill_id = 1

/obj/item/reagent_container/pill/tox
	pill_desc = "A toxins pill. It's highly toxic."
	list_reagents = list("toxin" = 50)
	pill_id = 2

/obj/item/reagent_container/pill/cyanide
	desc = "A cyanide pill. Don't swallow this!"
	pill_desc = null//so even non medics can see what this pill is.
	list_reagents = list("cyanide" = 50)
	pill_id = 2

/obj/item/reagent_container/pill/adminordrazine
	pill_desc = "An adminordrazine pill. It's magic. We don't have to explain it."
	list_reagents = list("adminordrazine" = 50)
	pill_id = 3

/obj/item/reagent_container/pill/sleeptoxin
	pill_desc = "A sleeping pill commonly used to treat insomnia."
	list_reagents = list("sleeptoxin" = 15)
	pill_id = 4

/obj/item/reagent_container/pill/kelotane
	pill_desc = "A kelotane pill. Used to treat burns."
	list_reagents = list("kelotane" = 15)
	pill_id = 5

/obj/item/reagent_container/pill/paracetamol
	pill_desc = "A paracetamol pill. Painkiller for the ages."
	list_reagents = list("paracetamol" = 15)
	pill_id = 6

/obj/item/reagent_container/pill/tramadol
	pill_desc = "A tramadol pill. A simple painkiller."
	list_reagents = list("tramadol" = 15)
	pill_id = 7

/obj/item/reagent_container/pill/methylphenidate
	pill_desc = "A methylphenidate pill. This improves the ability to concentrate."
	list_reagents = list("methylphenidate" = 15)
	pill_id = 8

/obj/item/reagent_container/pill/citalopram
	pill_desc = "A citalopram pill. A mild anti-depressant."
	list_reagents = list("citalopram" = 15)
	pill_id = 9

/obj/item/reagent_container/pill/inaprovaline
	pill_desc = "An inaprovaline pill. Used to stabilize patients."
	list_reagents = list("inaprovaline" = 30)
	pill_id = 10

/obj/item/reagent_container/pill/dexalin
	pill_desc = "A dexalin pill. Used to treat oxygen deprivation."
	list_reagents = list("dexalin" = 15)
	pill_id = 11

/obj/item/reagent_container/pill/spaceacillin
	pill_desc = "A spaceacillin pill. Used to treat infected wounds and slow down viral infections."
	list_reagents = list("spaceacillin" = 10)
	pill_id = 12

/obj/item/reagent_container/pill/happy
	pill_desc = "A Happy Pill! Happy happy joy joy!"
	list_reagents = list("space_drugs" = 15, "sugar" = 15, "laughter" = 5)
	pill_id = 13

/obj/item/reagent_container/pill/zoom
	pill_desc = "A Zoom pill! Gotta go fast!"
	list_reagents = list("synaptizine" = 5, "hyperzine" = 5, "nutriment" = 2)
	pill_id = 14

/obj/item/reagent_container/pill/russianRed
	pill_desc = "A Russian Red pill. A very dangerous radiation-countering substance."
	list_reagents = list("russianred" = 10)
	pill_id = 15

/obj/item/reagent_container/pill/peridaxon
	pill_desc = "A peridaxon pill. Heals internal organ damage."
	list_reagents = list("peridaxon" = 10)
	pill_id = 16

/obj/item/reagent_container/pill/imidazoline
	pill_desc = "An imidazoline pill. Heals eye damage."
	list_reagents = list("imidazoline" = 10)
	pill_id = 17

/obj/item/reagent_container/pill/alkysine
	pill_desc = "An Alkysine pill. Heals brain damage."
	list_reagents = list("alkysine" = 10)
	pill_id = 18

/obj/item/reagent_container/pill/bicaridine
	pill_desc = "A bicaridine pill. Heals brute damage."
	list_reagents = list("bicaridine" = 15)
	pill_id = 19

/obj/item/reagent_container/pill/quickclot
	pill_desc = "A quick-clot pill. Stabilizes internal bleeding temporarily."
	list_reagents = list("quickclot" = 10)
	pill_id = 20

/obj/item/reagent_container/pill/tricordrazine
	pill_desc = "A tricordrazine pill. Broad spectrum medication that slowly heals all damage types."
	list_reagents = list("tricordrazine" = 15)
	pill_id = 9

/obj/item/reagent_container/pill/hypervene
	pill_desc = "A hypervene pill. A purge medication used to treat overdoses and rapidly remove toxins. Causes pain and vomiting."
	list_reagents = list("hypervene" = 3)
	pill_id = 14

/obj/item/reagent_container/pill/ultrazine
	//pill_desc = "An ultrazine pill. A highly-potent, long-lasting combination CNS and muscle stimulant. Extremely addictive."
	list_reagents = list("ultrazine" = 5)
	pill_id = 21
