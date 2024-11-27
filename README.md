# `Skyrim C++ Libraries` <!-- omit in toc -->

![Skyrim Scripting C++ Libraries](resources/images/dragon-holding-cpp.jpg)

- [`vcpkg` + `xmake`](#vcpkg--xmake)
- [The Libraries](#the-libraries)
- [Build Tool Configuration](#build-tool-configuration)
  - [`xmake`](#xmake)
  - [`vcpkg`](#vcpkg)
    - [`vcpkg` Configuration](#vcpkg-configuration)
      - [`vcpkg-configuration.json`](#vcpkg-configurationjson)
        - [`vcpkg` Baseline](#vcpkg-baseline)
        - [`SkyrimScriptingBeta` Baseline](#skyrimscriptingbeta-baseline)
      - [`vcpkg.json`](#vcpkgjson)
    - [`CMake` Configuration](#cmake-configuration)


# `vcpkg` + `xmake`

<img src="resources/images/cmake-and-xmake.png" align="right" height="100" />

This is a registry of my C++ libraries for Skyrim modding.

They are provided in both `vcpkg` and `xmake` format.

# The Libraries

![Skyrim Scripting C++ Libraries](resources/images/cpp-skyrim-libraries.jpg)

- [`...`](#)
- [`...`](#)
- [`...`](#)
- [`...`](#)

# Build Tool Configuration

## `xmake`

Configuring `xmake` to use this package registry couldn't be easier:

```lua
-- This is the important line:
add_repositories("SkyrimScriptingBeta https://github.com/SkyrimScriptingBeta/Packages.git")

-- Then you can get the packages like this:
add_requires("some-library-from-this-registry")

-- And use it normally from targets:
target("my-target")
    set_kind("binary")
    add_files("src/*.cpp")
    add_packages("some-library-from-this-registry")
```

## `vcpkg`

Custom registries for `vcpkg` are a bit more involved, but still easy to set up.

### `vcpkg` Configuration

There are two `vcpkg` configuration files you need to create:

- `vcpkg-configuration.json`
- `vcpkg.json`

#### `vcpkg-configuration.json`

To allow downloading packages from registries, you need to create a `vcpkg-configuration.json` file:


```json
{
    "default-registry": {
        "kind": "git",
        "repository": "https://github.com/microsoft/vcpkg.git",
        "baseline": "c698ac9a9dfd33fe7364ef75d32b1aacb64f5a23"
    },
    "registries": [
        {
            "kind": "git",
            "repository": "https://github.com/SkyrimScriptingBeta/Packages.git",
            "baseline": "ed2c8705bccf9dc4c5393b6a9ffb35f8310424f8",
            "packages": ["some-library-from-this-registry"]
        }
    ]
}
```

> Note: be sure to update the `packages: [...]` list with the names of the packages you want to use from the registry.

You should update the `baseline` values to the latest commit hash of the respective repositories.

A `baseline` is the same as a `commit` identifier in a git repository.

##### `vcpkg` Baseline

You can get the latest up-to-date `baseline` value from here:

https://github.com/microsoft/vcpkg/commits/master/

Click on the little identifier hash to get the full commit hash:

![Click on vcpkg commit hash](resources/images/click-on-vcpkg-latest-commit.png)

Then you can take the long hash from the URL:

![Get the full commit hash](resources/images/get-vcpkg-latest-commit-from-url.png)

Copy that into the `baseline` field in the `vcpkg-configuration.json` file.

##### `SkyrimScriptingBeta` Baseline

You can repeat the same process for the SkyrimScriptingBeta repository.

You can get the latest commit hash from here:

https://github.com/SkyrimScriptingBeta/Packages/commits/main/

#### `vcpkg.json`

The `vcpkg.json` file is where you specify the packages you want to use:

```json
{
    "name": "my-project-this-can-be-anything",
    "version-string": "0.0.1",
    "dependencies": [
        "some-library-from-this-registry"
    ]
}
```

> Note: the `name` and `version-string` fields aren't important.
> They just need to be valid.
>
> The `name` needs to be all lowercase and contain only letters, numbers, and hyphens.

The `dependencies: [...]` list is a list of all `vcpkg` packages you want to use from any registry.

So, for example, you might want to use `spdlog` from the main `vcpkg` registry, and `some-library-from-this-registry` from this registry:

```json
{
    "name": "my-project-this-can-be-anything",
    "version-string": "0.0.1",
    "dependencies": [
        "spdlog",
        "some-library-from-this-registry"
    ]
}
```

### `CMake` Configuration

There are existing documents on how to use `vcpkg` with `CMake`.

This can differ depending on your project setup and code editor / IDE.

> In the future I will provide template repositories to get you started quickly
> if you need to use `CMake` with `vcpkg` and this registry.
