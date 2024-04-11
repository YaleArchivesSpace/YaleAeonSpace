LogInfo("Loading YaleAeonSpace plugin")

luanet.load_assembly("System")
luanet.load_assembly("System.Data")
luanet.load_assembly("System.Net")

require("Atlas-Addons-Lua-ParseJson.JsonParser")
require("Base64Encode")

-- This is the Atlas way of importing types, saved as a reference in case the HM way below seems to stop working
--Types = {};
--Types["System.Text.Encoding"] = luanet.import_type("System.Text.Encoding");

Ctx = {
   Encoding = luanet.import_type("System.Text.Encoding"),
   DataTable = luanet.import_type("System.Data.DataTable"),
   WebClient = luanet.import_type("System.Net.WebClient"),
   NameValueCollection = luanet.import_type("System.Collections.Specialized.NameValueCollection"),
   InterfaceManager = GetInterfaceManager(),
   BaseUrl = GetSetting("ArchivesSpaceAPIURL"),
   Username = GetSetting("ArchivesSpaceUser"),
   Password = GetSetting("ArchivesSpacePassword"),
   TabName = GetSetting("TabName"),
   LogLabel = GetSetting("LogLabel")
   ArchivesSpaceFields = GetSetting("ArchivesSpaceFields")
   AeonFields = GetSetting("AeonFields")
}

-- Needs to come after settings are imported, as it uses settings values
require("Logging");

-- Base URL requires a trailing slash
Ctx.BaseUrl = string.gsub(Ctx.BaseUrl .. "/", "/+$", "/")

function fileExists(path)
   local fh = io.open(path, "r")

   if fh == nil then
      return false
   else
      io.close(fh)
      return true
   end
end

function findInPath(name)
   local haystack = package.path .. ";"

   local start_idx = 0

   while true do
      end_idx = string.find(haystack, ";", start_idx)

      if end_idx == nil then
         break
      end

      local pattern = string.sub(haystack, start_idx, end_idx - 1)

      if (fileExists(string.gsub(pattern, "?", name))) then
         result, _ = string.gsub(pattern, "?", name)
         return result
      end

      start_idx = end_idx + 1
   end

   return nil
end

function Init()
	-- Build field mapping table
	mapToAeon = {};
	if string.len(Ctx.ArchivesSpaceFields) > 0 and string.len(Ctx.AeonFields) > 0 then
		local i = 0;
		for aspaceName in string.gmatch(Ctx.ArchivesSpaceFields, "[^|]+") do
			local m = 0;
			for aeonName in string.gmatch(Ctx.AeonFields, "[^|]+") do
				if m == i then
					mapToAeon[aspaceName] = aeonName;
				end
				m = m + 1;
			end
			i = i + 1;
		end
	end
   local mainProgram = findInPath("YaleAeonAspace")
   dofile(mainProgram)

   Ctx.PluginBaseDir = mainProgram:match("(.*\\)")

   ConfigureForm()
end
