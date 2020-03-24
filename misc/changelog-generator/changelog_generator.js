'use strict';

var utils = require("./utils.js");

// get log info (and latest tag if not first release)
const child = require("child_process");
const fs = require("fs");
var output;

const pastTags = child.execSync('git tag').toString('utf-8');
if (pastTags.length) {
  const latestTag = child.execSync('git describe --long').toString('utf-8').split('-')[0];
  
  output = child
  .execSync(`git log ${latestTag}..HEAD --format=%B%H----DELIMITER----`)
  .toString("utf-8");
} else {
  output = child
  .execSync(`git log --format=%B%H----DELIMITER----`)
  .toString("utf-8");
}

if (output.length === 0) {
  console.log("No new indicated changes since last tag");
  return process.exit(1);
}

// get array of commits since last tag
const commitsArray = output
.split("----DELIMITER----\n")
.map(commit => {
  const splitCommit = commit.split("\n");
  const sha = splitCommit[1], message = splitCommit[0];
  return { sha, message };
})
.filter(commit => Boolean(commit.sha));

// get current version info
const currNotes = fs.readFileSync("../../NEWS.md", "utf-8");
const currVersion = (require("./package.json").version).split('.');

var major = Number(currVersion[0]), minor = Number(currVersion[1]), patch = Number(currVersion[2]);

// sort commits by message tags
var changes = [], features = [], fixes = [];
var breakingChange = false, addedFunctionality = false, bugPatch = false;

commitsArray.forEach(commit => {
  
  if (commit.message.toLowerCase().startsWith("breaking-change:")) {
    changes = utils.parseMessage("breaking-change:", changes, commit);
    breakingChange = true;
  } else if (commit.message.toLowerCase().startsWith("feature:")) {
    features = utils.parseMessage("feature:", features, commit);
    addedFunctionality = true;
  } else if (commit.message.toLowerCase().startsWith("fix:")) {
    fixes = utils.parseMessage("fix:", fixes, commit);
    bugPatch = true;
  }
});

// update package version (following semantic versioning)
if (changes.length) {
  major += 1;
  minor = 0;
  patch = 0;
} else if (features.length) {
  minor += 1;
  patch = 0;
} else if (fixes.length) {
  patch += 1;
}

const newVersion = [String(major), String(minor), String(patch)].join('.');

// format commits into markdown
let newNotes = `# Version ${newVersion} (${
new Date().toISOString().split("T")[0]
})\n\n`;

if (changes.length) {
  newNotes = utils.formatUpdates(newNotes, `## Breaking Changes\n`, changes);
}
if (features.length) {
  newNotes = utils.formatUpdates(newNotes, `## New Features\n`, features);
}
if (fixes.length) {
  newNotes = utils.formatUpdates(newNotes, `## Bug Fixes\n`, fixes);
}

// prepend the new release notes to the current file
fs.writeFileSync("./NEWS.md", `${newNotes}${currNotes}`);

// update version in package.json
fs.writeFileSync("./package.json", JSON.stringify({ version: String(newVersion) }, null, 2));

// commit and tag new version
child.execSync('git add .');
child.execSync(`git commit -m "Bump to version ${newVersion}"`);
child.execSync(`git tag -a -m "Tag for version ${newVersion}" version${newVersion}`);
