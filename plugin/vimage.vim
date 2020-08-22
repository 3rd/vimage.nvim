if exists("g:loaded_vimg") | finish | endif
let s:save_cpo = &cpo
set cpo&vim

" This is truly horrific.
" "I'm gonna make my own editor one day." - Jane Doe
fun! vimage#compute_line_heights()
  let l:result = []

  " Works for nowrap
  let l:line_count = line('$')
  let l:result = map(range(1, l:line_count), 1)

  " " -- Wrap logic, disabled because it's painfully slow
  " let l:start = 0
  " let l:end = 0
  " let l:win_view = winsaveview()
  " " let l:old_query = getreg('/')
  " let l:last_line = line('$')
  " keepjumps normal! gg
  " while 1
  "   let l:start = winline()
  "   keepjumps normal! $
  "   let l:end = winline()
  "   let l:height = l:end - l:start + 1
  "   call add(l:result, l:height)
  "   if line('.') == last_line
  "     break
  "   endif
  "   keepjumps normal! +
  " endwhile
  " call winrestview(l:win_view)
  " " call setreg('/', l:old_query)
  return l:result
endfun

nmap <F10> :lua require('vimage').draw()<cr>

let &cpo = s:save_cpo
unlet s:save_cpo
let g:loaded_vimg = 1

