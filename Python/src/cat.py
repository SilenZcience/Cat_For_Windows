import pyperclip3 as pc
from os.path import getctime, realpath
from datetime import datetime
from itertools import groupby  
from util import parseArg
import util.StdInHelper as StdInHelper
from util.ArgConstants import *
from util.checksum import *

class Holder():
    files = []
    args = []
    args_id = []
    lineSum = 0
    fileCount = 0
    fileLineMaxLength = 0
    fileMaxLength = 0
    clipBoard = ""
    
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
    exit()

def _showVersion():
    print()
    print("------------------------------------------------------------")
    print("Cat 1.4.1.6")
    print("------------------------------------------------------------")
    print()
    print("Python: \t 3.10.0 (tags/v3.10.0:b494f59, Oct  4 2021, 19:00:18) [MSC v.1929 64 bit (AMD64)]") #sys.version
    print("Build time: \t " + str(datetime.fromtimestamp(getctime(realpath(__file__)))) + " CET")
    print("Author: \t Silas A. Kraume")
    exit()

def _showDebug(args, known_files, unknown_files):
    print("Debug Information:")
    print("args: ", end="")
    print(args)
    print("known_files:", end="")
    print(known_files)
    print("unknown_files:", end="")
    print(unknown_files)

def _getFileLinesSum(files):
    return sum([sum(1 for _ in open(file)) for file in files])

def _getFileLineMaxLength(holder):
    return len(str(holder.fileCount)) if 5 in holder.args_id else len(str(holder.lineSum))

def _getFileMaxLength(files):
    return len(str(len(files)))

def _getLineWithPrefix(holder, index, line_num):
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
    
def printFile(holder, fileIndex = 1):
    content = []
    with open(holder.files[fileIndex-1], 'r', encoding='utf-8') as f:
        content = f.read().splitlines()
    length = len(content)
    for i, arg in enumerate(holder.args_id):
        if arg == 1:
            content = [_getLineWithPrefix(holder, fileIndex, holder.fileCount-i if 5 in holder.args_id else holder.fileCount+i+1) + c for i, c in enumerate(content)]
        if arg == 2:
            content = [c + "$" for c in content]
        if arg == 3:
            content = [c.replace("\t", "^I") for c in content]
        if arg == 4:
            content = [g[0] for g in groupby(content)]
        if arg == 5:
            content.reverse()
        if arg == 7:
            content = [c for c in content if c]
        # if arg == 13:
        #     #TODO
        # if arg == 14:
        #     #TODO
        # if arg == 15:
        #     #TODO
        if arg == HIGHEST_ARG_ID+1:
            content = [eval(repr(c) + holder.args[i][1]) for c in content]
        if arg == HIGHEST_ARG_ID+2:
            replace_values = holder.args[i][1][1:-1].split(";")
            content = [c.replace(replace_values[0], replace_values[1]) for c in content]
    print(*content, sep="\n")
    if 11 in holder.args_id:
        holder.clipBoard += "\n".join(content)


def printFiles(holder):
    reversed = 5 in holder.args_id
    holder.lineSum = _getFileLinesSum(holder.files)
    holder.fileCount = holder.lineSum if reversed else 0
    holder.fileLineMaxLength = _getFileLineMaxLength(holder)
    
    holder.fileMaxLength = _getFileMaxLength(holder.files)
    start = len(holder.files)-1 if reversed else 0
    end = -1 if reversed else len(holder.files)
    if 12 in holder.args_id:
        for file in holder.files:
            print("Checksum of '" + file + "':")
            print(getChecksumFromFile(file))
    else:
        for i in range(start, end, -1 if reversed else 1):
            printFile(holder, i+1)
        if 11 in holder.args_id:
            pc.copy(holder.clipBoard)
            

def main():
    holder = Holder()
    piped_input = ""
    holder.args, known_files, unknown_files = parseArg.getArguments()
    holder.args_id = [x[0] for x in holder.args]
    if (len(known_files) == 0 and len(unknown_files) == 0) or 0 in holder.args_id:
        _showHelp()
    if 16 in holder.args_id:
        _showVersion()
    if 17 in holder.args_id:
        _showDebug(holder.args, known_files, unknown_files)
    if 10 in holder.args_id:
        piped_input = StdInHelper.addPipedStdIn()
        known_files.append(StdInHelper.writeTemp(piped_input))
        StdInHelper.writeFromStdIn(unknown_files, piped_input)
    else:
        StdInHelper.readWriteFromStdIn(unknown_files)
    
    holder.files = [*known_files, *unknown_files]
    
    printFiles(holder)
    
if __name__ == "__main__":
    main()