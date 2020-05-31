////////////////////////////////////////////////////////////////////////////////
/// HYPOSPRAY
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_containers/hypospray
	name = "hypospray"
	desc = "The hypospray is a sterile, air-needle reusable autoinjector for rapid administration of drugs to patients with customizable dosages."
	icon = 'icons/obj/items/syringe.dmi'
	item_state = "hypo"
	icon_state = "hypo_base"
	amount_per_transfer_from_this = 5
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

/obj/item/reagent_containers/hypospray/advanced
	name = "advanced hypospray"
	desc = "The hypospray is a sterile, air-needle reusable autoinjector for rapid administration of drugs to patients with customizable dosages. Comes complete with an internal reagent analyzer and digital labeler. Handy."
	core_name = "hypospray"


/obj/item/reagent_containers/hypospray/proc/empty(mob/user)
	if(alert(user, "Are you sure you want to empty [src]?", "Flush [src]:", "Yes", "No") != "Yes")
		return
	if(isturf(user.loc))
		to_chat(user, "<span class='notice'>You flush the contents of [src].</span>")
		reagents.reaction(user.loc)
		reagents.clear_reagents()

/obj/item/reagent_containers/hypospray/proc/label(mob/user)
	var/str = copytext(reject_bad_text(input(user,"Hypospray label text?", "Set label", "")), 1, MAX_NAME_LEN)
	if(!length(str))
		to_chat(user, "<span class='notice'>Invalid text.</span>")
		return
	to_chat(user, "<span class='notice'>You label [src] as \"[str]\".</span>")
	name = "[core_name] ([str])"
	label = str


/obj/item/reagent_containers/hypospray/afterattack(atom/A, mob/living/user)
	if(!A.reagents)
		return
	if(!istype(user))
		return
	if(!in_range(A, user) || !user.Adjacent(A))
		return
	if(inject_mode == HYPOSPRAY_INJECT_MODE_DRAW) //if we're draining
		if(reagents.holder_full())
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			inject_mode = HYPOSPRAY_INJECT_MODE_INJECT
			update_icon() //So we now display as Inject
			return

		if(iscarbon(A))
			var/amount = min(reagents.maximum_volume - reagents.total_volume, amount_per_transfer_from_this)
			var/mob/living/carbon/C = A
			if(C.get_blood_id() && reagents.has_reagent(C.get_blood_id()))
				to_chat(user, "<span class='warning'>There is already a blood sample in [src].</span>")
				return
			if(!C.blood_type)
				to_chat(user, "<span class='warning'>You are unable to locate any blood.</span>")
				return

			if(ishuman(C))
				var/mob/living/carbon/human/H = C
				if(H.species.species_flags & NO_BLOOD)
					to_chat(user, "<span class='warning'>You are unable to locate any blood.</span>")
					return
				else
					C.take_blood(src,amount)
			else
				C.take_blood(src,amount)

			reagents.handle_reactions()
			user.visible_message("<span clas='warning'>[user] takes a blood sample from [A].</span>",
								"<span class='notice'>You take a blood sample from [A].</span>", null, 4)

		else if(istype(A, /obj)) //if not mob
			if(!A.reagents.total_volume)
				to_chat(user, "<span class='warning'>[A] is empty.")
				return

			if(!A.is_drawable())
				to_chat(user, "<span class='warning'>You cannot directly remove reagents from this object.</span>")
				return

			var/trans = A.reagents.trans_to(src, amount_per_transfer_from_this)

			to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the solution.</span>")

		on_reagent_change()
		return TRUE


	if(!reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is empty.</span>")
		return
	if(!A.is_injectable() && !ismob(A))
		to_chat(user, "<span class='warning'>You cannot directly fill this object.</span>")
		return
	if(skilllock && user.skills.getRating("medical") < SKILL_MEDICAL_NOVICE)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out how to use the [src].</span>",
		"<span class='notice'>You fumble around figuring out how to use the [src].</span>")
		if(!do_after(user, SKILL_TASK_EASY, TRUE, A, BUSY_ICON_UNSKILLED) || (!in_range(A, user) || !user.Adjacent(A)))
			return

	if(ismob(A))
		var/mob/M = A
		if(!M.can_inject(user, TRUE, user.zone_selected, TRUE))
			return
		if(M != user && M.stat != DEAD && M.a_intent != INTENT_HELP && !M.incapacitated() && M.skills.getRating("cqc") >= SKILL_CQC_MP)
			user.Paralyze(60)
			log_combat(M, user, "blocked", addition="using their cqc skill (hypospray injection)")
			M.visible_message("<span class='danger'>[M]'s reflexes kick in and knock [user] to the ground before they could use \the [src]'!</span>", \
				"<span class='warning'>You knock [user] to the ground before they could inject you!</span>", null, 5)
			playsound(user.loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
			return FALSE

	var/list/injected = list()
	for(var/datum/reagent/R in reagents.reagent_list)
		injected += R.name
	log_combat(user, A, "injected", src, "Reagents: [english_list(injected)]")

	if(ismob(A))
		var/mob/M = A
		to_chat(user, "<span class='notice'>You inject [M] with [src]</span>.")
		to_chat(M, "<span class='warning'>You feel a tiny prick!</span>")

	playsound(loc, 'sound/items/hypospray.ogg', 50, 1)
	reagents.reaction(A, INJECT)
	var/trans = reagents.trans_to(A, amount_per_transfer_from_this)
	to_chat(user, "<span class='notice'>[trans] units injected. [reagents.total_volume] units remaining in [src]. </span>")

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

/obj/item/reagent_containers/hypospray/update_icon()
	if(ismob(loc))
		if(inject_mode)
			icon_state = "hypo_i"
		else
			icon_state = "hypo_d"
	else
		icon_state = "hypo"

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
			to_chat(usr, "<span class='notice'>[src] has been set to draw mode. It will now drain reagents.</span>")
		else
			to_chat(usr, "<span class='notice'>[src] has been set to inject mode. It will now inject reagents.</span>")
		inject_mode = !inject_mode
		update_icon()

	else if(href_list["autolabeler"])
		label(usr)

	else if(href_list["set_transfer"])
		var/N = input("Amount per transfer from this:", "[src]") as null|anything in list(1, 3, 5, 10, 15)
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
		display_reagents(usr)



/obj/item/reagent_containers/hypospray/advanced/tricordrazine
	list_reagents = list(/datum/reagent/medicine/tricordrazine = 60)


/obj/item/reagent_containers/hypospray/advanced/oxycodone
	list_reagents = list(/datum/reagent/medicine/oxycodone = 60)


/obj/item/reagent_containers/hypospray/advanced/update_icon()
	. = ..()

	overlays.Cut()
	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)			filling.icon_state = "[initial(icon_state)]-10"
			if(10 to 24) 		filling.icon_state = "[initial(icon_state)]10"
			if(25 to 49)		filling.icon_state = "[initial(icon_state)]25"
			if(50 to 74)		filling.icon_state = "[initial(icon_state)]50"
			if(75 to 79)		filling.icon_state = "[initial(icon_state)]75"
			if(80 to 90)		filling.icon_state = "[initial(icon_state)]80"
			if(91 to INFINITY)	filling.icon_state = "[initial(icon_state)]100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

/obj/item/reagent_containers/hypospray/advanced/examine(mob/user as mob)
	. = ..()
	if(get_dist(user,src) > 2)
		to_chat(user, "<span class = 'warning'>You're too far away to see [src]'s reagent display!</span>")
		return

	display_reagents(user)

/obj/item/reagent_containers/hypospray/advanced/proc/display_reagents(mob/user)
	if(!isnull(reagents))
		var/list/dat = list()
		dat += "\n \t <span class='notice'><b>Total Reagents:</b> [reagents.total_volume]/[volume]. <b>Dosage Size:</b> [min(reagents.total_volume, amount_per_transfer_from_this)]</span></br>"
		if(reagents.reagent_list.len > 0)
			for (var/datum/reagent/R in reagents.reagent_list)
				var/percent = round(R.volume / max(0.01 , reagents.total_volume * 0.01),0.01)
				var/dose = round(min(reagents.total_volume, amount_per_transfer_from_this) * percent * 0.01,0.01)
				if(R.scannable)
					dat += "\n \t <b>[R]:</b> [R.volume]|[percent]% <b>Amount per dose:</b> [dose]</br>"
				else
					dat += "\n \t <b>Unknown:</b> [R.volume]|[percent]% <b>Amount per dose:</b> [dose]</br>"
		if(dat)
			to_chat(user, "<span class = 'notice'>[src]'s reagent display shows the following contents: [dat.Join(" ")]</span>")
