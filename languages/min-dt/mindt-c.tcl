# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017-present Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                             http://core.tcl.tk/akupries/
##
# (c) 2018 Grammar mindt::parser::c 1 By Andreas Kupries
##
##	`marpa::runtime::c`-derived Parser for grammar "mindt::parser::c".
##	Generated On Wed Aug 15 21:14:01 PDT 2018
##		  By aku@hephaistos
##		 Via marpa-gen
##
#* Space taken: 5613 bytes
##
#* Statistics
#* L0
#* - #Symbols:   343
#* - #Lexemes:   10
#* - #Discards:  1
#* - #Always:    1
#* - #Rule Insn: 129 (+2: setup, start-sym)
#* - #Rules:     529 (>= insn, brange)
#* G1
#* - #Symbols:   30
#* - #Rule Insn: 32 (+2: setup, start-sym)
#* - #Rules:     32 (match insn)

package provide mindt::parser::c 1

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5 ;# apply, lassign, ...
package require critcl 3.1

critcl::buildrequirement {
    package require critcl::class
    package require critcl::cutil
    package require critcl::literals
}

if {![critcl::compiling]} {
    error "Unable to build mindt::parser::c, no compiler found."
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
    ** Shared string pool (700 bytes lengths over 350 entries)
    **                    (700 bytes offsets -----^)
    **                    (2033 bytes character content)
    */

    static marpatcl_rtc_size mindt_parser_c_pool_length [350] = { /* 700 bytes */
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
	 1,  8,  5,  8,  2,  2,  7,  7,  7, 12,  2,  7,  5,  5,  1,  1,
	 1,  1,  1,  1,  1,  1,  6,  1,  1,  1,  1, 14, 16, 16, 16, 16,
	16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,  7,  7,  1,
	 1,  1,  1,  1,  1,  1,  1,  6,  1,  1,  7,  7, 12, 16,  1,  1,
	 1,  1,  1,  1,  5,  5,  5,  6,  6, 11, 11, 12, 12,  1,  1,  1,
	 1,  6,  6,  6,  5,  5,  5,  6,  6,  6,  1,  1,  7,  1,  1,  8,
	 8, 13, 13, 14, 15,  1,  1,  7,  7,  4,  4,  4,  1,  1,  5,  6,
	 6, 10,  4,  4,  5,  6,  1,  1,  1,  1,  1,  1,  1,  1
    };

    static marpatcl_rtc_size mindt_parser_c_pool_offset [350] = { /* 700 bytes */
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
	1153, 1155, 1164, 1170, 1179, 1182, 1185, 1193, 1201, 1209, 1222, 1225, 1233, 1239, 1245, 1247,
	1249, 1251, 1253, 1255, 1257, 1259, 1261, 1268, 1270, 1272, 1274, 1276, 1291, 1308, 1325, 1342,
	1359, 1376, 1393, 1410, 1427, 1444, 1461, 1478, 1495, 1512, 1529, 1546, 1563, 1580, 1588, 1596,
	1598, 1600, 1602, 1604, 1606, 1608, 1610, 1612, 1619, 1621, 1623, 1631, 1639, 1652, 1669, 1671,
	1673, 1675, 1677, 1679, 1681, 1687, 1693, 1699, 1706, 1713, 1725, 1737, 1750, 1763, 1765, 1767,
	1769, 1771, 1778, 1785, 1792, 1798, 1804, 1810, 1817, 1824, 1831, 1833, 1835, 1843, 1845, 1847,
	1856, 1865, 1879, 1893, 1908, 1924, 1926, 1928, 1936, 1944, 1949, 1954, 1959, 1961, 1963, 1969,
	1976, 1983, 1994, 1999, 2004, 2010, 2017, 2019, 2021, 2023, 2025, 2027, 2029, 2031
    };

    static marpatcl_rtc_string mindt_parser_c_pool = { /* 24 + 2033 bytes */
	mindt_parser_c_pool_length,
	mindt_parser_c_pool_offset,
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
	/* 225 */ "C_STRONG\0"
	/* 226 */ "CDone\0"
	/* 227 */ "CInclude\0"
	/* 228 */ "CL\0"
	/* 229 */ "Cl\0"
	/* 230 */ "COMMAND\0"
	/* 231 */ "COMMENT\0"
	/* 232 */ "comment\0"
	/* 233 */ "CONTINUATION\0"
	/* 234 */ "CR\0"
	/* 235 */ "CStrong\0"
	/* 236 */ "CVdef\0"
	/* 237 */ "CVref\0"
	/* 238 */ "D\0"
	/* 239 */ "d\0"
	/* 240 */ "E\0"
	/* 241 */ "e\0"
	/* 242 */ "F\0"
	/* 243 */ "f\0"
	/* 244 */ "G\0"
	/* 245 */ "g\0"
	/* 246 */ "g_text\0"
	/* 247 */ "H\0"
	/* 248 */ "h\0"
	/* 249 */ "I\0"
	/* 250 */ "i\0"
	/* 251 */ "ILLEGAL_BYTE_0\0"
	/* 252 */ "ILLEGAL_BYTE_193\0"
	/* 253 */ "ILLEGAL_BYTE_240\0"
	/* 254 */ "ILLEGAL_BYTE_241\0"
	/* 255 */ "ILLEGAL_BYTE_242\0"
	/* 256 */ "ILLEGAL_BYTE_243\0"
	/* 257 */ "ILLEGAL_BYTE_244\0"
	/* 258 */ "ILLEGAL_BYTE_245\0"
	/* 259 */ "ILLEGAL_BYTE_246\0"
	/* 260 */ "ILLEGAL_BYTE_247\0"
	/* 261 */ "ILLEGAL_BYTE_248\0"
	/* 262 */ "ILLEGAL_BYTE_249\0"
	/* 263 */ "ILLEGAL_BYTE_250\0"
	/* 264 */ "ILLEGAL_BYTE_251\0"
	/* 265 */ "ILLEGAL_BYTE_252\0"
	/* 266 */ "ILLEGAL_BYTE_253\0"
	/* 267 */ "ILLEGAL_BYTE_254\0"
	/* 268 */ "ILLEGAL_BYTE_255\0"
	/* 269 */ "INCLUDE\0"
	/* 270 */ "include\0"
	/* 271 */ "J\0"
	/* 272 */ "j\0"
	/* 273 */ "K\0"
	/* 274 */ "k\0"
	/* 275 */ "L\0"
	/* 276 */ "l\0"
	/* 277 */ "M\0"
	/* 278 */ "m\0"
	/* 279 */ "markup\0"
	/* 280 */ "N\0"
	/* 281 */ "n\0"
	/* 282 */ "NEWLINE\0"
	/* 283 */ "NO_CFS1\0"
	/* 284 */ "NO_CFS_QUOTE\0"
	/* 285 */ "NO_CMD_FMT_SPACE\0"
	/* 286 */ "O\0"
	/* 287 */ "o\0"
	/* 288 */ "P\0"
	/* 289 */ "p\0"
	/* 290 */ "Q\0"
	/* 291 */ "q\0"
	/* 292 */ "QUOTE\0"
	/* 293 */ "Quote\0"
	/* 294 */ "quote\0"
	/* 295 */ "QUOTED\0"
	/* 296 */ "quoted\0"
	/* 297 */ "QUOTED_ELEM\0"
	/* 298 */ "quoted_elem\0"
	/* 299 */ "QUOTED_ELEMS\0"
	/* 300 */ "quoted_elems\0"
	/* 301 */ "R\0"
	/* 302 */ "r\0"
	/* 303 */ "S\0"
	/* 304 */ "s\0"
	/* 305 */ "SIMPLE\0"
	/* 306 */ "Simple\0"
	/* 307 */ "simple\0"
	/* 308 */ "SPACE\0"
	/* 309 */ "Space\0"
	/* 310 */ "space\0"
	/* 311 */ "SPACE0\0"
	/* 312 */ "SPACE1\0"
	/* 313 */ "strong\0"
	/* 314 */ "T\0"
	/* 315 */ "t\0"
	/* 316 */ "tclword\0"
	/* 317 */ "U\0"
	/* 318 */ "u\0"
	/* 319 */ "UNQUOTED\0"
	/* 320 */ "unquoted\0"
	/* 321 */ "UNQUOTED_ELEM\0"
	/* 322 */ "unquoted_elem\0"
	/* 323 */ "unquoted_elems\0"
	/* 324 */ "unquoted_leader\0"
	/* 325 */ "V\0"
	/* 326 */ "v\0"
	/* 327 */ "VAR_DEF\0"
	/* 328 */ "VAR_REF\0"
	/* 329 */ "vdef\0"
	/* 330 */ "vref\0"
	/* 331 */ "vset\0"
	/* 332 */ "W\0"
	/* 333 */ "w\0"
	/* 334 */ "WHITE\0"
	/* 335 */ "WHITE0\0"
	/* 336 */ "WHITE1\0"
	/* 337 */ "Whitespace\0"
	/* 338 */ "WORD\0"
	/* 339 */ "word\0"
	/* 340 */ "words\0"
	/* 341 */ "WORDS1\0"
	/* 342 */ "X\0"
	/* 343 */ "x\0"
	/* 344 */ "Y\0"
	/* 345 */ "y\0"
	/* 346 */ "Z\0"
	/* 347 */ "z\0"
	/* 348 */ "|\0"
	/* 349 */ "~\0"
    };

    static marpatcl_rtc_event_spec mindt_parser_c_events [3] = {
    // sym, type, active
	{ 2, marpatcl_rtc_event_after, 1 }, // CInclude: macro
	{ 5, marpatcl_rtc_event_after, 1 }, // CVdef: macro
	{ 6, marpatcl_rtc_event_after, 1 }, // CVref: macro
    };

    /*
    ** L0 structures
    */

    static marpatcl_rtc_sym mindt_parser_c_l0_sym_name [343] = { /* 686 bytes */
	/* --- (256) --- --- --- Characters
	 */
	251,  48,  49,  50,  51,  52,  53,  54,  55, 203, 200,  56,  57, 201,  58,  59,
	 60,  61,  62,  63,  64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,
	 76,   0,  77,   1,   2,   3,   4,   5,  78,  79,   6,   7,   8,   9,  10,  11,
	 12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  80,  23,  24,  25,  26,
	 27, 207, 210, 223, 238, 240, 242, 244, 247, 249, 271, 273, 275, 277, 280, 286,
	288, 290, 301, 303, 314, 317, 325, 332, 342, 344, 346,  81,  82,  85, 204, 205,
	206, 208, 211, 224, 239, 241, 243, 245, 248, 250, 272, 274, 276, 278, 281, 287,
	289, 291, 302, 304, 315, 318, 326, 333, 343, 345, 347,  86, 348,  87, 349,  88,
	 89,  90,  91,  92,  93,  94,  95,  96,  97,  98,  99, 100, 101, 102, 103, 104,
	105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120,
	121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136,
	137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152,
	153, 252, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167,
	168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183,
	184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199,
	253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268,

	/* --- (10) --- --- --- ACS: Lexeme
	 */
	216, 226, 227, 229, 235, 236, 237, 293, 306, 309,

	/* --- (1) --- --- --- ACS: Discard
	 */
	337,

	/* --- (10) --- --- --- Lexeme
	 */
	216, 226, 227, 229, 235, 236, 237, 293, 306, 309,

	/* --- (1) --- --- --- Discard
	 */
	337,

	/* --- (65) --- --- --- Internal
	 */
	 34,  42,  43,  32,  37,  41,  44,  83,  84, 202, 232, 270, 313, 331, 209, 212,
	213, 214, 215, 218, 219, 220, 221, 225, 228, 230, 231, 233, 234, 269, 282, 283,
	284, 285, 292, 295, 297, 299, 305, 308, 311, 312, 319, 321, 327, 328, 334, 335,
	336, 338, 341,  29,  30,  31,  33,  35,  45,  36,  38,  39,  40,  46,  47, 222,
	 28
    };

    static marpatcl_rtc_sym mindt_parser_c_l0_rule_definitions [418] = { /* 836 bytes */
	MARPATCL_RCMD_SETUP (9),
	MARPATCL_RCMD_PRIO  (1), 267, 296,                                         /* <Braced>                      ::= <BRACED> */
	MARPATCL_RCMD_PRIO  (1), 268, 306,                                         /* <CDone>                       ::= <CR> */
	MARPATCL_RCMD_PRIO  (1), 269, 307,                                         /* <CInclude>                    ::= <INCLUDE> */
	MARPATCL_RCMD_PRIO  (1), 270, 302,                                         /* <Cl>                          ::= <CL> */
	MARPATCL_RCMD_PRIO  (1), 271, 301,                                         /* <CStrong>                     ::= <C_STRONG> */
	MARPATCL_RCMD_PRIO  (1), 272, 322,                                         /* <CVdef>                       ::= <VAR_DEF> */
	MARPATCL_RCMD_PRIO  (1), 273, 323,                                         /* <CVref>                       ::= <VAR_REF> */
	MARPATCL_RCMD_PRIO  (1), 274, 312,                                         /* <Quote>                       ::= <QUOTE> */
	MARPATCL_RCMD_PRIO  (1), 275, 316,                                         /* <Simple>                      ::= <SIMPLE> */
	MARPATCL_RCMD_PRIO  (1), 276, 319,                                         /* <Space>                       ::= <SPACE1> */
	MARPATCL_RCMD_PRIO  (1), 277, 326,                                         /* <Whitespace>                  ::= <WHITE1> */
	MARPATCL_RCMD_PRIO  (2), 278, 192, 128,                                    /* <@^CLS:<\173\175>>            ::= <@BYTE:<\u00c0>> <@BYTE:<\200>> */
	MARPATCL_RCMD_PRIS  (1)     , 281,                                         /*                               |   <@BRAN:<\1z>> */
	MARPATCL_RCMD_PRIS  (1)     , 124,                                         /*                               |   <@BYTE:<|>> */
	MARPATCL_RCMD_PRIS  (1)     , 340,                                         /*                               |   <@BRAN:<~\177>> */
	MARPATCL_RCMD_PRIS  (2)     , 337, 333,                                    /*                               |   <@BRAN:<\u00c2\u00df>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 224, 282, 333,                               /*                               |   <@BYTE:<\u00e0>> <@BRAN:<\u00a0\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 338, 333, 333,                               /*                               |   <@BRAN:<\u00e1\u00ef>> <@BRAN:<\200\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (6)     , 237, 335, 333, 237, 336, 333,                /*                               |   <@BYTE:<\u00ed>> <@BRAN:<\u00a0\u00af>> <@BRAN:<\200\u00bf>> <@BYTE:<\u00ed>> <@BRAN:<\u00b0\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIO  (2), 279, 192, 128,                                    /* <@^CLS:<\t-\r\40\42\133\135>> ::= <@BYTE:<\u00c0>> <@BYTE:<\200>> */
	MARPATCL_RCMD_PRIS  (1)     , 331,                                         /*                               |   <@BRAN:<\1\10>> */
	MARPATCL_RCMD_PRIS  (1)     , 332,                                         /*                               |   <@BRAN:<\16\37>> */
	MARPATCL_RCMD_PRIS  (1)     , 33,                                          /*                               |   <@BYTE:<!>> */
	MARPATCL_RCMD_PRIS  (1)     , 330,                                         /*                               |   <@BRAN:<#Z>> */
	MARPATCL_RCMD_PRIS  (1)     , 92,                                          /*                               |   <@BYTE:<\134>> */
	MARPATCL_RCMD_PRIS  (1)     , 339,                                         /*                               |   <@BRAN:<^\177>> */
	MARPATCL_RCMD_PRIS  (2)     , 337, 333,                                    /*                               |   <@BRAN:<\u00c2\u00df>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 224, 282, 333,                               /*                               |   <@BYTE:<\u00e0>> <@BRAN:<\u00a0\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 338, 333, 333,                               /*                               |   <@BRAN:<\u00e1\u00ef>> <@BRAN:<\200\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (6)     , 237, 335, 333, 237, 336, 333,                /*                               |   <@BYTE:<\u00ed>> <@BRAN:<\u00a0\u00af>> <@BRAN:<\200\u00bf>> <@BYTE:<\u00ed>> <@BRAN:<\u00b0\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIO  (2), 280, 192, 128,                                    /* <@^CLS:<\t-\r\40\133\135>>    ::= <@BYTE:<\u00c0>> <@BYTE:<\200>> */
	MARPATCL_RCMD_PRIS  (1)     , 331,                                         /*                               |   <@BRAN:<\1\10>> */
	MARPATCL_RCMD_PRIS  (1)     , 332,                                         /*                               |   <@BRAN:<\16\37>> */
	MARPATCL_RCMD_PRIS  (1)     , 329,                                         /*                               |   <@BRAN:<!Z>> */
	MARPATCL_RCMD_PRIS  (1)     , 92,                                          /*                               |   <@BYTE:<\134>> */
	MARPATCL_RCMD_PRIS  (1)     , 339,                                         /*                               |   <@BRAN:<^\177>> */
	MARPATCL_RCMD_PRIS  (2)     , 337, 333,                                    /*                               |   <@BRAN:<\u00c2\u00df>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 224, 282, 333,                               /*                               |   <@BYTE:<\u00e0>> <@BRAN:<\u00a0\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 338, 333, 333,                               /*                               |   <@BRAN:<\u00e1\u00ef>> <@BRAN:<\200\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (6)     , 237, 335, 333, 237, 336, 333,                /*                               |   <@BYTE:<\u00ed>> <@BRAN:<\u00a0\u00af>> <@BRAN:<\200\u00bf>> <@BYTE:<\u00ed>> <@BRAN:<\u00b0\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIO  (1), 281, 331,                                         /* <@BRAN:<\1z>>                 ::= <@BRAN:<\1\10>> */
	MARPATCL_RCMD_PRIS  (1)     , 299,                                         /*                               |   <BRAN<d9-d122>> */
	MARPATCL_RCMD_PRIO  (1), 282, 335,                                         /* <@BRAN:<\u00a0\u00bf>>        ::= <@BRAN:<\u00a0\u00af>> */
	MARPATCL_RCMD_PRIS  (1)     , 336,                                         /*                               |   <@BRAN:<\u00b0\u00bf>> */
	MARPATCL_RCMD_PRIO  (1), 283, 10,                                          /* <@CLS:<\n\r>>                 ::= <@BYTE:<\n>> */
	MARPATCL_RCMD_PRIS  (1)     , 13,                                          /*                               |   <@BYTE:<\r>> */
	MARPATCL_RCMD_PRIO  (1), 284, 334,                                         /* <@CLS:<\t-\r\40>>             ::= <@BRAN:<\t\r>> */
	MARPATCL_RCMD_PRIS  (1)     , 32,                                          /*                               |   <@BYTE:<\40>> */
	MARPATCL_RCMD_PRIO  (2), 285, 92, 123,                                     /* <@STR:<\134\173>>             ::= <@BYTE:<\134>> <@BYTE:<\173>> */
	MARPATCL_RCMD_PRIO  (2), 286, 92, 125,                                     /* <@STR:<\134\175>>             ::= <@BYTE:<\134>> <@BYTE:<\175>> */
	MARPATCL_RCMD_PRIO  (2), 287, 13, 10,                                      /* <@STR:<\r\n>>                 ::= <@BYTE:<\r>> <@BYTE:<\n>> */
	MARPATCL_RCMD_PRIO  (7), 288, 99, 111, 109, 109, 101, 110, 116,            /* <@STR:<comment>>              ::= <@BYTE:<c>> <@BYTE:<o>> <@BYTE:<m>> <@BYTE:<m>> <@BYTE:<e>> <@BYTE:<n>> <@BYTE:<t>> */
	MARPATCL_RCMD_PRIO  (7), 289, 105, 110, 99, 108, 117, 100, 101,            /* <@STR:<include>>              ::= <@BYTE:<i>> <@BYTE:<n>> <@BYTE:<c>> <@BYTE:<l>> <@BYTE:<u>> <@BYTE:<d>> <@BYTE:<e>> */
	MARPATCL_RCMD_PRIO  (6), 290, 115, 116, 114, 111, 110, 103,                /* <@STR:<strong>>               ::= <@BYTE:<s>> <@BYTE:<t>> <@BYTE:<r>> <@BYTE:<o>> <@BYTE:<n>> <@BYTE:<g>> */
	MARPATCL_RCMD_PRIO  (4), 291, 118, 115, 101, 116,                          /* <@STR:<vset>>                 ::= <@BYTE:<v>> <@BYTE:<s>> <@BYTE:<e>> <@BYTE:<t>> */
	MARPATCL_RCMD_PRIO  (1), 292, 278,                                         /* <ANY_UNBRACED>                ::= <@^CLS:<\173\175>> */
	MARPATCL_RCMD_PRIO  (1), 293, 123,                                         /* <BL>                          ::= <@BYTE:<\173>> */
	MARPATCL_RCMD_PRIO  (1), 294, 125,                                         /* <BR>                          ::= <@BYTE:<\175>> */
	MARPATCL_RCMD_PRIO  (1), 295, 285,                                         /* <BRACE_ESCAPED>               ::= <@STR:<\134\173>> */
	MARPATCL_RCMD_PRIS  (1)     , 286,                                         /*                               |   <@STR:<\134\175>> */
	MARPATCL_RCMD_PRIO  (3), 296, 293, 298, 294,                               /* <BRACED>                      ::= <BL> <BRACED_ELEMS> <BR> */
	MARPATCL_RCMD_PRIO  (1), 297, 292,                                         /* <BRACED_ELEM>                 ::= <ANY_UNBRACED> */
	MARPATCL_RCMD_PRIS  (1)     , 296,                                         /*                               |   <BRACED> */
	MARPATCL_RCMD_PRIS  (1)     , 295,                                         /*                               |   <BRACE_ESCAPED> */
	MARPATCL_RCMD_QUN   (298), 297,                                            /* <BRACED_ELEMS>                ::= <BRACED_ELEM> * */
	MARPATCL_RCMD_PRIO  (1), 299, 334,                                         /* <BRAN<d9-d122>>               ::= <@BRAN:<\t\r>> */
	MARPATCL_RCMD_PRIS  (1)     , 300,                                         /*                               |   <BRAN<d14-d122>> */
	MARPATCL_RCMD_PRIO  (1), 300, 332,                                         /* <BRAN<d14-d122>>              ::= <@BRAN:<\16\37>> */
	MARPATCL_RCMD_PRIS  (1)     , 341,                                         /*                               |   <BRAN<d32-d122>> */
	MARPATCL_RCMD_PRIO  (1), 301, 290,                                         /* <C_STRONG>                    ::= <@STR:<strong>> */
	MARPATCL_RCMD_PRIO  (1), 302, 91,                                          /* <CL>                          ::= <@CHR:<\133>> */
	MARPATCL_RCMD_PRIO  (5), 303, 302, 325, 328, 325, 306,                     /* <COMMAND>                     ::= <CL> <WHITE0> <WORDS1> <WHITE0> <CR> */
	MARPATCL_RCMD_PRIO  (7), 304, 302, 325, 288, 326, 327, 325, 306,           /* <COMMENT>                     ::= <CL> <WHITE0> <@STR:<comment>> <WHITE1> <WORD> <WHITE0> <CR> */
	MARPATCL_RCMD_PRIO  (4), 305, 318, 92, 308, 318,                           /* <CONTINUATION>                ::= <SPACE0> <@BYTE:<\134>> <NEWLINE> <SPACE0> */
	MARPATCL_RCMD_PRIO  (1), 306, 93,                                          /* <CR>                          ::= <@CHR:<\135>> */
	MARPATCL_RCMD_PRIO  (7), 307, 302, 325, 289, 326, 327, 325, 306,           /* <INCLUDE>                     ::= <CL> <WHITE0> <@STR:<include>> <WHITE1> <WORD> <WHITE0> <CR> */
	MARPATCL_RCMD_PRIO  (1), 308, 283,                                         /* <NEWLINE>                     ::= <@CLS:<\n\r>> */
	MARPATCL_RCMD_PRIS  (1)     , 287,                                         /*                               |   <@STR:<\r\n>> */
	MARPATCL_RCMD_QUP   (309), 311,                                            /* <NO_CFS1>                     ::= <NO_CMD_FMT_SPACE> + */
	MARPATCL_RCMD_PRIO  (1), 310, 279,                                         /* <NO_CFS_QUOTE>                ::= <@^CLS:<\t-\r\40\42\133\135>> */
	MARPATCL_RCMD_PRIO  (1), 311, 280,                                         /* <NO_CMD_FMT_SPACE>            ::= <@^CLS:<\t-\r\40\133\135>> */
	MARPATCL_RCMD_PRIO  (1), 312, 34,                                          /* <QUOTE>                       ::= <@CHR:<\42>> */
	MARPATCL_RCMD_PRIO  (3), 313, 312, 315, 312,                               /* <QUOTED>                      ::= <QUOTE> <QUOTED_ELEMS> <QUOTE> */
	MARPATCL_RCMD_PRIO  (1), 314, 316,                                         /* <QUOTED_ELEM>                 ::= <SIMPLE> */
	MARPATCL_RCMD_PRIS  (1)     , 319,                                         /*                               |   <SPACE1> */
	MARPATCL_RCMD_PRIS  (1)     , 303,                                         /*                               |   <COMMAND> */
	MARPATCL_RCMD_QUN   (315), 314,                                            /* <QUOTED_ELEMS>                ::= <QUOTED_ELEM> * */
	MARPATCL_RCMD_QUP   (316), 310,                                            /* <SIMPLE>                      ::= <NO_CFS_QUOTE> + */
	MARPATCL_RCMD_PRIO  (1), 317, 284,                                         /* <SPACE>                       ::= <@CLS:<\t-\r\40>> */
	MARPATCL_RCMD_QUN   (318), 317,                                            /* <SPACE0>                      ::= <SPACE> * */
	MARPATCL_RCMD_QUP   (319), 317,                                            /* <SPACE1>                      ::= <SPACE> + */
	MARPATCL_RCMD_QUP   (320), 321,                                            /* <UNQUOTED>                    ::= <UNQUOTED_ELEM> + */
	MARPATCL_RCMD_PRIO  (1), 321, 309,                                         /* <UNQUOTED_ELEM>               ::= <NO_CFS1> */
	MARPATCL_RCMD_PRIS  (1)     , 303,                                         /*                               |   <COMMAND> */
	MARPATCL_RCMD_PRIO  (9), 322, 302, 325, 291, 326, 327, 326, 327, 325, 306, /* <VAR_DEF>                     ::= <CL> <WHITE0> <@STR:<vset>> <WHITE1> <WORD> <WHITE1> <WORD> <WHITE0> <CR> */
	MARPATCL_RCMD_PRIO  (7), 323, 302, 325, 291, 326, 327, 325, 306,           /* <VAR_REF>                     ::= <CL> <WHITE0> <@STR:<vset>> <WHITE1> <WORD> <WHITE0> <CR> */
	MARPATCL_RCMD_PRIO  (1), 324, 319,                                         /* <WHITE>                       ::= <SPACE1> */
	MARPATCL_RCMD_PRIS  (1)     , 304,                                         /*                               |   <COMMENT> */
	MARPATCL_RCMD_PRIS  (1)     , 305,                                         /*                               |   <CONTINUATION> */
	MARPATCL_RCMD_QUN   (325), 324,                                            /* <WHITE0>                      ::= <WHITE> * */
	MARPATCL_RCMD_QUP   (326), 324,                                            /* <WHITE1>                      ::= <WHITE> + */
	MARPATCL_RCMD_PRIO  (1), 327, 296,                                         /* <WORD>                        ::= <BRACED> */
	MARPATCL_RCMD_PRIS  (1)     , 313,                                         /*                               |   <QUOTED> */
	MARPATCL_RCMD_PRIS  (1)     , 320,                                         /*                               |   <UNQUOTED> */
	MARPATCL_RCMD_QUPS  (328), 327, MARPATCL_RCMD_SEP (326),                   /* <WORDS1>                      ::= <WORD> + (<WHITE1>) */
	MARPATCL_RCMD_BRAN  (329), MARPATCL_RCMD_BOXR ( 33, 90),                   /* <@BRAN:<!Z>>                  brange (33 - 90) */
	MARPATCL_RCMD_BRAN  (330), MARPATCL_RCMD_BOXR ( 35, 90),                   /* <@BRAN:<#Z>>                  brange (35 - 90) */
	MARPATCL_RCMD_BRAN  (331), MARPATCL_RCMD_BOXR (  1,  8),                   /* <@BRAN:<\1\10>>               brange (1 - 8) */
	MARPATCL_RCMD_BRAN  (332), MARPATCL_RCMD_BOXR ( 14, 31),                   /* <@BRAN:<\16\37>>              brange (14 - 31) */
	MARPATCL_RCMD_BRAN  (333), MARPATCL_RCMD_BOXR (128,191),                   /* <@BRAN:<\200\u00bf>>          brange (128 - 191) */
	MARPATCL_RCMD_BRAN  (334), MARPATCL_RCMD_BOXR (  9, 13),                   /* <@BRAN:<\t\r>>                brange (9 - 13) */
	MARPATCL_RCMD_BRAN  (335), MARPATCL_RCMD_BOXR (160,175),                   /* <@BRAN:<\u00a0\u00af>>        brange (160 - 175) */
	MARPATCL_RCMD_BRAN  (336), MARPATCL_RCMD_BOXR (176,191),                   /* <@BRAN:<\u00b0\u00bf>>        brange (176 - 191) */
	MARPATCL_RCMD_BRAN  (337), MARPATCL_RCMD_BOXR (194,223),                   /* <@BRAN:<\u00c2\u00df>>        brange (194 - 223) */
	MARPATCL_RCMD_BRAN  (338), MARPATCL_RCMD_BOXR (225,239),                   /* <@BRAN:<\u00e1\u00ef>>        brange (225 - 239) */
	MARPATCL_RCMD_BRAN  (339), MARPATCL_RCMD_BOXR ( 94,127),                   /* <@BRAN:<^\177>>               brange (94 - 127) */
	MARPATCL_RCMD_BRAN  (340), MARPATCL_RCMD_BOXR (126,127),                   /* <@BRAN:<~\177>>               brange (126 - 127) */
	MARPATCL_RCMD_BRAN  (341), MARPATCL_RCMD_BOXR ( 32,122),                   /* <BRAN<d32-d122>>              brange (32 - 122) */
	MARPATCL_RCMD_PRIO  (2), 342, 256, 267,                                    /* <@L0:START>                   ::= <@ACS:Braced> <Braced> */
	MARPATCL_RCMD_PRIS  (2)     , 257, 268,                                    /*                               |   <@ACS:CDone> <CDone> */
	MARPATCL_RCMD_PRIS  (2)     , 258, 269,                                    /*                               |   <@ACS:CInclude> <CInclude> */
	MARPATCL_RCMD_PRIS  (2)     , 259, 270,                                    /*                               |   <@ACS:Cl> <Cl> */
	MARPATCL_RCMD_PRIS  (2)     , 260, 271,                                    /*                               |   <@ACS:CStrong> <CStrong> */
	MARPATCL_RCMD_PRIS  (2)     , 261, 272,                                    /*                               |   <@ACS:CVdef> <CVdef> */
	MARPATCL_RCMD_PRIS  (2)     , 262, 273,                                    /*                               |   <@ACS:CVref> <CVref> */
	MARPATCL_RCMD_PRIS  (2)     , 263, 274,                                    /*                               |   <@ACS:Quote> <Quote> */
	MARPATCL_RCMD_PRIS  (2)     , 264, 275,                                    /*                               |   <@ACS:Simple> <Simple> */
	MARPATCL_RCMD_PRIS  (2)     , 265, 276,                                    /*                               |   <@ACS:Space> <Space> */
	MARPATCL_RCMD_PRIS  (2)     , 266, 277,                                    /*                               |   <@ACS:Whitespace> <Whitespace> */
	MARPATCL_RCMD_DONE  (342)
    };

    static const char* mindt_parser_c_l0idmap_sym [10] = {
	"Braced",
	"CDone",
	"CInclude",
	"Cl",
	"CStrong",
	"CVdef",
	"CVref",
	"Quote",
	"Simple",
	"Space"
    };

    static marpatcl_rtc_sym mindt_parser_c_l0idmap_id [10] = {
	0, 1, 2, 3, 4, 5, 6, 7, 8, 9
    };

    static marpatcl_rtc_symid mindt_parser_c_l0idmap = {
	/* .size   */ 10,
	/* .symbol */ mindt_parser_c_l0idmap_sym,
	/* .id     */ mindt_parser_c_l0idmap_id,
    };

    static marpatcl_rtc_events mindt_parser_c_l0events = {
	/* .size  */ 3,
	/* .data  */ mindt_parser_c_events,
	/* .idmap */ &mindt_parser_c_l0idmap
    };

    static marpatcl_rtc_rules mindt_parser_c_l0 = { /* 48 */
	/* .sname   */  &mindt_parser_c_pool,
	/* .symbols */  { 343, mindt_parser_c_l0_sym_name },
	/* .rules   */  { 0, NULL },
	/* .lhs     */  { 0, NULL },
	/* .rcode   */  mindt_parser_c_l0_rule_definitions,
	/* .events  */  &mindt_parser_c_l0events
    };

    static marpatcl_rtc_sym mindt_parser_c_l0semantics [3] = { /* 6 bytes */
	 MARPATCL_SV_START, MARPATCL_SV_LENGTH,  MARPATCL_SV_VALUE
    };

    /*
    ** G1 structures
    */

    static marpatcl_rtc_sym mindt_parser_c_g1_sym_name [30] = { /* 60 bytes */
	/* --- (10) --- --- --- Terminals
	 */
	216, 226, 227, 229, 235, 236, 237, 293, 306, 309,

	/* --- (20) --- --- --- Structure
	 */
	340, 339, 246, 279, 313, 316, 217, 296, 300, 298, 320, 324, 323, 322, 307, 310,
	294, 329, 330, 270
    };

    static marpatcl_rtc_sym mindt_parser_c_g1_rule_name [32] = { /* 64 bytes */
	340, 339, 339, 246, 246, 279, 279, 279, 279, 313, 316, 316, 316, 217, 296, 300,
	298, 298, 298, 320, 324, 324, 323, 322, 322, 322, 307, 310, 294, 329, 330, 270
    };

    static marpatcl_rtc_sym mindt_parser_c_g1_rule_lhs [32] = { /* 64 bytes */
	10, 11, 11, 12, 12, 13, 13, 13, 13, 14, 15, 15, 15, 16, 17, 18,
	19, 19, 19, 20, 21, 21, 22, 23, 23, 23, 24, 25, 26, 27, 28, 29
    };

    static marpatcl_rtc_sym mindt_parser_c_g1_rule_definitions [89] = { /* 178 bytes */
	MARPATCL_RCMD_SETUP (4),
	MARPATCL_RCMD_QUN   (10), 11,             /* <words>           ::= <word> * */
	MARPATCL_RCMD_PRIO  (1), 11, 12,          /* <word>            ::= <g_text> */
	MARPATCL_RCMD_PRIS  (1)    , 13,          /*                   |   <markup> */
	MARPATCL_RCMD_PRIO  (1), 12, 24,          /* <g_text>          ::= <simple> */
	MARPATCL_RCMD_PRIS  (1)    , 26,          /*                   |   <quote> */
	MARPATCL_RCMD_PRIO  (1), 13, 14,          /* <markup>          ::= <strong> */
	MARPATCL_RCMD_PRIS  (1)    , 27,          /*                   |   <vdef> */
	MARPATCL_RCMD_PRIS  (1)    , 28,          /*                   |   <vref> */
	MARPATCL_RCMD_PRIS  (1)    , 29,          /*                   |   <include> */
	MARPATCL_RCMD_PRIO  (4), 14, 3, 4, 15, 1, /* <strong>          ::= <Cl> <CStrong> <tclword> <CDone> */
	MARPATCL_RCMD_PRIO  (1), 15, 16,          /* <tclword>         ::= <braced> */
	MARPATCL_RCMD_PRIS  (1)    , 17,          /*                   |   <quoted> */
	MARPATCL_RCMD_PRIS  (1)    , 20,          /*                   |   <unquoted> */
	MARPATCL_RCMD_PRIO  (1), 16, 0,           /* <braced>          ::= <Braced> */
	MARPATCL_RCMD_PRIO  (3), 17, 7, 18, 7,    /* <quoted>          ::= <Quote> <quoted_elems> <Quote> */
	MARPATCL_RCMD_QUN   (18), 19,             /* <quoted_elems>    ::= <quoted_elem> * */
	MARPATCL_RCMD_PRIO  (1), 19, 24,          /* <quoted_elem>     ::= <simple> */
	MARPATCL_RCMD_PRIS  (1)    , 25,          /*                   |   <space> */
	MARPATCL_RCMD_PRIS  (1)    , 13,          /*                   |   <markup> */
	MARPATCL_RCMD_PRIO  (2), 20, 21, 22,      /* <unquoted>        ::= <unquoted_leader> <unquoted_elems> */
	MARPATCL_RCMD_PRIO  (1), 21, 24,          /* <unquoted_leader> ::= <simple> */
	MARPATCL_RCMD_PRIS  (1)    , 13,          /*                   |   <markup> */
	MARPATCL_RCMD_QUN   (22), 23,             /* <unquoted_elems>  ::= <unquoted_elem> * */
	MARPATCL_RCMD_PRIO  (1), 23, 24,          /* <unquoted_elem>   ::= <simple> */
	MARPATCL_RCMD_PRIS  (1)    , 13,          /*                   |   <markup> */
	MARPATCL_RCMD_PRIS  (1)    , 26,          /*                   |   <quote> */
	MARPATCL_RCMD_PRIO  (1), 24, 8,           /* <simple>          ::= <Simple> */
	MARPATCL_RCMD_PRIO  (1), 25, 9,           /* <space>           ::= <Space> */
	MARPATCL_RCMD_PRIO  (1), 26, 7,           /* <quote>           ::= <Quote> */
	MARPATCL_RCMD_PRIO  (1), 27, 5,           /* <vdef>            ::= <CVdef> */
	MARPATCL_RCMD_PRIO  (1), 28, 6,           /* <vref>            ::= <CVref> */
	MARPATCL_RCMD_PRIO  (1), 29, 2,           /* <include>         ::= <CInclude> */
	MARPATCL_RCMD_DONE  (10)
    };

    static marpatcl_rtc_rules mindt_parser_c_g1 = { /* 48 */
	/* .sname   */  &mindt_parser_c_pool,
	/* .symbols */  { 30, mindt_parser_c_g1_sym_name },
	/* .rules   */  { 32, mindt_parser_c_g1_rule_name },
	/* .lhs     */  { 32, mindt_parser_c_g1_rule_lhs },
	/* .rcode   */  mindt_parser_c_g1_rule_definitions,
	/* .events  */  0
    };

    static marpatcl_rtc_sym mindt_parser_c_g1semantics [4] = { /* 8 bytes */
	/* --- (1) --- --- --- Tag
	 */
	MARPATCL_S_SINGLE,

	/* --- (3) --- --- --- Common Semantics
	 */
	2, MARPATCL_SV_RULE_NAME, MARPATCL_SV_VALUE
    };

    static marpatcl_rtc_sym mindt_parser_c_g1masking [40] = { /* 80 bytes */
	/* --- (1) --- --- --- Tag
	 */
	MARPATCL_S_PER,

	/* --- (32) --- --- --- Mask Offsets
	 */
	 0,  0,  0,  0,  0,  0,  0,  0,  0, 35,  0,  0,  0,  0, 32,  0,
	 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,

	/* --- (3) --- --- --- Mask Data
	 */
	/* 32 */ 2, 0, 2,
	/* 35 */ 3, 0, 1, 3
    };

    /*
    ** Parser definition
    */

    static marpatcl_rtc_sym mindt_parser_c_always [1] = { /* 2 bytes */
	10
    };

    static marpatcl_rtc_spec mindt_parser_c_spec = { /* 72 */
	/* .lexemes    */  10,
	/* .discards   */  1,
	/* .l_symbols  */  343,
	/* .g_symbols  */  30,
	/* .always     */  { 1, mindt_parser_c_always },
	/* .l0         */  &mindt_parser_c_l0,
	/* .g1         */  &mindt_parser_c_g1,
	/* .l0semantic */  { 3, mindt_parser_c_l0semantics },
	/* .g1semantic */  { 4, mindt_parser_c_g1semantics },
	/* .g1mask     */  { 40, mindt_parser_c_g1masking }
    };
    /* --- end of generated data structures --- */
}

# # ## ### ##### ######## ############# #####################
## Class exposing the grammar engine.

critcl::literals::def mindt_parser_c_event {
    u0 "macro"
    u1 "macro"
    u2 "macro"
} +list

critcl::class def mindt::parser::c {

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
	instance->state = marpatcl_rtc_cons (&mindt_parser_c_spec,
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
			      (marpatcl_events_to_names) mindt_parser_c_event_list);
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