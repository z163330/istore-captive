local json = require "luci.jsonc"
local fs   = require "nixio.fs"

local f = SimpleForm("captive", "兑换码管理", "批量生成、作废、延长时长")
local o = f:field(Value, "count", "生成数量", "")
o.rmempty = false
o.datatype = "uinteger"
local t = f:field(Value, "mins", "时长(分钟)", "")
t.rmempty = false
t.datatype = "uinteger"
local n = f:field(Value, "note", "备注", "")

function f.handle(self, state, data)
  if state == FORM_VALID then
    os.execute("/usr/bin/codegen.sh %d %d '%s'"
               % {data.count, data.mins, data.note or ""})
    luci.http.redirect(luci.dispatcher.build_url("admin/services/captive"))
  end
end

-- 已生成码列表
local db = json.parse(fs.readfile("/etc/captive/codes.json") or "{}")
local tbody = ""
for c,d in pairs(db) do
  tbody = tbody .. "<tr><td>"..c.."</td><td>"..(d.mins or 0).."</td><td>"..
          (d.used==1 and "已用" or "未用").."</td><td>"..(d.note or "").."</td></tr>"
end
f:section(SimpleSection).template = "cbi/nullsection"
f:section(SimpleSection).html = [[
<table class="cbi-section-table">
 <tr><th>兑换码</th><th>分钟</th><th>状态</th><th>备注</th></tr>
]]..tbody.."</table>"
return f