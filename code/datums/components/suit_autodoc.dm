/datum/component/suit_autodoc
	var/obj/item/healthanalyzer/integrated/analyzer

	var/burn_nextuse
	var/oxy_nextuse
	var/brute_nextuse
	var/tox_nextuse
	var/pain_nextuse

	var/chem_cooldown = 2.5 MINUTES

	var/enabled = FALSE

	var/damage_threshold = 50
	var/pain_threshold = 70

	var/list/burn_chems = list(
		/datum/reagent/medicine/kelotane,
		/datum/reagent/medicine/tricordrazine)
	var/list/oxy_chems = list(
		/datum/reagent/medicine/dexalinplus,
		/datum/reagent/medicine/inaprovaline,
		/datum/reagent/medicine/tricordrazine)
	var/list/brute_chems = list(
		/datum/reagent/medicine/bicaridine,
		/datum/reagent/medicine/quickclot,
		/datum/reagent/medicine/tricordrazine)
	var/list/tox_chems = list(
		/datum/reagent/medicine/dylovene,
		/datum/reagent/medicine/spaceacillin,
		/datum/reagent/medicine/tricordrazine)
	var/list/pain_chems = list(
		/datum/reagent/medicine/oxycodone,
		/datum/reagent/medicine/tramadol)

	var/datum/action/suit_autodoc_toggle/toggle_action
	var/datum/action/suit_autodoc_scan/scan_action
	var/datum/action/suit_autodoc_configure/configure_action

/datum/component/suit_autodoc/Initialize(chem_cooldown, list/burn_chems, list/oxy_chems, list/brute_chems, list/tox_chems, list/pain_chems)
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	analyzer = new
	toggle_action = new(parent)
	scan_action = new(parent)
	configure_action = new(parent)
	if(!isnull(chem_cooldown))
		src.chem_cooldown = chem_cooldown
	if(islist(burn_chems))
		src.burn_chems = burn_chems
	if(islist(oxy_chems))
		src.oxy_chems = oxy_chems
	if(islist(brute_chems))
		src.brute_chems = brute_chems
	if(islist(tox_chems))
		src.tox_chems = tox_chems
	if(islist(pain_chems))
		src.pain_chems = pain_chems

/datum/component/suit_autodoc/Destroy(force, silent)
	QDEL_NULL(analyzer)
	QDEL_NULL(toggle_action)
	QDEL_NULL(scan_action)
	QDEL_NULL(configure_action)
	return ..()

/datum/component/suit_autodoc/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/dropped)
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/equipped)
	RegisterSignal(parent, COMPONENT_SUIT_AUTODOC_TOGGLE, .proc/action_toggle)
	RegisterSignal(parent, COMPONENT_SUIT_AUTODOC_SCAN, .proc/scan_user)
	RegisterSignal(parent, COMPONENT_SUIT_AUTODOC_CONFIGURE, .proc/configure)

/datum/component/suit_autodoc/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_EXAMINE,
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_EQUIPPED,
		COMPONENT_SUIT_AUTODOC_TOGGLE,
		COMPONENT_SUIT_AUTODOC_SCAN,
		COMPONENT_SUIT_AUTODOC_CONFIGURE))
	return ..()

/datum/component/suit_autodoc/proc/RegisterSignals(mob/user)
	RegisterSignal(user, COMSIG_HUMAN_DAMAGE_TAKEN, .proc/damage_taken)

/datum/component/suit_autodoc/proc/UnregisterSignals(mob/user)
	UnregisterSignal(user, COMSIG_HUMAN_DAMAGE_TAKEN)

/datum/component/suit_autodoc/proc/examine(datum/source, mob/user)
	var/details
	if(burn_nextuse > world.time)
		details += "Its burn treatment injector is currently refilling. It will resupply in [(burn_nextuse - world.time) * 0.1] seconds.</br>"

	if(brute_nextuse > world.time)
		details += "Its trauma treatment injector is currently refilling. It will resupply in [(brute_nextuse - world.time) * 0.1] seconds.</br>"

	if(oxy_nextuse > world.time)
		details += "Its oxygenating injector is currently refilling. It will resupply in [(oxy_nextuse - world.time) * 0.1] seconds.</br>"

	if(tox_nextuse > world.time)
		details += "Its anti-toxin injector is currently refilling. It will resupply in [(tox_nextuse - world.time) * 0.1] seconds.</br>"

	if(pain_nextuse > world.time)
		details += "Its painkiller injector is currently refilling. It will resupply in [(pain_nextuse - world.time) * 0.1] seconds.</br>"

	if(details)
		to_chat(user, "<span class='danger'>[details]</span>")

/datum/component/suit_autodoc/proc/dropped(datum/source, mob/user)
	remove_actions(user)
	disable(user)

/datum/component/suit_autodoc/proc/equipped(datum/source, mob/equipper, slot)
	var/obj/item/I = parent
	if(slotdefine2slotbit(slot) & I.flags_equip_slot)
		if(ishuman(equipper) && !enabled)
			give_actions(equipper)
			enable(equipper)
		return
	if(enabled)
		disable(equipper)

/datum/component/suit_autodoc/proc/disable(mob/user, silent = FALSE)
	if(!enabled)
		return
	enabled = FALSE
	UnregisterSignals(user)
	STOP_PROCESSING(SSobj, src)
	if(!silent)
		to_chat(user, "<span class='warning'>[parent] lets out a beep as its automedical suite deactivates.</span>")
		playsound(parent,'sound/machines/click.ogg', 15, 0, 1)

/datum/component/suit_autodoc/proc/enable(mob/user, silent = FALSE)
	if(enabled)
		return
	enabled = TRUE
	RegisterSignals(user)
	START_PROCESSING(SSobj, src)
	if(!silent)
		to_chat(user, "<span class='notice'>[parent] lets out a hum as its automedical suite activates.</span>")
		playsound(parent,'sound/voice/b18_activate.ogg', 15, 0, 1)

/datum/component/suit_autodoc/proc/damage_taken(datum/source, mob/living/carbon/human/wearer, damage)
	treat_injuries()

/datum/component/suit_autodoc/process()
	treat_injuries()

#define OVERDOSE_THRESHOLD_MODIFIER 0.5

/datum/component/suit_autodoc/proc/inject_chems(list/chems, mob/living/carbon/human/H, nextuse, damage, threshold, message_prefix)
	if(!length(chems) || nextuse > world.time || damage < threshold)
		return

	var/drugs

	for(var/chem in chems)
		var/datum/reagent/R = chem
		var/amount_to_administer = CLAMP(\
									initial(R.overdose_threshold) - H.reagents.get_reagent_amount(R),\
									0,\
									initial(R.overdose_threshold) * OVERDOSE_THRESHOLD_MODIFIER)
		if(amount_to_administer)
			H.reagents.add_reagent(R, amount_to_administer)
			drugs += " [initial(R.name)]: [amount_to_administer]U"

	if(LAZYLEN(drugs))
		. = "[message_prefix] administered. <span class='bold'>Dosage:[drugs]</span><br/>"

#undef OVERDOSE_THRESHOLD_MODIFIER

/datum/component/suit_autodoc/proc/treat_injuries()
	var/obj/item/I = parent // guarenteed by Initialize()
	var/mob/living/carbon/human/H = I.loc // uncertain
	if(!istype(H))
		return

	var/burns = inject_chems(burn_chems, H, burn_nextuse, H.getFireLoss(), damage_threshold, "Significant tissue burns detected. Restorative injection")
	if(burns)
		burn_nextuse = world.time + chem_cooldown
		addtimer(CALLBACK(src, .proc/nextuse_ready, "Burn treatment"), chem_cooldown)
	var/brute = inject_chems(brute_chems, H, brute_nextuse, H.getBruteLoss(), damage_threshold, "Significant tissue burns detected. Restorative injection")
	if(brute)
		brute_nextuse = world.time + chem_cooldown
		addtimer(CALLBACK(src, .proc/nextuse_ready, "Trauma treatment"), chem_cooldown)
	var/oxy = inject_chems(oxy_chems, H, oxy_nextuse, H.getOxyLoss(), damage_threshold, "Low blood oxygen detected. Reoxygenating preparation")
	if(oxy)
		oxy_nextuse = world.time + chem_cooldown
		addtimer(CALLBACK(src, .proc/nextuse_ready, "Oxygenation treatment"), chem_cooldown)
	var/tox = inject_chems(tox_chems, H, tox_nextuse, H.getToxLoss(), damage_threshold, "Significant blood toxicity detected. Chelating agents and curatives")
	if(tox)
		tox_nextuse = world.time + chem_cooldown
		addtimer(CALLBACK(src, .proc/nextuse_ready, "Toxicity treatment"), chem_cooldown)
	var/pain = inject_chems(pain_chems, H, pain_nextuse, H.traumatic_shock, pain_threshold, "User pain at performance impeding levels. Painkillers")
	if(pain)
		pain_nextuse = world.time + chem_cooldown
		addtimer(CALLBACK(src, .proc/nextuse_ready, "Painkiller"), chem_cooldown)

	if(burns || brute || oxy || tox || pain)
		playsound(I,'sound/items/hypospray.ogg', 25, 0, 1)
		to_chat(H, "<span class='notice'>[icon2html(I, H)] beeps:</br>[burns][brute][oxy][tox][pain]Estimated [chem_cooldown/600] minute replenishment time for each dosage.</span>")

/datum/component/suit_autodoc/proc/nextuse_ready(message)

	var/obj/item/I = parent // guarenteed by Initialize()

	playsound(I,'sound/effects/refill.ogg', 25, 0, 1)

	var/mob/living/carbon/human/H = I.loc // uncertain
	if(!istype(H))
		return

	to_chat(H, "<span class='notice'>[I] beeps: [message] reservoir replenished.</span>")

/datum/component/suit_autodoc/proc/give_actions(mob/user)
	toggle_action.give_action(user)
	scan_action.give_action(user)
	configure_action.give_action(user)

/datum/component/suit_autodoc/proc/remove_actions(mob/user)
	toggle_action.remove_action(user)
	scan_action.remove_action(user)
	configure_action.remove_action(user)

/datum/component/suit_autodoc/proc/action_toggle(datum/source, mob/user)
	if(enabled)
		disable(user)
	else
		enable(user)

/datum/component/suit_autodoc/proc/scan_user(datum/source, mob/user)
	analyzer.attack(user, user, TRUE)

/datum/component/suit_autodoc/proc/configure(datum/source, mob/user)
	interact(user)

/datum/component/suit_autodoc/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat = {"
	<A href='?src=\ref[src];automed_on=1'>Turn Automed System: [enabled ? "Off" : "On"]</A><BR>
	<BR>
	<B>Integrated Health Analyzer:</B><BR>
	<A href='byond://?src=\ref[src];analyzer=1'>Scan Wearer</A><BR>
	<A href='byond://?src=\ref[src];toggle_mode=1'>Turn Scanner HUD Mode: [analyzer.hud_mode ? "Off" : "On"]</A><BR>
	<BR>
	<B>Damage Trigger Threshold (Max 150, Min 50):</B><BR>
	<A href='byond://?src=\ref[src];automed_damage=-50'>-50</A>
	<A href='byond://?src=\ref[src];automed_damage=-10'>-10</A>
	<A href='byond://?src=\ref[src];automed_damage=-5'>-5</A>
	<A href='byond://?src=\ref[src];automed_damage=-1'>-1</A> [damage_threshold]
	<A href='byond://?src=\ref[src];automed_damage=1'>+1</A>
	<A href='byond://?src=\ref[src];automed_damage=5'>+5</A>
	<A href='byond://?src=\ref[src];automed_damage=10'>+10</A>
	<A href='byond://?src=\ref[src];automed_damage=50'>+50</A><BR>
	<BR>
	<B>Pain Trigger Threshold (Max 150, Min 50):</B><BR>
	<A href='byond://?src=\ref[src];automed_pain=-50'>-50</A>
	<A href='byond://?src=\ref[src];automed_pain=-10'>-10</A>
	<A href='byond://?src=\ref[src];automed_pain=-5'>-5</A>
	<A href='byond://?src=\ref[src];automed_pain=-1'>-1</A> [pain_threshold]
	<A href='byond://?src=\ref[src];automed_pain=1'>+1</A>
	<A href='byond://?src=\ref[src];automed_pain=5'>+5</A>
	<A href='byond://?src=\ref[src];automed_pain=10'>+10</A>
	<A href='byond://?src=\ref[src];automed_pain=50'>+50</A><BR>"}

	var/datum/browser/popup = new(user, "Suit Automedic")
	popup.set_content(dat)
	popup.open()

#define SUIT_AUTODOC_DAM_MIN 50
#define SUIT_AUTODOC_DAM_MAX 150

/datum/component/suit_autodoc/Topic(href, href_list)
	. = ..()
	if(.)
		return

	var/obj/item/I = parent
	var/mob/living/carbon/human/H = I.loc
	if(!istype(H) || usr != H)
		return

	if(href_list["automed_on"])
		if(enabled)
			disable(usr)
		else
			enable(usr)

	else if(href_list["analyzer"]) //Integrated scanner
		analyzer.attack(usr, usr, TRUE)

	else if(href_list["toggle_mode"]) //Integrated scanner
		analyzer.hud_mode = !analyzer.hud_mode
		if(analyzer.hud_mode)
			to_chat(usr, "<span class='notice'>The scanner now shows results on the hud.</span>")
		else
			to_chat(usr, "<span class='notice'>The scanner no longer shows results on the hud.</span>")

	else if(href_list["automed_damage"])
		damage_threshold += text2num(href_list["automed_damage"])
		damage_threshold = round(damage_threshold)
		damage_threshold = CLAMP(damage_threshold,SUIT_AUTODOC_DAM_MIN,SUIT_AUTODOC_DAM_MAX)
	else if(href_list["automed_pain"])
		pain_threshold += text2num(href_list["automed_pain"])
		pain_threshold = round(pain_threshold)
		pain_threshold = CLAMP(pain_threshold,SUIT_AUTODOC_DAM_MIN,SUIT_AUTODOC_DAM_MAX)

	interact(usr)

#undef SUIT_AUTODOC_DAM_MAX
#undef SUIT_AUTODOC_DAM_MIN

//// Action buttons

/datum/action/suit_autodoc_toggle
	name = "Toggle Suit Automedic"

/datum/action/suit_autodoc_toggle/action_activate()
	if(QDELETED(owner) || owner.incapacitated())
		return
	SEND_SIGNAL(target, COMPONENT_SUIT_AUTODOC_TOGGLE, owner)

/datum/action/suit_autodoc_scan
	name = "Suit Automedic User Scan"

/datum/action/suit_autodoc_scan/action_activate()
	if(QDELETED(owner) || owner.incapacitated())
		return
	SEND_SIGNAL(target, COMPONENT_SUIT_AUTODOC_SCAN, owner)

/datum/action/suit_autodoc_configure
	name = "Configure Suit Automedic"

/datum/action/suit_autodoc_configure/action_activate()
	if(QDELETED(owner) || !owner.incapacitated())
		return
	SEND_SIGNAL(target, COMPONENT_SUIT_AUTODOC_CONFIGURE, owner)
