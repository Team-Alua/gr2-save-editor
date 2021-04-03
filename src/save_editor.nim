# compile with --gc:arc to fix segfault

# edit_list
import strutils
import os
import binstreams
import parseopt
import system
import segfaults
import "./arg_parser"
import "./save/types"
import "./save/readers"
import "./helpers/writers"
from "./mod/types" as ModTypes import GRModOption, GRMod, GRModKind
from "./mod/edits" as ModEdits import newEdits, newOutFitEdits
from "./mod/writers" as ModWriters import write

proc getHelp(): void =
    var fileName = splitPath(getAppFilename())[1]
    let costumeChoices = ["kit19", "kit04", "cro01", "cro06", "sac01", "oth01", "tkg05"]
    let saveFileName = "Mydata0000.bin"
    echo "usage: $1 [options] fileName" % [fileName]
    echo "\toptions:"
    echo "\t\t-o, --online-items  Add all online items and dusty tokens"
    echo "\t\t-g, --max-gems      Set gems to max"
    echo "\t\t-c, --costume       Set Costume"
    echo "\t\t                    Choices are $1 All" % join(costumeChoices, " ")
    echo ""
    echo "\tExamples:"
    echo ""
    echo "\t\t$1 -o $2" % [fileName, saveFileName]
    echo ""
    echo "\t\t$1 -g $2" % [fileName, saveFileName]
    echo ""
    echo "\t\t$1 -o -g $2 or $1 -og $2 " % [fileName, saveFileName]
    echo ""
    echo "\t\t$1 -og -c:kit04 $2" % [fileName, saveFileName]
    echo ""
    echo "\t\t$1 -og -c:kit19,kit04,cro01 $2" % [fileName, saveFileName]
    echo ""
    echo "\t\t$1 -og -c:All $2" % [fileName, saveFileName]
    echo ""
    echo "\t\t$1 -og -c:$2 $3" % [fileName, join(costumeChoices, ","), saveFileName]
    echo ""

proc shouldMod(opts: GRModOption): bool = 
    let gems = opts.maxGems
    let online = opts.onlineItems
    var hasOneCostume: bool = false
    for costume in opts.costumes:
        if costume != "":
            hasOneCostume = true
            break
    return gems or online or hasOneCostume

proc appendToFileName(fileName: string, name: string): string =
    let fileSplit = splitFile(fileName)
    let newFileName = "$1_$2$3" % [fileSplit.name, name, fileSplit.ext]
    joinPath(fileSplit.dir, newFileName)

# parse arguments
var args = initOptParser("", shortNoVal = {'o', 'g', 'c'},
                              longNoVal = @["online-items", ""])
var grModOpts = args.parseArgs

if grModOpts.filename == "":
    echo "Invalid file name supplied."
    getHelp()
    quit(-1)

if not shouldMod(grModOpts):
    echo "Nothing to do."
    getHelp()
    quit(-1)

# write file to sequence for quicker access
var saveFile = open(grModOpts.filename, fmRead, 512)
var buffer: seq[byte] = newSeq[byte]()
buffer.write(saveFile)
saveFile.close()

var saveFileMem = newMemStream(buffer, bigEndian)

# parse gravity rush 2 save file
var sections: seq[GRDataType] 
sections = saveFileMem.readGRSaveFile

# generate the necessary edits for non costume types
var edits: seq[GRMod] = newEdits(grModOpts)

for edit in edits:
    saveFileMem.write(edit, sections)



# generate necessary costume edits
var outfits: seq[GRMod] = newOutFitEdits(grModOpts)

if len(outfits) == 0:
    var fileName = grModOpts.filename.appendToFileName("modded")
    echo "Writing to ", fileName
    var fs = newFileStream(fileName, bigEndian, fmWrite)
    fs.write(saveFileMem, len(buffer))
    fs.close()
else:
    for outfit in outfits:
        if outfit.kind != GRModKind.String:
            continue
        var ofName = outfit.stringValue
        var fileName = grModOpts.filename.appendToFileName(ofName)
        echo "Writing to ", fileName
        saveFileMem.write(outfit, sections)
        var fs = newFileStream(fileName, bigEndian , fmWrite)
        fs.write(saveFileMem, len(buffer))
        fs.close()

saveFileMem.close()
