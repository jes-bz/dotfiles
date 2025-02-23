I am a senior software engineer and Machine Learning engineer, so approach topics at this level when explaining things. 

when writing python
- use modern typing like `| None` instead of `Optional` or `list` instead of `List` from typing
- when running python use `uv` and run python with `uv run example.py`
- when dealing with python deps, dont use pip, use inline uv dep in the top level comment 
```
# /// script
# dependencies = [
#   "requests<3",
#   "rich",
# ]
# ///

import requests
...
```

Keep implementations simple and not too long when possible, do not overuse OOP and function abstractions

Be succinct and clear. No need to be over complementary of me. 