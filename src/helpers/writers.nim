import binstreams
import sequtils
proc write*(o: FileStream, i: MemStream, size: int64): void =
    var buffer: array[512, byte]
    var index: int64 = 0
    while index < size:
        i.setPosition(index)
        o.setPosition(index)
        var rwSize: int64 = 512
        if (size - index) < 512:
            rwSize = (size - index)
        i.read(buffer, 0, rwSize)
        o.write(buffer, 0, rwSize)
        index += rwSize

proc write*(o: var seq[byte], i: File): void =
    var fileSize=  i.getFileSize()
    var index: Natural = 0
    var buffer: array[512, byte]
    while index < fileSize:
        var bytesRead: Natural = i.readBuffer(buffer.addr, cast[Natural](512))
        o.add(buffer)
        if bytesRead < 512:
            o.delete(cast[Natural](index + bytesRead), cast[Natural](index + 512))
        index += bytesRead