local Util = require("Util");
local lookupify = Util.lookupify;
local EOF = "";
local base_ident = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_";
local base_digits = "1234567890";
local base_operators = "+-*/^%#";
local chars = {
		whitespace = lookupify(" \t\r"),
		validEscapes = lookupify('abfnrtv"\'\\'),
		ident = lookupify(base_ident .. base_digits, { start = lookupify(base_ident) }),
		digits = lookupify(base_digits, { hex = lookupify(base_digits .. "abcdefABCDEF") }),
		symbols = lookupify(base_operators .. ",{}[]();.:", { equality = lookupify("~=><"), operators = lookupify(base_operators) }),
	};
local keywords = { structure = lookupify({
			"and",
			"break",
			"do",
			"else",
			"elseif",
			"end",
			"for",
			"function",
			"goto",
			"if",
			"in",
			"local",
			"not",
			"or",
			"repeat",
			"return",
			"then",
			"until",
			"while",
		}), values = lookupify({ "true", "false", "nil" }) };
local function isWhiteSpace(char)
	return chars.whitespace[char] ~= nil;
end;
local function isEscape(char)
	return chars.validEscapes[char] ~= nil;
end;
local function isBase(char)
	return chars.ident.start[char] ~= nil;
end;
local function isIdent(char)
	return chars.ident[char] ~= nil;
end;
local function isDigit(char)
	return chars.digits[char] ~= nil;
end;
local function isSymbol(char)
	return chars.symbols[char];
end;
local function isOperator(char)
	return chars.symbols.operators[char];
end;
local function isEqualityOperator(char)
	return chars.symbols.equality[char];
end;
local function isHexDigit(char)
	return chars.digits.hex[char];
end;
local function isKeyword(word)
	return keywords.structure[word] ~= nil;
end;
local function isBoolean(word)
	return keywords.values[word] ~= nil;
end;
local function isEndOfLine(char)
	return char == "\n" or char == "\r";
end;
return function(text)
	local pos = 1;
	local start = 1;
	local posOffset = 0;
	local tokens = {};
	local function ErrorLog(msg, pos)
		print("Error: " .. msg);
		error("Error in position: " .. pos, 0);
	end;
	local function look(delta)
		delta = pos + (delta or 0);
		return text:sub(delta, delta);
	end;
	local function get()
		pos = pos + 1;
		return look(-1);
	end;
	local function getCurrentTokenText()
		return text:sub(start, pos - 1);
	end;
	local function AddToken(name, data)
		local token = data or getCurrentTokenText();
		local tokenPos = (posOffset + #token) - #token;
		local tk = {
				TYPE = name,
				DATA = token,
				FIRSTPOS = tokenPos,
				LASTPOS = (tokenPos + #token) - 1,
			};
		table.insert(tokens, tk);
		tokenPos = 0;
		return tk;
	end;
	local function getDataLevel()
		local num = 0;
		while look(num) == "=" do
			num = num + 1;
		end;
		if look(num) == "[" then
			pos = (pos + num) + 1;
			return num;
		end;
	end;
	local function getData(level)
		local level, data, Clevel, valid = level;
		if level then
			posOffset = pos;
			start = posOffset;
			while true do
				local charL = get();
				if charL == "]" then
					valid = true;
					pos = pos - 1;
					data = getCurrentTokenText();
					pos = pos + 1;
					break;
				end;
			end;
			for i = 1, level, 1 do
				if look() == "=" then
					pos = pos + 1;
				else
					valid = false;
					ErrorLog("The data level must be equal", pos);
					break;
				end;
			end;
			if valid and look() == "]" then
				pos = (pos - level) - 1;
				posOffset = pos;
				start = posOffset;
				pos = (pos + level) + 2;
			elseif valid and look() == "=" then
				ErrorLog("The data level must be equal", pos);
			end;
			return data;
		end;
	end;
	local function chompWhitespace()
		while true do
			local char = look();
			if char == "\n" then
				pos = pos + 1;
				posOffset = pos - 1;
				start = posOffset;
				AddToken("Newline");
			elseif isWhiteSpace(char) then
				pos = pos + 1;
			else
				break;
			end;
		end;
	end;
	local function isComment(char)
		if char == "-" and look() == "-" then
			posOffset = pos - 1;
			start = posOffset;
			pos = pos + 1;
			while not isEndOfLine(look()) do
				pos = pos + 1;
			end;
			return true;
		end;
		return false;
	end;
	while true do
		chompWhitespace();
		local char = get();
		if char == EOF then
			break;
		elseif isComment(char) then
			AddToken("Comment");
		elseif (char == "-" and look() == "0") and look(1) == "x" then
			posOffset = pos - 1;
			start = posOffset;
			pos = pos + 2;
			while true do
				if isDigit(look()) then
					pos = pos + 1;
				elseif look() == "." then
					pos = pos + 1;
				elseif isHexDigit(look()) then
					pos = pos + 1;
				else
					break;
				end;
			end;
			AddToken("Negative Hex Number");
		elseif char == "0" and look() == "x" then
			posOffset = pos - 1;
			start = posOffset;
			pos = pos + 1;
			while true do
				if isDigit(look()) then
					pos = pos + 1;
				elseif look() == "." then
					pos = pos + 1;
				elseif isHexDigit(look()) then
					pos = pos + 1;
				else
					break;
				end;
			end;
			AddToken("Hex Number");
		elseif isDigit(char) or char == "." and isDigit(look()) or char == "-" and isDigit(look()) then
			posOffset = pos - 1;
			start = posOffset;
			while true do
				if isDigit(look()) then
					pos = pos + 1;
				elseif look() == "." then
					pos = pos + 1;
				elseif isHexDigit(look()) then
					pos = pos + 1;
				else
					break;
				end;
			end;
			AddToken("Number");
		elseif char == "'" or char == '"' then
			posOffset = pos - 1;
			start = posOffset;
			AddToken("String Start");
			posOffset = pos;
			start = posOffset;
			while true do
				local char2 = get();
				if char2 == "\\" then
					pos = pos + 1;
				elseif char2 == "\n" then
					ErrorLog("Single line string must not contain new line", pos);
					break;
				elseif char2 == char or char2 == EOF then
					pos = pos - 1;
					AddToken("String");
					get();
					posOffset = pos - 1;
					start = posOffset;
					AddToken("String End");
					break;
				end;
			end;
		elseif char == "=" then
			if isWhiteSpace(look()) and isWhiteSpace(look(-2)) or not isEqualityOperator(look()) and not isEqualityOperator(look(-2)) then
				posOffset = pos - 1;
				start = posOffset;
				AddToken("Assignment");
			elseif (isEqualityOperator(look(-2)) and isWhiteSpace(look())) and isWhiteSpace(look(-3)) then
				posOffset = pos - 2;
				start = posOffset;
				AddToken("Comparator");
			end;
		elseif isEqualityOperator(char) then
			posOffset = pos - 1;
			start = posOffset;
			AddToken("Comparator");
		elseif char == ":" and look() == ":" then
			posOffset = pos - 1;
			start = posOffset;
			pos = pos + 1;
			AddToken("Label Start");
			chompWhitespace();
			if isBase(look()) then
				pos = pos + 1;
				posOffset = pos - 1;
				start = posOffset;
				while isIdent(look()) do
					pos = pos + 1;
				end;
				AddToken("Label");
				chompWhitespace();
				if look() == ":" and look(1) == ":" then
					posOffset = pos;
					start = posOffset;
					pos = pos + 2;
					AddToken("Label End");
				end;
			end;
		elseif char == "." then
			if look() == "." then
				pos = pos + 1;
				if look() == "." then
					pos = pos + 1;
					posOffset = pos - 3;
					start = posOffset;
					AddToken("Vararg");
				end;
			end;
		elseif char == "[" and look() == "[" then
			posOffset = pos - 1;
			start = posOffset;
			pos = pos + 1;
			AddToken("Multi-string Start");
			posOffset = pos;
			start = posOffset;
			while true do
				local charMS = get();
				if charMS == "]" and look() == "]" then
					pos = pos - 1;
					AddToken("Multi-string");
					posOffset = pos;
					start = posOffset;
					pos = pos + 2;
					AddToken("Multi-string End");
					break;
				end;
			end;
		elseif isOperator(char) then
			posOffset = pos - 1;
			start = posOffset;
			AddToken("Operator");
		elseif isSymbol(char) then
			posOffset = pos - 1;
			start = posOffset;
			if look() == "=" then
				local level = getDataLevel();
				if level then
					AddToken("Multi-string Start");
					AddToken("Multi-string", getData(level));
					AddToken("Multi-string End");
				end;
			else
				AddToken("Symbol");
			end;
		elseif isBase(char) then
			posOffset = pos - 1;
			start = posOffset;
			while isIdent(look()) do
				pos = pos + 1;
			end;
			local word = getCurrentTokenText();
			if isKeyword(word) then
				AddToken("Keyword");
			elseif isBoolean(word) then
				AddToken("Boolean");
			else
				AddToken("Identifier");
			end;
		end;
	end;
	return tokens;
end;