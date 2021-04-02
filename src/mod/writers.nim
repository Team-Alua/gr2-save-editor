import ./types as ModTypes
from ../save/types as SaveTypes import GRDataType
from ../save/search as SaveSearch import findByName
import binstreams

proc write*(f: MemStream, edit: GRMod, sections: seq[GRDataType]): void =
    var dataType: GRDataType = sections.findByName(edit.targetPath)
    f.setPosition(dataType.location)
    f.endian = littleEndian
    case edit.kind:
    of Boolean:
        f.writeBool(edit.boolValue)
    of Float:
        f.write(edit.floatValue)
    of Vector:
        for vectorValue in edit.vectorValue:
            f.write(vectorValue)
    of String:
        f.writeStr(edit.stringValue)