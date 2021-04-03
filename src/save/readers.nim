import binstreams
import ./types

proc read*(f: MemStream, T: typedesc[GRDataType]): GRDataType

proc readCString(f: MemStream): string =
    var str: string = ""
    while true:
        var character: char = f.readChar()
        if character == '\0':
            break
        str.add(character)
    return str

proc readCString(f: MemStream, length: uint32): string =
    return f.readStr(length)


proc read(f: MemStream, T: typedesc[GRVariable]): GRVariable =
    var varName = GRVariable()
    var pos: int64 = f.getPosition()
    var nameOffset: uint32 = f.read(uint32)
    varName.location = cast[int64](nameOffset)
    f.setPosition(cast[int64](nameOffset))
    varName.name = f.readCString
    result = varName
    f.setPosition(pos + 4)
    
proc readGRTable(f: MemStream, varName: GRVariable): GRDataType =
    var dataTypeInfo = GRDataType(varName: varName, kind: List)
    var count = f.read(uint32)
    f.setPosition(4, sspCur)
    var items: seq[GRDataType] = newSeq[GRDataType]()
    var totalProcessed: uint32 = 1
    for index in 1..count:
        var dataType = f.read(GRDataType)
        totalProcessed += dataType.processed
        items.add(dataType)
    dataTypeInfo.items = items
    dataTypeInfo.processed = totalProcessed
    result = dataTypeInfo


proc readGRFloat(f: MemStream, varName: GRVariable): GRDataType =
    var dataTypeInfo = GRDataType(varName: varName, kind: Float)
    dataTypeInfo.location = f.getPosition
    f.setPosition(4, sspCur)
    result = dataTypeInfo

proc readGRVector(f: MemStream, varName: GRVariable, vectorLoc: int64): GRDataType =
    var dataTypeInfo = GRDataType(varName: varName, kind: Vector)
    dataTypeInfo.location = vectorLoc
    f.setPosition(4, sspCur)
    result = dataTypeInfo

proc readGRString(f: MemStream, varName: GRVariable, stringLoc: int64): GRDataType =
    var dataTypeInfo = GRDataType(varName: varName, kind: String)
    var loc: int64 = f.getPosition
    var stringLength: uint32 = f.read(uint32)
    if stringLoc == 0x0:
        dataTypeInfo.location = stringLoc
        dataTypeInfo.stringValue = ""
    else:
        f.setPosition(stringLoc)
        dataTypeInfo.location = stringLoc
        dataTypeInfo.stringValue = f.readCString(stringLength)
    f.setPosition(loc + 0x4)
    result = dataTypeInfo

proc readGRBool(f: MemStream, varName: GRVariable): GRDataType =
    var dataTypeInfo = GRDataType(varName: varName, kind: Boolean)
    dataTypeInfo.location = f.getPosition
    f.setPosition(4, sspCur)
    result = dataTypeInfo

import bitops
proc read*(f: MemStream, T: typedesc[GRDataType]): GRDataType =
    var dataTypeInfo: GRDataType
    let varName: GRVariable = f.read(GRVariable)
    let rawDataType: uint32 = f.read(uint32) # 8
    var dataType: uint32 = rawDataType 
    dataType.mask(0b111'u32)
    let dataLocation: int64 = cast[int64](rawDataType) shr 4
    if dataType == 0:
        dataTypeInfo = f.readGRTable(varName)
    elif dataType == 1:
        dataTypeInfo = f.readGRFloat(varName)
    elif dataType == 2:
        dataTypeInfo = f.readGRVector(varName, dataLocation)
    elif dataType == 3:
        dataTypeInfo = f.readGRString(varName, dataLocation)
        if varName.name == "playtime":
            echo "Playtime: ", dataTypeInfo.stringValue
    elif dataType == 4:
        dataTypeInfo = f.readGRBool(varName)
    else:
        echo dataType
        var e: ref ValueError
        new e
        e.msg = "Invalid type discovered! "
        e.msg.add(varName.name)
        raise e
        
    if dataTypeInfo.kind != List:
        dataTypeInfo.processed = 1
        f.setPosition(4, sspCur)
    result = dataTypeInfo


import strutils
proc readGRSaveFile*(saveFileMem: MemStream): seq[GRDataType] =
    # check magic number
    if saveFileMem.readStr(4) != "ggdL":
        echo "Invalid Magic Number"
        quit(-1)
    saveFileMem.endian = littleEndian
    var value : uint32 = saveFileMem.read(uint32)
    if value != 0x1330689:
        echo "Corrupted save file"
        quit(-1)
    var fileSizeInBytes: uint32 = saveFileMem.read(uint32)
    let numOfData: uint32 =  saveFileMem.read(uint32)
    echo "Size: $1 bytes\nEntries: $2\n" % [$fileSizeInBytes, $numOfData]
    var data: seq[GRDataType] = newSeq[GRDataType]()
    var index: uint32 = 0
    while index < numOfData:
        try:
            data.add(saveFileMem.read(GRDataType))
            index += data[len(data) - 1].processed
        except(NilAccessDefect):
            echo "I caught exception"
            echo getCurrentExceptionMsg()
            raise getCurrentException()
        except(IOError):
            echo saveFileMem.getPosition()
            raise getCurrentException()
    result = data