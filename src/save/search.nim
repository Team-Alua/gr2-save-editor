import ./types
proc findByName*(typeList: seq[GRDataType], name: string): GRDataType
proc findByName*(dataType: GRDataType, name: string): GRDataType

proc findByName*(typeList: seq[GRDataType], names: seq[string]): GRDataType =
    if len(names) == 0:
        var e: ref ValueError
        new(e)
        e.msg = "Must have at least one name in sequence" 
    var dataType: GRDataType = typeList.findByName(names[0])
    for index in 1..(len(names) - 1):
        dataType = dataType.findByName(names[index])
    result = dataType

proc findByName*(typeList: seq[GRDataType], name: string): GRDataType =
    var found = false
    for item in typeList:
        if item.name == name:
            found = true
            result = item
            break
    if not found:
        var e: ref ValueError
        new(e)
        e.msg = name 
        e.msg.add(" not found")
        raise e

proc findByName*(dataType: GRDataType, name: string): GRDataType =
    if dataType.kind != List:
        var e: ref ValueError
        new(e)
        e.msg = "Invalid type provided " 
        e.msg.add(dataType.kind.str)
        raise e
    var found = false
    for item in dataType.items:
        if item.name == name:
            found = true
            result = item
            break
    if not found:
        var e: ref ValueError
        new(e)
        e.msg = name 
        e.msg.add(" not found")
        raise e
