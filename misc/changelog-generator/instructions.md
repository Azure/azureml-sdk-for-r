
### Creating Pull Requests for Inclusion in NEWS.md

If a PR is significant enough to warrant a mention in the next release notes update,
its name should begin with a prefix. 
There are three options depending on the PR's
purpose.

  * `breaking-change: ` if the change will make the next tag non-backward-compatible
  * `feature: ` if the change is a major addition that maintains backward-compatibility
  * `fix: ` if the change is a bug fix, security patch, or other improvement

If the PR does not begin with one of these prefixes, it WILL NOT be included in
the release notes, so make sure to name important PRs accordingly. 

### Generating Notes and Creating a New Tag

To update release notes for and commit a new git tag:

1. Navigate to this directory in while on master branch
2. Run `node changelog_generator.js` on the command line
3. Confirm version was updated in package.json and notes were added to NEWS.md
4. Push to **origin/master** (this can only be done by owners/admins).

The generator follows semantic versioning, so:

  * If there have been breaking changes since the last tag, it will increment the 1st (major) version digit by 1 and set the 2nd (minor) and 3rd (patch) to 0. (e.g. 0.6.8 &rightarrow; 1.0.0)
  * If there have been no breaking changes, but there have been feature additions, it will increment the minor digit by 1 and set the patch digit to 0. (e.g. 0.6.8 &rightarrow; 0.7.0)
  * If there have been no breaking changes nor feature additions, but there have been bug fixes, it will increment the patch digit by 1. (e.g. 0.6.8 &rightarrow; 0.6.9)

