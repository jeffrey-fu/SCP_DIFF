# SCP DIFF

## Used Frameworks

- build: [roadhog](https://github.com/sorrycc/roadhog)
- server: [nginx](https://www.nginx.com/)

## Background

- As we know, `Etag` is the main way to tell browser whether the file has changed.
- Before rebuild project we always clean the `/dist` folder to keep it clean, in `roadhog` this step executed here ([af-wepack](https://unpkg.com/browse/af-webpack@0.23.0-beta.1/src/build.js#L26)) then webpack put new files into `/dist`, and [copy files in public to outputPath](https://unpkg.com/browse/af-webpack@0.23.0-beta.1/src/getConfig.js#L255).
- After rebuild, all files last modified time changed, according to [nginx etag algorithm](https://serverfault.com/questions/690341/algorithm-behind-nginx-etag-generation), even no changed files ([webpack add a unique hash based on the content of an asset](https://webpack.js.org/guides/caching/#output-filenames)) lose original `etag`, unfortunately browser cache become invalid.

## Solution

- Before upload, we should find out content changed file based webpack hash code, this way is only apply to root directory.
* [Here is my code](/deploy.sh), let's discuss to give out more effective solution!

## References

* [webpack-cleaning-up-the-dist-folder](https://webpack.js.org/guides/output-management/#cleaning-up-the-dist-folder)
