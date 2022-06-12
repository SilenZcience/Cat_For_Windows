class ArgConstant():
    def __init__(self, shortForm, longForm, help, id):
        self.shortForm = shortForm
        self.longForm = longForm
        self.help = help
        self.id = id

ALL_ARGS = [[["-h", "--help"], "show this help message and exit", 0],
            [["-n", "--number"], "number all output lines", 1],
            [["-e", "--ends"], "display $ at end of each line", 2],
            [["-t", "--tabs"], "display TAB characters as ^I", 3],
            [["-s", "--squeeze"], "suppress repeated output lines", 4],
            [["-r", "--reverse"], "reverse output", 5],
            [["-c", "--count"], "show sum of lines", 6],
            [["-b", "--blank"], "hide empty lines", 7],
            [["-o", "--oem"], "read/write in oem-text-encoding", 8],
            [["-f", "--files"], "list applied files", 9],
            [["-i", "--interactive"], "use stdin", 10],
            [["-l", "--clip"], "copy output to clipboard", 11],
            [["-m", "--checksum"], "show the checksums of all files", 12],
            [["--dec", "--dec"], "convert decimal number to hexadecimal and binary", 13],
            [["--hex", "--hex"], "convert hexadecimal number to decimal and binary", 14],
            [["--bin", "--bin"], "convert binary number to decimal and hexadecimal", 15],
            [["-v", "--version"], "output version information and exit", 16],
            [["-d", "--debug"], "show debug information", 17]]

ALL_ARGS = [ArgConstant(x[0][0], x[0][1], x[1], x[2]) for x in ALL_ARGS]
HIGHEST_ARG_ID = len(ALL_ARGS)-1