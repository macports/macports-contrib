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

syn match PortfileGroup         "{.\+}" contained
syn match PortfileYesNo         "\%(yes\|no\)" contained

syn keyword PortfileRequired    PortSystem name version maintainers
syn keyword PortfileRequired    homepage master_sites platforms
syn match PortfileRequired      "categories\%(-append\|-delete\)\?"
syn match PortfileRequired      "\%(long_\)\?description" nextgroup=PortfileDescription skipwhite
syn region PortfileDescription  matchgroup=Normal start="" skip="\\$" end="$" contained

syn keyword PortfileOptional    PortGroup epoch revision worksrcdir distname
syn keyword PortfileOptional    patch_sites dist_subdir license conflicts
syn match PortfileOptional      "distfiles\%(-append\|-delete\)\?"
syn keyword PortfileOptional    replaced_by supported_archs

syn match  PortfileOptional     "checksums\%(-append\|-delete\)\?" nextgroup=PortfileChecksums skipwhite
syn region PortfileChecksums    matchgroup=Normal start="" skip="\\$" end="$" contained contains=PortfileChecksumsType
syn keyword PortfileChecksumsType md5 sha1 rmd160 sha256 contained

syn match PortfilePhases        "\%(pre-\|post-\)\?\%(fetch\|checksum\|extract\|patch\|configure\|build\|test\|destroot\|archive\|install\|activate\)\s" contains=PortfilePrePost

" Fetch phase options
syn match PortfilePhasesFetch   "fetch\.\%(type\|user\|password\|use_epsv\|ignore_sslcert\)"
syn match PortfilePhasesFetch   "cvs\.\%(root\|password\|tag\|date\|module\)"
syn match PortfilePhasesFetch   "svn\.\%(url\|revision\)"
syn match PortfilePhasesFetch   "git\.\%(url\|branch\)"
syn match PortfilePhasesFetch   "hg\.\%(url\|tag\)"

" Extract phase options
syn match PortfilePhasesExtract "extract\.\%(suffix\|mkdir\|cmd\|only\%(-append\|-delete\)\?\)"
syn match PortfilePhasesExtract "use_\%(7z\|bzip2\|lzma\|zip\|xz\)" nextgroup=PortfileYesNo skipwhite

" Patch phase options
syn match PortfilePhasesPatch   "patch\.\%(dir\|cmd\|args\%(-append\|-delete\)\?\)"
syn match PortfilePhasesPatch   "patchfiles\%(-append\|-delete\)\?"

" Configure phase options
syn keyword PortfilePhasesConf  use_configure nextgroup=PortfileYesNo skipwhite
syn match PortfilePhasesConf    "configure\.\%(env\|\%(c\|ld\|cpp\|cxx\|objc\|f\|fc\|f90\)flags\)\%(-append\|-delete\)\?"
syn match PortfilePhasesConf    "configure\.\%(pre_\|post_\)\?args\%(-append\|-delete\)\?" nextgroup=PortfileConfEntries skipwhite
syn region PortfileConfEntries  matchgroup=Normal start="" skip="\\$" end="$" contained
syn match PortfilePhasesConf    "configure\.\%(cc\|cpp\|cxx\|objc\|fc\|f77\|f90\|javac\|compiler\)"
syn match PortfilePhasesConf    "configure\.\%(perl\|python\|ruby\|install\|awk\|bison\)"
syn match PortfilePhasesConf    "configure\.\%(pkg_config\%(_path\)\?\)"
syn match PortfilePhasesConf    "configure.universal_\%(args\|\%(c\|cpp\|cxx\|ld\)flags\)"
syn match PortfilePhasesConf    "compiler\.\%(blacklist\|whitelist\|fallback\)"

" Automake and Autoconf
syn match PortfilePhasesAA      "use_auto\%(make\|\%(re\)\?conf\)" nextgroup=PortfileYesNo skipwhite
syn match PortfilePhasesAA      "auto\%(make\|\%(re\)\?conf\).\%(env\|args\|dir\)"

" Build phase options
syn match PortfilePhasesBuild   "build\.\%(cmd\|type\|dir\)"
syn match PortfilePhasesBuild   "build\.\%(pre_\|post_\)\?args"
syn match PortfilePhasesBuild   "build\.\%(target\|env\)\%(-append\|-delete\)\?"
syn keyword PortfilePhasesBuild use_parallel_build nextgroup=PortfileYesNo skipwhite

" Test phase options
syn match PortfilePhasesTest    "test\.\%(run\|cmd\|target\)"
syn match PortfilePhasesTest    "test\.env\%(-append\|-delete\)\?"

" Test destroot options
syn match PortfilePhasesDest    "destroot\.\%(cmd\|type\|dir\|destdir\|umask\|keepdirs\|violate_mtree\)"
syn match PortfilePhasesDest    "destroot\.\%(pre_\|post_\)\?args"
syn match PortfilePhasesDest    "destroot\.target\%(-append\|-delete\)\?"

" Variants
syn region PortfileVariant              matchgroup=Keyword start="^\s*\zsvariant" skip="\\$" end="$" contains=PortfileVariantName,PortfileVariantRequires,PortfileVariantDescription,PortfileVariantConflicts skipwhite
syn keyword PortfileVariantRequires     requires nextgroup=PortfileVariantName contained
syn keyword PortfileVariantConflicts    conflicts nextgroup=PortfileVariantName contained
syn keyword PortfileVariantDescription  description nextgroup=PortfileGroup contained skipwhite
syn match PortfileVariantName           "[a-zA-Z0-9_]\+" contained
syn keyword PortfileOptional            universal_variant nextgroup=PortfileYesNo skipwhite
syn match PortfileOptional              "default_variants\%(-append\|-delete\)\?" nextgroup=PortfileDefaultVariants skipwhite
syn match PortfileDefaultVariants       "\%([+\-][a-zA-Z0-9_]\+\s*\)\+" contained

" Platform
syn match PortfilePlatform          "platform" nextgroup=PortfilePlatformName skipwhite
syn match PortfilePlatformName      "[a-z][a-zA-Z0-9_]\+" nextgroup=PortfilePlatformVersion contained skipwhite
syn match PortfilePlatformVersion   "[0-9]\+" nextgroup=PortfilePlatformArch contained skipwhite
syn match PortfilePlatformArch      "[a-z][a-zA-Z0-9_]\+" contained

" Dependencies
syn match PortfileDepends           "depends_\%(\%(lib\|build\|run\|fetch\|extract\)\%(-append\|-delete\)\?\)" nextgroup=PortfileDependsEntries skipwhite
syn region PortfileDependsEntries   matchgroup=Normal start="" skip="\\$" end="$" contains=PortfileDependsEntry contained
syn match PortfileDependsEntry      "\%(port\|bin\|path\|lib\):" contained

" StartupItems
syn match PortfileStartupPid    "\%(none\|auto\|clean\|manual\)" contained
syn match PortfileOptional      "startupitem\.\%(start\|stop\|restart\|init\|executable\|logfile\)"
syn match PortfileOptional      "startupitem\.\%(create\|logevents\|netchange\)" nextgroup=PortfileYesNo skipwhite
syn match PortfileOptional      "startupitem\.pidfile" nextgroup=PortfileStartupPid skipwhite

" Livecheck / Distcheck
syn match PortfileOptional      "livecheck\.\%(type\|name\|distname\|version\|url\|regex\|md5\)"
syn keyword PortfileOptional    distcheck.check

" Notes
syn keyword PortfilePhases  notes

" Port Groups

" App
syn match PortfileGroups    "app\.\%(create\|name\|executable\|icon\|short_version_string\|version\|identifier\)"

" Archcheck
syn match PortfileGroups    "archcheck\.files"

" CMake
" has no keywords

" crossbinutils
syn match PortfileGroups    "crossbinutils\.\%(target\|setup\)"

" crossgcc
syn match PortfileGroups    "crossgcc\.\%(target\|setup\|setup_libc\)"

" github
syn match PortfileGroups    "github\.\%(author\|project\|version\|tag_prefix\|homepage\|raw\|master_sites\|tarball_from\|setup\)"

" Gnustep
syn match PortfileGroups    "gnustep\.\%(post_flags\|cc\)"
syn keyword PortfileGroups  variant_with_docs gnustep_layout
syn match PortfileGroups    "set_\%(gnustep_\%(make\|env\)\|\%(system\|local\)_library\)"

" Haskell
syn keyword PortfileGroups  haskell.setup

" hocbinding
syn match PortfileGroups    "hocbinding\.\%(framework\|deps\|setup\)"

" hunspelldict
syn match PortfileGroups    "hunspelldict\.\%(locale\|setup\)"

" KDE 4, versions 1.0 and 1.1
" have no keywords

" muniversal
syn match PortfileGroups    "merger_configure_\%(env\|args\|compiler\|cppflags\|cflags\|cxxflags\|objcflags\|ldflags\)"
syn match PortfileGroups    "merger_build_\%(env\|args\)"
syn match PortfileGroups    "merger_\%(host\|arch_\%(flag\|compiler\)\|destroot_env\|dont_diff\|must_run_binaries\|no_3_archs\)"
syn match PortfileGroups    "universal_archs_supported"

" obsolete
" has no keywords (other than replaced_by, and that should be elsewhere in
" this file)

" ocml
" has no keywords

" octave
syn match PortfileGroups    "octave\.\%(module\|setup\)"

" PEAR
syn match PortfileGroups    "pear\.\%(env\|configure\.pre_args\|destroot\|installer\|sourceroot\|instpath\|pearpath\|cmd-pear\|cmd-phar\|cmd-php\|channel\|packagexml\|package\|packagefile\|setup\)"

" Perl5
syn match PortfileGroups    "perl5\.\%(setup\|branches\|default_branch\|version\|major\|arch\|bin\|lib\|bindir\|archlib\)"

" PHP 1.0
syn match PortfileGroups    "php\.\%(branch\%(es\)\?\|build_dirs\|default_branch\|extension_ini\|extensions\|rootname\|type\|setup\)"
syn match PortfileGroups    "php\.\%(config\|extension_dir\|ini\%(_dir\)\?\|ize\|suffix\)"
" PHP 1.1 (only adding those not already present in 1.0)
syn match PortfileGroups    "php\.\%(rootname\|create_subports\|extensions\.zend\|build_dirs\|add_port_code\)"
syn match PortfileGroups    "php\.\%(pecl\%(_livecheck_stable\)\?\|pecl\.\%(name\|prerelease\)\)"

" PHP5 extension
syn match PortfileGroups    "php5extension\.\%(setup\|build_dirs\|extensions\|extension_dir\|ini\|inidir\|php_ini\|phpize\|type\|source\)"

" PHP5 PEAR
syn match PortfileGroups    "php5pear\.\%(env\|configure\.pre_args\|destroot\|installer\|sourceroot\|instpath\|pearpath\|cmd-\%(pear\|phar\|php\)\|channel\|packagexml\|package\|packagefile\|setup\)"

" Pure
syn match PortfileGroups    "pure\.setup"

" Python
syn match PortfileGroups    "python\.\%(versions\?\|default_version\|branch\|prefix\|bin\|lib\|libdir\|include\|pkgd\|add_archflags\|set_compiler\|link_binaries\%(_suffix\)\?\)"
" I'm not documenting the Python{24,25,26,27,31,32} groups. Don't use them.

" Qt4
syn match PortfileGroups    "qt_\%(name\|dir\|qmake_spec\|cmake_defines\|arch_types\)"
syn match PortfileGroups    "qt_\%(qmake\|moc\|uic\|lrelease\)_cmd"
syn match PortfileGroups    "qt_\%(docs\|plugins\|mkspecs\|imports\|includes\|libs\|frameworks\|bins\|apps\|data\|translations\|sysconf\|examples\|demos\|cmake_module\)_dir"

" Ruby
syn match PortfileGroups    "ruby\.\%(version\|bin\|rdoc\|gem\|lib\|arch\|archlib\|setup\)"

" Select
syn match PortfileGroups    "select\.\%(group\|file\)"

" TeX Live
syn match PortfileGroups    "texlive\.\%(exclude\|binaries\|formats\|languages\|maps\|forceupdatecnf\|use_mktexlsr\%(_on_deactivate\)\?\|texmfport\)"

" X11 Font
syn match PortfileGroups    "x11font\.setup"

" Xcode
syn match PortfileGroups    "xcode\.\%(project\|configuration\|target\|build\.settings\)"
syn match PortfileGroups    "xcode\.destroot\.\%(type\|path\|settings\)"
syn match PortfileGroups    "xcode\.universal\.\%(sdk\|settings\)"

" Xcode version
syn match PortfileGroups    "minimum_xcodeversions"

" Zope
syn match PortfileGroups    "zope\.\%(need_subdir\|setup\)"

" End of PortGroups


" Tcl extensions
syn keyword PortfileTcl     xinstall fs-traverse readdir md5 vercmp
syn keyword PortfileTcl     reinplace strsed
syn keyword PortfileTcl     copy move delete touch ln system
syn match PortfileTcl       "curl\s\+\%(fetch\|isnewer\)"
syn match PortfileTcl       "\%(add\|exists\)\%(user\|group\)"
syn keyword PortfileTcl     nextuid nextgid
syn keyword PortfileTcl     variant_isset variant_set
syn match PortfileTcl       "mk[sd]\?temp"
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

hi def link PortfileGroup               String
hi def link PortfileYesNo               Special
hi def link PortfileStartupPid          Special

hi def link PortfileRequired            Keyword
hi def link PortfileOptional            Keyword
hi def link PortfileDescription         String
hi def link PortfileChecksumsType       Special

hi def link PortfilePhases              Keyword
hi def link PortfilePhasesFetch         Keyword
hi def link PortfilePhasesExtract       Keyword
hi def link PortfilePhasesPatch         Keyword
hi def link PortfilePhasesConf          Keyword
hi def link PortfilePhasesAA            Keyword
hi def link PortfilePhasesBuild         Keyword
hi def link PortfilePhasesTest          Keyword
hi def link PortfilePhasesDest          Keyword

hi def link PortfileVariantConflicts    Statement
hi def link PortfileVariantDescription  Statement
hi def link PortfileVariantRequires     Statement
hi def link PortfileVariantName         Identifier
hi def link PortfileDefaultVariants     Identifier

hi def link PortfilePlatform            Keyword
hi def link PortfilePlatformName        Identifier
hi def link PortfilePlatformVersion     tclNumber
hi def link PortfilePlatformArch        Identifier

hi def link PortfileDepends             Keyword
hi def link PortfileDependsEntry        Special
hi def link PortfileGroups              Keyword

hi def link PortfileTcl                 Keyword

if g:portfile_highlight_space_errors == 1
    hi def link PortFileSpaceError      Error
endif

let b:current_syntax = "Portfile"
