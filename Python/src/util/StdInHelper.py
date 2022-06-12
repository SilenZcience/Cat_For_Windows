from sys import stdin
from tempfile import NamedTemporaryFile

def addPipedStdIn(known_files):
    input = ""
    for line in stdin:
        input += line
    return input
    # input = input.rstrip()
    # input = input[:-1] if ord(input[-1:]) == 26 else input
    # print("following:")
    # print(input)
    # print("end!")
    
def writeFromStdIn(unknown_files, piped_input):
    for file in unknown_files:
        print(file, type(file))
        with open(file, 'w', encoding="utf-8") as f:
            f.write(piped_input)
    
    
def readWriteFromStdIn(unknown_files, piped_input):
    print()