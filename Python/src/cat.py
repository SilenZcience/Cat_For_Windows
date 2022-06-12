from os.path import getctime, realpath
from datetime import datetime
from util import parseArg
import util.StdInHelper as StdInHelper
from util.ArgConstants import *

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
    
def main():
    piped_input = ""
    args, known_files, unknown_files = parseArg.getArguments()
    args_id = [x[0] for x in args]
    if (len(known_files) == 0 and len(unknown_files) == 0) or 0 in args_id:
        _showHelp()
    if 16 in args_id:
        _showVersion()
    if 10 in args_id:
        piped_input = StdInHelper.addPipedStdIn(known_files)
    if 17 in args_id:
        _showDebug(args, known_files, unknown_files)
    if len(unknown_files) > 0:
        if 10 in args_id:
            StdInHelper.writeFromStdIn(unknown_files, piped_input)
        else:
            StdInHelper.readWriteFromStdIn(unknown_files, piped_input)
    print(args_id)

    
    
    
    
if __name__ == "__main__":
    main()