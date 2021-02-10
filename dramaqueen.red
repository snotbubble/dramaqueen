Red [
	needs 'view
]

;; campaign site generator. 1st draft.

;; dir/file requrements
;;  this_program
;;  ./src
;;    template_base.html
;;  ./res
;;    preset_blank.pxx
;;  ./pub
;;    /fonts
;;    /images
;;      bg.jpg
;;      banner.png

;; template html keys
;; [surveyurl]
;; [promotiontitle]
;; [promotiontncs]

;; TODO
;; [X] make html template
;; [X] add minimal set of setup fields
;; [ ] add html source preview
;; [ ] (maybe) add banner and bg images
;; [ ] (impossible?) add html render preview
;; [X] t&c builder interface
;; [X] t&c to html function
;; [X] use common legal document structure names for t&cs
;; [X] t&c indentation params
;; [X] save and load t&cs
;; [ ] strip dash prefixes from t&c text
;; [ ] load saved t&c indentation markers
;; [ ] fix no-show of 1st t&c article
;; [ ] skip t&c article if nothing is in it
;; [ ] upload generic html template, preset, bg and banner
;; [ ] add client field to setup
;; [ ] add start/end date fields to setup
;; [ ] save/load all fields except t&cs (load chosen t&c preset instead)
;; [ ] embed setup field tags in t&cs
;; [-] resizable ui
;; [ ] resize limiting
;; [ ] redo preset ui if/when drop-down is fixed
;; [ ] (maybe) automatically convert formatting of t&c text on drop
;; [ ] (impossible?) add ftp upload tab & params
;; [ ] (maybe) use markup in t&c text, probably orgmode-compatible

prin [ "loading source template..." ]
h: read %./src/base_template.html
;print h
print [ "OK" ]

prin [ "writing clauser function..." ]
clauser: function [t s m] [
	print [ "clauser triggered..." ]
	o: rejoin ["<li>" t "</li>" m/2/1 "^/"]
	c: 1
	d: 0
	tbs: copy []
	j: #"-"
	;probe s
	;print [ "s=" s ]
	;print [ "length =" (length? s) ]
	either (length? s) > 1 [
		foreach line s [
			;print [ "	line: " line ]
			either (line/1 = j) [
				d: 1
				if (line/2 = j) [ d: 2 ]
			] [
				if ((trim line) <> "") [ d: 0] 
			]
			append tbs d
		]
		;probe tbs
		
		repeat x (length? tbs) [
			g: max 0 (min (x + 1) (length? tbs))
			od: tbs/:g
			td: tbs/:x
			ofs: od - td
			d: d + ofs
			;print [ "ofs=" ofs " td=" td " depth=" d ]
			if x <= (length? tbs) [ 
				if ofs = 1 [
					either d = 2 [
						o: rejoin[ o "<li>" s/:x "</li>" m/4/1 "^/" ]
					] [
						o: rejoin[ o "<li>" s/:x "</li>" m/3/1 "^/" ]
					]
				]
				if ofs = 0 [
					;print [ "s/:x = " s/:x ]
					if (trim s/:x) <> "" [
						o: rejoin[ o "<li>" s/:x "</li>^/" ]
					]
				]
				if ofs = -1 [
					o: rejoin[ o "<li>" s/:x "</li>"m/3/2"^/" ]
				]
				if ofs = -2 [
					o: rejoin[ o "<li>" s/:x "</li>"m/3/2 m/3/2"^/" ]
				]
			]
		]
	] [ 
		;print [ "single section = " s ]
		if (trim s) <> "" [ o: rejoin[ o "<li>" s/1 "</li>^/" ] ]
	]
	append o m/2/2
	;print o
	o
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

;prin [ "generating clause toggles..." ]
;bcmd: []
;repeat x length? tncs/thead [ 
;	append bcmd  compose/deep [ base 320x30 (tncs/thead/:x) [ foreach-face v [ if face/type = 'base [ face/color: gray ] ] face/color:papaya sidx: (:x) cl/text: (tncs/ttext/:x) ] return ]
;]
;print [ "OK" ]

prin [ "writing writesrc function..." ]
writesrc: function [n s c ht i] [
	print [ "writesrc triggered..." ]
	o: copy ht
	l: copy c
	g: take/last l
	;probe l
	replace o "[promotiontitle]" n
	replace o "[surveyurl]" s
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
					u: "..."
					if survey/text <> none [ u: survey/text ]
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
					u: "..."
					if survey/text <> none [ u: survey/text ]
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
					pf: request-file/title/file/filter "load preset" %./res/ ["presets" "*.pxx"]
					tncs: do read pf
					parse (to-string pf) [thru "preset_" copy pxn to "." ]
					svl/text: pxn
					sidx: atcl/selected cl/text: (tncs/ttext/:sidx)
				]
				button "save" 80x30 [
					write to-file (rejoin ["./res/preset_" svl/text ".pxx"]) tncs
				]
				return
				text 80x30 "section"
				atcl: drop-list 300x30 select 1 data tncs/thead [
					sidx: face/selected cl/text: (tncs/ttext/:sidx)
				]
			]
			;across
			;pp: panel 340x540 [ ] bcmd
			;below
			cc: panel 590x240 [
				cl: area 580x220 40.40.40 [
					tncs/ttext/:sidx: face/text
					tncs/thtml/:sidx: clauser tncs/thead/:sidx (split face/text newline) reduce [ indents/(tta/selected) indents/(ttb/selected) indents/(ttc/selected) indents/(ttd/selected) ]
					u: "..."
					if survey/text <> none [ u: survey/text ]
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
					print [ indents/(face/selected) ]
				]
				return
				text "indent sections with^-"
				ttb: drop-list 180x30 select 2 data indentlabels [
					face/text: pick face/data face/selected 
					print [ indents/(face/selected) ]
				]
				return
				text "indent clauses with^-^-^-"
				ttc: drop-list 180x30 select 5 data indentlabels [
					face/text: pick face/data face/selected 
					print [ indents/(face/selected) ]
				]
				return
				text "indent paragraphs with^-^-^-"
				ttd: drop-list 180x30 select 1 data indentlabels [
					face/text: pick face/data face/selected 
					print [ indents/(face/selected) ]
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
			cl/size: face/size - 60x420
			tt/offset/y: face/size/y - 280
        ]
    ]
]
