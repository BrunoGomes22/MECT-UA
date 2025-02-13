#include <iostream>
#include <filesystem>
#include <fstream>
#include <map>
#include <locale>
#include <sstream>
#include <codecvt>

using namespace std;
namespace fs = std::filesystem;

// helper function to trim leading and trailing spaces
wstring trim(const wstring &str) {
    const wstring whitespace = L" \t";
    size_t start = str.find_first_not_of(whitespace);
    size_t end = str.find_last_not_of(whitespace);
    return (start == wstring::npos || end == wstring::npos) ? L"" : str.substr(start, end - start + 1);
}

std::string wstring_to_string(const std::wstring &wstr)
{
    std::wstring_convert<std::codecvt_utf8<wchar_t>, wchar_t> converter;
    return converter.to_bytes(wstr);
}

void countWords(wifstream& f, map<wstring, int>& wordDict) {
    wstring line;
    while(getline(f, line)){
        if(((line.find(L"<") != wstring::npos) && (line.find(L">") != wstring::npos))){ // if line contains < and > ignore it
            continue;
        }
        else{
            wistringstream iss(line);
            wstring word;
            while (iss >> word) {
                for(wchar_t & c : word){
                    if(iswpunct(c)){
                        c = L' ';
                    } else if(iswupper(c)){
                        c = towlower(c);
                    }
                }
                word = trim(word);
                if(!word.empty()){
                    wordDict[word]++;
                }
            }
        }
    }
}

void countChars(wifstream& f, map<wchar_t, int>& charDict) {
    wstring line;
    while(getline(f, line)){
        if(((line.find(L"<") != wstring::npos) && (line.find(L">") != wstring::npos))){
            continue;
        }
        else{
            for(wchar_t & c : line){
                if(iswpunct(c)){
                    c = L' ';
                } else if(iswupper(c)){
                    c = towlower(c);
                }
                if(c != L' '){
                    charDict[c]++;
                }
            }
        }
    }
}


void analyzeFile(const string& filePath, map<wstring, int>& wordDict, map<wchar_t, int>& charDict) {
    wifstream f(filePath);
    if(f.is_open()){
        countWords(f, wordDict);
        // reset file pointer to the beginning
        f.clear();
        f.seekg(0, ios::beg);
        countChars(f, charDict);  
    }
    else{
        cerr << "Error: Could not open file " << filePath << endl;
    }
}



void analyzeDirectory(const string& dirPath, map<wstring, int>& wordDict, map<wchar_t, int>& charDict) {
    for (const auto & entry : fs::directory_iterator(dirPath)) {
        if (entry.path().extension() == ".txt") {
            analyzeFile(entry.path().string(), wordDict, charDict);
        }
    }
}


int main(){
    locale::global(locale("en_US.utf8"));
    wcin.imbue(locale("en_US.utf8"));
    wcout.imbue(locale("en_US.utf8"));
    
    map<wstring, int> wordDict;
    map<wchar_t, int> charDict;


    int choice;
    wcout << L"Choose an option:" << endl;
    wcout << L"1. Analyze a single file" << endl;
    wcout << L"2. Analyze all files in a directory" << endl;
    wcout << L"Enter your choice: ";
    wcin >> choice;

    if (choice == 1) {
        wstring filePath;
        wcout << L"Enter the file path: ";
        wcin >> filePath;
        analyzeFile(wstring_to_string(filePath), wordDict, charDict);
    } else if (choice == 2) {
        wstring dirPath;
        wcout << L"Enter the directory path: ";
        wcin >> dirPath;
        analyzeDirectory(wstring_to_string(dirPath), wordDict, charDict);
    } else {
        wcerr << L"Invalid choice" << endl;
        return 1;
    }

    ofstream wordDataFile("wordData.csv");
    for(auto pair : wordDict){
        wcout << pair.first << L" : " << pair.second << endl; 
        wordDataFile << wstring_to_string(pair.first) << "," << pair.second << endl;
    }
    wordDataFile.close();   

    ofstream charDataFile("charData.csv");
    for(auto pair : charDict){
        wcout << pair.first << L" : " << pair.second << endl; 
        charDataFile << pair.first << "," << pair.second << endl;
    }
    charDataFile.close();

    return 0; 
}