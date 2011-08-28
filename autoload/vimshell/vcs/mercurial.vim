"=============================================================================
" FILE: mercurial
" AUTHOR: Akihiro Okuno <choplin.public@gmail.com>
" Last Modified: 28 Aug 2011
" Usage: Just source this file.
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

" Check vcs directiory.
function! vimshell#vcs#mercurial#is_vcs_dir()"{{{
  if getcwd() =~ '[\\/]\.hg\%([\\/].*\)\?$'
    " Ignore inside .hg directiory.
    return 0
  else
    return s:get_hg_dir() != ''
  endif
endfunction"}}}

function! vimshell#vcs#mercurial#vcs_name()"{{{
  return 'mercurial'
endfunction"}}}

function! vimshell#vcs#mercurial#current_branch()"{{{
  let l:hg_dir = s:get_hg_dir()
  if !filereadable(l:hg_dir . '/branch')
    return ''
  endif

  let l:lines = readfile(l:hg_dir . '/branch')
  if empty(l:lines)
    return ''
  else
    return l:lines[0]
  endif
endfunction"}}}

function! vimshell#vcs#mercurial#repository_name()"{{{
  return fnamemodify(vimshell#vcs#mercurial#repository_root_path(), ':t')
endfunction"}}}

function! vimshell#vcs#mercurial#repository_root_path()"{{{
  return s:get_hg_dir()[: -(2+len('/.hg'))]
endfunction"}}}

function! vimshell#vcs#mercurial#repository_relative_path()"{{{
  return fnamemodify(getcwd(), ':p')[len(vimshell#vcs#mercurial#repository_root_path())+1 : -2]
endfunction"}}}

function! vimshell#vcs#mercurial#action_message()"{{{
  let codes = ['M', 'A', 'R', 'C', '!', '?', 'I']
  let l:status = {
    \'M': 'modified',
    \'A': 'added',
    \'R': 'removed',
    \'C': 'clean',
    \'!': '(deleted by non-hg command, but still tracked)',
    \'?': 'tracked',
    \'I': 'ignored'
  \}
  let l:files = {}
  let l:action = []
  for l:line in split(vimshell#system('hg status', '', 500), '\n')
    for l:code in l:codes
      if l:line =~# '^' . l:code
        if !has_key(l:files, l:code)
          let l:files[l:code] = []
        endif

        let l:file = matchstr(l:line, '\s\zs.*')
        call add(l:files[l:code], l:file)

        break
      endif
    endfor
  endfor
  for l:code in l:codes
    if has_key(l:files, l:code)
      call add(l:action, printf('%s:%d', l:status[l:code], len(l:files)))
    endif
  endfor

  return join(l:action)
endfunction"}}}

function! s:get_hg_dir()"{{{
  let l:hg_dir = finddir('.hg', ';')
  if l:hg_dir != ''
    let l:hg_dir = fnamemodify(l:hg_dir, ':p')
  endif

  return l:hg_dir
endfunction"}}}
" vim: foldmethod=marker
