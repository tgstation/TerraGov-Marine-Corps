#define GLOBAL_PROC "some_magic_bullshit"

#define CALLBACK new /datum/callback
#define INVOKE_ASYNC world.ImmediateInvokeAsync
#define INVOKE_NEXT_TICK(arguments...) addtimer(CALLBACK(##arguments), 1)

#define VARSET_LIST_CALLBACK(target, var_name, var_value) CALLBACK(GLOBAL_PROC, /proc/___callbackvarset, ##target, ##var_name, ##var_value)
#define VARSET_CALLBACK(datum, var, var_value) CALLBACK(GLOBAL_PROC, /proc/___callbackvarset, ##datum, NAMEOF(##datum, ##var), ##var_value)
#define CALLBACK_NEW(typepath, args) CALLBACK(GLOBAL_PROC, /proc/___callbacknew, typepath, args)
