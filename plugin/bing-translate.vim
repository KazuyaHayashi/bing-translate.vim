let s:cpo_save = &cpo
set cpo&vim

if exists("g:loaded_bing_translate")
    finish
endif
let g:loaded_bing_translate = 1

let s:BING_TRANSLATE_API = "http://api.bing.net/json.aspx"

" 直前にヤンクした内容を取得する
function! GetYankedString() range
    let l:tmp = @@
    silent normal gvy
    let l:selected = @@
    let @@ = l:tmp
    return l:selected
endfunction

function! ListToString(list)
    let l:string = ""
    for line in a:list
        let nonewline = substitute(line, "\n", "", "g")
        let l:string = l:string.nonewline
    endfor
    return l:string
endfunction

function! TranslateRange() range
    " 範囲指定した内容を各行のリストとして取得する
    let l:lines = getline(a:firstline, a:lastline)
    let l:string = ListToString(l:lines)
    let l:result_json = http#get(s:BING_TRANSLATE_API, {"AppId" : g:BING_APPID, "Query" : l:string, "Sources": "Translation", "Version" : "2.2", "Market" : "en-us", "Translation.SourceLanguage" : "en", "Translation.TargetLanguage" : "ja"})
    let l:traslate_result = json#decode(l:result_json.content)
    
    " 翻訳結果が入ってない場合もあるので例外処理を行う
    try
        echo l:traslate_result["SearchResponse"]["Translation"]["Results"][0]["TranslatedTerm"]
    catch
        echo "No result. Please try agein a few seconde after."
    endtry
endfunction

function! Translate()
    let l:string = GetYankedString()
    echo l:string
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
