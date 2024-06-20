# Delete Old Branches Script

This script deletes old branches from a Git repository based on certain conditions.

## Constants

- `SLEEP_TIME`: The sleep time between deletions.
- `MAX_DELETIONS`: The maximum number of branches to delete.
- `BRANCH_AGE_LIMIT`: The age limit for branches. Branches older than this limit will be deleted.
- `CHECK_MERGED`: Whether to check if a branch has been merged before deleting it.
- `MERGE_CHECK_BRANCH`: The branch name to check if other branches have been merged into.
- `BRANCH_NAME_PART`: A string that the branch name must contain to be deleted.
- `PROTECTED_BRANCHES`: A list of branches that should never be deleted.


## Usage

1. Navigate to the directory of the repository where you want to delete old branches.
2. Set the constants in the script to your desired values.
3. Run the script with `./delete-old-branches.sh`.
