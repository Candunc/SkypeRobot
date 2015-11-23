if arg[1] == nil or arg[1] == "" then
	print("break 01")
	os.exit(1)
end

HelpText = [[I was designed by Duncan Bristow. Prefix commands with an exclamation mark, the below are acceptable commands and their required arguments. The minimum amount of time between notifications is 5 minutes.

add @[handle] [number] - Add your number and handle to the bot to watch for.
del @[handle] - Remove your handle from the watchlist, as well as your number from the database.
calc [question] - Compute a mathmatical question.
help - Brings up this help text

If you have any improvements or suggestions contact me. https://www.candunc.com
]]

function VerifyMessage(input)
	for key,value in pairs(db) do
		if gsubNum(input["message"],key) > 0 then
			if (db["timing"][key]) == nil or (db["timing"][key]) < (os.time()-300) then -- Rate limit to one text per five minutes.
				db["timing"][key] = os.time()
				WriteDB(db)
				SendMessage("You were mentioned on Skype by "..input["sender"].." - \\\""..string.sub(input["message"],0,256).."\\\"")
			end
		end
	end
end

function SendMessage(number,message)
--	os.execute("osascript -e 'tell application \"Messages\"' -e 'send \""..string.gsub(message,"'","").."\" to buddy \""..number.."\" of (service 1 whose service type is iMessage)' -e 'end tell'")
end

function Reply(username,message)
	os.execute("arch -i386 python2.7 sender.py "..username.." '"..string.gsub(message,"'",'"').."'")
--	print(username,message)
end

function ReadDB() --Returns a table object of the database
	local file = io.open("database.json","r")
	if file == nil then
		return {timing={}; confirmed={};}
	else
		local output = json.decode(file:read("*a"))
		file:close()
		return output
	end
end

function WriteDB(input) -- Writes the table to the file database.json
	local file = io.open("database.json","w")
	file:write(json.encode(input))
	file:close()
end

function gsubNum(input,search)
	local a,b = string.gsub(input,search,"")
	return b
end

function Query(input)
	local file = io.open("key","r")
	local key = file:read("*a")
	file:close() -- Super inefficient, but I have to hide my API key and I'm tired tonight. Will add to db later.

	local xml = require("xml")
	local http = require("socket.http")
	
	local data = xml.load(http.request("http://api.wolframalpha.com/v2/query?appid="..key.."&format=plaintext&input="..string.gsub(input," ","%%20")))
	local output = {alt={}}

	if data["error"] == true then
		return 1,data[1][2][1]
	else
		if data[1][1]["xml"] == "didyoumean" then
			local text = "Did you mean: "
			for key,value in ipairs(data[1]) do
				text = (text.."\n'"..value[1].."'")
			end
			return 2,text

		else
			output["input"] = data[1][1][1][1]
			output["answer"] = data[2][1][1][1]
			for key,value in ipairs(data[3]) do
				if value[1][1] ~= nil then
					output["alt"][key] = value[1][1]
				end
			end

			return 0,output
		end
	end
end

json = require("json")
local input = string.gsub(arg[1],"\n","")
argument,err = json.decode(input)
if argument == nil then
	print("break 02",err,arg[1])
	os.exit(1)
end

if argument["status"] == "RECEIVED" or argument["status"] == "SENT" then
	if string.sub(argument["message"],1,1) == "!" then
		local input = {count=0;}
		for part in string.gmatch(string.sub(argument["message"],2), "([^ ]+)") do
			input[input["count"]] = part
			input["count"] = (input["count"]+1)
		end
		input["count"] = (input["count"]-1)
		local cmd = string.lower(input[0])

		if cmd == "add" then
			if input["count"] < 2 or string.sub(input[1],1,1) ~= "@" then
				Reply(argument["username"],"Incorrect syntax. Expected !add @[handle] [number]\nExample: !add @John 8005550199")
			else
				db = ReadDB()
				db[string.lower(input[1])] = string.gsub(input[2],"-","")
				WriteDB(db)
				Reply(argument["username"],"Successfully added '"..input[1].."' to the database with the number '"..input[2].."'")
			end

		elseif cmd == "del" then
			if input["count"] < 1 or string.sub(input[1],1) ~= "@" then
				Reply(argument["username"],"Incorrect syntax. Expected !del @[handle] \nExample: !del @John")
			else
				db = ReadDB()
				db[string.lower(input[1])] = nil
				WriteDB(db)
				Reply(argument["username"],"Successfully removed '"..input[1].."' from the database.")
			end

		elseif cmd == "calc" or cmd == "math" then
			local status,output = Query(string.sub(argument["message"],7))
			if status == 0 then
				local text = ("Input recieved: '"..output["input"].."'\n"..output["answer"].."\n\nAlternate measurements:")
				for key,value in ipairs(output["alt"]) do
					text = (text.."\n"..value)
				end
				Reply(argument["username"],text)

			elseif status == 1 then
				Reply(argument["username"],"Error: "..output)

			elseif status == 2 then
				Reply(argument["username"],output)

			else
				Reply(argument["username"],"An unknown error has occured.")
			end

		elseif cmd == "help" then
			Reply(argument["username"],HelpText)
		end
	else
		if gsubNum(argument["message"],"@") > 0 then
			db = ReadDB()
			VerifyMessage(argument)
		end
	end
end
