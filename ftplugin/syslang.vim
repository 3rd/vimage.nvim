lua require("vimage").draw()

au BufLeave <buffer> lua require('vimage').clear()

" handle
au BufReadPost,BufWritePost,BufEnter,TextChanged,VimResized <buffer> lua require('vimage').draw()

" handle cursor movement
au CursorMoved <buffer> lua require('vimage').handle_cursor_moved()

" hide images in insert mode
au InsertEnter <buffer> lua require('vimage').clear()
au InsertLeave <buffer> lua require('vimage').draw()
