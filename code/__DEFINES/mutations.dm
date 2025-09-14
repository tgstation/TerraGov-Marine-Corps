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

// The amount of strategic points needed to purchase a mutation building.
#define MUTATION_SHELL_CHAMBER_COST 400
#define MUTATION_SPUR_CHAMBER_COST 400
#define MUTATION_VEIL_CHAMBER_COST 400

/// The threshold requirement for obtaining an additional mutation.
#define MUTATION_BIOMASS_THRESHOLD_T1 300
#define MUTATION_BIOMASS_THRESHOLD_T2 400
#define MUTATION_BIOMASS_THRESHOLD_T3 500
#define MUTATION_BIOMASS_THRESHOLD_T4 600

#define MUTATION_SHELL_ALERT /atom/movable/screen/alert/shell
#define MUTATION_SPUR_ALERT /atom/movable/screen/alert/spur
#define MUTATION_VEIL_ALERT /atom/movable/screen/alert/veil

/// Name of each mutation structure/category.
#define MUTATION_SHELL "shell"
#define MUTATION_SPUR "spur"
#define MUTATION_VEIL "veil"

/// The minimum and maximum of chambers that can exist.
#define MUTATION_CHAMBER_MINIMUM 0
#define MUTATION_CHAMBER_MAXIMUM 3
