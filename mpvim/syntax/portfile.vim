" Vim syntax file
" Language: 	MacPorts Portfiles
" Maintainer: 	Maximilian Nickel <mnick@macports.org>
"

if &compatible || v:version < 603
	finish
endif

if exists("b:current_syntax")
	finish
endif

" Disable whitespace error highlight if variable is not set
if !exists("g:portfile_highlight_space_errors")
	let g:portfile_highlight_space_errors=0
endif

let is_tcl=1
runtime! syntax/tcl.vim

unlet b:current_syntax


syn match PortfileGroup 		"{.\+}" contained
syn match PortfileYesNo 		"\(yes\|no\)" contained

syn keyword PortfileRequired 	PortSystem name version maintainers
syn keyword PortfileRequired 	homepage master_sites categories platforms checksums
syn match PortfileRequired 		"^\(long_\)\?description" nextgroup=PortfileDescription skipwhite
syn region PortfileDescription 	matchgroup=Normal start="" skip="\\$" end="$" contained

syn keyword PortfileOptional 	PortGroup epoch revision worksrcdir distname platform
syn keyword PortfileOptional 	use_automake use_autoconf use_configure
syn keyword PortfileOptional 	patch_sites distfiles dist_subdir license conflicts
syn keyword PortfileOptional 	replaced_by supported_archs

syn keyword PortfileOptional 	checksums nextgroup=PortfileChecksums skipwhite
syn region PortfileChecksums 	matchgroup=Normal start="" skip="\\$" end="$" contained contains=PortfileChecksumsType
syn keyword PortfileChecksumsType md5 sha1 rmd160 sha256 contained

syn match PortfilePhases 		"\(\(pre\|post\)\-\)\?\(fetch\|checksum\|extract\|patch\|configure\|build\|test\|destroot\|archive\|install\|activate\)\s" contains=PortfilePrePost

" Fetch phase options
syn match PortfilePhasesFetch   "fetch\.\(type\|user\|password\|use_epsv\|ignore_sslcert\)"
syn match PortfilePhasesFetch 	"cvs\.\(root\|password\|tag\|date\|module\)"
syn match PortfilePhasesFetch 	"svn\.\(url\|revision\)"
syn match PortfilePhasesFetch 	"git\.\(url\|branch\)"
syn match PortfilePhasesFetch 	"hg\.\(url\|tag\)"

" Extract phase options
syn match PortfilePhasesExtract "extract\.\(suffix\|mkdir\|cmd\|only\(\-\(append\|delete\)\)\?\)"
syn match PortfilePhasesExtract "use_\(7z\|bzip2\|lzma\|zip\)" nextgroup=PortfileYesNo skipwhite

" Patch phase options
syn match PortfilePhasesPatch 	"patch\.\(dir\|cmd\|args\(\-\(append\|delete\)\)\?\)"
syn match PortfilePhasesPatch 	"patchfiles\(\-\(append\|delete\)\)\?"

" Configure phase options
syn keyword PortfilePhasesConf 	use_configure nextgroup=PortfileYesNo skipwhite
syn match PortfilePhasesConf 	"configure\.\(env\|\(c\|ld\|cpp\|cxx\|objc\|f\|fc\|f90\)flags\)\(-\(append\|delete\)\)\?"
syn match PortfilePhasesConf 	"configure\.\(\(pre\|post\)\-\)\?args\(-\(\append\|delete\)\)\?" nextgroup=PortfileConfEntries skipwhite
syn region PortfileConfEntries 	matchgroup=Normal start="" skip="\\$" end="$" contained
syn match PortfilePhasesConf 	"configure\.\(cc\|cpp\|cxx\|objc\|fc\|f77\|f90\|javac\|compiler\)"
syn match PortfilePhasesConf 	"configure\.\(perl\|python\|ruby\|install\|awk\|bison\)"
syn match PortfilePhasesConf 	"configure\.\(pkg_config\(_path\)\?\)"
syn match PortfilePhasesConf 	"configure.universal_\(args\|\(c\|cpp\|cxx\|ld\)flags\)"

" Automake and Autoconf
syn match PortfilePhasesAA 		"use_auto\(make\|\(re\)\?conf\)" nextgroup=PortfileYesNo skipwhite
syn match PortfilePhasesAA 		"auto\(make\|\(re\)\?conf\).\(env\|args\|dir\)"

" Build phase options
syn match PortfilePhasesBuild 	"build\.\(cmd\|type\|dir\)"
syn match PortfilePhasesBuild 	"build\.\(\(pre\|post\)_\)\?args"
syn match PortfilePhasesBuild 	"build\.\(target\|env\)\(-\(append\|delete\)\)\?"
syn keyword PortfilePhasesBuild use_parallel_build nextgroup=PortfileYesNo skipwhite

" Test phase options
syn match PortfilePhasesTest 	"test\.\(run\|cmd\|target\)"
syn match PortfilePhasesTest 	"test\.env\(-\(append\|delete\)\)\?"

" Test destroot options
syn match PortfilePhasesDest 	"destroot\.\(cmd\|type\|dir\|destdir\|umask\|keepdirs\|violate_mtree\)"
syn match PortfilePhasesDest 	"destroot\.\(\(pre\|post\)_\)\?args"
syn match PortfilePhasesDest 	"destroot\.target\(-\(append\|delete\)\)\?"

" Variants
syn region PortfileVariant 				matchgroup=Keyword start="^variant" skip="\\$" end="$" contains=PortfileVariantName,PortfileVariantRequires,PortfileVariantDescription,PortfileVariantConflicts skipwhite
syn keyword PortfileVariantRequires 	requires nextgroup=PortfileVariantName contained
syn keyword PortfileVariantConflicts 	conflicts nextgroup=PortfileVariantName contained
syn keyword PortfileVariantDescription 	description nextgroup=PortfileGroup contained skipwhite
syn match PortfileVariantName 			"[a-zA-Z0-9_]\+" contained
syn keyword PortfileOptional 			universal_variant nextgroup=PortfileYesNo skipwhite
syn match PortfileOptional 				"default_variants\(-\(append\|delete\)\)\?" nextgroup=PortfileDefaultVariants skipwhite
syn match PortfileDefaultVariants 		"\([+|\-][a-zA-Z0-9_]\+\s*\)\+" contained

" Dependencies
syn match PortfileDepends 			"depends_\(\(lib\|build\|run\|fetch\|extract\)\(-\(append\|delete\)\)\?\)" nextgroup=PortfileDependsEntries skipwhite
syn region PortfileDependsEntries 	matchgroup=Normal start="" skip="\\$" end="$" contains=PortfileDependsEntry contained
syn match PortfileDependsEntry 		"\(port\|bin\|path\|lib\):" contained

" StartupItems
syn match PortfileStartupPid 		"\(none\|auto\|clean\|manual\)" contained
syn match PortfileOptional 			"startupitem\.\(start\|stop\|restart\|init\|executable\)"
syn match PortfileOptional 			"startupitem\.\(create\|logevents\|netchange\)" nextgroup=PortfileYesNo skipwhite
syn match PortfileOptional 			"startupitem\.pidfile" nextgroup=PortfileStartupPid skipwhite

" Livecheck / Distcheck
syn match PortfileOptional 			"livecheck\.\(type\|name\|distname\|version\|url\|regex\|md5\)"
syn keyword PortfileOptional 		distcheck.check

" Notes
syn keyword PortfilePhases		notes

" Port Groups
" Gnustep
syn match 	PortfileGroups 			"gnustep\.\(post_flags\|cc\)"
syn keyword PortfileGroups 			variant_with_docs gnustep_layout
syn match 	PortfileGroups 			"set_\(gnustep_\(make\|env\)\|\(system\|local\)_library\)"
" Haskell
syn keyword PortfileGroups 			haskell.setup
" Perl5
syn match 	PortfileGroups 			"perl5\.\(setup\|version\|bin\|lib\|archlib\)"
" Python
syn match 	PortfileGroups 			"python\.\(bin\|lib\|include\|pkgd\)"
" Ruby
syn match 	PortfileGroups 			"ruby\.\(version\|bin\|lib\|arch\|archlib\)"
" Xcode
syn match 	PortfileGroups 			"xcode\.\(project\|configuration\|target\|build\.settings\)"
syn match 	PortfileGroups 			"xcode\.destroot\.\(type\|path\|settings\)"
syn match 	PortfileGroups 			"xcode\.universal\.\(sdk\|settings\)"

" Tcl extensions
syn keyword PortfileTcl		xinstall
" check whitespace, copied from python.vim
if g:portfile_highlight_space_errors == 1
  " trailing whitespace
  syn match   PortfileSpaceError   display excludenl "\S\s\+$"ms=s+1
  " mixed tabs and spaces
  syn match   PortfileSpaceError   display " \+\t"
  syn match   PortfileSpaceError   display "\t\+ "
endif

hi def link PortfileGroup 				String
hi def link PortfileYesNo 				Special
hi def link PortfileStartupPid 			Special

hi def link PortfileRequired 			Keyword
hi def link PortfileOptional 			Keyword
hi def link PortfileDescription 		String
hi def link PortfileChecksumsType 		Special

hi def link PortfilePhases 				Keyword
hi def link PortfilePhasesFetch 		Keyword
hi def link PortfilePhasesExtract 		Keyword
hi def link PortfilePhasesPatch 		Keyword
hi def link PortfilePhasesConf  		Keyword
hi def link PortfilePhasesAA 	  		Keyword
hi def link PortfilePhasesBuild  		Keyword
hi def link PortfilePhasesTest  		Keyword
hi def link PortfilePhasesDest  		Keyword

hi def link PortfileVariantConflicts 	Statement
hi def link PortfileVariantDescription 	Statement
hi def link PortfileVariantRequires 	Statement
hi def link PortfileVariantName 		Identifier
hi def link PortfileDefaultVariants 	Identifier
hi def link PortfileDepends 			Keyword
hi def link PortfileDependsEntry 		Special
hi def link PortfileGroups 				Keyword

hi def link PortfileTcl 				Keyword

if g:portfile_highlight_space_errors == 1
	hi def link PortFileSpaceError	Error
endif

let b:current_syntax = "Portfile"
