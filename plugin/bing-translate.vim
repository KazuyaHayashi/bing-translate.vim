let s:cpo_save = &cpo
set cpo&vim

if exists("g:loaded_bing_translate")
    finish
endif
let g:loaded_bing_translate = 1

let s:BING_TRANSLATE_API = "http://api.bing.net/json.aspx"

" 直前にヤンクした内容を取得する
function! s:GetYankedSentence()
    let l:tmp = @@
    silent normal gvy
    let l:selected = @@
    let @@ = l:tmp
    return l:selected
endfunction

" プレビューウィンドウに表示する
function! s:ShowResult(result)
    silent pedit! bing-traslate-result
    wincmd p
    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal noswapfile
    call append(0, a:result)
    wincmd p
endfunction

" bing の API へ get リクエストを投げる
function! s:TranslateRequest(string)
    let l:result_json = http#get(
        \s:BING_TRANSLATE_API, 
        \{"AppId" : g:BING_APPID, 
        \"Query" : a:string, 
        \"Sources": "Translation", 
        \"Version" : "2.2", 
        \"Market" : "en-us", 
        \"Translation.SourceLanguage" : "en", 
        \"Translation.TargetLanguage" : "ja"})
    let l:traslate_result = json#decode(l:result_json.content)
    return l:traslate_result
endfunction

" 指定範囲を翻訳する
function! TranslateRange() range
    " 範囲指定した内容を各行のリストとして取得する
    let l:lines = getline(a:firstline, a:lastline)
    let l:sentence = join(l:lines, "\n")
    let l:traslate_result = s:TranslateRequest(l:sentence)
    
    " 翻訳結果が入ってない場合もあるので例外処理を行う
    try
        call s:ShowResult(l:traslate_result["SearchResponse"]["Translation"]["Results"][0]["TranslatedTerm"])
    catch
        call s:ShowResult("No result. Please try agein a few second after.")
    endtry
endfunction

" 直前にヤンクした内容を翻訳する
function! TranslateYankedSentence()
    let l:sentence = s:GetYankedSentence()
    let l:traslate_result = s:TranslateRequest(l:sentence)
    
    " 翻訳結果が入ってない場合もあるので例外処理を行う
    try
        call s:ShowResult(l:traslate_result["SearchResponse"]["Translation"]["Results"][0]["TranslatedTerm"])
    catch
        call s:ShowResult("No result. Please try agein a few second after.")
    endtry
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
