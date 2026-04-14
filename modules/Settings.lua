local HttpService = game:GetService("HttpService")

local Settings = {}
Settings.FileName = "rb_settings.json"
Settings.Data = {}

function Settings:Save(data)
    self.Data = data or self.Data
    local json = HttpService:JSONEncode(self.Data)
    pcall(writefile, self.FileName, json)
end

function Settings:Load()
    if not isfile or not readfile then return {} end
    
    if isfile(self.FileName) then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(self.FileName))
        end)
        if ok and type(data) == "table" then
            self.Data = data
            return data
        end
    end
    return {}
end

return Settings
