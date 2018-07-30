
//the datum that stores specific statistics from the current round.
//not to be confused with the round_stats var which is stores logs like round starting or ending.

var/datum/round_statistics/round_statistics = new()

/datum/round_statistics
	var/total_projectiles_fired = 0
	var/total_bullets_fired = 0
	var/total_xeno_deaths = 0
	var/total_human_deaths = 0
	var/total_xenos_created = 0
	var/total_humans_created = 0
	var/total_bullet_hits_on_humans = 0
	var/total_bullet_hits_on_xenos = 0
	var/total_larva_burst = 0
	var/carrier_traps = 0
	var/boiler_acid_smokes = 0
	var/boiler_neuro_smokes = 0
	var/crusher_stomps = 0
	var/crusher_stomp_victims = 0
	var/praetorian_acid_sprays = 0
	var/praetorian_spray_direct_hits = 0
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