import os
import urllib.request

with urllib.request.urlopen(os.getenv("ENDPOINT")) as response:
   body = response.read()
assert(os.getenv("EXPECT") in body.decode("utf-8"))
