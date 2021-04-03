import parseopt
import pkg/nregex
import strutils
from "./mod/types" as ModTypes import GRModOption, GRMod, GRModKind
# -o, --online-items
# -g, --max-gems
# -c, --costume

proc parseCostumeArg(costumeArgs: string, opts: var GRModOption): void =
  const costumeChoices = ["kit19", "kit04", "cro01", "cro06", "sac01", "oth01", "tkg05"]
  for costumeArg in costumeArgs.split(','):
    if costumeArg == "All":
      for index in 1..len(costumeChoices):
        opts.costumes[index - 1] = costumeChoices[index - 1]
    else:
      var costIndex = costumeChoices.find(costumeArg)
      if costIndex == -1:
        echo "ignored costume choice: ", costumeArg
        continue
      opts.costumes[costIndex] = costumeChoices[costIndex]
 
proc parseArgs*(p: var OptParser): GRModOption =
  var opts = GRModOption()
  for kind, key, val in p.getopt():
    case kind:
    of cmdArgument:
      if contains(key, re"data\d{4}\.bin$"):
        opts.filename = key
    of cmdLongOption, cmdShortOption:
      case key:
      of "o", "online-items": opts.onlineItems = true
      of "g", "max-gems": opts.maxGems = true
      of "c", "costume":
        parseCostumeArg(val, opts)
    of cmdEnd:
      discard
  result = opts