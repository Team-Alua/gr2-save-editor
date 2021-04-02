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


proc read(f: MemStream, T: typedesc[GRVariable]): GRVariable =
    var varName = GRVariable()
    var pos: int64 = f.getPosition()
    var nameOffset: uint32 = f.read(uint32)
    varName.location = cast[int64](nameOffset)
    f.setPosition(cast[int64](nameOffset))
    varName.name = f.readCString
    result = varName
    f.setPosition(pos + 4)
    
proc readGRList(f: MemStream, varName: GRVariable): GRDataType =
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


proc readGRString(f: MemStream, varName: GRVariable, stringLoc: int64): GRDataType =
    var dataTypeInfo = GRDataType(varName: varName, kind: String)
    var loc: int64 = f.getPosition
    f.setPosition(stringLoc)
    dataTypeInfo.location = stringLoc
    dataTypeInfo.stringValue = f.readCString
    f.setPosition(loc + 0x4)
    result = dataTypeInfo

proc readGRBool(f: MemStream, varName: GRVariable): GRDataType =
    var dataTypeInfo = GRDataType(varName: varName, kind: Boolean)
    dataTypeInfo.location = f.getPosition
    f.setPosition(4, sspCur)
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


proc read*(f: MemStream, T: typedesc[GRDataType]): GRDataType =
    var dataTypeInfo: GRDataType
    let varName: GRVariable = f.read(GRVariable)
    let dataType: uint32 = f.read(uint32)
    if dataType == 0x8: # List
        dataTypeInfo = f.readGRList(varName)
    elif dataType mod 0x10 == 0xB:
        dataTypeInfo = f.readGRString(varName, cast[int64](dataType) shr 4)
        if varName.name == "playtime":
            echo "Playtime: ", dataTypeInfo.stringValue
    elif dataType == 0x9:
        dataTypeInfo = f.readGRFloat(varName)
    elif dataType == 0xC:
        dataTypeInfo = f.readGRBool(varName)
    elif f.peek(uint32) == 0x10:
        dataTypeInfo = f.readGRVector(varName, cast[int64](dataType))
    else:
        var e: ref ValueError
        new e
        e.msg = "Invalid type discovered!"
        raise e
        
    if dataTypeInfo.kind != List:
        dataTypeInfo.processed = 1
        f.setPosition(4, sspCur)
    result = dataTypeInfo


proc readGRSaveFile*(saveFileMem: MemStream): seq[GRDataType] =
    # check magic number
    if saveFileMem.peekStr(4) != "ggdL":
        echo "Invalid Magic Number"
        quit(-1)

    saveFileMem.setPosition(0xC)
    saveFileMem.endian = littleEndian

    let numOfData: uint32 =  saveFileMem.read(uint32)

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