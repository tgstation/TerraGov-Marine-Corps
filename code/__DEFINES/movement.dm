//The minimum for glide_size to be clamped to.
//If you want more classic style "delay" movement while still retaining the smoothness improvements at higher framerates, set this to 8
#define MIN_GLIDE_SIZE 0
//The maximum for glide_size to be clamped to.
//This shouldn't be higher than the icon size, and generally you shouldn't be changing this, but it's here just in case.
#define MAX_GLIDE_SIZE 32

///Broken down, here's what this does:w: 
/// divides the world icon_size (32) by delay divided by ticklag to get the number of pixels something should be moving each tick.
/// The division result is given a min value of 1 to prevent obscenely slow glide sizes from being set
/// This is then multiplied by the 1 - world time dilation, which scales speeds based on time dialation. Keeps things tighter feeling when server starts crawling.
/// Then that's multiplied by the config glide_size_mod. 1.15 by default feels pretty close to spot on. This is just to try to get byond to behave.
/// The whole result is then clamped to within the range above.
/// Not very readable but it works
#define DELAY_TO_GLIDE_SIZE(delay) (round((CLAMP(((32 / max(delay / world.tick_lag, 1)) * (1 - (SStime_track.time_dilation_current / 100)) * (CONFIG_GET(number/glide_size_mod) * 0.01)), MIN_GLIDE_SIZE, MAX_GLIDE_SIZE)), 0.1))

#define DELAY_TO_GLIDE_SIZE_STATIC(delay) (round(32 / (delay || 1), 0.1))

//Old behavior, client related. Currently unused.
#define DELAY_TO_GLIDE_SIZE_OLD(source, delay) (round(source.tick_lag ? ((32 / max(delay, source.tick_lag)) * source.tick_lag) : 0, 0.1))

#define GLIDE_MOD_PULLED (1<<0)
#define GLIDE_MOD_BUCKLED (1<<0)
