import builtins
from IPython.lib.pretty import pprint


def custom_print(*args, **kwargs):
    # Handle empty print call which raise error for ipython pprint
    if not args and not kwargs:
        builtins.print()
        return

    pprint(*args, **kwargs)


# print = custom_print
