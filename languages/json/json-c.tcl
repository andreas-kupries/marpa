# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017 Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                     http://core.tcl.tk/akupries/
##
# (c) 2018 Grammar json::parser::c 1 By Andreas Kupries
##
##	`marpa::runtime::c`-derived Parser for grammar "json::parser::c".
##	Generated On Wed Jan 31 13:08:13 PST 2018
##		  By aku@hephaistos
##		 Via marpa-gen
##
#* Space taken: 5008 bytes
##
#* Statistics
#* L0
#* - #Symbols:   321
#* - #Lexemes:   12
#* - #Discards:  1
#* - #Always:    1
#* - #Rule Insn: 101 (+2: setup, start-sym)
#* - #Rules:     326 (>= insn, brange)
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
    ** Shared string pool (632 bytes lengths over 316 entries)
    **                    (632 bytes offsets -----^)
    **                    (2010 bytes character content)
    */

    static marpatcl_rtc_size json_parser_c_pool_length [316] = { /* 632 bytes */
	 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
	 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  9,  8,  5,  5,
	 9, 10, 15,  7, 15, 11, 11, 11, 11, 11, 11, 11, 11, 11,  7,  5,
	 5,  4,  3,  3,  3,  3,  3,  3,  3,  4,  4,  5,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  2,  2,
	 2,  1,  1,  1,  1,  1,  5,  1,  1, 15,  1,  1,  4,  5,  5,  1,
	 1,  7,  6,  6,  1,  1,  7,  8,  8,  1,  1,  5,  8,  1,  1,  1,
	 1,  3,  1,  1, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 15, 15,
	15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 16,
	16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
	16,  3,  1,  1,  1,  1,  1,  1,  6,  8,  6,  5,  7,  7,  5,  1,
	 1,  1,  1,  4,  6,  1,  1,  6,  1,  1,  4,  5,  5,  8,  1,  1,
	 5,  1,  1,  6,  8,  1,  1,  6,  1,  1,  4,  1,  1,  1,  1,  5,
	 1,  1, 10,  5,  1,  1,  1,  1,  1,  1,  1,  1
    };

    static marpatcl_rtc_size json_parser_c_pool_offset [316] = { /* 632 bytes */
	   0,    2,    4,    6,    8,   10,   12,   14,   16,   18,   20,   22,   24,   26,   28,   30,
	  32,   34,   36,   38,   40,   42,   44,   46,   48,   50,   52,   54,   56,   66,   75,   81,
	  87,   97,  108,  124,  132,  148,  160,  172,  184,  196,  208,  220,  232,  244,  256,  264,
	 270,  276,  281,  285,  289,  293,  297,  301,  305,  309,  314,  319,  325,  330,  335,  340,
	 345,  350,  355,  360,  365,  370,  375,  380,  385,  390,  395,  400,  405,  410,  415,  420,
	 425,  430,  435,  440,  445,  450,  455,  460,  465,  470,  475,  480,  485,  490,  495,  500,
	 505,  510,  515,  520,  525,  530,  535,  540,  545,  550,  555,  560,  565,  570,  575,  580,
	 585,  590,  595,  600,  605,  610,  615,  620,  625,  630,  635,  640,  645,  650,  655,  660,
	 665,  670,  675,  680,  685,  690,  695,  700,  705,  710,  715,  720,  725,  730,  735,  740,
	 745,  750,  755,  760,  765,  770,  775,  780,  785,  790,  795,  800,  805,  810,  815,  820,
	 825,  830,  835,  840,  845,  850,  855,  860,  865,  870,  875,  880,  885,  890,  895,  898,
	 901,  904,  906,  908,  910,  912,  914,  920,  922,  924,  940,  942,  944,  949,  955,  961,
	 963,  965,  973,  980,  987,  989,  991,  999, 1008, 1017, 1019, 1021, 1027, 1036, 1038, 1040,
	1042, 1044, 1048, 1050, 1052, 1067, 1082, 1097, 1112, 1127, 1142, 1157, 1172, 1187, 1203, 1219,
	1235, 1251, 1267, 1283, 1299, 1315, 1331, 1347, 1363, 1379, 1395, 1411, 1427, 1443, 1459, 1475,
	1492, 1509, 1526, 1543, 1560, 1577, 1594, 1611, 1628, 1645, 1662, 1679, 1696, 1713, 1730, 1747,
	1764, 1781, 1785, 1787, 1789, 1791, 1793, 1795, 1797, 1804, 1813, 1820, 1826, 1834, 1842, 1848,
	1850, 1852, 1854, 1856, 1861, 1868, 1870, 1872, 1879, 1881, 1883, 1888, 1894, 1900, 1909, 1911,
	1913, 1919, 1921, 1923, 1930, 1939, 1941, 1943, 1950, 1952, 1954, 1959, 1961, 1963, 1965, 1967,
	1973, 1975, 1977, 1988, 1994, 1996, 1998, 2000, 2002, 2004, 2006, 2008
    };

    static marpatcl_rtc_string json_parser_c_pool = { /* 24 + 2010 bytes */
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
	/*  32 */ "[:space:]\0"
	/*  33 */ "[:xdigit:]\0"
	/*  34 */ "[\\0-\\37\\42\\134]\0"
	/*  35 */ "[\\40-!]\0"
	/*  36 */ "[\\42/\\134bfnrt]\0"
	/*  37 */ "[\\135-\\177]\0"
	/*  38 */ "[\\200-\\212]\0"
	/*  39 */ "[\\200-\\237]\0"
	/*  40 */ "[\\200-\\277]\0"
	/*  41 */ "[\\240-\\277]\0"
	/*  42 */ "[\\250-\\251]\0"
	/*  43 */ "[\\302-\\337]\0"
	/*  44 */ "[\\341-\\354]\0"
	/*  45 */ "[\\356-\\357]\0"
	/*  46 */ "[\\t-\\r]\0"
	/*  47 */ "[A-F]\0"
	/*  48 */ "[a-f]\0"
	/*  49 */ "[Ee]\0"
	/*  50 */ "\\13\0"
	/*  51 */ "\\14\0"
	/*  52 */ "\\40\0"
	/*  53 */ "\\42\0"
	/*  54 */ "\\50\0"
	/*  55 */ "\\51\0"
	/*  56 */ "\\73\0"
	/*  57 */ "\\133\0"
	/*  58 */ "\\134\0"
	/*  59 */ "\\134u\0"
	/*  60 */ "\\135\0"
	/*  61 */ "\\173\0"
	/*  62 */ "\\175\0"
	/*  63 */ "\\177\0"
	/*  64 */ "\\200\0"
	/*  65 */ "\\201\0"
	/*  66 */ "\\202\0"
	/*  67 */ "\\203\0"
	/*  68 */ "\\204\0"
	/*  69 */ "\\205\0"
	/*  70 */ "\\206\0"
	/*  71 */ "\\207\0"
	/*  72 */ "\\210\0"
	/*  73 */ "\\211\0"
	/*  74 */ "\\212\0"
	/*  75 */ "\\213\0"
	/*  76 */ "\\214\0"
	/*  77 */ "\\215\0"
	/*  78 */ "\\216\0"
	/*  79 */ "\\217\0"
	/*  80 */ "\\220\0"
	/*  81 */ "\\221\0"
	/*  82 */ "\\222\0"
	/*  83 */ "\\223\0"
	/*  84 */ "\\224\0"
	/*  85 */ "\\225\0"
	/*  86 */ "\\226\0"
	/*  87 */ "\\227\0"
	/*  88 */ "\\230\0"
	/*  89 */ "\\231\0"
	/*  90 */ "\\232\0"
	/*  91 */ "\\233\0"
	/*  92 */ "\\234\0"
	/*  93 */ "\\235\0"
	/*  94 */ "\\236\0"
	/*  95 */ "\\237\0"
	/*  96 */ "\\240\0"
	/*  97 */ "\\241\0"
	/*  98 */ "\\242\0"
	/*  99 */ "\\243\0"
	/* 100 */ "\\244\0"
	/* 101 */ "\\245\0"
	/* 102 */ "\\246\0"
	/* 103 */ "\\247\0"
	/* 104 */ "\\250\0"
	/* 105 */ "\\251\0"
	/* 106 */ "\\252\0"
	/* 107 */ "\\253\0"
	/* 108 */ "\\254\0"
	/* 109 */ "\\255\0"
	/* 110 */ "\\256\0"
	/* 111 */ "\\257\0"
	/* 112 */ "\\260\0"
	/* 113 */ "\\261\0"
	/* 114 */ "\\262\0"
	/* 115 */ "\\263\0"
	/* 116 */ "\\264\0"
	/* 117 */ "\\265\0"
	/* 118 */ "\\266\0"
	/* 119 */ "\\267\0"
	/* 120 */ "\\270\0"
	/* 121 */ "\\271\0"
	/* 122 */ "\\272\0"
	/* 123 */ "\\273\0"
	/* 124 */ "\\274\0"
	/* 125 */ "\\275\0"
	/* 126 */ "\\276\0"
	/* 127 */ "\\277\0"
	/* 128 */ "\\302\0"
	/* 129 */ "\\303\0"
	/* 130 */ "\\304\0"
	/* 131 */ "\\305\0"
	/* 132 */ "\\306\0"
	/* 133 */ "\\307\0"
	/* 134 */ "\\310\0"
	/* 135 */ "\\311\0"
	/* 136 */ "\\312\0"
	/* 137 */ "\\313\0"
	/* 138 */ "\\314\0"
	/* 139 */ "\\315\0"
	/* 140 */ "\\316\0"
	/* 141 */ "\\317\0"
	/* 142 */ "\\320\0"
	/* 143 */ "\\321\0"
	/* 144 */ "\\322\0"
	/* 145 */ "\\323\0"
	/* 146 */ "\\324\0"
	/* 147 */ "\\325\0"
	/* 148 */ "\\326\0"
	/* 149 */ "\\327\0"
	/* 150 */ "\\330\0"
	/* 151 */ "\\331\0"
	/* 152 */ "\\332\0"
	/* 153 */ "\\333\0"
	/* 154 */ "\\334\0"
	/* 155 */ "\\335\0"
	/* 156 */ "\\336\0"
	/* 157 */ "\\337\0"
	/* 158 */ "\\340\0"
	/* 159 */ "\\341\0"
	/* 160 */ "\\342\0"
	/* 161 */ "\\343\0"
	/* 162 */ "\\344\0"
	/* 163 */ "\\345\0"
	/* 164 */ "\\346\0"
	/* 165 */ "\\347\0"
	/* 166 */ "\\350\0"
	/* 167 */ "\\351\0"
	/* 168 */ "\\352\0"
	/* 169 */ "\\353\0"
	/* 170 */ "\\354\0"
	/* 171 */ "\\355\0"
	/* 172 */ "\\356\0"
	/* 173 */ "\\357\0"
	/* 174 */ "\\n\0"
	/* 175 */ "\\r\0"
	/* 176 */ "\\t\0"
	/* 177 */ "^\0"
	/* 178 */ "_\0"
	/* 179 */ "`\0"
	/* 180 */ "A\0"
	/* 181 */ "a\0"
	/* 182 */ "array\0"
	/* 183 */ "B\0"
	/* 184 */ "b\0"
	/* 185 */ "BRAN<d139-d159>\0"
	/* 186 */ "C\0"
	/* 187 */ "c\0"
	/* 188 */ "char\0"
	/* 189 */ "colon\0"
	/* 190 */ "comma\0"
	/* 191 */ "D\0"
	/* 192 */ "d\0"
	/* 193 */ "decimal\0"
	/* 194 */ "digits\0"
	/* 195 */ "digitz\0"
	/* 196 */ "E\0"
	/* 197 */ "e\0"
	/* 198 */ "element\0"
	/* 199 */ "elements\0"
	/* 200 */ "exponent\0"
	/* 201 */ "F\0"
	/* 202 */ "f\0"
	/* 203 */ "false\0"
	/* 204 */ "fraction\0"
	/* 205 */ "G\0"
	/* 206 */ "g\0"
	/* 207 */ "H\0"
	/* 208 */ "h\0"
	/* 209 */ "hex\0"
	/* 210 */ "I\0"
	/* 211 */ "i\0"
	/* 212 */ "ILLEGAL_BYTE_0\0"
	/* 213 */ "ILLEGAL_BYTE_1\0"
	/* 214 */ "ILLEGAL_BYTE_2\0"
	/* 215 */ "ILLEGAL_BYTE_3\0"
	/* 216 */ "ILLEGAL_BYTE_4\0"
	/* 217 */ "ILLEGAL_BYTE_5\0"
	/* 218 */ "ILLEGAL_BYTE_6\0"
	/* 219 */ "ILLEGAL_BYTE_7\0"
	/* 220 */ "ILLEGAL_BYTE_8\0"
	/* 221 */ "ILLEGAL_BYTE_14\0"
	/* 222 */ "ILLEGAL_BYTE_15\0"
	/* 223 */ "ILLEGAL_BYTE_16\0"
	/* 224 */ "ILLEGAL_BYTE_17\0"
	/* 225 */ "ILLEGAL_BYTE_18\0"
	/* 226 */ "ILLEGAL_BYTE_19\0"
	/* 227 */ "ILLEGAL_BYTE_20\0"
	/* 228 */ "ILLEGAL_BYTE_21\0"
	/* 229 */ "ILLEGAL_BYTE_22\0"
	/* 230 */ "ILLEGAL_BYTE_23\0"
	/* 231 */ "ILLEGAL_BYTE_24\0"
	/* 232 */ "ILLEGAL_BYTE_25\0"
	/* 233 */ "ILLEGAL_BYTE_26\0"
	/* 234 */ "ILLEGAL_BYTE_27\0"
	/* 235 */ "ILLEGAL_BYTE_28\0"
	/* 236 */ "ILLEGAL_BYTE_29\0"
	/* 237 */ "ILLEGAL_BYTE_30\0"
	/* 238 */ "ILLEGAL_BYTE_31\0"
	/* 239 */ "ILLEGAL_BYTE_192\0"
	/* 240 */ "ILLEGAL_BYTE_193\0"
	/* 241 */ "ILLEGAL_BYTE_240\0"
	/* 242 */ "ILLEGAL_BYTE_241\0"
	/* 243 */ "ILLEGAL_BYTE_242\0"
	/* 244 */ "ILLEGAL_BYTE_243\0"
	/* 245 */ "ILLEGAL_BYTE_244\0"
	/* 246 */ "ILLEGAL_BYTE_245\0"
	/* 247 */ "ILLEGAL_BYTE_246\0"
	/* 248 */ "ILLEGAL_BYTE_247\0"
	/* 249 */ "ILLEGAL_BYTE_248\0"
	/* 250 */ "ILLEGAL_BYTE_249\0"
	/* 251 */ "ILLEGAL_BYTE_250\0"
	/* 252 */ "ILLEGAL_BYTE_251\0"
	/* 253 */ "ILLEGAL_BYTE_252\0"
	/* 254 */ "ILLEGAL_BYTE_253\0"
	/* 255 */ "ILLEGAL_BYTE_254\0"
	/* 256 */ "ILLEGAL_BYTE_255\0"
	/* 257 */ "int\0"
	/* 258 */ "J\0"
	/* 259 */ "j\0"
	/* 260 */ "K\0"
	/* 261 */ "k\0"
	/* 262 */ "L\0"
	/* 263 */ "l\0"
	/* 264 */ "lbrace\0"
	/* 265 */ "lbracket\0"
	/* 266 */ "lfalse\0"
	/* 267 */ "lnull\0"
	/* 268 */ "lnumber\0"
	/* 269 */ "lstring\0"
	/* 270 */ "ltrue\0"
	/* 271 */ "M\0"
	/* 272 */ "m\0"
	/* 273 */ "N\0"
	/* 274 */ "n\0"
	/* 275 */ "null\0"
	/* 276 */ "number\0"
	/* 277 */ "O\0"
	/* 278 */ "o\0"
	/* 279 */ "object\0"
	/* 280 */ "P\0"
	/* 281 */ "p\0"
	/* 282 */ "pair\0"
	/* 283 */ "pairs\0"
	/* 284 */ "plain\0"
	/* 285 */ "positive\0"
	/* 286 */ "Q\0"
	/* 287 */ "q\0"
	/* 288 */ "quote\0"
	/* 289 */ "R\0"
	/* 290 */ "r\0"
	/* 291 */ "rbrace\0"
	/* 292 */ "rbracket\0"
	/* 293 */ "S\0"
	/* 294 */ "s\0"
	/* 295 */ "string\0"
	/* 296 */ "T\0"
	/* 297 */ "t\0"
	/* 298 */ "true\0"
	/* 299 */ "U\0"
	/* 300 */ "u\0"
	/* 301 */ "V\0"
	/* 302 */ "v\0"
	/* 303 */ "value\0"
	/* 304 */ "W\0"
	/* 305 */ "w\0"
	/* 306 */ "whitespace\0"
	/* 307 */ "whole\0"
	/* 308 */ "X\0"
	/* 309 */ "x\0"
	/* 310 */ "Y\0"
	/* 311 */ "y\0"
	/* 312 */ "Z\0"
	/* 313 */ "z\0"
	/* 314 */ "|\0"
	/* 315 */ "~\0"
    };

    /*
    ** L0 structures
    */

    static marpatcl_rtc_sym json_parser_c_l0_sym_name [321] = { /* 642 bytes */
	/* --- (256) --- --- --- Characters
	 */
	212, 213, 214, 215, 216, 217, 218, 219, 220, 176, 174,  50,  51, 175, 221, 222,
	223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238,
	 52,   0,  53,   1,   2,   3,   4,   5,  54,  55,   6,   7,   8,   9,  10,  11,
	 12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  56,  23,  24,  25,  26,
	 27, 180, 183, 186, 191, 196, 201, 205, 207, 210, 258, 260, 262, 271, 273, 277,
	280, 286, 289, 293, 296, 299, 301, 304, 308, 310, 312,  57,  58,  60, 177, 178,
	179, 181, 184, 187, 192, 197, 202, 206, 208, 211, 259, 261, 263, 272, 274, 278,
	281, 287, 290, 294, 297, 300, 302, 305, 309, 311, 313,  61, 314,  62, 315,  63,
	 64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,
	 80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,  91,  92,  93,  94,  95,
	 96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
	112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127,
	239, 240, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141,
	142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157,
	158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173,
	241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256,

	/* --- (12) --- --- --- ACS: Lexeme
	 */
	189, 190, 264, 265, 266, 267, 268, 269, 270, 288, 291, 292,

	/* --- (1) --- --- --- ACS: Discard
	 */
	306,

	/* --- (12) --- --- --- Lexeme
	 */
	189, 190, 264, 265, 266, 267, 268, 269, 270, 288, 291, 292,

	/* --- (1) --- --- --- Discard
	 */
	306,

	/* --- (39) --- --- --- Internal
	 */
	 34,  39,  40,  36,  49,  32,  33,  59, 203, 275, 298, 188, 193, 194, 195, 197,
	200, 204, 209, 257, 284, 285, 307,  29,  30,  35,  37,  38,  46,  41,  42,  43,
	 44,  45,  47,  48,  31, 185,  28
    };

    static marpatcl_rtc_sym json_parser_c_l0_rule_definitions [300] = { /* 600 bytes */
	MARPATCL_RCMD_SETUP (5),
	MARPATCL_RCMD_PRIO  (1), 269, 58,                        /* <colon>                 ::= <@CHR:<:>> */
	MARPATCL_RCMD_PRIO  (1), 270, 44,                        /* <comma>                 ::= <@CHR:<,>> */
	MARPATCL_RCMD_PRIO  (1), 271, 123,                       /* <lbrace>                ::= <@CHR:<\173>> */
	MARPATCL_RCMD_PRIO  (1), 272, 91,                        /* <lbracket>              ::= <@CHR:<\133>> */
	MARPATCL_RCMD_PRIO  (1), 273, 290,                       /* <lfalse>                ::= <@STR:<false>> */
	MARPATCL_RCMD_PRIO  (1), 274, 291,                       /* <lnull>                 ::= <@STR:<null>> */
	MARPATCL_RCMD_PRIO  (3), 275, 301, 299, 298,             /* <lnumber>               ::= <int> <fraction> <exponent> */
	MARPATCL_RCMD_PRIS  (2)     , 301, 298,                  /*                         |   <int> <exponent> */
	MARPATCL_RCMD_PRIS  (2)     , 301, 299,                  /*                         |   <int> <fraction> */
	MARPATCL_RCMD_PRIS  (1)     , 301,                       /*                         |   <int> */
	MARPATCL_RCMD_QUN   (276), 293,                          /* <lstring>               ::= <char> * */
	MARPATCL_RCMD_PRIO  (1), 277, 292,                       /* <ltrue>                 ::= <@STR:<true>> */
	MARPATCL_RCMD_PRIO  (1), 278, 34,                        /* <quote>                 ::= <@BYTE:<\42>> */
	MARPATCL_RCMD_PRIO  (1), 279, 125,                       /* <rbrace>                ::= <@CHR:<\175>> */
	MARPATCL_RCMD_PRIO  (1), 280, 93,                        /* <rbracket>              ::= <@CHR:<\135>> */
	MARPATCL_RCMD_QUP   (281), 287,                          /* <whitespace>            ::= <@NCC:<[:space:]>> + */
	MARPATCL_RCMD_PRIO  (1), 282, 307,                       /* <@^CLS:<\0-\37\42\134>> ::= <@BRAN:<\40!>> */
	MARPATCL_RCMD_PRIS  (1)     , 305,                       /*                         |   <@BRAN:<#\133>> */
	MARPATCL_RCMD_PRIS  (1)     , 308,                       /*                         |   <@BRAN:<\135\177>> */
	MARPATCL_RCMD_PRIS  (2)     , 313, 284,                  /*                         |   <@BRAN:<\u00c2\u00df>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 224, 311, 284,             /*                         |   <@BYTE:<\u00e0>> <@BRAN:<\u00a0\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 314, 284, 284,             /*                         |   <@BRAN:<\u00e1\u00ec>> <@BRAN:<\200\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 237, 283, 284,             /*                         |   <@BYTE:<\u00ed>> <@BRAN:<\200\237>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 315, 284, 284,             /*                         |   <@BRAN:<\u00ee\u00ef>> <@BRAN:<\200\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIO  (1), 283, 309,                       /* <@BRAN:<\200\237>>      ::= <@BRAN:<\200\212>> */
	MARPATCL_RCMD_PRIS  (1)     , 319,                       /*                         |   <BRAN<d139-d159>> */
	MARPATCL_RCMD_PRIO  (1), 284, 283,                       /* <@BRAN:<\200\u00bf>>    ::= <@BRAN:<\200\237>> */
	MARPATCL_RCMD_PRIS  (1)     , 311,                       /*                         |   <@BRAN:<\u00a0\u00bf>> */
	MARPATCL_RCMD_PRIO  (1), 285, 34,                        /* <@CLS:<\42/\134bfnrt>>  ::= <@BYTE:<\42>> */
	MARPATCL_RCMD_PRIS  (1)     , 47,                        /*                         |   <@BYTE:</>> */
	MARPATCL_RCMD_PRIS  (1)     , 92,                        /*                         |   <@BYTE:<\134>> */
	MARPATCL_RCMD_PRIS  (1)     , 98,                        /*                         |   <@BYTE:<b>> */
	MARPATCL_RCMD_PRIS  (1)     , 102,                       /*                         |   <@BYTE:<f>> */
	MARPATCL_RCMD_PRIS  (1)     , 110,                       /*                         |   <@BYTE:<n>> */
	MARPATCL_RCMD_PRIS  (1)     , 114,                       /*                         |   <@BYTE:<r>> */
	MARPATCL_RCMD_PRIS  (1)     , 116,                       /*                         |   <@BYTE:<t>> */
	MARPATCL_RCMD_PRIO  (1), 286, 69,                        /* <@CLS:<Ee>>             ::= <@BYTE:<E>> */
	MARPATCL_RCMD_PRIS  (1)     , 101,                       /*                         |   <@BYTE:<e>> */
	MARPATCL_RCMD_PRIO  (1), 287, 310,                       /* <@NCC:<[:space:]>>      ::= <@BRAN:<\t\r>> */
	MARPATCL_RCMD_PRIS  (1)     , 32,                        /*                         |   <@BYTE:<\40>> */
	MARPATCL_RCMD_PRIS  (2)     , 194, 160,                  /*                         |   <@BYTE:<\u00c2>> <@BYTE:<\u00a0>> */
	MARPATCL_RCMD_PRIS  (3)     , 225, 154, 128,             /*                         |   <@BYTE:<\u00e1>> <@BYTE:<\232>> <@BYTE:<\200>> */
	MARPATCL_RCMD_PRIS  (3)     , 225, 160, 142,             /*                         |   <@BYTE:<\u00e1>> <@BYTE:<\u00a0>> <@BYTE:<\216>> */
	MARPATCL_RCMD_PRIS  (3)     , 226, 128, 309,             /*                         |   <@BYTE:<\u00e2>> <@BYTE:<\200>> <@BRAN:<\200\212>> */
	MARPATCL_RCMD_PRIS  (3)     , 226, 128, 312,             /*                         |   <@BYTE:<\u00e2>> <@BYTE:<\200>> <@BRAN:<\u00a8\u00a9>> */
	MARPATCL_RCMD_PRIS  (3)     , 226, 128, 175,             /*                         |   <@BYTE:<\u00e2>> <@BYTE:<\200>> <@BYTE:<\u00af>> */
	MARPATCL_RCMD_PRIS  (3)     , 226, 129, 159,             /*                         |   <@BYTE:<\u00e2>> <@BYTE:<\201>> <@BYTE:<\237>> */
	MARPATCL_RCMD_PRIS  (3)     , 227, 128, 128,             /*                         |   <@BYTE:<\u00e3>> <@BYTE:<\200>> <@BYTE:<\200>> */
	MARPATCL_RCMD_PRIO  (1), 288, 306,                       /* <@NCC:<[:xdigit:]>>     ::= <@BRAN:<09>> */
	MARPATCL_RCMD_PRIS  (1)     , 316,                       /*                         |   <@BRAN:<AF>> */
	MARPATCL_RCMD_PRIS  (1)     , 317,                       /*                         |   <@BRAN:<af>> */
	MARPATCL_RCMD_PRIO  (2), 289, 92, 117,                   /* <@STR:<\134u>>          ::= <@BYTE:<\134>> <@BYTE:<u>> */
	MARPATCL_RCMD_PRIO  (5), 290, 102, 97, 108, 115, 101,    /* <@STR:<false>>          ::= <@BYTE:<f>> <@BYTE:<a>> <@BYTE:<l>> <@BYTE:<s>> <@BYTE:<e>> */
	MARPATCL_RCMD_PRIO  (4), 291, 110, 117, 108, 108,        /* <@STR:<null>>           ::= <@BYTE:<n>> <@BYTE:<u>> <@BYTE:<l>> <@BYTE:<l>> */
	MARPATCL_RCMD_PRIO  (4), 292, 116, 114, 117, 101,        /* <@STR:<true>>           ::= <@BYTE:<t>> <@BYTE:<r>> <@BYTE:<u>> <@BYTE:<e>> */
	MARPATCL_RCMD_PRIO  (1), 293, 302,                       /* <char>                  ::= <plain> */
	MARPATCL_RCMD_PRIS  (2)     , 92, 285,                   /*                         |   <@BYTE:<\134>> <@CLS:<\42/\134bfnrt>> */
	MARPATCL_RCMD_PRIS  (5)     , 289, 300, 300, 300, 300,   /*                         |   <@STR:<\134u>> <hex> <hex> <hex> <hex> */
	MARPATCL_RCMD_PRIO  (1), 294, 306,                       /* <decimal>               ::= <@BRAN:<09>> */
	MARPATCL_RCMD_QUP   (295), 294,                          /* <digits>                ::= <decimal> + */
	MARPATCL_RCMD_QUN   (296), 294,                          /* <digitz>                ::= <decimal> * */
	MARPATCL_RCMD_PRIO  (1), 297, 286,                       /* <e>                     ::= <@CLS:<Ee>> */
	MARPATCL_RCMD_PRIS  (2)     , 286, 45,                   /*                         |   <@CLS:<Ee>> <@CHR:<->> */
	MARPATCL_RCMD_PRIS  (2)     , 286, 43,                   /*                         |   <@CLS:<Ee>> <@CHR:<+>> */
	MARPATCL_RCMD_PRIO  (2), 298, 297, 295,                  /* <exponent>              ::= <e> <digits> */
	MARPATCL_RCMD_PRIO  (2), 299, 46, 295,                   /* <fraction>              ::= <@CHR:<.>> <digits> */
	MARPATCL_RCMD_PRIO  (1), 300, 288,                       /* <hex>                   ::= <@NCC:<[:xdigit:]>> */
	MARPATCL_RCMD_PRIO  (1), 301, 304,                       /* <int>                   ::= <whole> */
	MARPATCL_RCMD_PRIS  (2)     , 45, 304,                   /*                         |   <@CHR:<->> <whole> */
	MARPATCL_RCMD_PRIO  (1), 302, 282,                       /* <plain>                 ::= <@^CLS:<\0-\37\42\134>> */
	MARPATCL_RCMD_PRIO  (2), 303, 318, 296,                  /* <positive>              ::= <@RAN:<19>> <digitz> */
	MARPATCL_RCMD_PRIO  (1), 304, 48,                        /* <whole>                 ::= <@CHR:<0>> */
	MARPATCL_RCMD_PRIS  (1)     , 303,                       /*                         |   <positive> */
	MARPATCL_RCMD_BRAN  (305), MARPATCL_RCMD_BOXR ( 35, 91), /* <@BRAN:<#\133>>         brange (35 - 91) */
	MARPATCL_RCMD_BRAN  (306), MARPATCL_RCMD_BOXR ( 48, 57), /* <@BRAN:<09>>            brange (48 - 57) */
	MARPATCL_RCMD_BRAN  (307), MARPATCL_RCMD_BOXR ( 32, 33), /* <@BRAN:<\40!>>          brange (32 - 33) */
	MARPATCL_RCMD_BRAN  (308), MARPATCL_RCMD_BOXR ( 93,127), /* <@BRAN:<\135\177>>      brange (93 - 127) */
	MARPATCL_RCMD_BRAN  (309), MARPATCL_RCMD_BOXR (128,138), /* <@BRAN:<\200\212>>      brange (128 - 138) */
	MARPATCL_RCMD_BRAN  (310), MARPATCL_RCMD_BOXR (  9, 13), /* <@BRAN:<\t\r>>          brange (9 - 13) */
	MARPATCL_RCMD_BRAN  (311), MARPATCL_RCMD_BOXR (160,191), /* <@BRAN:<\u00a0\u00bf>>  brange (160 - 191) */
	MARPATCL_RCMD_BRAN  (312), MARPATCL_RCMD_BOXR (168,169), /* <@BRAN:<\u00a8\u00a9>>  brange (168 - 169) */
	MARPATCL_RCMD_BRAN  (313), MARPATCL_RCMD_BOXR (194,223), /* <@BRAN:<\u00c2\u00df>>  brange (194 - 223) */
	MARPATCL_RCMD_BRAN  (314), MARPATCL_RCMD_BOXR (225,236), /* <@BRAN:<\u00e1\u00ec>>  brange (225 - 236) */
	MARPATCL_RCMD_BRAN  (315), MARPATCL_RCMD_BOXR (238,239), /* <@BRAN:<\u00ee\u00ef>>  brange (238 - 239) */
	MARPATCL_RCMD_BRAN  (316), MARPATCL_RCMD_BOXR ( 65, 70), /* <@BRAN:<AF>>            brange (65 - 70) */
	MARPATCL_RCMD_BRAN  (317), MARPATCL_RCMD_BOXR ( 97,102), /* <@BRAN:<af>>            brange (97 - 102) */
	MARPATCL_RCMD_BRAN  (318), MARPATCL_RCMD_BOXR ( 49, 57), /* <@RAN:<19>>             brange (49 - 57) */
	MARPATCL_RCMD_BRAN  (319), MARPATCL_RCMD_BOXR (139,159), /* <BRAN<d139-d159>>       brange (139 - 159) */
	MARPATCL_RCMD_PRIO  (2), 320, 256, 269,                  /* <@L0:START>             ::= <@ACS:colon> <colon> */
	MARPATCL_RCMD_PRIS  (2)     , 257, 270,                  /*                         |   <@ACS:comma> <comma> */
	MARPATCL_RCMD_PRIS  (2)     , 258, 271,                  /*                         |   <@ACS:lbrace> <lbrace> */
	MARPATCL_RCMD_PRIS  (2)     , 259, 272,                  /*                         |   <@ACS:lbracket> <lbracket> */
	MARPATCL_RCMD_PRIS  (2)     , 260, 273,                  /*                         |   <@ACS:lfalse> <lfalse> */
	MARPATCL_RCMD_PRIS  (2)     , 261, 274,                  /*                         |   <@ACS:lnull> <lnull> */
	MARPATCL_RCMD_PRIS  (2)     , 262, 275,                  /*                         |   <@ACS:lnumber> <lnumber> */
	MARPATCL_RCMD_PRIS  (2)     , 263, 276,                  /*                         |   <@ACS:lstring> <lstring> */
	MARPATCL_RCMD_PRIS  (2)     , 264, 277,                  /*                         |   <@ACS:ltrue> <ltrue> */
	MARPATCL_RCMD_PRIS  (2)     , 265, 278,                  /*                         |   <@ACS:quote> <quote> */
	MARPATCL_RCMD_PRIS  (2)     , 266, 279,                  /*                         |   <@ACS:rbrace> <rbrace> */
	MARPATCL_RCMD_PRIS  (2)     , 267, 280,                  /*                         |   <@ACS:rbracket> <rbracket> */
	MARPATCL_RCMD_PRIS  (2)     , 268, 281,                  /*                         |   <@ACS:whitespace> <whitespace> */
	MARPATCL_RCMD_DONE  (320)
    };

    static marpatcl_rtc_rules json_parser_c_l0 = { /* 48 */
	/* .sname   */  &json_parser_c_pool,
	/* .symbols */  { 321, json_parser_c_l0_sym_name },
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
	189, 190, 264, 265, 266, 267, 268, 269, 270, 288, 291, 292,

	/* --- (12) --- --- --- Structure
	 */
	303, 279, 283, 282, 182, 199, 198, 295, 276, 298, 203, 275
    };

    static marpatcl_rtc_sym json_parser_c_g1_rule_name [18] = { /* 36 bytes */
	303, 303, 303, 303, 303, 303, 303, 279, 283, 282, 182, 199, 198, 295, 276, 298,
	203, 275
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
	/* .l_symbols  */  321,
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
	Tcl_Channel in = Tcl_FSOpenFileChannel (ip, path, "r", 0666);
	if (!in) {
	    return TCL_ERROR;
	}
	Tcl_SetChannelBufferSize (in, 4096);
	Tcl_SetChannelOption (ip, in, "-translation", "binary");
	Tcl_SetChannelOption (ip, in, "-encoding",    "binary");
	// TODO: abort on failed set-channel-option
	
	buf = NALLOC (char, 4096); // TODO: configurable
	while (!Tcl_Eof(in)) {
	    got = Tcl_Read (in, buf, 4096);
	    if (!got) continue; /* Pass the buck to next Tcl_Eof */
	    marpatcl_rtc_enter (instance->state, buf, got);
	    if (marpatcl_rtc_failed (instance->state)) break;
	}
	FREE (buf);

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