local present, nvim_autopairs = pcall(require, "nvim-autopairs")
if not present then
  return
end

nvim_autopairs.setup({
  enable_check_bracket_line = true,
  ignored_next_char = "[%w%.]",
  check_ts = true,
  ts_config = {
    lua = {'string'},
    javascript = {'template_string'},
    java = false,
  },
  fast_wrap = {
    map = '<M-e>',
    chars = { '{', '[', '(', '"', "'" },
    pattern = [=[[%'%"%)%>%]%)%}%,]]=],
    end_key = '$',
    keys = 'qwertyuiopzxcvbnmasdfghjkl',
    check_comma = true,
    highlight = 'Search',
    highlight_grey='Comment'
  },
})

-- Integration with cmp (if you're using it)
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local cmp = require('cmp')
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)

-- Add spaces between parentheses
local Rule = require('nvim-autopairs.rule')
nvim_autopairs.add_rules {
  Rule(' ', ' ')
    :with_pair(function (opts)
      local pair = opts.line:sub(opts.col - 1, opts.col)
      return vim.tbl_contains({ '()', '[]', '{}' }, pair)
    end),
  Rule('( ', ' )')
      :with_pair(function() return false end)
      :with_move(function(opts)
          return opts.prev_char:match('.%)') ~= nil
      end)
      :use_key(')'),
  Rule('{ ', ' }')
      :with_pair(function() return false end)
      :with_move(function(opts)
          return opts.prev_char:match('.%}') ~= nil
      end)
      :use_key('}'),
  Rule('[ ', ' ]')
      :with_pair(function() return false end)
      :with_move(function(opts)
          return opts.prev_char:match('.%]') ~= nil
      end)
      :use_key(']')
}

-- Auto close HTML/Vue tags
local filetypes = {
  'html', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'vue', 'tsx', 'jsx', 'xml'
}

local skip_tags = {
  'area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'slot',
  'input', 'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr','component'
}

for _, filetype in ipairs(filetypes) do
  nvim_autopairs.add_rules {
    Rule("<", ">", filetype)
      :with_pair(function(opts)
        local pair = opts.line:sub(opts.col - 1, opts.col)
        return vim.tbl_contains(skip_tags, pair)
      end),
    Rule("<", ">", filetype)
      :with_pair(function()
        return false
      end)
      :with_move(function(opts)
        return opts.prev_char:match(".>") ~= nil
      end)
      :use_key(">");
  }
end