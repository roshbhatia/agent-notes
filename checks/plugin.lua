local root = assert(vim.env.AGENT_NOTES_SOURCE)
vim.opt.runtimepath:prepend(root)
local file = vim.fn.tempname() .. ".go"
vim.fn.writefile({ "package auth", "func ValidToken() bool { return true }" }, file)
local added = vim
  .system(
    { "note", "add", "--file", file, "--line", "2", "--summary", "Reject empty tokens", "--origin", "user" },
    { text = true }
  )
  :wait()
assert(added.code == 0, added.stderr)
vim.cmd.edit(vim.fn.fnameescape(file))
local notes = require("agent_notes")
notes.setup({ command = "note" })
assert(
  vim.wait(5000, function()
    return notes.count() == 1
  end),
  "note did not load"
)
assert(notes.for_file(file)[1].summary == "Reject empty tokens")
require("agent_notes.list").quickfix()
local items = vim.fn.getqflist()
assert(#items == 1 and items[1].lnum == 2, "quickfix note missing")
assert(vim.api.nvim_buf_get_name(items[1].bufnr) == file)
assert(package.loaded["harness.launch"] == nil and package.loaded["snacks"] == nil)
vim.fn.delete(file)
print("Standalone note loading and quickfix passed")
vim.cmd("qa!")
