# Written by Petru Paler and Ross Cohen
#
# See LICENSE.bencode for license information
#
# SPDX-License-Identifier: BSD-3-Clause
#
#
# Changes:
#
# 2020-04-14: Python3 support (Heikki Orsila <heikki.orsila@iki.fi>)
#
# 2009-09-25: Support bool type (Heikki Orsila <heikki.orsila@iki.fi>)
#             and type validator. No copyrights claimed for this extension.
#
#             Example:
#
#             dictionary = fmt_bdecode({'name': STRING, 'age': INT}, data)

from typevalidator import validate


B_ORD = ord('b')
COLON_ORD = ord(':')
D_ORD = ord('d')
DASH_ORD = ord('-')
E_ORD = ord('e')
I_ORD = ord('i')
L_ORD = ord('l')
ONE_ORD = ord('1')
NINE_ORD = ord('9')
ZERO_ORD = ord('0')


def decode_bool(x, f):
    if x[f + 1] == ZERO_ORD:
        return (False, f + 2)
    elif x[f + 1] == ONE_ORD:
        return (True, f + 2)
    raise ValueError


def _byte_is_digit(byte):
    return byte >= ZERO_ORD and byte <= NINE_ORD


def decode_int(x, f):
    f = f + 1
    newf = x.index(E_ORD, f)
    if x[f] != DASH_ORD and not _byte_is_digit(x[f]):
        raise ValueError
    n = int(x[f:newf])
    if x[f] == DASH_ORD:
        if x[f + 1] == ZERO_ORD:
            raise ValueError
    elif x[f] == ZERO_ORD and newf != f+1:
        raise ValueError
    return (n, newf+1)


def decode_bytes(x, f):
    colon = x.index(COLON_ORD, f)
    n = int(x[f:colon])
    if x[f] == ZERO_ORD and colon != f+1:
        raise ValueError
    colon += 1
    return (x[colon:colon+n], colon+n)


def decode_list(x, f):
    r, f = [], f+1
    while x[f] != E_ORD:
        v, f = decode_func[x[f]](x, f)
        r.append(v)
    return (r, f + 1)


def decode_dict(x, f):
    r, f = {}, f+1
    lastkey = None
    while x[f] != E_ORD:
        try:
            k, f = decode_bytes(x, f)
        except ValueError:
            k, f = decode_int(x, f)
        if lastkey is not None and lastkey >= k:
            raise ValueError
        lastkey = k
        r[k], f = decode_func[x[f]](x, f)
    return (r, f + 1)


decode_func = {}
decode_func[B_ORD] = decode_bool
decode_func[L_ORD] = decode_list
decode_func[D_ORD] = decode_dict
decode_func[I_ORD] = decode_int
decode_func[48] = decode_bytes
decode_func[49] = decode_bytes
decode_func[50] = decode_bytes
decode_func[51] = decode_bytes
decode_func[52] = decode_bytes
decode_func[53] = decode_bytes
decode_func[54] = decode_bytes
decode_func[55] = decode_bytes
decode_func[56] = decode_bytes
decode_func[57] = decode_bytes


def bdecode(x):
    if not isinstance(x, bytes):
        raise ValueError('Decoded type must be bytes')
    try:
        r, length = decode_func[x[0]](x, 0)
    except (IndexError, KeyError):
        raise ValueError
    if length != len(x):
        raise ValueError
    return r


def test_bdecode():
    try:
        bdecode('a')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'0:0:')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'ie')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'i341foo382e')
        assert False
    except ValueError:
        pass
    assert bdecode(b'i4e') == 4
    assert bdecode(b'i0e') == 0
    assert bdecode(b'i123456789e') == 123456789
    assert bdecode(b'i-10e') == -10
    try:
        bdecode(b'i-0e')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'i 2e')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'i123')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'i6easd')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'35208734823ljdahflajhdf')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'2:abfdjslhfld')
        assert False
    except ValueError:
        pass
    assert bdecode(b'0:') == b''
    assert bdecode(b'3:abc') == b'abc'
    assert bdecode(b'10:1234567890') == b'1234567890'
    try:
        bdecode(b'02:xy')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'l')
        assert False
    except ValueError:
        pass
    assert bdecode(b'le') == []
    try:
        bdecode(b'leanfdldjfh')
        assert False
    except ValueError:
        pass
    assert bdecode(b'l0:0:0:e') == [b'', b'', b'']
    try:
        bdecode(b'relwjhrlewjh')
        assert False
    except ValueError:
        pass
    assert bdecode(b'li1ei2ei3ee') == [1, 2, 3]
    assert bdecode(b'l3:asd2:xye') == [b'asd', b'xy']
    assert bdecode(b'll5:Alice3:Bobeli2ei3eee') == [[b'Alice', b'Bob'], [2, 3]]
    try:
        bdecode(b'd')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'defoobar')
        assert False
    except ValueError:
        pass
    assert bdecode(b'de') == {}
    assert bdecode(b'd3:agei25e4:eyes4:bluee') == {
        b'age': 25, b'eyes': b'blue'}
    assert bdecode(b'd8:spam.mp3d6:author5:Alice6:lengthi100000eee') == {
        b'spam.mp3': {b'author': b'Alice', b'length': 100000}}
    try:
        bdecode(b'd3:fooe')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'di1e0:e')
    except ValueError:
        pass
    try:
        bdecode(b'd1:b0:1:a0:e')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'd1:a0:1:a0:e')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'i03e')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'l01:ae')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'9999:x')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'l0:')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'd0:0:')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'd0:')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'00:')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'l-3:e')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'i-03e')
        assert False
    except ValueError:
        pass
    try:
        bdecode(b'b2')
        assert False
    except ValueError:
        pass


def fmt_bdecode(fmt, data):
    try:
        x = bdecode(data)
    except ValueError:
        return None
    if not validate(fmt, x):
        return None
    return x


class Bencached(object):
    __slots__ = ['bencoded']

    def __init__(self, s):
        self.bencoded = s


def bencode_bool(x, b):
    if x:
        b.extend((B_ORD, ONE_ORD))
    else:
        b.extend((B_ORD, ZERO_ORD))


def bencode_int(x, b):
    b.append(I_ORD)
    b.extend(str(x).encode())
    b.append(E_ORD)


def bencode_bytes(x, b):
    b.extend(str(len(x)).encode())
    b.append(COLON_ORD)
    b.extend(x)


def bencode_list(x, b):
    b.append(L_ORD)
    for e in x:
        encode_func[type(e)](e, b)
    b.append(E_ORD)


def bencode_dict(x, b):
    b.append(D_ORD)
    for key in sorted(x):
        if type(key) is bytes:
            bencode_bytes(key, b)
        elif type(key) is str:
            bencode_string(key, b)
        elif type(key) is int:
            bencode_int(key, b)
        else:
            assert False
        encode_func[type(x[key])](x[key], b)
    b.append(E_ORD)


def bencode_string(x, b):
    bencode_bytes(x.encode(), b)


def bencode_cached(x, b):
    b.append(x.bencoded)


encode_func = {}
encode_func[bool] = bencode_bool
encode_func[int] = bencode_int
encode_func[bytes] = bencode_bytes
encode_func[str] = bencode_string
encode_func[list] = bencode_list
encode_func[tuple] = bencode_list
encode_func[dict] = bencode_dict
encode_func[Bencached] = bencode_cached


def bencode(item):
    b = bytearray()
    try:
        encode_func[type(item)](item, b)
    except KeyError as e:
        raise ValueError('KeyError({})'.format(e))
    return bytes(b)


def test_bencode():
    assert bencode('a') == b'1:a'
    assert bencode({'a': 1}) == b'd1:ai1ee'
    assert bencode(4) == b'i4e'
    assert bencode(0) == b'i0e'
    assert bencode(-10) == b'i-10e'
    assert bencode(12345678901234567890) == b'i12345678901234567890e'
    assert bencode(b'') == b'0:'
    assert bencode(b'abc') == b'3:abc'
    assert bencode(b'1234567890') == b'10:1234567890'
    assert bencode([]) == b'le'
    assert bencode([1, 2, 3]) == b'li1ei2ei3ee'
    assert bencode([[b'Alice', b'Bob'], [2, 3]]) == b'll5:Alice3:Bobeli2ei3eee'
    assert bencode({}) == b'de'
    assert bencode({b'age': 25, b'eyes': b'blue'}) == (
        b'd3:agei25e4:eyes4:bluee')
    assert bencode({b'spam.mp3': {
        b'author': b'Alice', b'length': 100000}}) == (
            b'd8:spam.mp3d6:author5:Alice6:lengthi100000eee')
    assert bencode(False) == b'b0'
    assert bencode(True) == b'b1'
    assert bencode([True, 2]) == b'lb1i2ee'
    assert bencode([2, False]) == b'li2eb0e'
    assert bencode({1: b'foo'}) == b'di1e3:fooe'


if __name__ == '__main__':
    test_bdecode()
    test_bencode()
