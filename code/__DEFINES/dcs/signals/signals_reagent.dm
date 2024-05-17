// Atom reagent signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from base of [/datum/reagents/proc/add_reagent] - Sent before the reagent is added: (reagenttype, amount, reagtemp, data, no_react)
#define COMSIG_REAGENTS_PRE_ADD_REAGENT "reagents_pre_add_reagent"
	/// Prevents the reagent from being added.
	#define COMPONENT_CANCEL_REAGENT_ADD (1<<0)
///from base of [/datum/reagents/proc/add_reagent]: (/datum/reagent, amount, reagtemp, data, no_react)
#define COMSIG_REAGENTS_NEW_REAGENT "reagents_new_reagent"
///from base of [/datum/reagents/proc/add_reagent]: (/datum/reagent, amount, reagtemp, data, no_react)
#define COMSIG_REAGENTS_ADD_REAGENT "reagents_add_reagent"
///from base of [/datum/reagents/proc/del_reagent]: (/datum/reagent)
#define COMSIG_REAGENTS_DEL_REAGENT "reagents_del_reagent"
///from base of [/datum/reagents/proc/remove_reagent]: (/datum/reagent, amount)
#define COMSIG_REAGENTS_REM_REAGENT "reagents_rem_reagent"
///from base of [/datum/reagents/proc/clear_reagents]: ()
#define COMSIG_REAGENTS_CLEAR_REAGENTS "reagents_clear_reagents"

///from base of [/datum/component/personal_crafting/proc/del_reqs]: ()
#define COMSIG_REAGENTS_CRAFTING_PING "reagents_crafting_ping"
