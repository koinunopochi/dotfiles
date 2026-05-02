set clipboard=unnamedplus

" --- OSC 52: yank を端末経由でローカルクリップボードに流す ---
" vim-oscyank (~/.vim/pack/plugins/start/vim-oscyank) に依存
let g:oscyank_silent = 1

augroup OSCYank
  autocmd!
  autocmd TextYankPost *
        \ if v:event.operator ==# 'y' |
        \   call OSCYank(join(v:event.regcontents, "\n")) |
        \ endif
augroup END

" --- 軽量タグナビゲーション ---
set tags=./tags;,tags
set path+=**
set suffixesadd+=.php,.js,.ts,.tsx,.jsx,.py,.rb,.go,.java,.kt,.rs,.c,.h,.cpp,.hpp
nnoremap <C-]> g<C-]>

" --- 表示 ---
syntax on
set number
