if [ $TRAVIS_BRANCH = 'master' ] && [ $TRAVIS_PULL_REQUEST = 'false' ]; then
    # Temporary dir for storing new packaged charts and index files
    BUILD_DIR=$(mktemp -d)

    # Push temporary directory to the stack
    pushd $BUILD_DIR

    # Iterate over all charts are package them push it to Harbor
    for dir in `ls ${REPO_DIR}/${CHART_FOLDER}`; do
    helm dep update ${REPO_DIR}/${CHART_FOLDER}/$dir
    helm package ${REPO_DIR}/${CHART_FOLDER}/$dir
    helm push --username ${HARBOR_USERNAME} --password ${HARBOR_PASSWORD}  ${REPO_DIR}/${CHART_FOLDER}/$dir ${HARBOR_CHART_URL}/${HARBOR_PROJECT_NAME}
    if [ $? != 0 ]; then
    travis_terminate 1
    fi
    done

    # Indexing of charts
    if [ -f index.yaml ]; then
    helm repo index --url ${HARBOR_CHART_URL}/${HARBOR_PROJECT_NAME} --merge index.yaml .
    else
    helm repo index --url ${HARBOR_CHART_URL}/${HARBOR_PROJECT_NAME} .
    fi

    # Pop temporary directory from the stack
    popd

    # List all the contents that we will push
    ls ${BUILD_DIR}

else
    echo "unknow branch"
fi