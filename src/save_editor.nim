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



# parse arguments
var args = initOptParser("", shortNoVal = {'o', 'g', 'c'},
                              longNoVal = @["online-items", "max-gems"])
var grModOpts = args.parseArgs

if grModOpts.filename == "":
    echo "Invalid file name supplied"
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
proc appendToFileName(fileName: string, name: string): string =
    let fileSplit = splitFile(fileName)
    let newFileName = "$1_$2$3" % [fileSplit.name, name, fileSplit.ext]
    joinPath(fileSplit.dir, newFileName)

if len(outfits) == 0:
    var fileName = grModOpts.filename.appendToFileName("modded")
    echo "Writing to ", fileName
    var fs = newFileStream(fileName, bigEndian, fmWrite)
    fs.write(saveFileMem, len(buffer))
    fs.close()
    discard
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
