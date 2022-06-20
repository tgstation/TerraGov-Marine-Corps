/*!
 * These are global lists for vending machines that all share the same inventory, it's format is simply:
 * list(typepath = list(records))
 * so all the vendors of same type have same inventory
 * it starts empty and is filled by first vendor initialized(unless its already filled).
 * the subsequent iniatilized vendors just uses the filled list.
 * there's one list for normal records and coin.
 */

GLOBAL_LIST_EMPTY(vending_records)
GLOBAL_LIST_EMPTY(vending_coin_records)
