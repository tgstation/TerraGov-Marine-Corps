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
