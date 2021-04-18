# compile with --gc:arc to fix segfault

# edit_list

import parseopt
import segfaults
import "./arg/parser"
import "./arg/validator"

# parse arguments
var args = initOptParser("")
var opts = args.parseArgs

validateArgs(opts)