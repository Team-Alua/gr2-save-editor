# compile with --gc:arc to fix segfault

# edit_list
import binstreams
import system
import segfaults
import ./save/types
import ./save/readers
import "./mod/writers"
from "./mod/types" as ModTypes import GRModOption, GRMod, GRModKind
from "./mod/edits" as ModEdits import newEdits, newOutFitEdits
# import parseopt
# Copy to buffer to quickly modify in memory

# -o, --online-items
# -g, --max-gems
# -s, --skin


# var arr: array[2000000, byte]
# system.zeroMem(arr.addr, 2000000)
# arr[0] = 0b1
proc write(o: FileStream, i: MemStream, size: int64): void =
    var buffer: array[512, byte]
    var index: int64 = 0
    while index < size:
        i.setPosition(index)
        o.setPosition(index)
        var rwSize: int64 = 512
        if (size - index) < 512:
            rwSize = (size - index)
        i.read(buffer, 0, rwSize)
        o.write(buffer, 0, rwSize)
        index += rwSize

proc write(o: var seq[byte], i: FileStream): void =
    i.setPosition(0)
    while not i.atEnd:
        o.add(i.read(byte))

var saveFile = newFileStream("data0001.bin", bigEndian , fmRead)

var buffer: seq[byte] = newSeq[byte]()

buffer.write(saveFile)
saveFile.close()

var saveFileMem = newMemStream(buffer, bigEndian)
var sections: seq[GRDataType] 
sections = saveFileMem.readGRSaveFile

# var opts = GRModOption(maxGems:true,onlineItems: true, skins: @["kit19", "kit04", "cro01", "cro06", "sac01", "oth01", "tkg05"])
var opts = GRModOption(skins: @["kit19", "kit04", "cro01", "cro06", "sac01", "oth01", "tkg05"])
var edits: seq[GRMod] = newEdits(opts)

for edit in edits:
    saveFileMem.write(edit, sections)

var outfits: seq[GRMod] = newOutFitEdits(opts)

for outfit in outfits:
    if outfit.kind != GRModKind.String:
        continue
    var ofName = outfit.stringValue
    var fileName = "data0001_"
    fileName.add(ofName)
    fileName.add(".bin")
    saveFileMem.write(outfit, sections)
    var fs = newFileStream(fileName, bigEndian , fmWrite)
    fs.write(saveFileMem, len(buffer))
    fs.close()

saveFileMem.close()
