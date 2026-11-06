/* 07_MESR_programs_10_15.do - shared helper programs 
   - fmt_b            : coefficient with stars, SE in brackets, z-value
   - pub_table        : journal-style Word table (no grid; a line above the
                        first row and below the last row; optional merged
                        header cells and italic group-heading rows)
   - mesr_dmf         : MESR, DMF(0) selection correction (unchanged from 10_10)
   - ipwra_linear_fast: IPWRA with ATT (unchanged from 10_10)
   - say              : plain paragraph in the Word file                     */
version 16

* fmt_b: formats a coefficient with stars, its SE in brackets and its z-value
capture program drop fmt_b
program define fmt_b, rclass
    args b se dec
    if missing(`b') | missing(`se') | `se'==0 {
        return local c = ""
        return local s = ""
        return local z = ""
        exit
    }
    local z  = `b'/`se'
    local p  = 2*normal(-abs(`z'))
    local st = cond(`p'<0.01,"***",cond(`p'<0.05,"**",cond(`p'<0.10,"*","")))
    return local c = strtrim(string(`b',"%12.`dec'f")) + "`st'"
    return local s = "(" + strtrim(string(`se',"%12.`dec'f")) + ")"
    return local z = strtrim(string(`z',"%8.2f"))
    return local p = strtrim(string(`p',"%6.3f"))
end

* pub_table: writes a dataset of string variables (first rows = header) to
* Word in journal style.
*   using     : .dta file of string variables, one per column
*   name()    : putdocx table name          tnum() : e.g. "Table 5."
*   title()   : table title                 note() : note under the table
*   headrows(): number of header rows (bold)
*   groups()  : table rows whose first cell is an italic group heading
*   spans()   : merged header cells, "row:col:ncols" items, RIGHT-TO-LEFT
*   fsize()   : font size inside the table (default 9)
*   rulehead  : also draw a line under the header rows
capture program drop pub_table
program define pub_table
    syntax using/, NAme(string) TNum(string) TItle(string) ///
        [NOte(string) HEADrows(integer 1) GRoups(numlist) SPans(string) ///
         FSize(real 9) RULEhead]
    preserve
    use `"`using'"', clear
    unab vl : _all
    * real minus signs in front of numbers
    foreach v of local vl {
        quietly replace `v' = "−" + substr(`v',2,.) if substr(`v',1,1)=="-" & inrange(substr(`v',2,1),"0","9")
        quietly replace `v' = "(−" + substr(`v',3,.) if substr(`v',1,2)=="(-"
        quietly replace `v' = subinstr(`v'," = -"," = −",.)
    }
    local nr = _N
    local nc : word count `vl'
    putdocx paragraph
    putdocx text ("`tnum' "), bold
    putdocx text (`"`title'"')
    putdocx table `name' = data(`vl'), border(all, nil) layout(autofitcontents)
    putdocx table `name'(.,.), font("Times New Roman", `fsize')
    putdocx table `name'(.,1), halign(left)
    if `nc' > 1 putdocx table `name'(.,2/`nc'), halign(center)
    putdocx table `name'(1/`headrows',.), bold
    foreach r of local groups {
        putdocx table `name'(`r',1), italic
    }
    foreach s of local spans {
        tokenize "`s'", parse(":")
        putdocx table `name'(`1',`3'), colspan(`5')
        putdocx table `name'(`1',`3'), halign(center)
    }
    putdocx table `name'(1,.), border(top, single)
    putdocx table `name'(`nr',.), border(bottom, single)
    if "`rulehead'" != "" putdocx table `name'(`headrows',.), border(bottom, single)
    if `"`note'"' != "" {
        putdocx paragraph
        putdocx text (`"`note'"'), font("Times New Roman", 8)
    }
    * Same already-formatted table cells as Word; export only, no re-estimation.
    mesr_tex_export, name("`name'") tnum("`tnum'") title(`"`title'"') ///
        note(`"`note'"') headrows(`headrows') groups("`groups'") spans("`spans'")
    restore
end

* Staged linear IPWRA: same point-estimation recipe as native teffects IPWRA,
* with joint EA- inference supplied by the caller. All three outcomes
* share ONE re-estimated treatment model per draw. No numerical EE solver.
capture program drop ipwra_linear_fast
program define ipwra_linear_fast, eclass
    version 16
    if `"`0'"'=="" {
        ereturn display
        exit
    }
    syntax, OUTcomes(varlist numeric) Xvars(varlist numeric) ///
        Zvars(varlist numeric) Regime(varname numeric) [Start(name)]
    tempname B v
    tempvar touse
    quietly gen byte `touse'=1
    markout `touse' `outcomes' `xvars' `zvars' `regime'
    local ok=0
    if "`start'"!="" {
        capture quietly mlogit `regime' `xvars' `zvars' if `touse', ///
            baseoutcome(4) from(`start',copy) iterate(100)
        if !_rc {
            if e(converged)==1 local ok=1
        }
    }
    if !`ok' {
        quietly mlogit `regime' `xvars' `zvars' if `touse', ///
            baseoutcome(4) iterate(100)
        if e(converged)!=1 exit 430
    }
    forvalues k=1/4 {
        tempvar p`k' w`k'
        quietly predict double `p`k'', outcome(`k')
        quietly count if (`p`k''<1e-5 | missing(`p`k'')) & `touse'
        if r(N)>0 exit 459
        quietly gen double `w`k''=1/`p`k'' if `touse'
    }
    local first=1
    foreach y of local outcomes {
        local o=subinstr("`y'","_","",.)
        forvalues k=1/4 {
            quietly regress `y' `xvars' if `regime'==`k' & `touse' [aw=`w`k'']
            if e(df_r)<=0 exit 2001
            tempvar mu`k'
            quietly predict double `mu`k'', xb
            quietly summarize `mu`k'' if `touse', meanonly
            local mean`k'=r(mean)
        }
        *--- IPWRA ATT (as in Manda et al. 2021, Table 5): treated households keep
        *    weight 1; non-participants are reweighted by p_j/p_4 to resemble regime j.
        forvalues j=1/3 {
            tempvar wa`j' m4a`j' mjj`j' dj`j'
            quietly gen double `wa`j''=`p`j''/`p4' if `touse'
            quietly regress `y' `xvars' if `regime'==4 & `touse' [aw=`wa`j'']
            quietly predict double `m4a`j'', xb
            quietly regress `y' `xvars' if `regime'==`j' & `touse'
            quietly predict double `mjj`j'', xb
            quietly gen double `dj`j''=`mjj`j''-`m4a`j''
            quietly summarize `dj`j'' if `regime'==`j' & `touse', meanonly
            local att`j'=r(mean)
            quietly summarize `m4a`j'' if `regime'==`j' & `touse', meanonly
            local cf`j'=r(mean)
        }
        matrix `v'=(`mean1'-`mean4',`mean2'-`mean4',`mean3'-`mean4', ///
            `mean1',`mean2',`mean3',`mean4', `att1',`att2',`att3', `cf1',`cf2',`cf3')
        matrix colnames `v'=ATE1 ATE2 ATE3 POmean1 POmean2 POmean3 POmean4 ATT1 ATT2 ATT3 CF1 CF2 CF3
        matrix coleq `v'=`o'_ipw
        if `first' matrix `B'=`v'
        else matrix `B'=`B',`v'
        local first=0
    }
    ereturn post `B', esample(`touse')
end

* say: adds a plain paragraph of explanation to the Word file
capture program drop say
program define say
    args txt
    putdocx paragraph
    putdocx text (`"`txt'"')
end


capture program drop mesr_dmf
program define mesr_dmf, eclass
    version 16
    * If Stata calls the program with no options (to redisplay results after
    * ), just show the stored results instead of re-estimating.
    if `"`0'"' == "" {
        ereturn display
        exit
    }
    syntax , OUTcomes(varlist numeric) Xvars(varlist numeric) ///
             Zvars(varlist numeric) Regime(varname numeric) ///
             [Start(name) Effects(string)]
    tempname B b a t
    tempvar touse
    quietly gen byte `touse' = 1
    markout `touse' `outcomes' `xvars' `zvars' `regime'
    if "`effects'"=="" local effects "source"
    if !inlist("`effects'","source","legacy") exit 198

    *--- Stage 1: ONE multinomial logit for all regimes (base = 4) ---
    local ok=0
    if "`start'"!="" {
        capture quietly mlogit `regime' `xvars' `zvars' if `touse', ///
            baseoutcome(4) from(`start', copy) iterate(100)
        if !_rc {
            if e(converged)==1 local ok=1
        }
    }
    if !`ok' {
        quietly mlogit `regime' `xvars' `zvars' if `touse', ///
            baseoutcome(4) iterate(100)
        if e(converged)!=1 exit 430
    }
    forvalues k = 1/4 {
        tempvar p`k' q`k' v`k'
        quietly predict double `p`k'', outcome(`k')
        quietly count if (`p`k''<=0 | `p`k''>=1 | missing(`p`k'')) & `touse'
        if r(N)>0 exit 498
        quietly gen double `q`k'' = `p`k''*ln(`p`k'')/(1-`p`k'')
        quietly gen double `v`k'' = `p`k''*(ln(`p`k'')/(1-`p`k''))^2
    }

    *--- DMF(0) correction terms (identical to selmlog, dmf(0)):
    *    for regime j and every other regime l: m_jl = P_l*ln(P_l)/(1-P_l) + ln(P_j)
    forvalues j = 1/4 {
        local mlist`j' ""
        local lnam`j'  ""
        forvalues l = 1/4 {
            if `l' != `j' {
                tempvar m`j'_`l'
                quietly gen double `m`j'_`l'' = `q`l'' + ln(`p`j'')
                local mlist`j' `mlist`j'' `m`j'_`l''
                local lnam`j'  `lnam`j'' lam`l'
            }
        }
    }

    local first 1
    foreach y of local outcomes {
        local o = subinstr("`y'","_","",.)
        *--- Stage 2: outcome equation for each regime ---
        forvalues j = 1/4 {
            quietly regress `y' `xvars' `mlist`j'' if `regime'==`j' & `touse'
            local nj  = e(N)
            local rss = e(rss)
            matrix `b' = e(b)
            matrix colnames `b' = `xvars' `lnam`j'' _cons
            matrix coleq    `b' = `o'_r`j'
            tempvar xb`j'_`o' dl
            quietly predict double `xb`j'_`o'', xb
            if "`effects'"=="source" {
                tempvar structural
                quietly gen double `structural'=_b[_cons] if `touse'
                foreach vv of local xvars {
                    quietly replace `structural'=`structural'+_b[`vv']*`vv' if `touse'
                }
                local ownalpha=0
                forvalues l=1/4 {
                    if `l'!=`j' local ownalpha=`ownalpha'-_b[`m`j'_`l'']
                }
                quietly replace `xb`j'_`o''=`structural' if `touse'
                forvalues l=1/4 {
                    if `l'==`j' local aa=`ownalpha'
                    else local aa=_b[`m`j'_`l'']
                    quietly replace `xb`j'_`o''=`xb`j'_`o''+ ///
                        `aa'*cond(`regime'==`l',-ln(`p`l''),`q`l'') if `touse'
                }
            }
            * sigma^2 and rho exactly as in selmlog dmf(0)
            quietly gen double `dl' = 0 if `regime'==`j' & `touse'
            forvalues l = 1/4 {
                if `l' != `j' {
                    quietly replace `dl' = `dl' + (_b[`m`j'_`l''])^2*`v`l'' if `regime'==`j' & `touse'
                }
            }
            quietly summarize `dl' if `regime'==`j' & `touse', meanonly
            local sig2 = `rss'/`nj' + r(mean)
            if `sig2'<=0 | missing(`sig2') exit 498
            local sg   = sqrt(`sig2')
            matrix `a' = (`sg')
            local anames sigma
            forvalues l = 1/4 {
                if `l' != `j' {
                    local rho = _b[`m`j'_`l'']*_pi/sqrt(6*`sig2')
                    matrix `a' = `a', (`rho')
                    local anames `anames' rho`l'
                }
            }
            matrix colnames `a' = `anames'
            matrix coleq    `a' = `o'_anc`j'
            if `first' == 1 {
                matrix `B' = `b', `a'
                local first 0
            }
            else {
                matrix `B' = `B', `b', `a'
            }
        }

        *--- Treatment effects against regime 4 (neither) ---
        local tn ""
        forvalues j = 1/3 {
            quietly summarize `xb`j'_`o'' if `regime'==`j' & `touse', meanonly
            local TR = r(mean)
            quietly summarize `xb4_`o'' if `regime'==`j' & `touse', meanonly
            local CF = r(mean)
            quietly summarize `xb`j'_`o'' if `regime'==4 & `touse', meanonly
            local CU = r(mean)
            quietly summarize `xb4_`o'' if `regime'==4 & `touse', meanonly
            local UA = r(mean)
            tempvar dd
            quietly gen double `dd' = `xb`j'_`o'' - `xb4_`o''
            quietly summarize `dd' if `touse', meanonly
            local ATE = r(mean)
            local ATT = `TR' - `CF'
            local ATU = `CU' - `UA'
            if `j'==1 matrix `t' = (`TR', `CF', `CU', `UA', `ATT', `ATU', `ATE')
            else      matrix `t' = `t', (`TR', `CF', `CU', `UA', `ATT', `ATU', `ATE')
            local tn `tn' TR`j' CF`j' CU`j' UA`j' ATT`j' ATU`j' ATE`j'
        }
        *--- Coupled (regime 3) versus each standalone option, among regime-3 households
        quietly summarize `xb3_`o'' if `regime'==3 & `touse', meanonly
        local BOTH = r(mean)
        quietly summarize `xb1_`o'' if `regime'==3 & `touse', meanonly
        local CFF = r(mean)
        quietly summarize `xb2_`o'' if `regime'==3 & `touse', meanonly
        local CFS = r(mean)
        local BvF = `BOTH' - `CFF'
        local BvS = `BOTH' - `CFS'
        matrix `t' = `t', (`BOTH', `CFF', `CFS', `BvF', `BvS')
        local tn `tn' BOTH CFF CFS BvF BvS
        matrix colnames `t' = `tn'
        matrix coleq    `t' = `o'_te
        matrix `B' = `B', `t'
    }
    ereturn post `B', esample(`touse')
    ereturn local effects "`effects'"
    * NOTE: e(cmd) is deliberately NOT set. If it is set, -- calls
    * mesr_dmf again without options to display results -> "option outcomes() required".
end


* LaTeX export only: no estimation, prediction, filtering or imputation.
capture program drop mesr_tex_escape
program define mesr_tex_escape, rclass
    * Empty table cells and omitted notes are valid: do not require text().
    syntax [, TEXT(string)]
    local t `"`text'"'
    local t = subinstr(`"`t'"', char(92), char(1), .)
    foreach ch in 123 125 38 37 36 35 95 {
        local t = subinstr(`"`t'"', char(`ch'), char(92)+char(`ch'), .)
    }
    local t = subinstr(`"`t'"', "~", "\textasciitilde{}", .)
    local t = subinstr(`"`t'"', "^", "\textasciicircum{}", .)
    local t = subinstr(`"`t'"', char(1), "\textbackslash{}", .)
    local t = subinstr(`"`t'"', uchar(160), " ", .)
    local t = subinstr(`"`t'"', "−", "-", .)
    local t = subinstr(`"`t'"', "–", "\textendash{}", .)
    local t = subinstr(`"`t'"', "χ²", "$\chi^2$", .)
    local t = subinstr(`"`t'"', "λ", "$\lambda$", .)
    local t = subinstr(`"`t'"', "ρ", "$\rho$", .)
    local t = subinstr(`"`t'"', "σ", "$\sigma$", .)
    local t = subinstr(`"`t'"', "≥", "$\geq$", .)
    local t = subinstr(`"`t'"', "≤", "$\leq$", .)
    local t = subinstr(`"`t'"', "±", "$\pm$", .)
    local t = subinstr(`"`t'"', "×", "$\times$", .)
    local t = subinstr(`"`t'"', "°", "$^{\circ}$", .)
    local t = subinstr(`"`t'"', "²", "$^2$", .)
    local t = subinstr(`"`t'"', char(10), " ", .)
    local t = subinstr(`"`t'"', char(13), " ", .)
    return local tex `"`t'"'
end

capture program drop mesr_tex_begin
program define mesr_tex_begin
    global MESR_TEXROOT "$result/latex"
    global MESR_TEX_N 0
    capture mkdir "$MESR_TEXROOT"
    capture mkdir "$MESR_TEXROOT/data"
    capture mkdir "$MESR_TEXROOT/tables"
    tempname fh
    file open `fh' using "$MESR_TEXROOT/export_complete.txt", write text replace
    file write `fh' "INCOMPLETE" _n
    file close `fh'
    file open `fh' using "$MESR_TEXROOT/MESR_annex_tables.tex", write text replace
    file write `fh' "% Generated from the same string datasets as the Word tables." _n
    file write `fh' "% Upload this SINGLE file beside main.tex in Overleaf." _n
    file close `fh'
    file open `fh' using "$MESR_TEXROOT/MESR_research_tables.tex", write text replace
    file write `fh' "\documentclass[10pt,a4paper]{article}" _n ///
        "\usepackage[margin=1.5cm]{geometry}" _n ///
        "\usepackage[T1]{fontenc}\usepackage[utf8]{inputenc}" _n ///
        "\usepackage{booktabs,longtable,array,graphicx,helvet,caption}" _n ///
        "\renewcommand{\familydefault}{\sfdefault}" _n ///
        "\begin{document}" _n
    file close `fh'
end

* Formats one row of the currently loaded string-table dataset.
capture program drop mesr_tex_row
program define mesr_tex_row, rclass
    syntax, ROW(integer) VARS(string) [HEAD(integer 0) SPANS(string) GROUPS(string)]
    local nc : word count `vars'
    local c = 1
    local line ""
    while `c'<=`nc' {
        local v : word `c' of `vars'
        local value = `v'[`row']
        quietly mesr_tex_escape, text(`"`value'"')
        local value `"`r(tex)'"'
        if `head' local value = subinstr(`"`value'"', "z-value", "z-\allowbreak value", .)
        local width 1
        foreach sp of local spans {
            tokenize "`sp'", parse(":")
            if `row'==`1' & `c'==`3' local width `5'
        }
        if `head' local value `"\textbf{`value'}"'
        if `width'>1 local value `"\multicolumn{`width'}{c}{`value'}"'
        if `c'==1 & strpos(" `groups' "," `row' ") local value `"\textit{`value'}"'
        if `c'>1 local line `"`line' & "'
        local line `"`line'`value'"'
        local c = `c' + `width'
    }
    return local tex `"`line' \\"'
end

capture program drop mesr_tex_export
program define mesr_tex_export
    syntax, NAME(string) TNUM(string) TITLE(string) [NOTE(string) ///
        HEADROWS(integer 1) GROUPS(string) SPANS(string)]
    if "$MESR_TEXROOT"=="" exit
    unab vl : _all
    local nr = _N
    local nc : word count `vl'
    local first : word 1 of `vl'
    global MESR_TEX_N = $MESR_TEX_N + 1
    local serial = string($MESR_TEX_N,"%02.0f")
    * Store the exact display values and metadata for export-only reruns.
    char _dta[mesr_name] `"`name'"'
    char _dta[mesr_tnum] `"`tnum'"'
    char _dta[mesr_title] `"`title'"'
    char _dta[mesr_note] `"`note'"'
    char _dta[mesr_headrows] "`headrows'"
    char _dta[mesr_groups] "`groups'"
    char _dta[mesr_spans] "`spans'"
    quietly save "$MESR_TEXROOT/data/table_`serial'.dta", replace
    quietly export delimited using "$MESR_TEXROOT/data/table_`serial'.csv", replace
    quietly mesr_tex_escape, text(`"`tnum' `title'"')
    local caption `"`r(tex)'"'
    quietly mesr_tex_escape, text(`"`note'"')
    local footnote `"`r(tex)'"'
    * Fixed, wrapping widths: more space to labels, less to z-values.
    local spec ""
    forvalues c=1/`nc' {
        local w = cond(`c'==1,.26,.64/(`nc'-1))
        if `nc'==9 & `c'>1 local w = cond(mod(`c',2)==0,.11,.055)
        if `nc'==2 local w = cond(`c'==1,.65,.25)
        if "`name'"=="t2" local w = cond(`c'==1,.23,cond(`c'==2,.48,.19))
        if "`name'"=="t6" local w = cond(`c'==1,.64,.13)
        local wtxt = string(`w',"%6.4f")
        local spec `"`spec'>{\raggedright\arraybackslash}p{`wtxt'\linewidth}"'
    }
    tempname tf af rf
    file open `tf' using "$MESR_TEXROOT/tables/table_`serial'.tex", write text replace
    file write `tf' "\begingroup\fontsize{8.5}{10.5}\selectfont" _n ///
        "\setlength{\tabcolsep}{2pt}\renewcommand{\arraystretch}{1.15}" _n ///
        "\begin{longtable}{@{}`spec'@{}}" _n ///
        `"\caption*{\textbf{`caption'}}\\"' _n "\toprule" _n
    forvalues rr=1/`headrows' {
        quietly mesr_tex_row, row(`rr') vars("`vl'") head(1) spans("`spans'")
        file write `tf' `"`r(tex)'"' _n
    }
    file write `tf' "\midrule\endfirsthead" _n "\toprule" _n
    forvalues rr=1/`headrows' {
        quietly mesr_tex_row, row(`rr') vars("`vl'") head(1) spans("`spans'")
        file write `tf' `"`r(tex)'"' _n
    }
    file write `tf' "\midrule\endhead" _n
    local start = `headrows'+1
    forvalues rr=`start'/`nr' {
        quietly mesr_tex_row, row(`rr') vars("`vl'") groups("`groups'")
        file write `tf' `"`r(tex)'"' _n
    }
    file write `tf' "\bottomrule\end{longtable}" _n ///
        `"{\footnotesize `footnote'\par}\endgroup\clearpage"' _n
    file close `tf'
    file open `rf' using "$MESR_TEXROOT/MESR_research_tables.tex", write text append
    file write `rf' "\input{tables/table_`serial'.tex}" _n
    file close `rf'

    * Identify SE rows, keeping each coefficient and its SE on one slide.
    tempvar se group
    quietly gen byte `se' = 0
    quietly gen byte `group' = 0
    foreach v of local vl {
        if "`v'"!="`first'" quietly replace `se'=1 if `first'=="" & substr(strtrim(`v'),1,1)=="("
    }
    foreach r of local groups {
        quietly replace `group'=1 in `r'
    }
    local part 0
    file open `af' using "$MESR_TEXROOT/MESR_annex_tables.tex", write text append
    while `start'<=`nr' {
        local ++part
        local stop = min(`nr',`start'+5)
        if "`name'"=="t2" local stop=min(`nr',`start'+2)
        if `nc'==2 local stop=min(`nr',`start'+3)
        * Treatment-effects panels: four rows per regime (ATT/ATU/BH/ATE).
        if substr("`name'",1,1)=="e" & `nc'==6 local stop=min(`nr',`start'+3)
        if `stop'<`nr' {
            if `se'[`stop'+1]==1 local --stop
            if `group'[`stop']==1 local --stop
        }
        if `stop'<`start' local stop=min(`nr',`start'+1)
        file write `af' "\def\slideid{`tnum' p`part'}" _n ///
            "\begin{frame}[t,label=mesr-`name'-`part']" _n ///
            `"\frametitle{\fontsize{12}{14}\selectfont `caption' (continued `part')}"' _n ///
            "\fontsize{8.3}{10}\selectfont\setlength{\tabcolsep}{2pt}" _n ///
            "\renewcommand{\arraystretch}{1.12}" _n ///
            "\begin{tabular}{@{}`spec'@{}}\toprule" _n
        forvalues rr=1/`headrows' {
            quietly mesr_tex_row, row(`rr') vars("`vl'") head(1) spans("`spans'")
            file write `af' `"`r(tex)'"' _n
        }
        file write `af' "\midrule" _n
        forvalues rr=`start'/`stop' {
            quietly mesr_tex_row, row(`rr') vars("`vl'") groups("`groups'")
            file write `af' `"`r(tex)'"' _n
        }
        file write `af' "\bottomrule\end{tabular}" _n ///
            `"\par\vspace{.12cm}{\fontsize{6.5}{8}\selectfont `footnote'\par}"' _n ///
            "\vfill{\fontsize{6}{7}\selectfont Generated by the Stata table export; `tnum'}" _n ///
            "\end{frame}" _n
        local start = `stop'+1
    }
    file close `af'
    drop `se' `group'
end

capture program drop mesr_tex_finish
program define mesr_tex_finish
    tempname fh
    file open `fh' using "$MESR_TEXROOT/MESR_research_tables.tex", write text append
    file write `fh' "\end{document}" _n
    file close `fh'
    file open `fh' using "$MESR_TEXROOT/export_complete.txt", write text replace
    file write `fh' "$MESR_TEX_N" _n
    file close `fh'
    di as result "LaTeX tables: $MESR_TEXROOT (tables exported: $MESR_TEX_N)"
end
