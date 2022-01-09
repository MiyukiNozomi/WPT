import std.stdio;

import sources;

void main(string[] args) {

	loadSources();

	if (args.length == 1) { writeln("Windows Package Tool - Version MiyukiLazyness249683"); return; }
	if (args[1] == "install") {
		if (args.length >= 3) {
			string packag = args[2];
			string[] foundIn = searchForPackage(packag);

			if (foundIn.length != 0) {
				//writeln("found but not downloaded because too lazy to do so");
				writeln("Installing package: ", packag);
				writeln("Downloading from: " , foundIn[0], "/download/", packag, "/latest.zip");
				writeln("Saving to: ","downloaded-packages-raw/" ~ packag ~ ".zip");
				if (downloadPackage(packag, foundIn[0])) {
					writeln("Successfully downloaded: ", packag, "!!!!!");
					unpackPackage(packag);
				} else {
					writeln("Failed to download it bruh!");
				}
			} else 
				writeln("Package: "~ packag ~ " isn't a thing in sources.smh");
		} else {
			writeln("could you specify a package?");
		}
	}
}