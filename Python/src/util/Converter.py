import string

def is_decimal(v):
    return v.isdecimal()

def is_hex(v):
    hex_digits = set(string.hexdigits)
    if v[:2] == "0x": v = v[2:]
    return all(c in hex_digits for c in v)

def is_bin(v):
    v_set = set(v)
    return v_set == {'0', '1'} or v_set == {'0'} or v_set == {'1'}

def dec_to_hex(value, leading=False):
    return "{0:#x}".format(value) if leading else "{0:x}".format(value)

def dec_to_bin(value, leading=False):
    return "{0:#b}".format(value) if leading else "{0:b}".format(value)

def _fromDEC(value, leading=False):
    return str(value) + " {Hexadecimal: " + str(dec_to_hex(value, leading)) + "; Binary: " + str(dec_to_bin(value, leading)) + "}"

def hex_to_dec(value):
    return int(value, 16)

def hex_to_bin(value, leading=False):
    return bin(int(value, 16)) if leading else bin(int(value, 16))[2:]

def _fromHEX(value, leading=False):
    return value + " {Decimal: " + str(hex_to_dec(value)) + "; Binary: " + str(hex_to_bin(value, leading)) + "}"

def bin_to_dec(value):
    return int(value, 2)

def bin_to_hex(value, leading=False):
    return hex(int(value, 2)) if leading else hex(int(value, 2))[2:]

def _fromBIN(value, leading=False):
    return str(value) + " {Decimal: " + str(bin_to_dec(value)) + "; Hexadecimal: " + str(bin_to_hex(value, leading)) + "}"