from typing import Iterable
from ..framework.core.settings import CLIENT_PORT

def servers_arg(nodes: Iterable) -> str:
    addrs = []
    for n in nodes or []:
        # Use instance name (resolves via docker network) with client port
        host = getattr(n, "name", "localhost")
        addrs.append(f"{host}:{int(CLIENT_PORT)}")
    return " ".join(addrs)
