type GRVariable* = object
    name*: string
    hash*: uint32 # uses fnv1a32

type GRDataKind* = enum 
    Table
    String
    Float
    Boolean
    Vector
    Unknown

proc str*(dataKind: GRDataKind): string = 
    case dataKind:
    of Table: result = "TABLE"
    of String: result = "STRING"
    of Float: result = "FLOAT"
    of Boolean: result = "BOOL"
    of Vector: result = "VECTOR"
    of Unknown: result = "unknown"


type GRDataType* = object
    varName*: GRVariable
    processed*: uint32
    case kind*: GRDataKind
    of Table:
        items*: seq[GRDataType]
    of String:
        stringValue*: string
    of Float:
        floatValue*: float32
        discard
    of Boolean:
        boolValue*: bool
        discard
    of Vector:
        vectorValue*:array[4, float32]
        discard
    of Unknown:
        discard

proc name*(dataType: GRDataType): string =
    return dataType.varName.name
