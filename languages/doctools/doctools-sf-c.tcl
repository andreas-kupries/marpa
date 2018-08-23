# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017-present Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                             http://core.tcl.tk/akupries/
##
# (c) 2018 Grammar doctools::parser::sf::c 1 By Andreas Kupries
##
##	`marpa::runtime::c`-derived Parser for grammar "doctools::parser::sf::c".
##	Generated On Wed Aug 22 16:53:01 PDT 2018
##		  By andreask@ten
##		 Via marpa-gen
##
#* Space taken: 6003 bytes
##
#* Statistics
#* L0
#* - #Symbols:   344
#* - #Lexemes:   11
#* - #Discards:  0
#* - #Always:    0
#* - #Rule Insn: 134 (+2: setup, start-sym)
#* - #Rules:     534 (>= insn, brange)
#* G1
#* - #Symbols:   32
#* - #Rule Insn: 40 (+2: setup, start-sym)
#* - #Rules:     40 (match insn)

package provide doctools::parser::sf::c 1

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5 ;# apply, lassign, ...
package require critcl 3.1

critcl::buildrequirement {
    package require critcl::class
    package require critcl::cutil
}

if {![critcl::compiling]} {
    error "Unable to build doctools::parser::sf::c, no compiler found."
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
    ** Shared string pool (706 bytes lengths over 353 entries)
    **                    (706 bytes offsets -----^)
    **                    (2033 bytes character content)
    */

    static marpatcl_rtc_size doctools_parser_sf_c_pool_length [353] = { /* 706 bytes */
	 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
	 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  9,  5,  5,  8,
	 6,  9, 10, 11, 11, 11, 11, 11, 11,  6, 22, 19, 10,  7,  8,  8,
	 2,  2,  2,  2,  2,  2,  2,  3,  3,  3,  3,  3,  3,  3,  3,  3,
	 3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,
	 3,  4,  4,  8,  8,  8,  8,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  2,  2,  4,  2,  1,  1,
	 1,  1,  1, 12,  1,  1,  2,  2, 13,  6,  6,  6, 11, 12, 13, 14,
	14,  1,  1,  2,  7,  7,  7, 12,  2,  1,  1,  1,  1,  7,  7,  7,
	 1,  1,  4,  1,  1,  1,  1,  1,  1, 14, 16, 16, 16, 16, 16, 16,
	16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,  7,  7,  7,  1,  1,
	 1,  1,  1,  1,  1,  1,  1,  1,  7, 12, 16,  1,  1,  1,  1,  4,
	 1,  1,  6,  6,  5,  5,  5,  6,  6, 11, 12,  1,  1,  7,  1,  1,
	 6,  6,  6,  5,  5,  5,  6,  6,  5,  4,  1,  1,  1,  1,  6,  8,
	13, 14, 13,  7,  7,  7,  1,  1,  5,  7,  7,  7,  4,  4,  4,  4,
	 1,  1,  5,  5,  6,  6,  4,  4,  6,  1,  1,  1,  1,  1,  1,  1,
	 1
    };

    static marpatcl_rtc_size doctools_parser_sf_c_pool_offset [353] = { /* 706 bytes */
	   0,    2,    4,    6,    8,   10,   12,   14,   16,   18,   20,   22,   24,   26,   28,   30,
	  32,   34,   36,   38,   40,   42,   44,   46,   48,   50,   52,   54,   56,   66,   72,   78,
	  87,   94,  104,  115,  127,  139,  151,  163,  175,  187,  194,  217,  237,  248,  256,  265,
	 274,  277,  280,  283,  286,  289,  292,  295,  299,  303,  307,  311,  315,  319,  323,  327,
	 331,  335,  339,  343,  347,  351,  355,  359,  363,  367,  371,  375,  379,  383,  387,  391,
	 395,  399,  404,  409,  418,  427,  436,  445,  450,  455,  460,  465,  470,  475,  480,  485,
	 490,  495,  500,  505,  510,  515,  520,  525,  530,  535,  540,  545,  550,  555,  560,  565,
	 570,  575,  580,  585,  590,  595,  600,  605,  610,  615,  620,  625,  630,  635,  640,  645,
	 650,  655,  660,  665,  670,  675,  680,  685,  690,  695,  700,  705,  710,  715,  720,  725,
	 730,  735,  740,  745,  750,  755,  760,  765,  770,  775,  780,  785,  790,  795,  800,  805,
	 810,  815,  820,  825,  830,  835,  840,  845,  850,  855,  860,  865,  870,  875,  880,  885,
	 890,  895,  900,  905,  910,  915,  920,  925,  930,  935,  940,  945,  950,  955,  960,  965,
	 970,  975,  980,  985,  990,  995, 1000, 1005, 1010, 1015, 1020, 1023, 1026, 1031, 1034, 1036,
	1038, 1040, 1042, 1044, 1057, 1059, 1061, 1064, 1067, 1081, 1088, 1095, 1102, 1114, 1127, 1141,
	1156, 1171, 1173, 1175, 1178, 1186, 1194, 1202, 1215, 1218, 1220, 1222, 1224, 1226, 1234, 1242,
	1250, 1252, 1254, 1259, 1261, 1263, 1265, 1267, 1269, 1271, 1286, 1303, 1320, 1337, 1354, 1371,
	1388, 1405, 1422, 1439, 1456, 1473, 1490, 1507, 1524, 1541, 1558, 1575, 1583, 1591, 1599, 1601,
	1603, 1605, 1607, 1609, 1611, 1613, 1615, 1617, 1619, 1627, 1640, 1657, 1659, 1661, 1663, 1665,
	1670, 1672, 1674, 1681, 1688, 1694, 1700, 1706, 1713, 1720, 1732, 1745, 1747, 1749, 1757, 1759,
	1761, 1768, 1775, 1782, 1788, 1794, 1800, 1807, 1814, 1820, 1825, 1827, 1829, 1831, 1833, 1840,
	1849, 1863, 1878, 1892, 1900, 1908, 1916, 1918, 1920, 1926, 1934, 1942, 1950, 1955, 1960, 1965,
	1970, 1972, 1974, 1980, 1986, 1993, 2000, 2005, 2010, 2017, 2019, 2021, 2023, 2025, 2027, 2029,
	2031
    };

    static marpatcl_rtc_string doctools_parser_sf_c_pool = { /* 24 + 2033 bytes */
	doctools_parser_sf_c_pool_length,
	doctools_parser_sf_c_pool_offset,
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
	/*  42 */ "[\\t-\\r\\40\\42\\133-\\135]\0"
	/*  43 */ "[\\t-\\r\\40\\133-\\135]\0"
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
	/*  83 */ "\\134\\133\0"
	/*  84 */ "\\134\\135\0"
	/*  85 */ "\\134\\173\0"
	/*  86 */ "\\134\\175\0"
	/*  87 */ "\\135\0"
	/*  88 */ "\\173\0"
	/*  89 */ "\\175\0"
	/*  90 */ "\\177\0"
	/*  91 */ "\\200\0"
	/*  92 */ "\\201\0"
	/*  93 */ "\\202\0"
	/*  94 */ "\\203\0"
	/*  95 */ "\\204\0"
	/*  96 */ "\\205\0"
	/*  97 */ "\\206\0"
	/*  98 */ "\\207\0"
	/*  99 */ "\\210\0"
	/* 100 */ "\\211\0"
	/* 101 */ "\\212\0"
	/* 102 */ "\\213\0"
	/* 103 */ "\\214\0"
	/* 104 */ "\\215\0"
	/* 105 */ "\\216\0"
	/* 106 */ "\\217\0"
	/* 107 */ "\\220\0"
	/* 108 */ "\\221\0"
	/* 109 */ "\\222\0"
	/* 110 */ "\\223\0"
	/* 111 */ "\\224\0"
	/* 112 */ "\\225\0"
	/* 113 */ "\\226\0"
	/* 114 */ "\\227\0"
	/* 115 */ "\\230\0"
	/* 116 */ "\\231\0"
	/* 117 */ "\\232\0"
	/* 118 */ "\\233\0"
	/* 119 */ "\\234\0"
	/* 120 */ "\\235\0"
	/* 121 */ "\\236\0"
	/* 122 */ "\\237\0"
	/* 123 */ "\\240\0"
	/* 124 */ "\\241\0"
	/* 125 */ "\\242\0"
	/* 126 */ "\\243\0"
	/* 127 */ "\\244\0"
	/* 128 */ "\\245\0"
	/* 129 */ "\\246\0"
	/* 130 */ "\\247\0"
	/* 131 */ "\\250\0"
	/* 132 */ "\\251\0"
	/* 133 */ "\\252\0"
	/* 134 */ "\\253\0"
	/* 135 */ "\\254\0"
	/* 136 */ "\\255\0"
	/* 137 */ "\\256\0"
	/* 138 */ "\\257\0"
	/* 139 */ "\\260\0"
	/* 140 */ "\\261\0"
	/* 141 */ "\\262\0"
	/* 142 */ "\\263\0"
	/* 143 */ "\\264\0"
	/* 144 */ "\\265\0"
	/* 145 */ "\\266\0"
	/* 146 */ "\\267\0"
	/* 147 */ "\\270\0"
	/* 148 */ "\\271\0"
	/* 149 */ "\\272\0"
	/* 150 */ "\\273\0"
	/* 151 */ "\\274\0"
	/* 152 */ "\\275\0"
	/* 153 */ "\\276\0"
	/* 154 */ "\\277\0"
	/* 155 */ "\\300\0"
	/* 156 */ "\\302\0"
	/* 157 */ "\\303\0"
	/* 158 */ "\\304\0"
	/* 159 */ "\\305\0"
	/* 160 */ "\\306\0"
	/* 161 */ "\\307\0"
	/* 162 */ "\\310\0"
	/* 163 */ "\\311\0"
	/* 164 */ "\\312\0"
	/* 165 */ "\\313\0"
	/* 166 */ "\\314\0"
	/* 167 */ "\\315\0"
	/* 168 */ "\\316\0"
	/* 169 */ "\\317\0"
	/* 170 */ "\\320\0"
	/* 171 */ "\\321\0"
	/* 172 */ "\\322\0"
	/* 173 */ "\\323\0"
	/* 174 */ "\\324\0"
	/* 175 */ "\\325\0"
	/* 176 */ "\\326\0"
	/* 177 */ "\\327\0"
	/* 178 */ "\\330\0"
	/* 179 */ "\\331\0"
	/* 180 */ "\\332\0"
	/* 181 */ "\\333\0"
	/* 182 */ "\\334\0"
	/* 183 */ "\\335\0"
	/* 184 */ "\\336\0"
	/* 185 */ "\\337\0"
	/* 186 */ "\\340\0"
	/* 187 */ "\\341\0"
	/* 188 */ "\\342\0"
	/* 189 */ "\\343\0"
	/* 190 */ "\\344\0"
	/* 191 */ "\\345\0"
	/* 192 */ "\\346\0"
	/* 193 */ "\\347\0"
	/* 194 */ "\\350\0"
	/* 195 */ "\\351\0"
	/* 196 */ "\\352\0"
	/* 197 */ "\\353\0"
	/* 198 */ "\\354\0"
	/* 199 */ "\\355\0"
	/* 200 */ "\\356\0"
	/* 201 */ "\\357\0"
	/* 202 */ "\\n\0"
	/* 203 */ "\\r\0"
	/* 204 */ "\\r\\n\0"
	/* 205 */ "\\t\0"
	/* 206 */ "^\0"
	/* 207 */ "_\0"
	/* 208 */ "`\0"
	/* 209 */ "A\0"
	/* 210 */ "a\0"
	/* 211 */ "ANY_UNBRACED\0"
	/* 212 */ "B\0"
	/* 213 */ "b\0"
	/* 214 */ "BL\0"
	/* 215 */ "BR\0"
	/* 216 */ "BRACE_ESCAPED\0"
	/* 217 */ "BRACED\0"
	/* 218 */ "Braced\0"
	/* 219 */ "braced\0"
	/* 220 */ "BRACED_ELEM\0"
	/* 221 */ "BRACED_ELEMS\0"
	/* 222 */ "BRAN<d9-d122>\0"
	/* 223 */ "BRAN<d14-d122>\0"
	/* 224 */ "BRAN<d32-d122>\0"
	/* 225 */ "C\0"
	/* 226 */ "c\0"
	/* 227 */ "CL\0"
	/* 228 */ "COMMAND\0"
	/* 229 */ "COMMENT\0"
	/* 230 */ "comment\0"
	/* 231 */ "CONTINUATION\0"
	/* 232 */ "CR\0"
	/* 233 */ "D\0"
	/* 234 */ "d\0"
	/* 235 */ "E\0"
	/* 236 */ "e\0"
	/* 237 */ "ESCAPED\0"
	/* 238 */ "Escaped\0"
	/* 239 */ "escaped\0"
	/* 240 */ "F\0"
	/* 241 */ "f\0"
	/* 242 */ "form\0"
	/* 243 */ "G\0"
	/* 244 */ "g\0"
	/* 245 */ "H\0"
	/* 246 */ "h\0"
	/* 247 */ "I\0"
	/* 248 */ "i\0"
	/* 249 */ "ILLEGAL_BYTE_0\0"
	/* 250 */ "ILLEGAL_BYTE_193\0"
	/* 251 */ "ILLEGAL_BYTE_240\0"
	/* 252 */ "ILLEGAL_BYTE_241\0"
	/* 253 */ "ILLEGAL_BYTE_242\0"
	/* 254 */ "ILLEGAL_BYTE_243\0"
	/* 255 */ "ILLEGAL_BYTE_244\0"
	/* 256 */ "ILLEGAL_BYTE_245\0"
	/* 257 */ "ILLEGAL_BYTE_246\0"
	/* 258 */ "ILLEGAL_BYTE_247\0"
	/* 259 */ "ILLEGAL_BYTE_248\0"
	/* 260 */ "ILLEGAL_BYTE_249\0"
	/* 261 */ "ILLEGAL_BYTE_250\0"
	/* 262 */ "ILLEGAL_BYTE_251\0"
	/* 263 */ "ILLEGAL_BYTE_252\0"
	/* 264 */ "ILLEGAL_BYTE_253\0"
	/* 265 */ "ILLEGAL_BYTE_254\0"
	/* 266 */ "ILLEGAL_BYTE_255\0"
	/* 267 */ "INCLUDE\0"
	/* 268 */ "Include\0"
	/* 269 */ "include\0"
	/* 270 */ "J\0"
	/* 271 */ "j\0"
	/* 272 */ "K\0"
	/* 273 */ "k\0"
	/* 274 */ "L\0"
	/* 275 */ "l\0"
	/* 276 */ "M\0"
	/* 277 */ "m\0"
	/* 278 */ "N\0"
	/* 279 */ "n\0"
	/* 280 */ "NEWLINE\0"
	/* 281 */ "NO_CFS_QUOTE\0"
	/* 282 */ "NO_CMD_FMT_SPACE\0"
	/* 283 */ "O\0"
	/* 284 */ "o\0"
	/* 285 */ "P\0"
	/* 286 */ "p\0"
	/* 287 */ "path\0"
	/* 288 */ "Q\0"
	/* 289 */ "q\0"
	/* 290 */ "q_elem\0"
	/* 291 */ "q_list\0"
	/* 292 */ "QUOTE\0"
	/* 293 */ "Quote\0"
	/* 294 */ "quote\0"
	/* 295 */ "QUOTED\0"
	/* 296 */ "quoted\0"
	/* 297 */ "QUOTED_ELEM\0"
	/* 298 */ "QUOTED_ELEMS\0"
	/* 299 */ "R\0"
	/* 300 */ "r\0"
	/* 301 */ "recurse\0"
	/* 302 */ "S\0"
	/* 303 */ "s\0"
	/* 304 */ "SIMPLE\0"
	/* 305 */ "Simple\0"
	/* 306 */ "simple\0"
	/* 307 */ "SPACE\0"
	/* 308 */ "Space\0"
	/* 309 */ "space\0"
	/* 310 */ "SPACE0\0"
	/* 311 */ "SPACE1\0"
	/* 312 */ "Start\0"
	/* 313 */ "Stop\0"
	/* 314 */ "T\0"
	/* 315 */ "t\0"
	/* 316 */ "U\0"
	/* 317 */ "u\0"
	/* 318 */ "unquot\0"
	/* 319 */ "UNQUOTED\0"
	/* 320 */ "UNQUOTED_ELEM\0"
	/* 321 */ "UNQUOTED_ELEMS\0"
	/* 322 */ "UNQUOTED_LEAD\0"
	/* 323 */ "uq_elem\0"
	/* 324 */ "uq_lead\0"
	/* 325 */ "uq_list\0"
	/* 326 */ "V\0"
	/* 327 */ "v\0"
	/* 328 */ "value\0"
	/* 329 */ "var_def\0"
	/* 330 */ "var_ref\0"
	/* 331 */ "varname\0"
	/* 332 */ "vars\0"
	/* 333 */ "VSET\0"
	/* 334 */ "Vset\0"
	/* 335 */ "vset\0"
	/* 336 */ "W\0"
	/* 337 */ "w\0"
	/* 338 */ "WHITE\0"
	/* 339 */ "White\0"
	/* 340 */ "WHITE0\0"
	/* 341 */ "WHITE1\0"
	/* 342 */ "WORD\0"
	/* 343 */ "Word\0"
	/* 344 */ "WORDS1\0"
	/* 345 */ "X\0"
	/* 346 */ "x\0"
	/* 347 */ "Y\0"
	/* 348 */ "y\0"
	/* 349 */ "Z\0"
	/* 350 */ "z\0"
	/* 351 */ "|\0"
	/* 352 */ "~\0"
    };

    /*
    ** L0 structures
    */

    static marpatcl_rtc_sym doctools_parser_sf_c_l0_sym_name [344] = { /* 688 bytes */
	/* --- (256) --- --- --- Characters
	 */
	249,  48,  49,  50,  51,  52,  53,  54,  55, 205, 202,  56,  57, 203,  58,  59,
	 60,  61,  62,  63,  64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,
	 76,   0,  77,   1,   2,   3,   4,   5,  78,  79,   6,   7,   8,   9,  10,  11,
	 12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  80,  23,  24,  25,  26,
	 27, 209, 212, 225, 233, 235, 240, 243, 245, 247, 270, 272, 274, 276, 278, 283,
	285, 288, 299, 302, 314, 316, 326, 336, 345, 347, 349,  81,  82,  87, 206, 207,
	208, 210, 213, 226, 234, 236, 241, 244, 246, 248, 271, 273, 275, 277, 279, 284,
	286, 289, 300, 303, 315, 317, 327, 337, 346, 348, 350,  88, 351,  89, 352,  90,
	 91,  92,  93,  94,  95,  96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106,
	107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122,
	123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138,
	139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154,
	155, 250, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169,
	170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185,
	186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201,
	251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266,

	/* --- (11) --- --- --- ACS: Lexeme
	 */
	218, 238, 268, 293, 305, 308, 312, 313, 334, 339, 343,

	/* --- (11) --- --- --- Lexeme
	 */
	218, 238, 268, 293, 305, 308, 312, 313, 334, 339, 343,

	/* --- (66) --- --- --- Internal
	 */
	 34,  42,  43,  32,  37,  41,  44,  83,  84,  85,  86, 204, 230, 269, 335, 211,
	214, 215, 216, 217, 220, 221, 222, 223, 227, 228, 229, 231, 232, 237, 267, 280,
	281, 282, 292, 295, 297, 298, 304, 307, 310, 311, 319, 320, 321, 322, 333, 338,
	340, 341, 342, 344,  29,  30,  31,  33,  35,  45,  36,  38,  39,  40,  46,  47,
	224,  28
    };

    static marpatcl_rtc_sym doctools_parser_sf_c_l0_rule_definitions [408] = { /* 816 bytes */
	MARPATCL_RCMD_SETUP (7),
	MARPATCL_RCMD_PRIO  (1), 267, 297,                               /* <Braced>                       ::= <BRACED> */
	MARPATCL_RCMD_PRIO  (1), 268, 307,                               /* <Escaped>                      ::= <ESCAPED> */
	MARPATCL_RCMD_PRIO  (1), 269, 308,                               /* <Include>                      ::= <INCLUDE> */
	MARPATCL_RCMD_PRIO  (1), 270, 312,                               /* <Quote>                        ::= <QUOTE> */
	MARPATCL_RCMD_PRIO  (1), 271, 316,                               /* <Simple>                       ::= <SIMPLE> */
	MARPATCL_RCMD_PRIO  (1), 272, 319,                               /* <Space>                        ::= <SPACE1> */
	MARPATCL_RCMD_PRIO  (1), 273, 302,                               /* <Start>                        ::= <CL> */
	MARPATCL_RCMD_PRIO  (1), 274, 306,                               /* <Stop>                         ::= <CR> */
	MARPATCL_RCMD_PRIO  (1), 275, 324,                               /* <Vset>                         ::= <VSET> */
	MARPATCL_RCMD_PRIO  (1), 276, 327,                               /* <White>                        ::= <WHITE1> */
	MARPATCL_RCMD_PRIO  (1), 277, 328,                               /* <Word>                         ::= <WORD> */
	MARPATCL_RCMD_PRIO  (2), 278, 192, 128,                          /* <@^CLS:<\173\175>>             ::= <@BYTE:<\u00c0>> <@BYTE:<\200>> */
	MARPATCL_RCMD_PRIS  (1)     , 281,                               /*                                |   <@BRAN:<\1z>> */
	MARPATCL_RCMD_PRIS  (1)     , 124,                               /*                                |   <@BYTE:<|>> */
	MARPATCL_RCMD_PRIS  (1)     , 341,                               /*                                |   <@BRAN:<~\177>> */
	MARPATCL_RCMD_PRIS  (2)     , 338, 334,                          /*                                |   <@BRAN:<\u00c2\u00df>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 224, 282, 334,                     /*                                |   <@BYTE:<\u00e0>> <@BRAN:<\u00a0\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 339, 334, 334,                     /*                                |   <@BRAN:<\u00e1\u00ef>> <@BRAN:<\200\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (6)     , 237, 336, 334, 237, 337, 334,      /*                                |   <@BYTE:<\u00ed>> <@BRAN:<\u00a0\u00af>> <@BRAN:<\200\u00bf>> <@BYTE:<\u00ed>> <@BRAN:<\u00b0\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIO  (2), 279, 192, 128,                          /* <@^CLS:<\t-\r\40\42\133-\135>> ::= <@BYTE:<\u00c0>> <@BYTE:<\200>> */
	MARPATCL_RCMD_PRIS  (1)     , 332,                               /*                                |   <@BRAN:<\1\10>> */
	MARPATCL_RCMD_PRIS  (1)     , 333,                               /*                                |   <@BRAN:<\16\37>> */
	MARPATCL_RCMD_PRIS  (1)     , 33,                                /*                                |   <@BYTE:<!>> */
	MARPATCL_RCMD_PRIS  (1)     , 331,                               /*                                |   <@BRAN:<#Z>> */
	MARPATCL_RCMD_PRIS  (1)     , 340,                               /*                                |   <@BRAN:<^\177>> */
	MARPATCL_RCMD_PRIS  (2)     , 338, 334,                          /*                                |   <@BRAN:<\u00c2\u00df>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 224, 282, 334,                     /*                                |   <@BYTE:<\u00e0>> <@BRAN:<\u00a0\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 339, 334, 334,                     /*                                |   <@BRAN:<\u00e1\u00ef>> <@BRAN:<\200\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (6)     , 237, 336, 334, 237, 337, 334,      /*                                |   <@BYTE:<\u00ed>> <@BRAN:<\u00a0\u00af>> <@BRAN:<\200\u00bf>> <@BYTE:<\u00ed>> <@BRAN:<\u00b0\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIO  (2), 280, 192, 128,                          /* <@^CLS:<\t-\r\40\133-\135>>    ::= <@BYTE:<\u00c0>> <@BYTE:<\200>> */
	MARPATCL_RCMD_PRIS  (1)     , 332,                               /*                                |   <@BRAN:<\1\10>> */
	MARPATCL_RCMD_PRIS  (1)     , 333,                               /*                                |   <@BRAN:<\16\37>> */
	MARPATCL_RCMD_PRIS  (1)     , 330,                               /*                                |   <@BRAN:<!Z>> */
	MARPATCL_RCMD_PRIS  (1)     , 340,                               /*                                |   <@BRAN:<^\177>> */
	MARPATCL_RCMD_PRIS  (2)     , 338, 334,                          /*                                |   <@BRAN:<\u00c2\u00df>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 224, 282, 334,                     /*                                |   <@BYTE:<\u00e0>> <@BRAN:<\u00a0\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 339, 334, 334,                     /*                                |   <@BRAN:<\u00e1\u00ef>> <@BRAN:<\200\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (6)     , 237, 336, 334, 237, 337, 334,      /*                                |   <@BYTE:<\u00ed>> <@BRAN:<\u00a0\u00af>> <@BRAN:<\200\u00bf>> <@BYTE:<\u00ed>> <@BRAN:<\u00b0\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIO  (1), 281, 332,                               /* <@BRAN:<\1z>>                  ::= <@BRAN:<\1\10>> */
	MARPATCL_RCMD_PRIS  (1)     , 300,                               /*                                |   <BRAN<d9-d122>> */
	MARPATCL_RCMD_PRIO  (1), 282, 336,                               /* <@BRAN:<\u00a0\u00bf>>         ::= <@BRAN:<\u00a0\u00af>> */
	MARPATCL_RCMD_PRIS  (1)     , 337,                               /*                                |   <@BRAN:<\u00b0\u00bf>> */
	MARPATCL_RCMD_PRIO  (1), 283, 10,                                /* <@CLS:<\n\r>>                  ::= <@BYTE:<\n>> */
	MARPATCL_RCMD_PRIS  (1)     , 13,                                /*                                |   <@BYTE:<\r>> */
	MARPATCL_RCMD_PRIO  (1), 284, 335,                               /* <@CLS:<\t-\r\40>>              ::= <@BRAN:<\t\r>> */
	MARPATCL_RCMD_PRIS  (1)     , 32,                                /*                                |   <@BYTE:<\40>> */
	MARPATCL_RCMD_PRIO  (2), 285, 92, 91,                            /* <@STR:<\134\133>>              ::= <@BYTE:<\134>> <@BYTE:<\133>> */
	MARPATCL_RCMD_PRIO  (2), 286, 92, 93,                            /* <@STR:<\134\135>>              ::= <@BYTE:<\134>> <@BYTE:<\135>> */
	MARPATCL_RCMD_PRIO  (2), 287, 92, 123,                           /* <@STR:<\134\173>>              ::= <@BYTE:<\134>> <@BYTE:<\173>> */
	MARPATCL_RCMD_PRIO  (2), 288, 92, 125,                           /* <@STR:<\134\175>>              ::= <@BYTE:<\134>> <@BYTE:<\175>> */
	MARPATCL_RCMD_PRIO  (2), 289, 13, 10,                            /* <@STR:<\r\n>>                  ::= <@BYTE:<\r>> <@BYTE:<\n>> */
	MARPATCL_RCMD_PRIO  (7), 290, 99, 111, 109, 109, 101, 110, 116,  /* <@STR:<comment>>               ::= <@BYTE:<c>> <@BYTE:<o>> <@BYTE:<m>> <@BYTE:<m>> <@BYTE:<e>> <@BYTE:<n>> <@BYTE:<t>> */
	MARPATCL_RCMD_PRIO  (7), 291, 105, 110, 99, 108, 117, 100, 101,  /* <@STR:<include>>               ::= <@BYTE:<i>> <@BYTE:<n>> <@BYTE:<c>> <@BYTE:<l>> <@BYTE:<u>> <@BYTE:<d>> <@BYTE:<e>> */
	MARPATCL_RCMD_PRIO  (4), 292, 118, 115, 101, 116,                /* <@STR:<vset>>                  ::= <@BYTE:<v>> <@BYTE:<s>> <@BYTE:<e>> <@BYTE:<t>> */
	MARPATCL_RCMD_PRIO  (1), 293, 278,                               /* <ANY_UNBRACED>                 ::= <@^CLS:<\173\175>> */
	MARPATCL_RCMD_PRIO  (1), 294, 123,                               /* <BL>                           ::= <@BYTE:<\173>> */
	MARPATCL_RCMD_PRIO  (1), 295, 125,                               /* <BR>                           ::= <@BYTE:<\175>> */
	MARPATCL_RCMD_PRIO  (1), 296, 287,                               /* <BRACE_ESCAPED>                ::= <@STR:<\134\173>> */
	MARPATCL_RCMD_PRIS  (1)     , 288,                               /*                                |   <@STR:<\134\175>> */
	MARPATCL_RCMD_PRIO  (3), 297, 294, 299, 295,                     /* <BRACED>                       ::= <BL> <BRACED_ELEMS> <BR> */
	MARPATCL_RCMD_PRIO  (1), 298, 293,                               /* <BRACED_ELEM>                  ::= <ANY_UNBRACED> */
	MARPATCL_RCMD_PRIS  (1)     , 297,                               /*                                |   <BRACED> */
	MARPATCL_RCMD_PRIS  (1)     , 296,                               /*                                |   <BRACE_ESCAPED> */
	MARPATCL_RCMD_QUN   (299), 298,                                  /* <BRACED_ELEMS>                 ::= <BRACED_ELEM> * */
	MARPATCL_RCMD_PRIO  (1), 300, 335,                               /* <BRAN<d9-d122>>                ::= <@BRAN:<\t\r>> */
	MARPATCL_RCMD_PRIS  (1)     , 301,                               /*                                |   <BRAN<d14-d122>> */
	MARPATCL_RCMD_PRIO  (1), 301, 333,                               /* <BRAN<d14-d122>>               ::= <@BRAN:<\16\37>> */
	MARPATCL_RCMD_PRIS  (1)     , 342,                               /*                                |   <BRAN<d32-d122>> */
	MARPATCL_RCMD_PRIO  (1), 302, 91,                                /* <CL>                           ::= <@BYTE:<\133>> */
	MARPATCL_RCMD_PRIO  (5), 303, 302, 326, 329, 326, 306,           /* <COMMAND>                      ::= <CL> <WHITE0> <WORDS1> <WHITE0> <CR> */
	MARPATCL_RCMD_PRIO  (7), 304, 302, 326, 290, 327, 328, 326, 306, /* <COMMENT>                      ::= <CL> <WHITE0> <@STR:<comment>> <WHITE1> <WORD> <WHITE0> <CR> */
	MARPATCL_RCMD_PRIO  (4), 305, 318, 92, 309, 318,                 /* <CONTINUATION>                 ::= <SPACE0> <@BYTE:<\134>> <NEWLINE> <SPACE0> */
	MARPATCL_RCMD_PRIO  (1), 306, 93,                                /* <CR>                           ::= <@BYTE:<\135>> */
	MARPATCL_RCMD_PRIO  (1), 307, 92,                                /* <ESCAPED>                      ::= <@BYTE:<\134>> */
	MARPATCL_RCMD_PRIS  (1)     , 285,                               /*                                |   <@STR:<\134\133>> */
	MARPATCL_RCMD_PRIS  (1)     , 286,                               /*                                |   <@STR:<\134\135>> */
	MARPATCL_RCMD_PRIO  (1), 308, 291,                               /* <INCLUDE>                      ::= <@STR:<include>> */
	MARPATCL_RCMD_PRIO  (1), 309, 283,                               /* <NEWLINE>                      ::= <@CLS:<\n\r>> */
	MARPATCL_RCMD_PRIS  (1)     , 289,                               /*                                |   <@STR:<\r\n>> */
	MARPATCL_RCMD_PRIO  (1), 310, 279,                               /* <NO_CFS_QUOTE>                 ::= <@^CLS:<\t-\r\40\42\133-\135>> */
	MARPATCL_RCMD_PRIO  (1), 311, 280,                               /* <NO_CMD_FMT_SPACE>             ::= <@^CLS:<\t-\r\40\133-\135>> */
	MARPATCL_RCMD_PRIO  (1), 312, 34,                                /* <QUOTE>                        ::= <@CHR:<\42>> */
	MARPATCL_RCMD_PRIO  (3), 313, 312, 315, 312,                     /* <QUOTED>                       ::= <QUOTE> <QUOTED_ELEMS> <QUOTE> */
	MARPATCL_RCMD_PRIO  (1), 314, 310,                               /* <QUOTED_ELEM>                  ::= <NO_CFS_QUOTE> */
	MARPATCL_RCMD_PRIS  (1)     , 317,                               /*                                |   <SPACE> */
	MARPATCL_RCMD_PRIS  (1)     , 303,                               /*                                |   <COMMAND> */
	MARPATCL_RCMD_PRIS  (1)     , 307,                               /*                                |   <ESCAPED> */
	MARPATCL_RCMD_QUN   (315), 314,                                  /* <QUOTED_ELEMS>                 ::= <QUOTED_ELEM> * */
	MARPATCL_RCMD_QUP   (316), 310,                                  /* <SIMPLE>                       ::= <NO_CFS_QUOTE> + */
	MARPATCL_RCMD_PRIO  (1), 317, 284,                               /* <SPACE>                        ::= <@CLS:<\t-\r\40>> */
	MARPATCL_RCMD_QUN   (318), 317,                                  /* <SPACE0>                       ::= <SPACE> * */
	MARPATCL_RCMD_QUP   (319), 317,                                  /* <SPACE1>                       ::= <SPACE> + */
	MARPATCL_RCMD_PRIO  (1), 320, 323,                               /* <UNQUOTED>                     ::= <UNQUOTED_LEAD> */
	MARPATCL_RCMD_PRIS  (2)     , 323, 322,                          /*                                |   <UNQUOTED_LEAD> <UNQUOTED_ELEMS> */
	MARPATCL_RCMD_PRIO  (1), 321, 323,                               /* <UNQUOTED_ELEM>                ::= <UNQUOTED_LEAD> */
	MARPATCL_RCMD_PRIS  (1)     , 312,                               /*                                |   <QUOTE> */
	MARPATCL_RCMD_QUP   (322), 321,                                  /* <UNQUOTED_ELEMS>               ::= <UNQUOTED_ELEM> + */
	MARPATCL_RCMD_PRIO  (1), 323, 311,                               /* <UNQUOTED_LEAD>                ::= <NO_CMD_FMT_SPACE> */
	MARPATCL_RCMD_PRIS  (1)     , 303,                               /*                                |   <COMMAND> */
	MARPATCL_RCMD_PRIS  (1)     , 307,                               /*                                |   <ESCAPED> */
	MARPATCL_RCMD_PRIO  (1), 324, 292,                               /* <VSET>                         ::= <@STR:<vset>> */
	MARPATCL_RCMD_PRIO  (1), 325, 317,                               /* <WHITE>                        ::= <SPACE> */
	MARPATCL_RCMD_PRIS  (1)     , 304,                               /*                                |   <COMMENT> */
	MARPATCL_RCMD_PRIS  (1)     , 305,                               /*                                |   <CONTINUATION> */
	MARPATCL_RCMD_QUN   (326), 325,                                  /* <WHITE0>                       ::= <WHITE> * */
	MARPATCL_RCMD_QUP   (327), 325,                                  /* <WHITE1>                       ::= <WHITE> + */
	MARPATCL_RCMD_PRIO  (1), 328, 297,                               /* <WORD>                         ::= <BRACED> */
	MARPATCL_RCMD_PRIS  (1)     , 313,                               /*                                |   <QUOTED> */
	MARPATCL_RCMD_PRIS  (1)     , 320,                               /*                                |   <UNQUOTED> */
	MARPATCL_RCMD_QUPS  (329), 328, MARPATCL_RCMD_SEP (327),         /* <WORDS1>                       ::= <WORD> + (<WHITE1>) */
	MARPATCL_RCMD_BRAN  (330), MARPATCL_RCMD_BOXR ( 33, 90),         /* <@BRAN:<!Z>>                   brange (33 - 90) */
	MARPATCL_RCMD_BRAN  (331), MARPATCL_RCMD_BOXR ( 35, 90),         /* <@BRAN:<#Z>>                   brange (35 - 90) */
	MARPATCL_RCMD_BRAN  (332), MARPATCL_RCMD_BOXR (  1,  8),         /* <@BRAN:<\1\10>>                brange (1 - 8) */
	MARPATCL_RCMD_BRAN  (333), MARPATCL_RCMD_BOXR ( 14, 31),         /* <@BRAN:<\16\37>>               brange (14 - 31) */
	MARPATCL_RCMD_BRAN  (334), MARPATCL_RCMD_BOXR (128,191),         /* <@BRAN:<\200\u00bf>>           brange (128 - 191) */
	MARPATCL_RCMD_BRAN  (335), MARPATCL_RCMD_BOXR (  9, 13),         /* <@BRAN:<\t\r>>                 brange (9 - 13) */
	MARPATCL_RCMD_BRAN  (336), MARPATCL_RCMD_BOXR (160,175),         /* <@BRAN:<\u00a0\u00af>>         brange (160 - 175) */
	MARPATCL_RCMD_BRAN  (337), MARPATCL_RCMD_BOXR (176,191),         /* <@BRAN:<\u00b0\u00bf>>         brange (176 - 191) */
	MARPATCL_RCMD_BRAN  (338), MARPATCL_RCMD_BOXR (194,223),         /* <@BRAN:<\u00c2\u00df>>         brange (194 - 223) */
	MARPATCL_RCMD_BRAN  (339), MARPATCL_RCMD_BOXR (225,239),         /* <@BRAN:<\u00e1\u00ef>>         brange (225 - 239) */
	MARPATCL_RCMD_BRAN  (340), MARPATCL_RCMD_BOXR ( 94,127),         /* <@BRAN:<^\177>>                brange (94 - 127) */
	MARPATCL_RCMD_BRAN  (341), MARPATCL_RCMD_BOXR (126,127),         /* <@BRAN:<~\177>>                brange (126 - 127) */
	MARPATCL_RCMD_BRAN  (342), MARPATCL_RCMD_BOXR ( 32,122),         /* <BRAN<d32-d122>>               brange (32 - 122) */
	MARPATCL_RCMD_PRIO  (2), 343, 256, 267,                          /* <@L0:START>                    ::= <@ACS:Braced> <Braced> */
	MARPATCL_RCMD_PRIS  (2)     , 257, 268,                          /*                                |   <@ACS:Escaped> <Escaped> */
	MARPATCL_RCMD_PRIS  (2)     , 258, 269,                          /*                                |   <@ACS:Include> <Include> */
	MARPATCL_RCMD_PRIS  (2)     , 259, 270,                          /*                                |   <@ACS:Quote> <Quote> */
	MARPATCL_RCMD_PRIS  (2)     , 260, 271,                          /*                                |   <@ACS:Simple> <Simple> */
	MARPATCL_RCMD_PRIS  (2)     , 261, 272,                          /*                                |   <@ACS:Space> <Space> */
	MARPATCL_RCMD_PRIS  (2)     , 262, 273,                          /*                                |   <@ACS:Start> <Start> */
	MARPATCL_RCMD_PRIS  (2)     , 263, 274,                          /*                                |   <@ACS:Stop> <Stop> */
	MARPATCL_RCMD_PRIS  (2)     , 264, 275,                          /*                                |   <@ACS:Vset> <Vset> */
	MARPATCL_RCMD_PRIS  (2)     , 265, 276,                          /*                                |   <@ACS:White> <White> */
	MARPATCL_RCMD_PRIS  (2)     , 266, 277,                          /*                                |   <@ACS:Word> <Word> */
	MARPATCL_RCMD_DONE  (343)
    };

    static marpatcl_rtc_rules doctools_parser_sf_c_l0 = { /* 48 */
	/* .sname   */  &doctools_parser_sf_c_pool,
	/* .symbols */  { 344, doctools_parser_sf_c_l0_sym_name },
	/* .rules   */  { 0, NULL },
	/* .lhs     */  { 0, NULL },
	/* .rcode   */  doctools_parser_sf_c_l0_rule_definitions,
	/* .events  */  0
    };

    static marpatcl_rtc_sym doctools_parser_sf_c_l0semantics [3] = { /* 6 bytes */
	 MARPATCL_SV_START, MARPATCL_SV_LENGTH,  MARPATCL_SV_VALUE
    };

    /*
    ** G1 structures
    */

    static marpatcl_rtc_sym doctools_parser_sf_c_g1_sym_name [32] = { /* 64 bytes */
	/* --- (11) --- --- --- Terminals
	 */
	218, 238, 268, 293, 305, 308, 312, 313, 334, 339, 343,

	/* --- (21) --- --- --- Structure
	 */
	242, 332, 329, 330, 269, 331, 287, 328, 301, 296, 291, 290, 318, 324, 325, 323,
	219, 306, 294, 309, 239
    };

    static marpatcl_rtc_sym doctools_parser_sf_c_g1_rule_name [40] = { /* 80 bytes */
	242, 242, 332, 332, 329, 329, 329, 329, 330, 330, 330, 330, 269, 269, 269, 269,
	331, 287, 328, 301, 301, 301, 296, 291, 290, 290, 290, 290, 318, 324, 324, 324,
	325, 323, 323, 219, 306, 294, 309, 239
    };

    static marpatcl_rtc_sym doctools_parser_sf_c_g1_rule_lhs [40] = { /* 80 bytes */
	11, 11, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15,
	16, 17, 18, 19, 19, 19, 20, 21, 22, 22, 22, 22, 23, 24, 24, 24,
	25, 26, 26, 27, 28, 29, 30, 31
    };

    static marpatcl_rtc_sym doctools_parser_sf_c_g1_rule_definitions [172] = { /* 344 bytes */
	MARPATCL_RCMD_SETUP (9),
	MARPATCL_RCMD_PRIO  (1), 11, 12,                          /* <form>    ::= <vars> */
	MARPATCL_RCMD_PRIS  (1)    , 15,                          /*           |   <include> */
	MARPATCL_RCMD_PRIO  (1), 12, 13,                          /* <vars>    ::= <var_def> */
	MARPATCL_RCMD_PRIS  (1)    , 14,                          /*           |   <var_ref> */
	MARPATCL_RCMD_PRIO  (9), 13, 6, 9, 8, 9, 16, 9, 18, 9, 7, /* <var_def> ::= <Start> <White> <Vset> <White> <varname> <White> <value> <White> <Stop> */
	MARPATCL_RCMD_PRIS  (8)    , 6, 9, 8, 9, 16, 9, 18, 7,    /*           |   <Start> <White> <Vset> <White> <varname> <White> <value> <Stop> */
	MARPATCL_RCMD_PRIS  (8)    , 6, 8, 9, 16, 9, 18, 9, 7,    /*           |   <Start> <Vset> <White> <varname> <White> <value> <White> <Stop> */
	MARPATCL_RCMD_PRIS  (7)    , 6, 8, 9, 16, 9, 18, 7,       /*           |   <Start> <Vset> <White> <varname> <White> <value> <Stop> */
	MARPATCL_RCMD_PRIO  (7), 14, 6, 9, 8, 9, 16, 9, 7,        /* <var_ref> ::= <Start> <White> <Vset> <White> <varname> <White> <Stop> */
	MARPATCL_RCMD_PRIS  (6)    , 6, 9, 8, 9, 16, 7,           /*           |   <Start> <White> <Vset> <White> <varname> <Stop> */
	MARPATCL_RCMD_PRIS  (6)    , 6, 8, 9, 16, 9, 7,           /*           |   <Start> <Vset> <White> <varname> <White> <Stop> */
	MARPATCL_RCMD_PRIS  (5)    , 6, 8, 9, 16, 7,              /*           |   <Start> <Vset> <White> <varname> <Stop> */
	MARPATCL_RCMD_PRIO  (7), 15, 6, 9, 2, 9, 17, 9, 7,        /* <include> ::= <Start> <White> <Include> <White> <path> <White> <Stop> */
	MARPATCL_RCMD_PRIS  (6)    , 6, 9, 2, 9, 17, 7,           /*           |   <Start> <White> <Include> <White> <path> <Stop> */
	MARPATCL_RCMD_PRIS  (6)    , 6, 2, 9, 17, 9, 7,           /*           |   <Start> <Include> <White> <path> <White> <Stop> */
	MARPATCL_RCMD_PRIS  (5)    , 6, 2, 9, 17, 7,              /*           |   <Start> <Include> <White> <path> <Stop> */
	MARPATCL_RCMD_PRIO  (1), 16, 19,                          /* <varname> ::= <recurse> */
	MARPATCL_RCMD_PRIO  (1), 17, 19,                          /* <path>    ::= <recurse> */
	MARPATCL_RCMD_PRIO  (1), 18, 10,                          /* <value>   ::= <Word> */
	MARPATCL_RCMD_PRIO  (1), 19, 27,                          /* <recurse> ::= <braced> */
	MARPATCL_RCMD_PRIS  (1)    , 20,                          /*           |   <quoted> */
	MARPATCL_RCMD_PRIS  (1)    , 23,                          /*           |   <unquot> */
	MARPATCL_RCMD_PRIO  (3), 20, 3, 21, 3,                    /* <quoted>  ::= <Quote> <q_list> <Quote> */
	MARPATCL_RCMD_QUN   (21), 22,                             /* <q_list>  ::= <q_elem> * */
	MARPATCL_RCMD_PRIO  (1), 22, 28,                          /* <q_elem>  ::= <simple> */
	MARPATCL_RCMD_PRIS  (1)    , 30,                          /*           |   <space> */
	MARPATCL_RCMD_PRIS  (1)    , 12,                          /*           |   <vars> */
	MARPATCL_RCMD_PRIS  (1)    , 31,                          /*           |   <escaped> */
	MARPATCL_RCMD_PRIO  (2), 23, 24, 25,                      /* <unquot>  ::= <uq_lead> <uq_list> */
	MARPATCL_RCMD_PRIO  (1), 24, 28,                          /* <uq_lead> ::= <simple> */
	MARPATCL_RCMD_PRIS  (1)    , 12,                          /*           |   <vars> */
	MARPATCL_RCMD_PRIS  (1)    , 31,                          /*           |   <escaped> */
	MARPATCL_RCMD_QUN   (25), 26,                             /* <uq_list> ::= <uq_elem> * */
	MARPATCL_RCMD_PRIO  (1), 26, 24,                          /* <uq_elem> ::= <uq_lead> */
	MARPATCL_RCMD_PRIS  (1)    , 29,                          /*           |   <quote> */
	MARPATCL_RCMD_PRIO  (1), 27, 0,                           /* <braced>  ::= <Braced> */
	MARPATCL_RCMD_PRIO  (1), 28, 4,                           /* <simple>  ::= <Simple> */
	MARPATCL_RCMD_PRIO  (1), 29, 3,                           /* <quote>   ::= <Quote> */
	MARPATCL_RCMD_PRIO  (1), 30, 5,                           /* <space>   ::= <Space> */
	MARPATCL_RCMD_PRIO  (1), 31, 1,                           /* <escaped> ::= <Escaped> */
	MARPATCL_RCMD_DONE  (11)
    };

    static marpatcl_rtc_rules doctools_parser_sf_c_g1 = { /* 48 */
	/* .sname   */  &doctools_parser_sf_c_pool,
	/* .symbols */  { 32, doctools_parser_sf_c_g1_sym_name },
	/* .rules   */  { 40, doctools_parser_sf_c_g1_rule_name },
	/* .lhs     */  { 40, doctools_parser_sf_c_g1_rule_lhs },
	/* .rcode   */  doctools_parser_sf_c_g1_rule_definitions,
	/* .events  */  0
    };

    static marpatcl_rtc_sym doctools_parser_sf_c_g1semantics [46] = { /* 92 bytes */
	/* --- (1) --- --- --- Tag
	 */
	MARPATCL_S_PER,

	/* --- (40) --- --- --- Semantics Offsets
	 */
	40, 40, 40, 40, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42,
	40, 40, 40, 40, 40, 40, 40, 42, 40, 40, 40, 40, 42, 40, 40, 40,
	42, 40, 40, 42, 42, 42, 42, 42,

	/* --- (2) --- --- --- Semantics Data
	 */
	/* 40 */ 1, MARPATCL_SV_A_FIRST,
	/* 42 */ 2, MARPATCL_SV_RULE_NAME, MARPATCL_SV_VALUE
    };

    static marpatcl_rtc_sym doctools_parser_sf_c_g1masking [96] = { /* 192 bytes */
	/* --- (1) --- --- --- Tag
	 */
	MARPATCL_S_PER,

	/* --- (40) --- --- --- Mask Offsets
	 */
	 0,  0,  0,  0, 87, 73, 80, 60, 66, 48, 54, 43, 66, 48, 54, 43,
	 0,  0,  0,  0,  0,  0, 40,  0,  0,  0,  0,  0,  0,  0,  0,  0,
	 0,  0,  0,  0,  0,  0,  0,  0,

	/* --- (3) --- --- --- Mask Data
	 */
	/* 40 */ 2, 0, 2,
	/* 43 */ 4, 0, 1, 2, 4,
	/* 48 */ 5, 0, 1, 2, 3, 5,
	/* 54 */ 5, 0, 1, 2, 4, 5,
	/* 60 */ 5, 0, 1, 2, 4, 6,
	/* 66 */ 6, 0, 1, 2, 3, 5, 6,
	/* 73 */ 6, 0, 1, 2, 3, 5, 7,
	/* 80 */ 6, 0, 1, 2, 4, 6, 7,
	/* 87 */ 7, 0, 1, 2, 3, 5, 7, 8
    };

    /*
    ** Parser definition
    */

    static marpatcl_rtc_sym doctools_parser_sf_c_always [0] = { /* 0 bytes */

    };

    static marpatcl_rtc_spec doctools_parser_sf_c_spec = { /* 72 */
	/* .lexemes    */  11,
	/* .discards   */  0,
	/* .l_symbols  */  344,
	/* .g_symbols  */  32,
	/* .always     */  { 0, doctools_parser_sf_c_always },
	/* .l0         */  &doctools_parser_sf_c_l0,
	/* .g1         */  &doctools_parser_sf_c_g1,
	/* .l0semantic */  { 3, doctools_parser_sf_c_l0semantics },
	/* .g1semantic */  { 46, doctools_parser_sf_c_g1semantics },
	/* .g1mask     */  { 96, doctools_parser_sf_c_g1masking }
    };
    /* --- end of generated data structures --- */
}

# # ## ### ##### ######## ############# #####################
## Class exposing the grammar engine.

critcl::class def doctools::parser::sf::c {

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
	instance->state = marpatcl_rtc_cons (&doctools_parser_sf_c_spec,
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