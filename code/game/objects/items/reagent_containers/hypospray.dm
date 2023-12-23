////////////////////////////////////////////////////////////////////////////////
/// HYPOSPRAY
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_containers/hypospray
	name = "Hypospray"
	desc = "The hypospray is a sterile, air-needle reusable autoinjector for rapid administration of drugs to patients with customizable dosages."
	icon = 'icons/obj/items/syringe.dmi'
	item_state = "hypo"
	icon_state = "hypo"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(1, 3, 5, 10, 15, 20, 30)
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
	desc = "The hypospray is a sterile, air-needle reusable autoinjector for rapid administration of drugs to patients with customizable dosages. Comes complete with an internal reagent analyzer, digital labeler and 2 letter tagger. Handy."
	core_name = "hypospray"


/obj/item/reagent_containers/hypospray/proc/empty(mob/user)
	if(tgui_alert(user, "Are you sure you want to empty [src]?", "Flush [src]:", list("Yes", "No")) != "Yes")
		return
	if(isturf(user.loc))
		user.balloon_alert(user, "Flushes hypospray.")
		reagents.reaction(user.loc)
		reagents.clear_reagents()

/obj/item/reagent_containers/hypospray/afterattack(atom/A, mob/living/user)
	if(!istype(user))
		return FALSE
	if(!in_range(A, user) || !user.Adjacent(A))
		return FALSE

	if(istype(A, /obj/item/storage/pill_bottle) && is_open_container()) //this should only run if its a pillbottle
		var/obj/item/storage/pill_bottle/bottle = A
		if(reagents.total_volume >= volume)
			balloon_alert(user, "Hypospray is full.")
			return  //early returning if its full

		if(!length(bottle.contents))
			return //early returning if its empty
		var/obj/item/pill = bottle.contents[1]

		if((pill.reagents.total_volume + reagents.total_volume) > volume)
			balloon_alert(user, "Can't hold that much.")
			return // so it doesnt let people have hypos more filled than their volume
		pill.reagents.trans_to(src, pill.reagents.total_volume)

		to_chat(user, span_notice("You dissolve [pill] from [bottle] in [src]."))
		bottle.remove_from_storage(pill,null,user)
		qdel(pill)
		return

	//For drawing reagents, will check if it's possible to draw, then draws.
	if(inject_mode == HYPOSPRAY_INJECT_MODE_DRAW)
		can_draw_reagent(A, user, FALSE)
		return

	if(!reagents.total_volume)
		balloon_alert(user, "Hypospray is Empty.")
		return
	if(!A.is_injectable() && !ismob(A))
		A.balloon_alert(user, "Can't fill.")
		return
	if(skilllock && user.skills.getRating(SKILL_MEDICAL) < SKILL_MEDICAL_NOVICE)
		user.visible_message(span_notice("[user] fumbles around figuring out how to use the [src]."),
		span_notice("You fumble around figuring out how to use the [src]."))
		if(!do_after(user, SKILL_TASK_EASY, NONE, A, BUSY_ICON_UNSKILLED) || (!in_range(A, user) || !user.Adjacent(A)))
			return

	if(ismob(A))
		var/mob/M = A
		if(!M.can_inject(user, TRUE, user.zone_selected, TRUE))
			return

	var/list/injected = list()
	for(var/datum/reagent/R in reagents.reagent_list)
		injected += R.name
	log_combat(user, A, "injected", src, "Reagents: [english_list(injected)]")

	if(ismob(A))
		var/mob/M = A
		balloon_alert(user, "Injects [M]")
		to_chat(M, span_warning("You feel a tiny prick!")) // inject self doubleposting
		record_reagent_consumption(min(amount_per_transfer_from_this, reagents.total_volume), injected, user, M)

	// /mob/living/carbon/human/attack_hand causes
	// changeNext_move(7) which creates a delay
	// This line overrides the delay, and will absolutely break everything
	user.changeNext_move(3) // please don't break the game

	playsound(loc, 'sound/items/hypospray.ogg', 50, 1)
	reagents.reaction(A, INJECT, min(amount_per_transfer_from_this, reagents.total_volume) / reagents.total_volume)
	var/trans = reagents.trans_to(A, amount_per_transfer_from_this)
	to_chat(user, span_notice("[trans] units injected. [reagents.total_volume] units remaining in [src]. ")) // better to not balloon

	return TRUE

/obj/item/reagent_containers/hypospray/afterattack_alternate(atom/A, mob/living/user)
	if(!istype(user))
		return FALSE
	if(!in_range(A, user) || !user.Adjacent(A)) //So we arent drawing reagent from a container behind a window
		return FALSE
	can_draw_reagent(A, user, TRUE) //Always draws reagents on right click

///If it's possible to draw from something. Will draw_blood() when targetting a carbon, or draw_reagent() when targetting a non-carbon
/obj/item/reagent_containers/hypospray/proc/can_draw_reagent(atom/A, mob/living/user)
	if(!A.reagents)
		return FALSE
	if(reagents.holder_full())
		balloon_alert(user, "Hypospray is full.")
		inject_mode = HYPOSPRAY_INJECT_MODE_INJECT
		update_icon() //So we now display as Inject
		return FALSE
	if(!A.reagents.total_volume)
		balloon_alert(user, "Hypospray is empty.")
		return
	if(!A.is_drawable())
		balloon_alert(user, "Can't remove reagents.")
		return

	if(iscarbon(A))
		draw_blood(A, user)
		return TRUE

	if(isobj(A)) //if not mob
		draw_reagent(A, user)
		return TRUE

///Checks if the carbon has blood, then tries to draw blood from it
/obj/item/reagent_containers/hypospray/proc/draw_blood(atom/A, mob/living/user)
	var/amount = min(reagents.maximum_volume - reagents.total_volume, amount_per_transfer_from_this)
	var/mob/living/carbon/C = A
	if(C.get_blood_id() && reagents.has_reagent(C.get_blood_id()))
		balloon_alert(user, "Already have a blood sample.")
		return
	if(!C.blood_type)
		balloon_alert(user, "Can't locate blood.")
		return
	if(C.blood_volume <= BLOOD_VOLUME_SURVIVE)
		balloon_alert(user, "No blood to draw.")
		return
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(H.species.species_flags & NO_BLOOD)
			balloon_alert(user, "Can't locate blood.")
			return
		else
			C.take_blood(src,amount)
	else
		C.take_blood(src,amount)
	reagents.handle_reactions()
	user.visible_message("<span clas='warning'>[user] takes a blood sample from [A].</span>",
						span_notice("You take a blood sample from [A]."), null, 4)
	on_reagent_change()

///Checks if a container is drawable, then draw reagents from the container
/obj/item/reagent_containers/hypospray/proc/draw_reagent(atom/A, mob/living/user)
	var/trans = A.reagents.trans_to(src, amount_per_transfer_from_this)
	balloon_alert(user, "Fills with [trans] units.")

	on_reagent_change()

/obj/item/reagent_containers/hypospray/on_reagent_change()
	if(reagents.holder_full())
		inject_mode = HYPOSPRAY_INJECT_MODE_INJECT
	update_icon()

/obj/item/reagent_containers/hypospray/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	update_icon()

/obj/item/reagent_containers/hypospray/on_enter_storage(mob/user, slot)
	. = ..()
	update_icon()

/obj/item/reagent_containers/hypospray/pickup(mob/user)
	. = ..()
	update_icon()

/obj/item/reagent_containers/hypospray/dropped(mob/user)
	. = ..()
	update_icon()

/obj/item/reagent_containers/hypospray/update_overlays()
	. = ..()
	if(isturf(loc) || !description_overlay)
		return
	var/mutable_appearance/desc = mutable_appearance('icons/misc/12x12.dmi')
	desc.pixel_x = 16
	desc.maptext = MAPTEXT(description_overlay)
	desc.maptext_width = 16
	. += desc

/obj/item/reagent_containers/hypospray/advanced
	icon_state = "hypo"
	init_reagent_flags = REFILLABLE|DRAINABLE
	liquifier = TRUE


/obj/item/reagent_containers/hypospray/open_ui(mob/user)
	var/dat = {"
	<B><A href='?src=[text_ref(src)];autolabeler=1'>Activate Autolabeler</A></B><BR>
	<B>Current Label:</B> [label]<BR>
	<BR>
	<B><A href='?src=[text_ref(src)];overlayer=1'>Activate Tagger</A></B><BR>
	<B>Current Tag:</B> [description_overlay]<BR>
	<BR>
	<B><A href='byond://?src=[text_ref(src)];inject_mode=1'>Toggle Mode:</A></B><BR>
	<B>Current Mode:</B> [inject_mode ? "Inject" : "Draw"]<BR>
	<BR>
	<B><A href='byond://?src=[text_ref(src)];set_transfer=1'>Set Transfer Amount:</A></B><BR>
	<B>Current Transfer Amount [amount_per_transfer_from_this]</B><BR>
	<BR>
	<B><A href='byond://?src=[text_ref(src)];flush=1'>Empty Hypospray:</A></B><BR>
	<BR>"}

	var/datum/browser/popup = new(user, "hypospray")
	popup.set_content(dat)
	popup.open()


/obj/item/reagent_containers/hypospray/advanced/open_ui(mob/user)
	var/dat = {"
	<B><A href='?src=[text_ref(src)];autolabeler=1'>Activate Autolabeler</A></B><BR>
	<B>Current Label:</B> [label]<BR>
	<BR>
	<B><A href='?src=[text_ref(src)];overlayer=1'>Activate Tagger</A></B><BR>
	<B>Current Tag:</B> [description_overlay]<BR>
	<BR>
	<B><A href='byond://?src=[text_ref(src)];inject_mode=1'>Toggle Mode:</A></B><BR>
	<B>Current Mode:</B> [inject_mode ? "Inject" : "Draw"]<BR>
	<BR>
	<B><A href='byond://?src=[text_ref(src)];set_transfer=1'>Set Transfer Amount:</A></B><BR>
	<B>Current Transfer Amount:</B> [amount_per_transfer_from_this]<BR>
	<BR>
	<B><A href='byond://?src=[text_ref(src)];displayreagents=1'>Display Reagent Content:</A></B><BR>
	<BR>
	<BR>
	<B><A href='byond://?src=[text_ref(src)];flush=1'>Empty Hypospray:</A></B><BR>
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
		var/mob/user = usr
		var/str = copytext(reject_bad_text(input(user,"Hypospray label text?", "Set label", "")), 1, MAX_NAME_LEN)
		if(!length(str))
			user.balloon_alert(user, "Invalid text.")
			return
		balloon_alert(user, "Labeled \"[str]\".")
		name = "[core_name] ([str])"
		label = str

	else if(href_list["overlayer"])
		var/mob/user = usr
		var/str = copytext(reject_bad_text(input(user,"Hypospray tag text?", "Set tag", "")), 1, MAX_NAME_HYPO)
		if(!length(str))
			user.balloon_alert(user, "Invalid text.")
			return
		user.balloon_alert(user, "You tag [src] as \"[str]\".")
		description_overlay = str
		update_icon()

	else if(href_list["set_transfer"])
		var/N = tgui_input_list(usr, "Amount per transfer from this:", "[src]", possible_transfer_amounts)
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
				icon_state = "[initial(icon_state)]_10"
			if(25 to 49)
				filling.icon_state = "[initial(icon_state)]25"
				icon_state = "[initial(icon_state)]_25"
			if(50 to 64)
				filling.icon_state = "[initial(icon_state)]50"
				icon_state = "[initial(icon_state)]_50"
			if(65 to 79)
				filling.icon_state = "[initial(icon_state)]65"
				icon_state = "[initial(icon_state)]_65"
			if(80 to 90)
				filling.icon_state = "[initial(icon_state)]80"
				icon_state = "[initial(icon_state)]_80"
			if(91 to INFINITY)
				filling.icon_state = "[initial(icon_state)]100"
				icon_state = "[initial(icon_state)]_100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

	else
		icon_state = "[initial(icon_state)]_0"

	if(ismob(loc))
		var/injoverlay
		switch(inject_mode)
			if (HYPOSPRAY_INJECT_MODE_DRAW)
				injoverlay = "draw"
			if (HYPOSPRAY_INJECT_MODE_INJECT)
				injoverlay = "inject"
		add_overlay(injoverlay)

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
	if(length(reagents.reagent_list) > 0)
		for (var/datum/reagent/R in reagents.reagent_list)
			var/percent = round(R.volume / max(0.01 , reagents.total_volume * 0.01),0.01)
			var/dose = round(min(reagents.total_volume, amount_per_transfer_from_this) * percent * 0.01,0.01)
			if(R.scannable)
				dat += "\n \t <b>[R]:</b> [R.volume]|[percent]% <b>Amount per dose:</b> [dose]</br>"
			else
				dat += "\n \t <b>Unknown:</b> [R.volume]|[percent]% <b>Amount per dose:</b> [dose]</br>"
	return span_notice("[src]'s reagent display shows the following contents: [dat.Join(" ")]")


/obj/item/reagent_containers/hypospray/advanced/bicaridine
	name = "bicaridine hypospray"
	desc = "A hypospray loaded with bicaridine. A chemical that heal cuts and bruises."
	list_reagents = list(
		/datum/reagent/medicine/bicaridine = 60,
	)
	description_overlay = "Bi"

/obj/item/reagent_containers/hypospray/advanced/kelotane
	name = "kelotane hypospray"
	desc = "A hypospray loaded with kelotane. A chemical that heal burns."
	list_reagents = list(
		/datum/reagent/medicine/kelotane = 60,
	)
	description_overlay = "Ke"

/obj/item/reagent_containers/hypospray/advanced/tramadol
	name = "tramadol hypospray"
	desc = "A hypospray loaded with tramadol. A chemical that numbs pain."
	list_reagents = list(
		/datum/reagent/medicine/tramadol = 60,
	)
	description_overlay = "Ta"

/obj/item/reagent_containers/hypospray/advanced/tricordrazine
	name = "tricordrazine hypospray"
	desc = "A hypospray loaded with tricordrazine. A chemical that heal cuts, bruises, burns, toxicity, and oxygen deprivation."
	list_reagents = list(
		/datum/reagent/medicine/tricordrazine = 60,
	)
	description_overlay = "Ti"

/obj/item/reagent_containers/hypospray/advanced/dylovene
	name = "dylovene hypospray"
	desc = "A hypospray loaded with dylovene. A chemical that heal toxicity whilst purging toxins, hindering stamina in the process."
	list_reagents = list(
		/datum/reagent/medicine/dylovene = 60,
	)
	description_overlay = "Dy"

/obj/item/reagent_containers/hypospray/advanced/inaprovaline
	name = "inaprovaline hypospray"
	desc = "A hypospray loaded with inaprovaline."
	amount_per_transfer_from_this = 15
	list_reagents = list(
		/datum/reagent/medicine/inaprovaline = 60,
	)
	description_overlay = "In"

/obj/item/reagent_containers/hypospray/advanced/meralyne
	name = "meralyne hypospray"
	desc = "A hypospray loaded with meralyne. An advanced chemical that heal cuts and bruises rapidly."
	amount_per_transfer_from_this = 5
	list_reagents = list(
		/datum/reagent/medicine/meralyne = 60,
	)
	description_overlay = "Mr"

/obj/item/reagent_containers/hypospray/advanced/dermaline
	name = "dermaline hypospray"
	desc = "A hypospray loaded with dermaline. An advanced chemical that heal burns rapdily."
	amount_per_transfer_from_this = 5
	list_reagents = list(
		/datum/reagent/medicine/dermaline = 60,
	)
	description_overlay = "Dr"

/obj/item/reagent_containers/hypospray/advanced/combat_advanced
	name = "advanced combat hypospray"
	desc = "A hypospray loaded with several doses of advanced healing and painkilling chemicals. Intended for use in active combat."
	list_reagents = list(
		/datum/reagent/medicine/meralyne = 20,
		/datum/reagent/medicine/dermaline = 20,
		/datum/reagent/medicine/tramadol = 20,
	)
	description_overlay = "Av"

/obj/item/reagent_containers/hypospray/advanced/meraderm
	name = "meraderm hypospray"
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
	name = "hypervene hypospray"
	desc = "A hypospray loaded with hypervene. A chemical that rapdidly flushes the body of all chemicals and toxins."
	amount_per_transfer_from_this = 3
	list_reagents = list(
		/datum/reagent/hypervene = 60,
	)
	description_overlay = "Hy"

/obj/item/reagent_containers/hypospray/advanced/nanoblood
	name = "nanoblood hypospray"
	desc = "A hypospray loaded with nanoblood. A chemical which rapidly restores blood at the cost of minor toxic damage."
	amount_per_transfer_from_this = 5
	list_reagents = list(
		/datum/reagent/medicine/nanoblood = 60,
	)
	description_overlay = "Na"

/obj/item/reagent_containers/hypospray/advanced/peridaxonplus
	name = "Peridaxon+ hypospray"
	desc = "A hypospray loaded with Peridaxon Plus, a chemical that heals organs while causing a buildup of toxins. Use with antitoxin. !DO NOT USE IN ACTIVE COMBAT!"
	amount_per_transfer_from_this = 3
	list_reagents = list(
		/datum/reagent/medicine/peridaxon_plus = 20,
		/datum/reagent/medicine/hyronalin = 40,
	)
	description_overlay = "Pe+"

/obj/item/reagent_containers/hypospray/advanced/quickclotplus
	name = "Quickclot+ hypospray"
	desc = "A hypospray loaded with quick-clot plus, a chemical designed to remove internal bleeding. Use with antitoxin. !DO NOT USE IN ACTIVE COMBAT!"
	amount_per_transfer_from_this = 5
	list_reagents = list(
		/datum/reagent/medicine/quickclotplus = 60,
	)
	description_overlay = "Qk+"

/obj/item/reagent_containers/hypospray/advanced/big
	name = "big hypospray"
	desc = "MK2 medical hypospray, which manages to fit even more reagents. Comes complete with an internal reagent analyzer, digital labeler and 2 letter tagger. Handy. This one is a 120 unit version."
	item_state = "hypomed"
	icon_state = "hypomed"
	core_name = "hypospray"
	volume = 120

/obj/item/reagent_containers/hypospray/advanced/big/bicaridine
	name = "big bicaridine hypospray"
	desc = "A hypospray loaded with bicaridine. A chemical that heal cuts and bruises."
	list_reagents = list(
		/datum/reagent/medicine/bicaridine = 120,
	)
	description_overlay = "Bi"

/obj/item/reagent_containers/hypospray/advanced/big/kelotane
	name = "big kelotane hypospray"
	desc = "A hypospray loaded with kelotane. A chemical that heal burns."
	list_reagents = list(
		/datum/reagent/medicine/kelotane = 120,
	)
	description_overlay = "Ke"

/obj/item/reagent_containers/hypospray/advanced/big/tramadol
	name = "big tramadol hypospray"
	desc = "A hypospray loaded with tramadol. A chemical that numbs pain."
	list_reagents = list(
		/datum/reagent/medicine/tramadol = 120,
	)
	description_overlay = "Ta"

/obj/item/reagent_containers/hypospray/advanced/big/tricordrazine
	name = "big tricordrazine hypospray"
	desc = "A hypospray loaded with tricordrazine. A chemical that heal cuts, bruises, burns, toxicity, and oxygen deprivation."
	list_reagents = list(
		/datum/reagent/medicine/tricordrazine = 120,
	)
	description_overlay = "Ti"

/obj/item/reagent_containers/hypospray/advanced/big/combatmix
	name = "big combat mix hypospray"
	desc = "A hypospray loaded with combat mix. There's a tag that reads BKTT 40:40:20:20."
	amount_per_transfer_from_this = 15
	list_reagents = list(
		/datum/reagent/medicine/bicaridine = 40,
		/datum/reagent/medicine/kelotane = 40,
		/datum/reagent/medicine/tramadol = 20,
		/datum/reagent/medicine/tricordrazine = 20,
	)
	description_overlay = "Cm"

/obj/item/reagent_containers/hypospray/advanced/big/dylovene
	name = "big dylovene hypospray"
	desc = "A hypospray loaded with dylovene. A chemical that heal toxicity whilst purging toxins, hindering stamina in the process."
	list_reagents = list(
		/datum/reagent/medicine/dylovene = 120,
	)
	description_overlay = "Dy"

/obj/item/reagent_containers/hypospray/advanced/big/inaprovaline
	name = "big inaprovaline hypospray"
	desc = "A hypospray loaded with inaprovaline. An emergency chemical used to stabilize and heal critical patients."
	amount_per_transfer_from_this = 15
	list_reagents = list(
		/datum/reagent/medicine/inaprovaline = 120,
	)
	description_overlay = "In"

/obj/item/reagent_containers/hypospray/advanced/big/isotonic
	name = "big isotonic hypospray"
	desc = "A hypospray loaded with isotonic. A chemical that aids in replenishing blood."
	list_reagents = list(
		/datum/reagent/medicine/saline_glucose = 120,
	)
	description_overlay = "Is"

/obj/item/reagent_containers/hypospray/advanced/big/spaceacillin
	name = "big spaceacillin hypospray"
	desc = "A hypospray loaded with spaceacillin. A chemical which fights viral and bacterial infections."
	list_reagents = list(
		/datum/reagent/medicine/spaceacillin = 120,
	)
	description_overlay = "Sp"

/obj/item/reagent_containers/hypospray/advanced/imialky
	name = "big imialky hypospray"
	desc = "A hypospray loaded with a mixture of imidazoline and alkysine. Chemicals that will heal brain, eyes, and ears."
	amount_per_transfer_from_this = 5
	list_reagents = list(
		/datum/reagent/medicine/imidazoline = 48,
		/datum/reagent/medicine/alkysine = 12,
	)
	description_overlay = "Im"

/obj/item/reagent_containers/hypospray/advanced/big/quickclot
	name = "big quick-clot hypospray"
	desc = "A hypospray loaded with quick-clot. A chemical that halts internal bleeding and restores blood."
	list_reagents = list(
		/datum/reagent/medicine/quickclot = 120,
	)
	description_overlay = "Qk"
