" Language:     mk
" Maintainer:   Andy Spencer <andy753421@gmail.com>
" Last Change:  2008 Jul 1
" BUGS:
"   rcVarPredef does not work from within regions (rcSubShell,rcString,etc)
"   regular expression globs in mkVarRef
"   Quoting/escaping? doesn't work correctly
"   foo=$target
" TODO:
"   attributes: for variables: var=attr=value doesn't work
"   aggregates: a(b)
"   P attr: 1.txt:VPcmp: 2.txt
"   indentation

if exists("b:current_syntax")
  finish
endif

" Merge globals for rc and mk
syn match mkGlobals ".*" contains=rcComment,rcString,rcSubshell,rcNumber,mkInclude,mkRule,mkVarRef,mkVarDef,mkRecipe

" Rc stuff before global stuff so we can override it
syn include @rcSyntax syntax/rc.vim
unlet b:current_syntax

" Includes
syn match mkInclude "^<|\?\S*" contained

" Rules
syn match mkRuleAttrs   "[DENnPQRUV]"          contained
syn match mkRuleGlob    "[%&]\|([^)]*)\|\\\d"     contained
syn match mkRuleTargets "^[^:]*:"me=e-1        contained contains=rcComment,mkRuleGlob,mkVarRef
syn match mkRuleAttrLst ":[^:]*:"me=e-1,ms=s+1 contained contains=rcComment,mkRuleGlob,mkVarRef,mkAttrs
syn match mkRulePrereqs ":[^:]*$"ms=s+1        contained contains=rcComment,mkRuleGlob,mkVarRef,rcSubShell
syn match mkRule "^[^:=]*:\([^:]*:\)\?.*$"     contained contains=mkRuleTargets,mkRuleAttrs,mkRulePrereqs

" Recipe
syn region mkRecipe start="^\t" end="$" oneline contained contains=mkVarPredef,@rcCmd 

" Variables, most stuff comes from rc
syn match mkVarAttrs   "[U]"                        contained
syn match mkVarGlob    "[%&]"                       contained
syn match mkVarDef     "^\s*[^#"\t\r\n ]\w*\ze\s*=" contained contains=mkVarSpecial
syn match mkVarRef     "\$\S\w*"                    contained contains=mkVarSpecial
syn match mkVarRef     "\${\S\w*:.*%.*=.*%.*}"      contained contains=mkVarGlob
syn match mkVarPredef  "\v\$(alltarget|newprereq|newmember|nproc|pid|prereq|stem\d?|target)" contained
syn match mkVarSpecial "\v\$?(NPROC|MKARGS|MKFLAGS|MKSHELL)" contained

" Define the default highlighting.
hi def link mkVarPredef   Keyword
hi def link mkVarSpecial  Keyword
hi def link mkVarDef      Identifier
hi def link mkVarRef      Identifier

hi def link mkInclude     Preproc
hi def link mkVarGlob     Preproc
hi def link mkRuleGlob    Preproc
hi def link mkRuleAttrs   Type
hi def link mkRuleTargets Function

"hi def link mkRulePrereqs String
"hi def link mkRecipe      String

let b:current_syntax = "mk"
