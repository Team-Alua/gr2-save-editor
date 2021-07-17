import "../arg/type"
import "../save/types"
import "../save/readers"
import "../save/writers" as SaveWriter
import "../helpers/writers" as HelperWriter
import binstreams

proc bin2txt*(opts: SaveOptions): void =
    var saveFile = open(opts.sourceFile, fmRead, 512)
    var buffer: seq[byte] = newSeq[byte]()
    buffer.write(saveFile)
    saveFile.close()
    var saveFileMem = newMemStream(buffer, bigEndian)

    # parse gravity rush 2 save file
    var sections: seq[GRDataType] 
    sections = saveFileMem.readGRSaveFile
    var humanReadableFile = newMemStream(@[], bigEndian)
    humanReadableFile.write(0xEF'u8)
    humanReadableFile.write(0xBB'u8)
    humanReadableFile.write(0xBF'u8)
    humanReadableFile.writeReadable(sections)
    var fs = newFileStream(opts.destinationFile, bigEndian , fmWrite)
    fs.write(humanReadableFile, len(humanReadableFile.data))
    fs.close()