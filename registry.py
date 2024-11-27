import argparse
import datetime
import json
import re
import subprocess
import sys
from abc import ABC, abstractmethod
from pathlib import Path
from urllib.request import urlopen
from dataclasses import dataclass

DRY_RUN = False

# TODO
# class PackagesFolder:
#     def __init__(self, root_folder: Path):
#         self.root_folder = root_folder
#
#     def mkdir(self, folder: Path) -> None:
#         if not folder.exists():
#             print(f"Creating {folder}")
#             folder.mkdir(exist_ok=True, parents=True)

class Git:
    @staticmethod
    def exec(args: list[str], working_dir: str | None = None) -> str:
        args = [str(arg) for arg in args]
        text_args = [f'"{arg}"' if " " in arg else arg for arg in args]
        print(f"git {' '.join(text_args)}")
        if DRY_RUN and args[0] == "commit":
            print("git commit skipped [--dry-run]")
            return ""
        return subprocess.run(
            ["git"] + args,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            cwd=working_dir,
        ).stdout

class GitHub:
    @dataclass
    class GitHubRepo:
        url: str
        username: str
        repo_name: str

    class GitHubApi:
        pass

        @dataclass
        class GitHubRepoInfo:
            description: str

        @dataclass
        class GitHubCommitInfo:
            date: str
            sha: str
            message: str

class PackageRegistry(ABC):
    @abstractmethod
    def add_package(self, *args, **kwargs):
        pass

    @abstractmethod
    def remove_port(self, port_name: str):
        pass

    @abstractmethod
    def update_port(self, port_name: str, ref: str = None):
        pass

    @abstractmethod
    def list_ports(self):
        pass

    @abstractmethod
    def package_exists(self, package_name: str) -> bool:
        pass

    @staticmethod
    def git(args: list[str], working_dir: str | None = None) -> str:
            return Git.exec(args, working_dir)


class VcpkgPackageRegistry(PackageRegistry):
    def package_exists(self, port_name: str) -> bool:
        if self.get_port_folder_path(port_name).exists():
            return any(self.get_port_folder_path(port_name).iterdir())
        return False

    @staticmethod
    def check_port_name_validity(port_name: str) -> bool:
        return not not re.compile("^[a-z0-9]+(-[a-z0-9]+)*$").match(port_name)

    @staticmethod
    def get_version_folder_path(port_name: str) -> Path:
        return Path("versions") / f"{port_name[0].lower()}-"

    def get_version_file_path(self, port_name: str) -> Path:
        return self.get_version_folder_path(port_name) / f"{port_name}.json"

    @staticmethod
    def get_port_folder_path(port_name: str) -> Path:
        return Path("ports") / port_name

    def get_portfile_path(self, port_name: str) -> Path:
        return self.get_port_folder_path(port_name) / "portfile.cmake"

    def get_vcpkg_json_path(self, port_name: str) -> Path:
        return self.get_port_folder_path(port_name) / "vcpkg.json"

    @staticmethod
    def get_baseline_path() -> Path:
        return Path("versions") / "baseline.json"

    @staticmethod
    def mkdir(folder: Path) -> None:
        if not folder.exists():
            print(f"Creating {folder}")
            folder.mkdir(exist_ok=True, parents=True)

    @staticmethod
    def get_git_tree_sha(port_name) -> str:
        output = Git.exec(["rev-parse", "HEAD:ports/" + port_name])
        return output.strip()

    @staticmethod
    def get_github_repo_info(username: str, repo_name: str) -> GitHub.GitHubApi.GitHubRepoInfo:
        url = f"https://api.github.com/repos/{username}/{repo_name}"
        with urlopen(url) as response:
            data = json.load(response)
            return GitHub.GitHubApi.GitHubRepoInfo(description=data["description"])

    @staticmethod
    def get_github_latest_commit_info(github_user: str, github_repo: str, ref: str) -> GitHub.GitHubApi.GitHubCommitInfo:
        ref = ref or "HEAD"
        url = f"https://api.github.com/repos/{github_user}/{github_repo}/commits/{ref}"
        with urlopen(url) as response:
            data = json.load(response)
            return GitHub.GitHubApi.GitHubCommitInfo(
                date=data["commit"]["committer"]["date"][:10],
                sha=data["sha"],
                message=data["commit"]["message"]
            )

    @staticmethod
    def create_portfile_contents_vcpkg_from_git(port_name: str, github_user: str, github_repo: str, ref: str, options_text: str, header_only: bool) -> str:
        cleanup_code = """
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)""" if header_only else ""

        return f"""vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://github.com/{github_user}/{github_repo}.git
    REF {ref}
)

vcpkg_cmake_configure(
    SOURCE_PATH ${{SOURCE_PATH}}{options_text}
)

vcpkg_cmake_install(){cleanup_code}

file(MAKE_DIRECTORY "${{CURRENT_PACKAGES_DIR}}/share/${{PORT}}")
file(INSTALL "${{SOURCE_PATH}}/LICENSE" DESTINATION "${{CURRENT_PACKAGES_DIR}}/share/${{PORT}}" RENAME copyright)
"""

    @staticmethod
    def create_portfile_contents_download_latest(port_name: str, github_user: str, github_repo: str, ref: str, options_text: str, header_only: bool) -> str:
        cleanup_code = """
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)""" if header_only else ""

        return f"""file(DOWNLOAD "https://api.github.com/repos/{github_user}/{github_repo}/tarball/{ref or 'main'}" ${{DOWNLOADS}}/{port_name}-latest.tar.gz
    SHOW_PROGRESS
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${{DOWNLOADS}}/{port_name}-latest.tar.gz
)

vcpkg_cmake_configure(
    SOURCE_PATH ${{SOURCE_PATH}}{options_text}
)

vcpkg_cmake_install(){cleanup_code}

file(MAKE_DIRECTORY "${{CURRENT_PACKAGES_DIR}}/share/${{PORT}}")
file(INSTALL "${{SOURCE_PATH}}/LICENSE" DESTINATION "${{CURRENT_PACKAGES_DIR}}/share/${{PORT}}" RENAME copyright)
"""

    def create_portfile_contents(self, port_name: str, github_user: str, github_repo: str, latest: bool, ref: str, options: list, header_only: bool) -> str:
        options_text = ""
        if options:
            options_text = "\n    OPTIONS "
            options_text += " ".join([f"-D{option}" for option in options])
        if latest:
            return self.create_portfile_contents_download_latest(port_name, github_user, github_repo, ref, options_text, header_only)
        else:
            return self.create_portfile_contents_vcpkg_from_git(port_name, github_user, github_repo, ref, options_text, header_only)

    @staticmethod
    def create_vcpkg_json_dict(port_name: str, port_description: str, github_user: str, github_repo: str, version_string: str, dependencies: list) -> dict:
        vcpkg_json = {
            "name": port_name,
            "version-string": version_string,
            "description": port_description,
            "dependencies": [
                {"name": "vcpkg-cmake", "host": True},
                {"name": "vcpkg-cmake-config", "host": True},
            ]
        }
        for dependency in dependencies:
            vcpkg_json["dependencies"].append(dependency)
        return vcpkg_json

    def add_package(self, port_name: str, github_user: str, github_repo: str, latest: bool, ref: str, dependencies: list, options: list, header_only: bool) -> None:
        if self.package_exists(port_name):
            print(f"Port {port_name} already exists.")
            sys.exit(1)
        if not self.check_port_name_validity(port_name):
            print(f"Invalid port name: {port_name}")
            sys.exit(1)
        print(f"Adding port '{port_name}'")
        # Get repository information
        repo_info = self.get_github_repo_info(github_user, github_repo)
        repo_description = repo_info.description
        # Get commit info from either the ref or the latest commit
        latest_commit= self.get_github_latest_commit_info(github_user, github_repo, ref)
        if not latest and not ref:
            ref = latest_commit.sha
        # Create the port directory
        port_dir = self.get_port_folder_path(port_name)
        self.mkdir(port_dir)
        # Create the version directory
        version_dir = self.get_version_folder_path(port_name)
        self.mkdir(version_dir)
        # Create the portfile.cmake
        portfile_contents = self.create_portfile_contents(port_name, github_user, github_repo, latest, ref, options, header_only)
        portfile_path = self.get_portfile_path(port_name)
        print(f"Writing {portfile_path}")
        with open(portfile_path, "w") as f:
            f.write(portfile_contents)
        # Create the vcpkg.json
        version_string = "latest" if latest else f"{latest_commit.date}-{latest_commit.sha[:7]}"
        vcpkg_json_dict = self.create_vcpkg_json_dict(port_name, repo_description, github_user, github_repo, version_string, dependencies)
        vcpkg_json_path = self.get_vcpkg_json_path(port_name)
        print(f"Writing {vcpkg_json_path}")
        with open(vcpkg_json_path, "w") as f:
            json.dump(vcpkg_json_dict, f, indent=2)
        # Add the port to git
        self.git(["add", f"ports/{port_name}"])
        self.git(["commit", "-m", f"Add new port {port_name}"])
        git_tree_sha = self.get_git_tree_sha(port_name)
        print(f"Git tree SHA: {git_tree_sha}")
        # Create the versions/*-/port-name.json file
        version_json = {
            "versions": [
                {
                    "version-string": version_string,
                    "git-tree": git_tree_sha
                }
            ]
        }
        version_file_path = self.get_version_file_path(port_name)
        print(f"Writing {version_file_path}")
        with open(version_file_path, "w") as f:
            json.dump(version_json, f, indent=2)
        # Add the port to the baseline versions
        baseline_path = self.get_baseline_path()
        baseline_data = {"default": {}}
        if baseline_path.exists():
            print(f"Updating {baseline_path}")
            with open(baseline_path, "r") as f:
                baseline_data = json.load(f)
        else:
            print(f"Creating {baseline_path}")
        baseline_data["default"][port_name] = {
            "baseline": version_string,
            "port-version": 0
        }
        with open(baseline_path, "w") as f:
            json.dump(baseline_data, f, indent=2)
        # Add and commit all the things
        self.git(["add", version_file_path])
        self.git(["add", baseline_path])
        self.git(["commit", "--amend", "--no-edit"])
        print(f"Successfully added port '{port_name}'")

    def remove_port(self, port_name: str) -> None:
        print(f"Removing port '{port_name}'")

        self.git(["rm", "-r", self.get_port_folder_path(port_name)])
        self.git(["rm", self.get_version_file_path(port_name)])

        versions_folder_path = self.get_version_folder_path(port_name)
        if versions_folder_path.exists():
            if not any(versions_folder_path.iterdir()):
                print(f"Removing {versions_folder_path}")
                versions_folder_path.rmdir()

        baseline_path = self.get_baseline_path()
        with open(baseline_path, "r") as f:
            baseline_data = json.load(f)
        if baseline_data.get("default", {}).get(port_name):
            del baseline_data["default"][port_name]
            print(f"Updating {baseline_path}")
            with open(baseline_path, "w") as f:
                json.dump(baseline_data, f, indent=2)

        # If there are no more ports, delete the ports and versions folders
        all_ports = self.get_ports()
        if not all_ports:
            print("No more ports. Removing ports and versions folders.")
            self.git(["rm", "-r", "ports"])
            self.git(["rm", "-r", "versions"])

        self.git(["add", baseline_path])
        self.git(["commit", "-m", f"Removed {port_name}"])

        print(f"Successfully removed port '{port_name}'")

    def update_port(self, port_name: str, ref: str = None) -> None:
        if not self.package_exists(port_name):
            print(f"Port {port_name} does not exist.")
            sys.exit(1)
        print(f"Updating port '{port_name}'")
        # Read the current portfile
        portfile_path = self.get_portfile_path(port_name)
        with open(portfile_path, "r") as f:
            portfile_contents = f.read()
        # Is the current portfile using vcpkg_from_git or file(DOWNLOAD)?
        if not "vcpkg_from_git" in portfile_contents:
            print(f"portfile for port {port_name} does not use vcpkg_from_git")
            print("Cannot update port that was created using --latest")
            sys.exit(1)
        # Get the github user and repo from the portfile
        url_pattern = re.compile(r'URL\s+(https://github.com/[\w\-]+/[\w\-\.]+)\.git')
        repo_url = url_pattern.search(portfile_contents).group(1)
        github_user, github_repo = repo_url.split("/")[-2:]
        # Get the latest commit info
        latest_commit= self.get_github_latest_commit_info(github_user, github_repo, None)
        # Get the REF from the portfile
        ref_pattern = re.compile(r'REF\s+([\w\-]+)')
        current_ref = ref_pattern.search(portfile_contents).group(1)
        print(f"GitHub repository URL: {repo_url}")
        print(f"Latest commit: {latest_commit.sha}")
        print(f"> {latest_commit.message}")
        if latest_commit.sha == current_ref:
            print(f"Port {port_name} is already up to date.")
            sys.exit(0)
        # Update the existing portfile with the updated REF
        portfile_contents = portfile_contents.replace(f"REF {current_ref}", f"REF {latest_commit.sha}")
        portfile_path = self.get_portfile_path(port_name)
        print(f"Updating {portfile_path}")
        with open(portfile_path, "w") as f:
            f.write(portfile_contents)
        # Update the existing vcpkg.json with the updated version-string
        vcpkg_json_path = self.get_vcpkg_json_path(port_name)
        with open(vcpkg_json_path, "r") as f:
            vcpkg_json_data = json.load(f)
        version_string = f"{latest_commit.date}-{latest_commit.sha[:7]}"
        vcpkg_json_data["version-string"] = version_string
        print(f"Updating {vcpkg_json_path}")
        with open(vcpkg_json_path, "w") as f:
            json.dump(vcpkg_json_data, f, indent=2)
        # Add the port to git
        self.git(["add", f"ports/{port_name}"])
        self.git(["commit", "-m", f"Update {port_name} to {version_string}"])
        git_tree_sha = self.get_git_tree_sha(port_name)
        print(f"Git tree SHA: {git_tree_sha}")
        # Add the new version to the versions .json file
        version_file_path = self.get_version_file_path(port_name)
        with open(version_file_path, "r") as f:
            version_json_data = json.load(f)
        version_json_data["versions"].append({
            "version-string": version_string,
            "git-tree": git_tree_sha
        })
        print(f"Updating {version_file_path}")
        with open(version_file_path, "w") as f:
            json.dump(version_json_data, f, indent=2)
        # Update the baseline version
        baseline_path = self.get_baseline_path()
        with open(baseline_path, "r") as f:
            baseline_data = json.load(f)
        baseline_data["default"][port_name]["baseline"] = version_string
        print(f"Updating {baseline_path}")
        with open(baseline_path, "w") as f:
            json.dump(baseline_data, f, indent=2)
        # Add and commit all the things
        self.git(["add", version_file_path])
        self.git(["add", baseline_path])
        self.git(["commit", "--amend", "--no-edit"])
        print(f"Successfully updated port '{port_name}'")

    def update_versions_file(self, port_name: str) -> None:
        # Get the current version-string from the vcpkg.json
        vcpkg_json_path = self.get_vcpkg_json_path(port_name)
        with open(vcpkg_json_path, "r") as f:
            vcpkg_json_data = json.load(f)
        version_string = vcpkg_json_data["version-string"]
        # Produce a commit message with the current date and time
        commit_message = f"Update {port_name} {version_string} ({datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')})"
        # Add the port to git and commit (note: there may be no changes to stage and that's ok)
        # (we just need the git tree SHA to update if there are changes to stage and commit)
        self.git(["add", f"ports/{port_name}"])
        self.git(["commit", "-m", commit_message])
        # Get the git tree SHA
        git_tree_sha = self.get_git_tree_sha(port_name)
        # Get the git-tree from the versions .json file for the current version-string
        version_file_path = self.get_version_file_path(port_name)
        with open(version_file_path, "r") as f:
            version_json_data = json.load(f)
        git_tree = next(
            (v["git-tree"] for v in version_json_data["versions"] if v["version-string"] == version_string), None)
        if git_tree == git_tree_sha:
            print(f"Port {port_name} is already up to date.")
            sys.exit(0)
        # Update the version in the versions .json file with a matching version-string to use the updated git tree SHA
        for v in version_json_data["versions"]:
            if v["version-string"] == version_string:
                v["git-tree"] = git_tree_sha
        print(f"Updating {version_file_path}")
        with open(version_file_path, "w") as f:
            json.dump(version_json_data, f, indent=2)
        # Add the updated versions .json file to git and commit
        self.git(["add", version_file_path])
        self.git(["commit", "--amend", "--no-edit"])
        print(f"Successfully updated versions file for port '{port_name}'")

    def get_ports(self) -> list[str]:
        ports_path = Path("ports")
        if not ports_path.exists():
            return []
        return [p.name for p in ports_path.iterdir() if p.is_dir()]

    def list_ports(self) -> None:
        print("Ports:")
        for port in self.get_ports():
            print(f" - {port}")

class PackageRegistryCLI:
    def __init__(self):
        self.registries: dict[str, PackageRegistry] = {}
        self.args = argparse.Namespace | None
        self.help_text: str = ""

    def add_registry(self, name: str, registry: PackageRegistry):
        self.registries[name] = registry

    def parse_args(self):
        parser = argparse.ArgumentParser(description="Manage package registries.")
        parser.add_argument("--dry-run", action="store_true", help="Don't perform any git commits.")
        parser.add_argument('-r', '--registry', default='all', help='Comma-separated list of registries to use (default: all)')

        subparsers = parser.add_subparsers(dest="command")

        add_parser = subparsers.add_parser("add", help="Add a new port to the registry.")
        add_parser.add_argument("port_name", help="The name of the port to add.")
        add_parser.add_argument("github_repo", help="The GitHub repository in the format 'user/repo'.")
        add_parser.add_argument("--latest", action="store_true", help="Use the latest version from the GitHub repository.")
        add_parser.add_argument("--ref", help="The specific git commit or branch to use for the port.")
        add_parser.add_argument("--dependencies", "--deps", default="", help="Comma-separated list of dependencies.")
        add_parser.add_argument('--options', help='Comma-separated list of CMake options in the format "Option=Value"', default='')
        add_parser.add_argument("--header-only", action="store_true", help="Configure as header-only library (removes lib/debug folders)")

        subparsers.add_parser("ls", help="List all ports in the registry.")

        remove_parser = subparsers.add_parser("rm", help="Remove a port from the registry.")
        remove_parser.add_argument("port_name", help="The name of the port to remove.")

        update_parser = subparsers.add_parser("update", help="Update a port in the registry.")
        update_parser.add_argument("port_name", help="The name of the port to update.")
        update_parser.add_argument("--ref", help="The specific git commit to update the port to use.")

        update_versions_parser = subparsers.add_parser("update-versions", help="Update the versions file for a port.")

        update_versions_parser.add_argument("port_name", help="The name of the port to update the versions file for.")

        self.args = parser.parse_args()

        self.help_text = parser.format_help()

    def execute(self):
        if self.args.dry_run:
            global DRY_RUN
            DRY_RUN = True
            print("Dry run mode enabled. No git commits will be performed.")

        selected_registries = self.args.registry.split(',') if self.args.registry != 'all' else self.registries.keys()

        for registry_name in selected_registries:
            registry = self.registries.get(registry_name)
            if not registry:
                print(f"Registry '{registry_name}' not found.")
                continue

            # If the github repo argument is in the format https://github.com/user/repo, convert it to user/repo
            if hasattr(self.args, 'github_repo') and self.args.github_repo.startswith("https://github.com/"):
                self.args.github_repo = self.args.github_repo[19:]

            if self.args.command == "add":
                dependencies = []
                if self.args.dependencies:
                    dependencies = self.args.dependencies.split(",")
                options = []
                if self.args.options:
                    options = self.args.options.split(",")
                github_user, github_repo = self.args.github_repo.split("/")
                registry.add_package(
                    self.args.port_name,
                    github_user,
                    github_repo,
                    self.args.latest,
                    self.args.ref,
                    dependencies,
                    options,
                    self.args.header_only
                )
            elif self.args.command == "ls":
                registry.list_ports()
            elif self.args.command == "rm":
                registry.remove_port(self.args.port_name)
            elif self.args.command == "update":
                registry.update_port(self.args.port_name, ref=self.args.ref)
            elif self.args.command == "update-versions":
                registry.update_versions_file(self.args.port_name)
            else:
                print(self.help_text)
                sys.exit(1)

def main():
    cli = PackageRegistryCLI()
    cli.add_registry("vcpkg", VcpkgPackageRegistry())
    # When you implement XmakePackageRegistry, add it here
    # cli.add_registry("xmake", XmakePackageRegistry())

    cli.parse_args()
    cli.execute()

if __name__ == "__main__":
    main()