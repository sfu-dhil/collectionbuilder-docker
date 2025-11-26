[![Docker Image Latest Badge](https://ghcr-badge.egpl.dev/sfu-dhil/collectionbuilder-docker/latest_tag?trim=major&label=latest)](https://github.com/sfu-dhil/collectionbuilder-docker/pkgs/container/collectionbuilder-docker)
[![Docker Image Size badge](https://ghcr-badge.egpl.dev/sfu-dhil/collectionbuilder-docker/size)](https://github.com/sfu-dhil/collectionbuilder-docker/pkgs/container/collectionbuilder-docker)

# CollectionBuilder-Docker

Based on [collectionbuilder-csv](https://github.com/CollectionBuilder/collectionbuilder-csv/) [(commit 2b61486)](https://github.com/CollectionBuilder/collectionbuilder-csv/tree/2b6148622e85b67b9a921dfc320474cf3e7d83b9), this repository tries to make a base docker image for collection builder that is easily customizable and deployable for various projects and build pipelines.

See the [demo](https://github.com/sfu-dhil/collectionbuilder-docker-demo) for an example.

## Requirements

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)

## General usage

A shell website (no content)

    docker run --rm -it --platform linux/amd64  \
        -p 4000:4000 \
        ghcr.io/sfu-dhil/collectionbuilder-docker

### Loading basic content & pages

The image doesn't contain any site content by default so you will need to mount your content into relevant the container folders (`/app/_data/<your metadata file>`, `/app/_data/<your theme file>`, `/app/pages/<your about page>`, and `/app/_config.yml`)

    docker run --rm -it --platform linux/amd64  \
        -p 4000:4000 \
        -v <PATH TO YOUR metadata csv file>:/app/_data/<metadata csv file> \
        -v <PATH TO YOUR theme yaml file>:/app/_data/theme.yml \
        -v <PATH TO YOUR objects folder>:/app/objects \
        -v <PATH TO YOUR about page>:/app/pages/about.yml \
        -v <PATH TO YOUR _config.yml>:/app/_config.yml \
        -v <PATH TO YOUR favicon.ico>:/app/favicon.ico \
        ghcr.io/sfu-dhil/collectionbuilder-docker
> will run `jekyll serve --host=0.0.0.0` allowing you access your content at `http://localhost:4000`

### Loading advanced content & pages

You can also override the entire `_data` and/or `pages` folders if you need additional metadata or page customization

    docker run --rm -it --platform linux/amd64  \
        -p 4000:4000 \
        -v <PATH TO YOUR _data folder>:/app/_data \
        -v <PATH TO YOUR objects folder>:/app/objects \
        -v <PATH TO YOUR pages folder>:/app/pages \
        -v <PATH TO YOUR _config.yml>:/app/_config.yml \
        -v <PATH TO YOUR favicon.ico>:/app/favicon.ico \
        ghcr.io/sfu-dhil/collectionbuilder-docker

### Loading metadata from remote url/google sheets

The new `cb_remote_csv.rb` plugin optionally allows you to automatically pull a csv file from a remote url via environment variables.

`METADATA_FILE_URL`: the publicly accessible url. For google sheets see the [CollectionBuilder Docs](https://collectionbuilder.github.io/cb-docs/docs/walkthroughs/sheets-walkthrough/#2-publish-your-google-sheet-to-the-web) on how to make your Google Sheets publicly accessible.

This uses the jekyll `:site` `:after_init` hook so it will only trigger once per build (not quite as robust). When developing locally, you will need to trigger a rebuild to re-fetch any changes from the remote file (ex: `touch pages/index.md` or add a space to a page file comment and save).

    docker run --rm -it --platform linux/amd64  \
        -p 4000:4000 \
        -e METADATA_FILE_URL="<GOOGLE SHEETS PUBLIC URL>" \
        -v <PATH TO YOUR _data folder>:/app/_data \
        -v <PATH TO YOUR objects folder>:/app/objects \
        -v <PATH TO YOUR pages folder>:/app/pages \
        -v <PATH TO YOUR _config.yml>:/app/_config.yml \
        -v <PATH TO YOUR favicon.ico>:/app/favicon.ico \
        ghcr.io/sfu-dhil/collectionbuilder-docker


#### Advanced loading metadata from google sheets (github pages)

In addition to using `METADATA_FILE_URL`, you can use a google sheets script to trigger the github pages workflow.

1. Copy `.github/workflows/jekyll.yml` into your project and modify the `METADATA_FILE_URL` environment variable as needed.
1. Generate a [personal access token](https://github.com/settings/tokens) to trigger the workflow. Click `Generate new token` -> `Generate new token` (__not__ classic)
    - Name: `Google Sheets Trigger for <repo>`
    - Resource owner: _the owner of the repo_ (ex: your organization's account or your user account)
    - Expiration: `never`
    - Repository access: `Only select repositories` -> _select the repo_
    - Permissions -> Repository permissions: `Actions` -> `Read and write` (no other permissions selected)
1. Click `Generate token` and copy the token for later
1. In the Google sheet, click `Extensions` -> `Apps Script` -> `Create a new project`
    - Rename to `Github pages trigger for <repo>`
    - Paste the following script in the editor
    - Click `Project Settings` (might need to expand side menu) -> `Add script property` x3
    - property: `GITHUB_TOKEN` value: _the previously generated personal access token_
    - property: `GITHUB_REPO` value: _the full github repo_ (account and name ex: `sfu-dhil/collectionbuilder-docker`)
    - property: `GITHUB_PAGES_WORKFLOW_ID` value: _the workflow id_ for the github pages action (You can use the workflow filename ex: `jekyll.yml`). default is `jekyll.yml`
    - property: `GITHUB_UPDATES_WORKFLOW_ID` value: _the workflow id_ for the update action (You can use the workflow filename ex: `updates.yml`). default is `updates.yml`


```javascript
function onOpen() {
  SpreadsheetApp.getUi()
    .createMenu('⚡ Collection Builder Github Functions')
    .addItem('Publish data to github pages', 'triggerGithubPagesAction')
    .addItem('Create github pull request with updates', 'triggerUpdateObjectsAction')
    .addToUi()
}

const properties = PropertiesService.getScriptProperties()
const GITHUB_PAGES_URL = `https://api.github.com/repos/${properties.getProperty('GITHUB_REPO')}/actions/workflows/${properties.getProperty('GITHUB_PAGES_WORKFLOW_ID') || 'jekyll.yml'}/dispatches`
const GITHUB_UPDATE_OBJECTS_URL = `https://api.github.com/repos/${properties.getProperty('GITHUB_REPO')}/actions/workflows/${properties.getProperty('GITHUB_UPDATES_WORKFLOW_ID') || 'updates.yml'}/dispatches`
const GITHUB_POST_PARAMS = {
  method: 'post',
  contentType: 'application/json',
  payload: JSON.stringify({ 'ref': 'main' }),
  headers: {
    Accept: 'application/vnd.github+json',
    Authorization: `Bearer ${properties.getProperty('GITHUB_TOKEN')}`,
    'X-GitHub-Api-Version': '2022-11-28',
  },
}

function triggerGithubPagesAction() {
  UrlFetchApp.fetch(GITHUB_PAGES_URL, GITHUB_POST_PARAMS)
}

function triggerUpdateObjectsAction() {
  UrlFetchApp.fetch(GITHUB_UPDATE_OBJECTS_URL, GITHUB_POST_PARAMS)
}
```

> Note: when running you will need to give permission to run the app and you will likely get a warning since it is not verified with google

## Build objects (generate_derivatives)

    docker run --rm -it --platform linux/amd64  \
        -v <PATH TO YOUR _data folder>:/app/_data \
        -v <PATH TO YOUR objects folder>:/app/objects \
        -v <PATH TO YOUR pages folder>:/app/pages \
        -v <PATH TO YOUR _config.yml>:/app/_config.yml \
        -v <PATH TO YOUR favicon.ico>:/app/favicon.ico \
        -v <export path>:/app/_site \
        ghcr.io/sfu-dhil/collectionbuilder-docker rake generate_derivatives

## Build for deployment

You can build the production version by additionally mounting the `/app/_site` and running the `rake deploy`

    docker run --rm -it --platform linux/amd64  \
        -v <PATH TO YOUR _data folder>:/app/_data \
        -v <PATH TO YOUR objects folder>:/app/objects \
        -v <PATH TO YOUR pages folder>:/app/pages \
        -v <PATH TO YOUR _config.yml>:/app/_config.yml \
        -v <PATH TO YOUR favicon.ico>:/app/favicon.ico \
        -v <export path>:/app/_site \
        ghcr.io/sfu-dhil/collectionbuilder-docker rake deploy

## Update Gemfile / Gemfile.lock

Add a new dep:

    docker run --rm -it --platform linux/amd64 -v ${PWD}/app:/app -w /app ruby:3.4-bookworm bundle add <GEM NAME>

Update `Gemfile` and `Gemfile.lock` (if you edit `Gemfile` directly):

    docker run --rm -it --platform linux/amd64 -v ${PWD}/app:/app -w /app ruby:3.4-bookworm bundle install

Update just `Gemfile.lock` (if it's outdated or removed for some reason):

    docker run --rm -it --platform linux/amd64 -v ${PWD}/app:/app -w /app ruby:3.4-bookworm bundle lock
