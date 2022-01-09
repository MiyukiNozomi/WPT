module sources;

import std.string;
import std.file : readText;

private string[] sourceUrls;

public void loadSources() {
    string raw = readText("sources.smh");
    sourceUrls = raw.splitLines();
}

import std.stdio : writeln, writefln;
import std.file : read, write, mkdir, exists;
import std.net.curl;

import std.zip;

public bool unpackPackage(string pack) {
    writeln("Installing package...");

    if (exists("installed/" ~ pack)) {
        writeln("Package has already been installed!");
        return true;
    }

    ZipArchive archive = new ZipArchive(read("downloaded-packages-raw/" ~ pack ~ ".zip"));

    writeln("Checking filesystem..");

    if (!exists("installed"))
    mkdir("installed/");
    mkdir("installed/" ~pack ~"/");

    foreach (name, am; archive.directory) {
        writefln("%10s  %08x  %s", am.expandedSize, am.crc32, name);
        
        if (name.endsWith("/")) {
            mkdir("installed/" ~ pack ~ "/" ~ name);
        } else {
            archive.expand(am);
            write("installed/" ~ pack ~ "/" ~ name, am.expandedData());
        }
    }
    
    return true;
}

public bool downloadPackage(string pack, string source, string ver = "latest") {
    try {
        download(source ~ "/download/" ~ pack ~ "/" ~ ver ~ ".zip", "downloaded-packages-raw/" ~ pack ~ ".zip");
        
        try {
        string res = readText("downloaded-packages-raw/" ~ pack ~ ".zip");

        if (res == "not found bruh" || res == "fail to send") {
            return false;
        }
        } catch(Exception e) {}
        
        return true; 
    } catch(Throwable e) {
        writeln(e.toString());
        return false;
    }
}

public string[] searchForPackage(string pack) {
    string[] sources;
    
    for (int i = 0; i < sourceUrls.length; i++) {
        try {
            auto returnContent = get(sourceUrls[i] ~ "/hasPackage?package=" ~ pack);
            writeln(returnContent);
            if (returnContent == "yes") {
                sources ~= sourceUrls[i];
            }
        } catch(Throwable e) {
            writeln("Failed to ask: ", sourceUrls[i], " rude server :(");
            writeln(e.toString());
        }
    }

    return sources;
} 