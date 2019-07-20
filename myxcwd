#!/usr/bin/python3

import json
import os
import subprocess
import sys

from collections import namedtuple, defaultdict
from pathlib import Path

DNode = namedtuple('DepthfulNode', ['node', 'depth'])

def get_parent(pid):
    with (Path(f'/proc/{pid}') / 'status').open() as status_file:
        for line in status_file:
            line = line.split('\t')
            if line[0] == 'PPid:':
                return int(line[1])

def get_proctree():
    def get_pids():
        yield from map(lambda d: int(d.name),
                       filter(lambda d: d.name.isdigit(),
                              Path('/proc').iterdir()))

    res = defaultdict(lambda: [])
    for pid in get_pids():
        ppid = get_parent(pid)
        res[ppid].append(pid)
    return res

def get_deepest_child(pid):
    ptree = get_proctree()
    def children_depth(pid, depth):
        children = ptree.get(pid)
        if children is None:
            return

        yield DNode(pid, depth)

        for child in children:
            yield from children_depth(child, depth + 1)

    return max(children_depth(pid, 0), key=lambda p: p.depth).node

def get_cwd(pid):
    return str(Path(f'/proc/{pid}/cwd').resolve())

def get_focused_xid():
    i3_root = json.loads(subprocess.check_output(['i3-msg', '-t', 'get_tree']))

    def get_focused(node, depth=0):
        if node['focused']:
            yield DNode(node, depth)

        for subnode in node.get('nodes', []):
            yield from get_focused(subnode, depth + 1)


    focused_node = max(get_focused(i3_root), key=lambda dnode: dnode.depth)
    return str(focused_node.node['window'])

def xprop(xid, *args):
    xprop_args = ['xprop', '-id', xid] + list(args)
    return subprocess.check_output(xprop_args).decode().strip()

def pid_from_xid(xid):
    try:
        return xprop(xid, '_NET_WM_PID').split(' ')[-1]
    except:
        return None

def window_name_from_xid(xid):
    try:
        window_name = xprop(xid, '-f', '_NET_WM_NAME', '8u', '_NET_WM_NAME')
        # The format looks like VARIABLE_NAME(type) = "value"
        return window_name[window_name.find('"') + 1:-1]
    except:
        return None

def cwd_from_xid(xid):
    window_name = window_name_from_xid(xid)
    pid = pid_from_xid(xid)

    if window_name is not None \
       and (window_name.startswith('/') \
            or window_name.startswith('~')):
        title_path = Path(window_name)

        # avoid looping indefinitely, just in case
        up_count = 0
        while not title_path.is_dir() and up_count < 3:
            title_path = title_path.parent
            up_count += 1

        return str(title_path)

    if pid is not None:
        return get_cwd(pid)

    return None

if __name__ == '__main__':
    cwd = cwd_from_xid(get_focused_xid())
    if cwd is None:
        cwd = os.environ.get('HOME')

    if cwd is None:
        cwd = '/'

    if len(sys.argv) < 2:
        print(cwd)
        exit(0)

    args = list(map(lambda s: s.replace('{}', cwd),
                    sys.argv[2:]))

    os.execlp(sys.argv[1], *([sys.argv[1]] + args))
    print("exec failed", file=sys.stderr)
    exit(1)
