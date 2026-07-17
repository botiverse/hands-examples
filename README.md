# Hands examples

Copy-ready CI examples and reusable actions for publishing app builds to
[Hands](https://hands.build).

## Start here

1. Install Hands for your Raft server by following the
   [Getting Started guide](https://hands.build/docs/getting-started/).
2. Create an app in Hands.
3. Create an app-scoped `publisher` deploy token in App Settings, or with an
   authorized CLI session:

   ```bash
   hands deploy-tokens create <app-slug> --name github-actions --role publisher
   ```

4. Store the one-time token in your CI secret store as `HANDS_BEARER_TOKEN`.
5. Build and sign your app in your existing CI, then use one of the examples
   below to publish the artifact to Hands.

Hands is the release and distribution layer. Your own build system remains
responsible for compiling and signing the APK, IPA, or other artifact.

## GitHub Actions

### Reusable Android publish action

The composite action at [`publish-android/action.yml`](publish-android/action.yml)
uploads an already-built, signed APK and creates a draft release:

```yaml
- name: Publish draft to Hands
  uses: botiverse/hands-examples/publish-android@v1
  with:
    app: my-android-app
    apk: app/build/outputs/apk/release/app-release.apk
    channel: preview
    version-name: ${{ github.ref_name }}
    version-code: ${{ github.run_number }}
    changelog-file: changelog.txt
    hands-token: ${{ secrets.HANDS_BEARER_TOKEN }}
```

The action defaults to `draft: true`. Activating a release remains a separate,
deliberate review step.

### Complete workflows

- [`android-gradle.yml`](examples/github-actions/android-gradle.yml) builds a
  Gradle Android project, signs it through the project's existing release
  configuration, and publishes the resulting APK as a Hands draft.
- [`publish-existing-apk.yml`](examples/github-actions/publish-existing-apk.yml)
  publishes an APK produced by an earlier job or downloaded from another build
  system.

Copy the selected file into your repository under `.github/workflows/`, then
replace the app slug, Gradle task, and APK path.

## Generic CI or local scripts

[`scripts/publish-android.sh`](scripts/publish-android.sh) is portable across
GitLab CI, Buildkite, Jenkins, and custom runners:

```bash
export HANDS_BEARER_TOKEN='<publisher deploy token>'

./scripts/publish-android.sh \
  --app my-android-app \
  --apk ./app-release.apk \
  --channel preview \
  --version-name 1.0.0 \
  --version-code 1000000 \
  --changelog ./changelog.txt
```

## Security boundary

- Use an app-scoped `publisher` deploy token for CI.
- Store tokens only in the CI platform's encrypted secret store.
- Examples create draft releases by default.
- Never commit signing material, deploy tokens, or generated credentials.

## Reference

- [Hands CLI reference](https://hands.build/docs/cli-reference/)
- [Hands agent guide](https://hands.build/docs/agent-guide/)
- [Hands Android SDK](https://hands.build/docs/android-sdk/)

## GitLab CI

- [`examples/gitlab-ci/android-publish.gitlab-ci.yml`](examples/gitlab-ci/android-publish.gitlab-ci.yml)
  — build stage placeholder + draft publish with `hands builds publish-android`.
- [`examples/gitlab-ci/ios-publish.gitlab-ci.yml`](examples/gitlab-ci/ios-publish.gitlab-ci.yml)
  — IPA + dSYM draft publish; TestFlight upload happens server-side in Hands
  afterwards.

## iOS on GitHub Actions

- [`examples/github-actions/ios-publish.yml`](examples/github-actions/ios-publish.yml)
  — archive/export placeholder + `hands builds publish-ios` draft publish.
  Do not add App Store Connect keys to CI: after review, Hands uploads to
  TestFlight server-side with its stored credential
  ([docs](https://hands.build/docs/ios-testflight/)).

## Electron

- [`examples/github-actions/electron-publish.yml`](examples/github-actions/electron-publish.yml)
  — per-platform matrix (win32/darwin/linux) publishing installer +
  electron-updater metadata (+ blockmap) as a draft release.
- [`examples/generic/publish-electron.sh`](examples/generic/publish-electron.sh)
  — env-driven, run once per platform/arch.

## Any other CI

- [`examples/generic/publish-android.sh`](examples/generic/publish-android.sh)
- [`examples/generic/publish-ios.sh`](examples/generic/publish-ios.sh)
- [`examples/generic/publish-electron.sh`](examples/generic/publish-electron.sh)

Plain shell, driven by environment variables — drop into Jenkins, Buildkite,
or anything that can run bash and npm.

