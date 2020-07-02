# maven-command

A CommandBox command for installing jar files from the maven central repository.

## Usage

	box maven

In the above usage it will look for a `pom.xml` file in the current directory and download all jar dependencies found and place them into a `lib/` subfolder.

If you want to use a different file name, or specify a different location to put the jar files, use the `path` and `libPath` options.

	box maven path=pom-pom.xml libPath=jars/

Verbose output can be added with `--verbose`

## Example POM XML File

Here's an example POM file that downloads bcrypt

	<?xml version="1.0"?>
	<project>
		<dependencies>
			<dependency>
			    <groupId>org.mindrot</groupId>
			    <artifactId>jbcrypt</artifactId>
			</dependency>
		</dependencies>
	</project>

In the above example we didn't specify a version, so the latest release version will be queried and used.

If you want to specify an exact version, then use:

	<?xml version="1.0"?>
	<project>
		<dependencies>
			<dependency>
			    <groupId>org.mindrot</groupId>
			    <artifactId>jbcrypt</artifactId>
			    <version>0.4</version>
			</dependency>
		</dependencies>
	</project>

