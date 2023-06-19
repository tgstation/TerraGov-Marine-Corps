//Baneling reagent defines
#define BANELING_NEUROTOXIN "Neurotoxin"
#define BANELING_HEMODILE "Hemodile"
#define BANELING_TRANSVITOX "Transvitox"
#define BANELING_OZELOMELYN "Ozelomelyn"
#define BANELING_ACID "Acid"

//List of baneling reagents
GLOBAL_LIST_INIT(baneling_reagent_type_list, list(
		/datum/effect_system/smoke_spread/xeno/ozelomelyn,
		/datum/effect_system/smoke_spread/xeno/hemodile,
		/datum/effect_system/smoke_spread/xeno/transvitox,
		/datum/effect_system/smoke_spread/xeno/neuro,
		/datum/effect_system/smoke_spread/xeno/acid,
		))

//List of baneling reagent images
GLOBAL_LIST_INIT(reagent_images_list,  list(
		BANELING_NEUROTOXIN = image('icons/mob/actions.dmi', icon_state = DEFILER_NEUROTOXIN),
		BANELING_HEMODILE = image('icons/mob/actions.dmi', icon_state = DEFILER_HEMODILE),
		BANELING_TRANSVITOX = image('icons/mob/actions.dmi', icon_state = DEFILER_TRANSVITOX),
		BANELING_OZELOMELYN = image('icons/mob/actions.dmi', icon_state = DEFILER_OZELOMELYN),
		BANELING_ACID = image('icons/mob/actions.dmi', icon_state = "spray_acid"),
		))

// ***************************************
// *********** Baneling Explode
// ***************************************
/datum/action/xeno_action/baneling_explode
	name = "Baneling Explode"
	action_icon_state = "baneling_explode"
	desc = ""
	ability_name = "baneling explode"
	/// The range of our smoke when we explode
	var/smoke_range = 4
	/// How long the smoke lasts for
	var/smoke_duration = 4
	var/datum/effect_system/smoke_spread/xeno/smoke
	keybinding_signals = list(
	KEYBINDING_NORMAL = COMSIG_XENOABILITY_BANELING_EXPLODE,
	)

/datum/action/xeno_action/baneling_explode/action_activate()
	. = ..()
	handle_smoke(smoke_duration)
	var/turf/T = get_turf(owner)
	playsound(T, 'sound/effects/blobattack.ogg', 25)

/datum/action/xeno_action/baneling_explode/proc/handle_smoke(remaining_time)
	var/mob/living/carbon/xenomorph/baneling/X = owner
	var/turf/T = get_turf(X)
	smoke = new X.selected_chemical(T)

	smoke.set_up(smoke_range, T)
	if(remaining_time <= 0)
		return
	smoke.start()
	addtimer(CALLBACK(src, PROC_REF(handle_smoke), remaining_time - 1), 1 SECONDS)

// ***************************************
// *********** Reagent Selection
// ***************************************

/datum/action/xeno_action/choose_baneling_reagent
	name = "Choose Explosion Reagent"
	action_icon_state = ""
	desc = ""
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BANELING_CHOOSE_REAGENT,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_BANELING_SWITCH_REAGENT,
	)
	use_state_flags = XACT_USE_BUSY|XACT_USE_LYING

/datum/action/xeno_action/choose_baneling_reagent/give_action(mob/living/L)
	. = ..()
	var/mob/living/carbon/xenomorph/caster = owner
	caster.selected_chemical = GLOB.baneling_reagent_type_list[1] //Set our default
	update_button_icon() //Update immediately to get our default

/datum/action/xeno_action/choose_baneling_reagent/update_button_icon()
	var/mob/living/carbon/xenomorph/caster = owner
	var/atom/A = caster.selected_chemical
	action_icon_state = initial(A.name)
	return ..()

/datum/action/xeno_action/choose_baneling_reagent/alternate_action_activate()
	var/mob/living/carbon/xenomorph/caster = owner
	var/i = GLOB.baneling_reagent_type_list.Find(caster.selected_chemical)
	if(length(GLOB.baneling_reagent_type_list) == i)
		caster.selected_chemical = GLOB.baneling_reagent_type_list[1]
	else
		caster.selected_chemical = GLOB.baneling_reagent_type_list[i+1]

	var/atom/A = caster.selected_chemical
	to_chat(caster, span_notice("We will now spread <b>[initial(A.name)]\s</b> when we explode"))
	caster.balloon_alert(caster,"[initial(A.name)]")
	update_button_icon()
	succeed_activate()
	return COMSIG_KB_ACTIVATED

/datum/action/xeno_action/choose_baneling_reagent/action_activate()
	var/reagent_choice = show_radial_menu(owner, owner, GLOB.reagent_images_list, radius = 48)
	if(!reagent_choice)
		return
	var/mob/living/carbon/xenomorph/caster = owner
	for(var/datum/effect_system/smoke_spread/reagent_type AS in GLOB.baneling_reagent_type_list)
		if(initial(reagent_type.name) == reagent_choice)
			caster.selected_chemical = reagent_type
			break
	to_chat(caster, span_notice("We will now spread <b>[reagent_choice]\s</b> when we explode"))
	caster.balloon_alert(caster, "[reagent_choice]")
	update_button_icon()
	return succeed_activate()

// ***************************************
// *********** Spawn Pod
// ***************************************
/datum/action/xeno_action/spawn_pod
	name = "Spawn pod"
	action_icon_state = "spawn_pod"
	desc = ""
	ability_name = "spawn pod"
	keybinding_signals = list(
	KEYBINDING_NORMAL = COMSIG_XENOABILITY_BANELING_SPAWN_POD,
	)

/datum/action/xeno_action/spawn_pod/action_activate()
	. = ..()
	var/mob/living/carbon/xenomorph/baneling/X = owner
	if(isnull(X.pod_ref))
		X.pod_ref = new /obj/structure/xeno/baneling_pod(owner.loc, owner)
		return
	var/obj/structure/xeno/baneling_pod/pod = X.pod_ref
	pod.loc = X.loc
