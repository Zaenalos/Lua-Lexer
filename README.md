---

# 📜 Lua-Lexer

**Lua-Lexer** is a lightweight lexer (tokenizer) for the Lua programming language. It breaks down Lua code into a series of tokens, providing a foundational tool for building an Abstract Syntax Tree (AST) or performing code analysis.

## ✨ Features

- Simple and easy-to-use Lua lexer.
- Converts Lua source code into tokens.
- Perfect for building custom parsers or AST generators.

## 🚀 Getting Started

To get started with Lua-Lexer, clone the repository by running the following command in your terminal:

```sh
git clone https://github.com/Zaenalos/Lua-Lexer
```

## 📦 Installation and Usage

After cloning the repository, you can start using the lexer in your Lua projects. Follow the steps below:

1. **Require the `Tokenizer` module** in your Lua script:

   ```lua
   local Tokenizer = require("Tokenizer")
   ```

2. **Pass your Lua code to the `Tokenizer`**:

   ```lua
   local code = [=[print("Hello World")]=]
   local tokens = Tokenizer(code)
   ```

3. **Use the tokens for further processing**:

   ```lua
   -- `tokens` is a table containing the parsed tokens from the Lua code
   for _, token in ipairs(tokens) do
       print(token.type, token.value)
   end
   ```

The `Tokenizer` function will return a table of tokens that you can use to build an AST or analyze the code further.

## 🤝 Contributing

Contributions are welcome! If you have ideas for new features or improvements, feel free to fork the repository and submit a pull request. Let's make Lua-Lexer better together!

## 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---