REBOL [
	Title: dq_upload
]

;; made for dramaqueen site generator
;; for unsecure ftp (classic australian security), 
;; sftp will probably be done separately in c or something.
;; pwd uses a simple substitution cipher while in transit from red to rebol, 
;; to prevent it from showing up somewhere else (like in ps for example).
;; dont yet know if red or rebol logs it though.

nargs: do system/script/args
probe nargs

site: nargs/1 ; base site
sdir: nargs/2 ; new dir name
fusr: nargs/3 ; user name
fphs: nargs/4 ; hashed hash
lidx: nargs/5 ; local index
lttf: nargs/6 ; local ttf font
lwtf: nargs/7 ; local wotf font
lban: nargs/8 ; local banner
lbkg: nargs/9 ; local bg image

log: %./log.txt
if exists? log  [ delete log ]
;write/append log nargs

write/append log rejoin [ "site is.................. : " site "^/" ]
write/append log rejoin [ "new dir is............... : " sdir "^/" ] 
write/append log rejoin [ "username is.............. : " fusr "^/" ]
write/append log rejoin [ "woah is.................. : " fphs "^/" ]
write/append log rejoin [ "local index to upload.... : " lidx "^/" ]
write/append log rejoin [ "local ttf font to upload. : " lttf "^/" ]
write/append log rejoin [ "local wotf font to upload : " lwtf "^/" ]
write/append log rejoin [ "local banner to upload... : " lban "^/" ]
write/append log rejoin [ "local bg image to upload. : " lbkg "^/^/" ]

ph: mold checksum/secure rejoin [ to-string site to-string sdir ]
rw: copy []
repeat x (length? fphs) [ append rw to-char ((to-integer fphs/:x) - (to-integer ph/:x)) ]
pass: to-string rejoin rw

parse site [ thru "www." copy dom to end ]

write/append log rejoin [ "checking site: " site "/index.html^/" ]
either exists? (to-url rejoin [ site "/index.html" ]) [
	either (pass <> none) and (pass <> "") [

		write/append log rejoin [ "^-making site dir: " site "/" sdir "/" "^/" ]
		make-dir (to-url rejoin [ "ftp://" fusr ":" pass "@ftp." dom "/" sdir "/" ])
		
		write/append log rejoin [ "^-making site dir: " site "/" sdir "/fonts/" "^/" ]
		make-dir (to-url rejoin [ "ftp://" fusr ":" pass "@ftp." dom "/" sdir "/fonts/" ])
		
		write/append log rejoin [ "^-making site dir: " site "/" sdir "/images/" "^/" ]
		make-dir (to-url rejoin [ "ftp://" fusr ":" pass "@ftp." dom "/" sdir "/images/" ])
		
		write/append log rejoin [ "copying index to: " site "/" sdir "/index.html" "^/" ]
		write/binary (to-url rejoin ["ftp://" fusr ":" pass "@ftp." dom "/" sdir "/index.html"]) read/binary lidx
		
		write/append log rejoin [ "copying ttf font to: " site "/" sdir "/fonts/ from " lttf "^/" ]
		write/binary (to-url rejoin ["ftp://" fusr ":" pass "@ftp." dom "/" sdir "/fonts/font.ttf"]) read/binary lttf
		
		write/append log rejoin [ "copying wotf font to: " site "/" sdir "/fonts/ from " lwtf "^/" ]
		write/binary (to-url rejoin ["ftp://" fusr ":" pass "@ftp." dom "/" sdir "/fonts/font.wotf"]) read/binary lwtf
		
		write/append log rejoin compose [ "does the banner exist? :" (exists? lban) "^/" ]
		if exists? lban [
			write/append log rejoin [ "^-copying banner to: " site "/" sdir "/images/ from " lban "^/" ]
			write/binary (to-url rejoin ["ftp://" fusr ":" pass "@ftp." dom "/" sdir "/images/banner.png"]) read/binary lban 
		]
		
		write/append log rejoin compose [ "does the bg image exist? :" (exists? lbkg) "^/" ]
		if exists? lbkg [
			write/append log rejoin [ "^-copying bg image to: " site "/" sdir "/images/ from " lbkg "^/" ]
			write/binary (to-url rejoin [ "ftp://" fusr ":" pass "@ftp." dom "/" sdir "/images/bg.png" ]) read/binary lbkg 
		]
	] [
		write/append log rejoin [ "invalid password for user: " fusr "^/" ] 
	]
] [ write/append log rejoin [ "site index not found, aborting: " site "/index.html^/" ] ]
