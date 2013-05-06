#!/bin/sh -

# build data file that is included in the source
# so we can automatically report Git repo information
# in the application

if [[ ! -d ".git" ]]; then
    lastRepoTag=`cat VERSION | grep version | awk '{print $2}'`
    lastCommitHash=`cat VERSION | grep commit | awk '{print $2}'`
else
    echo "Get Information from system"

    # Date and time that we are running this build
    buildDate=`date "+%F %H:%M:%S"`

    # Current branch in use
    currentBranchTemp=`git rev-parse --abbrev-ref HEAD`
    if [ -n "$currentBranchTemp" ]
    then
    currentBranch=$currentBranchTemp
    else
    currentBranch=""
    fi

    # Last hash from the current branch
    lastCommitHashTemp=`git rev-parse --short HEAD`
    if [ -n "$lastCommitHashTemp" ]
    then
    lastCommitHash=$lastCommitHashTemp
    else
    lastCommitHash=""
    fi

    # Date and time of the last commit on this branch
    lastCommitDateTemp=`git log --pretty=format:"%ad" --date=short -1`
    if [ -n "$" ]
    then
    lastCommitDate=$lastCommitDateTemp
    else
    lastCommitDate=""
    fi

    # Comment from the last commit on this branch
    lastCommitCommentTemp=`git log --pretty=format:"%s" -1`
    if [ -n "$" ]
    then
    lastCommitComment=$lastCommitCommentTemp
    else
    lastCommitComment=""
    fi

    # Last tag applied to this branch
    lastRepoTagTemp=`git describe --abbrev=0 --tags`
    if [ -n "$lastRepoTagTemp" ]
    then
    lastRepoTag=$lastRepoTagTemp
    else
    lastRepoTag="0.0.0"
    fi

    # Build the file with all the information in it
    # echo "Create header file"

    # echo "//-----------------------------------------" > $gitDataFile
    # echo "// Auto generated file" >> $gitDataFile
    # echo "// Created $buildDate" >> $gitDataFile
    # echo "//-----------------------------------------" >> $gitDataFile
    # echo "" >> $gitDataFile
    # echo "#define BUILD_DATE              @ \"$buildDate\"" >> $gitDataFile
    # echo "#define GIT_CURRENT_BRANCH      @ \"$currentBranch\"" >> $gitDataFile
    # echo "#define GIT_LAST_COMMIT_HASH    @ \"$lastCommitHash\"" >> $gitDataFile
    # echo "#define GIT_LAST_COMMIT_DATE    @ \"$lastCommitDate\"" >> $gitDataFile
    # echo "#define GIT_LAST_COMMIT_COMMENT @ \"$lastCommitComment\"" >> $gitDataFile
    # echo "#define GIT_LAST_REPO_TAG       @ \"$lastRepoTag\"" >> $gitDataFile
    # echo "#define AUTOVERSION $lastRepoTag" >> $gitDataFile
fi

version="${lastRepoTag}"
commit="${lastCommitHash}"
echo $commit

if [ -f "$1" ]
then
    echo "Modifying $1"
	sed -i .bak -E "s/^(__commit__ = )(None)$/\1\"${commit}\"/" $1 || exit 3
	sed -i .bak -E "s/^(__version__ = )\"([^\"]*)\"/\1\"${version}\"/" $1 || exit 3
    rm $1.bak
elif [ -z "$1" ]
then
    echo "Must supply a file to modify"
    exit 1
else
    echo "File $1 does not exist"
    exit 2
fi
