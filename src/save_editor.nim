# compile with --gc:arc to fix segfault

# edit_list

import parseopt
import segfaults
import "./arg/parser"
import "./arg/help"
import "./arg/type"
import "./arg/validator"

import "./cmd/bin2txt"

# parse arguments
var args = initOptParser("")
var opts = args.parseArgs

if not validateArgs(opts):
    echo opts.err
    getHelp()
    quit(-1)

case opts.cmd:
    of Bin2Txt:
        bin2txt(opts)
    of Txt2Bin:
        discard
    of Invalid:
        discard