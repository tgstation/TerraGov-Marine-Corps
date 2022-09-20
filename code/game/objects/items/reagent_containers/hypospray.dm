////////////////////////////////////////////////////////////////////////////////
/// HYPOSPRAY
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_containers/hypospray
	name = "Hypospray"
	desc = "The hypospray is a sterile, air-needle reusable autoinjector for rapid administration of drugs to patients with customizable dosages."
	icon = 'icons/obj/items/syringe.dmi'
	item_state = "hypo"
	icon_state = "hypo_base"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = null
	volume = 60
	init_reagent_flags = OPENCONTAINER
	flags_equip_slot = ITEM_SLOT_BELT
	flags_item = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	var/skilllock = 1
	var/inject_mode = HYPOSPRAY_INJECT_MODE_INJECT
	var/core_name = "hypospray"
	var/label = null
	/// Small description appearing as an overlay
	var/description_overlay = ""

/obj/item/reagent_containers/hypospray/advanced
	name = "Advanced hypospray"
	desc = "The hypospray is a sterile, air-needle reusable autoinjector for rapid administration of drugs to patients with customizable dosages. Comes complete with an internal reagent analyzer and digital labeler. Handy."
	core_name = "hypospray"


/obj/item/reagent_containers/hypospray/proc/empty(mob/user)
	if(tgui_alert(user, "Are you sure you want to empty [src]?", "Flush [src]:", list("Yes", "No")) != "Yes")
		return
	if(isturf(user.loc))
		to_chat(user, span_notice("You flush the contents of [src]."))
		reagents.reaction(user.loc)
		reagents.clear_reagents()

/obj/item/reagent_containers/hypospray/proc/label(mob/user)
	var/str = copytext(reject_bad_text(input(user,"Hypospray label text?", "Set label", "")), 1, MAX_NAME_LEN)
	if(!length(str))
		to_chat(user, span_notice("Invalid text."))
		return
	to_chat(user, span_notice("You label [src] as \"[str]\"."))
	name = "[core_name] ([str])"
	label = str


/obj/item/reagent_containers/hypospray/afterattack(atom/A, mob/living/user)
	if(istype(A, /obj/item/storage/pill_bottle)) //this should only run if its a pillbottle
		if(reagents.total_volume >= volume)
			to_chat(user, span_warning("[src] is full."))
			return  //early returning if its full

		if(!A.contents.len)
			return //early returning if its empty
		var/obj/item/pill = A.contents[1]

		if((pill.reagents.total_volume + reagents.total_volume) > volume)
			to_chat(user, span_warning("[src] cannot hold that much more."))
			return // so it doesnt let people have hypos more filled than their volume
		pill.reagents.trans_to(src, pill.reagents.total_volume)

		to_chat(user, span_notice("You dissolve pill inside [A] in [src]."))
		A.contents -= pill
		qdel(pill)
		return

	if(!A.reagents)
		return
	if(!istype(user))
		return
	if(!in_range(A, user) || !user.Adjacent(A))
		return
	if(inject_mode == HYPOSPRAY_INJECT_MODE_DRAW) //if we're draining
		if(reagents.holder_full())
			to_chat(user, span_warning("[src] is full."))
			inject_mode = HYPOSPRAY_INJECT_MODE_INJECT
			update_icon() //So we now display as Inject
			return

		if(iscarbon(A))
			var/amount = min(reagents.maximum_volume - reagents.total_volume, amount_per_transfer_from_this)
			var/mob/living/carbon/C = A
			if(C.get_blood_id() && reagents.has_reagent(C.get_blood_id()))
				to_chat(user, span_warning("There is already a blood sample in [src]."))
				return
			if(!C.blood_type)
				to_chat(user, span_warning("You are unable to locate any blood."))
				return

			if(ishuman(C))
				var/mob/living/carbon/human/H = C
				if(H.species.species_flags & NO_BLOOD)
					to_chat(user, span_warning("You are unable to locate any blood."))
					return
				else
					C.take_blood(src,amount)
			else
				C.take_blood(src,amount)

			reagents.handle_reactions()
			user.visible_message("<span clas='warning'>[user] takes a blood sample from [A].</span>",
								span_notice("You take a blood sample from [A]."), null, 4)

		else if(istype(A, /obj)) //if not mob
			if(!A.reagents.total_volume)
				to_chat(user, "<span class='warning'>[A] is empty.")
				return

			if(!A.is_drawable())
				to_chat(user, span_warning("You cannot directly remove reagents from this object."))
				return

			var/trans = A.reagents.trans_to(src, amount_per_transfer_from_this)

			to_chat(user, span_notice("You fill [src] with [trans] units of the solution."))

		on_reagent_change()
		return TRUE


	if(!reagents.total_volume)
		to_chat(user, span_warning("[src] is empty."))
		return
	if(!A.is_injectable() && !ismob(A))
		to_chat(user, span_warning("You cannot directly fill this object."))
		return
	if(skilllock && user.skills.getRating("medical") < SKILL_MEDICAL_NOVICE)
		user.visible_message(span_notice("[user] fumbles around figuring out how to use the [src]."),
		span_notice("You fumble around figuring out how to use the [src]."))
		if(!do_after(user, SKILL_TASK_EASY, TRUE, A, BUSY_ICON_UNSKILLED) || (!in_range(A, user) || !user.Adjacent(A)))
			return

	if(ismob(A))
		var/mob/M = A
		if(!M.can_inject(user, TRUE, user.zone_selected, TRUE))
			return
		if(M != user && M.stat != DEAD && M.a_intent != INTENT_HELP && !M.incapacitated() && M.skills.getRating("cqc") >= SKILL_CQC_MP)
			user.Paralyze(60)
			log_combat(M, user, "blocked", addition="using their cqc skill (hypospray injection)")
			M.visible_message(span_danger("[M]'s reflexes kick in and knock [user] to the ground before they could use \the [src]'!"), \
				span_warning("You knock [user] to the ground before they could inject you!"), null, 5)
			playsound(user.loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
			return FALSE

	var/list/injected = list()
	for(var/datum/reagent/R in reagents.reagent_list)
		injected += R.name
	log_combat(user, A, "injected", src, "Reagents: [english_list(injected)]")

	if(ismob(A))
		var/mob/M = A
		to_chat(user, "[span_notice("You inject [M] with [src]")].")
		to_chat(M, span_warning("You feel a tiny prick!"))

	// /mob/living/carbon/human/attack_hand causes
	// changeNext_move(7) which creates a delay
	// This line overrides the delay, and will absolutely break everything
	user.changeNext_move(3) // please don't break the game

	playsound(loc, 'sound/items/hypospray.ogg', 50, 1)
	reagents.reaction(A, INJECT, min(amount_per_transfer_from_this, reagents.total_volume) / reagents.total_volume)
	var/trans = reagents.trans_to(A, amount_per_transfer_from_this)
	to_chat(user, span_notice("[trans] units injected. [reagents.total_volume] units remaining in [src]. "))

	return TRUE

/obj/item/reagent_containers/hypospray/on_reagent_change()
	if(reagents.holder_full())
		inject_mode = HYPOSPRAY_INJECT_MODE_INJECT
	update_icon()

/obj/item/reagent_containers/hypospray/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	update_icon()

/obj/item/reagent_containers/hypospray/pickup(mob/user)
	. = ..()
	update_icon()

/obj/item/reagent_containers/hypospray/dropped(mob/user)
	. = ..()
	update_icon()

/obj/item/reagent_containers/hypospray/update_icon_state()
	if(!ismob(loc))
		icon_state = "hypo"
		return
	if(inject_mode)
		icon_state = "hypo_i"
		return
	icon_state = "hypo_d"


/obj/item/reagent_containers/hypospray/update_overlays()
	. = ..()
	if(isturf(loc) || !description_overlay)
		return
	var/mutable_appearance/desc = mutable_appearance()
	desc.pixel_x += 16
	desc.maptext = MAPTEXT(description_overlay)
	. += desc

/obj/item/reagent_containers/hypospray/advanced
	icon_state = "hypo"
	init_reagent_flags = REFILLABLE|DRAINABLE
	liquifier = TRUE


/obj/item/reagent_containers/hypospray/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat = {"
	<B><A href='?src=\ref[src];autolabeler=1'>Activate Autolabeler</A></B><BR>
	<B>Current Label:</B> [label]<BR>
	<BR>
	<B><A href='byond://?src=\ref[src];inject_mode=1'>Toggle Mode (Toggles between injecting and draining):</B><BR>
	<B>Current Mode:</B> [inject_mode ? "Inject" : "Draw"]</A><BR>
	<BR>
	<B><A href='byond://?src=\ref[src];set_transfer=1'>Set Transfer Amount (Change amount drained/injected per use):</A></B><BR>
	<B>Current Transfer Amount [amount_per_transfer_from_this]</B><BR>
	<BR>
	<B><A href='byond://?src=\ref[src];flush=1'>Flush Hypospray (Empties the hypospray of all contents):</A></B><BR>
	<BR>"}

	var/datum/browser/popup = new(user, "hypospray")
	popup.set_content(dat)
	popup.open()


/obj/item/reagent_containers/hypospray/advanced/interact(mob/user)
	. = ..()
	if(.)
		return
	var/dat = {"
	<B><A href='?src=\ref[src];autolabeler=1'>Activate Autolabeler</A></B><BR>
	<B>Current Label:</B> [label]<BR>
	<BR>
	<B><A href='byond://?src=\ref[src];inject_mode=1'>Toggle Mode:</A></B><BR>
	<B>Current Mode:</B> [inject_mode ? "Inject" : "Draw"]<BR>
	<BR>
	<B><A href='byond://?src=\ref[src];set_transfer=1'>Set Transfer Amount:</A></B><BR>
	<B>Current Transfer Amount:</B> [amount_per_transfer_from_this]<BR>
	<BR>
	<B><A href='byond://?src=\ref[src];displayreagents=1'>Display Reagent Content:</A></B><BR>
	<BR>
	<BR>
	<B><A href='byond://?src=\ref[src];flush=1'>Flush Hypospray (Empties the hypospray of all contents):</A></B><BR>
	<BR>"}

	var/datum/browser/popup = new(user, "hypospray")
	popup.set_content(dat)
	popup.open()


/obj/item/reagent_containers/hypospray/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["inject_mode"])
		if(inject_mode)
			to_chat(usr, span_notice("[src] has been set to draw mode. It will now drain reagents."))
		else
			to_chat(usr, span_notice("[src] has been set to inject mode. It will now inject reagents."))
		inject_mode = !inject_mode
		update_icon()

	else if(href_list["autolabeler"])
		label(usr)

	else if(href_list["set_transfer"])
		var/N = tgui_input_list(usr, "Amount per transfer from this:", "[src]", list(30, 20, 15, 10, 5, 3, 1))
		if(!N)
			return

		amount_per_transfer_from_this = N

	else if(href_list["flush"])
		empty(usr)

	updateUsrDialog()


/obj/item/reagent_containers/hypospray/advanced/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["displayreagents"])
		to_chat(usr, display_reagents())


/obj/item/reagent_containers/hypospray/advanced/update_overlays()
	. = ..()

	overlays.Cut()
	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)
				filling.icon_state = "[initial(icon_state)]-10"
			if(10 to 24)
				filling.icon_state = "[initial(icon_state)]10"
			if(25 to 49)
				filling.icon_state = "[initial(icon_state)]25"
			if(50 to 74)
				filling.icon_state = "[initial(icon_state)]50"
			if(75 to 79)
				filling.icon_state = "[initial(icon_state)]75"
			if(80 to 90)
				filling.icon_state = "[initial(icon_state)]80"
			if(91 to INFINITY)
				filling.icon_state = "[initial(icon_state)]100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

/obj/item/reagent_containers/hypospray/advanced/examine(mob/user as mob)
	. = ..()
	if(get_dist(user,src) > 2)
		. += span_warning("You're too far away to see [src]'s reagent display!")
		return

	. += display_reagents(user)

/// The proc display_reagents controls the information utilised in the hypospray menu/. Specifically how much of a chem there is, what percent that entails, and what type of chem it is if that is a known chem.
/obj/item/reagent_containers/hypospray/advanced/proc/display_reagents(mob/user)
	if(isnull(reagents))
		return
	var/list/dat = list()
	dat += "\n \t [span_notice("<b>Total Reagents:</b> [reagents.total_volume]/[volume]. <b>Dosage Size:</b> [min(reagents.total_volume, amount_per_transfer_from_this)]")]</br>"
	if(reagents.reagent_list.len > 0)
		for (var/datum/reagent/R in reagents.reagent_list)
			var/percent = round(R.volume / max(0.01 , reagents.total_volume * 0.01),0.01)
			var/dose = round(min(reagents.total_volume, amount_per_transfer_from_this) * percent * 0.01,0.01)
			if(R.scannable)
				dat += "\n \t <b>[R]:</b> [R.volume]|[percent]% <b>Amount per dose:</b> [dose]</br>"
			else
				dat += "\n \t <b>Unknown:</b> [R.volume]|[percent]% <b>Amount per dose:</b> [dose]</br>"
	return span_notice("[src]'s reagent display shows the following contents: [dat.Join(" ")]")


/obj/item/reagent_containers/hypospray/advanced/bicaridine
	name = "Bicaridine hypospray"
	desc = "A hypospray loaded with bicaridine. A chemical that heal cuts and bruises."
	list_reagents = list(
		/datum/reagent/medicine/bicaridine = 60,
	)
	description_overlay = "Bi"

/obj/item/reagent_containers/hypospray/advanced/kelotane
	name = "Kelotane hypospray"
	desc = "A hypospray loaded with kelotane. A chemical that heal burns."
	list_reagents = list(
		/datum/reagent/medicine/kelotane = 60,
	)
	description_overlay = "Ke"

/obj/item/reagent_containers/hypospray/advanced/tramadol
	name = "Tramadol hypospray"
	desc = "A hypospray loaded with tramadol. A chemical that numbs pain."
	list_reagents = list(
		/datum/reagent/medicine/tramadol = 60,
	)
	description_overlay = "Ta"

/obj/item/reagent_containers/hypospray/advanced/tricordrazine
	name = "Tricordrazine hypospray"
	desc = "A hypospray loaded with tricordrazine. A chemical that heal cuts, bruises, burns, toxicity, and oxygen deprivation."
	list_reagents = list(
		/datum/reagent/medicine/tricordrazine = 60,
	)
	description_overlay = "Ti"

/obj/item/reagent_containers/hypospray/advanced/dylovene
	name = "Dylovene hypospray"
	desc = "A hypospray loaded with dylovene. A chemical that heal toxicity whilst purging toxins, hindering stamina in the process."
	list_reagents = list(
		/datum/reagent/medicine/dylovene = 60,
	)
	description_overlay = "Dy"

/obj/item/reagent_containers/hypospray/advanced/inaprovaline
	name = "Inaprovaline hypospray"
	desc = "A hypospray loaded with inaprovaline."
	list_reagents = list(
		/datum/reagent/medicine/inaprovaline = 60,
	)
	description_overlay = "In"

/obj/item/reagent_containers/hypospray/advanced/meralyne
	name = "Meralyne hypospray"
	desc = "A hypospray loaded with meralyne. An advanced chemical that heal cuts and bruises rapidly."
	amount_per_transfer_from_this = 5
	list_reagents = list(
		/datum/reagent/medicine/meralyne = 60,
	)
	description_overlay = "Mr"

/obj/item/reagent_containers/hypospray/advanced/dermaline
	name = "Dermaline hypospray"
	desc = "A hypospray loaded with dermaline. An advanced chemical that heal burns rapdily."
	amount_per_transfer_from_this = 5
	list_reagents = list(
		/datum/reagent/medicine/dermaline = 60,
	)
	description_overlay = "Dr"

/obj/item/reagent_containers/hypospray/advanced/combat_advanced
	name = "Advanced combat hypospray"
	desc = "A hypospray loaded with several doses of advanced healing and painkilling chemicals. Intended for use in active combat."
	list_reagents = list(
		/datum/reagent/medicine/meralyne = 20,
		/datum/reagent/medicine/dermaline = 20,
		/datum/reagent/medicine/tramadol = 20,
	)
	description_overlay = "Av"

/obj/item/reagent_containers/hypospray/advanced/meraderm
	name = "Meraderm hypospray"
	desc = "A hypospray loaded with meralyne and dermaline."
	list_reagents = list(
		/datum/reagent/medicine/meralyne = 30,
		/datum/reagent/medicine/dermaline = 30,
	)
	description_overlay = "MD"

/obj/item/reagent_containers/hypospray/advanced/oxycodone
	name = "oxycodone hypospray"
	desc = "A hypospray loaded with oxycodone. An advanced but highly addictive chemical which almost entirely negates pain and shock."
	list_reagents = list(/datum/reagent/medicine/oxycodone = 60)
	description_overlay = "Ox"

/obj/item/reagent_containers/hypospray/advanced/hypervene
	name = "Hypervene hypospray"
	desc = "A hypospray loaded with hypervene. A chemical that rapdidly flushes the body of all chemicals and toxins."
	amount_per_transfer_from_this = 3
	list_reagents = list(
		/datum/reagent/hypervene = 60,
	)
	description_overlay = "Ht"

/obj/item/reagent_containers/hypospray/advanced/nanoblood
	name = "Nanoblood hypospray"
	desc = "A hypospray loaded with nanoblood. A chemical which rapidly restores blood at the cost of minor toxic damage."
	amount_per_transfer_from_this = 5
	list_reagents = list(
		/datum/reagent/medicine/nanoblood = 60,
	)
	description_overlay = "Na"

/obj/item/reagent_containers/hypospray/advanced/big
	name = "Big hypospray"
	desc = "The hypospray is a sterile, air-needle reusable autoinjector for rapid administration of drugs to patients with customizable dosages. Comes complete with an internal reagent analyzer and digital labeler. Handy. This one is a 120 unit version."
	core_name = "hypospray"
	volume = 120

/obj/item/reagent_containers/hypospray/advanced/big/bicaridine
	name = "Big bicaridine hypospray"
	desc = "A hypospray loaded with bicaridine. A chemical that heal cuts and bruises."
	list_reagents = list(
		/datum/reagent/medicine/bicaridine = 120,
	)
	description_overlay = "Bi"

/obj/item/reagent_containers/hypospray/advanced/big/kelotane
	name = "Big kelotane hypospray"
	desc = "A hypospray loaded with kelotane. A chemical that heal burns."
	list_reagents = list(
		/datum/reagent/medicine/kelotane = 120,
	)
	description_overlay = "Ke"

/obj/item/reagent_containers/hypospray/advanced/big/tramadol
	name = "Big tramadol hypospray"
	desc = "A hypospray loaded with tramadol. A chemical that numbs pain."
	list_reagents = list(
		/datum/reagent/medicine/tramadol = 120,
	)
	description_overlay = "Ta"

/obj/item/reagent_containers/hypospray/advanced/big/tricordrazine
	name = "Big tricordrazine hypospray"
	desc = "A hypospray loaded with tricordrazine. A chemical that heal cuts, bruises, burns, toxicity, and oxygen deprivation."
	list_reagents = list(
		/datum/reagent/medicine/tricordrazine = 120,
	)
	description_overlay = "Ti"

/obj/item/reagent_containers/hypospray/advanced/big/dylovene
	name = "Big dylovene hypospray"
	desc = "A hypospray loaded with dylovene. A chemical that heal toxicity whilst purging toxins, hindering stamina in the process."
	list_reagents = list(
		/datum/reagent/medicine/dylovene = 120,
	)
	description_overlay = "Dy"

/obj/item/reagent_containers/hypospray/advanced/big/inaprovaline
	name = "Big inaprovaline hypospray"
	desc = "A hypospray loaded with inaprovaline. An emergency chemical used to stabilize and heal critical patients."
	amount_per_transfer_from_this = 15
	list_reagents = list(
		/datum/reagent/medicine/inaprovaline = 120,
	)
	description_overlay = "In"

/obj/item/reagent_containers/hypospray/advanced/big/dexalin
	name = "Big dexalin hypospray"
	desc = "A hypospray loaded with dexalin. A chemical that heals oxygen damage."
	list_reagents = list(
		/datum/reagent/medicine/dexalin = 120,
	)
	description_overlay = "Dx"

/obj/item/reagent_containers/hypospray/advanced/big/spaceacillin
	name = "Big spaceacillin hypospray"
	desc = "A hypospray loaded with spaceacillin. A chemical which fights viral and bacterial infections."
	list_reagents = list(
		/datum/reagent/medicine/spaceacillin = 120,
	)
	description_overlay = "Sp"

/obj/item/reagent_containers/hypospray/advanced/big/imialky
	name = "Big imialky hypospray"
	desc = "A hypospray loaded with a mixture of imidazoline and alkysine. Chemicals that will heal the brain and eyes."
	list_reagents = list(
		/datum/reagent/medicine/imidazoline = 60,
		/datum/reagent/medicine/alkysine = 60,
	)
	description_overlay = "Im"

/obj/item/reagent_containers/hypospray/advanced/big/quickclot
	name = "Big quick clot hypospray"
	desc = "A hypospray loaded with quick. A chemical that halts internal bleeding and restores blood."
	list_reagents = list(
		/datum/reagent/medicine/quickclot = 120,
	)
	description_overlay = "Qk"
