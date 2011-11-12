"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Test todo entry filtering
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
source setup_tests.inc
call vimtap#Plan(8)

" Get Today's date for matching with the auto-generated dates
let lastmonth=strftime("%Y-%m-%d", localtime() - 86400 * 30)
let lastweek=strftime("%Y-%m-%d", localtime() - 86400 * 7)
let yesterday=strftime("%Y-%m-%d", localtime() - 86400)
let today=strftime("%Y-%m-%d")
let tomorrow=strftime("%Y-%m-%d", localtime() + 86400)
let day2=strftime("%Y-%m-%d", localtime() + 86400 * 2)
let day3=strftime("%Y-%m-%d", localtime() + 86400 * 3)
let day4=strftime("%Y-%m-%d", localtime() + 86400 * 4)
let day7=strftime("%Y-%m-%d", localtime() + 86400 * 7)
let day8=strftime("%Y-%m-%d", localtime() + 86400 * 8)

if exists("g:todo_files")
    unlet g:todo_files " We want to test current file only
endif

call append('$', 'TODO '.today.' Last Month {'.lastmonth.'}')
call append('$', 'TODO '.today.' Last Week {'.lastweek.'}')
call append('$', 'TODO '.today.' Yesterday {'.yesterday.'}')
call append('$', 'TODO '.today.' Today {'.today.'}')
call append('$', 'TODO '.today.' Tomorrow {'.tomorrow.'}')
call append('$', 'TODO '.today.' 2 Days {'.day2.'}')
call append('$', 'TODO '.today.' 3 Days {'.day3.'}')
call append('$', 'TODO '.today.' 4 Days {'.day4.'}')
call append('$', 'TODO '.today.' 7 Days {'.day7.'}')
call append('$', 'TODO '.today.' 8 Days {'.day8.'}')
call append('$', 'DONE '.today.' Last Month {'.lastmonth.'}')
call append('$', 'DONE '.today.' Last Week {'.lastweek.'}')
call append('$', 'DONE '.today.' Yesterday {'.yesterday.'}')
call append('$', 'DONE '.today.' Today {'.today.'}')
call append('$', 'DONE '.today.' Tomorrow {'.tomorrow.'}')
call append('$', 'DONE '.today.' 2 Days {'.day2.'}')
call append('$', 'DONE '.today.' 3 Days {'.day3.'}')
call append('$', 'DONE '.today.' 4 Days {'.day4.'}')
call append('$', 'DONE '.today.' 7 Days {'.day7.'}')
call append('$', 'DONE '.today.' 8 Days {'.day8.'}')
call vimtest#SaveOut()

function s:processResults()
    let results = []
    for l in getloclist(0)
        call add(results, l.text)
    endfor
    return results
endfunction

" Today
normal \cd
close
let results = s:processResults()
call vimtap#Is(results, [
            \'TODO '.today.' Today {'.today.'}'
            \], "Due Today")
Today
close
let resultscmd = s:processResults()
call vimtap#Is(results, resultscmd, "Due Today (command version)")

" Tomorrow
normal \cf
close
let results = s:processResults()
call vimtap#Is(results, [
            \'TODO '.today.' Tomorrow {'.tomorrow.'}'
            \], "Due Tomorrow")
Tomorrow
close
let resultscmd = s:processResults()
call vimtap#Is(results, resultscmd, "Due Tomorrow (command version)")

" In 7 days
normal \cw
close
let results = s:processResults()
call vimtap#Is(results, [
            \'TODO '.today.' Today {'.today.'}',
            \'TODO '.today.' Tomorrow {'.tomorrow.'}',
            \'TODO '.today.' 2 Days {'.day2.'}',
            \'TODO '.today.' 3 Days {'.day3.'}',
            \'TODO '.today.' 4 Days {'.day4.'}',
            \'TODO '.today.' 7 Days {'.day7.'}'
            \], "Due in the next week")
Week
close
let resultscmd = s:processResults()
call vimtap#Is(results, resultscmd, "Due in the next week (command version)")

" Overdue
normal \cx
close
let results = s:processResults()
call vimtap#Is(results, [
            \'TODO '.today.' Last Month {'.lastmonth.'}',
            \'TODO '.today.' Last Week {'.lastweek.'}',
            \'TODO '.today.' Yesterday {'.yesterday.'}'
            \], "Overdue")
Overdue
close
let resultscmd = s:processResults()
call vimtap#Is(results, resultscmd, "Overdue (command version)")

call vimtest#Quit()
