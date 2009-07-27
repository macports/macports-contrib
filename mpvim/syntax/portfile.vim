" Vim syntax file
" Language: 	MacPorts Portfiles
" Author: 		Maximilian Nickel <mnick@macports.org>
" Copyright: 	Copyright (c) 2009 Maximilian Nickel
" Licence: 		You may redistribute this under the same terms as Vim itself
"

if &compatible || v:version < 603
	finish
endif

if exists("b:current_syntax")
	finish
endif

let is_tcl=1
let portfile_highlight_space_errors=1
runtime! syntax/tcl.vim

unlet b:current_syntax


syn match PortfileGroup 		"{.\+}" contained
syn match PortfileYesNo 		"\(yes\|no\)" contained

syn keyword PortfileRequired 	PortSystem name version maintainers
syn keyword PortfileRequired 	homepage master_sites categories platforms checksums
syn match PortfileRequired 		"^\(long_\)\?description" nextgroup=PortfileDescription skipwhite
syn region PortfileDescription 	matchgroup=Normal start="[^\s\t]" skip="\\$" end="$" contained

syn keyword PortfileOptional 	PortGroup epoch revision worksrcdir distname platform
syn keyword PortfileOptional 	use_automake use_autoconf use_configure
syn keyword PortifleOptional 	patch_sites distfiles dist_subdir

syn keyword PortfileOptional 	checksums nextgroup=PortfileChecksums skipwhite
syn region PortfileChecksums 	matchgroup=Normal start="[^\s\t]" skip="\\$" end="$" contained contains=PortfileChecksumsType
syn keyword PortfileChecksumsType md5 sha1 rmd160 contained

syn match PortfilePhases 		"\(\(pre\|post\)\-\)*\(fetch\|checksum\|extract\|patch\|configure\|build\|test\|destroot\|archive\|install\|activate\)\s" contains=PortfilePrePost

" Fetch phase options
syn match PortfilePhasesFetch   "fetch\.\(type\|user\|password\|use_epsv\|ignore_sllcert\)"
syn match PortfilePhasesFetch 	"cvs\.\(root\|password\|tag\|date\|module\)"
syn match PortfilePhasesFetch 	"svn\.\(url\|tag\)"
syn match PortfilePhasesFetch 	"git\.\(url\|branch\)"
syn match PortfilePhasesFetch 	"hg\.\(url\|tag\)"

" Extract phase options
syn match PortfilePhasesExtract "extract\.\(suffix\|mkdir\|cmd\|only\(\-\(append\|delete\)\)*\)"
syn match PortfilePhasesExtract "use_\(7z\|bzip2\|lzma\|zip\)" nextgroup=PortfileYesNo skipwhite

" Patch phase options
syn match PortfilePhasesPatch 	"patch\.\(dir\|cmd\|args\(\-\(append\|delete\)\)*\)"
syn match PortfilePhasesPatch 	"patchfiles\(\-\(append\|delete\)\)*"

" Configure phase options
syn keyword PortfilePhasesConf 	use_configure nextgroup=PortfileYesNo skipwhite
syn match PortfilePhasesConf 	"configure\.\(env\|\(c\|ld\|cpp\|cxx\|objc\|f\|fc\|f90\)flags\)\(-\(append\|delete\)\)*"
syn match PortfilePhasesConf 	"configure\.\(\(pre\|post\)\-\)*args\(-\(\append\|delete\)\)"
syn match PortfilePhasesConf 	"configure\.\(cc\|cpp\|cxx\|objc\|fc\|f77\|f90\|javac\|compiler\)"
syn match PortfilePhasesConf 	"configure\.\(perl\|python\|ruby\|install\|awk\|bison\)"
syn match PortfilePhasesConf 	"configure\.\(pkg_config\(_path\)*\)"

" Variants
syn region PortfileVariant 				matchgroup=Keyword start="^variant" skip="\\$" end="$" contains=PortfileVariantName,PortfileVariantRequires,PortfileVariantDescription,PortfileVariantConflicts skipwhite
syn keyword PortfileVariantRequires 	requires nextgroup=PortfileVariantName contained
syn keyword PortfileVariantConflicts 	conflicts nextgroup=PortfileVariantName contained
syn keyword PortfileVariantDescription 	description nextgroup=PortfileGroup contained
syn match PortfileVariantName 			"[a-zA-Z0-9_]\+" contained

syn keyword PortfileOptional			default_variants nextgroup=PortfileDefaultVariants skipwhite
syn match PortfileDefaultVariants 		"\([+|\-][a-zA-Z0-9_]\+\s*\)\+" contained

" Depends
syn match PortfileDepends 				"depends_\(\(lib\|build\|run\)\(-\(append\|delete\)\)*\)" nextgroup=PortfileDependsEntries skipwhite
syn region PortfileDependsEntries 		matchgroup=Normal start="[^\s]" skip="\\$" end="$" contains=PortfileDependsEntry contained
syn match PortfileDependsEntry 			"\(port\|bin\):" contained

" check whitespace, copied from python.vim
if exists("portfile_highlight_space_errors")
  " trailing whitespace
  syn match   PortfileSpaceError   display excludenl "\S\s\+$"ms=s+1
  " mixed tabs and spaces
  syn match   PortfileSpaceError   display " \+\t"
  syn match   PortfileSpaceError   display "\t\+ "
endif

hi def link PortfileGroup 				String
hi def link PortfileYesNo 				Special

hi def link PortfileRequired 			Keyword
hi def link PortfileOptional 			Keyword
hi def link PortfileDescription 		String
hi def link PortfileChecksumsType 		Special

hi def link PortfilePhases 				Keyword
hi def link PortfilePhasesFetch 		Keyword
hi def link PortfilePhasesExtract 		Keyword
hi def link PortfilePhasesPatch 		Keyword
hi def link PortfilePhasesConf  		Keyword

hi def link PortfileVariantConflicts 	Statement
hi def link PortfileVariantDescription 	Statement
hi def link PortfileVariantRequires 	Statement
hi def link PortfileVariantName 		Identifier
hi def link PortfileDefaultVariants 	String
hi def link PortfileDepends 			Keyword
hi def link PortfileDependsEntry 		Special

if exists("portfile_highlight_space_errors")
	hi def link PortFileSpaceError	Error
endif

let b:current_syntax = "Portfile"
