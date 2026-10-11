from typevalidator import ZERO_OR_MORE, validate


def benchmark():
    specification = {'uid': str,
                     'ids': [ZERO_OR_MORE, int],
                     'purposes': [ZERO_OR_MORE, str],
                     'metas': [ZERO_OR_MORE, {}],
                     }
    request = {'uid': '0123456789abcdef',
               'ids': [0, 1, 2, 3, 4],
               'purposes': ['a', 'b', 'c', 'd', 'e'],
               'metas': [{}, {}, {}, {}, {}],
               }
    for i in range(100000):
        if not validate(specification, request):
            assert False


if __name__ == '__main__':
    benchmark()
