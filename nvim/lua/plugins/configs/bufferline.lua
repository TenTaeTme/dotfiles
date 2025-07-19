require('bufferline').setup {
  options = {
    themable = true,
    offsets = {
      {
        filetype = 'neo-tree',
        text = 'Project',
        highlight = 'Directory',
        text_align = 'left',
        separator = true,
      },
    },
  },
}
