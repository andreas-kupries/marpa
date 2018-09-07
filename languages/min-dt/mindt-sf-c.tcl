# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017-present Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                             http://core.tcl.tk/akupries/
##
# (c) 2018 Grammar mindt::parser::sf::c 0 By Andreas Kupries
##
##	`marpa::runtime::c`-derived Parser for grammar "mindt::parser::sf::c".
##	Generated On Fri Sep 07 15:24:36 PDT 2018
##		  By andreask@ten
##		 Via remeta
##
#* Space taken: 5800 bytes
##
#* Statistics
#* L0
#* - #Symbols:   338
#* - #Lexemes:   10
#* - #Discards:  0
#* - #Always:    0
#* - #Rule Insn: 124 (+2: setup, start-sym)
#* - #Rules:     524 (>= insn, brange)
#* G1
#* - #Symbols:   30
#* - #Rule Insn: 37 (+2: setup, start-sym)
#* - #Rules:     37 (match insn)

package provide mindt::parser::sf::c 0

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5 ;# apply, lassign, ...
package require critcl 3.1

critcl::buildrequirement {
    package require critcl::class
    package require critcl::cutil
}

if {![critcl::compiling]} {
    error "Unable to build mindt::parser::sf::c, no compiler found."
}

critcl::cutil::alloc
critcl::cutil::assertions on
critcl::cutil::tracer     on

critcl::debug symbols
#critcl::debug memory
#critcl::debug symbols memory

# # ## ### ##### ######## ############# #####################
## Requirements

critcl::api import marpa::runtime::c 0
critcl::api import critcl::callback  1

# # ## ### ##### ######## ############# #####################
## Static data structures declaring the grammar

critcl::ccode {
    /*
    ** Shared string pool (694 bytes lengths over 347 entries)
    **                    (694 bytes offsets -----^)
    **                    (1968 bytes character content)
    */

    static marpatcl_rtc_size mindt_parser_sf_c_pool_length [347] = { /* 694 bytes */
	 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
	 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  9,  5,  5,  8,
	 6,  9, 10, 11, 11, 11, 11, 11, 11,  6, 21, 18, 10,  7,  8,  8,
	 2,  2,  2,  2,  2,  2,  2,  3,  3,  3,  3,  3,  3,  3,  3,  3,
	 3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,
	 3,  4,  4,  8,  8,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  2,  2,  4,  2,  1,  1,  1,  1,
	 1, 12,  1,  1,  2,  2, 13,  6,  6,  6, 11, 12, 13, 14, 14,  1,
	 1,  2,  7,  7,  7, 12,  2,  1,  1,  1,  1,  1,  1,  4,  1,  1,
	 1,  1,  1,  1, 14, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
	16, 16, 16, 16, 16, 16,  7,  7,  7,  1,  1,  1,  1,  1,  1,  1,
	 1,  1,  1,  7,  7, 12, 16,  1,  1,  1,  1,  4,  1,  1,  6,  6,
	 5,  5,  5,  6,  6, 11, 12,  1,  1,  7,  1,  1,  6,  6,  6,  5,
	 5,  5,  6,  6,  5,  4,  1,  1,  1,  1,  6,  8, 13,  7,  7,  7,
	 1,  1,  5,  7,  7,  7,  4,  4,  4,  4,  1,  1,  5,  5,  6,  6,
	 4,  4,  6,  1,  1,  1,  1,  1,  1,  1,  1
    };

    static marpatcl_rtc_size mindt_parser_sf_c_pool_offset [347] = { /* 694 bytes */
	   0,    2,    4,    6,    8,   10,   12,   14,   16,   18,   20,   22,   24,   26,   28,   30,
	  32,   34,   36,   38,   40,   42,   44,   46,   48,   50,   52,   54,   56,   66,   72,   78,
	  87,   94,  104,  115,  127,  139,  151,  163,  175,  187,  194,  216,  235,  246,  254,  263,
	 272,  275,  278,  281,  284,  287,  290,  293,  297,  301,  305,  309,  313,  317,  321,  325,
	 329,  333,  337,  341,  345,  349,  353,  357,  361,  365,  369,  373,  377,  381,  385,  389,
	 393,  397,  402,  407,  416,  425,  430,  435,  440,  445,  450,  455,  460,  465,  470,  475,
	 480,  485,  490,  495,  500,  505,  510,  515,  520,  525,  530,  535,  540,  545,  550,  555,
	 560,  565,  570,  575,  580,  585,  590,  595,  600,  605,  610,  615,  620,  625,  630,  635,
	 640,  645,  650,  655,  660,  665,  670,  675,  680,  685,  690,  695,  700,  705,  710,  715,
	 720,  725,  730,  735,  740,  745,  750,  755,  760,  765,  770,  775,  780,  785,  790,  795,
	 800,  805,  810,  815,  820,  825,  830,  835,  840,  845,  850,  855,  860,  865,  870,  875,
	 880,  885,  890,  895,  900,  905,  910,  915,  920,  925,  930,  935,  940,  945,  950,  955,
	 960,  965,  970,  975,  980,  985,  990,  995, 1000, 1003, 1006, 1011, 1014, 1016, 1018, 1020,
	1022, 1024, 1037, 1039, 1041, 1044, 1047, 1061, 1068, 1075, 1082, 1094, 1107, 1121, 1136, 1151,
	1153, 1155, 1158, 1166, 1174, 1182, 1195, 1198, 1200, 1202, 1204, 1206, 1208, 1210, 1215, 1217,
	1219, 1221, 1223, 1225, 1227, 1242, 1259, 1276, 1293, 1310, 1327, 1344, 1361, 1378, 1395, 1412,
	1429, 1446, 1463, 1480, 1497, 1514, 1531, 1539, 1547, 1555, 1557, 1559, 1561, 1563, 1565, 1567,
	1569, 1571, 1573, 1575, 1583, 1591, 1604, 1621, 1623, 1625, 1627, 1629, 1634, 1636, 1638, 1645,
	1652, 1658, 1664, 1670, 1677, 1684, 1696, 1709, 1711, 1713, 1721, 1723, 1725, 1732, 1739, 1746,
	1752, 1758, 1764, 1771, 1778, 1784, 1789, 1791, 1793, 1795, 1797, 1804, 1813, 1827, 1835, 1843,
	1851, 1853, 1855, 1861, 1869, 1877, 1885, 1890, 1895, 1900, 1905, 1907, 1909, 1915, 1921, 1928,
	1935, 1940, 1945, 1952, 1954, 1956, 1958, 1960, 1962, 1964, 1966
    };

    static marpatcl_rtc_string mindt_parser_sf_c_pool = { /* 24 + 1968 bytes */
	mindt_parser_sf_c_pool_length,
	mindt_parser_sf_c_pool_offset,
	/*   0 */ "!\0"
	/*   1 */ "#\0"
	/*   2 */ "$\0"
	/*   3 */ "%\0"
	/*   4 */ "&\0"
	/*   5 */ "'\0"
	/*   6 */ "*\0"
	/*   7 */ "+\0"
	/*   8 */ ",\0"
	/*   9 */ "-\0"
	/*  10 */ ".\0"
	/*  11 */ "/\0"
	/*  12 */ "0\0"
	/*  13 */ "1\0"
	/*  14 */ "2\0"
	/*  15 */ "3\0"
	/*  16 */ "4\0"
	/*  17 */ "5\0"
	/*  18 */ "6\0"
	/*  19 */ "7\0"
	/*  20 */ "8\0"
	/*  21 */ "9\0"
	/*  22 */ ":\0"
	/*  23 */ "<\0"
	/*  24 */ "=\0"
	/*  25 */ ">\0"
	/*  26 */ "?\0"
	/*  27 */ "@\0"
	/*  28 */ "@L0:START\0"
	/*  29 */ "[!-Z]\0"
	/*  30 */ "[#-Z]\0"
	/*  31 */ "[\\1-\\10]\0"
	/*  32 */ "[\\1-z]\0"
	/*  33 */ "[\\16-\\37]\0"
	/*  34 */ "[\\173\\175]\0"
	/*  35 */ "[\\200-\\277]\0"
	/*  36 */ "[\\240-\\257]\0"
	/*  37 */ "[\\240-\\277]\0"
	/*  38 */ "[\\260-\\277]\0"
	/*  39 */ "[\\302-\\337]\0"
	/*  40 */ "[\\341-\\357]\0"
	/*  41 */ "[\\n\\r]\0"
	/*  42 */ "[\\t-\\r\\40\\42\\133\\135]\0"
	/*  43 */ "[\\t-\\r\\40\\133\\135]\0"
	/*  44 */ "[\\t-\\r\\40]\0"
	/*  45 */ "[\\t-\\r]\0"
	/*  46 */ "[^-\\177]\0"
	/*  47 */ "[~-\\177]\0"
	/*  48 */ "\\1\0"
	/*  49 */ "\\2\0"
	/*  50 */ "\\3\0"
	/*  51 */ "\\4\0"
	/*  52 */ "\\5\0"
	/*  53 */ "\\6\0"
	/*  54 */ "\\7\0"
	/*  55 */ "\\10\0"
	/*  56 */ "\\13\0"
	/*  57 */ "\\14\0"
	/*  58 */ "\\16\0"
	/*  59 */ "\\17\0"
	/*  60 */ "\\20\0"
	/*  61 */ "\\21\0"
	/*  62 */ "\\22\0"
	/*  63 */ "\\23\0"
	/*  64 */ "\\24\0"
	/*  65 */ "\\25\0"
	/*  66 */ "\\26\0"
	/*  67 */ "\\27\0"
	/*  68 */ "\\30\0"
	/*  69 */ "\\31\0"
	/*  70 */ "\\32\0"
	/*  71 */ "\\33\0"
	/*  72 */ "\\34\0"
	/*  73 */ "\\35\0"
	/*  74 */ "\\36\0"
	/*  75 */ "\\37\0"
	/*  76 */ "\\40\0"
	/*  77 */ "\\42\0"
	/*  78 */ "\\50\0"
	/*  79 */ "\\51\0"
	/*  80 */ "\\73\0"
	/*  81 */ "\\133\0"
	/*  82 */ "\\134\0"
	/*  83 */ "\\134\\173\0"
	/*  84 */ "\\134\\175\0"
	/*  85 */ "\\135\0"
	/*  86 */ "\\173\0"
	/*  87 */ "\\175\0"
	/*  88 */ "\\177\0"
	/*  89 */ "\\200\0"
	/*  90 */ "\\201\0"
	/*  91 */ "\\202\0"
	/*  92 */ "\\203\0"
	/*  93 */ "\\204\0"
	/*  94 */ "\\205\0"
	/*  95 */ "\\206\0"
	/*  96 */ "\\207\0"
	/*  97 */ "\\210\0"
	/*  98 */ "\\211\0"
	/*  99 */ "\\212\0"
	/* 100 */ "\\213\0"
	/* 101 */ "\\214\0"
	/* 102 */ "\\215\0"
	/* 103 */ "\\216\0"
	/* 104 */ "\\217\0"
	/* 105 */ "\\220\0"
	/* 106 */ "\\221\0"
	/* 107 */ "\\222\0"
	/* 108 */ "\\223\0"
	/* 109 */ "\\224\0"
	/* 110 */ "\\225\0"
	/* 111 */ "\\226\0"
	/* 112 */ "\\227\0"
	/* 113 */ "\\230\0"
	/* 114 */ "\\231\0"
	/* 115 */ "\\232\0"
	/* 116 */ "\\233\0"
	/* 117 */ "\\234\0"
	/* 118 */ "\\235\0"
	/* 119 */ "\\236\0"
	/* 120 */ "\\237\0"
	/* 121 */ "\\240\0"
	/* 122 */ "\\241\0"
	/* 123 */ "\\242\0"
	/* 124 */ "\\243\0"
	/* 125 */ "\\244\0"
	/* 126 */ "\\245\0"
	/* 127 */ "\\246\0"
	/* 128 */ "\\247\0"
	/* 129 */ "\\250\0"
	/* 130 */ "\\251\0"
	/* 131 */ "\\252\0"
	/* 132 */ "\\253\0"
	/* 133 */ "\\254\0"
	/* 134 */ "\\255\0"
	/* 135 */ "\\256\0"
	/* 136 */ "\\257\0"
	/* 137 */ "\\260\0"
	/* 138 */ "\\261\0"
	/* 139 */ "\\262\0"
	/* 140 */ "\\263\0"
	/* 141 */ "\\264\0"
	/* 142 */ "\\265\0"
	/* 143 */ "\\266\0"
	/* 144 */ "\\267\0"
	/* 145 */ "\\270\0"
	/* 146 */ "\\271\0"
	/* 147 */ "\\272\0"
	/* 148 */ "\\273\0"
	/* 149 */ "\\274\0"
	/* 150 */ "\\275\0"
	/* 151 */ "\\276\0"
	/* 152 */ "\\277\0"
	/* 153 */ "\\300\0"
	/* 154 */ "\\302\0"
	/* 155 */ "\\303\0"
	/* 156 */ "\\304\0"
	/* 157 */ "\\305\0"
	/* 158 */ "\\306\0"
	/* 159 */ "\\307\0"
	/* 160 */ "\\310\0"
	/* 161 */ "\\311\0"
	/* 162 */ "\\312\0"
	/* 163 */ "\\313\0"
	/* 164 */ "\\314\0"
	/* 165 */ "\\315\0"
	/* 166 */ "\\316\0"
	/* 167 */ "\\317\0"
	/* 168 */ "\\320\0"
	/* 169 */ "\\321\0"
	/* 170 */ "\\322\0"
	/* 171 */ "\\323\0"
	/* 172 */ "\\324\0"
	/* 173 */ "\\325\0"
	/* 174 */ "\\326\0"
	/* 175 */ "\\327\0"
	/* 176 */ "\\330\0"
	/* 177 */ "\\331\0"
	/* 178 */ "\\332\0"
	/* 179 */ "\\333\0"
	/* 180 */ "\\334\0"
	/* 181 */ "\\335\0"
	/* 182 */ "\\336\0"
	/* 183 */ "\\337\0"
	/* 184 */ "\\340\0"
	/* 185 */ "\\341\0"
	/* 186 */ "\\342\0"
	/* 187 */ "\\343\0"
	/* 188 */ "\\344\0"
	/* 189 */ "\\345\0"
	/* 190 */ "\\346\0"
	/* 191 */ "\\347\0"
	/* 192 */ "\\350\0"
	/* 193 */ "\\351\0"
	/* 194 */ "\\352\0"
	/* 195 */ "\\353\0"
	/* 196 */ "\\354\0"
	/* 197 */ "\\355\0"
	/* 198 */ "\\356\0"
	/* 199 */ "\\357\0"
	/* 200 */ "\\n\0"
	/* 201 */ "\\r\0"
	/* 202 */ "\\r\\n\0"
	/* 203 */ "\\t\0"
	/* 204 */ "^\0"
	/* 205 */ "_\0"
	/* 206 */ "`\0"
	/* 207 */ "A\0"
	/* 208 */ "a\0"
	/* 209 */ "ANY_UNBRACED\0"
	/* 210 */ "B\0"
	/* 211 */ "b\0"
	/* 212 */ "BL\0"
	/* 213 */ "BR\0"
	/* 214 */ "BRACE_ESCAPED\0"
	/* 215 */ "BRACED\0"
	/* 216 */ "Braced\0"
	/* 217 */ "braced\0"
	/* 218 */ "BRACED_ELEM\0"
	/* 219 */ "BRACED_ELEMS\0"
	/* 220 */ "BRAN<d9-d122>\0"
	/* 221 */ "BRAN<d14-d122>\0"
	/* 222 */ "BRAN<d32-d122>\0"
	/* 223 */ "C\0"
	/* 224 */ "c\0"
	/* 225 */ "CL\0"
	/* 226 */ "COMMAND\0"
	/* 227 */ "COMMENT\0"
	/* 228 */ "comment\0"
	/* 229 */ "CONTINUATION\0"
	/* 230 */ "CR\0"
	/* 231 */ "D\0"
	/* 232 */ "d\0"
	/* 233 */ "E\0"
	/* 234 */ "e\0"
	/* 235 */ "F\0"
	/* 236 */ "f\0"
	/* 237 */ "form\0"
	/* 238 */ "G\0"
	/* 239 */ "g\0"
	/* 240 */ "H\0"
	/* 241 */ "h\0"
	/* 242 */ "I\0"
	/* 243 */ "i\0"
	/* 244 */ "ILLEGAL_BYTE_0\0"
	/* 245 */ "ILLEGAL_BYTE_193\0"
	/* 246 */ "ILLEGAL_BYTE_240\0"
	/* 247 */ "ILLEGAL_BYTE_241\0"
	/* 248 */ "ILLEGAL_BYTE_242\0"
	/* 249 */ "ILLEGAL_BYTE_243\0"
	/* 250 */ "ILLEGAL_BYTE_244\0"
	/* 251 */ "ILLEGAL_BYTE_245\0"
	/* 252 */ "ILLEGAL_BYTE_246\0"
	/* 253 */ "ILLEGAL_BYTE_247\0"
	/* 254 */ "ILLEGAL_BYTE_248\0"
	/* 255 */ "ILLEGAL_BYTE_249\0"
	/* 256 */ "ILLEGAL_BYTE_250\0"
	/* 257 */ "ILLEGAL_BYTE_251\0"
	/* 258 */ "ILLEGAL_BYTE_252\0"
	/* 259 */ "ILLEGAL_BYTE_253\0"
	/* 260 */ "ILLEGAL_BYTE_254\0"
	/* 261 */ "ILLEGAL_BYTE_255\0"
	/* 262 */ "INCLUDE\0"
	/* 263 */ "Include\0"
	/* 264 */ "include\0"
	/* 265 */ "J\0"
	/* 266 */ "j\0"
	/* 267 */ "K\0"
	/* 268 */ "k\0"
	/* 269 */ "L\0"
	/* 270 */ "l\0"
	/* 271 */ "M\0"
	/* 272 */ "m\0"
	/* 273 */ "N\0"
	/* 274 */ "n\0"
	/* 275 */ "NEWLINE\0"
	/* 276 */ "NO_CFS1\0"
	/* 277 */ "NO_CFS_QUOTE\0"
	/* 278 */ "NO_CMD_FMT_SPACE\0"
	/* 279 */ "O\0"
	/* 280 */ "o\0"
	/* 281 */ "P\0"
	/* 282 */ "p\0"
	/* 283 */ "path\0"
	/* 284 */ "Q\0"
	/* 285 */ "q\0"
	/* 286 */ "q_elem\0"
	/* 287 */ "q_list\0"
	/* 288 */ "QUOTE\0"
	/* 289 */ "Quote\0"
	/* 290 */ "quote\0"
	/* 291 */ "QUOTED\0"
	/* 292 */ "quoted\0"
	/* 293 */ "QUOTED_ELEM\0"
	/* 294 */ "QUOTED_ELEMS\0"
	/* 295 */ "R\0"
	/* 296 */ "r\0"
	/* 297 */ "recurse\0"
	/* 298 */ "S\0"
	/* 299 */ "s\0"
	/* 300 */ "SIMPLE\0"
	/* 301 */ "Simple\0"
	/* 302 */ "simple\0"
	/* 303 */ "SPACE\0"
	/* 304 */ "Space\0"
	/* 305 */ "space\0"
	/* 306 */ "SPACE0\0"
	/* 307 */ "SPACE1\0"
	/* 308 */ "Start\0"
	/* 309 */ "Stop\0"
	/* 310 */ "T\0"
	/* 311 */ "t\0"
	/* 312 */ "U\0"
	/* 313 */ "u\0"
	/* 314 */ "unquot\0"
	/* 315 */ "UNQUOTED\0"
	/* 316 */ "UNQUOTED_ELEM\0"
	/* 317 */ "uq_elem\0"
	/* 318 */ "uq_lead\0"
	/* 319 */ "uq_list\0"
	/* 320 */ "V\0"
	/* 321 */ "v\0"
	/* 322 */ "value\0"
	/* 323 */ "var_def\0"
	/* 324 */ "var_ref\0"
	/* 325 */ "varname\0"
	/* 326 */ "vars\0"
	/* 327 */ "VSET\0"
	/* 328 */ "Vset\0"
	/* 329 */ "vset\0"
	/* 330 */ "W\0"
	/* 331 */ "w\0"
	/* 332 */ "WHITE\0"
	/* 333 */ "White\0"
	/* 334 */ "WHITE0\0"
	/* 335 */ "WHITE1\0"
	/* 336 */ "WORD\0"
	/* 337 */ "Word\0"
	/* 338 */ "WORDS1\0"
	/* 339 */ "X\0"
	/* 340 */ "x\0"
	/* 341 */ "Y\0"
	/* 342 */ "y\0"
	/* 343 */ "Z\0"
	/* 344 */ "z\0"
	/* 345 */ "|\0"
	/* 346 */ "~\0"
    };

    /*
    ** L0 structures
    */

    static marpatcl_rtc_sym mindt_parser_sf_c_l0_sym_name [338] = { /* 676 bytes */
	/* --- (256) --- --- --- Characters
	 */
	244,  48,  49,  50,  51,  52,  53,  54,  55, 203, 200,  56,  57, 201,  58,  59,
	 60,  61,  62,  63,  64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,
	 76,   0,  77,   1,   2,   3,   4,   5,  78,  79,   6,   7,   8,   9,  10,  11,
	 12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  80,  23,  24,  25,  26,
	 27, 207, 210, 223, 231, 233, 235, 238, 240, 242, 265, 267, 269, 271, 273, 279,
	281, 284, 295, 298, 310, 312, 320, 330, 339, 341, 343,  81,  82,  85, 204, 205,
	206, 208, 211, 224, 232, 234, 236, 239, 241, 243, 266, 268, 270, 272, 274, 280,
	282, 285, 296, 299, 311, 313, 321, 331, 340, 342, 344,  86, 345,  87, 346,  88,
	 89,  90,  91,  92,  93,  94,  95,  96,  97,  98,  99, 100, 101, 102, 103, 104,
	105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120,
	121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136,
	137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152,
	153, 245, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167,
	168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183,
	184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199,
	246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261,

	/* --- (10) --- --- --- ACS: Lexeme
	 */
	216, 263, 289, 301, 304, 308, 309, 328, 333, 337,

	/* --- (10) --- --- --- Lexeme
	 */
	216, 263, 289, 301, 304, 308, 309, 328, 333, 337,

	/* --- (62) --- --- --- Internal
	 */
	 34,  42,  43,  32,  37,  41,  44,  83,  84, 202, 228, 264, 329, 209, 212, 213,
	214, 215, 218, 219, 220, 221, 225, 226, 227, 229, 230, 262, 275, 276, 277, 278,
	288, 291, 293, 294, 300, 303, 306, 307, 315, 316, 327, 332, 334, 335, 336, 338,
	 29,  30,  31,  33,  35,  36,  38,  39,  40,  45,  46,  47, 222,  28
    };

    static marpatcl_rtc_sym mindt_parser_sf_c_l0_rule_definitions [378] = { /* 756 bytes */
	MARPATCL_RCMD_SETUP (7),
	MARPATCL_RCMD_PRIO  (1), 266, 293,                               /* <Braced>                      ::= <BRACED> */
	MARPATCL_RCMD_PRIO  (1), 267, 303,                               /* <Include>                     ::= <INCLUDE> */
	MARPATCL_RCMD_PRIO  (1), 268, 308,                               /* <Quote>                       ::= <QUOTE> */
	MARPATCL_RCMD_PRIO  (1), 269, 312,                               /* <Simple>                      ::= <SIMPLE> */
	MARPATCL_RCMD_PRIO  (1), 270, 315,                               /* <Space>                       ::= <SPACE1> */
	MARPATCL_RCMD_PRIO  (1), 271, 298,                               /* <Start>                       ::= <CL> */
	MARPATCL_RCMD_PRIO  (1), 272, 302,                               /* <Stop>                        ::= <CR> */
	MARPATCL_RCMD_PRIO  (1), 273, 318,                               /* <Vset>                        ::= <VSET> */
	MARPATCL_RCMD_PRIO  (1), 274, 321,                               /* <White>                       ::= <WHITE1> */
	MARPATCL_RCMD_PRIO  (1), 275, 322,                               /* <Word>                        ::= <WORD> */
	MARPATCL_RCMD_PRIO  (2), 276, 192, 128,                          /* <@^CLS:<\173\175>>            ::= <@BYTE:<\300>> <@BYTE:<\200>> */
	MARPATCL_RCMD_PRIS  (1)     , 279,                               /*                               |   <@BRAN:<\1z>> */
	MARPATCL_RCMD_PRIS  (1)     , 124,                               /*                               |   <@BYTE:<|>> */
	MARPATCL_RCMD_PRIS  (1)     , 335,                               /*                               |   <@BRAN:<~\177>> */
	MARPATCL_RCMD_PRIS  (2)     , 331, 328,                          /*                               |   <@BRAN:<\302\337>> <@BRAN:<\200\277>> */
	MARPATCL_RCMD_PRIS  (3)     , 224, 280, 328,                     /*                               |   <@BYTE:<\340>> <@BRAN:<\240\277>> <@BRAN:<\200\277>> */
	MARPATCL_RCMD_PRIS  (3)     , 332, 328, 328,                     /*                               |   <@BRAN:<\341\357>> <@BRAN:<\200\277>> <@BRAN:<\200\277>> */
	MARPATCL_RCMD_PRIS  (6)     , 237, 329, 328, 237, 330, 328,      /*                               |   <@BYTE:<\355>> <@BRAN:<\240\257>> <@BRAN:<\200\277>> <@BYTE:<\355>> <@BRAN:<\260\277>> <@BRAN:<\200\277>> */
	MARPATCL_RCMD_PRIO  (2), 277, 192, 128,                          /* <@^CLS:<\t-\r\40\42\133\135>> ::= <@BYTE:<\300>> <@BYTE:<\200>> */
	MARPATCL_RCMD_PRIS  (1)     , 326,                               /*                               |   <@BRAN:<\1\10>> */
	MARPATCL_RCMD_PRIS  (1)     , 327,                               /*                               |   <@BRAN:<\16\37>> */
	MARPATCL_RCMD_PRIS  (1)     , 33,                                /*                               |   <@BYTE:<!>> */
	MARPATCL_RCMD_PRIS  (1)     , 325,                               /*                               |   <@BRAN:<#Z>> */
	MARPATCL_RCMD_PRIS  (1)     , 92,                                /*                               |   <@BYTE:<\134>> */
	MARPATCL_RCMD_PRIS  (1)     , 334,                               /*                               |   <@BRAN:<^\177>> */
	MARPATCL_RCMD_PRIS  (2)     , 331, 328,                          /*                               |   <@BRAN:<\302\337>> <@BRAN:<\200\277>> */
	MARPATCL_RCMD_PRIS  (3)     , 224, 280, 328,                     /*                               |   <@BYTE:<\340>> <@BRAN:<\240\277>> <@BRAN:<\200\277>> */
	MARPATCL_RCMD_PRIS  (3)     , 332, 328, 328,                     /*                               |   <@BRAN:<\341\357>> <@BRAN:<\200\277>> <@BRAN:<\200\277>> */
	MARPATCL_RCMD_PRIS  (6)     , 237, 329, 328, 237, 330, 328,      /*                               |   <@BYTE:<\355>> <@BRAN:<\240\257>> <@BRAN:<\200\277>> <@BYTE:<\355>> <@BRAN:<\260\277>> <@BRAN:<\200\277>> */
	MARPATCL_RCMD_PRIO  (2), 278, 192, 128,                          /* <@^CLS:<\t-\r\40\133\135>>    ::= <@BYTE:<\300>> <@BYTE:<\200>> */
	MARPATCL_RCMD_PRIS  (1)     , 326,                               /*                               |   <@BRAN:<\1\10>> */
	MARPATCL_RCMD_PRIS  (1)     , 327,                               /*                               |   <@BRAN:<\16\37>> */
	MARPATCL_RCMD_PRIS  (1)     , 324,                               /*                               |   <@BRAN:<!Z>> */
	MARPATCL_RCMD_PRIS  (1)     , 92,                                /*                               |   <@BYTE:<\134>> */
	MARPATCL_RCMD_PRIS  (1)     , 334,                               /*                               |   <@BRAN:<^\177>> */
	MARPATCL_RCMD_PRIS  (2)     , 331, 328,                          /*                               |   <@BRAN:<\302\337>> <@BRAN:<\200\277>> */
	MARPATCL_RCMD_PRIS  (3)     , 224, 280, 328,                     /*                               |   <@BYTE:<\340>> <@BRAN:<\240\277>> <@BRAN:<\200\277>> */
	MARPATCL_RCMD_PRIS  (3)     , 332, 328, 328,                     /*                               |   <@BRAN:<\341\357>> <@BRAN:<\200\277>> <@BRAN:<\200\277>> */
	MARPATCL_RCMD_PRIS  (6)     , 237, 329, 328, 237, 330, 328,      /*                               |   <@BYTE:<\355>> <@BRAN:<\240\257>> <@BRAN:<\200\277>> <@BYTE:<\355>> <@BRAN:<\260\277>> <@BRAN:<\200\277>> */
	MARPATCL_RCMD_PRIO  (1), 279, 326,                               /* <@BRAN:<\1z>>                 ::= <@BRAN:<\1\10>> */
	MARPATCL_RCMD_PRIS  (1)     , 296,                               /*                               |   <BRAN<d9-d122>> */
	MARPATCL_RCMD_PRIO  (1), 280, 329,                               /* <@BRAN:<\240\277>>            ::= <@BRAN:<\240\257>> */
	MARPATCL_RCMD_PRIS  (1)     , 330,                               /*                               |   <@BRAN:<\260\277>> */
	MARPATCL_RCMD_PRIO  (1), 281, 10,                                /* <@CLS:<\n\r>>                 ::= <@BYTE:<\n>> */
	MARPATCL_RCMD_PRIS  (1)     , 13,                                /*                               |   <@BYTE:<\r>> */
	MARPATCL_RCMD_PRIO  (1), 282, 333,                               /* <@CLS:<\t-\r\40>>             ::= <@BRAN:<\t\r>> */
	MARPATCL_RCMD_PRIS  (1)     , 32,                                /*                               |   <@BYTE:<\40>> */
	MARPATCL_RCMD_PRIO  (2), 283, 92, 123,                           /* <@STR:<\134\173>>             ::= <@BYTE:<\134>> <@BYTE:<\173>> */
	MARPATCL_RCMD_PRIO  (2), 284, 92, 125,                           /* <@STR:<\134\175>>             ::= <@BYTE:<\134>> <@BYTE:<\175>> */
	MARPATCL_RCMD_PRIO  (2), 285, 13, 10,                            /* <@STR:<\r\n>>                 ::= <@BYTE:<\r>> <@BYTE:<\n>> */
	MARPATCL_RCMD_PRIO  (7), 286, 99, 111, 109, 109, 101, 110, 116,  /* <@STR:<comment>>              ::= <@BYTE:<c>> <@BYTE:<o>> <@BYTE:<m>> <@BYTE:<m>> <@BYTE:<e>> <@BYTE:<n>> <@BYTE:<t>> */
	MARPATCL_RCMD_PRIO  (7), 287, 105, 110, 99, 108, 117, 100, 101,  /* <@STR:<include>>              ::= <@BYTE:<i>> <@BYTE:<n>> <@BYTE:<c>> <@BYTE:<l>> <@BYTE:<u>> <@BYTE:<d>> <@BYTE:<e>> */
	MARPATCL_RCMD_PRIO  (4), 288, 118, 115, 101, 116,                /* <@STR:<vset>>                 ::= <@BYTE:<v>> <@BYTE:<s>> <@BYTE:<e>> <@BYTE:<t>> */
	MARPATCL_RCMD_PRIO  (1), 289, 276,                               /* <ANY_UNBRACED>                ::= <@^CLS:<\173\175>> */
	MARPATCL_RCMD_PRIO  (1), 290, 123,                               /* <BL>                          ::= <@BYTE:<\173>> */
	MARPATCL_RCMD_PRIO  (1), 291, 125,                               /* <BR>                          ::= <@BYTE:<\175>> */
	MARPATCL_RCMD_PRIO  (1), 292, 283,                               /* <BRACE_ESCAPED>               ::= <@STR:<\134\173>> */
	MARPATCL_RCMD_PRIS  (1)     , 284,                               /*                               |   <@STR:<\134\175>> */
	MARPATCL_RCMD_PRIO  (3), 293, 290, 295, 291,                     /* <BRACED>                      ::= <BL> <BRACED_ELEMS> <BR> */
	MARPATCL_RCMD_PRIO  (1), 294, 289,                               /* <BRACED_ELEM>                 ::= <ANY_UNBRACED> */
	MARPATCL_RCMD_PRIS  (1)     , 293,                               /*                               |   <BRACED> */
	MARPATCL_RCMD_PRIS  (1)     , 292,                               /*                               |   <BRACE_ESCAPED> */
	MARPATCL_RCMD_QUN   (295), 294,                                  /* <BRACED_ELEMS>                ::= <BRACED_ELEM> * */
	MARPATCL_RCMD_PRIO  (1), 296, 333,                               /* <BRAN<d9-d122>>               ::= <@BRAN:<\t\r>> */
	MARPATCL_RCMD_PRIS  (1)     , 297,                               /*                               |   <BRAN<d14-d122>> */
	MARPATCL_RCMD_PRIO  (1), 297, 327,                               /* <BRAN<d14-d122>>              ::= <@BRAN:<\16\37>> */
	MARPATCL_RCMD_PRIS  (1)     , 336,                               /*                               |   <BRAN<d32-d122>> */
	MARPATCL_RCMD_PRIO  (1), 298, 91,                                /* <CL>                          ::= <@CHR:<\133>> */
	MARPATCL_RCMD_PRIO  (5), 299, 298, 320, 323, 320, 302,           /* <COMMAND>                     ::= <CL> <WHITE0> <WORDS1> <WHITE0> <CR> */
	MARPATCL_RCMD_PRIO  (7), 300, 298, 320, 286, 321, 322, 320, 302, /* <COMMENT>                     ::= <CL> <WHITE0> <@STR:<comment>> <WHITE1> <WORD> <WHITE0> <CR> */
	MARPATCL_RCMD_PRIO  (4), 301, 314, 92, 304, 314,                 /* <CONTINUATION>                ::= <SPACE0> <@BYTE:<\134>> <NEWLINE> <SPACE0> */
	MARPATCL_RCMD_PRIO  (1), 302, 93,                                /* <CR>                          ::= <@CHR:<\135>> */
	MARPATCL_RCMD_PRIO  (1), 303, 287,                               /* <INCLUDE>                     ::= <@STR:<include>> */
	MARPATCL_RCMD_PRIO  (1), 304, 281,                               /* <NEWLINE>                     ::= <@CLS:<\n\r>> */
	MARPATCL_RCMD_PRIS  (1)     , 285,                               /*                               |   <@STR:<\r\n>> */
	MARPATCL_RCMD_QUP   (305), 307,                                  /* <NO_CFS1>                     ::= <NO_CMD_FMT_SPACE> + */
	MARPATCL_RCMD_PRIO  (1), 306, 277,                               /* <NO_CFS_QUOTE>                ::= <@^CLS:<\t-\r\40\42\133\135>> */
	MARPATCL_RCMD_PRIO  (1), 307, 278,                               /* <NO_CMD_FMT_SPACE>            ::= <@^CLS:<\t-\r\40\133\135>> */
	MARPATCL_RCMD_PRIO  (1), 308, 34,                                /* <QUOTE>                       ::= <@CHR:<\42>> */
	MARPATCL_RCMD_PRIO  (3), 309, 308, 311, 308,                     /* <QUOTED>                      ::= <QUOTE> <QUOTED_ELEMS> <QUOTE> */
	MARPATCL_RCMD_PRIO  (1), 310, 312,                               /* <QUOTED_ELEM>                 ::= <SIMPLE> */
	MARPATCL_RCMD_PRIS  (1)     , 315,                               /*                               |   <SPACE1> */
	MARPATCL_RCMD_PRIS  (1)     , 299,                               /*                               |   <COMMAND> */
	MARPATCL_RCMD_QUN   (311), 310,                                  /* <QUOTED_ELEMS>                ::= <QUOTED_ELEM> * */
	MARPATCL_RCMD_QUP   (312), 306,                                  /* <SIMPLE>                      ::= <NO_CFS_QUOTE> + */
	MARPATCL_RCMD_PRIO  (1), 313, 282,                               /* <SPACE>                       ::= <@CLS:<\t-\r\40>> */
	MARPATCL_RCMD_QUN   (314), 313,                                  /* <SPACE0>                      ::= <SPACE> * */
	MARPATCL_RCMD_QUP   (315), 313,                                  /* <SPACE1>                      ::= <SPACE> + */
	MARPATCL_RCMD_QUP   (316), 317,                                  /* <UNQUOTED>                    ::= <UNQUOTED_ELEM> + */
	MARPATCL_RCMD_PRIO  (1), 317, 305,                               /* <UNQUOTED_ELEM>               ::= <NO_CFS1> */
	MARPATCL_RCMD_PRIS  (1)     , 299,                               /*                               |   <COMMAND> */
	MARPATCL_RCMD_PRIO  (1), 318, 288,                               /* <VSET>                        ::= <@STR:<vset>> */
	MARPATCL_RCMD_PRIO  (1), 319, 315,                               /* <WHITE>                       ::= <SPACE1> */
	MARPATCL_RCMD_PRIS  (1)     , 300,                               /*                               |   <COMMENT> */
	MARPATCL_RCMD_PRIS  (1)     , 301,                               /*                               |   <CONTINUATION> */
	MARPATCL_RCMD_QUN   (320), 319,                                  /* <WHITE0>                      ::= <WHITE> * */
	MARPATCL_RCMD_QUP   (321), 319,                                  /* <WHITE1>                      ::= <WHITE> + */
	MARPATCL_RCMD_PRIO  (1), 322, 293,                               /* <WORD>                        ::= <BRACED> */
	MARPATCL_RCMD_PRIS  (1)     , 309,                               /*                               |   <QUOTED> */
	MARPATCL_RCMD_PRIS  (1)     , 316,                               /*                               |   <UNQUOTED> */
	MARPATCL_RCMD_QUPS  (323), 322, MARPATCL_RCMD_SEP (321),         /* <WORDS1>                      ::= <WORD> + (<WHITE1>) */
	MARPATCL_RCMD_BRAN  (324), MARPATCL_RCMD_BOXR ( 33, 90),         /* <@BRAN:<!Z>>                  brange (33 - 90) */
	MARPATCL_RCMD_BRAN  (325), MARPATCL_RCMD_BOXR ( 35, 90),         /* <@BRAN:<#Z>>                  brange (35 - 90) */
	MARPATCL_RCMD_BRAN  (326), MARPATCL_RCMD_BOXR (  1,  8),         /* <@BRAN:<\1\10>>               brange (1 - 8) */
	MARPATCL_RCMD_BRAN  (327), MARPATCL_RCMD_BOXR ( 14, 31),         /* <@BRAN:<\16\37>>              brange (14 - 31) */
	MARPATCL_RCMD_BRAN  (328), MARPATCL_RCMD_BOXR (128,191),         /* <@BRAN:<\200\277>>            brange (128 - 191) */
	MARPATCL_RCMD_BRAN  (329), MARPATCL_RCMD_BOXR (160,175),         /* <@BRAN:<\240\257>>            brange (160 - 175) */
	MARPATCL_RCMD_BRAN  (330), MARPATCL_RCMD_BOXR (176,191),         /* <@BRAN:<\260\277>>            brange (176 - 191) */
	MARPATCL_RCMD_BRAN  (331), MARPATCL_RCMD_BOXR (194,223),         /* <@BRAN:<\302\337>>            brange (194 - 223) */
	MARPATCL_RCMD_BRAN  (332), MARPATCL_RCMD_BOXR (225,239),         /* <@BRAN:<\341\357>>            brange (225 - 239) */
	MARPATCL_RCMD_BRAN  (333), MARPATCL_RCMD_BOXR (  9, 13),         /* <@BRAN:<\t\r>>                brange (9 - 13) */
	MARPATCL_RCMD_BRAN  (334), MARPATCL_RCMD_BOXR ( 94,127),         /* <@BRAN:<^\177>>               brange (94 - 127) */
	MARPATCL_RCMD_BRAN  (335), MARPATCL_RCMD_BOXR (126,127),         /* <@BRAN:<~\177>>               brange (126 - 127) */
	MARPATCL_RCMD_BRAN  (336), MARPATCL_RCMD_BOXR ( 32,122),         /* <BRAN<d32-d122>>              brange (32 - 122) */
	MARPATCL_RCMD_PRIO  (2), 337, 256, 266,                          /* <@L0:START>                   ::= <@ACS:Braced> <Braced> */
	MARPATCL_RCMD_PRIS  (2)     , 257, 267,                          /*                               |   <@ACS:Include> <Include> */
	MARPATCL_RCMD_PRIS  (2)     , 258, 268,                          /*                               |   <@ACS:Quote> <Quote> */
	MARPATCL_RCMD_PRIS  (2)     , 259, 269,                          /*                               |   <@ACS:Simple> <Simple> */
	MARPATCL_RCMD_PRIS  (2)     , 260, 270,                          /*                               |   <@ACS:Space> <Space> */
	MARPATCL_RCMD_PRIS  (2)     , 261, 271,                          /*                               |   <@ACS:Start> <Start> */
	MARPATCL_RCMD_PRIS  (2)     , 262, 272,                          /*                               |   <@ACS:Stop> <Stop> */
	MARPATCL_RCMD_PRIS  (2)     , 263, 273,                          /*                               |   <@ACS:Vset> <Vset> */
	MARPATCL_RCMD_PRIS  (2)     , 264, 274,                          /*                               |   <@ACS:White> <White> */
	MARPATCL_RCMD_PRIS  (2)     , 265, 275,                          /*                               |   <@ACS:Word> <Word> */
	MARPATCL_RCMD_DONE  (337)
    };

    static marpatcl_rtc_rules mindt_parser_sf_c_l0 = { /* 48 */
	/* .sname   */  &mindt_parser_sf_c_pool,
	/* .symbols */  { 338, mindt_parser_sf_c_l0_sym_name },
	/* .rules   */  { 0, NULL },
	/* .lhs     */  { 0, NULL },
	/* .rcode   */  mindt_parser_sf_c_l0_rule_definitions,
	/* .events  */  0
    };

    static marpatcl_rtc_sym mindt_parser_sf_c_l0semantics [3] = { /* 6 bytes */
	 MARPATCL_SV_START, MARPATCL_SV_LENGTH,  MARPATCL_SV_VALUE
    };

    /*
    ** G1 structures
    */

    static marpatcl_rtc_sym mindt_parser_sf_c_g1_sym_name [30] = { /* 60 bytes */
	/* --- (10) --- --- --- Terminals
	 */
	216, 263, 289, 301, 304, 308, 309, 328, 333, 337,

	/* --- (20) --- --- --- Structure
	 */
	237, 326, 323, 324, 264, 325, 283, 322, 297, 292, 287, 286, 314, 318, 319, 317,
	217, 302, 290, 305
    };

    static marpatcl_rtc_sym mindt_parser_sf_c_g1_rule_name [37] = { /* 74 bytes */
	237, 237, 326, 326, 323, 323, 323, 323, 324, 324, 324, 324, 264, 264, 264, 264,
	325, 283, 322, 297, 297, 297, 292, 287, 286, 286, 286, 314, 318, 318, 319, 317,
	317, 217, 302, 290, 305
    };

    static marpatcl_rtc_sym mindt_parser_sf_c_g1_rule_lhs [37] = { /* 74 bytes */
	10, 10, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14,
	15, 16, 17, 18, 18, 18, 19, 20, 21, 21, 21, 22, 23, 23, 24, 25,
	25, 26, 27, 28, 29
    };

    static marpatcl_rtc_sym mindt_parser_sf_c_g1_rule_definitions [165] = { /* 330 bytes */
	MARPATCL_RCMD_SETUP (9),
	MARPATCL_RCMD_PRIO  (1), 10, 11,                          /* <form>    ::= <vars> */
	MARPATCL_RCMD_PRIS  (1)    , 14,                          /*           |   <include> */
	MARPATCL_RCMD_PRIO  (1), 11, 12,                          /* <vars>    ::= <var_def> */
	MARPATCL_RCMD_PRIS  (1)    , 13,                          /*           |   <var_ref> */
	MARPATCL_RCMD_PRIO  (9), 12, 5, 8, 7, 8, 15, 8, 17, 8, 6, /* <var_def> ::= <Start> <White> <Vset> <White> <varname> <White> <value> <White> <Stop> */
	MARPATCL_RCMD_PRIS  (8)    , 5, 8, 7, 8, 15, 8, 17, 6,    /*           |   <Start> <White> <Vset> <White> <varname> <White> <value> <Stop> */
	MARPATCL_RCMD_PRIS  (8)    , 5, 7, 8, 15, 8, 17, 8, 6,    /*           |   <Start> <Vset> <White> <varname> <White> <value> <White> <Stop> */
	MARPATCL_RCMD_PRIS  (7)    , 5, 7, 8, 15, 8, 17, 6,       /*           |   <Start> <Vset> <White> <varname> <White> <value> <Stop> */
	MARPATCL_RCMD_PRIO  (7), 13, 5, 8, 7, 8, 15, 8, 6,        /* <var_ref> ::= <Start> <White> <Vset> <White> <varname> <White> <Stop> */
	MARPATCL_RCMD_PRIS  (6)    , 5, 8, 7, 8, 15, 6,           /*           |   <Start> <White> <Vset> <White> <varname> <Stop> */
	MARPATCL_RCMD_PRIS  (6)    , 5, 7, 8, 15, 8, 6,           /*           |   <Start> <Vset> <White> <varname> <White> <Stop> */
	MARPATCL_RCMD_PRIS  (5)    , 5, 7, 8, 15, 6,              /*           |   <Start> <Vset> <White> <varname> <Stop> */
	MARPATCL_RCMD_PRIO  (7), 14, 5, 8, 1, 8, 16, 8, 6,        /* <include> ::= <Start> <White> <Include> <White> <path> <White> <Stop> */
	MARPATCL_RCMD_PRIS  (6)    , 5, 8, 1, 8, 16, 6,           /*           |   <Start> <White> <Include> <White> <path> <Stop> */
	MARPATCL_RCMD_PRIS  (6)    , 5, 1, 8, 16, 8, 6,           /*           |   <Start> <Include> <White> <path> <White> <Stop> */
	MARPATCL_RCMD_PRIS  (5)    , 5, 1, 8, 16, 6,              /*           |   <Start> <Include> <White> <path> <Stop> */
	MARPATCL_RCMD_PRIO  (1), 15, 18,                          /* <varname> ::= <recurse> */
	MARPATCL_RCMD_PRIO  (1), 16, 18,                          /* <path>    ::= <recurse> */
	MARPATCL_RCMD_PRIO  (1), 17, 9,                           /* <value>   ::= <Word> */
	MARPATCL_RCMD_PRIO  (1), 18, 26,                          /* <recurse> ::= <braced> */
	MARPATCL_RCMD_PRIS  (1)    , 19,                          /*           |   <quoted> */
	MARPATCL_RCMD_PRIS  (1)    , 22,                          /*           |   <unquot> */
	MARPATCL_RCMD_PRIO  (3), 19, 2, 20, 2,                    /* <quoted>  ::= <Quote> <q_list> <Quote> */
	MARPATCL_RCMD_QUN   (20), 21,                             /* <q_list>  ::= <q_elem> * */
	MARPATCL_RCMD_PRIO  (1), 21, 27,                          /* <q_elem>  ::= <simple> */
	MARPATCL_RCMD_PRIS  (1)    , 29,                          /*           |   <space> */
	MARPATCL_RCMD_PRIS  (1)    , 11,                          /*           |   <vars> */
	MARPATCL_RCMD_PRIO  (2), 22, 23, 24,                      /* <unquot>  ::= <uq_lead> <uq_list> */
	MARPATCL_RCMD_PRIO  (1), 23, 27,                          /* <uq_lead> ::= <simple> */
	MARPATCL_RCMD_PRIS  (1)    , 11,                          /*           |   <vars> */
	MARPATCL_RCMD_QUN   (24), 25,                             /* <uq_list> ::= <uq_elem> * */
	MARPATCL_RCMD_PRIO  (1), 25, 23,                          /* <uq_elem> ::= <uq_lead> */
	MARPATCL_RCMD_PRIS  (1)    , 28,                          /*           |   <quote> */
	MARPATCL_RCMD_PRIO  (1), 26, 0,                           /* <braced>  ::= <Braced> */
	MARPATCL_RCMD_PRIO  (1), 27, 3,                           /* <simple>  ::= <Simple> */
	MARPATCL_RCMD_PRIO  (1), 28, 2,                           /* <quote>   ::= <Quote> */
	MARPATCL_RCMD_PRIO  (1), 29, 4,                           /* <space>   ::= <Space> */
	MARPATCL_RCMD_DONE  (10)
    };

    static marpatcl_rtc_rules mindt_parser_sf_c_g1 = { /* 48 */
	/* .sname   */  &mindt_parser_sf_c_pool,
	/* .symbols */  { 30, mindt_parser_sf_c_g1_sym_name },
	/* .rules   */  { 37, mindt_parser_sf_c_g1_rule_name },
	/* .lhs     */  { 37, mindt_parser_sf_c_g1_rule_lhs },
	/* .rcode   */  mindt_parser_sf_c_g1_rule_definitions,
	/* .events  */  0
    };

    static marpatcl_rtc_sym mindt_parser_sf_c_g1semantics [43] = { /* 86 bytes */
	/* --- (1) --- --- --- Tag
	 */
	MARPATCL_S_PER,

	/* --- (37) --- --- --- Semantics Offsets
	 */
	37, 37, 37, 37, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39,
	37, 37, 37, 37, 37, 37, 37, 39, 37, 37, 37, 39, 37, 37, 39, 37,
	37, 39, 39, 39, 39,

	/* --- (2) --- --- --- Semantics Data
	 */
	         /* 37 */ 1, MARPATCL_SV_A_FIRST,
	           /* 39 */ 2, MARPATCL_SV_RULE_NAME,     MARPATCL_SV_VALUE
    };

    static marpatcl_rtc_sym mindt_parser_sf_c_g1masking [93] = { /* 186 bytes */
	/* --- (1) --- --- --- Tag
	 */
	MARPATCL_S_PER,

	/* --- (37) --- --- --- Mask Offsets
	 */
	 0,  0,  0,  0, 84, 70, 77, 57, 63, 45, 51, 40, 63, 45, 51, 40,
	 0,  0,  0,  0,  0,  0, 37,  0,  0,  0,  0,  0,  0,  0,  0,  0,
	 0,  0,  0,  0,  0,

	/* --- (3) --- --- --- Mask Data
	 */
	/* 37 */ 2, 0, 2,
	/* 40 */ 4, 0, 1, 2, 4,
	/* 45 */ 5, 0, 1, 2, 3, 5,
	/* 51 */ 5, 0, 1, 2, 4, 5,
	/* 57 */ 5, 0, 1, 2, 4, 6,
	/* 63 */ 6, 0, 1, 2, 3, 5, 6,
	/* 70 */ 6, 0, 1, 2, 3, 5, 7,
	/* 77 */ 6, 0, 1, 2, 4, 6, 7,
	/* 84 */ 7, 0, 1, 2, 3, 5, 7, 8
    };

    /*
    ** Parser definition
    */

    static marpatcl_rtc_sym mindt_parser_sf_c_always [0] = { /* 0 bytes */

    };

    static marpatcl_rtc_spec mindt_parser_sf_c_spec = { /* 72 */
	/* .lexemes    */  10,
	/* .discards   */  0,
	/* .l_symbols  */  338,
	/* .g_symbols  */  30,
	/* .always     */  { 0, mindt_parser_sf_c_always },
	/* .l0         */  &mindt_parser_sf_c_l0,
	/* .g1         */  &mindt_parser_sf_c_g1,
	/* .l0semantic */  { 3, mindt_parser_sf_c_l0semantics },
	/* .g1semantic */  { 43, mindt_parser_sf_c_g1semantics },
	/* .g1mask     */  { 93, mindt_parser_sf_c_g1masking }
    };
    /* --- end of generated data structures --- */
}

# # ## ### ##### ######## ############# #####################
## Class exposing the grammar engine.

critcl::class def mindt::parser::sf::c {

    insvariable marpatcl_rtc_sv_p result {
	Parse result
    } {
	instance->result = 0;
    } {
	if (instance->result) marpatcl_rtc_sv_unref (instance->result);
    }

    # Note how `rtc` is declared before `pedesc`. We need it
    # initalized to be able to feed it into the construction of the
    # PE descriptor facade.
    insvariable marpatcl_rtc_p state {
	C-level engine, RTC structures.
    } {
	instance->state = marpatcl_rtc_cons (&mindt_parser_sf_c_spec,
					     NULL, /* No actions */
					     @stem@_result, (void*) instance,
					     marpatcl_rtc_eh_report, (void*) &instance->ehstate );
    } {
	marpatcl_rtc_destroy (instance->state);
    }

    insvariable marpatcl_rtc_pedesc_p pedesc {
	Facade to the parse event descriptor structures.
	Maintained only when we have parse events declared, i.e. possible.
    } {
	// Feed our RTC structure into the facade class so that its constructor has access to it.
	marpatcl_rtc_pedesc_rtc_set (interp, instance->state);
	instance->pedesc = marpatcl_rtc_pedesc_new (interp, 0, 0);
	ASSERT (!marpatcl_rtc_pedesc_rtc_get (interp), "Constructor failed to take rtc structure");
    } {
	marpatcl_rtc_pedesc_destroy (instance->pedesc);
    }

    insvariable marpatcl_ehandlers ehstate {
	Handler for parse events
    } {
	marpatcl_rtc_eh_init (&instance->ehstate, interp,
			      (marpatcl_events_to_names) 0);
	/* See on-event above for further setup */
    } {
	marpatcl_rtc_eh_clear (&instance->ehstate);
	Tcl_DecrRefCount (instance->ehstate.self);
	instance->ehstate.self = 0;
    }

    insvariable Tcl_Obj* name {
	Object name, tail
    } { /* Initialized in the post constructor */ } {
	Tcl_DecrRefCount (instance->name);
    }

    method on-event proc {object args} void {
	marpatcl_rtc_eh_setup (&instance->ehstate, args.c, args.v);
    }

    method match proc {Tcl_Interp* ip object args} ok {
	/* -- Delegate to the parse event descriptor facade */
	return marpatcl_rtc_pe_match (instance->pedesc, ip, instance->name,
				      args.c, args.v);
    }

    constructor {
        /*
	 * Syntax:                          ... []
         * skip == 2: <class> new           ...
         *      == 3: <class> create <name> ...
         */

	if (objc > 0) {
	    Tcl_WrongNumArgs (interp, objcskip, objv-objcskip, 0);
	    goto error;
	}
    } {
	/* Post body. Save the FQN for use in the callbacks */
	instance->ehstate.self = fqn;
        Tcl_IncrRefCount (fqn);
        instance->name = Tcl_NewStringObj (Tcl_GetCommandName (interp, instance->cmd), -1);
        Tcl_IncrRefCount (instance->name);
    }

    method process-file proc {Tcl_Interp* ip object path object args} ok {
	int from, to;
	if (!marpatcl_rtc_pe_range (ip, args.c, args.v, &from, &to)) { return TCL_ERROR; }

	Tcl_Obj* ebuf;
	if (marpatcl_rtc_fget (ip, instance->state, path, &ebuf) != TCL_OK) {
	    return TCL_ERROR;
	}


	int got;
	char* buf = Tcl_GetStringFromObj (ebuf, &got);
	marpatcl_rtc_enter (instance->state, buf, got, from, to);
	Tcl_DecrRefCount (ebuf);

	return marpatcl_rtc_sv_complete (ip, instance->result, instance->state);
    }

    method process proc {Tcl_Interp* ip pstring string object args} ok {
	int from, to;
	if (!marpatcl_rtc_pe_range (ip, args.c, args.v, &from, &to)) { return TCL_ERROR; }
	marpatcl_rtc_enter (instance->state, string.s, string.len, from, to);
	return marpatcl_rtc_sv_complete (ip, instance->result, instance->state);
    }

    method extend proc {Tcl_Interp* ip pstring string} int {
	return marpatcl_rtc_enter_more (instance->state, string.s, string.len);
    }

    method extend-file proc {Tcl_Interp* ip object path} ok {
	Tcl_Obj* ebuf;
	if (marpatcl_rtc_fget (ip, instance->state, path, &ebuf) != TCL_OK) {
	    return TCL_ERROR;
	}

	int got;
	char* buf = Tcl_GetStringFromObj (ebuf, &got);
	int offset = marpatcl_rtc_enter_more (instance->state, buf, got);
	Tcl_DecrRefCount (ebuf);

	Tcl_SetObjResult (ip, Tcl_NewIntObj (offset));
	return TCL_OK;
    }

    support {
	/*
	** Stem:  @stem@
	** Pkg:   @package@
	** Class: @class@
	** IType: @instancetype@
	** CType: @classtype@
	*/

	/*
	** Helper function capturing parse results (semantic values of the parser)
	*/

	static void
	@stem@_result (void* cdata, marpatcl_rtc_sv_p sv)
	{
	    @instancetype@ instance = (@instancetype@) cdata;
	    if (instance->result) marpatcl_rtc_sv_unref (instance->result);
	    if (sv) marpatcl_rtc_sv_ref (sv);
	    instance->result = sv;
	    return;
	}
    }
}

# # ## ### ##### ######## ############# #####################
return