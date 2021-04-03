import ./types


proc addDustyToken(edits: var seq[GRMod]): void =
    var edit: GRMod = GRMod(
        targetPath: @["StatisticalChart","DustyToken"], 
        kind: Float,
        floatValue: 99999.0
    )
    edits.add(edit)

proc addCostumes(edits: var seq[GRMod]): void =
    var costumes = @[
        "kit02",
        "kit03",
        "kit05",
        "kit06",
        "kit07",
        "kit08",
        "kit10",
        "kit13",
        "kit14",
        "kit15",
        "kit16",
        "kit18",
        "kit02"
    ]
    for costume in costumes:
        var edit: GRMod = GRMod(targetPath: @["CostumeUnlock", costume], kind: Boolean)
        edit.boolValue = true
        edits.add(edit)

proc addGestures(edits: var seq[GRMod]): void =
    var gestures = @[
        "item_01",
        "item_02",
        "item_03",
        "item_04",
        "item_05",
        "item_06",
        "item_07",
        "item_08",
        "item_09",
        "item_10",
        "item_11",
        "item_12",
        "item_13",
        "item_14",
        "item_15",
        "item_16",
        "item_17",
        "item_18",
        "item_19",
        "item_20"
    ]
    for gesture in gestures:
        var edit: GRMod = GRMod(targetPath: @["Gesture", gesture], kind: Boolean)
        edit.boolValue = true
        edits.add(edit)

proc addHomeInfoUnlocks(edits: var seq[GRMod]): void =
    let homeUnlocks = @[
        "kagu_01_01",
        "kagu_01_02",
        "kagu_01_03",
        "kagu_01_04",
        "kagu_02_01",
        "kagu_02_02",
        "kagu_02_03",
        "kagu_02_04",
        "kagu_03_01",
        "kagu_03_02",
        "kagu_03_03",
        "kagu_03_04",
        "kagu_04_01",
        "kagu_04_02",
        "kagu_04_03",
        "kagu_04_04",
        "kagu_05_01",
        "kagu_05_02",
        "kagu_05_03",
        "kagu_05_04",
        "kagu_06_01",
        "kagu_06_02",
        "kagu_06_03",
        "kagu_06_04",
        "kagu_07_01",
        "kagu_07_02",
        "kagu_07_03",
        "kagu_07_04",
        "kagu_08_01",
        "kagu_08_02",
        "kagu_08_03",
        "kagu_08_04",
        "kagu_09_01",
        "kagu_09_02",
        "kagu_09_03",
        "kagu_10_01",
        "kagu_11_01",
        "kagu_12_01",
        "kagu_13_01"
    ]
    for homeUnlock in homeUnlocks:
        var edit: GRMod = GRMod(targetPath: @["HomeInfo", "Unlock", homeUnlock], kind: Boolean)
        edit.boolValue = true
        edits.add(edit)

proc addPhotoItems(edits: var seq[GRMod]): void =
    var photoItems = @[
        "item_01",
        "item_02",
        "item_03",
        "item_04",
        "item_05",
        "item_06",
        "item_07",
        "item_08",
        "item_09",
        "item_10",
        "item_11",
        "item_12",
        "item_13",
        "item_14",
        "item_15",
        "item_16",
        "item_17",
        "item_18",
        "item_19",
        "item_20",
        "item_21",
        "item_22",
        "item_23",
        "item_24",
        "item_25",
        "item_26",
        "item_27",
        "item_28",
        "item_29"
    ]
    for photoItem in photoItems:
        var edit: GRMod = GRMod(targetPath: @["PhotoItem", photoItem], kind: Boolean)
        edit.boolValue = true
        edits.add(edit)

proc addTailsman(edits: var seq[GRMod]): void =
    var slots= @[
        ("Slot997", [4450.0'f, 24832.0'f, 0.0'f, 0.0'f]),
        ("Slot998", [4745.0'f, 0.0'f, 0.0'f, 0.0'f]),
        ("Slot999", [4875.0'f, 2816.0'f, 0.0'f, 0.0'f])
    ]
    for (name, vector) in slots:
        var edit: GRMod = GRMod(targetPath: @["Talisman", name], kind: Vector)
        edit.vectorValue = vector
        edits.add(edit)

proc addMaxGems(edits: var seq[GRMod]): void =
    var typeValues = @[("Hi", 15.0'f), ("Lo", 16974.0'f)]

    var gemInfoTypes = @[
        "PreciousGemNum",
        "TotalPreciousGemNum"
    ]
    for gemInfoType in gemInfoTypes:
        for (typeName, typeValue) in typeValues:
            var edit: GRMod = GRMod(targetPath: @["GemInfo", gemInfoType, typeName], kind: Float)
            edit.floatValue = typeValue
            edits.add(edit)


proc newOnlineEdits*(modOptions: GRModOption): seq[GRMod] = 
    var edits: seq[GRMod] = newSeq[GRMod]()
    if modOptions.onlineItems:
        edits.addDustyToken
        edits.addCostumes
        edits.addGestures
        edits.addHomeInfoUnlocks
        edits.addPhotoItems
        edits.addTailsman
    return edits

proc newMaxGemEdits*(modOptions: GRModOption): seq[GRMod] = 
    var edits: seq[GRMod] = newSeq[GRMod]()
    if modOptions.maxGems:
        edits.addMaxGems

proc newOutFitEdits*(modOptions: GRModOption): seq[GRMod] = 
    var edits: seq[GRMod] = newSeq[GRMod]()
    for costume in modOptions.costumes:
        if costume == "":
            continue
        var edit: GRMod = GRMod(targetPath: @["Player", "Costume"], kind: String)
        edit.stringValue = costume
        edits.add(edit)
    return edits

proc newEdits*(modOptions: GRModOption): seq[GRMod] =
    var edits: seq[GRMod] = newSeq[GRMod]()
    edits.add(newOnlineEdits(modOptions))
    edits.add(newMaxGemEdits(modOptions))
    result = edits


