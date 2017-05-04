/**
* A program to convert arbitary files into hex .
* representations. Hex can be printed to the
* console, or written to a file
*
* Author: H Paterson, University of Otago, 2017 
*/

module hexdump.app;

import std.stdio;
import std.format;
import std.getopt;
import std.range;
import std.conv;
import hexdump.constants;

/**
* Entry point for the application.
*
* Usage:
* hexdump source -d=[dest]
*   -source: The file to hexdump
*   -dest:   File to write the dump to.
*            If ommited, hexdump writes to the stdout.
* Params:
*       args = the command line arguments
*       args[1] = the file to convert
*/
void main(string[] args) {
    auto source = new File(args[1], "rb");
    ubyte[] bin = getBin(source);
    string output = formatOutput(bin);
    writeln(output);
}

/**
* getbin, generates bin from a file.
* Params:
*       source - the file to convert into bin
* Returns: A reference to the ubyte array of 
*          representing the file.
*/
ubyte[] getBin(File* source) {
    ubyte[] bin;     //TODO: Make 'bin' a static array for speed
    foreach (ubyte[] buffer; source.byChunk(MB)) {
        bin ~= buffer;
    }
    return bin;
}

/** 
* Formats a ubyte[] into human readable hex.
* Params:
*       bin - the binary data to convert
* Returns: A hex formatted human readable string
* Examples:
*----------------------------------------------------------
* ubyte[9] a = [0xf0, 0xe1, 0xd2, 0xc3, 0xb4, 0xa5, 0x96, 0x87, 0x78];
* string b = getOutput(a);
* assert(b == 
* r"           0   1   2   3   4   5   6   7
* 0000000000  f0  e1  d2  c3  b4  a5  96  87
* 0000000008  78
* ");
*--------------------------------------------------------*/
string formatOutput(ubyte[] bin) {
    //char[] hex =cast(char[]) ("\t\t0\t1\t2\t3\t4\t5\t6\t7\n");
    char[] headline = cast(char[]) "\t";
    foreach (size_t i ; 0..WORD_LENGTH){
        headline ~= "\t" ~ to!string(i);
    }
    headline ~= "\n";
    char[] hex;
    for(int line; WORD_LENGTH * line < bin.length; line++) {
        if (WORD_LENGTH * line + WORD_LENGTH >= bin.length) {
            hex ~= format("%0#0 10x%(\t%1 0 2x%)\n", line * WORD_LENGTH, bin[WORD_LENGTH * line..bin.length]);
        }
        else {
            hex ~= format("%0#0 10x%(\t%1 0 2x%)\n",
                          line * WORD_LENGTH,
                          bin[WORD_LENGTH * line .. WORD_LENGTH * line + WORD_LENGTH]);
        }
    }
    return to!string(headline ~ hex);
}

///Example of getOutput()
unittest {
    ubyte[9] a = [0xf0, 0xe1, 0xd2, 0xc3, 0xb4, 0xa5, 0x96, 0x87, 0x78];
    string b = getOutput(a);
    write(b);
    assert(b == 
r"           0   1   2   3   4   5   6   7
0000000000  f0  e1  d2  c3  b4  a5  96  87
0x00000008  78
");
}
