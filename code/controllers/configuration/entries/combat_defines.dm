/*
These defines may be a terrible idea, but for the time being are a necessary evil.
*/

/datum/config_entry/number/combat_define
	integer = FALSE


/*
Projectile damage multiplier, projectile accuracy multiplier.
Global settings for projectile damage and accuracy multiplication. Can increase or decrease it based on these numbers.
This can be changed in the game, and is based off 1 instead of .01. It's just multiplied by .01 after the number is changed.
So, 0.95 is less than 1.05. The latter will result in more damage/accuracy, the former in less.
*/
/datum/config_entry/number/combat_define/proj_base_accuracy_mult
	config_entry_value = 0.01

/datum/config_entry/number/combat_define/proj_base_damage_mult
	config_entry_value = 0.01

/*
Projectile variance.
Global settings for projectile variance for damage and accuracy. This is the base other variance is added to.
*/
/datum/config_entry/number/combat_define/proj_variance_high
	config_entry_value = 105

/datum/config_entry/number/combat_define/proj_variance_low
	config_entry_value = 95

/*
Critical hit.
These are the boundaries of a critical hit.
*/
/datum/config_entry/number/combat_define/critical_chance_low
	config_entry_value = 5

/datum/config_entry/number/combat_define/critical_chance_high
	config_entry_value = 10

/*
Base armor resist.
These are the multiples * after soaking damage. Low is the initial one used after soaking damage,
high is the derived one after soaking damage again.
*/
/datum/config_entry/number/combat_define/base_armor_resist_low
	config_entry_value = 1.0

/datum/config_entry/number/combat_define/base_armor_resist_high
	config_entry_value = 2.0

/*
Xeno armor resist.
Xenos use this as a boundary for soaking damage or adding more armor.
*/
/datum/config_entry/number/combat_define/xeno_armor_resist_vlow
	config_entry_value = 0.25

/datum/config_entry/number/combat_define/xeno_armor_resist_low
	config_entry_value = 0.5

/datum/config_entry/number/combat_define/xeno_armor_resist_lmed
	config_entry_value = 0.75

/*
Xenos use this as the upper boundary for deflecting damage on their second pass.
*/
/datum/config_entry/number/combat_define/xeno_armor_resist_high
	config_entry_value = 1.5

/*
Accuracy.
*/
/datum/config_entry/number/combat_define/min_hit_accuracy
	config_entry_value = 5

/datum/config_entry/number/combat_define/low_hit_accuracy
	config_entry_value = 10

/datum/config_entry/number/combat_define/med_hit_accuracy
	config_entry_value = 15

/datum/config_entry/number/combat_define/hmed_hit_accuracy
	config_entry_value = 20

/datum/config_entry/number/combat_define/high_hit_accuracy
	config_entry_value = 30

/datum/config_entry/number/combat_define/max_hit_accuracy
	config_entry_value = 40

/*
Accuracy multiplier.
*/
/datum/config_entry/number/combat_define/base_hit_accuracy_mult
	config_entry_value = 1

/datum/config_entry/number/combat_define/min_hit_accuracy_mult
	config_entry_value = 0.05

/datum/config_entry/number/combat_define/mlow_hit_accuracy_mult
	config_entry_value = 0.10

/datum/config_entry/number/combat_define/low_hit_accuracy_mult
	config_entry_value = 0.15

/datum/config_entry/number/combat_define/med_hit_accuracy_mult
	config_entry_value = 0.20

/datum/config_entry/number/combat_define/hmed_hit_accuracy_mult
	config_entry_value = 0.30

/datum/config_entry/number/combat_define/high_hit_accuracy_mult
	config_entry_value = 0.40

/datum/config_entry/number/combat_define/max_hit_accuracy_mult
	config_entry_value = 0.50


/*
Damage.
Damage of the projectile, though the gun itself can modify it. This is the main source of projectile damage.
*/
/datum/config_entry/number/combat_define/base_hit_damage
	config_entry_value = 10

/datum/config_entry/number/combat_define/min_hit_damage
	config_entry_value = 15

/datum/config_entry/number/combat_define/llow_hit_damage
	config_entry_value = 20

/datum/config_entry/number/combat_define/mlow_hit_damage
	config_entry_value = 25

/datum/config_entry/number/combat_define/low_hit_damage
	config_entry_value = 30

/datum/config_entry/number/combat_define/hlow_hit_damage
	config_entry_value = 35

/datum/config_entry/number/combat_define/lmed_hit_damage
	config_entry_value = 40

/datum/config_entry/number/combat_define/lmmed_hit_damage
	config_entry_value = 45

/datum/config_entry/number/combat_define/med_hit_damage
	config_entry_value = 50

/datum/config_entry/number/combat_define/hmed_hit_damage
	config_entry_value = 55

/datum/config_entry/number/combat_define/high_hit_damage
	config_entry_value = 70

/datum/config_entry/number/combat_define/mhigh_hit_damage
	config_entry_value = 80

/datum/config_entry/number/combat_define/max_hit_damage
	config_entry_value = 90

/datum/config_entry/number/combat_define/super_hit_damage
	config_entry_value = 120

/datum/config_entry/number/combat_define/ultra_hit_damage
	config_entry_value = 150

/datum/config_entry/number/combat_define/aprocket_hit_damage
	config_entry_value = 250

/datum/config_entry/number/combat_define/ltb_hit_damage
	config_entry_value = 300

/*
Damage multiplier.
*/
/datum/config_entry/number/combat_define/base_hit_damage_mult
	config_entry_value = 1

/datum/config_entry/number/combat_define/min_hit_damage_mult
	config_entry_value = 0.05

/datum/config_entry/number/combat_define/low_hit_damage_mult
	config_entry_value = 0.10

/datum/config_entry/number/combat_define/med_hit_damage_mult
	config_entry_value = 0.20

/datum/config_entry/number/combat_define/tacshottie_damage_mult
	config_entry_value = 0.25

/datum/config_entry/number/combat_define/hmed_hit_damage_mult
	config_entry_value = 0.30

/datum/config_entry/number/combat_define/high_hit_damage_mult
	config_entry_value = 0.40

/datum/config_entry/number/combat_define/max_hit_damage_mult
	config_entry_value = 0.50


/*
Damage falloff.
How much damage the projectile loses per turf traveled.
*/
/datum/config_entry/number/combat_define/reg_damage_falloff
	config_entry_value = 1

/datum/config_entry/number/combat_define/smg_damage_falloff
	config_entry_value = 1.5

/datum/config_entry/number/combat_define/buckshot_damage_falloff
	config_entry_value = 5

/datum/config_entry/number/combat_define/extra_damage_falloff
	config_entry_value = 20

/*
Damage falloff multiplier.
*/
/datum/config_entry/number/combat_define/base_damage_falloff_mult
	config_entry_value = 1

/datum/config_entry/number/combat_define/min_damage_falloff_mult
	config_entry_value = 0.1

/datum/config_entry/number/combat_define/low_damage_falloff_mult
	config_entry_value = 0.25

/datum/config_entry/number/combat_define/lmed_damage_falloff_mult
	config_entry_value = 0.4

/datum/config_entry/number/combat_define/med_damage_falloff_mult
	config_entry_value = 0.5

/datum/config_entry/number/combat_define/hmed_damage_falloff_mult
	config_entry_value = 0.75

/datum/config_entry/number/combat_define/high_damage_falloff_mult
	config_entry_value = 1.5

/datum/config_entry/number/combat_define/max_damage_falloff_mult
	config_entry_value = 2

/*
Burst fire.
How many shots the weapon shoots each burst. Should be set to 1 if the gun doesn't burst at all.
*/
/datum/config_entry/number/combat_define/min_burst_value
	config_entry_value = 1

/datum/config_entry/number/combat_define/low_burst_value
	config_entry_value = 2

/datum/config_entry/number/combat_define/med_burst_value
	config_entry_value = 3

/datum/config_entry/number/combat_define/high_burst_value
	config_entry_value = 4

/datum/config_entry/number/combat_define/mhigh_burst_value
	config_entry_value = 5

/datum/config_entry/number/combat_define/max_burst_value
	config_entry_value = 6

/datum/config_entry/number/combat_define/minigun_burst_value
	config_entry_value = 10

/*
Fire delay.
Ticks before the weapon can be fired again. Should be 6 for regular delay and 2 for burst delay.
*/
/datum/config_entry/number/combat_define/no_fire_delay
	config_entry_value = 0.1

/datum/config_entry/number/combat_define/min_fire_delay
	config_entry_value = 1

/datum/config_entry/number/combat_define/vlow_fire_delay
	config_entry_value = 1.5

/datum/config_entry/number/combat_define/mlow_fire_delay
	config_entry_value = 2

/datum/config_entry/number/combat_define/low_fire_delay
	config_entry_value = 3

/datum/config_entry/number/combat_define/med_fire_delay
	config_entry_value = 4

/datum/config_entry/number/combat_define/high_fire_delay
	config_entry_value = 5

/datum/config_entry/number/combat_define/mhigh_fire_delay
	config_entry_value = 6

/datum/config_entry/number/combat_define/max_fire_delay
	config_entry_value = 7

/datum/config_entry/number/combat_define/tacshottie_fire_delay
	config_entry_value = 15

/datum/config_entry/number/combat_define/scoutshottie_fire_delay
	config_entry_value = 20


/*
Scatter.
% chance of scattering the projectile, added to the gun scatter chance when fired. Only affects guns.
*/
/datum/config_entry/number/combat_define/min_scatter_value
	config_entry_value = 5

/datum/config_entry/number/combat_define/mlow_scatter_value
	config_entry_value = 10

/datum/config_entry/number/combat_define/low_scatter_value
	config_entry_value = 15

/datum/config_entry/number/combat_define/med_scatter_value
	config_entry_value = 20

/datum/config_entry/number/combat_define/high_scatter_value
	config_entry_value = 25

/datum/config_entry/number/combat_define/thirty_scatter_value
	config_entry_value = 30

/datum/config_entry/number/combat_define/mhigh_scatter_value
	config_entry_value = 35

/datum/config_entry/number/combat_define/max_scatter_value
	config_entry_value = 40

/*
Recoil.
Amount of screen shake. Anything above 2 is really crazy recoil.
*/
/datum/config_entry/number/combat_define/min_recoil_value
	config_entry_value = 1

/datum/config_entry/number/combat_define/low_recoil_value
	config_entry_value = 2

/datum/config_entry/number/combat_define/med_recoil_value
	config_entry_value = 3

/datum/config_entry/number/combat_define/high_recoil_value
	config_entry_value = 4

/datum/config_entry/number/combat_define/max_recoil_value
	config_entry_value = 5

/*
Shrapnel.
% chance of imbedding shrapnel in the target.
*/
/datum/config_entry/number/combat_define/min_shrapnel_chance
	config_entry_value = 5

/datum/config_entry/number/combat_define/low_shrapnel_chance
	config_entry_value = 10

/datum/config_entry/number/combat_define/mlow_shrapnel_chance
	config_entry_value = 20

/datum/config_entry/number/combat_define/med_shrapnel_chance
	config_entry_value = 25

/datum/config_entry/number/combat_define/high_shrapnel_chance
	config_entry_value = 45

/datum/config_entry/number/combat_define/max_shrapnel_chance
	config_entry_value = 75

/*
Range.
Number of tiles.
*/
/datum/config_entry/number/combat_define/min_shell_range
	config_entry_value = 3

/datum/config_entry/number/combat_define/close_shell_range
	config_entry_value = 5

/datum/config_entry/number/combat_define/screen_shell_range
	config_entry_value = 7

/datum/config_entry/number/combat_define/near_shell_range
	config_entry_value = 10

/datum/config_entry/number/combat_define/short_shell_range
	config_entry_value = 15

/datum/config_entry/number/combat_define/norm_shell_range
	config_entry_value = 20

/datum/config_entry/number/combat_define/lnorm_shell_range
	config_entry_value = 25

/datum/config_entry/number/combat_define/long_shell_range
	config_entry_value = 30

/datum/config_entry/number/combat_define/vlong_shell_range
	config_entry_value = 35

/datum/config_entry/number/combat_define/max_shell_range
	config_entry_value = 40

/*
Speed.
How quick the projectile travels, or more accurately how many turfs per sleep(1) it travels.
*/
/datum/config_entry/number/combat_define/min_shell_speed
	config_entry_value = 1

/datum/config_entry/number/combat_define/slow_shell_speed
	config_entry_value = 2

/datum/config_entry/number/combat_define/reg_shell_speed
	config_entry_value = 3

/datum/config_entry/number/combat_define/fast_shell_speed
	config_entry_value = 4

/datum/config_entry/number/combat_define/super_shell_speed
	config_entry_value = 5

/datum/config_entry/number/combat_define/ultra_shell_speed
	config_entry_value = 6

/*
Penetration.
Flat number subtracted from target armor before damage calculations take place.
*/
/datum/config_entry/number/combat_define/min_armor_penetration
	config_entry_value = 5

/datum/config_entry/number/combat_define/mlow_armor_penetration
	config_entry_value = 10

/datum/config_entry/number/combat_define/low_armor_penetration
	config_entry_value = 20

/datum/config_entry/number/combat_define/lmed_armor_penetration
	config_entry_value = 25

/datum/config_entry/number/combat_define/med_armor_penetration
	config_entry_value = 30

/datum/config_entry/number/combat_define/hmed_armor_penetration
	config_entry_value = 40

/datum/config_entry/number/combat_define/high_armor_penetration
	config_entry_value = 50

/datum/config_entry/number/combat_define/mhigh_armor_penetration
	config_entry_value = 60

/datum/config_entry/number/combat_define/vhigh_armor_penetration
	config_entry_value = 70

/datum/config_entry/number/combat_define/max_armor_penetration
	config_entry_value = 80

/datum/config_entry/number/combat_define/aprocket_armor_penetration
	config_entry_value = 150

/datum/config_entry/number/combat_define/ltb_armor_penetration
	config_entry_value = 200

/*
Extra projectiles.
How many extra projectiles the projectile spawn when fired. Extra projectiles scatter when fired.
*/
/datum/config_entry/number/combat_define/min_proj_extra
	config_entry_value = 1

/datum/config_entry/number/combat_define/low_proj_extra
	config_entry_value = 2

/datum/config_entry/number/combat_define/med_proj_extra
	config_entry_value = 3

/datum/config_entry/number/combat_define/hmed_proj_extra
	config_entry_value = 4

/datum/config_entry/number/combat_define/high_proj_extra
	config_entry_value = 5

/datum/config_entry/number/combat_define/mhigh_proj_extra
	config_entry_value = 6

/datum/config_entry/number/combat_define/vhigh_proj_extra
	config_entry_value = 7

/datum/config_entry/number/combat_define/max_proj_extra
	config_entry_value = 8

/*
Projectile variance.
Variance is is a multiple (out of 100) that is used when generating a bullet. Affects accuracy and damage.
*/
/datum/config_entry/number/combat_define/min_proj_variance
	config_entry_value = 1

/datum/config_entry/number/combat_define/low_proj_variance
	config_entry_value = 3

/datum/config_entry/number/combat_define/mlow_proj_variance
	config_entry_value = 5

/datum/config_entry/number/combat_define/med_proj_variance
	config_entry_value = 7

/datum/config_entry/number/combat_define/hmed_proj_variance
	config_entry_value = 8

/datum/config_entry/number/combat_define/high_proj_variance
	config_entry_value = 9

/datum/config_entry/number/combat_define/max_proj_variance
	config_entry_value = 10

/*
Movement accuracy penalty.
*/
/datum/config_entry/number/combat_define/min_movement_acc_penalty
	config_entry_value = 0.1

/datum/config_entry/number/combat_define/low_movement_acc_penalty
	config_entry_value = 0.25

/datum/config_entry/number/combat_define/med_movement_acc_penalty
	config_entry_value = 0.5

/*
Scatter penalty while bursting.
*/
/datum/config_entry/number/combat_define/low_burst_scatter_penalty
	config_entry_value = 0.25

/*
Accuracy penalty while bursting.
*/
/datum/config_entry/number/combat_define/min_burst_accuracy_penalty
	config_entry_value = 0.9

/datum/config_entry/number/combat_define/low_burst_accuracy_penalty
	config_entry_value = 0.8

/datum/config_entry/number/combat_define/mlow_burst_accuracy_penalty
	config_entry_value = 0.7

/datum/config_entry/number/combat_define/med_burst_accuracy_penalty
	config_entry_value = 0.6

/datum/config_entry/number/combat_define/hmed_burst_accuracy_penalty
	config_entry_value = 0.5

/datum/config_entry/number/combat_define/high_burst_accuracy_penalty
	config_entry_value = 0.4

/datum/config_entry/number/combat_define/mhigh_burst_accuracy_penalty
	config_entry_value = 0.3

/datum/config_entry/number/combat_define/max_burst_accuracy_penalty
	config_entry_value = 0.2
	
/*
Accuracy bonuses from focus order
*/
/datum/config_entry/number/combat_define/focus_base_bonus
	config_entry_value = 3
	
/datum/config_entry/number/combat_define/focus_per_tile_bonus
	config_entry_value = 0.35	