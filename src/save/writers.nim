import binstreams
import ./types
import strutils
proc writeReadable*(f: MemStream, sections: seq[GRDataType], indentLevel: uint32 = 0) : void 

proc float32ToString(floatValue: float32): string =
    var floatBytes = cast[array[4, byte]](floatValue)
    # should be little endian
    var floatToLittleHex = ""
    for index in countdown(3, 0):
        floatToLittleHex.add(floatBytes[index].toHex)
    floatToLittleHex
    

proc writeDataType(f: MemStream, dataType: GRDataType, indentLevel: uint32): void =
    let tabIndents = "\t".repeat(indentLevel) 
    f.writeStr(tabIndents)
    f.writeStr("$1\t$2\t" % [dataType.name, dataType.kind.str])
    case dataType.kind:
        of Table:
            f.writeStr($len(dataType.items))
            f.writeStr("\n")
            f.writeReadable(dataType.items, indentLevel + 1)
        of Boolean:
            if dataType.boolValue:
                f.writeStr("True")
            else:
                f.writeStr("False")
        of Float:
            var floatValue = dataType.floatValue
            f.writeStr("$1($2)" % [floatValue.formatFloat(ffDecimal, 6), floatValue.float32ToString])
        of Vector:
            for floatValue in dataType.vectorValue:
                f.writeStr("$1($2) " % [floatValue.formatFloat(ffDecimal, 6), floatValue.float32ToString])
            f.setPosition(f.getPosition() - 1)
        of String:
            f.writeStr("\"$1" % dataType.stringValue)
            f.setPosition(f.getPosition() - 1)
            f.writeStr("\"")
        of Unknown:
            discard
    if dataType.kind != Table:
        f.writeStr("\n")

proc writeReadable*(f: MemStream, sections: seq[GRDataType], indentLevel: uint32 = 0) : void =
    for dataType in sections:
        f.writeDataType(dataType,indentLevel)