from typevalidator import (
    float_or_int,
    match,
    non_negative_int,
    negative_int,
    one_of,
    positive_int,
    type_or_none,
    union_type,
    validate,
    validate2,

    ANY,
    ONE_OR_MORE,
    OPTIONAL_KEY,
    ZERO_OR_MORE,
)


def test_validate():
    # Test list validation
    assert validate(
        [str, [ONE_OR_MORE, int], [ZERO_OR_MORE, int], {'a': int, 1: str}],
        ['fff', [0], [], {'a': 0, 1: 'foo'}])
    assert not validate(
        [str, [ONE_OR_MORE, int], [ZERO_OR_MORE, int], {'a': int, 1: str}],
        [1, [0], [], {'a': 0, 1: 'foo'}])
    assert not validate(
        [str, [ONE_OR_MORE, int], [ZERO_OR_MORE, int], {'a': int, 1: str}],
        ['fff', [], [], {'a': 0, 1: 'foo'}])
    assert validate([ONE_OR_MORE, int, ZERO_OR_MORE, str], [1, 1, 1])
    assert validate([ONE_OR_MORE, int, ZERO_OR_MORE, str], [1, 1, 1, 's'])
    assert validate([ZERO_OR_MORE, int, ONE_OR_MORE, str], [1, 1, 1, 's'])
    assert not validate([ZERO_OR_MORE, int, ONE_OR_MORE, str], [1, 1, 1])
    assert validate([ZERO_OR_MORE, int, ONE_OR_MORE, str], ['d'])
    assert not validate([ZERO_OR_MORE, int, ONE_OR_MORE, str], [])

    # Test tuple validation
    assert validate(
        (str, [ONE_OR_MORE, int], [ZERO_OR_MORE, int], {'a': int, 1: str}),
        ('fff', [0], [], {'a': 0, 1: 'foo'}))
    assert not validate(
        (str, [ONE_OR_MORE, int], [ZERO_OR_MORE, int], {'a': int, 1: str}),
        (1, [0], [], {'a': 0, 1: 'foo'}))
    assert not validate(
        (str, [ONE_OR_MORE, int], [ZERO_OR_MORE, int], {'a': int, 1: str}),
        ('fff', [], [], {'a': 0, 1: 'foo'}))
    assert validate((ONE_OR_MORE, int, ZERO_OR_MORE, str), (1, 1, 1))
    assert validate((ONE_OR_MORE, int, ZERO_OR_MORE, str), (1, 1, 1, 's'))
    assert validate((ZERO_OR_MORE, int, ONE_OR_MORE, str), (1, 1, 1, 's'))
    assert not validate((ZERO_OR_MORE, int, ONE_OR_MORE, str), (1, 1, 1))
    assert validate((ZERO_OR_MORE, int, ONE_OR_MORE, str), ('d', ))
    assert not validate((ZERO_OR_MORE, int, ONE_OR_MORE, str), tuple())

    # Test union type
    validate2((union_type([int, float]), union_type([int, float])),
              (1, 2))
    assert not validate((ONE_OR_MORE, union_type([int, float])), tuple())
    assert validate((ONE_OR_MORE, union_type([int, float])), (1, ))
    validate2(union_type([int, float]), 1.0)
    try:
        validate2(union_type([1, float]), 1.0)
        assert False
    except ValueError:
        pass

    assert not validate((int, ), [int, ])
    assert not validate([int, ], (tuple, ))

    assert validate((int, ), (1, ))
    assert not validate((int, ), (1, 2))
    assert not validate((int, str), (1, ))
    assert validate((int, str), (1, 'a'))

    assert validate(lambda x: x % 2 == 0, 0)
    assert not validate(lambda x: x % 2 == 0, 1)

    assert validate({str: str}, {'a': 'b'})
    assert not validate({str: str}, {1: 'b'})
    assert not validate({str: str}, {'a': 1})
    assert validate({str: int}, {'a': 1})
    assert validate({int: str}, {1: 'a'})
    assert not validate({int: str}, {1: 'a', 'b': 2})

    # Extra keys in dictionary are allowed
    assert validate({'x': int}, {'x': 1, 'y': 1})
    # Missing key fails
    assert not validate({'x': int}, {'y': 1})

    # OK
    assert validate({'x': int, str: int}, {'x': 1, 'y': 1})
    # Non-string key
    assert not validate({'x': int, str: int}, {'x': 1, 1: 1})
    # Missing key, but correct key type
    assert not validate({'x': int, str: int}, {'y': 1})

    assert validate({'x': bool}, {'x': False})
    assert not validate({'x': bool}, {'x': 0})

    # Test OPTIONAL_KEY
    assert validate({OPTIONAL_KEY('x'): int}, {})
    assert validate({OPTIONAL_KEY('x'): int}, {'x': 1})
    assert not validate({OPTIONAL_KEY('x'): int}, {'x': 'invalid'})

    # Typevalidator can be used to check that values are equal
    assert validate([1, 2, 3, [True, 'a']], [1, 2, 3, [True, 'a']])
    assert not validate('foo', 'bar')

    assert validate(float, 0.0)
    assert not validate(float, 1)

    assert validate({'value': one_of(['x', 'y'])}, {'value': 'x'})
    assert not validate({'value': one_of(['x', 'y'])}, {'value': 'z'})

    validate2(one_of([1, ]), 1)
    try:
        validate2(one_of([1, ]), 1.0)
        assert False
    except ValueError:
        pass

    # Test object as dict key
    assert validate({object: int}, {'1': 1, 2: 2})
    assert validate({object: int}, {str: 1})
    assert validate({str: object}, {'1': object})
    assert validate({object: object}, {object: object})

    # Test object as list type
    assert validate([ZERO_OR_MORE, object], [])
    assert validate([ZERO_OR_MORE, object], [1])
    assert validate([ZERO_OR_MORE, object], [1, '2'])
    assert validate([ZERO_OR_MORE, object], [1, '2', object])

    assert not validate({str: int}, {str: 1})
    assert not validate({str: int}, {'x': int})

    try:
        validate({OPTIONAL_KEY(str): str}, {'1': '2'})
        assert False
    except ValueError:
        pass

    # Test validation exceptions
    validate2(int, 1) == 1

    try:
        validate2(int, '1')
        assert False
    except ValueError:
        pass
    try:
        validate2([ZERO_OR_MORE, int], ['x'])
        assert False
    except ValueError:
        pass
    try:
        validate2(['x'], [1])
        assert False
    except ValueError:
        pass
    try:
        validate2(['x'], 's')
        assert False
    except ValueError:
        pass
    try:
        validate2({'x': int}, {'x': 'y'})
        assert False
    except ValueError:
        pass
    try:
        validate2({str: int}, {1: 'y'})
        assert False
    except ValueError:
        pass
    try:
        validate2([], 'x')
        assert False
    except ValueError:
        pass
    try:
        validate2(['x'], [])
        assert False
    except ValueError:
        pass
    try:
        validate2({}, [])
        assert False
    except ValueError:
        pass
    try:
        validate2({'x': int}, {})
        assert False
    except ValueError:
        pass
    try:
        validate2(lambda x: (x & 1) == 0, 1)
        assert False
    except ValueError:
        pass

    try:
        validate2({'x': [ZERO_OR_MORE, str]}, {'x': ['y', 0]})
        assert False
    except ValueError:
        pass
    assert validate({'x': [ZERO_OR_MORE, {'y': dict}]}, {'x': []})
    assert validate({'x': [ZERO_OR_MORE, {'y': dict}]}, {'x': [{'y': {}}]})

    assert not validate({'x': [ONE_OR_MORE, {'y': dict}]}, {'x': []})

    assert validate(union_type([int, float]), 1)
    assert validate(union_type([int, float]), 2.0)
    assert not validate(union_type([int, float]), '3')

    # Test ANY backwards compatibility
    assert validate(ANY, 0)
    assert validate(object, 0)
    assert validate(ANY, False)
    assert validate(object, False)

    # Test list function validator
    assert validate([ZERO_OR_MORE,
                     lambda x: type(x) == int and (x % 2) == 0], [2])
    assert not validate([ZERO_OR_MORE,
                         lambda x: type(x) == int and (x % 2) == 0], [2, 3])
    assert not validate([ZERO_OR_MORE,
                         lambda x: type(x) == int and (x % 2) == 0], ['2'])

    # Test dict key function validator
    assert validate({lambda x: isinstance(x, int) and (x % 2) == 0: str},
                    {2: 'a'})
    assert not validate({lambda x: isinstance(x, int) and (x % 2) == 0: str},
                        {3: 'a'})
    assert not validate({lambda x: isinstance(x, int) and (x % 2) == 0: str},
                        {2: 1})

    # Test set validation
    assert validate({str}, {'a', })
    assert not validate({str}, {1, })
    assert not validate({str}, {1, 'a'})
    assert not validate({str}, {'a', 1})

    assert validate({ZERO_OR_MORE}, set())
    assert validate({ZERO_OR_MORE}, {'a', })
    assert not validate({ONE_OR_MORE}, set())
    try:
        validate2({ONE_OR_MORE}, set())
        assert False
    except ValueError:
        pass
    assert validate({ONE_OR_MORE}, {'a', })
    assert validate(set, set())
    assert validate({ONE_OR_MORE, str}, {'a', })
    assert not validate({ONE_OR_MORE, str}, set())
    assert not validate({ONE_OR_MORE, str}, {1, })
    assert validate({ZERO_OR_MORE, str}, set())

    assert validate({lambda x: isinstance(x, int) and (x % 2) == 0}, {2, })
    assert not validate({lambda x: isinstance(x, int) and (x % 2) == 0}, {3, })

    assert validate({str, 'x'}, {'x'})
    assert validate({str, 'x'}, {'x', 'y'})
    assert not validate({str, 'x'}, {'y'})

    assert validate({str, one_of(['x', 'y'])}, {'y'})
    assert validate({str, one_of(['x', 'y'])}, {'x', 'y'})
    assert not validate({str, one_of(['x', 'y'])}, {'x', 'z'})

    assert not validate(non_negative_int, -1)
    assert validate(non_negative_int, 0)
    assert validate(non_negative_int, 1)
    assert not validate(non_negative_int, 1.0)

    assert validate(negative_int, -1)
    assert not validate(negative_int, -1.0)
    assert not validate(negative_int, 0)
    assert not validate(negative_int, 1)

    assert not validate(positive_int, -1)
    assert not validate(positive_int, 0)
    assert validate(positive_int, 1)
    assert not validate(positive_int, 1.0)

    assert validate(float_or_int, 1)
    assert validate(float_or_int, 1.5)
    assert not validate(float_or_int, True)
    assert not validate(float_or_int, complex())

    assert validate(type_or_none(int), 0)
    assert validate(type_or_none(int), None)
    assert not validate(type_or_none(int), 'x')


def test_match():
    assert match({str: int}, {'a': 1}) == {'a': 1}
    assert match({str: int}, {'a': '1'}) is None
    assert match({str: int}, {'a': 1}, {'def': 2}) == {'a': 1}
    assert match({str: int}, {'a': '1'}, {'def': 2}) == {'def': 2}
    assert match({str: int}, {'a': 1}, default={'def': 2}) == {'a': 1}
    assert match({str: int}, {'a': '1'}, default={'def': 2}) == {'def': 2}


if __name__ == '__main__':
    test_validate()
    test_match()
