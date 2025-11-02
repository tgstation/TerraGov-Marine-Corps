/datum/keybinding/xeno/larval_growth_sting
	name = "larval_growth_sting"
	full_name = "Larval Growth Sting"
	description = "Inject an impregnated host with growth serum, causing the larva inside to grow quicker. Has harmful effects for non-infected hosts while stabilizing larva-infected hosts."
	keybind_signal = COMSIG_XENOABILITY_LARVAL_GROWTH_STING

/datum/keybinding/xeno/tail_stab
	name = "tail_stab"
	full_name = "Tail Stab"
	description = "Allows the xeno to launch a 2 range attack with some armor piercing and bonus damage on grab or to structures."
	keybind_signal = COMSIG_XENOABILITY_TAIL_STAB
	hotkey_keys = list("ShiftE")

/datum/keybinding/xeno/psychic_radiance
	name = "psychic_radiance"
	full_name = "Psychic Radiance"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_RADIANCE

/datum/keybinding/xeno/impregnate
	name = "Impregnate"
	full_name = "Impregnate"
	description = "Infect an adjacent host with a larva without needing a hugger. This will burn them a bit due to acidic release."
	keybind_signal = COMSIG_XENOABILITY_IMPREGNATE

/datum/keybinding/xeno/dash_explosion
	name = "Dash Explosion"
	full_name = "Baneling: Dash Explode"
	description = "Aim in a direction, charge up and dash, knocking down any humans hit and detonate yourself. "
	keybind_signal = COMSIG_XENOABILITY_BANELING_DASH_EXPLOSION
	hotkey_keys = list("Q")

/datum/keybinding/xeno/spawn_pod
	name = "Spawn Pod"
	full_name = "Baneling: Spawn Pod"
	description = "Spawn a pod on your current position, when you die from any source you will respawn on this pod. Activate again to change its location. "
	keybind_signal = COMSIG_XENOABILITY_BANELING_SPAWN_POD
	hotkey_keys = list("F")

/datum/keybinding/xeno/baneling_explode
	name = "Explode"
	full_name = "Baneling: Explode"
	description = "Detonate yourself, spreading your currently selected reagent. Size depends on current stored plasma, more plasma is more reagent."
	keybind_signal = COMSIG_XENOABILITY_BANELING_EXPLODE
	hotkey_keys = list("E")

/datum/keybinding/xeno/select_reagent/baneling
	name = "Select Reagent"
	full_name = "Baneling: Select Reagent"
	description = "Choose a reagent that will be spread upon death. Costs plasma to change."
	keybind_signal = COMSIG_XENOABILITY_BANELING_CHOOSE_REAGENT
	hotkey_keys = list("C")

/datum/keybinding/xeno/long_range_sight
	name = "long_range_sight"
	full_name = "Boiler: Long Range Sight"
	description = "Toggles the zoom in."
	keybind_signal = COMSIG_XENOABILITY_LONG_RANGE_SIGHT
	hotkey_keys = list("E")

/datum/keybinding/xeno/create_edible_jelly
	name = "create_edible_jelly"
	full_name = "Create Edible Jelly"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_CREATE_EDIBLE_JELLY
	hotkey_keys = list("L")

/datum/keybinding/xeno/displacement
	name = "displacement"
	full_name = "Hunter: Displacement"
	description = "Change form to/from incorporeal."
	keybind_signal = COMSIG_XENOMORPH_HUNTER_DISPLACEMENT
	hotkey_keys = list("F")

/datum/keybinding/xeno/hunter_lunge
	name = "hunter_lunge"
	full_name = "Hunter: Lunge"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_HUNTER_LUNGE
	hotkey_keys = list("E")

/datum/keybinding/xeno/blink
	name = "wraith_blink"
	full_name = "Wraith: Blink"
	description = "Teleport to a space a short distance away within line of sight. Can teleport mobs you're dragging with you at the cost of higher cooldown."
	keybind_signal = COMSIG_XENOABILITY_BLINK
	hotkey_keys = list("Q")

/datum/keybinding/xeno/banish
	name = "banish"
	full_name = "Wraith: Banish"
	description = "Banish a creature or object a short distance away within line of sight to null space. Can target oneself and allies. Can be manually cancelled with Recall."
	keybind_signal = COMSIG_XENOABILITY_BANISH
	hotkey_keys = list("F")

/datum/keybinding/xeno/recall
	name = "recall"
	full_name = "Wraith: Recall"
	description = "Recall a target from netherspace, ending Banish's effect."
	keybind_signal = COMSIG_XENOABILITY_RECALL
	hotkey_keys = list("G")

/datum/keybinding/xeno/toggle_bump_attack_allies
	name = "Toggle Bump Attack Allies"
	full_name = "Toggle Bump Attack Allies"
	description = "Enable or disable the toggle: Toggle Bump Attack Allies."
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_BUMP_ATTACK_ALLIES

/datum/keybinding/xeno/toggle_bump_attack_allies/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/xenomorph/xeno_user = user.mob
	if(isxeno(xeno_user))
		xeno_user.toggle_bump_attack_allies()
		return TRUE

/datum/keybinding/xeno/toggle_destroy_own_structures
	name = "Toggle Destroy Own Structures"
	full_name = "Toggle Destroy Own Structures"
	description = "Enable or disable the toggle: Toggle Destroy Own Structures."
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_DESTROY_OWN_STRUCTURES

/datum/keybinding/xeno/toggle_destroy_own_structures/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/xenomorph/xeno_user = user.mob
	if(isxeno(xeno_user))
		xeno_user.toggle_destroy_own_structures()
		return TRUE

/datum/keybinding/xeno/toggle_destroy_weeds
	name = "Toggle Destroy Weeds"
	full_name = "Toggle Destroy Weeds"
	description = "Enable or disable the toggle: Toggle Destroy Weeds."
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_DESTROY_WEEDS

/datum/keybinding/xeno/toggle_destroy_weeds/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/xenomorph/xeno_user = user.mob
	if(isxeno(xeno_user))
		xeno_user.toggle_destroy_weeds()
		return TRUE
