type GRModKind* = enum
    Float
    Boolean
    Vector
    String

type GRMod* = object
    targetPath*: seq[string]
    case kind*: GRModKind
    of Float:
        floatValue*: float32
    of Boolean:
        boolValue*: bool
    of Vector:
        vectorValue*: array[4, float32]
    of String:
        stringValue*: string

type GRModOption* = object
    onlineItems*: bool
    maxGems*: bool
    skins*: seq[string]
