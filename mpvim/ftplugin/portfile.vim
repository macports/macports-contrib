" Vim filetype plugin for portfile
" Author: Maximilian Nickel <mnick@macports.org>

if exists("b:did_ftplugin")
	finish
endif
let b:did_ftplugin = 1

if !exists("g:did_mpftplugin") 
	function PortfileGetErrors()
		if !empty(getqflist())
			exe "copen"
		end
	endfunction
	let g:did_mpftplugin = 1
endif

au QuickFixCmdPre make exe "cclose"
au QuickFixCmdPost make call PortfileGetErrors()
