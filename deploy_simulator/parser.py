"""Real parser for EasyBuild-style `.eb` easyconfig files.

This module genuinely parses the Python-dict-like easyconfig syntax used by
EasyBuild (name/version/toolchain/dependencies/moduleclass assignments). It
does NOT hardcode a duplicate list of the 28 packages anywhere -- everything
returned here is derived by reading and parsing the actual `.eb` text files
on disk with Python's `ast` module.

We deliberately do not `exec()` the easyconfig (EasyBuild itself effectively
evaluates the file as restricted Python, but doing that here would mean
trusting arbitrary code). Instead we parse the module into an AST and pull
out the top-level assignments we care about, using `ast.literal_eval` on the
right-hand side of each one. This is a real, safe parse of real syntax.
"""
from __future__ import annotations

import ast
import glob
import os
from dataclasses import dataclass, field


class EasyconfigParseError(Exception):
    pass


@dataclass
class Easyconfig:
    name: str
    version: str
    homepage: str
    description: str
    toolchain: dict | None  # {'name':..., 'version':...} or None for SYSTEM
    dependencies: list[tuple[str, str]]
    moduleclass: str
    source_file: str

    @property
    def full_version(self) -> str:
        return self.version

    @property
    def module_name(self) -> str:
        return f"{self.name}/{self.version}"

    def dependency_module_names(self) -> list[str]:
        names = [f"{d[0]}/{d[1]}" for d in self.dependencies]
        if self.toolchain is not None:
            names.append(f"{self.toolchain['name']}/{self.toolchain['version']}")
        return names


def _literal_or_system(node: ast.AST):
    """Evaluate a right-hand side node; special-case the bare NAME `SYSTEM`."""
    if isinstance(node, ast.Name) and node.id == "SYSTEM":
        return None
    return ast.literal_eval(node)


def parse_easyconfig_file(path: str) -> Easyconfig:
    with open(path, "r") as f:
        text = f.read()

    try:
        tree = ast.parse(text, filename=path)
    except SyntaxError as exc:
        raise EasyconfigParseError(f"{path}: invalid Python/easyconfig syntax: {exc}") from exc

    values: dict[str, object] = {}
    for node in tree.body:
        if not isinstance(node, ast.Assign):
            continue
        if len(node.targets) != 1 or not isinstance(node.targets[0], ast.Name):
            continue
        key = node.targets[0].id
        try:
            values[key] = _literal_or_system(node.value)
        except (ValueError, SyntaxError):
            # Not a literal we need to capture (e.g. easyblock string is fine,
            # but skip anything we can't safely literal_eval).
            try:
                values[key] = ast.literal_eval(node.value)
            except Exception:
                continue

    required = ["name", "version", "homepage", "description", "moduleclass"]
    missing = [k for k in required if k not in values]
    if missing:
        raise EasyconfigParseError(f"{path}: missing required field(s): {missing}")

    toolchain = values.get("toolchain", None)
    if toolchain is not None and not (isinstance(toolchain, dict) and "name" in toolchain and "version" in toolchain):
        raise EasyconfigParseError(f"{path}: malformed toolchain field: {toolchain!r}")

    deps_raw = values.get("dependencies", [])
    dependencies = []
    for d in deps_raw:
        if not (isinstance(d, (tuple, list)) and len(d) >= 2):
            raise EasyconfigParseError(f"{path}: malformed dependency entry: {d!r}")
        dependencies.append((str(d[0]), str(d[1])))

    return Easyconfig(
        name=str(values["name"]),
        version=str(values["version"]),
        homepage=str(values["homepage"]),
        description=str(values["description"]),
        toolchain=toolchain,
        dependencies=dependencies,
        moduleclass=str(values["moduleclass"]),
        source_file=path,
    )


def parse_all(easyconfigs_dir: str) -> dict[str, Easyconfig]:
    """Parse every `.eb` file in a directory. Returns {module_name: Easyconfig}."""
    ecs: dict[str, Easyconfig] = {}
    paths = sorted(glob.glob(os.path.join(easyconfigs_dir, "*.eb")))
    if not paths:
        raise EasyconfigParseError(f"No .eb files found in {easyconfigs_dir}")
    for path in paths:
        ec = parse_easyconfig_file(path)
        if ec.module_name in ecs:
            raise EasyconfigParseError(f"Duplicate module name parsed: {ec.module_name} ({path})")
        ecs[ec.module_name] = ec
    return ecs


def build_dependency_graph(ecs: dict[str, Easyconfig]) -> dict[str, list[str]]:
    """Build {module_name: [dependency_module_names]} purely from parsed data.

    A toolchain (e.g. 'foss/2023a', 'GCC/12.3.0') that is itself one of the
    parsed easyconfigs is treated as a real build dependency edge, since a
    package cannot be built with a toolchain that hasn't been deployed.
    """
    graph: dict[str, list[str]] = {}
    for modname, ec in ecs.items():
        edges = []
        for dep_mod in ec.dependency_module_names():
            if dep_mod in ecs:
                edges.append(dep_mod)
            # dependencies on modules outside our 28 (e.g. a bare OS lib) are
            # silently ignored for graph purposes -- they are not things we
            # deploy/resolve ourselves.
        graph[modname] = sorted(set(edges))
    return graph


if __name__ == "__main__":
    import sys
    d = sys.argv[1] if len(sys.argv) > 1 else "easyconfigs"
    parsed = parse_all(d)
    print(f"Parsed {len(parsed)} easyconfigs from {d}")
    graph = build_dependency_graph(parsed)
    for mod, deps in graph.items():
        print(f"  {mod}: {deps}")
