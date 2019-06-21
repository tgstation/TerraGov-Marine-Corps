
//the datum that stores specific statistics from the current round.

/*
To add new statistics, include "var/the_thing_to_count = 0" in the list below indented accordingly.

Then, in the file where the thing you want to count happens, include "round_statistics.the_thing_to_count++"

to use said count anywhere else include round_statistics.the_thing_to_count in your code.
add [] around this to use it in text.
*/

GLOBAL_DATUM_INIT(round_statistics, /datum/round_statistics, new)

/datum/round_statistics
	var/total_projectiles_fired = 0
	var/total_bullets_fired = 0
	var/total_xeno_deaths = 0
	var/total_human_deaths = 0
	var/total_xenos_created = 0
	var/total_humans_created = 0
	var/total_bullet_hits_on_humans = 0
	var/total_bullet_hits_on_marines = 0
	var/total_bullet_hits_on_xenos = 0
	var/total_larva_burst = 0
	var/carrier_traps = 0
	var/boiler_acid_smokes = 0
	var/boiler_neuro_smokes = 0
	var/crusher_stomps = 0
	var/crusher_stomp_victims = 0
	var/praetorian_acid_sprays = 0
	var/praetorian_spray_direct_hits = 0
	var/psychic_flings = 0
	var/psychic_chokes = 0
	var/psychic_cures = 0
	var/warrior_flings = 0
	var/warrior_punches = 0
	var/warrior_lunges = 0
	var/warrior_limb_rips = 0
	var/warrior_agility_toggles = 0
	var/warrior_grabs = 0
	var/defender_headbutts = 0
	var/defender_tail_sweeps = 0
	var/defender_tail_sweep_hits = 0
	var/defender_crest_lowerings = 0
	var/defender_crest_raises = 0 //manual disabling of the crest
	var/defender_fortifiy_toggles = 0
	var/runner_savage_attacks = 0
	var/ravager_ravages = 0
	var/ravager_ravage_victims = 0
	var/ravager_second_winds = 0
	var/weeds_planted = 0
	var/weeds_destroyed = 0
	var/grenades_thrown = 0
	var/queen_screech = 0
	var/now_pregnant = 0
	var/sentinel_neurotoxin_stings = 0
	var/defiler_defiler_stings = 0
	var/defiler_neurogas_uses = 0
	var/larval_growth_stings = 0
	var/drone_salvage_plasma = 0
