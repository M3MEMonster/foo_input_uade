# A simple type validator to check types of bencoded data that comes from
# an untrusted source (say, network).
#
# SPDX-License-Identifier: BSD-2-Clause
# See LICENSE for more information.
#
# Originally written by Heikki Orsila <heikki.orsila@iki.fi> on 2009-09-12
#
# Repository at https://gitlab.com/heikkiorsila/bencodetools

from types import FunctionType


class ZERO_OR_MORE:
    pass


class ONE_OR_MORE:
    pass


class OPTIONAL_KEY:
    def __init__(self, key):
        if isinstance(key, type):
            raise ValueError('key {} must not be a type'.format(key))
        self.key = key


class ValidationError(ValueError):
    def __init__(self, reason='', fmt=None, obj=None):
        self._reason = reason
        self.fmt = fmt
        self.obj = obj

    def __str__(self):
        return self._reason


# Define Invalid_Format_Object for backwards compatibility
Invalid_Format_Object = ValidationError


class Context:
    def __init__(self, raise_error=False):
        self._stack = []
        self._raise_error = raise_error

    def error(self, fmt, obj):
        if self._raise_error:
            raise ValidationError(
                reason=('Validation error: {} expected format is '
                        '{} and value is {}'.format(
                            self._print_stack(), repr(fmt), repr(obj))),
                fmt=fmt, obj=obj)

    def error2(self, msg, fmt, obj):
        if self._raise_error:
            raise ValidationError(
                reason=('Validation error: {} {}'.format(
                    self._print_stack(), msg)),
                fmt=fmt, obj=obj)

    def _print_stack(self):
        if len(self._stack) == 0:
            return 'At root position'
        return 'At position ' + ''.join(self._stack)

    def pop(self):
        self._stack.pop()

    def push(self, s):
        self._stack.append(s)

    def is_root(self):
        return len(self._stack) == 0


# Example:
#
# SPEC = {'value': one_of(['x', 'y'])}
#
# then validate(SPEC, d) means that d['value'] must be either 'x' or 'y'
def one_of(alternatives):
    d = {}
    for alternative in alternatives:
        d[alternative] = alternative

    def test_f(o):
        return o in d and isinstance(o, type(d[o]))

    return test_f


# Accept an object if its type matches one of the types in a given sequence
#
# Example:
#
# SPEC = {'value': union_type([int, float])}
#
# then validate(SPEC, d) means that d['value'] must be either a float or
# an int.
def union_type(alternative_types):
    valid_types = set(alternative_types)
    for t in valid_types:
        if not isinstance(t, type):
            raise ValueError('{} is not a type in union {}'.format(
                t, valid_types))

    def test_f(o):
        return type(o) in valid_types

    return test_f


# Accepts an object if its type is the given obj_type or it is None.
def type_or_none(obj_type):
    return union_type((obj_type, type(None)))


# Accept only non-negative integers
#
# TODO: Reject booleans. Same for other int validators.
def non_negative_int(o: object):
    return isinstance(o, int) and o >= 0


# Accept only negative integers
def negative_int(o: object):
    return isinstance(o, int) and o < 0


# Accept only positive integers
def positive_int(o: object):
    return isinstance(o, int) and o > 0


def float_or_int(o: object):
    return type(o) in (float, int)


def _validate_list(org_fmt, org_o, ctx):
    if isinstance(org_fmt, list):
        fmt_type = list
        fmt_type_str = 'list'
    else:
        fmt_type = tuple
        fmt_type_str = 'tuple'

    if type(org_o) != fmt_type:
        ctx.error2('expect a {}. Class is {}'.format(
            fmt_type_str, type(org_o)), fmt_type, org_o)
        return False

    if ctx.is_root():
        ctx.push('[]')

    fmt = list(org_fmt)
    o = list(org_o)
    pos = 0
    while len(fmt) > 0:
        fitem = fmt.pop(0)
        if fitem == ZERO_OR_MORE or fitem == ONE_OR_MORE:
            if len(fmt) == 0:
                raise ValidationError(
                    'In {} fmt {}: missing list element type'.format(
                        fmt_type_str, org_fmt))
            ftype = fmt.pop(0)
            if len(o) == 0:
                if fitem == ONE_OR_MORE:
                    ctx.error2('expect a value in {}, '
                               'but there is none.'.format(fmt_type_str),
                               fmt=org_fmt, obj=org_o)
                    return False
                continue

            while len(o) > 0:
                ctx.push('[{}]'.format(pos))
                if not _validate(ftype, o[0], ctx):
                    # This is somewhat esoteric. It is possible to concatenate
                    # list segments of different types.
                    # E.g. [ONE_OR_MORE, int, ZERO_OR_MORE, str].
                    if len(fmt) > 0:
                        break
                    return False
                ctx.pop()
                o.pop(0)
                pos += 1
            continue

        if len(o) == 0:
            ctx.error2('expect a value in {}, but there is none.'.format(
                fmt_type_str), fmt=org_fmt, obj=org_o)
            return False
        oitem = o.pop(0)
        ctx.push('[{}]'.format(pos))
        if not _validate(fitem, oitem, ctx):
            return False
        ctx.pop()
        pos += 1

    ret = (len(o) == 0)
    if not ret:
        ctx.error(org_fmt, org_o)

    if ctx.is_root():
        ctx.pop('[]')

    return ret


def _validate_dict(fmt, o, ctx):
    if type(o) != dict:
        ctx.error2('expect a dict. Class is {}'.format(type(o)), dict, o)
        return False

    if ctx.is_root():
        ctx.push('{}')

    for key in fmt:
        key_type = type(key)
        if isinstance(key, OPTIONAL_KEY):
            # OPTIONAL_KEY
            if key.key in o:
                ctx.push('[{}]'.format(repr(key.key)))
                if not _validate(fmt[key], o[key.key], ctx):
                    return False
                ctx.pop()
        elif key_type == type:
            # str, int, ...
            for okey in o:
                if key is not object:
                    if type(okey) == type or type(okey) != key:
                        ctx.error2(
                            'expect key in {} but key is {}'.format(
                                key, repr(okey)), key, okey)
                        return False
                ctx.push('[{}]'.format(repr(okey)))
                if not _validate(fmt[key], o[okey], ctx):
                    return False
                ctx.pop()
        elif key_type == FunctionType:
            for okey in o:
                ctx.push('[key:{}]'.format(repr(okey)))
                if not _validate(key, okey, ctx):
                    return False
                ctx.pop()
                ctx.push('[{}]'.format(repr(okey)))
                if not _validate(fmt[key], o[okey], ctx):
                    return False
                ctx.pop()
        else:
            # Key is a value, not a type. It must exist in the object.
            if key not in o:
                ctx.error2('key {} does not exist'.format(repr(key)), fmt, o)
                return False
            ctx.push('[{}]'.format(repr(key)))
            if not _validate(fmt[key], o[key], ctx):
                return False
            ctx.pop()

    if ctx.is_root():
        ctx.pop()

    return True


def _validate_set(fmt, o, ctx):
    if type(o) != set:
        ctx.error2('expect a set. Class is {}'.format(type(o)), set, o)
        return False

    if ctx.is_root():
        ctx.push('set()')

    for value in fmt:
        value_type = type(value)
        if value == ZERO_OR_MORE:
            pass
        elif value == ONE_OR_MORE:
            if len(o) == 0:
                ctx.error2('Expected at least one element in the list',
                           value, o)
                return False
        elif value_type == type:
            # str, int, ...
            for ovalue in o:
                if value is not object:
                    if type(ovalue) == type or type(ovalue) != value:
                        ctx.error2(
                            'expect value in {} but value is {}'.format(
                                value, repr(ovalue)), value, ovalue)
                        return False
        elif value_type == FunctionType:
            for ovalue in o:
                ctx.push('[value:{}]'.format(repr(ovalue)))
                if not _validate(value, ovalue, ctx):
                    return False
                ctx.pop()
        else:
            # Value is not a type. It must exist in the set.
            if value not in o:
                ctx.error2('value {} does not exist'.format(repr(value)),
                           fmt, o)
                return False

    if ctx.is_root():
        ctx.pop()

    return True


def _validate_function_type(fmt, o, ctx):
    # fmt is a user given checker function
    ret = fmt(o)
    if not ret:
        ctx.error2('function call {}({}) returns False'.format(
            fmt.__name__, repr(o)), fmt, o)
    return ret


def _validate_type(fmt, o, ctx):
    if type(o) != fmt and fmt is not object:
        ctx.error2('expect type {} and value is {}'.format(
            fmt.__name__, repr(o)), fmt, o)
        return False
    return True


TYPE_HANDLERS = {
    FunctionType: _validate_function_type,
    list: _validate_list,
    dict: _validate_dict,
    set: _validate_set,
    tuple: _validate_list,
    type: _validate_type,
}


def _validate(fmt, o, ctx):
    validator = TYPE_HANDLERS.get(type(fmt))
    if validator is not None:
        return validator(fmt, o, ctx)

    # If given format is a not a type but a value, compare input to the
    # given value
    ret = (fmt == o)
    if not ret:
        ctx.error2('expect value {}, but value is {}'.format(
            repr(fmt), repr(o)), fmt, o)
    return ret


def validate(fmt, o):
    """Returns True if o is valid with respect to fmt, False otherwise."""
    ctx = Context()
    return _validate(fmt, o, ctx)


def validate2(fmt, o):
    """Similar to validate() but raises ValidationError() if o is not valid.

    ValidationError is a subclass of ValueError.
    Catching ValidationError rather than ValueError allows to gain insight
    where the validation failed inside o.

    Returns the object o after validation.
    """
    ctx = Context(raise_error=True)
    _validate(fmt, o, ctx)
    return o


def match(fmt, o, default=None) -> object:
    if not validate(fmt, o):
        return default
    return o


# BOOL*, INT*, STRING* and FLOAT* are used for backward compability
# with the old interface. New code should use bool/int/str/float directly.
BOOL = bool
BOOL_KEY = bool
INT = int
INT_KEY = int
STRING = str
STRING_KEY = str
FLOAT = float
FLOAT_KEY = float

# ANY is used for backwards compatibility. Use object in new code instead.
ANY = object
