unmap <Space>

" vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")
" vmap K :masove '<-2<CR>gv=gv
" nmap H "^"
nmap("L" , "$")

exmap linedown obcommand editor:swap-line-down
nmap <A-j> :linedown
" vmap J :swap-line-down

" exmap xxx obcommand editor:swap-line-down
" nmap <A-m> :xxx

exmap lineup obcommand editor:swap-line-up
nmap <A-k> :lineup
" vmap K :swap-line-up

" Emulate Tab Switching https://vimhelp.org/tabpage.txt.html#gt
" requires Cycle Through Panes Plugins https://obsidian.md/plugins?id=cycle-through-panes
exmap nexttab obcommand workspace:next-tab
nmap K :nexttab
exmap previoustab obcommand workspace:previous-tab
nmap J :previoustab
