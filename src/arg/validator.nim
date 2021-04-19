import "./type" 
import strutils

proc isValidSaveFileName(saveFileName: string): bool =
  if saveFileName.len < 12:
    return false
  var focusStr = saveFileName.substr(saveFileName.len - 12)
  if focusStr[0..3] != "data":
    return false
  for index in 4..7:
    if not focusStr[index].isDigit:
      return false
  return focusStr.endsWith(".bin")

proc isValidSaveTextFileName(saveFileName: string): bool =
    return saveFileName.endsWith(".txt")

proc validateBin2Txt*(opts: SaveOptions): string =
    var err: seq[string] = @[]
    if not isValidSaveFileName(opts.sourceFile):
        err.add("Source file \"$1\" is not of format dataXXXX.bin" % opts.sourceFile) 
    if not isValidSaveTextFileName(opts.destinationFile):
        err.add("Destination file \"$1\" does not have txt extension" % opts.destinationFile) 
    return err.join("\n")

proc validateTxt2Bin*(opts: SaveOptions): string =
    var err: seq[string] = @[]
    if not isValidSaveTextFileName(opts.sourceFile):
        err.add("Source file \"$1\" does not have txt extension" % opts.sourceFile) 
    if not isValidSaveFileName(opts.destinationFile):
        err.add("Destination file \"$1\" is not of format dataXXXX.bin" % opts.destinationFile) 
    return err.join("\n")

proc validateArgs*(opts: var SaveOptions): bool =
    var err: string = ""
    case opts.cmd:
        of Bin2Txt:
            err = validateBin2Txt(opts)
        of Txt2Bin:
            err = validateTxt2Bin(opts)
        of Invalid:
            err = "%s is not a valid command type." % opts.cmdName
    opts.err = err    
    return err.len == 0