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
GLOBAL_LIST_INIT(hugger_images_list,  list(
		BANELING_NEUROTOXIN = image('icons/mob/actions.dmi', icon_state = DEFILER_NEUROTOXIN),
		BANELING_HEMODILE = image('icons/mob/actions.dmi', icon_state = DEFILER_HEMODILE),
		BANELING_TRANSVITOX = image('icons/mob/actions.dmi', icon_state = DEFILER_TRANSVITOX),
		BANELING_OZELOMELYN = image('icons/mob/actions.dmi', icon_state = DEFILER_OZEMOLYN),
		BANELING_ACID = image('icons/mob/actions.dmi', icon_state = SPRAY_ACID),
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
	var/datum/effect_system/smoke_spread/xeno/baneling_smoke
	keybinding_signals = list(
	KEYBINDING_NORMAL = COMSIG_XENOABILITY_BANELING_EXPLODE,
	)

/datum/action/xeno_action/baneling_explode/action_activate()
	. = ..()

/datum/action/xeno_action/baneling_explode/proc/handle_smoke(remaining_time)
	var/mob/living/carbon/xenomorph/baneling/X = owner
	var/turf/T = get_turf(X)
	switch(X.baneling_current_chemical)
		if(/datum/reagent/toxin/xeno_neurotoxin)
			smoke = new /datum/effect_system/smoke_spread/xeno/neuro(T)
		if(/datum/reagent/toxin/xeno_hemodile)
			smoke = new /datum/effect_system/smoke_spread/xeno/hemodile(T)
		if(/datum/reagent/toxin/xeno_transvitox)
			smoke = new /datum/effect_system/smoke_spread/xeno/transvitox(T)
		if(/datum/reagent/toxin/xeno_ozelomelyn)
			smoke = new /datum/effect_system/smoke_spread/xeno/ozelomelyn(T)
		if(/datum/reagent/toxin/acid)
			smoke = new/datum/effect_system/smoke_spread/xeno/acid(T)
	playsound(T, 'sound/effects/blobattack.ogg', 25)
	smoke.set_up(smoke_range, T)
	handle_smoke(smoke_duration)
	if(remaining_time <= 0)
		return
	smoke.start()
	addtimer(CALLBACK(src, PROC_REF(handle_smoke), remaining_time - 1), 1 SECONDS)

// ***************************************
// *********** Reagent Selection
// ***************************************

/datum/action/xeno_action/baneling_reagent
	name = "Choose Explosion Reagent"
	action_icon_state = ""
	desc = "Selects which hugger type you will build with the Spawn Hugger ability."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CHOOSE_HUGGER,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_SWITCH_HUGGER,
	)
	use_state_flags = XACT_USE_BUSY|XACT_USE_LYING

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
