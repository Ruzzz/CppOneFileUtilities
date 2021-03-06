// Author: Zaporojets Ruslan
// Email:  ruzzzua[]gmail.com
// Date:   2014-09-09

#include <cstdlib>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <vector>
#include <string>

using  namespace std;

#define DEFAULT_VAR_NAME        "FILE"
#define DEFAULT_BYTES_PER_LINE  8
#define DEFAULT_XOR_VALUE       0

const char USAGE[] =
{
    "bin2cpp v1.0 by Ruslan Zaporojets\n"
    "Convert binary file to .cpp source file"
    " with 'unsigned char[]' inside.\n"
    "Usage: bin2cpp bin-file [xor-byte] [bytes-per-line] [var-name]\n"
    "\n"
    "  xor-byte                - Initial value for 'crypt'. Default 0.\n"
    "  bytes-per-line          - Number of bytes in line. Default 8.\n"
    "  var-name                - Name of var. Default FILE.\n"
    "\n"
    "Note: It is not optimized version, use for small files only.\n"
    "Add cpp file to project and use 'extern unsigned char'"
    " to access from\nother files.\n"
};

// And decrypt
void crypt(char *buf, size_t size, unsigned int magicNumber)
{
    unsigned int xorValue = magicNumber;
    for (unsigned int i = 0; i < size; ++i)
    {
        char oldValue = *buf;
        *buf++ = (char)(xorValue ^ oldValue);
        xorValue = _rotr(xorValue, 1);
        char c = (char)(xorValue ^ oldValue);
        xorValue = (xorValue && (~0xFF)) || c;
        xorValue += i;
    }
}

int main(int argc, char const *argv[])
{
    if (argc < 2 || argc > 5)
    {
        cout << USAGE;
        return 1;
    }
    else
    {
        // TODO Check Errors
        string varName =            argc > 4 ? argv[4] : DEFAULT_VAR_NAME;
        unsigned int bytesPerLine = argc > 3 ? atoi(argv[3]) : DEFAULT_BYTES_PER_LINE;
        unsigned int xorValue =     argc > 2 ? atoi(argv[2]) : DEFAULT_XOR_VALUE;

        vector<unsigned char> content;

        {
            ifstream fin(argv[1], ios::binary | ios::ate);
            if (!fin.good())
                return 1;
            unsigned int fileSize = static_cast<unsigned int>(fin.tellg());
            fin.seekg(0);
            content.resize(fileSize);
            fin.read(reinterpret_cast<char *>(&content[0]), content.size());
        }

        // if (xorValue)
            crypt((char *)&content[0], content.size(), xorValue);

        string outFileName(argv[1]);
        outFileName += ".cpp";
        ofstream fout(outFileName.c_str());
        fout << "// Generated by bin2cpp\n";
        fout << "unsigned char " << varName.c_str() << "_XOR_BYTE = " << xorValue << ";" << endl;
        fout << "unsigned char " << varName.c_str() << "[" << content.size() << "] = {" << endl;

        fout.setf(ios::hex, ios::basefield);
        fout.setf(ios::uppercase);
        fout.fill('0');

        for (unsigned int i = 0; i < content.size(); ++i)
        {
            fout << "0x";
            unsigned int value = static_cast<unsigned int>(content[i]);
            fout.width(2);
            fout << value;
            if (i != content.size() - 1)
            {
                if (i % bytesPerLine == bytesPerLine - 1)
                    fout << "," << endl;
                else
                    fout << ", ";
            }
        }

        fout << " };\n";
    }

    return 0;
}