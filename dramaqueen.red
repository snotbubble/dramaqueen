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
;; [-] add banner and bg images
;; [?] add html render preview
;; [!] fix no-show of 1st t&c article
;; [ ] skip bg html if bg.png is missing, use white instead
;; [ ] upload generic html template, preset, bg and banner
;; [!] add client field to setup
;; [!] add start/end date fields to setup
;; [?] choose html template (scan res dir)
;; [ ] save/load setup fields, template & preset selection
;; [ ] allow setup field tags in t&cs
;; [!] resizable ui
;; [ ] resize limiting
;; [ ] redo preset ui if/when drop-down is fixed
;; [ ] optimize
;; [ ] redify
;; [ ] (maybe) automatically convert formatting of t&c text on drop
;; [ ] (impossible?) add ftp upload tab & params
;; [ ] (maybe) use a common markup in t&c text, probably orgmode


prin [ "loading source template..." ]
h: read %./res/template_default.html

clauser: function [t s m] [
	print [ "clauser triggered..." ]
	;print [ "^-clauser indentation = " m ]
	print [ "^-clauser strings = " s ]
	probe s

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
;; d is absolute indentation, 1 to 4, with 1 being the section headers, 2~4 for whatever is entered

		foreach line s [
			;print [ "^-checking line: " (trim line) ]
			;probe line
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
			print [ "current = " td "^/next = " d "^/offset = " ofs ]

;; tagging

			if x <= (length? tbs) [
				if ofs = 1 [
					print [ "^-next line is indented" ]
					o: rejoin[ o pws li tsx cli m/(d)/1 "^/" ]
				]
				if ofs = 2 [
					print [ "^-next line is indented by 2" ]
					o: rejoin[ o pws li tsx cli m/(d - 1)/1 "^/" pws "^-" m/(d)/1 "^/" ]
				]
				if ofs = 0 [
					print [ "^-next line is on the same level" ]
					if tsx <> "" [ o: rejoin[ o pws li tsx cli "^/" ] ]
				]
				if ofs = -1 [
					print [ "^-next line is unindented by 1" ]
					o: rejoin[ o pws li tsx cli "^/" (take/part (copy pws) (td - 2)) m/(td)/2 "^/" ]
				]
				if ofs = -2 [
					print [ "^-next line is unindented by 2" ]
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
		print o
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

sidx: 1

prin [ "writing writesrc function..." ]
writesrc: function [n s c ht i] [
	print [ "writesrc triggered..." ]
	;print [ "survey = " s ]
	probe s
	o: copy ht
	l: copy c
	g: take/last l
	;probe l
	replace o "[promotiontitle]" n
	either (none? s) or (s = "") [
		replace o "[surveyurl]" ""
	] [
		replace o "[surveyurl]" rejoin ["<div id=^"mid-container^" align=^"center^"> ^/ ^- <iframe height=^"700^" width=^"640^" frameborder=^"0^" allowtransparency=^"true^" style=^"background: #FFFFFF;^" src=^"" s "^"></iframe>^/</div>"]
	]
	replace o "[promotiontncs]" (rejoin [i/1 "^/" (rejoin l ) i/2 "^/" g])
	write %./pub/test.html o
	o
]
print [ "OK" ]

indents: [ ["<ul>" "</ul>"] ["<ol type=^"A^">" "</ol>"] ["<ol type=^"a^">" "</ol>"]  ["<ol type=^"I^">" "</ol>"] ["<ol type=^"i^">" "</ol>"] ["<ol type=^"1^">" "</ol>"] ]
indentlabels: [ "Bullet" "Uppercase letters" "Lowercase letters"  "Uppercase Roman" "Lowercase Roman" "Numbers" ]

prin [ "making the ui..." ]
v: layout [
	return
	tp: tab-panel 610x500 [
		"setup" [
			below
			panel [
				text "promotion name"
				return
				pname: field 780x30 on-change [
					u: survey/text
					n: "..."
					if pname/text <> none [ n: pname/text ]
					print [ "name changed..." ]
					m: writesrc n u tncs/thtml h indents/(tta/selected)
					viewsrc/text: m
				]
			]
			panel [
				text "site url"
				return
				siteurl: field 780x30
			]
			panel [
				text "survey url"
				return
				survey: field 780x30 on-change [
					u: survey/text
					n: "..."
					if pname/text <> none [ n: pname/text ]
					print [ "survey changed..." ]
					m: writesrc n u tncs/thtml h indents/(tta/selected)
					viewsrc/text: m
				]
			]
		]
		"source html" [
			panel [
				viewsrc: area 790x590
			]
		]
		"terms and conditions"[
			below
			sp: panel 590x100 [
				text 80x30 "preset"
				svl: field 300x30 "blank"
				;svl: drop-down 300x30 select 1 data[ "blank" ] [ 
				;	face/text: pick face/data face/selected
				;]
				button "load" 80x30 [
					pf: request-file/title/file/filter "load preset" %./res/ ["presets" "*.tnc"]
					tncs: do read pf
					tta/selected: tncs/tind/1
					ttb/selected: tncs/tind/2
					ttc/selected: tncs/tind/3
					ttd/selected: tncs/tind/4
					parse (to-string pf) [thru "preset_" copy pxn to "." ]
					svl/text: pxn
					sidx: atcl/selected 
					cl/text: (tncs/ttext/:sidx)
					u: survey/text
					n: "..."
					if pname/text <> none [ n: pname/text ]
					m: writesrc n u tncs/thtml h indents/(tncs/tind/1)
					viewsrc/text: m
				]
				button "save" 80x30 [
					write to-file (rejoin ["./res/preset_" svl/text ".tnc"]) tncs
				]
				return
				text 80x30 "section"
				atcl: drop-list 400x30 select 1 data tncs/thead [
					sidx: face/selected
					cl/text: (tncs/ttext/:sidx)
					tncs/thtml/:sidx: clauser tncs/thead/:sidx (split cl/text newline) reduce [ indents/(tta/selected) indents/(ttb/selected) indents/(ttc/selected) indents/(ttd/selected) ]
				]
				pad 10x0 tcln: field 40x30 on-enter [ 
					tncs/thead/:sidx: face/text
					atcl/data: tncs/thead
					atcl/selected: sidx
				]
			]
			;across
			;pp: panel 340x540 [ ] bcmd
			;below
			cc: panel 590x240 [
				cl: area 580x220 40.40.40 [
					tncs/ttext/:sidx: face/text
					tncs/thtml/:sidx: clauser tncs/thead/:sidx (split face/text newline) reduce [ indents/(tta/selected) indents/(ttb/selected) indents/(ttc/selected) indents/(ttd/selected) ]
					u: survey/text
					n: "..."
					if pname/text <> none [ n: pname/text ]
					print [ "clause changed..." ]
					m: writesrc n u tncs/thtml h indents/(tta/selected)
					viewsrc/text: m
				]
			]
			tt: panel 440x180 [
				text "indent articles with"
				tta: drop-list 180x30 select 6 data indentlabels [ 
					face/text: pick face/data face/selected 
					print [ "indent x1 tag : " indents/(face/selected) ]
				]
				return
				text "indent sections with^-"
				ttb: drop-list 180x30 select 2 data indentlabels [
					face/text: pick face/data face/selected 
					print [ "indent x2 tag : " indents/(face/selected) ]
				]
				return
				text "indent clauses with^-^-^-"
				ttc: drop-list 180x30 select 5 data indentlabels [
					face/text: pick face/data face/selected 
					print [ "indent x3 tag : " indents/(face/selected) ]
				]
				return
				text "indent paragraphs with^-^-^-"
				ttd: drop-list 180x30 select 1 data indentlabels [
					face/text: pick face/data face/selected 
					print [ "indent x4 tag : " indents/(face/selected) ]
				]
			]
		]
	]
]
print [ "OK" ]

view/flags/options v [resize] [
	 actors: object [
		on-resizing: function [face event][
			;face/size/x: min (max face/size/x 1024) 610
			tp/size: face/size - 20x50
			cc/size: face/size - 40x400
			sp/size/x: face/size/x - 40
			cl/size: face/size - 60x420
			tcln/size/x: face/size/x - ( tcln/offset/x + 50 )
			tt/offset/y: face/size/y - 280
        ]
    ]
]
