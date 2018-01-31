# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017 Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                     http://core.tcl.tk/akupries/
##
# (c) 2018 Grammar json::parser::c 1 By Andreas Kupries
##
##	`marpa::runtime::c`-derived Parser for grammar "json::parser::c".
##	Generated On Tue Jan 30 16:42:41 PST 2018
##		  By aku@hephaistos
##		 Via marpa-gen
##
#* Space taken: 6130 bytes
##
#* Statistics
#* L0
#* - #Symbols:   356
#* - #Lexemes:   12
#* - #Discards:  1
#* - #Always:    1
#* - #Rule Insn: 179 (+2: setup, start-sym)
#* - #Rules:     682 (>= insn, brange)
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
    ** Shared string pool (702 bytes lengths over 351 entries)
    **                    (702 bytes offsets -----^)
    **                    (2484 bytes character content)
    */

    static marpatcl_rtc_size json_parser_c_pool_length [351] = { /* 702 bytes */
	 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
	 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  9,  8,  5,  5,
	 9, 10, 14,  7, 20,  8, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11,
	11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11,
	11, 11, 11, 11, 11, 11,  7,  5,  5,  4,  3,  3,  3,  3,  3,  3,
	 3,  3,  4,  4,  5,  5,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  2,  2,  2,  1,  1,  1,  1,  1,  5,  1,  1,
	15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 10,  1,  1,  4,  5,
	 5,  1,  1,  7,  6,  6,  1,  1,  7,  8,  8,  1,  1,  5,  8,  1,
	 1,  1,  1,  3,  1,  1, 14, 14, 14, 14, 14, 14, 14, 14, 15, 15,
	15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
	16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
	16, 16, 16, 16,  3,  1,  1,  1,  1,  1,  1,  6,  8,  6,  5,  7,
	 7,  5,  1,  1,  1,  1,  4,  6,  1,  1,  6,  1,  1,  4,  5,  5,
	 8,  1,  1,  5,  1,  1,  6,  8,  1,  1,  6,  1,  1,  4,  1,  1,
	 1,  1,  5,  1,  1, 10,  5,  1,  1,  1,  1,  1,  1,  1,  1
    };

    static marpatcl_rtc_size json_parser_c_pool_offset [351] = { /* 702 bytes */
	   0,    2,    4,    6,    8,   10,   12,   14,   16,   18,   20,   22,   24,   26,   28,   30,
	  32,   34,   36,   38,   40,   42,   44,   46,   48,   50,   52,   54,   56,   66,   75,   81,
	  87,   97,  108,  123,  131,  152,  161,  173,  185,  197,  209,  221,  233,  245,  257,  269,
	 281,  293,  305,  317,  329,  341,  353,  365,  377,  389,  401,  413,  425,  437,  449,  461,
	 473,  485,  497,  509,  521,  533,  545,  553,  559,  565,  570,  574,  578,  582,  586,  590,
	 594,  598,  602,  607,  612,  618,  624,  629,  634,  639,  644,  649,  654,  659,  664,  669,
	 674,  679,  684,  689,  694,  699,  704,  709,  714,  719,  724,  729,  734,  739,  744,  749,
	 754,  759,  764,  769,  774,  779,  784,  789,  794,  799,  804,  809,  814,  819,  824,  829,
	 834,  839,  844,  849,  854,  859,  864,  869,  874,  879,  884,  889,  894,  899,  904,  909,
	 914,  919,  924,  929,  934,  939,  944,  949,  954,  959,  964,  969,  974,  979,  984,  989,
	 994,  999, 1004, 1009, 1014, 1019, 1024, 1029, 1034, 1039, 1044, 1049, 1054, 1059, 1064, 1069,
	1074, 1079, 1084, 1089, 1094, 1099, 1104, 1109, 1114, 1119, 1124, 1129, 1134, 1139, 1144, 1149,
	1154, 1159, 1164, 1169, 1174, 1179, 1182, 1185, 1188, 1190, 1192, 1194, 1196, 1198, 1204, 1206,
	1208, 1224, 1240, 1256, 1272, 1288, 1304, 1320, 1336, 1352, 1368, 1384, 1395, 1397, 1399, 1404,
	1410, 1416, 1418, 1420, 1428, 1435, 1442, 1444, 1446, 1454, 1463, 1472, 1474, 1476, 1482, 1491,
	1493, 1495, 1497, 1499, 1503, 1505, 1507, 1522, 1537, 1552, 1567, 1582, 1597, 1612, 1627, 1643,
	1659, 1675, 1691, 1707, 1723, 1739, 1755, 1771, 1787, 1803, 1819, 1835, 1851, 1867, 1883, 1899,
	1915, 1932, 1949, 1966, 1983, 2000, 2017, 2034, 2051, 2068, 2085, 2102, 2119, 2136, 2153, 2170,
	2187, 2204, 2221, 2238, 2255, 2259, 2261, 2263, 2265, 2267, 2269, 2271, 2278, 2287, 2294, 2300,
	2308, 2316, 2322, 2324, 2326, 2328, 2330, 2335, 2342, 2344, 2346, 2353, 2355, 2357, 2362, 2368,
	2374, 2383, 2385, 2387, 2393, 2395, 2397, 2404, 2413, 2415, 2417, 2424, 2426, 2428, 2433, 2435,
	2437, 2439, 2441, 2447, 2449, 2451, 2462, 2468, 2470, 2472, 2474, 2476, 2478, 2480, 2482
    };

    static marpatcl_rtc_string json_parser_c_pool = { /* 24 + 2484 bytes */
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
	/*  34 */ "[\\10\\42/bfnrt]\0"
	/*  35 */ "[\\40-!]\0"
	/*  36 */ "[\\42\\134[:control:]]\0"
	/*  37 */ "[\\135-~]\0"
	/*  38 */ "[\\200-\\212]\0"
	/*  39 */ "[\\200-\\215]\0"
	/*  40 */ "[\\200-\\216]\0"
	/*  41 */ "[\\200-\\234]\0"
	/*  42 */ "[\\200-\\237]\0"
	/*  43 */ "[\\200-\\241]\0"
	/*  44 */ "[\\200-\\270]\0"
	/*  45 */ "[\\200-\\276]\0"
	/*  46 */ "[\\200-\\277]\0"
	/*  47 */ "[\\202-\\277]\0"
	/*  48 */ "[\\206-\\233]\0"
	/*  49 */ "[\\217-\\277]\0"
	/*  50 */ "[\\220-\\251]\0"
	/*  51 */ "[\\220-\\277]\0"
	/*  52 */ "[\\235-\\277]\0"
	/*  53 */ "[\\236-\\277]\0"
	/*  54 */ "[\\240-\\242]\0"
	/*  55 */ "[\\240-\\254]\0"
	/*  56 */ "[\\241-\\277]\0"
	/*  57 */ "[\\243-\\277]\0"
	/*  58 */ "[\\244-\\272]\0"
	/*  59 */ "[\\244-\\277]\0"
	/*  60 */ "[\\250-\\251]\0"
	/*  61 */ "[\\256-\\277]\0"
	/*  62 */ "[\\257-\\277]\0"
	/*  63 */ "[\\260-\\277]\0"
	/*  64 */ "[\\274-\\276]\0"
	/*  65 */ "[\\274-\\277]\0"
	/*  66 */ "[\\303-\\327]\0"
	/*  67 */ "[\\331-\\332]\0"
	/*  68 */ "[\\335-\\337]\0"
	/*  69 */ "[\\343-\\354]\0"
	/*  70 */ "[\\t-\\r]\0"
	/*  71 */ "[A-F]\0"
	/*  72 */ "[a-f]\0"
	/*  73 */ "[Ee]\0"
	/*  74 */ "\\10\0"
	/*  75 */ "\\13\0"
	/*  76 */ "\\14\0"
	/*  77 */ "\\40\0"
	/*  78 */ "\\42\0"
	/*  79 */ "\\50\0"
	/*  80 */ "\\51\0"
	/*  81 */ "\\73\0"
	/*  82 */ "\\133\0"
	/*  83 */ "\\134\0"
	/*  84 */ "\\134b\0"
	/*  85 */ "\\134u\0"
	/*  86 */ "\\135\0"
	/*  87 */ "\\173\0"
	/*  88 */ "\\175\0"
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
	/* 123 */ "\\243\0"
	/* 124 */ "\\244\0"
	/* 125 */ "\\245\0"
	/* 126 */ "\\246\0"
	/* 127 */ "\\247\0"
	/* 128 */ "\\250\0"
	/* 129 */ "\\251\0"
	/* 130 */ "\\252\0"
	/* 131 */ "\\253\0"
	/* 132 */ "\\254\0"
	/* 133 */ "\\255\0"
	/* 134 */ "\\256\0"
	/* 135 */ "\\257\0"
	/* 136 */ "\\260\0"
	/* 137 */ "\\261\0"
	/* 138 */ "\\262\0"
	/* 139 */ "\\263\0"
	/* 140 */ "\\264\0"
	/* 141 */ "\\265\0"
	/* 142 */ "\\266\0"
	/* 143 */ "\\267\0"
	/* 144 */ "\\270\0"
	/* 145 */ "\\271\0"
	/* 146 */ "\\272\0"
	/* 147 */ "\\273\0"
	/* 148 */ "\\274\0"
	/* 149 */ "\\275\0"
	/* 150 */ "\\276\0"
	/* 151 */ "\\277\0"
	/* 152 */ "\\302\0"
	/* 153 */ "\\303\0"
	/* 154 */ "\\304\0"
	/* 155 */ "\\305\0"
	/* 156 */ "\\306\0"
	/* 157 */ "\\307\0"
	/* 158 */ "\\310\0"
	/* 159 */ "\\311\0"
	/* 160 */ "\\312\0"
	/* 161 */ "\\313\0"
	/* 162 */ "\\314\0"
	/* 163 */ "\\315\0"
	/* 164 */ "\\316\0"
	/* 165 */ "\\317\0"
	/* 166 */ "\\320\0"
	/* 167 */ "\\321\0"
	/* 168 */ "\\322\0"
	/* 169 */ "\\323\0"
	/* 170 */ "\\324\0"
	/* 171 */ "\\325\0"
	/* 172 */ "\\326\0"
	/* 173 */ "\\327\0"
	/* 174 */ "\\330\0"
	/* 175 */ "\\331\0"
	/* 176 */ "\\332\0"
	/* 177 */ "\\333\0"
	/* 178 */ "\\334\0"
	/* 179 */ "\\335\0"
	/* 180 */ "\\336\0"
	/* 181 */ "\\337\0"
	/* 182 */ "\\340\0"
	/* 183 */ "\\341\0"
	/* 184 */ "\\342\0"
	/* 185 */ "\\343\0"
	/* 186 */ "\\344\0"
	/* 187 */ "\\345\0"
	/* 188 */ "\\346\0"
	/* 189 */ "\\347\0"
	/* 190 */ "\\350\0"
	/* 191 */ "\\351\0"
	/* 192 */ "\\352\0"
	/* 193 */ "\\353\0"
	/* 194 */ "\\354\0"
	/* 195 */ "\\355\0"
	/* 196 */ "\\357\0"
	/* 197 */ "\\n\0"
	/* 198 */ "\\r\0"
	/* 199 */ "\\t\0"
	/* 200 */ "^\0"
	/* 201 */ "_\0"
	/* 202 */ "`\0"
	/* 203 */ "A\0"
	/* 204 */ "a\0"
	/* 205 */ "array\0"
	/* 206 */ "B\0"
	/* 207 */ "b\0"
	/* 208 */ "BRAN<d139-d141>\0"
	/* 209 */ "BRAN<d143-d156>\0"
	/* 210 */ "BRAN<d157-d159>\0"
	/* 211 */ "BRAN<d160-d161>\0"
	/* 212 */ "BRAN<d160-d191>\0"
	/* 213 */ "BRAN<d162-d184>\0"
	/* 214 */ "BRAN<d163-d172>\0"
	/* 215 */ "BRAN<d170-d191>\0"
	/* 216 */ "BRAN<d173-d191>\0"
	/* 217 */ "BRAN<d185-d190>\0"
	/* 218 */ "BRAN<d187-d191>\0"
	/* 219 */ "BYTE<d162>\0"
	/* 220 */ "C\0"
	/* 221 */ "c\0"
	/* 222 */ "char\0"
	/* 223 */ "colon\0"
	/* 224 */ "comma\0"
	/* 225 */ "D\0"
	/* 226 */ "d\0"
	/* 227 */ "decimal\0"
	/* 228 */ "digits\0"
	/* 229 */ "digitz\0"
	/* 230 */ "E\0"
	/* 231 */ "e\0"
	/* 232 */ "element\0"
	/* 233 */ "elements\0"
	/* 234 */ "exponent\0"
	/* 235 */ "F\0"
	/* 236 */ "f\0"
	/* 237 */ "false\0"
	/* 238 */ "fraction\0"
	/* 239 */ "G\0"
	/* 240 */ "g\0"
	/* 241 */ "H\0"
	/* 242 */ "h\0"
	/* 243 */ "hex\0"
	/* 244 */ "I\0"
	/* 245 */ "i\0"
	/* 246 */ "ILLEGAL_BYTE_0\0"
	/* 247 */ "ILLEGAL_BYTE_1\0"
	/* 248 */ "ILLEGAL_BYTE_2\0"
	/* 249 */ "ILLEGAL_BYTE_3\0"
	/* 250 */ "ILLEGAL_BYTE_4\0"
	/* 251 */ "ILLEGAL_BYTE_5\0"
	/* 252 */ "ILLEGAL_BYTE_6\0"
	/* 253 */ "ILLEGAL_BYTE_7\0"
	/* 254 */ "ILLEGAL_BYTE_14\0"
	/* 255 */ "ILLEGAL_BYTE_15\0"
	/* 256 */ "ILLEGAL_BYTE_16\0"
	/* 257 */ "ILLEGAL_BYTE_17\0"
	/* 258 */ "ILLEGAL_BYTE_18\0"
	/* 259 */ "ILLEGAL_BYTE_19\0"
	/* 260 */ "ILLEGAL_BYTE_20\0"
	/* 261 */ "ILLEGAL_BYTE_21\0"
	/* 262 */ "ILLEGAL_BYTE_22\0"
	/* 263 */ "ILLEGAL_BYTE_23\0"
	/* 264 */ "ILLEGAL_BYTE_24\0"
	/* 265 */ "ILLEGAL_BYTE_25\0"
	/* 266 */ "ILLEGAL_BYTE_26\0"
	/* 267 */ "ILLEGAL_BYTE_27\0"
	/* 268 */ "ILLEGAL_BYTE_28\0"
	/* 269 */ "ILLEGAL_BYTE_29\0"
	/* 270 */ "ILLEGAL_BYTE_30\0"
	/* 271 */ "ILLEGAL_BYTE_31\0"
	/* 272 */ "ILLEGAL_BYTE_127\0"
	/* 273 */ "ILLEGAL_BYTE_192\0"
	/* 274 */ "ILLEGAL_BYTE_193\0"
	/* 275 */ "ILLEGAL_BYTE_238\0"
	/* 276 */ "ILLEGAL_BYTE_240\0"
	/* 277 */ "ILLEGAL_BYTE_241\0"
	/* 278 */ "ILLEGAL_BYTE_242\0"
	/* 279 */ "ILLEGAL_BYTE_243\0"
	/* 280 */ "ILLEGAL_BYTE_244\0"
	/* 281 */ "ILLEGAL_BYTE_245\0"
	/* 282 */ "ILLEGAL_BYTE_246\0"
	/* 283 */ "ILLEGAL_BYTE_247\0"
	/* 284 */ "ILLEGAL_BYTE_248\0"
	/* 285 */ "ILLEGAL_BYTE_249\0"
	/* 286 */ "ILLEGAL_BYTE_250\0"
	/* 287 */ "ILLEGAL_BYTE_251\0"
	/* 288 */ "ILLEGAL_BYTE_252\0"
	/* 289 */ "ILLEGAL_BYTE_253\0"
	/* 290 */ "ILLEGAL_BYTE_254\0"
	/* 291 */ "ILLEGAL_BYTE_255\0"
	/* 292 */ "int\0"
	/* 293 */ "J\0"
	/* 294 */ "j\0"
	/* 295 */ "K\0"
	/* 296 */ "k\0"
	/* 297 */ "L\0"
	/* 298 */ "l\0"
	/* 299 */ "lbrace\0"
	/* 300 */ "lbracket\0"
	/* 301 */ "lfalse\0"
	/* 302 */ "lnull\0"
	/* 303 */ "lnumber\0"
	/* 304 */ "lstring\0"
	/* 305 */ "ltrue\0"
	/* 306 */ "M\0"
	/* 307 */ "m\0"
	/* 308 */ "N\0"
	/* 309 */ "n\0"
	/* 310 */ "null\0"
	/* 311 */ "number\0"
	/* 312 */ "O\0"
	/* 313 */ "o\0"
	/* 314 */ "object\0"
	/* 315 */ "P\0"
	/* 316 */ "p\0"
	/* 317 */ "pair\0"
	/* 318 */ "pairs\0"
	/* 319 */ "plain\0"
	/* 320 */ "positive\0"
	/* 321 */ "Q\0"
	/* 322 */ "q\0"
	/* 323 */ "quote\0"
	/* 324 */ "R\0"
	/* 325 */ "r\0"
	/* 326 */ "rbrace\0"
	/* 327 */ "rbracket\0"
	/* 328 */ "S\0"
	/* 329 */ "s\0"
	/* 330 */ "string\0"
	/* 331 */ "T\0"
	/* 332 */ "t\0"
	/* 333 */ "true\0"
	/* 334 */ "U\0"
	/* 335 */ "u\0"
	/* 336 */ "V\0"
	/* 337 */ "v\0"
	/* 338 */ "value\0"
	/* 339 */ "W\0"
	/* 340 */ "w\0"
	/* 341 */ "whitespace\0"
	/* 342 */ "whole\0"
	/* 343 */ "X\0"
	/* 344 */ "x\0"
	/* 345 */ "Y\0"
	/* 346 */ "y\0"
	/* 347 */ "Z\0"
	/* 348 */ "z\0"
	/* 349 */ "|\0"
	/* 350 */ "~\0"
    };

    /*
    ** L0 structures
    */

    static marpatcl_rtc_sym json_parser_c_l0_sym_name [356] = { /* 712 bytes */
	/* --- (256) --- --- --- Characters
	 */
	246, 247, 248, 249, 250, 251, 252, 253,  74, 199, 197,  75,  76, 198, 254, 255,
	256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271,
	 77,   0,  78,   1,   2,   3,   4,   5,  79,  80,   6,   7,   8,   9,  10,  11,
	 12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  81,  23,  24,  25,  26,
	 27, 203, 206, 220, 225, 230, 235, 239, 241, 244, 293, 295, 297, 306, 308, 312,
	315, 321, 324, 328, 331, 334, 336, 339, 343, 345, 347,  82,  83,  86, 200, 201,
	202, 204, 207, 221, 226, 231, 236, 240, 242, 245, 294, 296, 298, 307, 309, 313,
	316, 322, 325, 329, 332, 335, 337, 340, 344, 346, 348,  87, 349,  88, 350, 272,
	 89,  90,  91,  92,  93,  94,  95,  96,  97,  98,  99, 100, 101, 102, 103, 104,
	105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120,
	121, 122, 219, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135,
	136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151,
	273, 274, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165,
	166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181,
	182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 275, 196,
	276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291,

	/* --- (12) --- --- --- ACS: Lexeme
	 */
	223, 224, 299, 300, 301, 302, 303, 304, 305, 323, 326, 327,

	/* --- (1) --- --- --- ACS: Discard
	 */
	341,

	/* --- (12) --- --- --- Lexeme
	 */
	223, 224, 299, 300, 301, 302, 303, 304, 305, 323, 326, 327,

	/* --- (1) --- --- --- Discard
	 */
	341,

	/* --- (74) --- --- --- Internal
	 */
	 36,  39,  40,  41,  42,  43,  44,  45,  46,  49,  51,  52,  54,  55,  57,  59,
	 65,  34,  73,  32,  33,  84,  85, 237, 310, 333, 212, 222, 227, 228, 229, 231,
	234, 238, 243, 292, 319, 320, 342,  29,  30,  35,  37,  38,  47,  48,  50,  53,
	 70,  56,  58,  60,  61,  62,  63,  64,  66,  67,  68,  69,  71,  72,  31, 208,
	209, 210, 211, 213, 214, 215, 216, 217, 218,  28
    };

    static marpatcl_rtc_sym json_parser_c_l0_rule_definitions [519] = { /* 1038 bytes */
	MARPATCL_RCMD_SETUP (5),
	MARPATCL_RCMD_PRIO  (1), 269, 58,                        /* <colon>                      ::= <@CHR:<:>> */
	MARPATCL_RCMD_PRIO  (1), 270, 44,                        /* <comma>                      ::= <@CHR:<,>> */
	MARPATCL_RCMD_PRIO  (1), 271, 123,                       /* <lbrace>                     ::= <@CHR:<\173>> */
	MARPATCL_RCMD_PRIO  (1), 272, 91,                        /* <lbracket>                   ::= <@CHR:<\133>> */
	MARPATCL_RCMD_PRIO  (1), 273, 305,                       /* <lfalse>                     ::= <@STR:<false>> */
	MARPATCL_RCMD_PRIO  (1), 274, 306,                       /* <lnull>                      ::= <@STR:<null>> */
	MARPATCL_RCMD_PRIO  (3), 275, 317, 315, 314,             /* <lnumber>                    ::= <int> <fraction> <exponent> */
	MARPATCL_RCMD_PRIS  (2)     , 317, 314,                  /*                              |   <int> <exponent> */
	MARPATCL_RCMD_PRIS  (2)     , 317, 315,                  /*                              |   <int> <fraction> */
	MARPATCL_RCMD_PRIS  (1)     , 317,                       /*                              |   <int> */
	MARPATCL_RCMD_QUN   (276), 309,                          /* <lstring>                    ::= <char> * */
	MARPATCL_RCMD_PRIO  (1), 277, 307,                       /* <ltrue>                      ::= <@STR:<true>> */
	MARPATCL_RCMD_PRIO  (1), 278, 34,                        /* <quote>                      ::= <@BYTE:<\42>> */
	MARPATCL_RCMD_PRIO  (1), 279, 125,                       /* <rbrace>                     ::= <@CHR:<\175>> */
	MARPATCL_RCMD_PRIO  (1), 280, 93,                        /* <rbracket>                   ::= <@CHR:<\135>> */
	MARPATCL_RCMD_QUP   (281), 301,                          /* <whitespace>                 ::= <@NCC:<[:space:]>> + */
	MARPATCL_RCMD_PRIO  (1), 282, 323,                       /* <@^CLS:<\42\134[:control:]>> ::= <@BRAN:<\40!>> */
	MARPATCL_RCMD_PRIS  (1)     , 321,                       /*                              |   <@BRAN:<#\133>> */
	MARPATCL_RCMD_PRIS  (1)     , 324,                       /*                              |   <@BRAN:<\135~>> */
	MARPATCL_RCMD_PRIS  (2)     , 194, 295,                  /*                              |   <@BYTE:<\u00c2>> <@BRAN:<\u00a0\u00ac>> */
	MARPATCL_RCMD_PRIS  (2)     , 194, 334,                  /*                              |   <@BYTE:<\u00c2>> <@BRAN:<\u00ae\u00bf>> */
	MARPATCL_RCMD_PRIS  (2)     , 338, 290,                  /*                              |   <@BRAN:<\u00c3\u00d7>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (2)     , 216, 327,                  /*                              |   <@BYTE:<\u00d8>> <@BRAN:<\206\233>> */
	MARPATCL_RCMD_PRIS  (2)     , 216, 293,                  /*                              |   <@BYTE:<\u00d8>> <@BRAN:<\235\u00bf>> */
	MARPATCL_RCMD_PRIS  (2)     , 339, 290,                  /*                              |   <@BRAN:<\u00d9\u00da>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (2)     , 219, 285,                  /*                              |   <@BYTE:<\u00db>> <@BRAN:<\200\234>> */
	MARPATCL_RCMD_PRIS  (2)     , 219, 329,                  /*                              |   <@BYTE:<\u00db>> <@BRAN:<\236\u00bf>> */
	MARPATCL_RCMD_PRIS  (2)     , 220, 284,                  /*                              |   <@BYTE:<\u00dc>> <@BRAN:<\200\216>> */
	MARPATCL_RCMD_PRIS  (2)     , 220, 292,                  /*                              |   <@BYTE:<\u00dc>> <@BRAN:<\220\u00bf>> */
	MARPATCL_RCMD_PRIS  (2)     , 340, 290,                  /*                              |   <@BRAN:<\u00dd\u00df>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 224, 294, 290,             /*                              |   <@BYTE:<\u00e0>> <@BRAN:<\u00a0\u00a2>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 224, 163, 287,             /*                              |   <@BYTE:<\u00e0>> <@BYTE:<\u00a3>> <@BRAN:<\200\u00a1>> */
	MARPATCL_RCMD_PRIS  (3)     , 224, 163, 296,             /*                              |   <@BYTE:<\u00e0>> <@BYTE:<\u00a3>> <@BRAN:<\u00a3\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 224, 297, 290,             /*                              |   <@BYTE:<\u00e0>> <@BRAN:<\u00a4\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 225, 286, 290,             /*                              |   <@BYTE:<\u00e1>> <@BRAN:<\200\237>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 225, 160, 283,             /*                              |   <@BYTE:<\u00e1>> <@BYTE:<\u00a0>> <@BRAN:<\200\215>> */
	MARPATCL_RCMD_PRIS  (3)     , 225, 160, 291,             /*                              |   <@BYTE:<\u00e1>> <@BYTE:<\u00a0>> <@BRAN:<\217\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 225, 331, 290,             /*                              |   <@BYTE:<\u00e1>> <@BRAN:<\u00a1\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 226, 128, 325,             /*                              |   <@BYTE:<\u00e2>> <@BYTE:<\200>> <@BRAN:<\200\212>> */
	MARPATCL_RCMD_PRIS  (3)     , 226, 128, 328,             /*                              |   <@BYTE:<\u00e2>> <@BYTE:<\200>> <@BRAN:<\220\u00a9>> */
	MARPATCL_RCMD_PRIS  (3)     , 226, 128, 335,             /*                              |   <@BYTE:<\u00e2>> <@BYTE:<\200>> <@BRAN:<\u00af\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 226, 129, 286,             /*                              |   <@BYTE:<\u00e2>> <@BYTE:<\201>> <@BRAN:<\200\237>> */
	MARPATCL_RCMD_PRIS  (3)     , 226, 129, 165,             /*                              |   <@BYTE:<\u00e2>> <@BYTE:<\201>> <@BYTE:<\u00a5>> */
	MARPATCL_RCMD_PRIS  (3)     , 226, 129, 336,             /*                              |   <@BYTE:<\u00e2>> <@BYTE:<\201>> <@BRAN:<\u00b0\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 226, 326, 290,             /*                              |   <@BYTE:<\u00e2>> <@BRAN:<\202\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 341, 290, 290,             /*                              |   <@BRAN:<\u00e3\u00ec>> <@BRAN:<\200\u00bf>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 237, 286, 290,             /*                              |   <@BYTE:<\u00ed>> <@BRAN:<\200\237>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 239, 332, 290,             /*                              |   <@BYTE:<\u00ef>> <@BRAN:<\u00a4\u00ba>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 239, 187, 289,             /*                              |   <@BYTE:<\u00ef>> <@BYTE:<\u00bb>> <@BRAN:<\200\u00be>> */
	MARPATCL_RCMD_PRIS  (3)     , 239, 337, 290,             /*                              |   <@BYTE:<\u00ef>> <@BRAN:<\u00bc\u00be>> <@BRAN:<\200\u00bf>> */
	MARPATCL_RCMD_PRIS  (3)     , 239, 191, 288,             /*                              |   <@BYTE:<\u00ef>> <@BYTE:<\u00bf>> <@BRAN:<\200\u00b8>> */
	MARPATCL_RCMD_PRIS  (3)     , 239, 191, 298,             /*                              |   <@BYTE:<\u00ef>> <@BYTE:<\u00bf>> <@BRAN:<\u00bc\u00bf>> */
	MARPATCL_RCMD_PRIO  (1), 283, 325,                       /* <@BRAN:<\200\215>>           ::= <@BRAN:<\200\212>> */
	MARPATCL_RCMD_PRIS  (1)     , 345,                       /*                              |   <BRAN<d139-d141>> */
	MARPATCL_RCMD_PRIO  (1), 284, 283,                       /* <@BRAN:<\200\216>>           ::= <@BRAN:<\200\215>> */
	MARPATCL_RCMD_PRIS  (1)     , 142,                       /*                              |   <@BYTE:<\216>> */
	MARPATCL_RCMD_PRIO  (1), 285, 284,                       /* <@BRAN:<\200\234>>           ::= <@BRAN:<\200\216>> */
	MARPATCL_RCMD_PRIS  (1)     , 346,                       /*                              |   <BRAN<d143-d156>> */
	MARPATCL_RCMD_PRIO  (1), 286, 285,                       /* <@BRAN:<\200\237>>           ::= <@BRAN:<\200\234>> */
	MARPATCL_RCMD_PRIS  (1)     , 347,                       /*                              |   <BRAN<d157-d159>> */
	MARPATCL_RCMD_PRIO  (1), 287, 286,                       /* <@BRAN:<\200\u00a1>>         ::= <@BRAN:<\200\237>> */
	MARPATCL_RCMD_PRIS  (1)     , 348,                       /*                              |   <BRAN<d160-d161>> */
	MARPATCL_RCMD_PRIO  (1), 288, 287,                       /* <@BRAN:<\200\u00b8>>         ::= <@BRAN:<\200\u00a1>> */
	MARPATCL_RCMD_PRIS  (1)     , 349,                       /*                              |   <BRAN<d162-d184>> */
	MARPATCL_RCMD_PRIO  (1), 289, 288,                       /* <@BRAN:<\200\u00be>>         ::= <@BRAN:<\200\u00b8>> */
	MARPATCL_RCMD_PRIS  (1)     , 353,                       /*                              |   <BRAN<d185-d190>> */
	MARPATCL_RCMD_PRIO  (1), 290, 289,                       /* <@BRAN:<\200\u00bf>>         ::= <@BRAN:<\200\u00be>> */
	MARPATCL_RCMD_PRIS  (1)     , 191,                       /*                              |   <@BYTE:<\u00bf>> */
	MARPATCL_RCMD_PRIO  (1), 291, 346,                       /* <@BRAN:<\217\u00bf>>         ::= <BRAN<d143-d156>> */
	MARPATCL_RCMD_PRIS  (1)     , 293,                       /*                              |   <@BRAN:<\235\u00bf>> */
	MARPATCL_RCMD_PRIO  (1), 292, 328,                       /* <@BRAN:<\220\u00bf>>         ::= <@BRAN:<\220\u00a9>> */
	MARPATCL_RCMD_PRIS  (1)     , 351,                       /*                              |   <BRAN<d170-d191>> */
	MARPATCL_RCMD_PRIO  (1), 293, 347,                       /* <@BRAN:<\235\u00bf>>         ::= <BRAN<d157-d159>> */
	MARPATCL_RCMD_PRIS  (1)     , 308,                       /*                              |   <BRAN<d160-d191>> */
	MARPATCL_RCMD_PRIO  (1), 294, 348,                       /* <@BRAN:<\u00a0\u00a2>>       ::= <BRAN<d160-d161>> */
	MARPATCL_RCMD_PRIS  (1)     , 162,                       /*                              |   <BYTE<d162>> */
	MARPATCL_RCMD_PRIO  (1), 295, 294,                       /* <@BRAN:<\u00a0\u00ac>>       ::= <@BRAN:<\u00a0\u00a2>> */
	MARPATCL_RCMD_PRIS  (1)     , 350,                       /*                              |   <BRAN<d163-d172>> */
	MARPATCL_RCMD_PRIO  (1), 296, 350,                       /* <@BRAN:<\u00a3\u00bf>>       ::= <BRAN<d163-d172>> */
	MARPATCL_RCMD_PRIS  (1)     , 352,                       /*                              |   <BRAN<d173-d191>> */
	MARPATCL_RCMD_PRIO  (1), 297, 332,                       /* <@BRAN:<\u00a4\u00bf>>       ::= <@BRAN:<\u00a4\u00ba>> */
	MARPATCL_RCMD_PRIS  (1)     , 354,                       /*                              |   <BRAN<d187-d191>> */
	MARPATCL_RCMD_PRIO  (1), 298, 337,                       /* <@BRAN:<\u00bc\u00bf>>       ::= <@BRAN:<\u00bc\u00be>> */
	MARPATCL_RCMD_PRIS  (1)     , 191,                       /*                              |   <@BYTE:<\u00bf>> */
	MARPATCL_RCMD_PRIO  (1), 299, 8,                         /* <@CLS:<\10\42/bfnrt>>        ::= <@BYTE:<\10>> */
	MARPATCL_RCMD_PRIS  (1)     , 34,                        /*                              |   <@BYTE:<\42>> */
	MARPATCL_RCMD_PRIS  (1)     , 47,                        /*                              |   <@BYTE:</>> */
	MARPATCL_RCMD_PRIS  (1)     , 98,                        /*                              |   <@BYTE:<b>> */
	MARPATCL_RCMD_PRIS  (1)     , 102,                       /*                              |   <@BYTE:<f>> */
	MARPATCL_RCMD_PRIS  (1)     , 110,                       /*                              |   <@BYTE:<n>> */
	MARPATCL_RCMD_PRIS  (1)     , 114,                       /*                              |   <@BYTE:<r>> */
	MARPATCL_RCMD_PRIS  (1)     , 116,                       /*                              |   <@BYTE:<t>> */
	MARPATCL_RCMD_PRIO  (1), 300, 69,                        /* <@CLS:<Ee>>                  ::= <@BYTE:<E>> */
	MARPATCL_RCMD_PRIS  (1)     , 101,                       /*                              |   <@BYTE:<e>> */
	MARPATCL_RCMD_PRIO  (1), 301, 330,                       /* <@NCC:<[:space:]>>           ::= <@BRAN:<\t\r>> */
	MARPATCL_RCMD_PRIS  (1)     , 32,                        /*                              |   <@BYTE:<\40>> */
	MARPATCL_RCMD_PRIS  (2)     , 194, 160,                  /*                              |   <@BYTE:<\u00c2>> <@BYTE:<\u00a0>> */
	MARPATCL_RCMD_PRIS  (3)     , 225, 154, 128,             /*                              |   <@BYTE:<\u00e1>> <@BYTE:<\232>> <@BYTE:<\200>> */
	MARPATCL_RCMD_PRIS  (3)     , 225, 160, 142,             /*                              |   <@BYTE:<\u00e1>> <@BYTE:<\u00a0>> <@BYTE:<\216>> */
	MARPATCL_RCMD_PRIS  (3)     , 226, 128, 325,             /*                              |   <@BYTE:<\u00e2>> <@BYTE:<\200>> <@BRAN:<\200\212>> */
	MARPATCL_RCMD_PRIS  (3)     , 226, 128, 333,             /*                              |   <@BYTE:<\u00e2>> <@BYTE:<\200>> <@BRAN:<\u00a8\u00a9>> */
	MARPATCL_RCMD_PRIS  (3)     , 226, 128, 175,             /*                              |   <@BYTE:<\u00e2>> <@BYTE:<\200>> <@BYTE:<\u00af>> */
	MARPATCL_RCMD_PRIS  (3)     , 226, 129, 159,             /*                              |   <@BYTE:<\u00e2>> <@BYTE:<\201>> <@BYTE:<\237>> */
	MARPATCL_RCMD_PRIS  (3)     , 227, 128, 128,             /*                              |   <@BYTE:<\u00e3>> <@BYTE:<\200>> <@BYTE:<\200>> */
	MARPATCL_RCMD_PRIO  (1), 302, 322,                       /* <@NCC:<[:xdigit:]>>          ::= <@BRAN:<09>> */
	MARPATCL_RCMD_PRIS  (1)     , 342,                       /*                              |   <@BRAN:<AF>> */
	MARPATCL_RCMD_PRIS  (1)     , 343,                       /*                              |   <@BRAN:<af>> */
	MARPATCL_RCMD_PRIO  (2), 303, 92, 98,                    /* <@STR:<\134b>>               ::= <@BYTE:<\134>> <@BYTE:<b>> */
	MARPATCL_RCMD_PRIO  (2), 304, 92, 117,                   /* <@STR:<\134u>>               ::= <@BYTE:<\134>> <@BYTE:<u>> */
	MARPATCL_RCMD_PRIO  (5), 305, 102, 97, 108, 115, 101,    /* <@STR:<false>>               ::= <@BYTE:<f>> <@BYTE:<a>> <@BYTE:<l>> <@BYTE:<s>> <@BYTE:<e>> */
	MARPATCL_RCMD_PRIO  (4), 306, 110, 117, 108, 108,        /* <@STR:<null>>                ::= <@BYTE:<n>> <@BYTE:<u>> <@BYTE:<l>> <@BYTE:<l>> */
	MARPATCL_RCMD_PRIO  (4), 307, 116, 114, 117, 101,        /* <@STR:<true>>                ::= <@BYTE:<t>> <@BYTE:<r>> <@BYTE:<u>> <@BYTE:<e>> */
	MARPATCL_RCMD_PRIO  (1), 308, 295,                       /* <BRAN<d160-d191>>            ::= <@BRAN:<\u00a0\u00ac>> */
	MARPATCL_RCMD_PRIS  (1)     , 352,                       /*                              |   <BRAN<d173-d191>> */
	MARPATCL_RCMD_PRIO  (1), 309, 318,                       /* <char>                       ::= <plain> */
	MARPATCL_RCMD_PRIS  (2)     , 303, 299,                  /*                              |   <@STR:<\134b>> <@CLS:<\10\42/bfnrt>> */
	MARPATCL_RCMD_PRIS  (5)     , 304, 316, 316, 316, 316,   /*                              |   <@STR:<\134u>> <hex> <hex> <hex> <hex> */
	MARPATCL_RCMD_PRIO  (1), 310, 322,                       /* <decimal>                    ::= <@BRAN:<09>> */
	MARPATCL_RCMD_QUP   (311), 310,                          /* <digits>                     ::= <decimal> + */
	MARPATCL_RCMD_QUN   (312), 310,                          /* <digitz>                     ::= <decimal> * */
	MARPATCL_RCMD_PRIO  (1), 313, 300,                       /* <e>                          ::= <@CLS:<Ee>> */
	MARPATCL_RCMD_PRIS  (2)     , 300, 45,                   /*                              |   <@CLS:<Ee>> <@CHR:<->> */
	MARPATCL_RCMD_PRIS  (2)     , 300, 43,                   /*                              |   <@CLS:<Ee>> <@CHR:<+>> */
	MARPATCL_RCMD_PRIO  (2), 314, 313, 311,                  /* <exponent>                   ::= <e> <digits> */
	MARPATCL_RCMD_PRIO  (2), 315, 46, 311,                   /* <fraction>                   ::= <@CHR:<.>> <digits> */
	MARPATCL_RCMD_PRIO  (1), 316, 302,                       /* <hex>                        ::= <@NCC:<[:xdigit:]>> */
	MARPATCL_RCMD_PRIO  (1), 317, 320,                       /* <int>                        ::= <whole> */
	MARPATCL_RCMD_PRIS  (2)     , 45, 320,                   /*                              |   <@CHR:<->> <whole> */
	MARPATCL_RCMD_PRIO  (1), 318, 282,                       /* <plain>                      ::= <@^CLS:<\42\134[:control:]>> */
	MARPATCL_RCMD_PRIO  (2), 319, 344, 312,                  /* <positive>                   ::= <@RAN:<19>> <digitz> */
	MARPATCL_RCMD_PRIO  (1), 320, 48,                        /* <whole>                      ::= <@CHR:<0>> */
	MARPATCL_RCMD_PRIS  (1)     , 319,                       /*                              |   <positive> */
	MARPATCL_RCMD_BRAN  (321), MARPATCL_RCMD_BOXR ( 35, 91), /* <@BRAN:<#\133>>              brange (35 - 91) */
	MARPATCL_RCMD_BRAN  (322), MARPATCL_RCMD_BOXR ( 48, 57), /* <@BRAN:<09>>                 brange (48 - 57) */
	MARPATCL_RCMD_BRAN  (323), MARPATCL_RCMD_BOXR ( 32, 33), /* <@BRAN:<\40!>>               brange (32 - 33) */
	MARPATCL_RCMD_BRAN  (324), MARPATCL_RCMD_BOXR ( 93,126), /* <@BRAN:<\135~>>              brange (93 - 126) */
	MARPATCL_RCMD_BRAN  (325), MARPATCL_RCMD_BOXR (128,138), /* <@BRAN:<\200\212>>           brange (128 - 138) */
	MARPATCL_RCMD_BRAN  (326), MARPATCL_RCMD_BOXR (130,191), /* <@BRAN:<\202\u00bf>>         brange (130 - 191) */
	MARPATCL_RCMD_BRAN  (327), MARPATCL_RCMD_BOXR (134,155), /* <@BRAN:<\206\233>>           brange (134 - 155) */
	MARPATCL_RCMD_BRAN  (328), MARPATCL_RCMD_BOXR (144,169), /* <@BRAN:<\220\u00a9>>         brange (144 - 169) */
	MARPATCL_RCMD_BRAN  (329), MARPATCL_RCMD_BOXR (158,191), /* <@BRAN:<\236\u00bf>>         brange (158 - 191) */
	MARPATCL_RCMD_BRAN  (330), MARPATCL_RCMD_BOXR (  9, 13), /* <@BRAN:<\t\r>>               brange (9 - 13) */
	MARPATCL_RCMD_BRAN  (331), MARPATCL_RCMD_BOXR (161,191), /* <@BRAN:<\u00a1\u00bf>>       brange (161 - 191) */
	MARPATCL_RCMD_BRAN  (332), MARPATCL_RCMD_BOXR (164,186), /* <@BRAN:<\u00a4\u00ba>>       brange (164 - 186) */
	MARPATCL_RCMD_BRAN  (333), MARPATCL_RCMD_BOXR (168,169), /* <@BRAN:<\u00a8\u00a9>>       brange (168 - 169) */
	MARPATCL_RCMD_BRAN  (334), MARPATCL_RCMD_BOXR (174,191), /* <@BRAN:<\u00ae\u00bf>>       brange (174 - 191) */
	MARPATCL_RCMD_BRAN  (335), MARPATCL_RCMD_BOXR (175,191), /* <@BRAN:<\u00af\u00bf>>       brange (175 - 191) */
	MARPATCL_RCMD_BRAN  (336), MARPATCL_RCMD_BOXR (176,191), /* <@BRAN:<\u00b0\u00bf>>       brange (176 - 191) */
	MARPATCL_RCMD_BRAN  (337), MARPATCL_RCMD_BOXR (188,190), /* <@BRAN:<\u00bc\u00be>>       brange (188 - 190) */
	MARPATCL_RCMD_BRAN  (338), MARPATCL_RCMD_BOXR (195,215), /* <@BRAN:<\u00c3\u00d7>>       brange (195 - 215) */
	MARPATCL_RCMD_BRAN  (339), MARPATCL_RCMD_BOXR (217,218), /* <@BRAN:<\u00d9\u00da>>       brange (217 - 218) */
	MARPATCL_RCMD_BRAN  (340), MARPATCL_RCMD_BOXR (221,223), /* <@BRAN:<\u00dd\u00df>>       brange (221 - 223) */
	MARPATCL_RCMD_BRAN  (341), MARPATCL_RCMD_BOXR (227,236), /* <@BRAN:<\u00e3\u00ec>>       brange (227 - 236) */
	MARPATCL_RCMD_BRAN  (342), MARPATCL_RCMD_BOXR ( 65, 70), /* <@BRAN:<AF>>                 brange (65 - 70) */
	MARPATCL_RCMD_BRAN  (343), MARPATCL_RCMD_BOXR ( 97,102), /* <@BRAN:<af>>                 brange (97 - 102) */
	MARPATCL_RCMD_BRAN  (344), MARPATCL_RCMD_BOXR ( 49, 57), /* <@RAN:<19>>                  brange (49 - 57) */
	MARPATCL_RCMD_BRAN  (345), MARPATCL_RCMD_BOXR (139,141), /* <BRAN<d139-d141>>            brange (139 - 141) */
	MARPATCL_RCMD_BRAN  (346), MARPATCL_RCMD_BOXR (143,156), /* <BRAN<d143-d156>>            brange (143 - 156) */
	MARPATCL_RCMD_BRAN  (347), MARPATCL_RCMD_BOXR (157,159), /* <BRAN<d157-d159>>            brange (157 - 159) */
	MARPATCL_RCMD_BRAN  (348), MARPATCL_RCMD_BOXR (160,161), /* <BRAN<d160-d161>>            brange (160 - 161) */
	MARPATCL_RCMD_BRAN  (349), MARPATCL_RCMD_BOXR (162,184), /* <BRAN<d162-d184>>            brange (162 - 184) */
	MARPATCL_RCMD_BRAN  (350), MARPATCL_RCMD_BOXR (163,172), /* <BRAN<d163-d172>>            brange (163 - 172) */
	MARPATCL_RCMD_BRAN  (351), MARPATCL_RCMD_BOXR (170,191), /* <BRAN<d170-d191>>            brange (170 - 191) */
	MARPATCL_RCMD_BRAN  (352), MARPATCL_RCMD_BOXR (173,191), /* <BRAN<d173-d191>>            brange (173 - 191) */
	MARPATCL_RCMD_BRAN  (353), MARPATCL_RCMD_BOXR (185,190), /* <BRAN<d185-d190>>            brange (185 - 190) */
	MARPATCL_RCMD_BRAN  (354), MARPATCL_RCMD_BOXR (187,191), /* <BRAN<d187-d191>>            brange (187 - 191) */
	MARPATCL_RCMD_PRIO  (2), 355, 256, 269,                  /* <@L0:START>                  ::= <@ACS:colon> <colon> */
	MARPATCL_RCMD_PRIS  (2)     , 257, 270,                  /*                              |   <@ACS:comma> <comma> */
	MARPATCL_RCMD_PRIS  (2)     , 258, 271,                  /*                              |   <@ACS:lbrace> <lbrace> */
	MARPATCL_RCMD_PRIS  (2)     , 259, 272,                  /*                              |   <@ACS:lbracket> <lbracket> */
	MARPATCL_RCMD_PRIS  (2)     , 260, 273,                  /*                              |   <@ACS:lfalse> <lfalse> */
	MARPATCL_RCMD_PRIS  (2)     , 261, 274,                  /*                              |   <@ACS:lnull> <lnull> */
	MARPATCL_RCMD_PRIS  (2)     , 262, 275,                  /*                              |   <@ACS:lnumber> <lnumber> */
	MARPATCL_RCMD_PRIS  (2)     , 263, 276,                  /*                              |   <@ACS:lstring> <lstring> */
	MARPATCL_RCMD_PRIS  (2)     , 264, 277,                  /*                              |   <@ACS:ltrue> <ltrue> */
	MARPATCL_RCMD_PRIS  (2)     , 265, 278,                  /*                              |   <@ACS:quote> <quote> */
	MARPATCL_RCMD_PRIS  (2)     , 266, 279,                  /*                              |   <@ACS:rbrace> <rbrace> */
	MARPATCL_RCMD_PRIS  (2)     , 267, 280,                  /*                              |   <@ACS:rbracket> <rbracket> */
	MARPATCL_RCMD_PRIS  (2)     , 268, 281,                  /*                              |   <@ACS:whitespace> <whitespace> */
	MARPATCL_RCMD_DONE  (355)
    };

    static marpatcl_rtc_rules json_parser_c_l0 = { /* 48 */
	/* .sname   */  &json_parser_c_pool,
	/* .symbols */  { 356, json_parser_c_l0_sym_name },
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
	223, 224, 299, 300, 301, 302, 303, 304, 305, 323, 326, 327,

	/* --- (12) --- --- --- Structure
	 */
	338, 314, 318, 317, 205, 233, 232, 330, 311, 333, 237, 310
    };

    static marpatcl_rtc_sym json_parser_c_g1_rule_name [18] = { /* 36 bytes */
	338, 338, 338, 338, 338, 338, 338, 314, 318, 317, 205, 233, 232, 330, 311, 333,
	237, 310
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
	/* .l_symbols  */  356,
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