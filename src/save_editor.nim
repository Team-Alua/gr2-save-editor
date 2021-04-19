# compile with --gc:arc to fix segfault

# edit_list

import parseopt
import segfaults
import "./arg/parser"
import "./arg/help"
import "./arg/type"
import "./arg/validator"

# parse arguments
var args = initOptParser("")
var opts = args.parseArgs

if not validateArgs(opts):
    echo opts.err
    getHelp()
    quit(-1)

