import pyperclip3 as pc
from os import remove
from os.path import getctime, realpath, exists
from datetime import datetime
from itertools import groupby
from sys import executable
from sys import exit as sysexit
from util.StdInHelper import *
from util.parseArg import *
from util.ArgConstants import *
from util.checksum import *
from util.Converter import _fromDEC, _fromHEX, _fromBIN, is_decimal, is_hex, is_bin

class Holder():
    files = []
    args = []
    args_id = []
    lineSum = 0
    fileCount = 0
    fileLineMaxLength = 0
    fileMaxLength = 0
    clipBoard = ""
    
holder = Holder()

def _showHelp():
    print("Usage: cat [FILE]... [OPTION]...")
    print("Concatenate FILE(s) to standard output.")
    print()
    for x in ALL_ARGS:
        print("%-25s" % str("\t" + x.shortForm + ", " + x.longForm), end=x.help + "\n")
    print()
    print("%-25s" % str("\t'[a;b]':"), end="replace a with b in every line.\n")
    print("%-25s" % str("\t'[a:b]':"), end="python-like string manipulation syntax.\n")
    print()
    print("Examples:")
    print("%-25s" % str("\tcat f g -r"), end="Output g's contents in reverse order, then f's content in reverse order\n")
    print("%-25s" % str("\tcat f g -ne"), end="Output f's, then g's content, while numerating and showing the end of lines.\n")
    sysexit(0)

def _showVersion():
    print()
    print("------------------------------------------------------------")
    print("Cat 1.4.1.7")
    print("------------------------------------------------------------")
    print()
    print("Python: \t 3.10.0 (tags/v3.10.0:b494f59, Oct  4 2021, 19:00:18) [MSC v.1929 64 bit (AMD64)]") #sys.version
    print("Build time: \t " + str(datetime.fromtimestamp(getctime(realpath(executable)))) + " CET")
    print("Author: \t Silas A. Kraume")
    sysexit(0)

def _showDebug(args, known_files, unknown_files):
    print("Debug Information:")
    print("args: ", end="")
    print(args)
    print("known_files:", end="")
    print(known_files)
    print("unknown_files:", end="")
    print(unknown_files)

def _count_generator(reader):
    b = reader(1024 * 1024)
    while b:
        yield b
        b = reader(1024 * 1024)

def _getFileLinesSum(file):
    with open(file, 'rb') as fp:
        c_generator = _count_generator(fp.raw.read)
        count = sum(buffer.count(b'\n') for buffer in c_generator)
        return count + 1

def _getFilesLinesSum():
    return sum([_getFileLinesSum(file) for file in holder.files])

def _getFileLineMaxLength():
    return len(str(holder.fileCount)) if ARGS_REVERSE in holder.args_id else len(str(holder.lineSum))

def _getFileMaxLength():
    return len(str(len(holder.files)))

def _getLineWithPrefix(index, line_num):
    line_prefix = str(line_num) + ")  "
    for i in range(len(str(line_num)), holder.fileLineMaxLength-1):
        line_prefix += " "
    file_prefix = ""
    if len(holder.files) > 1:
        file_prefix += str(index)
        for i in range(len(str(index)), holder.fileMaxLength-1):
            file_prefix += " "
        file_prefix += "."
    
    return file_prefix + line_prefix
    
def printFile(fileIndex = 1):
    content = []
    try:
        with open(holder.files[fileIndex-1], 'r') as f:
            content = f.read().splitlines()
    except:
        print("failed!", holder.files[fileIndex-1])
        inp = input("Do you want to open the file as a binary?")
        if not 'y' in inp and not 'Y' in inp: return
        try:
            with open(holder.files[fileIndex-1], 'rb') as f:
                content = f.read().splitlines()
        except:
            print("Operation failed!")
            return
    length = len(content)
    for i, arg in enumerate(holder.args_id):
        if arg == ARGS_NUMBER:
            content = [_getLineWithPrefix(fileIndex, holder.fileCount-i if ARGS_REVERSE in holder.args_id else holder.fileCount+i+1) + c for i, c in enumerate(content)]
        if arg == ARGS_ENDS:
            content = [c + "$" for c in content]
        if arg == ARGS_TABS:
            content = [c.replace("\t", "^I") for c in content]
        if arg == ARGS_SQUEEZE:
            content = [g[0] for g in groupby(content)]
        if arg == ARGS_REVERSE:
            content.reverse()
        if arg == ARGS_BLANK:
            content = [c for c in content if c]
        if arg == ARGS_DEC:
            if holder.args[i][1] == "-dec":
                content = [_fromDEC(int(c), True) for c in content if is_decimal(c)]
            else:
                content = [_fromDEC(int(c)) for c in content if is_decimal(c)]
        if arg == ARGS_HEX:
            if holder.args[i][1] == "-hex":
                content = [_fromHEX(c, True) for c in content if is_hex(c)]
            else:
                content = [_fromHEX(c) for c in content if is_hex(c)]
        if arg == ARGS_BIN:
            if holder.args[i][1] == "-bin":
                content = [_fromBIN(c, True) for c in content if is_bin(c)]
            else:
                content = [_fromBIN(c) for c in content if is_bin(c)]
        if arg == HIGHEST_ARG_ID+1:
            content = [eval(repr(c) + holder.args[i][1]) for c in content]
        if arg == HIGHEST_ARG_ID+2:
            replace_values = holder.args[i][1][1:-1].split(";")
            content = [c.replace(replace_values[0], replace_values[1]) for c in content]
    print(*content, sep="\n")
    if ARGS_CLIP in holder.args_id:
        holder.clipBoard += "\n".join(content)


def printFiles():
    reversed = ARGS_REVERSE in holder.args_id
    holder.lineSum = _getFilesLinesSum()
    holder.fileCount = holder.lineSum if reversed else 0
    holder.fileLineMaxLength = _getFileLineMaxLength()
    
    holder.fileMaxLength = _getFileMaxLength()
    start = len(holder.files)-1 if reversed else 0
    end = -1 if reversed else len(holder.files)
    if ARGS_CHECKSUM in holder.args_id:
        for file in holder.files:
            print("Checksum of '" + file + "':")
            print(getChecksumFromFile(file))
    else:
        for i in range(start, end, -1 if reversed else 1):
            printFile(i+1)
        if ARGS_COUNT in holder.args_id:
            print()
            print("Lines: " + str(holder.lineSum))
        if ARGS_FILES in holder.args_id:
            print()
            print("applied FILE(s):", end="")
            print("", *holder.files, sep="\n\t")
        if ARGS_CLIP in holder.args_id:
            pc.copy(holder.clipBoard)
            
def main():
    piped_input = temp_file = ""
    holder.args, known_files, unknown_files = getArguments()
    holder.args_id = [x[0] for x in holder.args]
    if (len(known_files) == 0 and len(unknown_files) == 0 and len(holder.args) == 0) or ARGS_HELP in holder.args_id:
        _showHelp()
    if ARGS_VERSION in holder.args_id:
        _showVersion()
    if ARGS_DEBUG in holder.args_id:
        _showDebug(holder.args, known_files, unknown_files)
    if ARGS_INTERACTIVE in holder.args_id:
        piped_input = addPipedStdIn()
        temp_file = writeTemp(piped_input)
        known_files.append(temp_file)
        writeFromStdIn(unknown_files, piped_input)
    else:
        readWriteFromStdIn(unknown_files)
    
    holder.files = [*known_files, *unknown_files]
    
    printFiles()
    
    if exists(temp_file):
        remove(temp_file)
    
if __name__ == "__main__":
    main()
#pyinstaller cat.py --onefile --clean --dist ../bin

#TODO: update README