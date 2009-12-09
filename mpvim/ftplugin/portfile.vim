" ============================================================================
" Vim filetype plugin for portfile
" Maintainer: Maximilian Nickel <mnick@macports.org>
" ============================================================================

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

	function TracPatch(url)
		let patchfile="$TMPDIR/portfile.patch"
		let url = substitute(a:url, "/attachment/", "/raw-attachment/", "")
		let cmd = "!curl --progress-bar -o \"" . patchfile . "\" \"" . url . "\""
		exe cmd
		exe "diffpatch " . patchfile
	endfunction

	let g:did_mpftplugin = 1
endif

au QuickFixCmdPre make exe "cclose"
au QuickFixCmdPost make call PortfileGetErrors()
command! -nargs=1 MPpatch :call TracPatch("<args>") 
