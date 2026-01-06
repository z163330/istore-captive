module("luci.controller.cp", package.seeall)

function index()
  entry({"admin", "services", "cp_codes"}, cbi("cp_codes"), "兑换码管理", 60)
end