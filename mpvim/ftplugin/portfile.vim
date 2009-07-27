" Vim filetype plugin for portfile
" Author: Maximilian Nickel <mnick@macports.org>

if exists("b:did_ftplugin") 
	finish
endif
let b:did_ftplugin = 1

function PortfileGetErrors()
	if !empty(getqflist())
		exe "copen"
	end
endfunction

au QuickFixCmdPre make exe "cclose"
au QuickFixCmdPost make call PortfileGetErrors()
