#define SUIT_AUTODOC_DAM_MIN 50
#define SUIT_AUTODOC_DAM_MAX 150
#define COOLDOWN_CHEM_BURN "chem_burn"
#define COOLDOWN_CHEM_OXY "oxy_chems"
#define COOLDOWN_CHEM_BRUTE "brute_chems"
#define COOLDOWN_CHEM_TOX "tox_chems"
#define COOLDOWN_CHEM_PAIN "pain_chems"

/**
	Autodoc component

	The autodoc is an item component that can be eqiupped to inject the wearer with chemicals.

	Parameters
	* chem_cooldown {time} default time between injections of chemicals
	* list/burn_chems {list/datum/reagent/medicine} chemicals available to be injected to treat burn injuries
	* list/oxy_chems {list/datum/reagent/medicine} chemicals available to be injected to treat oxygen injuries
	* list/brute_chems {list/datum/reagent/medicine} chemicals available to be injected to treat brute injuries
	* list/tox_chems {list/datum/reagent/medicine} chemicals available to be injected to treat toxin injuries
	* list/pain_chems {list/datum/reagent/medicine} chemicals available to be injected to treat pain injuries
	* overdose_threshold_mod {float} how close to overdosing will drugs inject to

*/
/datum/component/suit_autodoc
	var/obj/item/healthanalyzer/integrated/analyzer

	var/chem_cooldown = 2.5 MINUTES

	var/enabled = FALSE

	var/damage_threshold = 50
	var/pain_threshold = 70

	var/list/burn_chems
	var/list/oxy_chems
	var/list/brute_chems
	var/list/tox_chems
	var/list/pain_chems

	var/static/list/default_burn_chems = list(
		/datum/reagent/medicine/kelotane,
		/datum/reagent/medicine/tricordrazine)
	var/static/list/default_oxy_chems = list(
		/datum/reagent/medicine/dexalinplus,
		/datum/reagent/medicine/inaprovaline,
		/datum/reagent/medicine/tricordrazine)
	var/static/list/default_brute_chems = list(
		/datum/reagent/medicine/bicaridine,
		/datum/reagent/medicine/quickclot,
		/datum/reagent/medicine/tricordrazine)
	var/static/list/default_tox_chems = list(
		/datum/reagent/medicine/dylovene,
		/datum/reagent/medicine/spaceacillin,
		/datum/reagent/medicine/tricordrazine)
	var/static/list/default_pain_chems = list(
		/datum/reagent/medicine/hydrocodone,
		/datum/reagent/medicine/tramadol)

	var/datum/action/suit_autodoc/toggle/toggle_action
	var/datum/action/suit_autodoc/scan/scan_action
	var/datum/action/suit_autodoc/configure/configure_action

	var/mob/living/carbon/wearer

	var/overdose_threshold_mod = 0.5

/**
	Setup the default cooldown, chemicals and supported limbs
*/
/datum/component/suit_autodoc/Initialize(chem_cooldown, list/burn_chems, list/oxy_chems, list/brute_chems, list/tox_chems, list/pain_chems, overdose_threshold_mod)
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE

	analyzer = new
	if(!isnull(chem_cooldown))
		src.chem_cooldown = chem_cooldown

	src.burn_chems = burn_chems || default_burn_chems
	src.oxy_chems = oxy_chems || default_oxy_chems
	src.brute_chems = brute_chems || default_brute_chems
	src.tox_chems = tox_chems || default_tox_chems
	src.pain_chems = pain_chems || default_pain_chems

	if(!isnull(overdose_threshold_mod))
		src.overdose_threshold_mod = overdose_threshold_mod

/**
	Cleans up any actions, and internal items used by the autodoc component
*/
/datum/component/suit_autodoc/Destroy(force, silent)
	QDEL_NULL(analyzer)
	QDEL_NULL(toggle_action)
	QDEL_NULL(scan_action)
	QDEL_NULL(configure_action)
	wearer = null
	return ..()

/**
	Registers signals to enable/disable the autodoc when equipped/dropper/etc
*/
/datum/component/suit_autodoc/RegisterWithParent()
	. = ..()
	toggle_action = new(parent)
	scan_action = new(parent)
	configure_action = new(parent)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)
	RegisterSignal(parent, list(COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, COMSIG_ITEM_DROPPED), .proc/dropped)
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED_TO_SLOT, .proc/equipped)
	RegisterSignal(toggle_action, COMSIG_ACTION_TRIGGER, .proc/action_toggle)
	RegisterSignal(scan_action, COMSIG_ACTION_TRIGGER, .proc/scan_user)
	RegisterSignal(configure_action, COMSIG_ACTION_TRIGGER, .proc/configure)


/**
	Remove signals
*/
/datum/component/suit_autodoc/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_EXAMINE,
		COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT,
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_EQUIPPED_TO_SLOT))
	QDEL_NULL(toggle_action)
	QDEL_NULL(scan_action)
	QDEL_NULL(configure_action)

/**
	Specifically registers signals with the wearer to ensure we capture damage taken events
*/
/datum/component/suit_autodoc/proc/RegisterSignals(mob/user)
	RegisterSignal(user, COMSIG_HUMAN_DAMAGE_TAKEN, .proc/damage_taken)

/**
	Removes specific user signals
*/
/datum/component/suit_autodoc/proc/UnregisterSignals(mob/user)
	UnregisterSignal(user, COMSIG_HUMAN_DAMAGE_TAKEN)

/**
	Hook into the examine of the parent to show additional information about the suit_autodoc
*/
/datum/component/suit_autodoc/proc/examine(datum/source, mob/user, list/details)
	SIGNAL_HANDLER
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_CHEM_BURN))
		details += "Its burn treatment injector is currently refilling.</br>"

	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_CHEM_BRUTE))
		details += "Its trauma treatment injector is currently refilling.</br>"

	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_CHEM_OXY))
		details += "Its oxygenating injector is currently refilling.</br>"

	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_CHEM_TOX))
		details += "Its anti-toxin injector is currently refilling.</br>"

	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_CHEM_PAIN))
		details += "Its painkiller injector is currently refilling.</br>"


/**
	Disables the autodoc and removes actions when dropped
*/
/datum/component/suit_autodoc/proc/dropped(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!iscarbon(user))
		return
	remove_actions()
	disable()
	wearer = null


/**
	Enable the autodoc and give appropriate actions
*/
/datum/component/suit_autodoc/proc/equipped(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if(!iscarbon(equipper)) // living can equip stuff but only carbon has traumatic shock
		return
	wearer = equipper
	enable()
	give_actions()

/**
	Disables to stop processing and calls to the signals from the user.

	Additionally removes limb support if applicable
*/
/datum/component/suit_autodoc/proc/disable(silent = FALSE)
	if(!enabled)
		return
	enabled = FALSE
	toggle_action.set_toggle(FALSE)
	UnregisterSignals(wearer)
	STOP_PROCESSING(SSobj, src)
	if(!silent)
		wearer.balloon_alert(wearer, "The automedical suite deactivates")
		playsound(parent,'sound/machines/click.ogg', 15, 0, 1)

/**
	Enable processing and calls out to register signals from the user.

	Additionally adds limb support if applicable
*/
/datum/component/suit_autodoc/proc/enable(silent = FALSE)
	if(enabled)
		return
	enabled = TRUE
	toggle_action.set_toggle(TRUE)
	RegisterSignals(wearer)
	START_PROCESSING(SSobj, src)
	if(!silent)
		wearer.balloon_alert(wearer, "The automedical suite activates")
		playsound(parent,'sound/voice/b18_activate.ogg', 15, 0, 1)


/**
	Proc for the damange taken signal, calls treat_injuries
*/
/datum/component/suit_autodoc/proc/damage_taken(datum/source, mob/living/carbon/human/wearer, damage)
	SIGNAL_HANDLER
	treat_injuries()

/**
	Process proc called periodically, calls treat_injuries
*/
/datum/component/suit_autodoc/process()
	treat_injuries()

/**
	Handles actually injecting specific checmicals for specific damage types.

	This proc checks the damage is over the appropraite threshold, the cooldowns and if succesful injects
	chemicals into the user and sets the cooldown again
*/
/datum/component/suit_autodoc/proc/inject_chems(list/chems, mob/living/carbon/human/H, cooldown_type, damage, threshold, treatment_message, message_prefix)
	if(!length(chems) || TIMER_COOLDOWN_CHECK(src, cooldown_type) || damage < threshold)
		return

	var/drugs

	for(var/chem in chems)
		var/datum/reagent/R = chem
		var/amount_to_administer = clamp(\
									initial(R.overdose_threshold) - H.reagents.get_reagent_amount(R),\
									0,\
									initial(R.overdose_threshold) * overdose_threshold_mod)
		if(amount_to_administer)
			H.reagents.add_reagent(R, amount_to_administer)
			drugs += " [initial(R.name)]: [amount_to_administer]U"

	if(LAZYLEN(drugs))
		. = "[message_prefix] administered. [span_bold("Dosage:[drugs]")]<br/>"
		TIMER_COOLDOWN_START(src, cooldown_type, chem_cooldown)
		addtimer(CALLBACK(src, .proc/nextuse_ready, treatment_message), chem_cooldown)

/**
	Trys to inject each chmical into the user.

	Calls each proc and then reports the results if any to the user.
	additionally trys to support any limbs if required
*/
/datum/component/suit_autodoc/proc/treat_injuries()
	if(!wearer)
		CRASH("attempting to treat_injuries with no wearer")

	var/burns = inject_chems(burn_chems, wearer, COOLDOWN_CHEM_BURN, wearer.getFireLoss(), damage_threshold, "Burn treatment", "Significant tissue burns detected. Restorative injection")
	var/brute = inject_chems(brute_chems, wearer, COOLDOWN_CHEM_BRUTE, wearer.getBruteLoss(), damage_threshold, "Trauma treatment", "Significant tissue burns detected. Restorative injection")
	var/oxy = inject_chems(oxy_chems, wearer, COOLDOWN_CHEM_OXY, wearer.getOxyLoss(), damage_threshold, "Oxygenation treatment", "Low blood oxygen detected. Reoxygenating preparation")
	var/tox = inject_chems(tox_chems, wearer, COOLDOWN_CHEM_TOX, wearer.getToxLoss(), damage_threshold, "Toxicity treatment", "Significant blood toxicity detected. Chelating agents and curatives")
	var/pain = inject_chems(pain_chems, wearer, COOLDOWN_CHEM_PAIN, wearer.traumatic_shock, pain_threshold, "Painkiller", "User pain at performance impeding levels. Painkillers")

	if(burns || brute || oxy || tox || pain)
		playsound(parent,'sound/items/hypospray.ogg', 25, 0, 1)
		to_chat(wearer, span_notice("[icon2html(parent, wearer)] beeps:</br>[burns][brute][oxy][tox][pain]Estimated [chem_cooldown/600] minute replenishment time for each dosage."))

/**
	Plays a sound and message to the user informing the user chemicals are ready again
*/
/datum/component/suit_autodoc/proc/nextuse_ready(message)

	var/obj/item/I = parent // guarenteed by Initialize()

	playsound(I,'sound/effects/refill.ogg', 25, 0, 1)

	var/mob/living/carbon/human/H = I.loc // uncertain
	if(!istype(H))
		return

	to_chat(H, span_notice("[I] beeps: [message] reservoir replenished."))

/**
	Add the actions to the user

	Actions include
	- Enable and disable the suit
	- Manually do a health scan
	- Open suit settings
*/
/datum/component/suit_autodoc/proc/give_actions()
	toggle_action.give_action(wearer)
	scan_action.give_action(wearer)
	configure_action.give_action(wearer)

/**
	Remove the actions from the user

	Actions include
	- Enable and disable the suit
	- Manually do a health scan
	- Open suit settings
*/
/datum/component/suit_autodoc/proc/remove_actions()
	if(!wearer)
		return
	toggle_action.remove_action(wearer)
	scan_action.remove_action(wearer)
	configure_action.remove_action(wearer)

/**
	Toggle the suit

	This will enable or disable the suit
*/
/datum/component/suit_autodoc/proc/action_toggle(datum/source)
	SIGNAL_HANDLER
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_TOGGLE))
		return
	TIMER_COOLDOWN_START(src, COOLDOWN_TOGGLE, 2 SECONDS)
	if(enabled)
		disable()
	else
		enable()

/**
	Proc to handle the internal analyzer scanning the user
*/
/datum/component/suit_autodoc/proc/scan_user(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(analyzer, /obj/item.proc/attack, wearer, wearer, TRUE)

/**
	Proc to show the suit configuration page
*/
/datum/component/suit_autodoc/proc/configure(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/interact, wearer)

/**
	Shows the suit configuration
*/
/datum/component/suit_autodoc/interact(mob/user)
	var/dat = {"
	<A href='?src=[REF(src)];automed_on=1'>Turn Automed System: [enabled ? "Off" : "On"]</A><BR>
	<BR>
	<B>Integrated Health Analyzer:</B><BR>
	<A href='byond://?src=[REF(src)];analyzer=1'>Scan Wearer</A><BR>
	<BR>
	<B>Damage Trigger Threshold (Max [SUIT_AUTODOC_DAM_MAX], Min [SUIT_AUTODOC_DAM_MIN]):</B><BR>
	<A href='byond://?src=[REF(src)];automed_damage=-50'>-50</A>
	<A href='byond://?src=[REF(src)];automed_damage=-10'>-10</A>
	<A href='byond://?src=[REF(src)];automed_damage=-5'>-5</A>
	<A href='byond://?src=[REF(src)];automed_damage=-1'>-1</A> [damage_threshold]
	<A href='byond://?src=[REF(src)];automed_damage=1'>+1</A>
	<A href='byond://?src=[REF(src)];automed_damage=5'>+5</A>
	<A href='byond://?src=[REF(src)];automed_damage=10'>+10</A>
	<A href='byond://?src=[REF(src)];automed_damage=50'>+50</A><BR>
	<BR>
	<B>Pain Trigger Threshold (Max [SUIT_AUTODOC_DAM_MAX], Min [SUIT_AUTODOC_DAM_MIN]):</B><BR>
	<A href='byond://?src=[REF(src)];automed_pain=-50'>-50</A>
	<A href='byond://?src=[REF(src)];automed_pain=-10'>-10</A>
	<A href='byond://?src=[REF(src)];automed_pain=-5'>-5</A>
	<A href='byond://?src=[REF(src)];automed_pain=-1'>-1</A> [pain_threshold]
	<A href='byond://?src=[REF(src)];automed_pain=1'>+1</A>
	<A href='byond://?src=[REF(src)];automed_pain=5'>+5</A>
	<A href='byond://?src=[REF(src)];automed_pain=10'>+10</A>
	<A href='byond://?src=[REF(src)];automed_pain=50'>+50</A><BR>"}

	var/datum/browser/popup = new(user, "Suit Automedic")
	popup.set_content(dat)
	popup.open()

/**
	If the user is able to interact with the suit

	Always TRUE
*/
/datum/component/suit_autodoc/can_interact(mob/user)
	return TRUE

/**
	Handles the topic interactions with the suit when updating configurations
*/
/datum/component/suit_autodoc/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(wearer != usr)
		return

	if(href_list["automed_on"])
		action_toggle()

	else if(href_list["analyzer"]) //Integrated scanner
		analyzer.attack(wearer, wearer, TRUE)

	else if(href_list["automed_damage"])
		damage_threshold += text2num(href_list["automed_damage"])
		damage_threshold = round(damage_threshold)
		damage_threshold = clamp(damage_threshold,SUIT_AUTODOC_DAM_MIN,SUIT_AUTODOC_DAM_MAX)
	else if(href_list["automed_pain"])
		pain_threshold += text2num(href_list["automed_pain"])
		pain_threshold = round(pain_threshold)
		pain_threshold = clamp(pain_threshold,SUIT_AUTODOC_DAM_MIN,SUIT_AUTODOC_DAM_MAX)

	interact(wearer)

//// Action buttons
/datum/action/suit_autodoc
	action_icon = 'icons/mob/screen_alert.dmi'

/datum/action/suit_autodoc/New(target)
	..()
	if(visual_references[VREF_MUTABLE_LINKED_OBJ])
		button.cut_overlay(visual_references[VREF_MUTABLE_LINKED_OBJ])
		visual_references[VREF_MUTABLE_LINKED_OBJ] = null

/datum/action/suit_autodoc/can_use_action()
	if(QDELETED(owner) || owner.incapacitated() || owner.lying_angle)
		return FALSE
	return TRUE

/datum/action/suit_autodoc/toggle
	name = "Toggle Suit Automedic"
	action_icon_state = "suit_toggle"

/datum/action/suit_autodoc/scan
	name = "User Medical Scan"
	action_icon_state = "suit_scan"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_SUITANALYZER
	)

/datum/action/suit_autodoc/configure
	name = "Configure Suit Automedic"
	action_icon_state = "suit_configure"

#undef SUIT_AUTODOC_DAM_MAX
#undef SUIT_AUTODOC_DAM_MIN
#undef COOLDOWN_CHEM_BURN
#undef COOLDOWN_CHEM_OXY
#undef COOLDOWN_CHEM_BRUTE
#undef COOLDOWN_CHEM_TOX
#undef COOLDOWN_CHEM_PAIN
