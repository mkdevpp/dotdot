return {
	{
		"saghen/blink.cmp",
		opts = {
			completion = {
				menu = { border = "single" },
				documentation = { window = { border = "single" } },
			},
			signature = { window = { border = "single" } },
			keymap = {
				preset = "super-tab",
				-- ["<Tab>"] 이 설정은 lazyvim이 sper-tab 설정을 읽지 못하는 버그를 위한 것이다. 패치되면 삭제 필요
				["<Tab>"] = {
					require("blink.cmp.keymap.presets").get("super-tab")["<Tab>"][1],
					require("lazyvim.util.cmp").map({ "snippet_forward", "ai_accept" }),
					"fallback",
				},
			},
		},
	},
}
