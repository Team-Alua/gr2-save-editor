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
    var nameOffset: uint32 = f.read(uint32)
    let pos: int64 = f.getPosition()
    # varName.location = cast[int64](nameOffset)
    f.setPosition(cast[int64](nameOffset))
    varName.name = f.readCString
    result = varName
    f.setPosition(pos)
    
proc readGRTable(f: MemStream, varName: var GRVariable): GRDataType =
    var dataTypeInfo = GRDataType(varName: varName, kind: Table)
    var count = f.read(uint32)
    dataTypeInfo.varName.hash = f.read(uint32)
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
    var dataTypeInfo = GRDataType(varName: varName, kind: Float, processed: 1)
    # dataTypeInfo.location = f.getPosition
    dataTypeInfo.floatValue = f.read(float32)
    dataTypeInfo.varName.hash = f.read(uint32)
    result = dataTypeInfo

import system
proc readGRVector(f: MemStream, varName: GRVariable, vectorLoc: int64): GRDataType =
    var dataTypeInfo = GRDataType(varName: varName, kind: Vector, processed: 1)
    # dataTypeInfo.location = vectorLoc
    let vectorSize = f.read(uint32)
    dataTypeInfo.varName.hash = f.read(uint32)
    let pos = f.getPosition() 
    f.setPosition(vectorLoc)
    let vectorCount = vectorSize.div(4)
    for index in 1..vectorCount: 
        dataTypeInfo.vectorValue[index - 1] = f.read(float32)
    f.setPosition(pos)
    result = dataTypeInfo

proc readGRString(f: MemStream, varName: GRVariable, stringLoc: int64): GRDataType =
    var dataTypeInfo = GRDataType(varName: varName, kind: String, processed: 1)
    var stringLength: uint32 = f.read(uint32)
    dataTypeInfo.varName.hash = f.read(uint32)
    var loc: int64 = f.getPosition
    if stringLoc == 0x0:
        # dataTypeInfo.location = stringLoc
        dataTypeInfo.stringValue = ""
    else:
        f.setPosition(stringLoc)
        # dataTypeInfo.location = stringLoc
        dataTypeInfo.stringValue = f.readCString(stringLength)
    f.setPosition(loc)
    result = dataTypeInfo

proc readGRBool(f: MemStream, varName: GRVariable): GRDataType =
    var dataTypeInfo = GRDataType(varName: varName, kind: Boolean, processed: 1)
    # dataTypeInfo.location = f.getPosition
    dataTypeInfo.boolValue = f.read(uint32) > 0
    dataTypeInfo.varName.hash = f.read(uint32)
    result = dataTypeInfo

import bitops
proc read*(f: MemStream, T: typedesc[GRDataType]): GRDataType =
    var dataTypeInfo: GRDataType
    var varName: GRVariable = f.read(GRVariable)
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