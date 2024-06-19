# Constants
SLEEP_TIME=2
MAX_DELETIONS=4000
BRANCH_AGE_LIMIT=0
CHECK_MERGED=true
BRANCH_NAME_PART=""
PROTECTED_BRANCHES=("origin" "master" "main" "production" "stage") # Add protected branches here
MERGE_CHECK_BRANCH="origin/master" # Add the branch name to check if other branches have been merged into

# Fetch all remote branches
git fetch --prune
echo "Done fetching all remote branches."

# Get current date
echo "Getting current date..."
current_date=$(date +%s)
echo "Current date is $current_date."

# Save the original IFS
oldIFS=$IFS
# Set IFS to newline only for the purpose of this loop
IFS=$'\n'

# Initialize deletion counter
delete_counter=0

# Loop over all branches
echo "Looping over all branches..."
for branch in $(git branch -r --format '%(refname:short) %(committerdate:unix)'); do
    # Extract branch name and commit date
    branch_name=$(echo $branch | cut -f1 -d' ')
    commit_date=$(echo $branch | cut -f2 -d' ')
    # Convert Unix timestamp to human-readable date
    commit_date_human=$(date -r $commit_date)
    echo "Processing branch $branch_name with commit date [$commit_date_human]."

    # Extract branch name and remove 'origin/' prefix
    branch_name=$(echo $branch | cut -f1 -d' ' | sed 's/^origin\///')

    # Calculate age of branch
    branch_age_years=$(echo "scale=2; ($current_date - $commit_date) / 31536000" | bc)
    echo "Branch $branch_name is $branch_age_years years old."

    # If branch is older than BRANCH_AGE_LIMIT years, branch name contains BRANCH_NAME_PART (case insensitive),
    # branch is not in the list of protected branches, and we haven't deleted MAX_DELETIONS branches yet
    if (( $(echo "$branch_age_years > $BRANCH_AGE_LIMIT" | bc -l) )) && \
       [[ $(echo "$branch_name" | tr '[:upper:]' '[:lower:]') == *$(echo "$BRANCH_NAME_PART" | tr '[:upper:]' '[:lower:]')* ]] && \
       ! [[ " ${PROTECTED_BRANCHES[@]} " =~ " ${branch_name} " ]] && \
       [ $delete_counter -lt $MAX_DELETIONS ]; then

        # If CHECK_MERGED is true, check if the branch has been merged into MERGE_CHECK_BRANCH
        if $CHECK_MERGED && ! git branch -r --merged $MERGE_CHECK_BRANCH | grep -q "$branch_name"; then
            echo "Branch $branch_name has not been merged into $MERGE_CHECK_BRANCH. Skipping..."
            continue
        fi

        # Delete branch
        echo "Branch $branch_name is older than $BRANCH_AGE_LIMIT years. Deleting..."
        git push origin --delete $branch_name
        echo "Deleted branch $branch_name."
        # Sleep for SLEEP_TIME seconds
        sleep $SLEEP_TIME
        # Increment deletion counter
        ((delete_counter++))

        # If we have deleted MAX_DELETIONS branches, exit the loop
        if [ $delete_counter -eq $MAX_DELETIONS ]; then
            echo "Deleted $MAX_DELETIONS branches. Exiting..."
            break
        fi
    else
        echo "Branch $branch_name is not older than $BRANCH_AGE_LIMIT years or does not contain '$BRANCH_NAME_PART' or is protected. Skipping..."
    fi
done
echo "Done processing all branches."

# Restore the original IFS
IFS=$oldIFS
