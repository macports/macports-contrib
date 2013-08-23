" vim:fenc=utf-8:et:sw=4:ts=4:sts=4

" Vim syntax file
" Language: MacPorts Portfiles
" Maintainer: Maximilian Nickel <mnick@macports.org>
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

" Some custom extensions contain a dash (for example, fs-traverse)
setlocal iskeyword+=-

let s:portfile_commands = []
let s:portfile_options = []

syn match PortfileGroup         "{.\+}" contained
syn match PortfileYesNo         "\<\%(yes\|no\)\>" contained

syn keyword PortfileRequired    PortSystem
syn keyword PortfileOptional    PortGroup

" Main options (from port1.0/portmain.tcl)
call extend(s:portfile_options,
            \ 'add_users', 'altprefix', 'categories', 'conflicts',
            \ 'copy_log_files', 'default_variants', 'depends_skip_archcheck',
            \ 'description', 'distname', 'distpath', 'epoch', 'filesdir',
            \ 'homepage', 'installs_libs', 'libpath', 'license',
            \ 'license_noconflict', 'long_description',
            \ 'macosx_deployment_target', 'maintainers', 'name', 'notes',
            \ 'platforms', 'portdbpath', 'prefix', 'provides', 'replaced_by',
            \ 'revision', 'sources_conf', 'supported_archs',
            \ 'universal_variant', 'version', 'worksrcdir',
            \ 'compiler\.\%(cpath\|library_path\)',
            \ 'install\.\%(group\|user\)',
            \ 'os\.\%(arch\|endian\|major\|platform\|subplatform\)', 
            \ 'os\.\%(universal_supported\|version\)',
            \])

syn match PortfilePhases        "\<\%(pre-\|post-\)\?\%(fetch\|checksum\|extract\|patch\|configure\|build\|test\|destroot\|archive\|install\|activate\|deactivate\)\>" contains=PortfilePrePost

" Fetch phase options (from port1.0/portfetch.tcl)
call extend(s:portfile_commands, ['bzr', 'cvs', 'svn'])
call extend(s:portfile_options, [
            \ 'bzr\.\%(revision\|url\)',
            \ 'cvs\.\%(date\|method\|module\|password\|root\|tag\)',
            \ 'dist_subdir', 'distfiles',
            \ 'extract\.suffix',
            \ 'fetch\.\%(ignore_sslcert\|password\|use_epsv\|user\)',
            \ 'git\.\%(branch\|cmd\|url\)',
            \ 'hg\.\%(cmd\|tag\|url\)',
            \ '\%(master\|patch\)_sites\%(\.mirror_subdir\)\?',
            \ 'patchfiles',
            \ 'svn\.\%(method\|revision\|url\)',
            \ 'use_\%(7z\|bzip2\|dmg\|lzma\|xz\|zip\)',
            \ ])

" Checksum phase options (from port1.0/portchecksum.tcl)
call extend(s:portfile_options, ['checksums\%(\.skip\)\?'])

" Extract phase options (from port1.0/portextract.tcl)
call extend(s:portfile_commands, ['extract'])
call extend(s:portfile_options, ['extract\.\%(asroot\|mkdir\|only\)'])

" Patch phase options (from port1.0/portpatch.tcl)
call extend(s:portfile_commands, ['patch'])
call extend(s:portfile_options, ['patch\.asroot'])

" Configure phase options (from port1.0/portconfigure.tcl)
call extend(s:portfile_commands, ['configure', 'auto\%(conf\|reconf\|make\)', 'xmkmf'])
call extend(s:portfile_options, [
            \ 'configure\.asroot',
            \ 'configure\.\%(m32\|m64\|march\|mtune\)',
            \ 'configure\.\%(c\|cpp\|cxx\|f\|f90\|fc\|ld\|objc\|objcxx\)flags',
            \ 'configure\.\%(classpath\|libs\)',
            \ 'configure\.\%(awk\|bison\|install\|pkg_config\%(_path\)\?\)',
            \ 'configure\.\%(perl\|python\|ruby\)',
            \ 'configure\.\%(build_arch\|sdkroot\)',
            \ 'configure\.\%(cc\|cxx\|f77\|f90\|fc\|ld\|objc\|objcxx\)_archflags',
            \ 'configure\.universal_\%(archs\|args\)',
            \ 'configure\.universal_\%(c\|cpp\|cxx\|ld\|objc\|objcxx\)flags',
            \ 'configure\.\%(ccache\|distcc\|pipe\)',
            \ 'configure\.\%(cc\|cpp\|cxx\|f77\|f90\|fc\|javac\|objc\|objcxx\)',
            \ 'configure\.compiler\%(\.add_deps\)\?',
            \ 'compiler\.\%(blacklist\|fallback\|whitelist\)',
            \ ])

" Build phase options (from port1.0/portbuild.tcl)
call extend(s:portfile_commands, ['build'])
call extend(s:portfile_options, [
            \ 'build\.\%(asroot\|jobs\|target\)',
            \ 'use_parallel_build',
            \])

" Test phase options (from port1.0/porttest.tcl)
call extend(s:portfile_commands, ['test'])
call extend(s:portfile_options, ['test\.\%(run\|target\)'])

" Destroot phase options (from port1.0/portdestroot.tcl)
call extend(s:portfile_commands, ['destroot'])
call extend(s:portfile_options, [
            \ 'destroot\.\%(asroot\|clean\|delete_la_files\|destdir\)',
            \ 'destroot\.\%(keepdirs\|target\|umask\|violate_mtree\)',
            \])

" StartupItem options (from port1.0/portdestroot.tcl)
call extend(s:portfile_options, [
            \ 'startupitem\.\%(autostart\|create\|executable\|init\)',
            \ 'startupitem\.\%(install\|location\|logevents\|logfile\)',
            \ 'startupitem\.\%(name\|netchange\|pidfile\|plist\|requires\)',
            \ 'startupitem\.\%(restart\|start\|stop\|type\|uniquename\)',
            \])

" Variants
syn region PortfileVariant              matchgroup=Keyword start="^\s*\zsvariant" skip="\\$" end="$" contains=PortfileVariantName,PortfileVariantRequires,PortfileVariantDescription,PortfileVariantConflicts skipwhite
syn keyword PortfileVariantRequires     requires nextgroup=PortfileVariantName contained
syn keyword PortfileVariantConflicts    conflicts nextgroup=PortfileVariantName contained
syn keyword PortfileVariantDescription  description nextgroup=PortfileGroup contained skipwhite
syn match PortfileVariantName           "\<\w\+\>" contained
syn keyword PortfileOptional            universal_variant nextgroup=PortfileYesNo skipwhite
syn match PortfileOptional              "\<default_variants\%(-append\|-delete\)\?\>" nextgroup=PortfileDefaultVariants skipwhite
syn match PortfileDefaultVariants       "\<[+-]\w\+\%(\s\+[+-]\w\+\)*\>" contained

" Platform
syn match PortfilePlatform          "\<platform\>" nextgroup=PortfilePlatformName skipwhite
syn match PortfilePlatformName      "\<\l\w\+\>" nextgroup=PortfilePlatformVersion contained skipwhite
syn match PortfilePlatformVersion   "\<\d\+\>" nextgroup=PortfilePlatformArch contained skipwhite
syn match PortfilePlatformArch      "\<\l\w\+\>" contained

" Subports
syn region PortfileSubport       matchgroup=Keyword start="^\s*\zssubport\>" skip="\\$" end="$" contains=PortfileSubportName
syn match PortfileSubportName   "\<[\w\.-]\+\>" contained

" Dependencies
syn match PortfileDepends           "\<depends_\%(\%(lib\|build\|run\|fetch\|extract\)\%(-append\|-delete\)\?\)\>" nextgroup=PortfileDependsEntries skipwhite
syn region PortfileDependsEntries   matchgroup=Normal start="" skip="\\$" end="$" contains=PortfileDependsEntry contained
syn match PortfileDependsEntry      "\<\%(port\|bin\|path\|lib\):" contained

" Livecheck / Distcheck
call extend(s:portfile_options, [
            \ 'distcheck\.check',
            \ 'livecheck\.\%(distname\|ignore_sslcert\|md5\|name\)',
            \ 'livecheck\.\$(regex\|type\|url\|version\)',
            \])

" Port Groups

" App
syn match PortfileGroups    "\<app\.\%(create\|name\|executable\|icon\|short_version_string\|version\|identifier\)\>"

" Archcheck
syn match PortfileGroups    "\<archcheck\.files\>"

" CMake
" has no keywords

" crossbinutils
syn match PortfileGroups    "\<crossbinutils\.\%(target\|setup\)\>"

" crossgcc
syn match PortfileGroups    "\<crossgcc\.\%(target\|setup\|setup_libc\)\>"

" github
syn match PortfileGroups    "\<github\.\%(author\|project\|version\|tag_prefix\|homepage\|raw\|master_sites\|tarball_from\|setup\)\>"

" Gnustep
syn match PortfileGroups    "\<gnustep\.\%(post_flags\|cc\)\>"
syn keyword PortfileGroups  variant_with_docs gnustep_layout
syn match PortfileGroups    "\<set_\%(gnustep_\%(make\|env\)\|\%(system\|local\)_library\)\>"

" Haskell
syn keyword PortfileGroups  haskell.setup

" hocbinding
syn match PortfileGroups    "\<hocbinding\.\%(framework\|deps\|setup\)\>"

" hunspelldict
syn match PortfileGroups    "\<hunspelldict\.\%(locale\|setup\)\>"

" KDE 4, versions 1.0 and 1.1
" have no keywords

" muniversal
syn match PortfileGroups    "\<merger_configure_\%(env\|args\|compiler\|cppflags\|cflags\|cxxflags\|objcflags\|ldflags\)\>"
syn match PortfileGroups    "\<merger_build_\%(env\|args\)\>"
syn match PortfileGroups    "\<merger_\%(host\|arch_\%(flag\|compiler\)\|destroot_env\|dont_diff\|must_run_binaries\|no_3_archs\)\>"
syn match PortfileGroups    "\<universal_archs_supported\>"

" obsolete
" has no keywords (other than replaced_by, and that should be elsewhere in
" this file)

" ocml
" has no keywords

" octave
syn match PortfileGroups    "\<octave\.\%(module\|setup\)\>"

" PEAR
syn match PortfileGroups    "\<pear\.\%(env\|configure\.pre_args\|destroot\|installer\|sourceroot\|instpath\|pearpath\|cmd-pear\|cmd-phar\|cmd-php\|channel\|packagexml\|package\|packagefile\|setup\)\>"

" Perl5
syn match PortfileGroups    "\<perl5\.\%(setup\|branches\|default_branch\|version\|major\|arch\|bin\|lib\|bindir\|archlib\)\>"

" PHP 1.0
syn match PortfileGroups    "\<php\.\%(branch\%(es\)\?\|build_dirs\|default_branch\|extension_ini\|extensions\|rootname\|type\|setup\)\>"
syn match PortfileGroups    "\<php\.\%(config\|extension_dir\|ini\%(_dir\)\?\|ize\|suffix\)\>"
" PHP 1.1 (only adding those not already present in 1.0)
syn match PortfileGroups    "\<php\.\%(rootname\|create_subports\|extensions\.zend\|build_dirs\|add_port_code\)\>"
syn match PortfileGroups    "\<php\.\%(pecl\%(_livecheck_stable\)\?\|pecl\.\%(name\|prerelease\)\)\>"

" PHP5 extension
syn match PortfileGroups    "\<php5extension\.\%(setup\|build_dirs\|extensions\|extension_dir\|ini\|inidir\|php_ini\|phpize\|type\|source\)\>"

" PHP5 PEAR
syn match PortfileGroups    "\<php5pear\.\%(env\|configure\.pre_args\|destroot\|installer\|sourceroot\|instpath\|pearpath\|cmd-\%(pear\|phar\|php\)\|channel\|packagexml\|package\|packagefile\|setup\)\>"

" Pure
syn match PortfileGroups    "\<pure\.setup\>"

" Python
syn match PortfileGroups    "\<python\.\%(versions\?\|default_version\|branch\|prefix\|bin\|lib\|libdir\|include\|pkgd\|add_archflags\|set_compiler\|link_binaries\%(_suffix\)\?\)\>"
" I'm not documenting the Python{24,25,26,27,31,32} groups. Don't use them.

" Qt4
syn match PortfileGroups    "\<qt_\%(name\|dir\|qmake_spec\|cmake_defines\|arch_types\)\>"
syn match PortfileGroups    "\<qt_\%(qmake\|moc\|uic\|lrelease\)_cmd\>"
syn match PortfileGroups    "\<qt_\%(docs\|plugins\|mkspecs\|imports\|includes\|libs\|frameworks\|bins\|apps\|data\|translations\|sysconf\|examples\|demos\|cmake_module\)_dir\>"

" Ruby
syn match PortfileGroups    "\<ruby\.\%(version\|bin\|rdoc\|gem\|lib\|arch\|archlib\|setup\)\>"

" Select
syn match PortfileGroups    "\<select\.\%(group\|file\)\>"

" TeX Live
syn match PortfileGroups    "\<texlive\.\%(exclude\|binaries\|formats\|languages\|maps\|forceupdatecnf\|use_mktexlsr\%(_on_deactivate\)\?\|texmfport\)\>"

" X11 Font
syn match PortfileGroups    "\<x11font\.setup\>"

" Xcode
syn match PortfileGroups    "\<xcode\.\%(project\|configuration\|target\|build\.settings\)\>"
syn match PortfileGroups    "\<xcode\.destroot\.\%(type\|path\|settings\)\>"
syn match PortfileGroups    "\<xcode\.universal\.\%(sdk\|settings\)\>"

" Xcode version
syn match PortfileGroups    "\<minimum_xcodeversions\>"

" Zope
syn match PortfileGroups    "\<zope\.\%(need_subdir\|setup\)\>"

" End of PortGroups


" Tcl extensions
syn keyword PortfileTcl     xinstall fs-traverse readdir md5 vercmp
syn keyword PortfileTcl     reinplace strsed
syn keyword PortfileTcl     copy move delete touch ln system
syn match PortfileTcl       "\<curl\s\+\%(fetch\|isnewer\)\>"
syn match PortfileTcl       "\<\%(add\|exists\)\%(user\|group\)\>"
syn keyword PortfileTcl     nextuid nextgid
syn keyword PortfileTcl     variant_isset variant_set
syn match PortfileTcl       "\<mk[sd]\?temp\>"
syn keyword PortfileTcl     lpush lpop lunshift lshift ldindex
syn keyword PortfileTcl     ui_debug ui_error ui_info ui_msg ui_warn

" check whitespace, copied from python.vim
if g:portfile_highlight_space_errors == 1
    " trailing whitespace
    syn match PortfileSpaceError    display excludenl "\S\s\+$"ms=s+1
    " mixed tabs and spaces
    syn match PortfileSpaceError    display " \+\t"
    syn match PortfileSpaceError    display "\t\+ "
endif

let suffixes = ['args', 'cmd', 'dir', 'env', 'nice', 'post_args', 'pre_args', 'type']
for cmd in s:portfile_commands
    call add(s:portfile_options, 'use_' . cmd)
    call extend(s:portfile_options, map(copy(suffixes), 'cmd . "." . v:val'))
endfor
unlet cmd suffixes

execute 'syntax match PortfileOption'
            \ '"^\s*\zs\%(' .
            \ join(s:portfile_options, '\|') .
            \ '\)\%(-append\|-delete\|-replace\|-strsed\)\?\ze\%(\s\+\|$\)"'

highlight default link PortfileOption   Keyword

hi def link PortfileGroup               String
hi def link PortfileYesNo               Special

hi def link PortfileRequired            Keyword
hi def link PortfileOptional            Keyword
hi def link PortfileDescription         String

hi def link PortfilePhases              Keyword
hi def link PortfilePhasesAA            Keyword

hi def link PortfileVariantConflicts    Statement
hi def link PortfileVariantDescription  Statement
hi def link PortfileVariantRequires     Statement
hi def link PortfileVariantName         Identifier
hi def link PortfileDefaultVariants     Identifier

hi def link PortfilePlatform            Keyword
hi def link PortfilePlatformName        Identifier
hi def link PortfilePlatformVersion     tclNumber
hi def link PortfilePlatformArch        Identifier

hi def link PortfileSubportName         Identifier

hi def link PortfileDepends             Keyword
hi def link PortfileDependsEntry        Special
hi def link PortfileGroups              Keyword

hi def link PortfileTcl                 Keyword

if g:portfile_highlight_space_errors == 1
    hi def link PortFileSpaceError      Error
endif

let b:current_syntax = "Portfile"
