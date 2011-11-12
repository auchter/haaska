" Language:     rc
" Maintainer:   Andy Spencer <andy753421@gmail.com>
" Last Change:  2008 Jul 1
" BUGS:
"   control strucutres
"   more bash error checking
"   globbing?
"   some form of rcLiteral for string/quoted/numbers/etc
"   Check extned/keepend for different regions

if exists("b:current_syntax")
    finish
endif

syn cluster rcConst contains=rcString,rcNumber
syn cluster rcCmd contains=rcRedir,rcVarDef,rcVarRef,@rcConst,rcKeywords,rcComment,rcSubShell,coreUtils

syn keyword coreUtils printenv install less clear egrep fgrep chdir gnufind gnugrep ulimit admin alias ar asa at awk basename batch bc bg break c99 cal cat cd cflow chgrp chmod chown cksum cmp colon comm command compress continue cp crontab csplit ctags cut cxref date dd delta df diff dirname dot du echo ed env eval ex exec exit expand export expr false fc fg file find fold fort77 fuser gencat get getconf getopts grep hash head iconv id ipcrm ipcs jobs join kill lex link ln locale localedef logger logname lp ls m4 mailx make man mesg mkdir mkfifo more mv newgrp nice nl nm nohup od paste patch pathchk pax pr printf prs ps pwd qalter qdel qhold qmove qmsg qrerun qrls qselect qsig qstat qsub read readonly renice return rm rmdel rmdir sact sccs sed set sh shift sleep sort split strings strip stty tabs tail talk tee test time times touch tput tr trap true tsort tty type umask unalias uname uncompress unexpand unget uniq unlink unset uucp uudecode uuencode uustat uux val vi wait wc what who write xargs yacc zcat while case if switch fn

syn match rcVarDef  "^\s*\zs[^#"\t\r\n ]\w*\ze\s*="
syn match rcVarRef  "\v\$([#"]\S\w*|\S\w*(\([^)]*\))?)" contains=rcVarLst,rcVarOper
syn match rcVarOper +[#"]+ contained
syn match rcVarLst  "\(([^)]*)\)" contained contains=rcNumber

syn region rcString start=+"+ skip=+\\"+ end=+"+ contains=rcVarRef extend
syn region rcString start=+'+ skip=+\\'+ end=+'+ extend
syn match  rcNumber "\<\d\+\>"

"syn region rcList start="(" end=")" contains=rcString,rcList,rcVarRef

syn match rcComment "#.*"

syn match rcKeywords "\(||\|&&\|>>\|[;^\\]\)"
syn match rcRedir    "[<>|]\v(\[\d+\=?\d*])?" contains=rcNumber

syn match  rcSSEnds   "\(`{\|\}\)" contained 
syn region rcSubShell start="`{" end="}" contains=@rcCmd,rcSSEnds keepend 

" Ignore bash
" Bad $(), ${}, 2>&1, `foo`, 
" TODO: {foo,bar}.txt (use: (foo bar)^.txt
"       {foo; bar} is ok
syn match shError "\($(.\{-})\|${.\{-}}\|\d\+>\(&\d\+\)\?\|`[^{]\{-}`\)"

hi def link coreUtils  Keyword
hi def link rcVarDef   Identifier
hi def link rcVarRef   Identifier
hi def link rcVarOper  Operator
hi def link rcVarLst   Identifier
hi def link rcKeywords Keyword
hi def link rcRedir    Statement
hi def link rcString   String
hi def link rcNumber   Number
hi def link rcList     Type
hi def link rcComment  Comment
hi def link rcSSends   PreProc
hi def link shError    Error

let b:current_syntax = "rc"
