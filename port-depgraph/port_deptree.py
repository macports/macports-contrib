#!/usr/bin/env python
# Copyright (c) 2014, 2015 Mathias Laurin
# BSD 3-Clause License (http://opensource.org/licenses/BSD-3-Clause)

r"""Print all dependencies required to build a port as a graph.

Usage:
    port_deptree.py [--min] PORTNAME [VARIANTS ...]

Example:
    port_deptree.py irssi -perl | dot -Tpdf -oirssi.pdf
    port_deptree.py --min $(port echo requested and outdated)\
            | dot -Tpdf | open -fa Preview

"""
from __future__ import print_function
import sys
_stdout, sys.stdout = sys.stdout, sys.stderr
import subprocess
from itertools import product
from altgraph import Dot, Graph
__version__ = "0.9"


def _(bytes):
    return bytes.decode("utf-8")


class NodeData(object):

    __slots__ = ("type", "status")

    def __init__(self, type):
        self.type = type  # in (root, vertex, leaf)
        self.status = "missing"  # in (installed, outdated, missing)


class EdgeData(object):

    __slots__ = ("section",)

    def __init__(self, section):
        self.section = section


def get_deps(portname, variants):
    """Return `section, depname` dependents of `portname` with `variants`."""
    process = ["port", "deps", portname]
    process.extend(variants)
    for line in subprocess.Popen(
            process, stdout=subprocess.PIPE).stdout.readlines():
        section, sep, children = _(line).partition(":")
        if not section.endswith("Dependencies"):
            continue
        for child in [child.strip() for child in children.split(",")]:
            yield section.split()[0].lower(), child


def make_graph(graph, portname, variants):
    """Traverse dependency tree of `portname` with `variants`.

    Args:
        portname (str): The name of a port.
        variants (list): The variants to apply to `portname`.

    """
    def call(cmd):
        return subprocess.Popen(
            cmd.split(), stdout=subprocess.PIPE).stdout.readlines()

    installed = set(_(line.split()[0]) for line in call("port echo installed"))
    outdated = set(_(line.split()[0]) for line in call("port echo outdated"))
    visited = set(node for node in graph)

    def traverse(parent):
        """Recursively traverse dependencies to `parent`."""
        if parent in visited:
            return
        else:
            visited.add(parent)
        node_data = graph.node_data(parent)
        if parent in outdated:
            node_data.status = "outdated"
        elif parent in installed:
            node_data.status = "installed"
        for section, child in get_deps(parent.strip('"'), variants):
            if node_data.type is not "root":
                node_data.type = "vertex"
            if child not in graph:
                graph.add_node(child, NodeData("leaf"))
            graph.add_edge(parent, child, EdgeData(section),
                           create_nodes=False)
            traverse(child)
    graph.add_node(portname, NodeData("root"))
    traverse(portname)


def reduce_graph(graph, root):
    """Keep only "missing" and "outdated" nodes and their parents."""
    for node in graph.forw_bfs(root):
        node_data = graph.node_data(node)
        if node_data.type is "root" or node_data.status is not "installed":
            continue
        children = set(graph.tail(edge) for edge in graph.out_edges(node))
        if not set(("outdated", "missing")).intersection(
                data.status for data in (graph.node_data(child)
                                         for child in children)):
            parents = set(graph.head(edge) for edge in graph.inc_edges(node))
            for parent, child in product(parents, children):
                if not graph.edge_by_node(parent, child):
                    graph.add_edge(parent, child, EdgeData("virtual"))
            graph.hide_node(node)


def make_dot(graph):
    """Convert the graph to a dot file.

    Node and edge styles is obtained from the corresponding data.

    Args:
        graph (Graph.Graph): The graph.

    Returns:
        Dot.Dot: The dot file generator.

    """
    dot = Dot.Dot(graph, graphtype="digraph")
    dot.style(overlap=False, bgcolor="transparent")
    for node in graph:
        node_data = graph.node_data(node)
        shape = ("circle" if node_data.type is "vertex" else "doublecircle")
        color, fillcolor = dict(missing=("red", "moccasin"),
                                outdated=("forestgreen", "lightblue")
                                ).get(node_data.status, ("black", "white"))
        dot.node_style(node, shape=shape,
                       style="filled", fillcolor=fillcolor, color=color)
    for edge, edge_data, head, tail in (graph.describe_edge(edge)
                                        for edge in graph.edge_list()):
        section = edge_data.section
        color = dict(fetch="forestgreen",
                     extract="darkgreen",
                     build="blue",
                     runtime="red",
                     virtual="darkgray").get(section, "black")
        style = dict(virtual="dashed").get(section, "solid")
        dot.edge_style(
            head, tail,
            label=section if section not in ("library", "virtual") else "",
            style=style, color=color, fontcolor=color)
    return dot


def make_stats(graph):
    """Return the stats for `graph`."""
    stats = dict(missing=0,
                 installed=0,
                 outdated=0,
                 total=graph.number_of_nodes())
    for node in graph:
        node_data = graph.node_data(node)
        stats[node_data.status] += 1
    return stats


if __name__ == '__main__':
    graph = Graph.Graph()
    reduce = False
    commandline = {}
    try:
        if not sys.argv[1:]:
            raise RuntimeError
        for arg in sys.argv[1:]:
            if arg.startswith("@"):
                continue
            elif arg.startswith("--min"):
                reduce = True
            elif not (arg.startswith("+") or arg.startswith("-")):
                portname = arg
                commandline[portname] = []
            else:
                commandline[portname].append(arg)
    except:
        print(__doc__, file=sys.stderr)
        exit(1)
    for portname, variants in commandline.items():
        print("Calculating dependencies for", portname, *variants,
              file=sys.stderr)
        make_graph(graph, portname, variants)
    stats = make_stats(graph)
    if reduce:
        for portname in commandline:
            reduce_graph(graph, portname)
    print("Total:", stats["total"],
          "(%i" % stats["outdated"], "upgrades,", stats["missing"], "new)",
          file=sys.stderr)
    for line in make_dot(graph).iterdot():
        print(line, file=_stdout)
    _stdout.flush()
