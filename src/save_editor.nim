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

proc write(o: FileStream, i: MemStream): void =
    i.setPosition(0)
    while not i.atEnd:
        o.write(i.read(byte))

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

var opts = GRModOption(maxGems:true,onlineItems: true, skins: @["kit19", "kit04", "cro01", "cro06", "sac01", "oth01", "tkg05"])
var edits: seq[GRMod] = newEdits(opts)
echo len(edits)

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
    fs.write(saveFileMem)
    fs.close()

saveFileMem.close()
