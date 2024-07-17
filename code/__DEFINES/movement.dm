//The minimum for glide_size to be clamped to.
//If you want more classic style "delay" movement while still retaining the smoothness improvements at higher framerates, set this to 8
#define MIN_GLIDE_SIZE 3
//The maximum for glide_size to be clamped to.
//This shouldn't be higher than the icon size, and generally you shouldn't be changing this, but it's here just in case.
#define MAX_GLIDE_SIZE 32

/// Compensating for time dilation
GLOBAL_VAR_INIT(glide_size_multiplier, 1)

///Broken down, here's what this does:
/// divides the world icon_size (32) by delay divided by ticklag to get the number of pixels something should be moving each tick.
/// The division result is given a min value of 1 to prevent obscenely slow glide sizes from being set
/// Then that's multiplied by the global glide size multiplier. 1.25 by default feels pretty close to spot on. This is just to try to get byond to behave.
/// The whole result is then clamped to within the range above.
/// Not very readable but it works
#define DELAY_TO_GLIDE_SIZE(delay) (clamp(((32 / max((delay) / world.tick_lag, 1)) * GLOB.glide_size_multiplier), MIN_GLIDE_SIZE, MAX_GLIDE_SIZE))

///Similar to DELAY_TO_GLIDE_SIZE, except without the clamping, and it supports piping in an unrelated scalar
#define MOVEMENT_ADJUSTED_GLIDE_SIZE(delay, movement_disparity) (32 / ((delay) / world.tick_lag) * movement_disparity * GLOB.glide_size_multiplier)

#define DELAY_TO_GLIDE_SIZE_STATIC(delay) (round(clamp((32 / (delay || 1)) * (CONFIG_GET(number/glide_size_mod) * 0.01), MIN_GLIDE_SIZE, MAX_GLIDE_SIZE), 0.1))

#define GLIDE_MOD_PULLED (1<<0)
#define GLIDE_MOD_BUCKLED (1<<0)

#define TURF_CAN_ENTER (1<<0)
#define TURF_ENTER_ALREADY_MOVED (1<<1)
