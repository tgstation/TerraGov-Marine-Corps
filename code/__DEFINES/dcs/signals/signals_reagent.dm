// Atom reagent signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from base of [/datum/reagents/proc/add_reagent] - Sent before the reagent is added: (reagenttype, amount, reagtemp, data, no_react)
#define COMSIG_REAGENTS_PRE_ADD_REAGENT "reagents_pre_add_reagent"
	/// Prevents the reagent from being added.
	#define COMPONENT_CANCEL_REAGENT_ADD (1<<0)
///from base of [/datum/reagents/proc/add_reagent]: (reagent_type, amount, reagtemp, data, no_react)
#define COMSIG_REAGENTS_NEW_REAGENT "reagents_new_reagent"
///from base of [/datum/reagents/proc/add_reagent]: (reagent_type, amount, reagtemp, data, no_react)
#define COMSIG_REAGENTS_ADD_REAGENT "reagents_add_reagent"
///from base of [/datum/reagents/proc/del_reagent]: (reagent_type)
#define COMSIG_REAGENTS_DEL_REAGENT "reagents_del_reagent"
///from base of [/datum/reagents/proc/remove_reagent]: (reagent_type, amount)
#define COMSIG_REAGENTS_REM_REAGENT "reagents_rem_reagent"
///from base of [/datum/reagents/proc/clear_reagents]: ()
#define COMSIG_REAGENTS_CLEAR_REAGENTS "reagents_clear_reagents"

///from base of [/datum/component/personal_crafting/proc/del_reqs]: ()
#define COMSIG_REAGENTS_CRAFTING_PING "reagents_crafting_ping"
/// sent when reagents are transfered from a cup, to something refillable (atom/transfer_to)
#define COMSIG_REAGENTS_CUP_TRANSFER_TO "reagents_cup_transfer_to"
/// sent when reagents are transfered from some reagent container, to a cup (atom/transfer_from)
#define COMSIG_REAGENTS_CUP_TRANSFER_FROM "reagents_cup_transfer_from"

// Atom reagent signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from base of atom/expose_reagents(): (/list, /datum/reagents, methods, volume_modifier, show_message)
#define COMSIG_ATOM_EXPOSE_REAGENTS "atom_expose_reagents"
	/// Prevents the atom from being exposed to reagents if returned on [COMSIG_ATOM_EXPOSE_REAGENTS]
	#define COMPONENT_NO_EXPOSE_REAGENTS (1<<0)
///from base of atom/expose_reagents(): (/list, /datum/reagents, methods, volume_modifier, show_message)
#define COMSIG_ATOM_AFTER_EXPOSE_REAGENTS "atom_after_expose_reagents"
///from base of [/datum/reagent/proc/expose_atom]: (/datum/reagent, reac_volume)
#define COMSIG_ATOM_EXPOSE_REAGENT "atom_expose_reagent"
///from base of [/datum/reagent/proc/expose_atom]: (/atom, reac_volume)
#define COMSIG_REAGENT_EXPOSE_ATOM "reagent_expose_atom"
///from base of [/datum/reagent/proc/expose_atom]: (/obj, reac_volume)
#define COMSIG_REAGENT_EXPOSE_OBJ "reagent_expose_obj"
///from base of [/datum/reagent/proc/expose_atom]: (/mob/living, reac_volume, methods, show_message, touch_protection, /mob/camera/blob) // ovemind arg is only used by blob reagents.
#define COMSIG_REAGENT_EXPOSE_MOB "reagent_expose_mob"
///from base of [/datum/reagent/proc/expose_atom]: (/turf, reac_volume)
#define COMSIG_REAGENT_EXPOSE_TURF "reagent_expose_turf"
