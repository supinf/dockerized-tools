import os
import urllib.request

body = ""
try:
    with urllib.request.urlopen(os.getenv("ENDPOINT")) as response:
        candidate = response.read()
    body = candidate.decode("utf-8")
except:
    pass
assert(os.getenv("EXPECT") in body)
