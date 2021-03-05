Red [
	needs 'view
]

;; campaign site generator. 1st draft.

;; dir/file requrements
;;  this_program
;;  ./src
;;    (client supplied files)
;;  ./res
;;    template_default.html
;;    preset_blank.tnc
;;  ./pub
;;    /fonts
;;    /images
;;      bg.jpg
;;      banner.png

;; template html keys
;; [surveyurl]
;; [promotiontitle]
;; [promotiontncs]

;; ! : doing it
;; ? : having problems with it
;; - : dropped it

;; TODO
;; [?] (onerous - merge seperate project) add html render preview
;; [ ] fix no-show of 1st t&c article
;; [ ] skip bg html if bg.png is missing, use white instead
;; [ ] upload generic html template, preset, bg and banner to github
;; [?] add article html code preview
;; [!] fix article html code corruption caused by find/replace
;; [ ] move indentation lists to popmenus if possible
;; [ ] add pre-existing indentation checks to clauser
;; [ ] make AUS redemption boilerplate T&Cs
;; [ ] make AUS competition boilerplate T&Cs
;; [ ] make AUS bonus-offer boilerplate T&Cs
;; [ ] make NZ redemption boilerplate T&Cs
;; [ ] make NZ competition boilerplate T&Cs
;; [ ] make NZ bonus-offer boilerplate T&Cs
;; [ ] check and download templates on startup
;; [ ] (onerous - merge separate project) add option rip tncs directly from source pdf and docx files
;; [?] fix tab-panel size vs menu
;; [?] resizable ui
;; [?] resize limiting
;; [?] redo preset ui if/when drop-down is fixed
;; [ ] optimize
;; [ ] redify
;; [ ] (maybe) make a date picker for date fields - not important here tho
;; [ ] (onerus - merge saparate project) try in-situ drag'n'drop tnc builder using draw; make it an interactive outliner
;; [ ] investigate curl vs rebol for ftp
;; [ ] add ftp upload tab & params
;; [ ] hose everything and redesign.


prin [ "loading source template..." ]
h: read %./res/template_default.html
print [ "OK" ]

;; display tile only, not used for anything else
promotionfilename: "DramaQueen"

prin [ "writing clauser function..." ]
clauser: function [t s m u] [
	;print [ "clauser triggered..." ]
	;print [ "^-clauser indentation = " m ]
	;print [ "^-clauser strings = " s ]
	;probe s

;; skip if empty

	either ((length? s) = 1) and (s/1 = "") [
		return ""
	] [
		o: rejoin ["<li>" t "</li>" m/2/1 "^/"]
		c: 1
		d: 2
		tbs: copy []
		j: #"-"
		td: 0

;; get indentation values, retain previous value if line is blank
;; td is current indentation, d is next-line indentation
;; indentation is 2 to 4, with 1 being reserved for section headers

		foreach line s [
			either (line/1 = j) [
				d: 3
				if (line/2 = j) [ d: 4 ]
			] [
				if ((trim line) <> "") [ d: 2] 
			]
			append tbs d
		]

;; loop through lines of text, indent and tag as required

		repeat x (length? tbs) [
		
;; calc next-depth and offset
;; offset is -1 to account for depth of 1 being reserved for headers
		
			g: max 0 (min (x + 1) (length? tbs))
			od: tbs/:g
			td: tbs/:x
			ofs: (od - 1) - (td - 1)
			d: td + ofs
			tsx: trim copy s/:x

;; tab indent

			pws: copy [] 
			loop (td - 1) [ append pws "^-" ]

;; list-tags

			li: "<li>"
			cli: "</li>"
			if tsx = "" [ li: "" cli: "" ]

;; remove markers

			if tsx/1 = j [ tsx: replace tsx "--" "" ]
			if tsx/1 = j [ tsx: replace tsx "-" "" ]
			;print [ "current = " td "^/next = " d "^/offset = " ofs ]


;; tagging

			if x <= (length? tbs) [
				if ofs = 1 [
					;print [ "^-next line is indented" ]
					o: rejoin[ o pws li tsx cli m/(d)/1 "^/" ]
				]
				if ofs = 2 [
					;print [ "^-next line is indented by 2" ]
					o: rejoin[ o pws li tsx cli m/(d - 1)/1 "^/" pws "^-" m/(d)/1 "^/" ]
				]
				if ofs = 0 [
					;print [ "^-next line is on the same level" ]
					if tsx <> "" [ o: rejoin[ o pws li tsx cli "^/" ] ]
				]
				if ofs = -1 [
					;print [ "^-next line is unindented by 1" ]
					o: rejoin[ o pws li tsx cli "^/" (take/part (copy pws) (td - 2)) m/(td)/2 "^/" ]
				]
				if ofs = -2 [
					;print [ "^-next line is unindented by 2" ]
					o: rejoin[ o pws li tsx cli "^/" (take/part (copy pws) (td - 2)) m/(td)/2 "^/" (take/part (copy pws) (td - 3)) m/(d - 1)/2 "^/" ]
				]
			]
		]

;; close off tags left open

		td: td - 2
		while [td > 0] [
			pws: ""
			loop td [ pws: rejoin [pws "^-"] ]
			append o rejoin [ pws m/:d/2 "^/" ] td: td - 1 d: d - 1 
		]
		append o m/2/2

;; replace setup tags with field values

		repeat fx ((length? u) - 1) [
			if fx % 2 = 1 [
				unless none? u/(fx + 1) [ o: replace o u/:fx u/(fx + 1) ]
			]
		]
		;print o
		return o
	]
]
print [ "OK" ]


;; terms and conditions data: section names, section text, section html, indentation rules

tncs: context [
	thead: ["GENERAL CONDITIONS" "PROMOTER" "PROMOTION PERIOD" "REDEMPTION OFFER" "APPLICABLE PRODUCTS" "EXCLUDED PRODUCTS" "HOW TO REDEEM" "DELIVERY" "DISCLAIMER AND RIGHTS OF THE PROMOTER" "PERSONAL INFORMATION" "LIABILITY" "GOVERNING LAW"]

	ttext: ["GENERAL CONDITIONS" "PROMOTER" "PROMOTION PERIOD" "REDEMPTION OFFER" "APPLICABLE PRODUCTS" "EXCLUDED PRODUCTS" "HOW TO REDEEM" "DELIVERY" "DISCLAIMER AND RIGHTS OF THE PROMOTER" "PERSONAL INFORMATION" "LIABILITY" "GOVERNING LAW"]

	thtml: ["<li>GENERAL CONDITIONS</li>" "<li>PROMOTER</li>" "<li>PROMOTION PERIOD</li>" "<li>REDEMPTION OFFER</li>" "<li>APPLICABLE PRODUCTS</li>" "<li>EXCLUDED PRODUCTS</li>" "<li>HOW TO REDEEM</li>" "<li>DELIVERY</li>" "<li>DISCLAIMER AND RIGHTS OF THE PROMOTER</li>" "<li>PERSONAL INFORMATION</li>" "<li>LIABILITY</li>" "GOVERNING LAW"]

	tind: [ 6 2 5 1 ] 
]

;; promotion data =
;; promotion_name client_name start_date end_date site_url site_user survey_url tnc_preset

pset: [ "" "" "" "" "" "" "" "" "blank" ]

sidx: 1

prin [ "writing writesrc function..." ]
writesrc: function [n s c ht i u] [
	print [ "writesrc triggered..." ]
	;print [ "n = " n ]
	;print [ "s = " s ]
	;print [ "c = " c ]
	;print [ "i = " i ]
	;probe s
	o: copy ht
	l: copy c
	g: take/last l
	;probe l
	replace o "[promotiontitle]" n
	either (none? s) or (s = "") [
		replace o "[surveyurl]" ""
	] [
		replace o "[surveyurl]" (rejoin ["<div id=^"mid-container^" align=^"center^"> ^/ ^- <iframe height=^"700^" width=^"640^" frameborder=^"0^" allowtransparency=^"true^" style=^"background: #FFFFFF;^" src=^"" s "^"></iframe>^/</div>"])
	]
	replace o "[promotiontncs]" (rejoin [i/1 "^/" (rejoin l ) i/2 "^/" g])
	repeat fx ((length? u) - 1) [
		if fx % 2 = 1 [
			unless none? u/(fx + 1) [ o: replace o u/:fx u/(fx + 1) ]
		]
	]
	write %./pub/test.html o
	o
]
print [ "OK" ]

indents: [ ["<ul>" "</ul>"] ["<ol type=^"A^">" "</ol>"] ["<ol type=^"a^">" "</ol>"]  ["<ol type=^"I^">" "</ol>"] ["<ol type=^"i^">" "</ol>"] ["<ol type=^"1^">" "</ol>"] ]
indentlabels: [ "Bullet" "Uppercase letters" "Lowercase letters"  "Uppercase Roman" "Lowercase Roman" "Numbers" ]

prin [ "writing fittopane function..." ]
fittopane: function [ii ps] [
	g: ii/image
	either (ps/x / ps/y) > (g/size/x / g/size/y) [
		ii/size/y: to-integer (ps/y - 20)
		ii/size/x: to-integer ((ps/y - 20) * (g/size/x / g/size/y))
	] [
		ii/size/x: to-integer (ps/x - 20)
		ii/size/y: to-integer ((ps/x - 20) * (g/size/y / g/size/x))
	]
	ii/offset/x: (to-integer ((ps/x - ii/size/x) * 0.5))
]
print [ "OK" ]

prin [ "writing loadtnc func..." ]
loadtnc: func [ presetfile ] [
	print [ "loadtnc func triggered..." ]
	either not (none? presetfile) [
		either exists? presetfile [
			print [ "opening tncs from file..." ]
			clear tncs/thead
			clear tncs/ttext
			clear tncs/thtml
			tncs: do read presetfile
			tta/selected: tncs/tind/1
			ttb/selected: tncs/tind/2
			ttc/selected: tncs/tind/3
			ttd/selected: tncs/tind/4
			parse (to-string presetfile) [thru "preset_" copy pxn to "." ]
			sidx: atcl/selected 
			atcl/data: tncs/thead
			svl/text: pxn
			atcl/selected: sidx
			cl/text: (tncs/ttext/:sidx)
			u: survey/text
			n: "..."
			if pname/text <> none [ n: pname/text ]
			ttags: reduce [ "[clientname]" (clientname/text) "[starting]" (starting/text) "[ending]" (ending/text)]
			m: writesrc n u tncs/thtml h indents/(tncs/tind/1) ttags
			viewsrc/text: m
			;probe tncs/thtml/:sidx
		] [ print [ "^-can't find preset file: " presetfile ] ]
	] [ print [ "^-preset file not set: " presetfile ] ]
]
print [ "OK" ]

hidx: 1

prin [ "making the ui..." ]
v: layout [
	title promotionfilename
	tp: tab-panel 600x400 [
		"Setup" [
			below
			sup: panel [
				text 230x30 "html template"
				htl: drop-list 320x30 select 1 data (collect [foreach file read %./res/ [ if (parse (to-string file) ["template_" thru ".html"]) [keep (to-string file)] ]]) [
					unless face/selected = hidx [
						h: read (to-file rejoin [ "./res/" face/data/(face/selected) ])
						ttags: reduce [ "[clientname]" (clientname/text) "[starting]" (starting/text) "[ending]" (ending/text)]
						m: writesrc pname/text survey/text tncs/thtml h indents/(tta/selected) ttags
						viewsrc/text: m
						v/text: (rejoin [promotionfilename " *"])
						hidx: face/selected 
					]
				]
				return
				text 230x30 "promotion name"
				pname: field 320x30 on-change [
					print [ "name changed..." ]
					ttags: reduce [ "[clientname]" (clientname/text) "[starting]" (starting/text) "[ending]" (ending/text)]
					m: writesrc pname/text survey/text tncs/thtml h indents/(tta/selected) ttags
					viewsrc/text: m
					v/text: (rejoin [promotionfilename " *"])
				]
				return
				text 230x30 "client name"
				clientname: field 320x30 on-change [
					ttags: reduce [ "[clientname]" (clientname/text) "[starting]" (starting/text) "[ending]" (ending/text)]
					m: writesrc pname/text survey/text tncs/thtml h indents/(tta/selected) ttags
					viewsrc/text: m
					v/text: (rejoin [promotionfilename " *"])
				]
				return
				text 230x30 "promotion start (dd-mm-yyyy)"
				starting: field 320x30 on-change [
					ttags: reduce [ "[clientname]" (clientname/text) "[starting]" (starting/text) "[ending]" (ending/text)]
					m: writesrc pname/text survey/text tncs/thtml h indents/(tta/selected) ttags
					viewsrc/text: m
					v/text: (rejoin [promotionfilename " *"])
				]
				return
				text 230x30 "promotion end (dd-mm-yyyy)"
				ending: field 320x30 on-change [
					ttags: reduce [ "[clientname]" (clientname/text) "[starting]" (starting/text) "[ending]" (ending/text)]
					m: writesrc pname/text survey/text tncs/thtml h indents/(tta/selected) ttags
					viewsrc/text: m
					v/text: (rejoin [promotionfilename " *"])
				]
				return
				text 230x30 "site url"
				siteurl: field 320x30 on-change [
					v/text: (rejoin [promotionfilename " *"])
				]
				return
				text 230x30 "site username"
				siteusr: field 320x30 on-change [
					v/text: (rejoin [promotionfilename " *"])
				]
				return
				text 230x30 "survey url"
				survey: field 320x30 on-change [
					print [ "survey changed..." ]
					ttags: reduce [ "[clientname]" (clientname/text) "[starting]" (starting/text) "[ending]" (ending/text)]
					m: writesrc pname/text survey/text tncs/thtml h indents/(tta/selected) ttags
					viewsrc/text: m
					v/text: (rejoin [promotionfilename " *"])
				]
			]
		]
		"Banner image" [
			below
			bpp: panel 580x50 [
				text "click below to source banner image"
				heb: check true "overwrite ./pub/images/banner.png"
			]
			bp: panel 100x100 [
				bi: image 500x500 on-up [
					bi/image: load request-file/filter ["pics" "*.png; *jpg"]
					either heb/data [
						save %./pub/images/banner.png bi/image
					] [
						if not (exists? %./pub/images/banner.png) [
							save %./pub/images/banner.png bi/image
						]
					]
					fittopane bi (bp/size - 0x30)
				]
			]
		]
		"Terms and Conditions"[
			below
			sp: panel 590x100 [
				text 80x30 "preset"
				svl: field 300x30 "blank"
				button "load" 80x30 [
					pf: request-file/title/file/filter "load preset" %./res/ ["presets" "*.tnc"]
					loadtnc pf
					v/text: (rejoin [promotionfilename " *"])
					sp/color: none
				]
				button "save" 80x30 [
					write to-file (rejoin ["./res/preset_" svl/text ".tnc"]) tncs
					sp/color: none
				]
				return
				text 80x30 "section"
				atcl: drop-list 400x30 select 1 data tncs/thead [
					print [ "section list changed..." ]
					ocol: sp/color
					sidx: face/selected
					print [ "changing cl/text to : " tncs/ttext/:sidx ]
					cl/text: tncs/ttext/:sidx
					print [ "changed cl/text to : " cl/text ]
					tcln/text: tncs/thead/:sidx
					sp/color: ocol
				]
				pad 10x0 tcln: field 40x30 on-enter [
					print [ "tcln changed..." ]
					if (face/text <> "") and (face/text <> none) [
						tncs/thead/:sidx: face/text
						atcl/data: tncs/thead
						atcl/selected: sidx
						sp/color: 100.70.55
					]
				]
			]
			cc: panel 590x240 [
				cl: area 270x220 40.40.40 font-name "consolas" font-size 10 on-change [
					print [ "clause changed..." ]
					print [ "^-check tncs/ttext/:sidx : " tncs/ttext/:sidx ]
					ttags: reduce [ "[clientname]" (clientname/text) "[starting]" (starting/text) "[ending]" (ending/text)]
					;tncs/ttext/:sidx: face/text ;; these are entangled, possibly a bug so uncomment if its not working later
					tncs/thtml/:sidx: clauser tncs/thead/:sidx (split face/text newline) (reduce [ indents/(tta/selected) indents/(ttb/selected) indents/(ttc/selected) ttags indents/(ttd/selected) ])
					m: writesrc pname/text survey/text tncs/thtml h indents/(tta/selected)
					viewsrc/text: m
					print [ "html updated." ]
					;v/text: (rejoin [promotionfilename " *"])  ;; this breaks the event: triggers itself again with empty data
					sp/color: 100.70.55
					print [ "^-check tncs/ttext/:sidx after clauser : " tncs/ttext/:sidx ]
					clh/text: tncs/thtml/:sidx 
				]
				clh: area 270x220 30.35.40 font-name "consolas" font-size 8
			]
			tt: panel 440x180 [
				text "indent articles with"
				tta: drop-list 180x30 select 6 data indentlabels [ 
					face/text: pick face/data face/selected
					tncs/tind/1: face/selected
					;sp/color: 100.70.55
					;print [ "indent x1 tag : " indents/(face/selected) ]
				]
				return
				text "indent sections with^-"
				ttb: drop-list 180x30 select 2 data indentlabels [
					face/text: pick face/data face/selected
					tncs/tind/2: face/selected
					;sp/color: 100.70.55
					;print [ "indent x2 tag : " indents/(face/selected) ]
				]
				return
				text "indent clauses with^-^-^-"
				ttc: drop-list 180x30 select 5 data indentlabels [
					face/text: pick face/data face/selected
					tncs/tind/3: face/selected
					;sp/color: 100.70.55
					;print [ "indent x3 tag : " indents/(face/selected) ]
				]
				return
				text "indent paragraphs with^-^-^-"
				ttd: drop-list 180x30 select 1 data indentlabels [
					face/text: pick face/data face/selected
					tncs/tind/4: face/selected
					sp/color: 100.70.55
					;print [ "indent x4 tag : " indents/(face/selected) ]
				]
			]
		]
		"Review html" [
			vsp: panel [
				viewsrc: area 790x590 40.40.40 font-name "consolas" font-size 8
			]
		]
		"Upload" [

;; no ftp for Red, so make a bash cmd here and run it

		]
	]
]
print [ "OK" ]

view/flags/options v [resize] [
	menu: [
		"File" [
			"Open promotion" otp
			"Save promotion" stp
		]
	]
	actors: object [
		on-menu: func [face event] [
			probe event/picked
			switch event/picked [
				otp [ po: request-file/title/file/filter "load promotion setup" %./res/ ["promotion" "*.pro"]
					if not (none? po) [
						pset: do read po
						probe pset
						htlidx: index? (find htl/data pset/1)
						unless none? htlidx [ htl/selected: htlidx ]
						pname/text: pset/2
						clientname/text: pset/3
						starting/text: pset/4 
						ending/text: pset/5
						siteurl/text: pset/6 
						siteusr/text: pset/7 
						survey/text: pset/8 
						svl/text: pset/9
						pf: to-file (rejoin ["./res/preset_" svl/text ".tnc"])
						loadtnc pf
						promotionfilename: (rejoin ["./res/promotion_" pname/text ".pro"])
						v/text: promotionfilename
						if exists? %./pub/images/banner.png  [
							bi/image: load %./pub/images/banner.png
						]
						sp/color: none
					]
				]
				stp [
					if (none? pname/text) or (pname/text = "") [ pname/text: "untitled" ]
					pset: reduce [ htl/data/(htl/selected) pname/text clientname/text starting/text ending/text siteurl/text siteusr/text survey/text svl/text ]
					repeat st (length? pset) [ if none? pset/:st [ pset/:st: "" ]] 
					write to-file (rejoin ["./res/promotion_" (replace (trim pname/text) " " "_") ".pro"]) pset
					promotionfilename: (rejoin ["./res/promotion_" pname/text ".pro"])
					v/text: promotionfilename
					sp/color: none
				]
			]
		]
		on-resizing: function [face event][
			;face/size/x: min (max face/size/x 1024) 610
			tp/size: face/size - 20x50
			cc/size: face/size - 40x400
			sp/size/x: face/size/x - 40
			cl/size: face/size - ( to-pair reduce [ (to-integer ((cc/size/x * 0.5) + 60)) 420] )
			clh/size: cl/size
			clh/offset/x: (cl/offset/x + cl/size/x + 20)
			tcln/size/x: face/size/x - ( tcln/offset/x + 50 )
			tt/offset/y: face/size/y - 280
			vsp/size: face/size - 40x110
			viewsrc/size: face/size - 60x130
			sup/size: face/size - 40x110
			bp/size: face/size - 40x140
            fittopane bi (bp/size - 0x30)
        ]
    ]
]
