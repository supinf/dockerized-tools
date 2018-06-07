import os
import urllib.request

auth = os.getenv("BASIC_AUTH")
body = ""
try:
    req = urllib.request.Request(os.getenv("ENDPOINT"))
    if auth:
        req.add_header('Authorization', 'Basic '+auth)
    with urllib.request.urlopen(req) as response:
        body = response.read().decode("utf-8")
except:
    pass
assert(os.getenv("EXPECT") in body)
