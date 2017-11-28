if not LOCALE_zhCN or GRA_FORCE_ENGLISH then return end

local L = select( 2, ...).L

-- L["Stop tracking loots and attendances?"]
-- L["Stop Tracking This Raid"]
L["%d raid logs have been received: %s"] = "%d 天的活动记录已接收：%s"
L["About"] = "关于"
L["Absent"] = "缺勤"
L["Absentees"] = "缺勤者"
L["All"] = "全选"
L["Announcements"] = "公告"
L["Attendance Sheet"] = "出勤表"
L["Attendees"] = "出勤者"
L["Author"] = "作者"
L["Award EP"] = "奖励 EP"
L["Base GP has been set to "] = "基础 GP 已被设置为 "
L["Base GP"] = "基础 GP"
L["Check to show this class."] = "勾选以显示该职业。"
L["Config"] = "设置"
L["Credit GP"] = "记入 GP"
L["Raid start time has been set to "] = "活动开始时间已被设置为 "
L["Raid Start Time: "] = "活动开始时间："
L["Raid Start Time"] = "活动开始时间"
L["Decay EP and GP by %d%%?"] = "将 EP 与 GP 衰减 %d%%？"
L["Decay has been set to "] = "衰减已被设置为 "
L["Decay"] = "衰减"
L["Decayed EP and GP by %d%%."] = "EP 与 GP 已衰减 %d%%。"
L["Delete this Entry and undo changes to EP/GP?"] = "删除此项并返还 EP 或 GP？"
L["Discard All Changes"] = "放弃所有更改"
L["EP Award"] = "EP 奖励"
L["EPGP Options"] = "EPGP 选项"
L["Excluding EP/GP in officer note"] = "不包含官员备注中的EP/GP"
L["Fri"] = "周五"
L["GP Credit"] = "GP 记入"
L["GP Modify"] = "GP 修改"
L["GP Undo"] = "GP 撤销"
L["EP Modify"] = "EP 修改"
L["EP Undo"] = "EP 撤销"
L["EP Penalize"] = "EP 惩罚"
L["EP Penalize Undo"] = "EP 惩罚撤销"
L["GP Penalize"] = "GP 惩罚"
L["GP Penalize Undo"] = "GP 惩罚撤销"
L["Penalize"] = "必须惩罚"
L["Guilty!"] = "有罪！"
L["Green"] = "绿色"
L["Guild Rank:"] = "公会级别:"
L["Import"] = "导入"
L["Join Time: "] = "进团时间："
L["Keep track of loots and attendances during this raid session?"] = "为此副本记录拾取与出勤？"
L["Last updated time: "] = "最后更新时间："
L["Late"] = "迟到"
L["Left Click: "] = "左键单击："
L["Left raid instance, Stop tracking."] = "已离开副本，停止记录。"
L["Legend"] = "图例"
L["Looter"] = "物品获得者"
L["Magenta"] = "品红色"
L["Attendance Editor"] = "出勤编辑"
L["Members: "] = "成员："
L["members"] = "成员"
L["Memory usage"] = "内存占用"
L["Min EP has been set to "] = "最小 EP 已被设置为 "
L["Min EP"] = "最小 EP"
L["Misc"] = "杂项"
L["Modify EP"] = "修改 EP"
L["Modify GP"] = "修改 GP"
L["Modify"] = "修改"
L["Mon"] = "周一"
L["Name"] = "名字"
L["never"] = "从不"
L["No member"] = "无成员"
L["No raid log"] = "无活动记录"
L["No"] = "否"
L["OK"] = "OK"
L["On Leave"] = "请假"
L["Present"] = "出勤"
L["Raid Logs"] = "活动记录"
L["Raid roster has been received."] = "团队名单已接收。"
L["Raid tracking started."] = "副本记录已开始。"
L["Raid: "] = "副本："
L["Raids: "] = "活动记录数："
L["Reason"] = "理由"
L["Receive raid logs data from %s?"] = "接收来自 %s 的活动记录数据？"
L["Receive Raid Logs"] = "接收活动记录"
L["Receive Raid Roster"] = "接收团队名单"
L["Receive roster data from %s?"] = "接收来自 %s 的团队名单数据？"
L["Receiving raid logs data from %s"] = "正在接收来自 %s 的活动记录数据"
L["Receiving roster data from %s"] = "正在接收来自 %s 的团队名单数据"
L["Red"] = "红色"
L["Refresh"] = "刷新"
L["Reload"] = "重载"
L["Reset all data?"] = "重置所有数据？"
L["Reset EP and GP?"] = "重置 EP 与 GP？"
L["Reset EPGP"] = "重置 EPGP"
L["Reset"] = "重置"
L["Resume last raid"] = "恢复上次的副本记录"
L["Resumed last raid (%s)."] = "恢复上次的副本记录（%s）。"
L["Right Click: "] = "右键单击："
L["Roster Editor"] = "名单编辑"
L["Roster"] = "名单"
L["Sat"] = "周六"
L["Save All Changes"] = "保存所有更改"
L["Select All"] = "全选"
L["Date Columns"] = "日期列"
L["Attendance Rate Columns"] = "出勤率列"
L["Send raid roster data to raid/party members?"] = "发送团队名单数据给团队/小队成员？"
L["Send Roster"] = "发送名单"
L["Send selected raid logs data to raid/party members?"] = "将选中的活动记录数据发送给团队或小队成员？"
L["Send To Raid"] = "发送至团队"
L["Set"] = "设置"
L["Toggle Anchor"] = "开关锚点"
L["Sort attendance sheet by class."] = "按职业排列出勤表。"
L["Sort attendance sheet by EP."] = "按 EP 排列出勤表。"
L["Sort attendance sheet by GP."] = "按 GP 排列出勤表。"
L["Sort attendance sheet by name."] = "按名字排列出勤表。"
L["Sort attendance sheet by PR."] = "按 PR 排列出勤表。"
L["Sort: "] = "排序："
L["Sun"] = "周日"
L["Thu"] = "周四"
L["Today's EP: "] = "今日 EP："
L["Today's GP: "] = "今日 GP："
L["Track This Raid"] = "记录此副本"
L["Translators"] = "翻译人员"
L["Tue"] = "周二"
L["Unselect All"] = "全不选"
L["Use Game Font"] = "使用游戏字体"
L["Value"] = "分值"
L["Version"] = "版本"
L["Websites"] = "发布网站"
L["Wed"] = "周三"
L["Yellow"] = "黄色"
L["Yes"] = "是"
-- L["Check to use EPGP system for your raid team."] = 
L["EPGP is disabled"] = "EPGP 已禁用"
L["Disable EPGP?"] = "禁用 EPGP？"
L["Enable EPGP"] = "启用 EPGP" 
L["Enable EPGP?"] = "启用 EPGP？"
L["EPGP disabled."] = "EPGP 已禁用。"
L["EPGP enabled."] = "EPGP 已启用。"
L["Record Loot"] = "记录拾取"
L["Ignored"] = "忽略"
L["Record it!"] = "记录！"
L["Note"] = "备注"
L["Item"] = "物品"
-- L["EPGP system stores its data in officer notes.\nYou'd better back up your officer notes before using EPGP."]
-- L["Sort attendance sheet by attendance rate (lifetime)."]
-- L["Sort attendance sheet by attendance rate (90 days)."]
-- L["Sort attendance sheet by attendance rate (60 days)."]
-- L["Sort attendance sheet by attendance rate (30 days)."]
-- L["Send roster data to raid members"]
-- L["Raid members data (including attendance rate)."]
-- L["Raid schedule settings."]
-- L["EPGP settings (if enabled)."]
L["Raid Date: "] = "活动日期："
-- L["Send selected logs to raid members"]
-- L["GRA must be installed to receive data."]
-- L["Select multiple logs with the Ctrl and Shift keys."]
-- L["Attendance rate data will be sent ATST."]
L["New Raid Log"] = "新建活动记录"
L["Create a new raid log"] = "创建新的活动记录"
-- L["After creating it, you can manually edit attendance."]
L["Create"] = "创建"
L["Cancel"] = "取消"
L["Delete Raid Log"] = "删除活动记录"
-- L["Delete selected raid logs."]
-- L["Select multiple logs with the Ctrl and Shift keys."]
-- L["Delete selected raid logs data?"]
-- L["This will affect attendance rate!"]
-- L["Deleted raid logs: "]
-- L["Apply changes to roster?"]
-- L["Deleted: "]
-- L["Renamed: "]
-- L["Edit Name"]
-- L["Double Click: "]
-- L["Edit fullname (must contain realm name)."]
-- L["All related logs will be updated."]
-- L["Attendance Editor Help"]
-- L["Double click on the second column: "]
-- L["Select attendance status."]
-- L["Double click on the third column: "]
-- L["Set join time (Present) / note (Absent)."]
-- L["Join after \"Raid Start Time\" means the member is late.\n\nIt's used as default raid start time for each day, you can set a different time in attendance editor."]
-- L["New version found (%s). Please visit https://mods.curse.com/addons/wow/guild-raid-attendance to get the latest version."]

-------------------------------------------------------
-- config
-------------------------------------------------------
L["Help"] = "帮助"

-------------------------------------------------------
-- loot distribution
-------------------------------------------------------
-- L["A simple loot distribution tool. You might want to use |cFF00BFFFBigDumbLootCouncil|r or |cFF00BFFFRCLootCouncil|r, if you need more functionality."]
L["iLevel: "] = "物品等级："
L["Loot Distr"] = "物品分配"
L["Loot Distribution"] = "物品分配"
-- L["Quick Notes"]
-- L["Loot Master Only"]
-- L["Only when you're the loot master and in a raid instance will these take effect."]
L["Enable Loot Distribution tool"] = "启用物品分配工具"
-- L["Disable loot distribution tool?"]
-- L["GRA Loot Distribution Tool"]
L["Loot distr tool is disabled"] = "物品分配工具已禁用"
-- L["Save Reply Buttons"]
-- L["Reply buttons saved."]
L["Warforged"] = "战火"
L["Titanforged"] = "泰坦"
L["Socket"] = "插槽"
L["Pass"] = "放弃"
L["End Session"] = "结束此分配"
-- L["Response"]
-- L["Current Gear"]
-- L["Notes"]
-- L["Loot distribution tool enabled."]
-- L["Considering..."]

-------------------------------------------------------
-- help
-------------------------------------------------------
L["Get Started"] = "开始"
L["Start Tracking"] = "开始记录"
L["Edit Attendance"] = "修改出勤"
L["Raid Log Entries"] = "活动记录条目"
L["Loot Distribution Tool"] = "物品分配工具"
L["Slash Commands"] = "斜杠命令"
-- L["GET_STARTED"] = [[
    
-- ]]
