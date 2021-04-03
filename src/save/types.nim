type GRVariable* = object
    name*: string
    hash*: uint32 # uses fnv1a32
    location*: int64

type GRDataKind* = enum 
    List
    String
    Float
    Boolean
    Vector
    Unknown

proc str*(dataKind: GRDataKind): string = 
    case dataKind:
    of List: result = "List"
    of String: result = "String"
    of Float: result = "Float"
    of Boolean: result = "Boolean"
    of Vector: result = "Vector"
    of Unknown: result = "unknown"


type GRDataType* = object
    varName*: GRVariable
    processed*: uint32
    location*: int64
    case kind*: GRDataKind
    of List:
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
