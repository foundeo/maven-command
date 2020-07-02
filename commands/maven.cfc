/**
 * Scans box.json files for Security Issues
 * .
 * Examples
 * {code:bash}
 * maven 
 * {code}
 **/
component extends="commandbox.system.BaseCommand" excludeFromHelp=false {

	property name="mavenClient"				inject="Maven@maven-client" ;
	property name="progressableDownloader" 	inject="ProgressableDownloader";
	property name="progressBar" 			inject="ProgressBar";


	/**
	* @path.hint path to pom.xml
	* @path.libPath directory path to place jars in
	**/
	function run(path="./pom.xml", libPath="./lib/", boolean verbose="false")  {
		var deps = "";
		var dep = "";
		var depFiles = "";
		var v = "";
		var depData = "";
		var d = "";

		arguments.path = fileSystemUtil.resolvePath(arguments.path);

		if (!fileExists(arguments.path)) {
			error("Path File does not exist: #arguments.path#");
		}

		deps = getDependencies(arguments.path);

		if (arrayLen(deps)) {
			//create directory for libs
			if (arguments.verbose) {
				print.yellowLine("Found #arrayLen(deps)# Dependencies in #getFileFromPath(arguments.path)#");
			}
			arguments.libPath = fileSystemUtil.resolvePath(arguments.libPath);
			if (!directoryExists(arguments.libPath)) {
				directoryCreate(arguments.libPath);
			}

			depFiles = {};
			for (dep in deps) {
				if (!len(dep.version)) {
					print.redLine("Version was not specified for #dep.groupId#:#dep.artifactId#, finding latest release version.");
					depData = mavenClient.getArtifactMetadata(dep.groupId, dep.artifactId);
					if (len(depData.versioning.release)) {
						dep.version = depData.versioning.release;
					} else {
						error("Unable to find a version to use for #dep.groupId#:#dep.artifactId#");
					}

				}
				if (arguments.verbose) {
					print.yellowLine("Found Dependency: #dep.groupId#:#dep.artifactId#:#dep.version#");
				}

				depData = mavenClient.getArtifactAndDependencyJarURLs(dep.groupId, dep.artifactId, dep.version);
				for (d in depData) {
					if (!depFiles.keyExists("#d.groupId#:#d.artifactId#")) {
						depFiles["#d.groupId#:#d.artifactId#"] = d;
					} else {
						//todo use semver to select version?
					}
				}
 			}
 			local.failed = false;
 			for (d in depFiles) {
 				dep = depFiles[d];
 				var result = progressableDownloader.download(
					dep.download,
					fileSystemUtil.resolvePath(arguments.libPath & "/" & getFileFromPath(dep.download)),
					function( status ) {
						progressBar.update( argumentCollection = status );
					}
				);
				if (result.responseCode != 200) {
					local.failed = true;
					print.redLine("X Download #d# resulted in status code: #result.responseCode# -> #dep.download#");
				} else {
					print.greenLine("✓ Downloaded: #getFileFromPath(dep.download)#");
				}

 			}
 			if (local.failed) {
 				print.redLine("One or more jar downloads failed.");
 				return 1;
 			}

		} else {
			print.line("#getFileFromPath(arguments.path)# did not contain any dependencies.");
		}

		
		

	}

	private function getDependencies(path) {
		var pom = mavenClient.parsePOM( fileRead(arguments.path) );
		return pom.dependencies;
	}

	

}