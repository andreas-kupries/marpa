# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017 Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                     http://core.tcl.tk/akupries/
##
# (c) 2018-present Grammar json::parser::c 1 By Andreas Kupries
##
##	`marpa::runtime::c`-derived Parser for grammar "json::parser::c".
##	Generated On Tue Mar 20 20:43:56 PDT 2018
##		  By aku@hephaistos
##		 Via marpa-gen
##
#* Space taken: 4899 bytes
##
#* Statistics
#* L0
#* - #Symbols:   318
#* - #Lexemes:   12
#* - #Discards:  1
#* - #Always:    1
#* - #Rule Insn: 89 (+2: setup, start-sym)
#* - #Rules:     344 (>= insn, brange)
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
    ** Shared string pool (626 bytes lengths over 313 entries)
    **                    (626 bytes offsets -----^)
    **                    (1997 bytes character content)
    */

    static marpatcl_rtc_size json_parser_c_pool_length [313] = { /* 626 bytes */
	 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
	 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  9,  8,  5,  5,
	10, 15,  7, 15, 11, 11, 11, 11, 11, 11, 11, 12,  7,  5,  5,  4,
	 3,  3,  3,  3,  3,  4,  4,  5,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  2,  2,  2,  1,  1,  1,
	 1,  1,  5,  1,  1,  1,  1,  4,  5,  5,  1,  1,  7,  6,  6,  1,
	 1,  7,  8,  8,  1,  1,  5,  8,  1,  1,  1,  1,  3,  1,  1, 14,
	14, 14, 14, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 15, 15,
	15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16,
	16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,  3,  1,
	 1,  1,  1,  1,  1,  6,  8,  6,  5,  7,  7,  5,  1,  1,  1,  1,
	 4,  6,  1,  1,  6,  1,  1,  4,  5,  5,  8,  1,  1,  5,  1,  1,
	 6,  8,  1,  1,  6,  1,  1,  4,  1,  1,  1,  1,  5,  1,  1, 10,
	 5,  1,  1,  1,  1,  1,  1,  1,  1
    };

    static marpatcl_rtc_size json_parser_c_pool_offset [313] = { /* 626 bytes */
	   0,    2,    4,    6,    8,   10,   12,   14,   16,   18,   20,   22,   24,   26,   28,   30,
	  32,   34,   36,   38,   40,   42,   44,   46,   48,   50,   52,   54,   56,   66,   75,   81,
	  87,   98,  114,  122,  138,  150,  162,  174,  186,  198,  210,  222,  235,  243,  249,  255,
	 260,  264,  268,  272,  276,  280,  285,  290,  296,  301,  306,  311,  316,  321,  326,  331,
	 336,  341,  346,  351,  356,  361,  366,  371,  376,  381,  386,  391,  396,  401,  406,  411,
	 416,  421,  426,  431,  436,  441,  446,  451,  456,  461,  466,  471,  476,  481,  486,  491,
	 496,  501,  506,  511,  516,  521,  526,  531,  536,  541,  546,  551,  556,  561,  566,  571,
	 576,  581,  586,  591,  596,  601,  606,  611,  616,  621,  626,  631,  636,  641,  646,  651,
	 656,  661,  666,  671,  676,  681,  686,  691,  696,  701,  706,  711,  716,  721,  726,  731,
	 736,  741,  746,  751,  756,  761,  766,  771,  776,  781,  786,  791,  796,  801,  806,  811,
	 816,  821,  826,  831,  836,  841,  846,  851,  856,  861,  866,  869,  872,  875,  877,  879,
	 881,  883,  885,  891,  893,  895,  897,  899,  904,  910,  916,  918,  920,  928,  935,  942,
	 944,  946,  954,  963,  972,  974,  976,  982,  991,  993,  995,  997,  999, 1003, 1005, 1007,
	1022, 1037, 1052, 1067, 1082, 1097, 1112, 1127, 1142, 1158, 1174, 1190, 1206, 1222, 1238, 1254,
	1270, 1286, 1302, 1318, 1334, 1350, 1366, 1382, 1398, 1414, 1430, 1446, 1462, 1479, 1496, 1513,
	1530, 1547, 1564, 1581, 1598, 1615, 1632, 1649, 1666, 1683, 1700, 1717, 1734, 1751, 1768, 1772,
	1774, 1776, 1778, 1780, 1782, 1784, 1791, 1800, 1807, 1813, 1821, 1829, 1835, 1837, 1839, 1841,
	1843, 1848, 1855, 1857, 1859, 1866, 1868, 1870, 1875, 1881, 1887, 1896, 1898, 1900, 1906, 1908,
	1910, 1917, 1926, 1928, 1930, 1937, 1939, 1941, 1946, 1948, 1950, 1952, 1954, 1960, 1962, 1964,
	1975, 1981, 1983, 1985, 1987, 1989, 1991, 1993, 1995
    };

    static marpatcl_rtc_string json_parser_c_pool = { /* 24 + 1997 bytes */
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
	/*  37 */ "[\\200-\\277]\0"
	/*  38 */ "[\\240-\\257]\0"
	/*  39 */ "[\\240-\\277]\0"
	/*  40 */ "[\\260-\\277]\0"
	/*  41 */ "[\\302-\\337]\0"
	/*  42 */ "[\\341-\\357]\0"
	/*  43 */ "[\\t-\\n\\r\\40]\0"
	/*  44 */ "[\\t-\\n]\0"
	/*  45 */ "[A-F]\0"
	/*  46 */ "[a-f]\0"
	/*  47 */ "[Ee]\0"
	/*  48 */ "\\40\0"
	/*  49 */ "\\42\0"
	/*  50 */ "\\50\0"
	/*  51 */ "\\51\0"
	/*  52 */ "\\73\0"
	/*  53 */ "\\133\0"
	/*  54 */ "\\134\0"
	/*  55 */ "\\134u\0"
	/*  56 */ "\\135\0"
	/*  57 */ "\\173\0"
	/*  58 */ "\\175\0"
	/*  59 */ "\\177\0"
	/*  60 */ "\\200\0"
	/*  61 */ "\\201\0"
	/*  62 */ "\\202\0"
	/*  63 */ "\\203\0"
	/*  64 */ "\\204\0"
	/*  65 */ "\\205\0"
	/*  66 */ "\\206\0"
	/*  67 */ "\\207\0"
	/*  68 */ "\\210\0"
	/*  69 */ "\\211\0"
	/*  70 */ "\\212\0"
	/*  71 */ "\\213\0"
	/*  72 */ "\\214\0"
	/*  73 */ "\\215\0"
	/*  74 */ "\\216\0"
	/*  75 */ "\\217\0"
	/*  76 */ "\\220\0"
	/*  77 */ "\\221\0"
	/*  78 */ "\\222\0"
	/*  79 */ "\\223\0"
	/*  80 */ "\\224\0"
	/*  81 */ "\\225\0"
	/*  82 */ "\\226\0"
	/*  83 */ "\\227\0"
	/*  84 */ "\\230\0"
	/*  85 */ "\\231\0"
	/*  86 */ "\\232\0"
	/*  87 */ "\\233\0"
	/*  88 */ "\\234\0"
	/*  89 */ "\\235\0"
	/*  90 */ "\\236\0"
	/*  91 */ "\\237\0"
	/*  92 */ "\\240\0"
	/*  93 */ "\\241\0"
	/*  94 */ "\\242\0"
	/*  95 */ "\\243\0"
	/*  96 */ "\\244\0"
	/*  97 */ "\\245\0"
	/*  98 */ "\\246\0"
	/*  99 */ "\\247\0"
	/* 100 */ "\\250\0"
	/* 101 */ "\\251\0"
	/* 102 */ "\\252\0"
	/* 103 */ "\\253\0"
	/* 104 */ "\\254\0"
	/* 105 */ "\\255\0"
	/* 106 */ "\\256\0"
	/* 107 */ "\\257\0"
	/* 108 */ "\\260\0"
	/* 109 */ "\\261\0"
	/* 110 */ "\\262\0"
	/* 111 */ "\\263\0"
	/* 112 */ "\\264\0"
	/* 113 */ "\\265\0"
	/* 114 */ "\\266\0"
	/* 115 */ "\\267\0"
	/* 116 */ "\\270\0"
	/* 117 */ "\\271\0"
	/* 118 */ "\\272\0"
	/* 119 */ "\\273\0"
	/* 120 */ "\\274\0"
	/* 121 */ "\\275\0"
	/* 122 */ "\\276\0"
	/* 123 */ "\\277\0"
	/* 124 */ "\\302\0"
	/* 125 */ "\\303\0"
	/* 126 */ "\\304\0"
	/* 127 */ "\\305\0"
	/* 128 */ "\\306\0"
	/* 129 */ "\\307\0"
	/* 130 */ "\\310\0"
	/* 131 */ "\\311\0"
	/* 132 */ "\\312\0"
	/* 133 */ "\\313\0"
	/* 134 */ "\\314\0"
	/* 135 */ "\\315\0"
	/* 136 */ "\\316\0"
	/* 137 */ "\\317\0"
	/* 138 */ "\\320\0"
	/* 139 */ "\\321\0"
	/* 140 */ "\\322\0"
	/* 141 */ "\\323\0"
	/* 142 */ "\\324\0"
	/* 143 */ "\\325\0"
	/* 144 */ "\\326\0"
	/* 145 */ "\\327\0"
	/* 146 */ "\\330\0"
	/* 147 */ "\\331\0"
	/* 148 */ "\\332\0"
	/* 149 */ "\\333\0"
	/* 150 */ "\\334\0"
	/* 151 */ "\\335\0"
	/* 152 */ "\\336\0"
	/* 153 */ "\\337\0"
	/* 154 */ "\\340\0"
	/* 155 */ "\\341\0"
	/* 156 */ "\\342\0"
	/* 157 */ "\\343\0"
	/* 158 */ "\\344\0"
	/* 159 */ "\\345\0"
	/* 160 */ "\\346\0"
	/* 161 */ "\\347\0"
	/* 162 */ "\\350\0"
	/* 163 */ "\\351\0"
	/* 164 */ "\\352\0"
	/* 165 */ "\\353\0"
	/* 166 */ "\\354\0"
	/* 167 */ "\\355\0"
	/* 168 */ "\\356\0"
	/* 169 */ "\\357\0"
	/* 170 */ "\\n\0"
	/* 171 */ "\\r\0"
	/* 172 */ "\\t\0"
	/* 173 */ "^\0"
	/* 174 */ "_\0"
	/* 175 */ "`\0"
	/* 176 */ "A\0"
	/* 177 */ "a\0"
	/* 178 */ "array\0"
	/* 179 */ "B\0"
	/* 180 */ "b\0"
	/* 181 */ "C\0"
	/* 182 */ "c\0"
	/* 183 */ "char\0"
	/* 184 */ "colon\0"
	/* 185 */ "comma\0"
	/* 186 */ "D\0"
	/* 187 */ "d\0"
	/* 188 */ "decimal\0"
	/* 189 */ "digits\0"
	/* 190 */ "digitz\0"
	/* 191 */ "E\0"
	/* 192 */ "e\0"
	/* 193 */ "element\0"
	/* 194 */ "elements\0"
	/* 195 */ "exponent\0"
	/* 196 */ "F\0"
	/* 197 */ "f\0"
	/* 198 */ "false\0"
	/* 199 */ "fraction\0"
	/* 200 */ "G\0"
	/* 201 */ "g\0"
	/* 202 */ "H\0"
	/* 203 */ "h\0"
	/* 204 */ "hex\0"
	/* 205 */ "I\0"
	/* 206 */ "i\0"
	/* 207 */ "ILLEGAL_BYTE_0\0"
	/* 208 */ "ILLEGAL_BYTE_1\0"
	/* 209 */ "ILLEGAL_BYTE_2\0"
	/* 210 */ "ILLEGAL_BYTE_3\0"
	/* 211 */ "ILLEGAL_BYTE_4\0"
	/* 212 */ "ILLEGAL_BYTE_5\0"
	/* 213 */ "ILLEGAL_BYTE_6\0"
	/* 214 */ "ILLEGAL_BYTE_7\0"
	/* 215 */ "ILLEGAL_BYTE_8\0"
	/* 216 */ "ILLEGAL_BYTE_11\0"
	/* 217 */ "ILLEGAL_BYTE_12\0"
	/* 218 */ "ILLEGAL_BYTE_14\0"
	/* 219 */ "ILLEGAL_BYTE_15\0"
	/* 220 */ "ILLEGAL_BYTE_16\0"
	/* 221 */ "ILLEGAL_BYTE_17\0"
	/* 222 */ "ILLEGAL_BYTE_18\0"
	/* 223 */ "ILLEGAL_BYTE_19\0"
	/* 224 */ "ILLEGAL_BYTE_20\0"
	/* 225 */ "ILLEGAL_BYTE_21\0"
	/* 226 */ "ILLEGAL_BYTE_22\0"
	/* 227 */ "ILLEGAL_BYTE_23\0"
	/* 228 */ "ILLEGAL_BYTE_24\0"
	/* 229 */ "ILLEGAL_BYTE_25\0"
	/* 230 */ "ILLEGAL_BYTE_26\0"
	/* 231 */ "ILLEGAL_BYTE_27\0"
	/* 232 */ "ILLEGAL_BYTE_28\0"
	/* 233 */ "ILLEGAL_BYTE_29\0"
	/* 234 */ "ILLEGAL_BYTE_30\0"
	/* 235 */ "ILLEGAL_BYTE_31\0"
	/* 236 */ "ILLEGAL_BYTE_192\0"
	/* 237 */ "ILLEGAL_BYTE_193\0"
	/* 238 */ "ILLEGAL_BYTE_240\0"
	/* 239 */ "ILLEGAL_BYTE_241\0"
	/* 240 */ "ILLEGAL_BYTE_242\0"
	/* 241 */ "ILLEGAL_BYTE_243\0"
	/* 242 */ "ILLEGAL_BYTE_244\0"
	/* 243 */ "ILLEGAL_BYTE_245\0"
	/* 244 */ "ILLEGAL_BYTE_246\0"
	/* 245 */ "ILLEGAL_BYTE_247\0"
	/* 246 */ "ILLEGAL_BYTE_248\0"
	/* 247 */ "ILLEGAL_BYTE_249\0"
	/* 248 */ "ILLEGAL_BYTE_250\0"
	/* 249 */ "ILLEGAL_BYTE_251\0"
	/* 250 */ "ILLEGAL_BYTE_252\0"
	/* 251 */ "ILLEGAL_BYTE_253\0"
	/* 252 */ "ILLEGAL_BYTE_254\0"
	/* 253 */ "ILLEGAL_BYTE_255\0"
	/* 254 */ "int\0"
	/* 255 */ "J\0"
	/* 256 */ "j\0"
	/* 257 */ "K\0"
	/* 258 */ "k\0"
	/* 259 */ "L\0"
	/* 260 */ "l\0"
	/* 261 */ "lbrace\0"
	/* 262 */ "lbracket\0"
	/* 263 */ "lfalse\0"
	/* 264 */ "lnull\0"
	/* 265 */ "lnumber\0"
	/* 266 */ "lstring\0"
	/* 267 */ "ltrue\0"
	/* 268 */ "M\0"
	/* 269 */ "m\0"
	/* 270 */ "N\0"
	/* 271 */ "n\0"
	/* 272 */ "null\0"
	/* 273 */ "number\0"
	/* 274 */ "O\0"
	/* 275 */ "o\0"
	/* 276 */ "object\0"
	/* 277 */ "P\0"
	/* 278 */ "p\0"
	/* 279 */ "pair\0"
	/* 280 */ "pairs\0"
	/* 281 */ "plain\0"
	/* 282 */ "positive\0"
	/* 283 */ "Q\0"
	/* 284 */ "q\0"
	/* 285 */ "quote\0"
	/* 286 */ "R\0"
	/* 287 */ "r\0"
	/* 288 */ "rbrace\0"
	/* 289 */ "rbracket\0"
	/* 290 */ "S\0"
	/* 291 */ "s\0"
	/* 292 */ "string\0"
	/* 293 */ "T\0"
	/* 294 */ "t\0"
	/* 295 */ "true\0"
	/* 296 */ "U\0"
	/* 297 */ "u\0"
	/* 298 */ "V\0"
	/* 299 */ "v\0"
	/* 300 */ "value\0"
	/* 301 */ "W\0"
	/* 302 */ "w\0"
	/* 303 */ "whitespace\0"
	/* 304 */ "whole\0"
	/* 305 */ "X\0"
	/* 306 */ "x\0"
	/* 307 */ "Y\0"
	/* 308 */ "y\0"
	/* 309 */ "Z\0"
	/* 310 */ "z\0"
	/* 311 */ "|\0"
	/* 312 */ "~\0"
    };

    /*
    ** L0 structures
    */

    static marpatcl_rtc_sym json_parser_c_l0_sym_name [318] = { /* 636 bytes */
	/* --- (256) --- --- --- Characters
	 */
	207, 208, 209, 210, 211, 212, 213, 214, 215, 172, 170, 216, 217, 171, 218, 219,
	220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235,
	 48,   0,  49,   1,   2,   3,   4,   5,  50,  51,   6,   7,   8,   9,  10,  11,
	 12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  52,  23,  24,  25,  26,
	 27, 176, 179, 181, 186, 191, 196, 200, 202, 205, 255, 257, 259, 268, 270, 274,
	277, 283, 286, 290, 293, 296, 298, 301, 305, 307, 309,  53,  54,  56, 173, 174,
	175, 177, 180, 182, 187, 192, 197, 201, 203, 206, 256, 258, 260, 269, 271, 275,
	278, 284, 287, 291, 294, 297, 299, 302, 306, 308, 310,  57, 311,  58, 312,  59,
	 60,  61,  62,  63,  64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,
	 76,  77,  78,  79,  80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,  91,
	 92,  93,  94,  95,  96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107,
	108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123,
	236, 237, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137,
	138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153,
	154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169,
	238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253,

	/* --- (12) --- --- --- ACS: Lexeme
	 */
	184, 185, 261, 262, 263, 264, 265, 266, 267, 285, 288, 289,

	/* --- (1) --- --- --- ACS: Discard
	 */
	303,

	/* --- (12) --- --- --- Lexeme
	 */
	184, 185, 261, 262, 263, 264, 265, 266, 267, 285, 288, 289,

	/* --- (1) --- --- --- Discard
	 */
	303,

	/* --- (36) --- --- --- Internal
	 */
	 33,  39,  35,  43,  47,  32,  55, 198, 272, 295, 183, 188, 189, 190, 192, 195,
	199, 204, 254, 281, 282, 304,  29,  30,  34,  36,  37,  44,  38,  40,  41,  42,
	 45,  46,  31,  28
    };

    static marpatcl_rtc_sym json_parser_c_l0_rule_definitions [261] = { /* 522 bytes */
	MARPATCL_RCMD_SETUP (6),
	MARPATCL_RCMD_PRIO  (1), 269, 58,                           /* <colon>                 ::= <@CHR:<:>> */
	MARPATCL_RCMD_PRIO  (1), 270, 44,                           /* <comma>                 ::= <@CHR:<,>> */
	MARPATCL_RCMD_PRIO  (1), 271, 123,                          /* <lbrace>                ::= <@CHR:<\173>> */
	MARPATCL_RCMD_PRIO  (1), 272, 91,                           /* <lbracket>              ::= <@CHR:<\133>> */
	MARPATCL_RCMD_PRIO  (1), 273, 289,                          /* <lfalse>                ::= <@STR:<false>> */
	MARPATCL_RCMD_PRIO  (1), 274, 290,                          /* <lnull>                 ::= <@STR:<null>> */
	MARPATCL_RCMD_PRIO  (3), 275, 300, 298, 297,                /* <lnumber>               ::= <int> <fraction> <exponent> */
	MARPATCL_RCMD_PRIS  (2)     , 300, 297,                     /*                         |   <int> <exponent> */
	MARPATCL_RCMD_PRIS  (2)     , 300, 298,                     /*                         |   <int> <fraction> */
	MARPATCL_RCMD_PRIS  (1)     , 300,                          /*                         |   <int> */
	MARPATCL_RCMD_QUN   (276), 292,                             /* <lstring>               ::= <char> * */
	MARPATCL_RCMD_PRIO  (1), 277, 291,                          /* <ltrue>                 ::= <@STR:<true>> */
	MARPATCL_RCMD_PRIO  (1), 278, 34,                           /* <quote>                 ::= <@BYTE:<\42>> */
	MARPATCL_RCMD_PRIO  (1), 279, 125,                          /* <rbrace>                ::= <@CHR:<\175>> */
	MARPATCL_RCMD_PRIO  (1), 280, 93,                           /* <rbracket>              ::= <@CHR:<\135>> */
	MARPATCL_RCMD_QUP   (281), 285,                             /* <whitespace>            ::= <@CLS:<\t-\n\r\40>> + */
	MARPATCL_RCMD_PRIO  (1), 282, 306,                          /* <@^CLS:<\0-\37\42\134>> ::= <@BRAN:<\40!>> */
	MARPATCL_RCMD_PRIS  (1)     , 304,                          /*                         |   <@BRAN:<#\133>> */
	MARPATCL_RCMD_PRIS  (1)     , 307,                          /*                         |   <@BRAN:<\135\177>> */
	MARPATCL_RCMD_PRIS  (2)     , 312, 308,                     /*                         |   <@BRAN:<\u00c2\u00df>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 224, 283, 308,                /*                         |   <@BYTE:<\u00e0>> <@BRAN:<\u00a0\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 313, 308, 308,                /*                         |   <@BRAN:<\u00e1\u00ef>> <@BRAN:<\200\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (6)     , 237, 310, 308, 237, 311, 308, /*                         |   <@BYTE:<\u00ed>> <@BRAN:<\u00a0\u00af>> <@BRAN:<\200\u00bf>> <@BYTE:<\u00ed>> <@BRAN:<\u00b0\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIO  (1), 283, 310,                          /* <@BRAN:<\u00a0\u00bf>>  ::= <@BRAN:<\u00a0\u00af>> */
	MARPATCL_RCMD_PRIS  (1)     , 311,                          /*                         |   <@BRAN:<\u00b0\u00bf>> */
	MARPATCL_RCMD_PRIO  (1), 284, 34,                           /* <@CLS:<\42/\134bfnrt>>  ::= <@BYTE:<\42>> */
	MARPATCL_RCMD_PRIS  (1)     , 47,                           /*                         |   <@BYTE:</>> */
	MARPATCL_RCMD_PRIS  (1)     , 92,                           /*                         |   <@BYTE:<\134>> */
	MARPATCL_RCMD_PRIS  (1)     , 98,                           /*                         |   <@BYTE:<b>> */
	MARPATCL_RCMD_PRIS  (1)     , 102,                          /*                         |   <@BYTE:<f>> */
	MARPATCL_RCMD_PRIS  (1)     , 110,                          /*                         |   <@BYTE:<n>> */
	MARPATCL_RCMD_PRIS  (1)     , 114,                          /*                         |   <@BYTE:<r>> */
	MARPATCL_RCMD_PRIS  (1)     , 116,                          /*                         |   <@BYTE:<t>> */
	MARPATCL_RCMD_PRIO  (1), 285, 309,                          /* <@CLS:<\t-\n\r\40>>     ::= <@BRAN:<\t\n>> */
	MARPATCL_RCMD_PRIS  (1)     , 13,                           /*                         |   <@BYTE:<\r>> */
	MARPATCL_RCMD_PRIS  (1)     , 32,                           /*                         |   <@BYTE:<\40>> */
	MARPATCL_RCMD_PRIO  (1), 286, 69,                           /* <@CLS:<Ee>>             ::= <@BYTE:<E>> */
	MARPATCL_RCMD_PRIS  (1)     , 101,                          /*                         |   <@BYTE:<e>> */
	MARPATCL_RCMD_PRIO  (1), 287, 305,                          /* <@NCC:<[:xdigit:]>>     ::= <@BRAN:<09>> */
	MARPATCL_RCMD_PRIS  (1)     , 314,                          /*                         |   <@BRAN:<AF>> */
	MARPATCL_RCMD_PRIS  (1)     , 315,                          /*                         |   <@BRAN:<af>> */
	MARPATCL_RCMD_PRIO  (2), 288, 92, 117,                      /* <@STR:<\134u>>          ::= <@BYTE:<\134>> <@BYTE:<u>> */
	MARPATCL_RCMD_PRIO  (5), 289, 102, 97, 108, 115, 101,       /* <@STR:<false>>          ::= <@BYTE:<f>> <@BYTE:<a>> <@BYTE:<l>> <@BYTE:<s>> <@BYTE:<e>> */
	MARPATCL_RCMD_PRIO  (4), 290, 110, 117, 108, 108,           /* <@STR:<null>>           ::= <@BYTE:<n>> <@BYTE:<u>> <@BYTE:<l>> <@BYTE:<l>> */
	MARPATCL_RCMD_PRIO  (4), 291, 116, 114, 117, 101,           /* <@STR:<true>>           ::= <@BYTE:<t>> <@BYTE:<r>> <@BYTE:<u>> <@BYTE:<e>> */
	MARPATCL_RCMD_PRIO  (1), 292, 301,                          /* <char>                  ::= <plain> */
	MARPATCL_RCMD_PRIS  (2)     , 92, 284,                      /*                         |   <@BYTE:<\134>> <@CLS:<\42/\134bfnrt>> */
	MARPATCL_RCMD_PRIS  (5)     , 288, 299, 299, 299, 299,      /*                         |   <@STR:<\134u>> <hex> <hex> <hex> <hex> */
	MARPATCL_RCMD_PRIO  (1), 293, 305,                          /* <decimal>               ::= <@BRAN:<09>> */
	MARPATCL_RCMD_QUP   (294), 293,                             /* <digits>                ::= <decimal> + */
	MARPATCL_RCMD_QUN   (295), 293,                             /* <digitz>                ::= <decimal> * */
	MARPATCL_RCMD_PRIO  (1), 296, 286,                          /* <e>                     ::= <@CLS:<Ee>> */
	MARPATCL_RCMD_PRIS  (2)     , 286, 45,                      /*                         |   <@CLS:<Ee>> <@CHR:<->> */
	MARPATCL_RCMD_PRIS  (2)     , 286, 43,                      /*                         |   <@CLS:<Ee>> <@CHR:<+>> */
	MARPATCL_RCMD_PRIO  (2), 297, 296, 294,                     /* <exponent>              ::= <e> <digits> */
	MARPATCL_RCMD_PRIO  (2), 298, 46, 294,                      /* <fraction>              ::= <@CHR:<.>> <digits> */
	MARPATCL_RCMD_PRIO  (1), 299, 287,                          /* <hex>                   ::= <@NCC:<[:xdigit:]>> */
	MARPATCL_RCMD_PRIO  (1), 300, 303,                          /* <int>                   ::= <whole> */
	MARPATCL_RCMD_PRIS  (2)     , 45, 303,                      /*                         |   <@CHR:<->> <whole> */
	MARPATCL_RCMD_PRIO  (1), 301, 282,                          /* <plain>                 ::= <@^CLS:<\0-\37\42\134>> */
	MARPATCL_RCMD_PRIO  (2), 302, 316, 295,                     /* <positive>              ::= <@RAN:<19>> <digitz> */
	MARPATCL_RCMD_PRIO  (1), 303, 48,                           /* <whole>                 ::= <@CHR:<0>> */
	MARPATCL_RCMD_PRIS  (1)     , 302,                          /*                         |   <positive> */
	MARPATCL_RCMD_BRAN  (304), MARPATCL_RCMD_BOXR ( 35, 91),    /* <@BRAN:<#\133>>         brange (35 - 91) */
	MARPATCL_RCMD_BRAN  (305), MARPATCL_RCMD_BOXR ( 48, 57),    /* <@BRAN:<09>>            brange (48 - 57) */
	MARPATCL_RCMD_BRAN  (306), MARPATCL_RCMD_BOXR ( 32, 33),    /* <@BRAN:<\40!>>          brange (32 - 33) */
	MARPATCL_RCMD_BRAN  (307), MARPATCL_RCMD_BOXR ( 93,127),    /* <@BRAN:<\135\177>>      brange (93 - 127) */
	MARPATCL_RCMD_BRAN  (308), MARPATCL_RCMD_BOXR (128,191),    /* <@BRAN:<\200\u00bf>>    brange (128 - 191) */
	MARPATCL_RCMD_BRAN  (309), MARPATCL_RCMD_BOXR (  9, 10),    /* <@BRAN:<\t\n>>          brange (9 - 10) */
	MARPATCL_RCMD_BRAN  (310), MARPATCL_RCMD_BOXR (160,175),    /* <@BRAN:<\u00a0\u00af>>  brange (160 - 175) */
	MARPATCL_RCMD_BRAN  (311), MARPATCL_RCMD_BOXR (176,191),    /* <@BRAN:<\u00b0\u00bf>>  brange (176 - 191) */
	MARPATCL_RCMD_BRAN  (312), MARPATCL_RCMD_BOXR (194,223),    /* <@BRAN:<\u00c2\u00df>>  brange (194 - 223) */
	MARPATCL_RCMD_BRAN  (313), MARPATCL_RCMD_BOXR (225,239),    /* <@BRAN:<\u00e1\u00ef>>  brange (225 - 239) */
	MARPATCL_RCMD_BRAN  (314), MARPATCL_RCMD_BOXR ( 65, 70),    /* <@BRAN:<AF>>            brange (65 - 70) */
	MARPATCL_RCMD_BRAN  (315), MARPATCL_RCMD_BOXR ( 97,102),    /* <@BRAN:<af>>            brange (97 - 102) */
	MARPATCL_RCMD_BRAN  (316), MARPATCL_RCMD_BOXR ( 49, 57),    /* <@RAN:<19>>             brange (49 - 57) */
	MARPATCL_RCMD_PRIO  (2), 317, 256, 269,                     /* <@L0:START>             ::= <@ACS:colon> <colon> */
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
	MARPATCL_RCMD_DONE  (317)
    };

    static marpatcl_rtc_rules json_parser_c_l0 = { /* 48 */
	/* .sname   */  &json_parser_c_pool,
	/* .symbols */  { 318, json_parser_c_l0_sym_name },
	/* .rules   */  { 0, NULL },
	/* .lhs     */  { 0, NULL },
	/* .rcode   */  json_parser_c_l0_rule_definitions,
	0
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
	184, 185, 261, 262, 263, 264, 265, 266, 267, 285, 288, 289,

	/* --- (12) --- --- --- Structure
	 */
	300, 276, 280, 279, 178, 194, 193, 292, 273, 295, 198, 272
    };

    static marpatcl_rtc_sym json_parser_c_g1_rule_name [18] = { /* 36 bytes */
	300, 300, 300, 300, 300, 300, 300, 276, 280, 279, 178, 194, 193, 292, 273, 295,
	198, 272
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
	/* .rcode   */  json_parser_c_g1_rule_definitions,
	0
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
	/* .l_symbols  */  318,
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
					     @stem@_result, (void*) instance,
					     0, 0 );
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
	    marpatcl_rtc_enter (instance->state, buf, got, 0, -1);
	    if (marpatcl_rtc_failed (instance->state)) break;
	}
	Tcl_DecrRefCount (cbuf);

	(void) Tcl_Close (ip, in);
	return marpatcl_rtc_sv_complete (ip, &instance->result, instance->state);
    }

    method process proc {Tcl_Interp* ip pstring string} ok {
	marpatcl_rtc_enter (instance->state, string.s, string.len, 0, -1);
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
