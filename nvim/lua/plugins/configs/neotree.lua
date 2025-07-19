-- configs/neotree.lua

-- Define key mappings
vim.api.nvim_set_keymap('n', '<Leader>e', '<Cmd>Neotree toggle<CR>', { noremap = true, silent = true, desc = 'Toggle Explorer' })
vim.api.nvim_set_keymap('n', '<Leader>o', [[<Cmd>lua ToggleNeoTreeFocus()<CR>]], { noremap = true, silent = true, desc = 'Toggle Explorer Focus' })

local icons = {
  ActiveLSP = '',
  ActiveTS = '',
  ArrowLeft = '',
  ArrowRight = '',
  Bookmarks = '',
  BufferClose = '󰅖',
  DapBreakpoint = '',
  DapBreakpointCondition = '',
  DapBreakpointRejected = '',
  DapLogPoint = '󰛿',
  DapStopped = '󰁕',
  Debugger = '',
  DefaultFile = '󰈙',
  Diagnostic = '󰒡',
  DiagnosticError = '',
  DiagnosticHint = '󰌵',
  DiagnosticInfo = '󰋼',
  DiagnosticWarn = '',
  Ellipsis = '…',
  Environment = '',
  FileNew = '',
  FileModified = '',
  FileReadOnly = '',
  FoldClosed = '',
  FoldOpened = '',
  FoldSeparator = ' ',
  FolderClosed = '',
  FolderEmpty = '',
  FolderOpen = '',
  Git = '󰊢',
  GitAdd = '',
  GitBranch = '',
  GitChange = '',
  GitConflict = '',
  GitDelete = '',
  GitIgnored = '◌',
  GitRenamed = '➜',
  GitSign = '▎',
  GitStaged = '✓',
  GitUnstaged = '✗',
  GitUntracked = '★',
  LSPLoading1 = '',
  LSPLoading2 = '󰀚',
  LSPLoading3 = '',
  MacroRecording = '',
  Package = '󰏖',
  Paste = '󰅌',
  Refresh = '',
  Search = '',
  Selected = '❯',
  Session = '󱂬',
  Sort = '󰒺',
  Spellcheck = '󰓆',
  Tab = '󰓩',
  TabClose = '󰅙',
  Terminal = '',
  Window = '',
  WordFile = '󰈭',
}

local get_icon = function(name)
  -- Attempt to get the icon from the predefined table
  local icon = icons[name]
  if icon then
    return icon
  else
    -- If not found, fallback to nvim-web-devicons
    return require('nvim-web-devicons').get_icon(name, '', { default = true })
  end
end

-- Function to toggle focus on NeoTree
function ToggleNeoTreeFocus()
  if vim.bo.filetype == 'neo-tree' then
    vim.cmd.wincmd 'p'
  else
    vim.cmd.Neotree 'focus'
  end
end

-- Create augroup for NeoTree autocommands
vim.api.nvim_create_augroup('neotree_start', {})

-- Create autocommand to open NeoTree on startup with directory
vim.api.nvim_create_autocmd('BufEnter', {
  desc = 'Open Neo-Tree on startup with directory',
  group = 'neotree_start',
  callback = function()
    if package.loaded['neo-tree'] then
      return true
    else
      local stats = (vim.uv or vim.loop).fs_stat(vim.api.nvim_buf_get_name(0)) -- TODO: REMOVE vim.loop WHEN DROPPING SUPPORT FOR Neovim v0.9
      if stats and stats.type == 'directory' then
        require('lazy').load { plugins = { 'neo-tree.nvim' } }
        return true
      end
    end
  end,
})

-- Create autocommand to refresh NeoTree sources when closing lazygit
vim.api.nvim_create_autocmd('TermClose', {
  pattern = '*lazygit*',
  desc = 'Refresh Neo-Tree sources when closing lazygit',
  group = 'neotree_start',
  callback = function()
    local manager_avail, manager = pcall(require, 'neo-tree.sources.manager')
    if manager_avail then
      for _, source in ipairs { 'filesystem', 'git_status', 'document_symbols' } do
        local module = 'neo-tree.sources.' .. source
        if package.loaded[module] then
          manager.refresh(require(module).name)
        end
      end
    end
  end,
})

local git_available = vim.fn.executable 'git' == 1
local sources = {
  { source = 'filesystem', display_name = get_icon 'FolderClosed' .. ' File' },
  { source = 'buffers', display_name = get_icon 'DefaultFile' .. ' Bufs' },
  { source = 'diagnostics', display_name = get_icon 'Diagnostic' .. ' Diagnostic' },
}

if git_available then
  table.insert(sources, 3, { source = 'git_status', display_name = get_icon 'Git' .. ' Git' })
end

local neotree_config = {
  enable_git_status = git_available,
  auto_clean_after_session_restore = true,
  close_if_last_window = true,
  sources = { 'filesystem', 'buffers', git_available and 'git_status' or nil },
  source_selector = {
    winbar = true,
    content_layout = 'center',
    sources = sources,
  },
  default_component_configs = {
    indent = {
      padding = 0,
      expander_collapsed = get_icon 'FoldClosed',
      expander_expanded = get_icon 'FoldOpened',
    },
    icon = {
      folder_closed = get_icon 'FolderClosed',
      folder_open = get_icon 'FolderOpen',
      folder_empty = get_icon 'FolderEmpty',
      folder_empty_open = get_icon 'FolderEmpty',
      default = get_icon 'DefaultFile',
    },
    modified = { symbol = get_icon 'FileModified' },
    git_status = {
      symbols = {
        added = get_icon 'GitAdd',
        deleted = get_icon 'GitDelete',
        modified = get_icon 'GitChange',
        renamed = get_icon 'GitRenamed',
        untracked = get_icon 'GitUntracked',
        ignored = get_icon 'GitIgnored',
        unstaged = get_icon 'GitUnstaged',
        staged = get_icon 'GitStaged',
        conflict = get_icon 'GitConflict',
      },
    },
  },
  commands = {
    system_open = function(state)
      local node = state.tree:get_node()
      local path = node:get_id()
      vim.fn.jobstart({ 'xdg-open', path }, { detach = true })
    end,
    parent_or_close = function(state)
      local node = state.tree:get_node()
      if node:has_children() and node:is_expanded() then
        state.commands.toggle_node(state)
      else
        require('neo-tree.ui.renderer').focus_node(state, node:get_parent_id())
      end
    end,
    child_or_open = function(state)
      local node = state.tree:get_node()
      if node:has_children() then
        if not node:is_expanded() then
          state.commands.toggle_node(state)
        else
          require('neo-tree.ui.renderer').focus_node(state, node:get_child_ids()[1])
        end
      else
        state.commands.open(state)
      end
    end,
    copy_selector = function(state)
      local node = state.tree:get_node()
      local filepath = node:get_id()
      local filename = node.name
      local modify = vim.fn.fnamemodify

      local vals = {
        ['BASENAME'] = modify(filename, ':r'),
        ['EXTENSION'] = modify(filename, ':e'),
        ['FILENAME'] = filename,
        ['PATH (CWD)'] = modify(filepath, ':.'),
        ['PATH (HOME)'] = modify(filepath, ':~'),
        ['PATH'] = filepath,
        ['URI'] = vim.uri_from_fname(filepath),
      }

      local options = vim.tbl_filter(function(val)
        return vals[val] ~= ''
      end, vim.tbl_keys(vals))
      if vim.tbl_isempty(options) then
        vim.notify('No values to copy', vim.log.levels.WARN)
        return
      end
      table.sort(options)
      vim.ui.select(options, {
        prompt = 'Choose to copy to clipboard:',
        format_item = function(item)
          return ('%s: %s'):format(item, vals[item])
        end,
      }, function(choice)
        local result = vals[choice]
        if result then
          vim.notify(('Copied: `%s`'):format(result))
          vim.fn.setreg('+', result)
        end
      end)
    end,
    avante_add_files = function(state)
      local node = state.tree:get_node()
      local filepath = node:get_id()
      local relative_path = require('avante.utils').relative_path(filepath)

      local sidebar = require('avante').get()

      local open = sidebar:is_open()
      -- ensure avante sidebar is open
      if not open then
        require('avante.api').ask()
        sidebar = require('avante').get()
      end

      sidebar.file_selector:add_selected_file(relative_path)

      -- remove neo tree buffer
      if not open then
        sidebar.file_selector:remove_selected_file 'neo-tree filesystem [1]'
      end
    end,
  },
  window = {
    width = 30,
    mappings = {
      ['<S-CR>'] = 'system_open',
      ['<Space>'] = false,
      ['[b'] = 'prev_source',
      [']b'] = 'next_source',
      O = 'system_open',
      Y = 'copy_selector',
      h = 'parent_or_close',
      l = 'child_or_open',
      ['oa'] = 'avante_add_files',
    },
    fuzzy_finder_mappings = {
      ['<C-J>'] = 'move_cursor_down',
      ['<C-K>'] = 'move_cursor_up',
    },
  },
  filesystem = {
    follow_current_file = { enabled = true },
    filtered_items = { hide_gitignored = git_available, hide_dotfiles = false, visible = true },
    hijack_netrw_behavior = 'open_current',
    use_libuv_file_watcher = vim.fn.has 'win32' ~= 1,
  },
  event_handlers = {
    {
      event = 'neo_tree_buffer_enter',
      handler = function(_)
        vim.opt_local.signcolumn = 'auto'
        vim.opt_local.foldcolumn = '0'
      end,
    },
  },
}

-- Integrate with telescope.nvim if available
if pcall(require, 'telescope') then
  neotree_config.commands.find_in_dir = function(state)
    local node = state.tree:get_node()
    local path = node.type == 'file' and node:get_parent_id() or node:get_id()
    require('telescope.builtin').find_files { cwd = path }
  end
  neotree_config.window.mappings.F = 'find_in_dir'
end

-- Integrate with toggleterm.nvim if available
if pcall(require, 'toggleterm') then
  local toggleterm_in_direction = function(state, direction)
    local node = state.tree:get_node()
    local path = node.type == 'file' and node:get_parent_id() or node:get_id()
    require('toggleterm.terminal').Terminal:new({ dir = path, direction = direction }):toggle()
  end
  local prefix = 'T'
  neotree_config.window.mappings[prefix] = { 'show_help', nowait = false, config = { title = 'New Terminal', prefix_key = prefix } }
  for suffix, direction in pairs { f = 'float', h = 'horizontal', v = 'vertical' } do
    local command = 'toggleterm_' .. direction
    neotree_config.commands[command] = function(state)
      toggleterm_in_direction(state, direction)
    end
    neotree_config.window.mappings[prefix .. suffix] = command
  end
end

-- Finally, call setup with the complete configuration
require('neo-tree').setup(neotree_config)
