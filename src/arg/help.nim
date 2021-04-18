import strutils
import os

proc getHelp*(): void =
    var fileName = splitPath(getAppFilename())[1]
    echo "usage: $1 [options] fileName" % [fileName]
