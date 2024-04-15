import os
import sys
from dmi import *


def green(text):
    return "\033[32m" + str(text) + "\033[0m"


def red(text):
    return "\033[31m" + str(text) + "\033[0m"


def _self_test():
    # test: can we load every DMI in the tree
    count = 0
    failed = 0
    for dirpath, dirnames, filenames in os.walk('.'):
        if '.git' in dirnames:
            dirnames.remove('.git')
        for filename in filenames:
            if filename.endswith('.dmi'):
                fullpath = os.path.join(dirpath, filename)
                failures_this_file = 0
                try:
                    dmi = Dmi.from_file(fullpath)
                    dmi_states = dmi.states
                    number_of_icon_states = len(dmi.states)
                    if number_of_icon_states > 512:
                        print("{0} {1} has too many icon states: {2}/512.".format(red("FAIL"), fullpath, number_of_icon_states))
                        failures_this_file += 1
                    existing_states = []
                    for state in dmi_states:
                        state_name = state.name
                        if state.movement:
                            state_name += "_MOVEMENT_STATE_TRUE"
                        if state_name in existing_states:
                            print("{0} {1} has a duplicate state '{2}'.".format(red("FAIL"), fullpath, state.name))
                            failures_this_file += 1
                            continue
                        existing_states.append(state_name)
                except Exception:
                    print("{0} {1} threw an exception.".format(red("FAIL"), fullpath))
                    failures_this_file += 1
                    raise
                count += 1
                if failures_this_file > 0:
                    failed += 1

    print(f"{os.path.relpath(__file__)}: {green(f'successfully parsed {count-failed} .dmi files')}")
    if failed > 0:
        print(f"{os.path.relpath(__file__)}: {red(f'failed to parse {failed} .dmi files')}")
        exit(1)


def _usage():
    print(f"Usage:")
    print(f"    tools{os.sep}bootstrap{os.sep}python -m {__spec__.name}")
    exit(1)


def _main():
    if len(sys.argv) == 1:
        return _self_test()

    return _usage()


if __name__ == '__main__':
    _main()
