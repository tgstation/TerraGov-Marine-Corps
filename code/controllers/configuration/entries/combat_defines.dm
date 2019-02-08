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

/datum/config_entry/number/combat_define/proj_base_damage_mult

/*
Projectile variance.
Global settings for projectile variance for damage and accuracy. This is the base other variance is added to.
*/
/datum/config_entry/number/combat_define/proj_variance_high

/datum/config_entry/number/combat_define/proj_variance_low


/*
Critical hit.
These are the boundaries of a critical hit.
*/
/datum/config_entry/number/combat_define/critical_chance_low

/datum/config_entry/number/combat_define/critical_chance_high

/*
Base armor resist.
These are the multiples * after soaking damage. Low is the initial one used after soaking damage,
high is the derived one after soaking damage again.
*/
/datum/config_entry/number/combat_define/base_armor_resist_low

/datum/config_entry/number/combat_define/base_armor_resist_high


/*
Xeno armor resist.
Xenos use this as a boundary for soaking damage or adding more armor.
*/
/datum/config_entry/number/combat_define/xeno_armor_resist_min

/datum/config_entry/number/combat_define/xeno_armor_resist_vlow

/datum/config_entry/number/combat_define/xeno_armor_resist_low

/datum/config_entry/number/combat_define/xeno_armor_resist_mlow

/datum/config_entry/number/combat_define/xeno_armor_resist_lmed
/*
Xenos use this as the upper boundary for deflecting damage on their second pass.
*/
/datum/config_entry/number/combat_define/xeno_armor_resist_high


/*
Accuracy.
*/
/datum/config_entry/number/combat_define/min_hit_accuracy

/datum/config_entry/number/combat_define/low_hit_accuracy

/datum/config_entry/number/combat_define/med_hit_accuracy

/datum/config_entry/number/combat_define/hmed_hit_accuracy

/datum/config_entry/number/combat_define/high_hit_accuracy

/datum/config_entry/number/combat_define/max_hit_accuracy

/*
Accuracy multiplier.
*/
/datum/config_entry/number/combat_define/base_hit_accuracy_mult

/datum/config_entry/number/combat_define/min_hit_accuracy_mult

/datum/config_entry/number/combat_define/mlow_hit_accuracy_mult

/datum/config_entry/number/combat_define/low_hit_accuracy_mult

/datum/config_entry/number/combat_define/med_hit_accuracy_mult

/datum/config_entry/number/combat_define/hmed_hit_accuracy_mult

/datum/config_entry/number/combat_define/high_hit_accuracy_mult

/datum/config_entry/number/combat_define/max_hit_accuracy_mult


/*
Damage.
Damage of the projectile, though the gun itself can modify it. This is the main source of projectile damage.
*/
/datum/config_entry/number/combat_define/base_hit_damage

/datum/config_entry/number/combat_define/min_hit_damage

/datum/config_entry/number/combat_define/llow_hit_damage

/datum/config_entry/number/combat_define/mlow_hit_damage

/datum/config_entry/number/combat_define/low_hit_damage

/datum/config_entry/number/combat_define/hlow_hit_damage

/datum/config_entry/number/combat_define/lmed_hit_damage

/datum/config_entry/number/combat_define/lmmed_hit_damage

/datum/config_entry/number/combat_define/med_hit_damage

/datum/config_entry/number/combat_define/hmed_hit_damage

/datum/config_entry/number/combat_define/high_hit_damage

/datum/config_entry/number/combat_define/mhigh_hit_damage

/datum/config_entry/number/combat_define/max_hit_damage

/datum/config_entry/number/combat_define/super_hit_damage

/datum/config_entry/number/combat_define/ultra_hit_damage

/datum/config_entry/number/combat_define/aprocket_hit_damage

/datum/config_entry/number/combat_define/ltb_hit_damage

/*
Damage multiplier.
*/
/datum/config_entry/number/combat_define/base_hit_damage_mult

/datum/config_entry/number/combat_define/min_hit_damage_mult

/datum/config_entry/number/combat_define/low_hit_damage_mult

/datum/config_entry/number/combat_define/med_hit_damage_mult

/datum/config_entry/number/combat_define/tacshottie_damage_mult

/datum/config_entry/number/combat_define/hmed_hit_damage_mult

/datum/config_entry/number/combat_define/high_hit_damage_mult

/datum/config_entry/number/combat_define/max_hit_damage_mult


/*
Damage falloff.
How much damage the projectile loses per turf traveled.
*/
/datum/config_entry/number/combat_define/reg_damage_falloff

/datum/config_entry/number/combat_define/smg_damage_falloff

/datum/config_entry/number/combat_define/buckshot_damage_falloff

/datum/config_entry/number/combat_define/extra_damage_falloff

/*
Damage falloff multiplier.
*/
/datum/config_entry/number/combat_define/base_damage_falloff_mult

/datum/config_entry/number/combat_define/min_damage_falloff_mult

/datum/config_entry/number/combat_define/low_damage_falloff_mult

/datum/config_entry/number/combat_define/lmed_damage_falloff_mult

/datum/config_entry/number/combat_define/med_damage_falloff_mult

/datum/config_entry/number/combat_define/hmed_damage_falloff_mult

/datum/config_entry/number/combat_define/high_damage_falloff_mult

/datum/config_entry/number/combat_define/max_damage_falloff_mult

/*
Burst fire.
How many shots the weapon shoots each burst. Should be set to 1 if the gun doesn't burst at all.
*/
/datum/config_entry/number/combat_define/min_burst_value

/datum/config_entry/number/combat_define/low_burst_value

/datum/config_entry/number/combat_define/med_burst_value

/datum/config_entry/number/combat_define/high_burst_value

/datum/config_entry/number/combat_define/mhigh_burst_value

/datum/config_entry/number/combat_define/max_burst_value

/datum/config_entry/number/combat_define/minigun_burst_value

/*
Fire delay.
Ticks before the weapon can be fired again. Should be 6 for regular delay and 2 for burst delay.
*/
/datum/config_entry/number/combat_define/no_fire_delay

/datum/config_entry/number/combat_define/min_fire_delay

/datum/config_entry/number/combat_define/vlow_fire_delay

/datum/config_entry/number/combat_define/mlow_fire_delay

/datum/config_entry/number/combat_define/low_fire_delay

/datum/config_entry/number/combat_define/med_fire_delay

/datum/config_entry/number/combat_define/high_fire_delay

/datum/config_entry/number/combat_define/mhigh_fire_delay

/datum/config_entry/number/combat_define/max_fire_delay

/datum/config_entry/number/combat_define/tacshottie_fire_delay

/datum/config_entry/number/combat_define/scoutshottie_fire_delay


/*
Scatter.
% chance of scattering the projectile, added to the gun scatter chance when fired. Only affects guns.
*/
/datum/config_entry/number/combat_define/min_scatter_value

/datum/config_entry/number/combat_define/mlow_scatter_value

/datum/config_entry/number/combat_define/low_scatter_value

/datum/config_entry/number/combat_define/med_scatter_value

/datum/config_entry/number/combat_define/high_scatter_value

/datum/config_entry/number/combat_define/thirty_scatter_value

/datum/config_entry/number/combat_define/mhigh_scatter_value

/datum/config_entry/number/combat_define/max_scatter_value

/*
Recoil.
Amount of screen shake. Anything above 2 is really crazy recoil.
*/
/datum/config_entry/number/combat_define/min_recoil_value

/datum/config_entry/number/combat_define/low_recoil_value

/datum/config_entry/number/combat_define/med_recoil_value

/datum/config_entry/number/combat_define/high_recoil_value

/datum/config_entry/number/combat_define/max_recoil_value

/*
Shrapnel.
% chance of imbedding shrapnel in the target.
*/
/datum/config_entry/number/combat_define/min_shrapnel_chance

/datum/config_entry/number/combat_define/low_shrapnel_chance

/datum/config_entry/number/combat_define/mlow_shrapnel_chance

/datum/config_entry/number/combat_define/med_shrapnel_chance

/datum/config_entry/number/combat_define/high_shrapnel_chance

/datum/config_entry/number/combat_define/max_shrapnel_chance

/*
Range.
Number of tiles.
*/
/datum/config_entry/number/combat_define/min_shell_range

/datum/config_entry/number/combat_define/close_shell_range

/datum/config_entry/number/combat_define/screen_shell_range

/datum/config_entry/number/combat_define/near_shell_range

/datum/config_entry/number/combat_define/short_shell_range

/datum/config_entry/number/combat_define/norm_shell_range

/datum/config_entry/number/combat_define/lnorm_shell_range

/datum/config_entry/number/combat_define/long_shell_range

/datum/config_entry/number/combat_define/vlong_shell_range

/datum/config_entry/number/combat_define/max_shell_range

/*
Speed.
How quick the projectile travels, or more accurately how many turfs per sleep(1) it travels.
*/
/datum/config_entry/number/combat_define/min_shell_speed

/datum/config_entry/number/combat_define/slow_shell_speed

/datum/config_entry/number/combat_define/reg_shell_speed

/datum/config_entry/number/combat_define/fast_shell_speed

/datum/config_entry/number/combat_define/super_shell_speed

/datum/config_entry/number/combat_define/ultra_shell_speed

/*
Penetration.
Flat number subtracted from target armor before damage calculations take place.
*/
/datum/config_entry/number/combat_define/min_armor_penetration

/datum/config_entry/number/combat_define/mlow_armor_penetration

/datum/config_entry/number/combat_define/low_armor_penetration

/datum/config_entry/number/combat_define/lmed_armor_penetration

/datum/config_entry/number/combat_define/med_armor_penetration

/datum/config_entry/number/combat_define/hmed_armor_penetration

/datum/config_entry/number/combat_define/high_armor_penetration

/datum/config_entry/number/combat_define/mhigh_armor_penetration

/datum/config_entry/number/combat_define/vhigh_armor_penetration

/datum/config_entry/number/combat_define/max_armor_penetration

/datum/config_entry/number/combat_define/aprocket_armor_penetration

/datum/config_entry/number/combat_define/ltb_armor_penetration

/*
Extra projectiles.
How many extra projectiles the projectile spawn when fired. Extra projectiles scatter when fired.
*/
/datum/config_entry/number/combat_define/min_proj_extra

/datum/config_entry/number/combat_define/low_proj_extra

/datum/config_entry/number/combat_define/med_proj_extra

/datum/config_entry/number/combat_define/hmed_proj_extra

/datum/config_entry/number/combat_define/high_proj_extra

/datum/config_entry/number/combat_define/mhigh_proj_extra

/datum/config_entry/number/combat_define/vhigh_proj_extra

/datum/config_entry/number/combat_define/max_proj_extra

/*
Projectile variance.
Variance is is a multiple (out of 100) that is used when generating a bullet. Affects accuracy and damage.
*/
/datum/config_entry/number/combat_define/min_proj_variance

/datum/config_entry/number/combat_define/low_proj_variance

/datum/config_entry/number/combat_define/mlow_proj_variance

/datum/config_entry/number/combat_define/med_proj_variance

/datum/config_entry/number/combat_define/hmed_proj_variance

/datum/config_entry/number/combat_define/high_proj_variance

/datum/config_entry/number/combat_define/max_proj_variance

/*
Movement accuracy penalty.
*/
/datum/config_entry/number/combat_define/min_movement_acc_penalty

/datum/config_entry/number/combat_define/low_movement_acc_penalty

/datum/config_entry/number/combat_define/med_movement_acc_penalty

/*
Scatter penalty while bursting.
*/
/datum/config_entry/number/combat_define/low_burst_scatter_penalty