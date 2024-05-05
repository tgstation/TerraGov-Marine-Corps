// Atom reagent signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from base of [/datum/component/personal_crafting/proc/del_reqs]: ()
#define COMSIG_REAGENTS_CRAFTING_PING "reagents_crafting_ping"
/// sent when reagents are transfered from a cup, to something refillable (atom/transfer_to)
#define COMSIG_REAGENTS_CUP_TRANSFER_TO "reagents_cup_transfer_to"
/// sent when reagents are transfered from some reagent container, to a cup (atom/transfer_from)
#define COMSIG_REAGENTS_CUP_TRANSFER_FROM "reagents_cup_transfer_from"
