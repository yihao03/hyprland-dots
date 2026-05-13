------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
	output = "eDP-1",
	mode = "preferred",
	position = "auto",
	scale = "1.5",
	icc = "/home/yihao/.local/share/icc/default.icm",
	bitdepth = 10,
})

hl.monitor({
	output = "desc:Acer Technologies EK221Q H 1335088483W01",
	mode = "1920x1080@100",
	position = "auto-center-up",
})

hl.monitor({
	output = "desc:Beihai Century Joint Innovation Technology Co.Ltd X240 0000000000000",
	mode = "1920x1080@120",
	position = "auto-center-left",
})
