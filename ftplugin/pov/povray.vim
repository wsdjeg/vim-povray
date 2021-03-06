if !exists("g:povray_command")
    let g:povray_command = "povray"
endif

if !empty(glob("~/.vim/*/vim-do"))
    let g:execute_command = "DoQuietly"
else
    let g:execute_command = "silent !"
endif

let s:compilation_failed = 0

function! CleanPreviousImage()
    let l:remove = system("rm " . expand("%:r") . ".png")
    redraw!
endfunction

function! PovrayCompileSilent()
    call CleanPreviousImage()
    execute 'w!'
    let g:compile_output = system(g:povray_command . " "
                \ . expand("%"))
    if empty(glob(expand("%:r") . ".png"))
        let s:compilation_failed = 1
        call ShowCompilationOutput()
    else
        let s:compilation_failed = 0
    endif
endfunction

function! ShowCompilationOutput()
    execute 'silent pedit [POVRAY]' . expand("%:r") . ".png"
    wincmd P
    setlocal filetype=povray_output
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal bufhidden=wipe
    setlocal modifiable
    call append(0, split(g:compile_output, '\v\n'))
    setlocal nomodifiable

    nnoremap <silent> <buffer> q :silent bd!<CR>
endfunction

" Compile asynchronously if vim-do is installed
function! PovrayCompileAsync()
    call CleanPreviousImage()
    execute 'w!'
    execute g:execute_command . " "
                \ . g:povray_command . " "
                \ . expand("%")
    redraw!
endfunction

function! ShowImage()
    if exists("g:image_viewer")
        execute "silent ! " . g:image_viewer . " "
                    \ . expand("%:r") . ".png" . "&"
        redraw!
    else
        echom "Define an image viewer - let g:image_viewer = <viewer>"
    endif
endfunction

function! PovrayCompileAndShow()
    call PovrayCompileSilent()
    if !s:compilation_failed
        call ShowImage()
    endif
endfunction

nnoremap <F5> :call PovrayCompileAndShow()<cr>
nnoremap <F8> :call PovrayCompileAsync()<cr>
inoremap <F5> <Esc> :call PovrayCompileAndShow()<cr>
inoremap <F8> <Esc> :call PovrayCompileAsync()<cr>
nnoremap <F9> :call ShowImage()<cr>
