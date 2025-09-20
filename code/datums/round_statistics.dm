
//the datum that stores specific statistics from the current round.

/*
To add new statistics, include "var/the_thing_to_count = 0" in the list below indented accordingly.

Then, in the file where the thing you want to count happens, include "round_statistics.the_thing_to_count++"

to use said count anywhere else include round_statistics.the_thing_to_count in your code.
add [] around this to use it in text.
*/

GLOBAL_DATUM_INIT(round_statistics, /datum/round_statistics, new)

/datum/round_statistics
	///All projectiles fired during the round, listed by faction
	var/list/total_projectiles_fired = list()
	var/human_bump_attacks = 0
	var/points_from_objectives = 0
	var/points_from_research = 0
	var/points_from_mining = 0
	var/points_from_xenos = 0
	var/total_xeno_deaths = 0
	///All human deaths during the round, listed by faction
	var/list/total_human_deaths = list()
	///All human revives during the round, listed by faction
	var/list/total_human_revives = list()
	var/total_human_respawns = 0
	var/total_xenos_created = 0
	///All humans created during the round, listed by faction. Occurs at job spawn to capture faction
	var/list/total_humans_created = list()
	///All projectiles hit during the round, listed by faction
	var/list/total_projectile_hits = list()
	var/total_bullet_hits_on_marines = 0
	var/total_bullet_hits_on_xenos = 0
	var/workout_counts = list()
	///Xeno Stats
	var/acid_maw_fires = 0
	var/acid_jaw_fires = 0
	var/all_acid_applied = 0 // Acid applied to walls, items, etc. Seperate from the personal tracking.
	var/behemoth_rock_victims = 0
	var/boiler_acid_smokes = 0
	var/boiler_neuro_smokes = 0
	var/bull_crush_hit = 0
	var/bull_gore_hit = 0
	var/bull_headbutt_hit = 0
	var/crusher_stomps = 0
	var/crusher_stomp_victims = 0
	var/defender_charges = 0
	var/defender_charge_victims = 0
	var/defender_headbutts = 0
	var/defender_tail_sweeps = 0
	var/defender_tail_sweep_hits = 0
	var/defender_crest_lowerings = 0
	var/defender_crest_raises = 0 //manual disabling of the crest
	var/defender_fortifiy_toggles = 0
	var/defiler_defiler_stings = 0
	var/defiler_neurogas_uses = 0
	var/defiler_inject_egg_neurogas = 0
	var/defiler_reagent_slashes = 0
	var/globadier_grenades_thrown = 0
	var/globadier_mines_placed = 0
	var/globadier_XADAR_fired = 0
	var/hunter_marks = 0
	var/hunter_silence_targets = 0
	var/hunter_cloaks = 0
	var/hunter_cloak_victims = 0
	var/larva_from_marine_spawning = 0
	var/larva_from_silo = 0
	var/larva_from_cocoon = 0
	var/larva_from_psydrain = 0
	var/larva_from_siloing_body = 0
	var/melter_acid_shrouds = 0
	var/melter_acidic_missiles = 0
	var/now_pregnant = 0
	var/ozelomelyn_stings = 0
	var/praetorian_acid_sprays = 0
	var/praetorian_spray_direct_hits = 0
	var/psychic_flings = 0
	var/psychic_cures = 0
	var/psy_crushes = 0
	var/psy_blasts = 0
	var/psy_lances = 0
	var/psy_shields = 0
	var/psy_shield_blasts = 0
	var/transfusion_overheal = 0
	var/pyrogen_fireballs = 0
	var/pyrogen_firestorms = 0
	var/pyrogen_infernos
	var/queen_screech = 0
	var/runner_savage_attacks = 0
	var/runner_pounce_victims = 0
	var/runner_evasions = 0
	var/runner_items_stolen = 0
	var/ravager_endures = 0
	var/ravager_rages = 0
	var/sentinel_drain_stings = 0
	var/sentinel_neurotoxin_stings = 0
	var/spitter_acid_sprays = 0
	var/spitter_scatter_spits = 0
	var/total_larva_burst = 0
	var/trap_holes = 0
	/// The amount of health points restored via Acidic Salve.
	var/drone_acidic_salve = 0
	/// The amount of sunder removed via Acidic Salve.
	var/drone_acidic_salve_sunder = 0
	/// The amount of health points restored via the Essence Link status effect and Salve Regen status effect.
	var/drone_essence_link = 0
	/// The amount of sunder removed via Essence Link status effect and Salve Regen status effect.
	var/drone_essence_link_sunder = 0
	var/warrior_flings = 0
	var/warrior_punches = 0
	var/warrior_lunges = 0
	var/warrior_agility_toggles = 0
	var/warrior_grabs = 0
	var/hivelord_healing_infusions = 0
	var/weeds_planted = 0
	var/weeds_destroyed = 0
	var/wraith_phase_shifts = 0
	var/xeno_acid_wells = 0
	var/xeno_unarmed_attacks = 0
	var/xeno_bump_attacks = 0
	var/xeno_rally_hive = 0
	///Human Stats
	var/grenades_thrown = 0
	var/mortar_shells_fired = 0
	var/howitzer_shells_fired = 0
	var/rocket_shells_fired = 0
	var/obs_fired = 0
	var/sandevistan_uses = 0
	var/sandevistan_gibs = 0
	var/req_items_produced = list()
