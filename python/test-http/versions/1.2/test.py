import os
import urllib.request

auth = os.getenv("BASIC_AUTH")
ua = os.getenv("USER_AGENT")
referer = os.getenv("REFERER")

body = ""
try:
    req = urllib.request.Request(os.getenv("ENDPOINT"))

    if auth:
        req.add_header('Authorization', 'Basic '+auth)
    if ua:
        req.add_header('User-Agent', ua)
    if referer:
        req.add_header('Referer', referer)

    with urllib.request.urlopen(req) as response:
        body = response.read().decode("utf-8")
except:
    pass
assert(os.getenv("EXPECT") in body)
