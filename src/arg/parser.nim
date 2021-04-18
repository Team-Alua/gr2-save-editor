import parseopt
import strutils
import "./type" 

proc getCmdType(cmdType: string): Cmd =
  if cmdType.toLower() == "bin2txt":
    return Bin2Txt
  if cmdType.toLower() == "txt2bin": 
    return Txt2Bin 
  return Invalid

proc parseArgs*(p: var OptParser): SaveOptions =
  var opts = SaveOptions()
  var cmdIndex = 1
  while true:
    p.next()
    if p.kind == cmdArgument:
      if cmdIndex == 1:
        opts.cmd = getCmdType(p.key);
      elif cmdIndex == 2:
        opts.sourceFile = p.key;
      elif cmdIndex == 3:
        opts.destinationFile = p.key;
      else:
        opts.args.add(p.key);
      cmdIndex += 1
    if p.kind == cmdEnd:
      break
  result = opts