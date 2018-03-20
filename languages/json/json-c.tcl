# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017 Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                     http://core.tcl.tk/akupries/
##
# (c) 2018 Grammar json::parser::c 1 By Andreas Kupries
##
##	`marpa::runtime::c`-derived Parser for grammar "json::parser::c".
##	Generated On Tue Mar 13 08:05:01 PDT 2018
##		  By aku@hephaistos
##		 Via marpa-gen
##
#* Space taken: 4965 bytes
##
#* Statistics
#* L0
#* - #Symbols:   320
#* - #Lexemes:   12
#* - #Discards:  1
#* - #Always:    1
#* - #Rule Insn: 94 (+2: setup, start-sym)
#* - #Rules:     315 (>= insn, brange)
#* G1
#* - #Symbols:   24
#* - #Rule Insn: 18 (+2: setup, start-sym)
#* - #Rules:     18 (match insn)

package provide json::parser::c 1

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5 ;# apply, lassign, ...
package require critcl 3.1
critcl::buildrequirement {
    package require critcl::class
    package require critcl::cutil
}

if {![critcl::compiling]} {
    error "Unable to build json::parser::c, no compiler found."
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

# # ## ### ##### ######## ############# #####################
## Static data structures declaring the grammar

critcl::ccode {
    /*
    ** Shared string pool (630 bytes lengths over 315 entries)
    **                    (630 bytes offsets -----^)
    **                    (2021 bytes character content)
    */

    static marpatcl_rtc_size json_parser_c_pool_length [315] = { /* 630 bytes */
	 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
	 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  9,  8,  5,  5,
	10, 15,  7, 15, 11, 11, 11, 11, 11, 11, 11, 11, 11, 12,  7,  5,
	 5,  4,  3,  3,  3,  3,  3,  4,  4,  5,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  2,  2,  2,  1,
	 1,  1,  1,  1,  5,  1,  1,  1,  1,  4,  5,  5,  1,  1,  7,  6,
	 6,  1,  1,  7,  8,  8,  1,  1,  5,  8,  1,  1,  1,  1,  3,  1,
	 1, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15,
	15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 16, 16,
	16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
	 3,  1,  1,  1,  1,  1,  1,  6,  8,  6,  5,  7,  7,  5,  1,  1,
	 1,  1,  4,  6,  1,  1,  6,  1,  1,  4,  5,  5,  8,  1,  1,  5,
	 1,  1,  6,  8,  1,  1,  6,  1,  1,  4,  1,  1,  1,  1,  5,  1,
	 1, 10,  5,  1,  1,  1,  1,  1,  1,  1,  1
    };

    static marpatcl_rtc_size json_parser_c_pool_offset [315] = { /* 630 bytes */
	   0,    2,    4,    6,    8,   10,   12,   14,   16,   18,   20,   22,   24,   26,   28,   30,
	  32,   34,   36,   38,   40,   42,   44,   46,   48,   50,   52,   54,   56,   66,   75,   81,
	  87,   98,  114,  122,  138,  150,  162,  174,  186,  198,  210,  222,  234,  246,  259,  267,
	 273,  279,  284,  288,  292,  296,  300,  304,  309,  314,  320,  325,  330,  335,  340,  345,
	 350,  355,  360,  365,  370,  375,  380,  385,  390,  395,  400,  405,  410,  415,  420,  425,
	 430,  435,  440,  445,  450,  455,  460,  465,  470,  475,  480,  485,  490,  495,  500,  505,
	 510,  515,  520,  525,  530,  535,  540,  545,  550,  555,  560,  565,  570,  575,  580,  585,
	 590,  595,  600,  605,  610,  615,  620,  625,  630,  635,  640,  645,  650,  655,  660,  665,
	 670,  675,  680,  685,  690,  695,  700,  705,  710,  715,  720,  725,  730,  735,  740,  745,
	 750,  755,  760,  765,  770,  775,  780,  785,  790,  795,  800,  805,  810,  815,  820,  825,
	 830,  835,  840,  845,  850,  855,  860,  865,  870,  875,  880,  885,  890,  893,  896,  899,
	 901,  903,  905,  907,  909,  915,  917,  919,  921,  923,  928,  934,  940,  942,  944,  952,
	 959,  966,  968,  970,  978,  987,  996,  998, 1000, 1006, 1015, 1017, 1019, 1021, 1023, 1027,
	1029, 1031, 1046, 1061, 1076, 1091, 1106, 1121, 1136, 1151, 1166, 1182, 1198, 1214, 1230, 1246,
	1262, 1278, 1294, 1310, 1326, 1342, 1358, 1374, 1390, 1406, 1422, 1438, 1454, 1470, 1486, 1503,
	1520, 1537, 1554, 1571, 1588, 1605, 1622, 1639, 1656, 1673, 1690, 1707, 1724, 1741, 1758, 1775,
	1792, 1796, 1798, 1800, 1802, 1804, 1806, 1808, 1815, 1824, 1831, 1837, 1845, 1853, 1859, 1861,
	1863, 1865, 1867, 1872, 1879, 1881, 1883, 1890, 1892, 1894, 1899, 1905, 1911, 1920, 1922, 1924,
	1930, 1932, 1934, 1941, 1950, 1952, 1954, 1961, 1963, 1965, 1970, 1972, 1974, 1976, 1978, 1984,
	1986, 1988, 1999, 2005, 2007, 2009, 2011, 2013, 2015, 2017, 2019
    };

    static marpatcl_rtc_string json_parser_c_pool = { /* 24 + 2021 bytes */
	json_parser_c_pool_length,
	json_parser_c_pool_offset,
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
	/*  29 */ "[#-\\133]\0"
	/*  30 */ "[0-9]\0"
	/*  31 */ "[1-9]\0"
	/*  32 */ "[:xdigit:]\0"
	/*  33 */ "[\\0-\\37\\42\\134]\0"
	/*  34 */ "[\\40-!]\0"
	/*  35 */ "[\\42/\\134bfnrt]\0"
	/*  36 */ "[\\135-\\177]\0"
	/*  37 */ "[\\200-\\237]\0"
	/*  38 */ "[\\200-\\277]\0"
	/*  39 */ "[\\240-\\257]\0"
	/*  40 */ "[\\240-\\277]\0"
	/*  41 */ "[\\260-\\277]\0"
	/*  42 */ "[\\302-\\337]\0"
	/*  43 */ "[\\341-\\354]\0"
	/*  44 */ "[\\356-\\357]\0"
	/*  45 */ "[\\t-\\n\\r\\40]\0"
	/*  46 */ "[\\t-\\n]\0"
	/*  47 */ "[A-F]\0"
	/*  48 */ "[a-f]\0"
	/*  49 */ "[Ee]\0"
	/*  50 */ "\\40\0"
	/*  51 */ "\\42\0"
	/*  52 */ "\\50\0"
	/*  53 */ "\\51\0"
	/*  54 */ "\\73\0"
	/*  55 */ "\\133\0"
	/*  56 */ "\\134\0"
	/*  57 */ "\\134u\0"
	/*  58 */ "\\135\0"
	/*  59 */ "\\173\0"
	/*  60 */ "\\175\0"
	/*  61 */ "\\177\0"
	/*  62 */ "\\200\0"
	/*  63 */ "\\201\0"
	/*  64 */ "\\202\0"
	/*  65 */ "\\203\0"
	/*  66 */ "\\204\0"
	/*  67 */ "\\205\0"
	/*  68 */ "\\206\0"
	/*  69 */ "\\207\0"
	/*  70 */ "\\210\0"
	/*  71 */ "\\211\0"
	/*  72 */ "\\212\0"
	/*  73 */ "\\213\0"
	/*  74 */ "\\214\0"
	/*  75 */ "\\215\0"
	/*  76 */ "\\216\0"
	/*  77 */ "\\217\0"
	/*  78 */ "\\220\0"
	/*  79 */ "\\221\0"
	/*  80 */ "\\222\0"
	/*  81 */ "\\223\0"
	/*  82 */ "\\224\0"
	/*  83 */ "\\225\0"
	/*  84 */ "\\226\0"
	/*  85 */ "\\227\0"
	/*  86 */ "\\230\0"
	/*  87 */ "\\231\0"
	/*  88 */ "\\232\0"
	/*  89 */ "\\233\0"
	/*  90 */ "\\234\0"
	/*  91 */ "\\235\0"
	/*  92 */ "\\236\0"
	/*  93 */ "\\237\0"
	/*  94 */ "\\240\0"
	/*  95 */ "\\241\0"
	/*  96 */ "\\242\0"
	/*  97 */ "\\243\0"
	/*  98 */ "\\244\0"
	/*  99 */ "\\245\0"
	/* 100 */ "\\246\0"
	/* 101 */ "\\247\0"
	/* 102 */ "\\250\0"
	/* 103 */ "\\251\0"
	/* 104 */ "\\252\0"
	/* 105 */ "\\253\0"
	/* 106 */ "\\254\0"
	/* 107 */ "\\255\0"
	/* 108 */ "\\256\0"
	/* 109 */ "\\257\0"
	/* 110 */ "\\260\0"
	/* 111 */ "\\261\0"
	/* 112 */ "\\262\0"
	/* 113 */ "\\263\0"
	/* 114 */ "\\264\0"
	/* 115 */ "\\265\0"
	/* 116 */ "\\266\0"
	/* 117 */ "\\267\0"
	/* 118 */ "\\270\0"
	/* 119 */ "\\271\0"
	/* 120 */ "\\272\0"
	/* 121 */ "\\273\0"
	/* 122 */ "\\274\0"
	/* 123 */ "\\275\0"
	/* 124 */ "\\276\0"
	/* 125 */ "\\277\0"
	/* 126 */ "\\302\0"
	/* 127 */ "\\303\0"
	/* 128 */ "\\304\0"
	/* 129 */ "\\305\0"
	/* 130 */ "\\306\0"
	/* 131 */ "\\307\0"
	/* 132 */ "\\310\0"
	/* 133 */ "\\311\0"
	/* 134 */ "\\312\0"
	/* 135 */ "\\313\0"
	/* 136 */ "\\314\0"
	/* 137 */ "\\315\0"
	/* 138 */ "\\316\0"
	/* 139 */ "\\317\0"
	/* 140 */ "\\320\0"
	/* 141 */ "\\321\0"
	/* 142 */ "\\322\0"
	/* 143 */ "\\323\0"
	/* 144 */ "\\324\0"
	/* 145 */ "\\325\0"
	/* 146 */ "\\326\0"
	/* 147 */ "\\327\0"
	/* 148 */ "\\330\0"
	/* 149 */ "\\331\0"
	/* 150 */ "\\332\0"
	/* 151 */ "\\333\0"
	/* 152 */ "\\334\0"
	/* 153 */ "\\335\0"
	/* 154 */ "\\336\0"
	/* 155 */ "\\337\0"
	/* 156 */ "\\340\0"
	/* 157 */ "\\341\0"
	/* 158 */ "\\342\0"
	/* 159 */ "\\343\0"
	/* 160 */ "\\344\0"
	/* 161 */ "\\345\0"
	/* 162 */ "\\346\0"
	/* 163 */ "\\347\0"
	/* 164 */ "\\350\0"
	/* 165 */ "\\351\0"
	/* 166 */ "\\352\0"
	/* 167 */ "\\353\0"
	/* 168 */ "\\354\0"
	/* 169 */ "\\355\0"
	/* 170 */ "\\356\0"
	/* 171 */ "\\357\0"
	/* 172 */ "\\n\0"
	/* 173 */ "\\r\0"
	/* 174 */ "\\t\0"
	/* 175 */ "^\0"
	/* 176 */ "_\0"
	/* 177 */ "`\0"
	/* 178 */ "A\0"
	/* 179 */ "a\0"
	/* 180 */ "array\0"
	/* 181 */ "B\0"
	/* 182 */ "b\0"
	/* 183 */ "C\0"
	/* 184 */ "c\0"
	/* 185 */ "char\0"
	/* 186 */ "colon\0"
	/* 187 */ "comma\0"
	/* 188 */ "D\0"
	/* 189 */ "d\0"
	/* 190 */ "decimal\0"
	/* 191 */ "digits\0"
	/* 192 */ "digitz\0"
	/* 193 */ "E\0"
	/* 194 */ "e\0"
	/* 195 */ "element\0"
	/* 196 */ "elements\0"
	/* 197 */ "exponent\0"
	/* 198 */ "F\0"
	/* 199 */ "f\0"
	/* 200 */ "false\0"
	/* 201 */ "fraction\0"
	/* 202 */ "G\0"
	/* 203 */ "g\0"
	/* 204 */ "H\0"
	/* 205 */ "h\0"
	/* 206 */ "hex\0"
	/* 207 */ "I\0"
	/* 208 */ "i\0"
	/* 209 */ "ILLEGAL_BYTE_0\0"
	/* 210 */ "ILLEGAL_BYTE_1\0"
	/* 211 */ "ILLEGAL_BYTE_2\0"
	/* 212 */ "ILLEGAL_BYTE_3\0"
	/* 213 */ "ILLEGAL_BYTE_4\0"
	/* 214 */ "ILLEGAL_BYTE_5\0"
	/* 215 */ "ILLEGAL_BYTE_6\0"
	/* 216 */ "ILLEGAL_BYTE_7\0"
	/* 217 */ "ILLEGAL_BYTE_8\0"
	/* 218 */ "ILLEGAL_BYTE_11\0"
	/* 219 */ "ILLEGAL_BYTE_12\0"
	/* 220 */ "ILLEGAL_BYTE_14\0"
	/* 221 */ "ILLEGAL_BYTE_15\0"
	/* 222 */ "ILLEGAL_BYTE_16\0"
	/* 223 */ "ILLEGAL_BYTE_17\0"
	/* 224 */ "ILLEGAL_BYTE_18\0"
	/* 225 */ "ILLEGAL_BYTE_19\0"
	/* 226 */ "ILLEGAL_BYTE_20\0"
	/* 227 */ "ILLEGAL_BYTE_21\0"
	/* 228 */ "ILLEGAL_BYTE_22\0"
	/* 229 */ "ILLEGAL_BYTE_23\0"
	/* 230 */ "ILLEGAL_BYTE_24\0"
	/* 231 */ "ILLEGAL_BYTE_25\0"
	/* 232 */ "ILLEGAL_BYTE_26\0"
	/* 233 */ "ILLEGAL_BYTE_27\0"
	/* 234 */ "ILLEGAL_BYTE_28\0"
	/* 235 */ "ILLEGAL_BYTE_29\0"
	/* 236 */ "ILLEGAL_BYTE_30\0"
	/* 237 */ "ILLEGAL_BYTE_31\0"
	/* 238 */ "ILLEGAL_BYTE_192\0"
	/* 239 */ "ILLEGAL_BYTE_193\0"
	/* 240 */ "ILLEGAL_BYTE_240\0"
	/* 241 */ "ILLEGAL_BYTE_241\0"
	/* 242 */ "ILLEGAL_BYTE_242\0"
	/* 243 */ "ILLEGAL_BYTE_243\0"
	/* 244 */ "ILLEGAL_BYTE_244\0"
	/* 245 */ "ILLEGAL_BYTE_245\0"
	/* 246 */ "ILLEGAL_BYTE_246\0"
	/* 247 */ "ILLEGAL_BYTE_247\0"
	/* 248 */ "ILLEGAL_BYTE_248\0"
	/* 249 */ "ILLEGAL_BYTE_249\0"
	/* 250 */ "ILLEGAL_BYTE_250\0"
	/* 251 */ "ILLEGAL_BYTE_251\0"
	/* 252 */ "ILLEGAL_BYTE_252\0"
	/* 253 */ "ILLEGAL_BYTE_253\0"
	/* 254 */ "ILLEGAL_BYTE_254\0"
	/* 255 */ "ILLEGAL_BYTE_255\0"
	/* 256 */ "int\0"
	/* 257 */ "J\0"
	/* 258 */ "j\0"
	/* 259 */ "K\0"
	/* 260 */ "k\0"
	/* 261 */ "L\0"
	/* 262 */ "l\0"
	/* 263 */ "lbrace\0"
	/* 264 */ "lbracket\0"
	/* 265 */ "lfalse\0"
	/* 266 */ "lnull\0"
	/* 267 */ "lnumber\0"
	/* 268 */ "lstring\0"
	/* 269 */ "ltrue\0"
	/* 270 */ "M\0"
	/* 271 */ "m\0"
	/* 272 */ "N\0"
	/* 273 */ "n\0"
	/* 274 */ "null\0"
	/* 275 */ "number\0"
	/* 276 */ "O\0"
	/* 277 */ "o\0"
	/* 278 */ "object\0"
	/* 279 */ "P\0"
	/* 280 */ "p\0"
	/* 281 */ "pair\0"
	/* 282 */ "pairs\0"
	/* 283 */ "plain\0"
	/* 284 */ "positive\0"
	/* 285 */ "Q\0"
	/* 286 */ "q\0"
	/* 287 */ "quote\0"
	/* 288 */ "R\0"
	/* 289 */ "r\0"
	/* 290 */ "rbrace\0"
	/* 291 */ "rbracket\0"
	/* 292 */ "S\0"
	/* 293 */ "s\0"
	/* 294 */ "string\0"
	/* 295 */ "T\0"
	/* 296 */ "t\0"
	/* 297 */ "true\0"
	/* 298 */ "U\0"
	/* 299 */ "u\0"
	/* 300 */ "V\0"
	/* 301 */ "v\0"
	/* 302 */ "value\0"
	/* 303 */ "W\0"
	/* 304 */ "w\0"
	/* 305 */ "whitespace\0"
	/* 306 */ "whole\0"
	/* 307 */ "X\0"
	/* 308 */ "x\0"
	/* 309 */ "Y\0"
	/* 310 */ "y\0"
	/* 311 */ "Z\0"
	/* 312 */ "z\0"
	/* 313 */ "|\0"
	/* 314 */ "~\0"
    };

    /*
    ** L0 structures
    */

    static marpatcl_rtc_sym json_parser_c_l0_sym_name [320] = { /* 640 bytes */
	/* --- (256) --- --- --- Characters
	 */
	209, 210, 211, 212, 213, 214, 215, 216, 217, 174, 172, 218, 219, 173, 220, 221,
	222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237,
	 50,   0,  51,   1,   2,   3,   4,   5,  52,  53,   6,   7,   8,   9,  10,  11,
	 12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  54,  23,  24,  25,  26,
	 27, 178, 181, 183, 188, 193, 198, 202, 204, 207, 257, 259, 261, 270, 272, 276,
	279, 285, 288, 292, 295, 298, 300, 303, 307, 309, 311,  55,  56,  58, 175, 176,
	177, 179, 182, 184, 189, 194, 199, 203, 205, 208, 258, 260, 262, 271, 273, 277,
	280, 286, 289, 293, 296, 299, 301, 304, 308, 310, 312,  59, 313,  60, 314,  61,
	 62,  63,  64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,
	 78,  79,  80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,  91,  92,  93,
	 94,  95,  96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109,
	110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125,
	238, 239, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139,
	140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155,
	156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171,
	240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255,

	/* --- (12) --- --- --- ACS: Lexeme
	 */
	186, 187, 263, 264, 265, 266, 267, 268, 269, 287, 290, 291,

	/* --- (1) --- --- --- ACS: Discard
	 */
	305,

	/* --- (12) --- --- --- Lexeme
	 */
	186, 187, 263, 264, 265, 266, 267, 268, 269, 287, 290, 291,

	/* --- (1) --- --- --- Discard
	 */
	305,

	/* --- (38) --- --- --- Internal
	 */
	 33,  38,  40,  35,  45,  49,  32,  57, 200, 274, 297, 185, 190, 191, 192, 194,
	197, 201, 206, 256, 283, 284, 306,  29,  30,  34,  36,  37,  46,  39,  41,  42,
	 43,  44,  47,  48,  31,  28
    };

    static marpatcl_rtc_sym json_parser_c_l0_rule_definitions [276] = { /* 552 bytes */
	MARPATCL_RCMD_SETUP (6),
	MARPATCL_RCMD_PRIO  (1), 269, 58,                           /* <colon>                 ::= <@CHR:<:>> */
	MARPATCL_RCMD_PRIO  (1), 270, 44,                           /* <comma>                 ::= <@CHR:<,>> */
	MARPATCL_RCMD_PRIO  (1), 271, 123,                          /* <lbrace>                ::= <@CHR:<\173>> */
	MARPATCL_RCMD_PRIO  (1), 272, 91,                           /* <lbracket>              ::= <@CHR:<\133>> */
	MARPATCL_RCMD_PRIO  (1), 273, 290,                          /* <lfalse>                ::= <@STR:<false>> */
	MARPATCL_RCMD_PRIO  (1), 274, 291,                          /* <lnull>                 ::= <@STR:<null>> */
	MARPATCL_RCMD_PRIO  (3), 275, 301, 299, 298,                /* <lnumber>               ::= <int> <fraction> <exponent> */
	MARPATCL_RCMD_PRIS  (2)     , 301, 298,                     /*                         |   <int> <exponent> */
	MARPATCL_RCMD_PRIS  (2)     , 301, 299,                     /*                         |   <int> <fraction> */
	MARPATCL_RCMD_PRIS  (1)     , 301,                          /*                         |   <int> */
	MARPATCL_RCMD_QUN   (276), 293,                             /* <lstring>               ::= <char> * */
	MARPATCL_RCMD_PRIO  (1), 277, 292,                          /* <ltrue>                 ::= <@STR:<true>> */
	MARPATCL_RCMD_PRIO  (1), 278, 34,                           /* <quote>                 ::= <@BYTE:<\42>> */
	MARPATCL_RCMD_PRIO  (1), 279, 125,                          /* <rbrace>                ::= <@CHR:<\175>> */
	MARPATCL_RCMD_PRIO  (1), 280, 93,                           /* <rbracket>              ::= <@CHR:<\135>> */
	MARPATCL_RCMD_QUP   (281), 286,                             /* <whitespace>            ::= <@CLS:<\t-\n\r\40>> + */
	MARPATCL_RCMD_PRIO  (1), 282, 307,                          /* <@^CLS:<\0-\37\42\134>> ::= <@BRAN:<\40!>> */
	MARPATCL_RCMD_PRIS  (1)     , 305,                          /*                         |   <@BRAN:<#\133>> */
	MARPATCL_RCMD_PRIS  (1)     , 308,                          /*                         |   <@BRAN:<\135\177>> */
	MARPATCL_RCMD_PRIS  (2)     , 313, 283,                     /*                         |   <@BRAN:<\u00c2\u00df>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 224, 284, 283,                /*                         |   <@BYTE:<\u00e0>> <@BRAN:<\u00a0\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 314, 283, 283,                /*                         |   <@BRAN:<\u00e1\u00ec>> <@BRAN:<\200\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 237, 309, 283,                /*                         |   <@BYTE:<\u00ed>> <@BRAN:<\200\237>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 315, 283, 283,                /*                         |   <@BRAN:<\u00ee\u00ef>> <@BRAN:<\200\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (6)     , 237, 311, 283, 237, 312, 283, /*                         |   <@BYTE:<\u00ed>> <@BRAN:<\u00a0\u00af>> <@BRAN:<\200\u00bf>> <@BYTE:<\u00ed>> <@BRAN:<\u00b0\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIO  (1), 283, 309,                          /* <@BRAN:<\200\u00bf>>    ::= <@BRAN:<\200\237>> */
	MARPATCL_RCMD_PRIS  (1)     , 284,                          /*                         |   <@BRAN:<\u00a0\u00bf>> */
	MARPATCL_RCMD_PRIO  (1), 284, 311,                          /* <@BRAN:<\u00a0\u00bf>>  ::= <@BRAN:<\u00a0\u00af>> */
	MARPATCL_RCMD_PRIS  (1)     , 312,                          /*                         |   <@BRAN:<\u00b0\u00bf>> */
	MARPATCL_RCMD_PRIO  (1), 285, 34,                           /* <@CLS:<\42/\134bfnrt>>  ::= <@BYTE:<\42>> */
	MARPATCL_RCMD_PRIS  (1)     , 47,                           /*                         |   <@BYTE:</>> */
	MARPATCL_RCMD_PRIS  (1)     , 92,                           /*                         |   <@BYTE:<\134>> */
	MARPATCL_RCMD_PRIS  (1)     , 98,                           /*                         |   <@BYTE:<b>> */
	MARPATCL_RCMD_PRIS  (1)     , 102,                          /*                         |   <@BYTE:<f>> */
	MARPATCL_RCMD_PRIS  (1)     , 110,                          /*                         |   <@BYTE:<n>> */
	MARPATCL_RCMD_PRIS  (1)     , 114,                          /*                         |   <@BYTE:<r>> */
	MARPATCL_RCMD_PRIS  (1)     , 116,                          /*                         |   <@BYTE:<t>> */
	MARPATCL_RCMD_PRIO  (1), 286, 310,                          /* <@CLS:<\t-\n\r\40>>     ::= <@BRAN:<\t\n>> */
	MARPATCL_RCMD_PRIS  (1)     , 13,                           /*                         |   <@BYTE:<\r>> */
	MARPATCL_RCMD_PRIS  (1)     , 32,                           /*                         |   <@BYTE:<\40>> */
	MARPATCL_RCMD_PRIO  (1), 287, 69,                           /* <@CLS:<Ee>>             ::= <@BYTE:<E>> */
	MARPATCL_RCMD_PRIS  (1)     , 101,                          /*                         |   <@BYTE:<e>> */
	MARPATCL_RCMD_PRIO  (1), 288, 306,                          /* <@NCC:<[:xdigit:]>>     ::= <@BRAN:<09>> */
	MARPATCL_RCMD_PRIS  (1)     , 316,                          /*                         |   <@BRAN:<AF>> */
	MARPATCL_RCMD_PRIS  (1)     , 317,                          /*                         |   <@BRAN:<af>> */
	MARPATCL_RCMD_PRIO  (2), 289, 92, 117,                      /* <@STR:<\134u>>          ::= <@BYTE:<\134>> <@BYTE:<u>> */
	MARPATCL_RCMD_PRIO  (5), 290, 102, 97, 108, 115, 101,       /* <@STR:<false>>          ::= <@BYTE:<f>> <@BYTE:<a>> <@BYTE:<l>> <@BYTE:<s>> <@BYTE:<e>> */
	MARPATCL_RCMD_PRIO  (4), 291, 110, 117, 108, 108,           /* <@STR:<null>>           ::= <@BYTE:<n>> <@BYTE:<u>> <@BYTE:<l>> <@BYTE:<l>> */
	MARPATCL_RCMD_PRIO  (4), 292, 116, 114, 117, 101,           /* <@STR:<true>>           ::= <@BYTE:<t>> <@BYTE:<r>> <@BYTE:<u>> <@BYTE:<e>> */
	MARPATCL_RCMD_PRIO  (1), 293, 302,                          /* <char>                  ::= <plain> */
	MARPATCL_RCMD_PRIS  (2)     , 92, 285,                      /*                         |   <@BYTE:<\134>> <@CLS:<\42/\134bfnrt>> */
	MARPATCL_RCMD_PRIS  (5)     , 289, 300, 300, 300, 300,      /*                         |   <@STR:<\134u>> <hex> <hex> <hex> <hex> */
	MARPATCL_RCMD_PRIO  (1), 294, 306,                          /* <decimal>               ::= <@BRAN:<09>> */
	MARPATCL_RCMD_QUP   (295), 294,                             /* <digits>                ::= <decimal> + */
	MARPATCL_RCMD_QUN   (296), 294,                             /* <digitz>                ::= <decimal> * */
	MARPATCL_RCMD_PRIO  (1), 297, 287,                          /* <e>                     ::= <@CLS:<Ee>> */
	MARPATCL_RCMD_PRIS  (2)     , 287, 45,                      /*                         |   <@CLS:<Ee>> <@CHR:<->> */
	MARPATCL_RCMD_PRIS  (2)     , 287, 43,                      /*                         |   <@CLS:<Ee>> <@CHR:<+>> */
	MARPATCL_RCMD_PRIO  (2), 298, 297, 295,                     /* <exponent>              ::= <e> <digits> */
	MARPATCL_RCMD_PRIO  (2), 299, 46, 295,                      /* <fraction>              ::= <@CHR:<.>> <digits> */
	MARPATCL_RCMD_PRIO  (1), 300, 288,                          /* <hex>                   ::= <@NCC:<[:xdigit:]>> */
	MARPATCL_RCMD_PRIO  (1), 301, 304,                          /* <int>                   ::= <whole> */
	MARPATCL_RCMD_PRIS  (2)     , 45, 304,                      /*                         |   <@CHR:<->> <whole> */
	MARPATCL_RCMD_PRIO  (1), 302, 282,                          /* <plain>                 ::= <@^CLS:<\0-\37\42\134>> */
	MARPATCL_RCMD_PRIO  (2), 303, 318, 296,                     /* <positive>              ::= <@RAN:<19>> <digitz> */
	MARPATCL_RCMD_PRIO  (1), 304, 48,                           /* <whole>                 ::= <@CHR:<0>> */
	MARPATCL_RCMD_PRIS  (1)     , 303,                          /*                         |   <positive> */
	MARPATCL_RCMD_BRAN  (305), MARPATCL_RCMD_BOXR ( 35, 91),    /* <@BRAN:<#\133>>         brange (35 - 91) */
	MARPATCL_RCMD_BRAN  (306), MARPATCL_RCMD_BOXR ( 48, 57),    /* <@BRAN:<09>>            brange (48 - 57) */
	MARPATCL_RCMD_BRAN  (307), MARPATCL_RCMD_BOXR ( 32, 33),    /* <@BRAN:<\40!>>          brange (32 - 33) */
	MARPATCL_RCMD_BRAN  (308), MARPATCL_RCMD_BOXR ( 93,127),    /* <@BRAN:<\135\177>>      brange (93 - 127) */
	MARPATCL_RCMD_BRAN  (309), MARPATCL_RCMD_BOXR (128,159),    /* <@BRAN:<\200\237>>      brange (128 - 159) */
	MARPATCL_RCMD_BRAN  (310), MARPATCL_RCMD_BOXR (  9, 10),    /* <@BRAN:<\t\n>>          brange (9 - 10) */
	MARPATCL_RCMD_BRAN  (311), MARPATCL_RCMD_BOXR (160,175),    /* <@BRAN:<\u00a0\u00af>>  brange (160 - 175) */
	MARPATCL_RCMD_BRAN  (312), MARPATCL_RCMD_BOXR (176,191),    /* <@BRAN:<\u00b0\u00bf>>  brange (176 - 191) */
	MARPATCL_RCMD_BRAN  (313), MARPATCL_RCMD_BOXR (194,223),    /* <@BRAN:<\u00c2\u00df>>  brange (194 - 223) */
	MARPATCL_RCMD_BRAN  (314), MARPATCL_RCMD_BOXR (225,236),    /* <@BRAN:<\u00e1\u00ec>>  brange (225 - 236) */
	MARPATCL_RCMD_BRAN  (315), MARPATCL_RCMD_BOXR (238,239),    /* <@BRAN:<\u00ee\u00ef>>  brange (238 - 239) */
	MARPATCL_RCMD_BRAN  (316), MARPATCL_RCMD_BOXR ( 65, 70),    /* <@BRAN:<AF>>            brange (65 - 70) */
	MARPATCL_RCMD_BRAN  (317), MARPATCL_RCMD_BOXR ( 97,102),    /* <@BRAN:<af>>            brange (97 - 102) */
	MARPATCL_RCMD_BRAN  (318), MARPATCL_RCMD_BOXR ( 49, 57),    /* <@RAN:<19>>             brange (49 - 57) */
	MARPATCL_RCMD_PRIO  (2), 319, 256, 269,                     /* <@L0:START>             ::= <@ACS:colon> <colon> */
	MARPATCL_RCMD_PRIS  (2)     , 257, 270,                     /*                         |   <@ACS:comma> <comma> */
	MARPATCL_RCMD_PRIS  (2)     , 258, 271,                     /*                         |   <@ACS:lbrace> <lbrace> */
	MARPATCL_RCMD_PRIS  (2)     , 259, 272,                     /*                         |   <@ACS:lbracket> <lbracket> */
	MARPATCL_RCMD_PRIS  (2)     , 260, 273,                     /*                         |   <@ACS:lfalse> <lfalse> */
	MARPATCL_RCMD_PRIS  (2)     , 261, 274,                     /*                         |   <@ACS:lnull> <lnull> */
	MARPATCL_RCMD_PRIS  (2)     , 262, 275,                     /*                         |   <@ACS:lnumber> <lnumber> */
	MARPATCL_RCMD_PRIS  (2)     , 263, 276,                     /*                         |   <@ACS:lstring> <lstring> */
	MARPATCL_RCMD_PRIS  (2)     , 264, 277,                     /*                         |   <@ACS:ltrue> <ltrue> */
	MARPATCL_RCMD_PRIS  (2)     , 265, 278,                     /*                         |   <@ACS:quote> <quote> */
	MARPATCL_RCMD_PRIS  (2)     , 266, 279,                     /*                         |   <@ACS:rbrace> <rbrace> */
	MARPATCL_RCMD_PRIS  (2)     , 267, 280,                     /*                         |   <@ACS:rbracket> <rbracket> */
	MARPATCL_RCMD_PRIS  (2)     , 268, 281,                     /*                         |   <@ACS:whitespace> <whitespace> */
	MARPATCL_RCMD_DONE  (319)
    };

    static marpatcl_rtc_rules json_parser_c_l0 = { /* 48 */
	/* .sname   */  &json_parser_c_pool,
	/* .symbols */  { 320, json_parser_c_l0_sym_name },
	/* .rules   */  { 0, NULL },
	/* .lhs     */  { 0, NULL },
	/* .rcode   */  json_parser_c_l0_rule_definitions
    };

    static marpatcl_rtc_sym json_parser_c_l0semantics [3] = { /* 6 bytes */
	 MARPATCL_SV_START, MARPATCL_SV_LENGTH,  MARPATCL_SV_VALUE
    };

    /*
    ** G1 structures
    */

    static marpatcl_rtc_sym json_parser_c_g1_sym_name [24] = { /* 48 bytes */
	/* --- (12) --- --- --- Terminals
	 */
	186, 187, 263, 264, 265, 266, 267, 268, 269, 287, 290, 291,

	/* --- (12) --- --- --- Structure
	 */
	302, 278, 282, 281, 180, 196, 195, 294, 275, 297, 200, 274
    };

    static marpatcl_rtc_sym json_parser_c_g1_rule_name [18] = { /* 36 bytes */
	302, 302, 302, 302, 302, 302, 302, 278, 282, 281, 180, 196, 195, 294, 275, 297,
	200, 274
    };

    static marpatcl_rtc_sym json_parser_c_g1_rule_lhs [18] = { /* 36 bytes */
	12, 12, 12, 12, 12, 12, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
	22, 23
    };

    static marpatcl_rtc_sym json_parser_c_g1_rule_definitions [58] = { /* 116 bytes */
	MARPATCL_RCMD_SETUP (3),
	MARPATCL_RCMD_PRIO  (1), 12, 13,                      /* <value>    ::= <object> */
	MARPATCL_RCMD_PRIS  (1)    , 16,                      /*            |   <array> */
	MARPATCL_RCMD_PRIS  (1)    , 19,                      /*            |   <string> */
	MARPATCL_RCMD_PRIS  (1)    , 20,                      /*            |   <number> */
	MARPATCL_RCMD_PRIS  (1)    , 21,                      /*            |   <true> */
	MARPATCL_RCMD_PRIS  (1)    , 22,                      /*            |   <false> */
	MARPATCL_RCMD_PRIS  (1)    , 23,                      /*            |   <null> */
	MARPATCL_RCMD_PRIO  (3), 13, 2, 14, 10,               /* <object>   ::= <lbrace> <pairs> <rbrace> */
	MARPATCL_RCMD_QUNS  (14), 15, MARPATCL_RCMD_SEPP (1), /* <pairs>    ::= <pair> * (<comma> P) */
	MARPATCL_RCMD_PRIO  (3), 15, 19, 0, 12,               /* <pair>     ::= <string> <colon> <value> */
	MARPATCL_RCMD_PRIO  (3), 16, 3, 17, 11,               /* <array>    ::= <lbracket> <elements> <rbracket> */
	MARPATCL_RCMD_QUNS  (17), 18, MARPATCL_RCMD_SEPP (1), /* <elements> ::= <element> * (<comma> P) */
	MARPATCL_RCMD_PRIO  (1), 18, 12,                      /* <element>  ::= <value> */
	MARPATCL_RCMD_PRIO  (3), 19, 9, 7, 9,                 /* <string>   ::= <quote> <lstring> <quote> */
	MARPATCL_RCMD_PRIO  (1), 20, 6,                       /* <number>   ::= <lnumber> */
	MARPATCL_RCMD_PRIO  (1), 21, 8,                       /* <true>     ::= <ltrue> */
	MARPATCL_RCMD_PRIO  (1), 22, 4,                       /* <false>    ::= <lfalse> */
	MARPATCL_RCMD_PRIO  (1), 23, 5,                       /* <null>     ::= <lnull> */
	MARPATCL_RCMD_DONE  (12)
    };

    static marpatcl_rtc_rules json_parser_c_g1 = { /* 48 */
	/* .sname   */  &json_parser_c_pool,
	/* .symbols */  { 24, json_parser_c_g1_sym_name },
	/* .rules   */  { 18, json_parser_c_g1_rule_name },
	/* .lhs     */  { 18, json_parser_c_g1_rule_lhs },
	/* .rcode   */  json_parser_c_g1_rule_definitions
    };

    static marpatcl_rtc_sym json_parser_c_g1semantics [4] = { /* 8 bytes */
	/* --- (1) --- --- --- Tag
	 */
	MARPATCL_S_SINGLE,

	/* --- (3) --- --- --- Common Semantics
	 */
	2, MARPATCL_SV_RULE_NAME, MARPATCL_SV_VALUE
    };

    static marpatcl_rtc_sym json_parser_c_g1masking [24] = { /* 48 bytes */
	/* --- (1) --- --- --- Tag
	 */
	MARPATCL_S_PER,

	/* --- (18) --- --- --- Mask Offsets
	 */
	 0,  0,  0,  0,  0,  0,  0, 20,  0, 18, 20,  0,  0, 20,  0,  0,
	 0,  0,

	/* --- (2) --- --- --- Mask Data
	 */
	/* 18 */ 1, 1,
	/* 20 */ 2, 0, 2
    };

    /*
    ** Parser definition
    */

    static marpatcl_rtc_sym json_parser_c_always [1] = { /* 2 bytes */
	12
    };

    static marpatcl_rtc_spec json_parser_c_spec = { /* 72 */
	/* .lexemes    */  12,
	/* .discards   */  1,
	/* .l_symbols  */  320,
	/* .g_symbols  */  24,
	/* .always     */  { 1, json_parser_c_always },
	/* .l0         */  &json_parser_c_l0,
	/* .g1         */  &json_parser_c_g1,
	/* .l0semantic */  { 3, json_parser_c_l0semantics },
	/* .g1semantic */  { 4, json_parser_c_g1semantics },
	/* .g1mask     */  { 24, json_parser_c_g1masking }
    };
    /* --- end of generated data structures --- */
}

# # ## ### ##### ######## ############# #####################
## Class exposing the grammar engine.

critcl::class def json::parser::c {
    insvariable marpatcl_rtc_sv_p result {
	Parse result
    } {
	instance->result = 0;
    } {
	if (instance->result) marpatcl_rtc_sv_unref (instance->result);
    }
    
    insvariable marpatcl_rtc_p state {
	C-level engine, RTC structures.
    } {
	instance->state = marpatcl_rtc_cons (&json_parser_c_spec,
					     NULL /* actions - TODO FUTURE */,
					     @stem@_result,
					     (void*) instance );
    } {
	marpatcl_rtc_destroy (instance->state);
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
    } {}

    method process-file proc {Tcl_Interp* ip Tcl_Obj* path} ok {
	int res, got;
	char* buf;
	Tcl_Obj* cbuf = Tcl_NewObj();
	Tcl_Channel in = Tcl_FSOpenFileChannel (ip, path, "r", 0666);
	if (!in) {
	    return TCL_ERROR;
	}
	Tcl_SetChannelBufferSize (in, 4096);
	Tcl_SetChannelOption (ip, in, "-translation", "binary");
	Tcl_SetChannelOption (ip, in, "-encoding",    "utf-8");
	// TODO: abort on failed set-channel-option
	
	while (!Tcl_Eof(in)) {
	    got = Tcl_ReadChars (in, cbuf, 4096, 0);
	    if (got < 0) {
		return TCL_ERROR;
	    }
	    if (!got) continue; /* Pass the buck to next Tcl_Eof */
	    buf = Tcl_GetStringFromObj (cbuf, &got);
	    marpatcl_rtc_enter (instance->state, buf, got);
	    if (marpatcl_rtc_failed (instance->state)) break;
	}
	Tcl_DecrRefCount (cbuf);

	(void) Tcl_Close (ip, in);
	return marpatcl_rtc_sv_complete (ip, &instance->result, instance->state);
    }
    
    method process proc {Tcl_Interp* ip pstring string} ok {
	marpatcl_rtc_enter (instance->state, string.s, string.len);
	return marpatcl_rtc_sv_complete (ip, &instance->result, instance->state);
    }

    support {
	/* Helper function capturing parse results (semantic values of the parser)
	** Stem:  @stem@
	** Pkg:   @package@
	** Class: @class@
	** IType: @instancetype@
	** CType: @classtype@
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