// ***************************************
// *********** Baneling Explode
// ***************************************
/datum/action/xeno_action/baneling_explode
	name = "Baneling Explode"
	action_icon_state = "baneling_explode"
	desc = ""
	ability_name = "baneling explode"
	keybinding_signals = list(
	KEYBINDING_NORMAL = COMSIG_XENOABILITY_BANELING_EXPLODE,
	)

// ***************************************
// *********** Spawn Pod
// ***************************************
/datum/action/xeno_action/spawn_pod
	name = "Spawn pod"
	action_icon_state = "baneling_explode"
	desc = ""
	ability_name = "baneling explode"


/datum/action/xeno_action/spawn_pod/action_activate()
	. = ..()
	var/mob/living/carbon/xenomorph/baneling/X = owner
	if(isnull(X.pod_ref))
		X.pod_ref = new /obj/structure/xeno/baneling_pod(owner.loc, owner)
		return
	var/obj/structure/xeno/baneling_pod/pod = X.pod_ref
	pod.loc = X.loc
