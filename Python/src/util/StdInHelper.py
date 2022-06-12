from sys import stdin
from tempfile import NamedTemporaryFile

def writeTemp(content):
    tmp_file = NamedTemporaryFile(delete=False).name
    with open(tmp_file, 'w') as f:
        f.write(content)
    return tmp_file

def addPipedStdIn():
    input = ""
    for line in stdin:
        input += line
    return input
    
def writeFromStdIn(unknown_files, piped_input):
    for file in unknown_files:
        with open(file, 'w') as f:
            f.write(piped_input)
    
    
def readWriteFromStdIn(unknown_files):
    if len(unknown_files) == 0: return
    print("The given FILE(s)", end="")
    print("", *unknown_files, sep="\n\t")
    print("do/does not exist. Write the FILE(s) and finish with the '^Z'-suffix ((Ctrl + Z) + Enter):")
    input = ""
    for line in stdin:
        input += line
    input = input.rstrip()
    if ord(input[-1:]) == 26: input = input[:-1]
    writeFromStdIn(unknown_files, input)