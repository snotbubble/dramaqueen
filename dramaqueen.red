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
;; [?] (onerous - merge seperate project) add html render preview... test html to draw, might not be possible
;; [!] upload generic html template, preset, bg and banner to github
;; [ ] move indentation lists to pop-menus if possible
;; [ ] add pre-existing indentation checks to clauser
;; [!] make AUS redemption boilerplate T&Cs
;; [!] make AUS competition boilerplate T&Cs
;; [!] make AUS bonus-offer boilerplate T&Cs
;; [!] make NZ redemption boilerplate T&Cs
;; [!] make NZ competition boilerplate T&Cs
;; [!] make NZ bonus-offer boilerplate T&Cs
;; [ ] check and download templates on startup
;; [ ] (onerous - merge separate project) add option rip tncs directly from source pdf and docx files
;; [!] add menu option to show/hide eval buttons, set to hidden by default
;; [?] fix tab-panel size vs menu
;; [?] resizable ui
;; [?] resize limiting
;; [?] redo preset ui if/when drop-down is fixed
;; [ ] icons
;; [ ] (maybe) help menu item spawns help window with usage.md
;; [ ] optimize
;; [ ] redify
;; [ ] remove console spammage
;; [ ] compile & test on other machines
;; [ ] hose everything and redesign.

noupdate: true

prin "loading source template..."
h: read %./res/template_default.html
print "OK"

;; display tile only, not used for anything else
promotionfilename: "DramaQueen"

prin "writing clauser function..."
clauser: function [ t s m u tabi tby ] [
	prin [ tabi "clauser function triggered by " tby "..." ]
	;print [ "^-clauser indentation = " m ]
	;print [ "^-clauser strings = " s ]
	;probe s

;; skip if empty

	either ((length? s) = 1) and (s/1 = "") [
		print [ "skipping empty section (" t ")" ]
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
				;print [ "clauser: replacing article tag" reduce u/:fx "with" reduce u/(fx + 1) ]
				unless none? u/(fx + 1) [ o: replace/all o reduce u/:fx reduce u/(fx + 1) ]
			]
		]
		print [ "OK" ]
		;print o
		return o
	]
]
print "OK"


;; terms and conditions data: section names, section text, section html, indentation rules

tncs: context [
	thead: ["GENERAL CONDITIONS" "PROMOTER" "PROMOTION PERIOD" "REDEMPTION OFFER" "APPLICABLE PRODUCTS" "EXCLUDED PRODUCTS" "HOW TO REDEEM" "DELIVERY" "DISCLAIMER AND RIGHTS OF THE PROMOTER" "PERSONAL INFORMATION" "LIABILITY" "GOVERNING LAW"]

	ttext: ["GENERAL CONDITIONS" "PROMOTER" "PROMOTION PERIOD" "REDEMPTION OFFER" "APPLICABLE PRODUCTS" "EXCLUDED PRODUCTS" "HOW TO REDEEM" "DELIVERY" "DISCLAIMER AND RIGHTS OF THE PROMOTER" "PERSONAL INFORMATION" "LIABILITY" "GOVERNING LAW"]

	thtml: ["<li>GENERAL CONDITIONS</li>" "<li>PROMOTER</li>" "<li>PROMOTION PERIOD</li>" "<li>REDEMPTION OFFER</li>" "<li>APPLICABLE PRODUCTS</li>" "<li>EXCLUDED PRODUCTS</li>" "<li>HOW TO REDEEM</li>" "<li>DELIVERY</li>" "<li>DISCLAIMER AND RIGHTS OF THE PROMOTER</li>" "<li>PERSONAL INFORMATION</li>" "<li>LIABILITY</li>" "GOVERNING LAW"]

	tind: [ 6 2 5 1 ] 
]

;; promotion data =
;; promotion_name client_name start_date end_date site_url site_user survey_url tnc_preset

pset: [ "" "" "" "" "" "" "" "" "" "blank" ]

sidx: 1

prin "writing writesrc function..."
writesrc: function [n s c ht i u tabi tby ] [
	print [ tabi "writesrc function triggered by " tby "..." ]
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
	unless (exists? %./pub/images/bg.png) [
		replace o "background:url(./images/bg.jpg) no-repeat center center fixed;background-size:cover;" ""
	]
	either (none? s) or (s = "") [
		replace o "[surveyurl]" ""
	] [
		replace o "[surveyurl]" (rejoin ["<div id=^"mid-container^" align=^"center^"> ^/ ^- <iframe height=^"700^" width=^"640^" frameborder=^"0^" allowtransparency=^"true^" style=^"background: #FFFFFF;^" src=^"" s "^"></iframe>^/</div>"])
	]
	replace o "[promotiontncs]" (rejoin [i/1 "^/" (rejoin l ) i/2 "^/" g])

;; replace tnc tags with setup field vals

	repeat fx ((length? u) - 1) [
		if fx % 2 = 1 [
			unless none? u/(fx + 1) [ o: replace/all o reduce u/:fx reduce u/(fx + 1) ]
		]
	]
	print [ tabi "^-wrtesrc is writing the html file: ./pub/test.html" ]
	write %./pub/test.html o
	print [ tabi "wrtesrc function is done."]
	o
]
print "OK"

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
print "OK"

prin "writing loadtnc func..."
loadtnc: func [ presetfile tabi tby ] [
	print [ tabi "loadtnc func triggered by " tby "..." ]
	either not (none? presetfile) [
		either exists? presetfile [
			print [ tabi "^-loadtnc is opening tncs from file..." ]
			noupdate: true
			clear tncs/thead
			clear tncs/ttext
			clear tncs/thtml
			tncs: do read presetfile
			print [ tabi "^-loadtnc is changing tnc indent lists..." ]
			tta/selected: tncs/tind/1
			ttb/selected: tncs/tind/2
			ttc/selected: tncs/tind/3
			ttd/selected: tncs/tind/4
			parse (to-string presetfile) [thru "preset_" copy pxn to "." ]
			print [ tabi "^-loadtnc func is changing tnc section list..." ]
			sidx: 1
			tncseclst/data: tncs/thead
			tncseclst/selected: 1
			print [ tabi "^-loadtnc func is changing tnc preset name..." ]
			tncpretxt/text: pxn
			print [ tabi "^-loadtnc func is changing tnc section name..." ]
			tncsectxt/text: tncs/thead/1
			print [ tabi "^-loadtnc func is changing tnc section article..." ]
			cl/text: tncs/ttext/1
			print [ tabi "^-loadtnc func is changing tnc section html preview..." ]
			clh/text: tncs/thtml/:sidx
			n: "..."
			if pname/text <> none [ n: pname/text ]
			ttags: reduce [ "[clientname]" (clientname/text) "[starting]" (starting/text) "[ending]" (ending/text)]
			print [ tabi "^-loadtnc func is changing the html source..." ]
			m: writesrc n survey/text tncs/thtml h indents/(tncs/tind/1) ttags rejoin [ tabi "^-^-"] "loadtnc"
			viewsrc/text: m
		] [ print [ tabi "^-loadtnc can't find preset file: " presetfile ] ]
	] [ print [ tabi "^-loadtnc presetfile arg is set to " presetfile ] ]
	print [ tabi "loadtnc function is done." ]
]
print "OK"

prin "writing updatehtml func..."
updatehtml: func [ t tabi tby ] [
	print [ tabi "updatehtml func triggered by " tby "..." ]
	if (t <> none) [
		print [ tabi "^-updatehtml changed text is: " t ]
		noupdate: true
		ttags: reduce [ "[clientname]" (clientname/text) "[starting]" (starting/text) "[ending]" (ending/text)]
		repeat th (length? tncs/thtml) [
			tncs/thtml/:th: clauser tncs/thead/:th (split tncs/ttext/:th newline) (reduce [ indents/(tta/selected) indents/(ttb/selected) indents/(ttc/selected) indents/(ttd/selected) ]) ttags rejoin [ tabi "^-^-" ] "updatehtml"
		]
		print [ tabi "^-updatehtml is changing html source..." ]
		m: writesrc pname/text survey/text tncs/thtml h indents/(tta/selected) ttags rejoin [ tabi "^-^-" ] "updatehtml"
		viewsrc/text: m
		print [ tabi "^-updatehtml is changing tnc article html preview..." ]
		clh/text: tncs/thtml/:sidx
		noupdate: false
	]
	print [ tabi "updatehtml func is done." ]
]
print "OK"

hidx: 1
pidx: 0

prin "making the ui..."
v: layout [
	title promotionfilename
	tp: tab-panel 800x800 [
		"Setup" [
			below
			pro: panel 780x100 [
				text 230x30 "campaign project"
				pol: drop-list 520x30 data (collect [foreach file read %./res/ [ if (parse (to-string file) [ "promotion_" thru ".pro"]) [keep (to-string file)] ]]) [
					unless face/selected = pidx [
						print "pol list change is loading project settings..."
						po: (to-file rejoin [ "./res/" face/data/(face/selected) ])
						if exists? po [
							noupdate: true
							pset: do read po
							print "^-pol list is changing the html template field..."
							htlidx: index? (find htl/data pset/1)
							unless none? htlidx [ htl/selected: htlidx ]
							print "^-pol list is changing the promotion name field..."
							pname/text: pset/2
							print "^-pol list is changing the clientname field..."
							clientname/text: pset/3
							print "^-pol list is changing the starting field..."
							starting/text: pset/4 
							print "^-pol list is changing the ending field..."
							ending/text: pset/5
							print "^-pol list is changing the siteurl field..."
							siteurl/text: pset/6
							print "^-pol list is changing the sitedir field..."
							sitedir/text: pset/7
							print "^-pol list is changing the siteusr field..."
							siteusr/text: pset/8 
							print "^-pol list is changing the survey field..."
							survey/text: pset/9
							print "^-pol list is changing the tnc preset name field..."
							tncpretxt/text: pset/10
							pf: to-file (rejoin ["./res/preset_" tncpretxt/text ".tnc"])
							print "^-pol list is loading tncs..."
							loadtnc pf "^-^-" "pol_list"
							noupdate: true
							print "^-pol list is changing the promotion name..."
							promotionfilename: (rejoin ["./res/promotion_" pname/text ".pro"])
							v/text: promotionfilename
							print "^-pol list is changing the banner image..."
							if exists? %./pub/images/banner.png  [
								bi/image: load %./pub/images/banner.png
								fittopane bi (bp/size - 0x30)
							]
							sp/color: none
							noupdate: false
							pidx: face/selected
						]
						print "pol list change event is done.^/" 
					]
				]
				return
				pad 240x0
				pname: field 430x30 on-change [
					print [ "name changed..." ]
					if (face/text <> "") and (face/text <> none) [
						unless noupdate [
							noupdate: true
							ttags: reduce [ "[clientname]" (clientname/text) "[starting]" (starting/text) "[ending]" (ending/text)]
							m: writesrc pname/text survey/text tncs/thtml h indents/(tta/selected) ttags "^-" "pname"
							viewsrc/text: m
							v/text: (rejoin [promotionfilename " *"])
							noupdate: false
						]
					]
				]
				button 80x30 "save" [
					if (none? pname/text) or (pname/text = "") [ pname/text: "untitled" ]
					pset: reduce [ htl/data/(htl/selected) pname/text clientname/text starting/text ending/text siteurl/text sitedir/text siteusr/text survey/text tncpretxt/text ]
					repeat st (length? pset) [ if none? pset/:st [ pset/:st: "" ]] 
					write to-file (rejoin ["./res/promotion_" (replace (trim pname/text) " " "_") ".pro"]) pset
					promotionfilename: (rejoin ["./res/promotion_" pname/text ".pro"])
					noupdate: true
					v/text: promotionfilename
					sp/color: none
					pol/data: (collect [foreach file read %./res/ [ if (parse (to-string file) [ "promotion_" thru ".pro"]) [keep (to-string file)] ]])
					pol/selected: index? find pol/data rejoin [ "promotion_" pname/text ".pro" ]
					noupdate: false
				]
			]
			sup: panel 780x630 [
				text 230x30 "html template"
				htl: drop-list 520x30 select 1 data (collect [foreach file read %./res/ [ if (parse (to-string file) ["template_" thru ".html"]) [keep (to-string file)] ]]) [
					unless face/selected = hidx [
						print "html template list event triggered..."
						unless noupdate [
							noupdate: true
							h: read (to-file rejoin [ "./res/" face/data/(face/selected) ])
							ttags: reduce [ "[clientname]" (clientname/text) "[starting]" (starting/text) "[ending]" (ending/text)]
							m: writesrc pname/text survey/text tncs/thtml h indents/(tta/selected) ttags "^-" "html_template_list"
							viewsrc/text: m
							v/text: (rejoin [promotionfilename " *"])
							noupdate: false
						]
						hidx: face/selected
						print "html template list event done.^/" 
					]
				]
				return
				text 230x30 "client name"
				clientname: field 520x30 on-change [
					unless noupdate [
						print "clientname field event triggered..."
						updatehtml face/text "^-" "clientname"
						v/text: (rejoin [promotionfilename " *"])
					]
				]
				return
				text 230x30 "promotion start (dd-mm-yyyy)"
				starting: field 520x30 on-change [
					unless noupdate [
						print "starting field event triggered..."
						updatehtml face/text "^-" "starting"
						v/text: (rejoin [promotionfilename " *"])
					]
				]
				return
				text 230x30 "promotion end (dd-mm-yyyy)"
				ending: field 520x30 on-change [
					unless noupdate [
						print "ending field event triggered..."
						updatehtml face/text "^-" "ending"
						v/text: (rejoin [promotionfilename " *"])
					]
				]
				return
				text 230x30 "site url (full url)"
				siteurl: field 520x30 on-change [
					unless noupdate [ v/text: (rejoin [promotionfilename " *"]) ]
				]
				return
				text 230x30 "campaign directory name"
				sitedir: field 520x30 on-change [
					unless noupdate [ v/text: (rejoin [promotionfilename " *"]) ]
				]
				return
				text 230x30 "site username"
				siteusr: field 520x30 on-change [
					unless noupdate [ v/text: (rejoin [promotionfilename " *"]) ]
				]
				return
				text 230x30 "survey url"
				survey: field 520x30 on-change [
					unless noupdate [
						print "survey field event triggered..."
						updatehtml face/text "^-" "survey" 
						v/text: (rejoin [promotionfilename " *"])
					]
				]
			]
		]
		"Banner image" [
			below
			bpp: panel 780x50 [
				text "click below to source banner image"
				heb: check true "overwrite ./pub/images/banner.png"
			]
			bp: panel 780x680 [
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
			sp: panel 780x100 [
				text 80x30 "preset"
				tncpretxt: field 300x30 "blank"
				button "load" 80x30 [
					pf: request-file/title/file/filter "load preset" %./res/ ["presets" "*.tnc"]
					loadtnc pf
					v/text: (rejoin [promotionfilename " *"])
					sp/color: none
				]
				button "save" 80x30 [
					write to-file (rejoin ["./res/preset_" tncpretxt/text ".tnc"]) tncs
					sp/color: none
				]
				return
				text 80x30 "section"
				tncseclst: drop-list 400x30 select 1 data tncs/thead [
					unless noupdate [
						print "tnc section list changed..."
						noupdate: true
						ocol: sp/color
						sidx: face/selected
						print [ "^-section list is changing cl/text... " ]
						cl/text: tncs/ttext/:sidx
						print [ "^-section list is changing clh/text... " ]
						clh/text: tncs/thtml/:sidx
						tncsectxt/text: tncs/thead/:sidx
						sp/color: ocol
						noupdate: false
						print "tnc section list event is done.^/"
					]
				]
				tncsectxt: field 260x30 with [ text: tncs/thead/1 ] on-enter [
					print [ "tncsectxt changed..." ]
					if (face/text <> "") and (face/text <> none) [
						noupdate: true
						tncs/thead/:sidx: face/text
						tncseclst/data: tncs/thead
						tncseclst/selected: sidx
						sp/color: 100.70.55
						noupdate: false
					]
				]
			]
			across
			cc: panel 370x630 [
				below
				text 80x20 "text"
				cl: area 350x580 40.40.40 font-name "consolas" font-size 10 font-color 255.255.180 with [ text: tncs/ttext/1 ] on-change [
					print "cl text has changed..."
					either (face/text <> none) and (face/text <> "") [
						unless noupdate [
							noupdate: true
							ttags: reduce [ "[clientname]" (clientname/text) "[starting]" (starting/text) "[ending]" (ending/text)]
							tncs/thtml/:sidx: clauser tncs/thead/:sidx (split face/text newline) (reduce [ indents/(tta/selected) indents/(ttb/selected) indents/(ttc/selected) indents/(ttd/selected) ]) ttags "^-" "cl_text"
							print "^-cl text is updating html source..."
							m: writesrc pname/text survey/text tncs/thtml h indents/(tta/selected) ttags "^-" "cl_text"
							viewsrc/text: m
							print [ "^-cl is changing clh/text... " ] 
							clh/text: tncs/thtml/:sidx
							v/text: (rejoin [promotionfilename " *"])
							sp/color: 100.70.55
							noupdate: false
							print "cl text event is done.^/"
						]
					] [
						clh/text: ""
					]
				]
			]
			tt: panel 400x630 [
				below
				text 120x20 "html preview"
				clh: area 380x220 30.35.40 font-name "consolas" font-size 8 font-color 80.255.80
				text "indent articles with"
				tta: drop-list 180x30 select 6 data indentlabels [
					print [ "tta change event triggered..." ]
					face/text: pick face/data face/selected
					tncs/tind/1: face/selected
					unless noupdate [
						print [ "^-tta is updating all html..." ]
						updatehtml face/text "^-" "tta"
						sp/color: 100.70.55
					]
					print [ "tta change event is done.^/" ]
				]
				text "indent sections with"
				ttb: drop-list 180x30 select 2 data indentlabels [
					print [ "ttb change event triggered..." ]
					face/text: pick face/data face/selected
					tncs/tind/2: face/selected
					unless noupdate [
						print [ "^-ttb is updating all html..." ]
						updatehtml face/text "^-^-" "ttb"
						sp/color: 100.70.55
					]
					print [ "ttb change event is done.^/" ]
				]
				text "indent clauses with"
				ttc: drop-list 180x30 select 5 data indentlabels [
					print [ "ttc change event triggered..." ]
					face/text: pick face/data face/selected
					tncs/tind/3: face/selected
					unless noupdate [
						print [ "^-ttc is updating all html..." ]
						updatehtml face/text "^-" "ttc"
						sp/color: 100.70.55
					]
					print [ "ttc change event is done.^/" ]
				]
				text "indent paragraphs with"
				ttd: drop-list 180x30 select 1 data indentlabels [
					print [ "ttd change event triggered..." ]
					face/text: pick face/data face/selected
					tncs/tind/4: face/selected
					unless noupdate [
						print [ "^-ttd is updating all html..." ]
						updatehtml face/text "^-" "ttd"
						sp/color: 100.70.55
					]
					print [ "ttd change event is done.^/" ]
				]
			]
		]
		"Review html" [
			vsp: panel 780x740 [
				viewsrc: area 760x720 40.40.40 font-name "consolas" font-size 8
			]
		]
		"Upload" [
			below
			uu: panel 780x50 [
				button 200x30 "check rebol bridge" [
					either (siteurl/text <> "") and (siteurl/text <> none) and (siteusr/text <> "") and (siteusr/text <> none) and (sitedir/text <> "") and (sitedir/text <> none) [
						kh: copy []
						kw: copy []
						ph: mold checksum rejoin [ siteurl/text sitedir/text ] 'sha1
						repeat x (length? woh/text) [ append kw ((to-integer ph/:x) + (to-integer woh/text/:x)) ]
						probe rejoin ["./rebol upload.r [ " siteurl/text " " sitedir/text " " siteusr/text " [" kw "] %./index.html %./pub/fonts/font.ttf %./pub/fonts/font.wotf %./pub/images/banner.png %./pub/images/bg.png]"]
						huh: ""
						call/wait/output rejoin ["./rebol upload.r [ " siteurl/text " " sitedir/text " " siteusr/text " [" kw "] %./index.html %./pub/fonts/font.ttf %./pub/fonts/font.wotf %./pub/images/banner.png %./pub/images/bg.png]"] huh
						parse huh [remove thru "(none)" ]
						co/text: huh
						either exists? %./log.txt [ lo/text: read %./log.txt ] [ lo/text: "upload script failed" ]
					] [
						lo/text: "setup not completed yet..."
						co/text: ""
					]
				]
				pad 10x0 text "password"
				woh: field 120x30 with [flags: 'password]
				pad 10x0 button 80x30 "clear" [ woh/text: none ]
			]
			oo: panel 780x620 [
				below
				lol: text 80x20 "console"
				lo: area 760x330 40.40.40 font-name "consolas" font-size 10 font-color 255.120.50 bold
				col: text 80x20 "output"
				co: area 760x200 30.35.40 font-name "consolas" font-size 10 font-color 80.180.255 bold
			]
			ff: panel 780x50 [
				button 120x30 "eval REBOL" [
					rebo: copy ""
					co/text: ""
					co/font/color: 80.180.255
					rebs: rejoin [ "REBOL [ ]^/" lo/text ]
					;print rebs
					write %./res/temp.r rebs
					;print rejoin ["./rebol ./res/temp.r" ]
					call/wait/output rejoin ["./rebol ./res/temp.r" ] rebo
					delete %./res/temp.r
					parse rebo [remove thru {(none)^/} ]
					co/text: rebo
				]
				button 120x30 "eval RED" [
					redo: copy ""
					co/text: ""
					co/font/color: 255.80.80
					reds: rejoin [ {Red [ ] ^/} lo/text ]
					;print reds
					write %./res/temp.red reds
					;print rejoin ["./red-latest ./res/temp.red" ]
					call/wait/output rejoin ["./red-latest ./res/temp.red" ] redo
					delete %./res/temp.red
					co/text: redo
				]
				button 120x30 "clear output" [ co/text: "" ]
			]
		]
	]
]
print "OK"

view/flags/options v [] [
;	actors: object [
;		on-resizing: function [face event][
;			tp/size: face/size - 20x20
;			sup/size: face/size - 40x190
;			cc/size: tp/size - ( to-pair reduce [ (tt/size/x + 20) (sp/offset/y + sp/size/y + 30)] )
;			tt/size/y: cc/size/y
;			tt/offset/x: face/size/x - (tt/size/x + 30)
;			oo/size: face/size - 40x190
;			uu/size/x: oo/size/x
;			ff/size/x: oo/size/x
;			ff/offset/y: face/size/y - 120
;			sp/size/x: face/size/x - 40
;			cl/size: cc/size - 20x50
;			clh/size/x: tt/size/x - 20
;			tncsectxt/size/x: face/size/x - ( tncsectxt/offset/x + 50 )
;			lo/size: oo/size - 20x300
;			co/size/x: lo/size/x
;			co/offset/y: oo/size/y - 210
;			col/offset/y: oo/size/y - 240
;			bp/size: face/size - 40x140
;			vsp/size: face/size - 40x80
;			viewsrc/size: vsp/size - 20x20
;			fittopane bi (bp/size)
;		]
;	]
]
