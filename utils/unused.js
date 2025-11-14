/// Finds unused dependencies from pubspec.yaml
///
/// Achieves this by parsing pubspec.yaml and recursively
/// searching the lib folder for an import statement that
/// contains the name of each package. Prints out the results.
const fs = require('fs');
const YAML = require('yaml');
const { execSync } = require('child_process');

/// Read pubspec.yaml
const file = fs.readFileSync('../pubspec.yaml', 'utf8');
const doc = YAML.parseDocument(file);

/// Convenience function to extract keys from a top level key
///
/// Eg, used for getting all the package names from the "dependencies" key
function extractKeys(topLevelKey) {
  //  console.log(topLevelKey);
  return typeof doc.get(topLevelKey) != 'undefined'
    ? doc.get(topLevelKey).items.map(({ key }) => key.value)
    : [];
}

/// Extract deps, overrides, and development deps
const deps = extractKeys('dependencies');
const depOverrides = extractKeys('dependency_overrides');
const devDeps = extractKeys('dev_dependencies');

/// Search the project to see if it's using a certain package
/// by checking for an import statement
function searchProjectForUse(packageName) {
  try {
    /// Will throw error if a file isn't found that contains an import statement
    execSync(`grep -Ril "import 'package:${packageName}" ../lib`);
    return true;
  } catch {
    return false;
  }
}

/// Take a list of package names and search the project for use,
/// return a list of unused packages.
function printListOfUnusedPackagesWithIndents(listOfPackages) {
  listOfPackages.forEach((packageName) => {
    const isUsingPackage = searchProjectForUse(packageName);
    if (isUsingPackage == false) {
      console.log(`  ${packageName}`);
    }
  });
}

console.log(`# Checking pubspec.yaml for dependencies that 
# aren't referenced in import statements...`);

console.log('\ndependencies:');
printListOfUnusedPackagesWithIndents(deps);

console.log('\ndependency_overrides:');
printListOfUnusedPackagesWithIndents(depOverrides);
