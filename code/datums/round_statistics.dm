
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