//The minimum for glide_size to be clamped to.
//If you want more classic style "delay" movement while still retaining the smoothness improvements at higher framerates, set this to 8
#define MIN_GLIDE_SIZE 0
//The maximum for glide_size to be clamped to.
//This shouldn't be higher than the icon size, and generally you shouldn't be changing this, but it's here just in case.
#define MAX_GLIDE_SIZE 32

///Broken down, here's what this does:w: 
/// divides the world icon_size (32) by delay divided by ticklag to get the number of pixels something should be moving each tick.
/// The division result is given a min value of 1 to prevent obscenely slow glide sizes from being set
/// This is then multiplied by the world time dilation, which is somewhat of a hack but helps get things looking a little smoother.
/// Then *that* result has 0. 15 added to it which is another smoothness trick. Serves to help prevent situations where movement "jumps"
/// The whole result is then clamped to within the range above.
/// Not very readable but it works
#define DELAY_TO_GLIDE_SIZE(delay) (CLAMP(((32 / max(delay / world.tick_lag, 1)) * ((SStime_track.time_dilation_current / 100) + 1) + 0.15), MIN_GLIDE_SIZE, MAX_GLIDE_SIZE))
