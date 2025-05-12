GLOBAL_DATUM_INIT(mutation_selector, /datum/mutation_datum, new)

GLOBAL_LIST_INIT(shell_mutations, typecacheof(/datum/mutation_upgrade/shell))
GLOBAL_LIST_INIT(spur_mutations, typecacheof(/datum/mutation_upgrade/spur))
GLOBAL_LIST_INIT(veil_mutations, typecacheof(/datum/mutation_upgrade/veil))

#define is_shell_mutation(A) is_type_in_typecache(A, GLOB.shell_mutations)
#define is_spur_mutation(A) is_type_in_typecache(A, GLOB.spur_mutations)
#define is_veil_mutation(A) is_type_in_typecache(A, GLOB.veil_mutations)

/// The maximum amount of biomass a hive can have.
#define MUTATION_BIOMASS_MAXIMUM 1800

/// The amount of biomass gains or generated through certain actions.
#define MUTATION_BIOMASS_PER_PSYDRAIN 5
#define MUTATION_BIOMASS_PER_COCOON_COMPLETION 6
#define MUTATION_BIOMASS_PER_COCOON_TICK 0.1 // Biomass gained every five seconds (SSslowprocess).

/// The amount of strategic points needed to purchase a mutation building.
#define MUTATION_SHELL_CHAMBER_COST 400
#define MUTATION_SPUR_CHAMBER_COST 400
#define MUTATION_VEIL_CHAMBER_COST 400

/// The threshold requirement for obtaining an additional mutation; this should always be equal or less than a third of MUTATION_BIOMASS_MAXIMUM.
#define MUTATION_BIOMASS_THRESHOLD_T1 300
#define MUTATION_BIOMASS_THRESHOLD_T2 400
#define MUTATION_BIOMASS_THRESHOLD_T3 500
#define MUTATION_BIOMASS_THRESHOLD_T4 600

/// The type path for status effect alerts.
#define MUTATION_SHELL_ALERT /atom/movable/screen/alert/status_effect/shell
#define MUTATION_SPUR_ALERT /atom/movable/screen/alert/status_effect/spur
#define MUTATION_VEIL_ALERT /atom/movable/screen/alert/status_effect/veil

/// Name of each mutation structure.
#define MUTATION_STRUCTURE_SHELL "shell"
#define MUTATION_STRUCTURE_SPUR "spur"
#define MUTATION_STRUCTURE_VEIL "veil"

/// Name of each mutation category.
// TODO: Does this really need to be a seperate definition?
#define MUTATION_CATEGORY_SHELL "Shell"
#define MUTATION_CATEGORY_SPUR "Spur"
#define MUTATION_CATEGORY_VEIL "Veil"

/// List of status effects (non-stackable) that should be decreased/removed when an xenomorph ability says so.
GLOBAL_LIST_INIT(nonstackable_decreasable_debuffs_for_xenos, list(
	/datum/status_effect/shatter
))

/// List of status effects (stackable) that should be decreased/removed when an xenomorph ability says so.
GLOBAL_LIST_INIT(stackable_decreasable_debuffs_for_xenos, list(
	/datum/status_effect/stacking/microwave
))

/// Mutation trait.
#define MUTATION_TRAIT "mutation"

/// Movespeed IDs.
#define MOVESPEED_ID_MUTATION_SLOW_AND_STEADY "MUTATION_SLOW_AND_STEADY"

/// Sunder signal
#define COMSIG_XENOMORPH_SUNDER_CHANGE "xenomorph_sunder_change" // (old, new)
