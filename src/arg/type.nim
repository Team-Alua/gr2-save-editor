type Cmd* = enum
    Bin2Txt
    Txt2Bin
    Invalid


type SaveOptions* = object
  cmd*: Cmd
  cmdName*: string
  sourceFile*: string
  destinationFile*: string
  args*: seq[string]