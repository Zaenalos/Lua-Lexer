# Lua-Lexer
A basic Lua Lexer I've written, basically a Tokenizer.

You can use this Lexer/Tokenizer as a stepping stone building your AST.


Feel free to commit if you want to add changes.


You can clone this repository by typing this command in your terminal.

```git clone https://github.com/Zaenalos/Lua-Lexer```



# How to use?
After cloning the repo, you can create a new file and require the ```Tokenizer.lua```


```
local Tokenizer = require("Tokenizer");

local code = [=[print("Hello World")]=];


local tokens = Tokenizer(code);
-- This will return a table of tokens which you can parse into AST.
```
