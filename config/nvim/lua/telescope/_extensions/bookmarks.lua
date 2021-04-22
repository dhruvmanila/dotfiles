local telescope = require('telescope')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local config = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local entry_display = require('telescope.pickers.entry_display')

---Path to the Brave bookmarks file
local filename = os.getenv('HOME')
  .. '/Library/Application Support/BraveSoftware/Brave-Browser/Default/Bookmarks'

---Default categories of bookmarks to look for.
local categories = {'bookmark_bar', 'other', 'synced'}

---Collect all the bookmarks in a table in the following form:
---{
---  {name = bookmark.name, url = bookmark.url},
---  ...,
---}
---@return table
local function collect_bookmarks()
  local items = {}
  local file = io.open(filename)
  local content = file:read("*a")
  file:close()
  local json_content = vim.fn.json_decode(content)

  local function insert_items(parent, bookmark)
    local name = parent
      and (parent ~= '' and parent .. '/' .. bookmark.name or bookmark.name)
      or ''
    if bookmark.type == 'folder' then
      for _, child in ipairs(bookmark.children) do
        insert_items(name, child)
      end
    else
      table.insert(items, {name = name, url = bookmark.url})
    end
  end

  for _, category in ipairs(categories) do
    insert_items(nil, json_content.roots[category])
  end
  return items
end

---Create a displayer which will be used to display the entries in telescope
---results buffer.
---@type function
local displayer = entry_display.create {
  separator = ' ',
  items = {
    {width = 65},
    {remaining = true},
  },
}

---Configure the entry to be displayed.
---@param entry table
local function make_display(entry)
  return displayer {
    entry.name,
    {entry.value, 'Grey'},
  }
end

---Entry maker for the telescope finder.
---@param entry table
---@return table
local function entry_maker(entry)
  return {
    display = make_display,
    name = entry.name,
    value = entry.url,
    ordinal = entry.name .. ' ' .. entry.url,
  }
end

---Main entrypoint from telescope
local function bookmarks(opts)
  opts = opts or {}
  local results = collect_bookmarks()

  pickers.new(opts, {
    prompt_title = 'Search Bookmarks',
    finder = finders.new_table {
      results = results,
      entry_maker = entry_maker,
    },
    previewer = false,
    sorter = config.file_sorter(opts),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        os.execute('open "' .. selection.value .. '" &> /dev/null')
      end)
      return true
    end,
  }):find()
end

return telescope.register_extension {
  exports = {bookmarks = bookmarks},
}
