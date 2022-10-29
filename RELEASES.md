# Releasing new changes

This repository uses Github Actions to compile and generate new releases.

Creating and pushing a new tag will generate a new release to be consumed.

Please keep tag names consistent and use "v<tag_name>" (i.e: v2.2.0).

This can be done either via CLI or through the Github desktop app.

# CLI

```bash
git pull origin main
git tag v<tag_name>
git push origin v<tag_name>
```

# Desktop app

Take a look at the [documentation](https://github.blog/2020-05-12-create-and-push-tags-in-the-latest-github-desktop-2-5-release/) online to perform this.
