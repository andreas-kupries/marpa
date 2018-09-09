# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017-present Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                             http://core.tcl.tk/akupries/
##
# (c) 2018 Grammar doctools::parser::sf::c 0 By Andreas Kupries
##
##	`marpa::runtime::c`-derived Parser for grammar "doctools::parser::sf::c".
##	Generated On Sat Sep 08 15:32:30 PDT 2018
##		  By aku@hephaistos
##		 Via remeta
##
#* Space taken: 5997 bytes
##
#* Statistics
#* L0
#* - #Symbols:   345
#* - #Lexemes:   12
#* - #Discards:  0
#* - #Always:    0
#* - #Rule Insn: 131 (+2: setup, start-sym)
#* - #Rules:     472 (>= insn, brange)
#* G1
#* - #Symbols:   34
#* - #Rule Insn: 42 (+2: setup, start-sym)
#* - #Rules:     42 (match insn)

package provide doctools::parser::sf::c 0

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
    ** Shared string pool (708 bytes lengths over 354 entries)
    **                    (708 bytes offsets -----^)
    **                    (2021 bytes character content)
    */

    static marpatcl_rtc_size doctools_parser_sf_c_pool_length [354] = { /* 708 bytes */
	 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
	 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  9,  5,  8,  6,
	 9, 10, 11, 11, 11, 11, 11, 11,  6, 26, 10,  7,  5,  8,  8,  2,
	 2,  2,  2,  2,  2,  2,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,
	 3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,
	 4,  4,  7,  8,  8,  8,  8,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
	 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  2,  2,  4,  2,  1,  1,
	 1,  1,  1, 12,  1,  1,  2,  2, 13,  6,  6,  6, 11, 12,  6,  6,
	13, 14, 14,  1,  1,  2,  7,  7,  7, 12,  2,  1,  1,  1,  1,  7,
	 7,  7,  1,  1,  4,  1,  1,  1,  1,  1,  1, 14, 16, 16, 16, 16,
	16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,  7,  7,  7,
	 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  7,  1,  1,  1,  1,  4,
	 1,  1,  6,  6,  5,  5,  5,  6,  6, 11, 12,  1,  1,  7,  1,  1,
	 6,  6,  6, 11,  5,  5,  5,  6,  6,  5,  4,  1,  1,  1,  1,  6,
	 8, 13, 14, 13,  7,  7,  7,  1,  1,  5,  7,  7,  7,  4,  4,  4,
	 4,  1,  1,  5,  5,  6,  6,  4,  4,  6,  1,  1,  1,  1,  1,  1,
	 1,  1
    };

    static marpatcl_rtc_size doctools_parser_sf_c_pool_offset [354] = { /* 708 bytes */
	   0,    2,    4,    6,    8,   10,   12,   14,   16,   18,   20,   22,   24,   26,   28,   30,
	  32,   34,   36,   38,   40,   42,   44,   46,   48,   50,   52,   54,   56,   66,   72,   81,
	  88,   98,  109,  121,  133,  145,  157,  169,  181,  188,  215,  226,  234,  240,  249,  258,
	 261,  264,  267,  270,  273,  276,  279,  283,  287,  291,  295,  299,  303,  307,  311,  315,
	 319,  323,  327,  331,  335,  339,  343,  347,  351,  355,  359,  363,  367,  371,  375,  379,
	 383,  388,  393,  401,  410,  419,  428,  437,  442,  447,  452,  457,  462,  467,  472,  477,
	 482,  487,  492,  497,  502,  507,  512,  517,  522,  527,  532,  537,  542,  547,  552,  557,
	 562,  567,  572,  577,  582,  587,  592,  597,  602,  607,  612,  617,  622,  627,  632,  637,
	 642,  647,  652,  657,  662,  667,  672,  677,  682,  687,  692,  697,  702,  707,  712,  717,
	 722,  727,  732,  737,  742,  747,  752,  757,  762,  767,  772,  777,  782,  787,  792,  797,
	 802,  807,  812,  817,  822,  827,  832,  837,  842,  847,  852,  857,  862,  867,  872,  877,
	 882,  887,  892,  897,  902,  907,  912,  917,  922,  927,  932,  937,  942,  947,  952,  957,
	 962,  967,  972,  977,  982,  987,  992,  997, 1002, 1007, 1012, 1015, 1018, 1023, 1026, 1028,
	1030, 1032, 1034, 1036, 1049, 1051, 1053, 1056, 1059, 1073, 1080, 1087, 1094, 1106, 1119, 1126,
	1133, 1147, 1162, 1177, 1179, 1181, 1184, 1192, 1200, 1208, 1221, 1224, 1226, 1228, 1230, 1232,
	1240, 1248, 1256, 1258, 1260, 1265, 1267, 1269, 1271, 1273, 1275, 1277, 1292, 1309, 1326, 1343,
	1360, 1377, 1394, 1411, 1428, 1445, 1462, 1479, 1496, 1513, 1530, 1547, 1564, 1581, 1589, 1597,
	1605, 1607, 1609, 1611, 1613, 1615, 1617, 1619, 1621, 1623, 1625, 1633, 1635, 1637, 1639, 1641,
	1646, 1648, 1650, 1657, 1664, 1670, 1676, 1682, 1689, 1696, 1708, 1721, 1723, 1725, 1733, 1735,
	1737, 1744, 1751, 1758, 1770, 1776, 1782, 1788, 1795, 1802, 1808, 1813, 1815, 1817, 1819, 1821,
	1828, 1837, 1851, 1866, 1880, 1888, 1896, 1904, 1906, 1908, 1914, 1922, 1930, 1938, 1943, 1948,
	1953, 1958, 1960, 1962, 1968, 1974, 1981, 1988, 1993, 1998, 2005, 2007, 2009, 2011, 2013, 2015,
	2017, 2019
    };

    static marpatcl_rtc_string doctools_parser_sf_c_pool = { /* 24 + 2021 bytes */
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
	/*  29 */ "[#-Z]\0"
	/*  30 */ "[\\1-\\10]\0"
	/*  31 */ "[\\1-z]\0"
	/*  32 */ "[\\16-\\37]\0"
	/*  33 */ "[\\173\\175]\0"
	/*  34 */ "[\\200-\\277]\0"
	/*  35 */ "[\\240-\\257]\0"
	/*  36 */ "[\\240-\\277]\0"
	/*  37 */ "[\\260-\\277]\0"
	/*  38 */ "[\\302-\\337]\0"
	/*  39 */ "[\\341-\\357]\0"
	/*  40 */ "[\\n\\r]\0"
	/*  41 */ "[\\t-\\r\\40\\42\\133-\\135\\173]\0"
	/*  42 */ "[\\t-\\r\\40]\0"
	/*  43 */ "[\\t-\\r]\0"
	/*  44 */ "[^-z]\0"
	/*  45 */ "[|-\\177]\0"
	/*  46 */ "[~-\\177]\0"
	/*  47 */ "\\1\0"
	/*  48 */ "\\2\0"
	/*  49 */ "\\3\0"
	/*  50 */ "\\4\0"
	/*  51 */ "\\5\0"
	/*  52 */ "\\6\0"
	/*  53 */ "\\7\0"
	/*  54 */ "\\10\0"
	/*  55 */ "\\13\0"
	/*  56 */ "\\14\0"
	/*  57 */ "\\16\0"
	/*  58 */ "\\17\0"
	/*  59 */ "\\20\0"
	/*  60 */ "\\21\0"
	/*  61 */ "\\22\0"
	/*  62 */ "\\23\0"
	/*  63 */ "\\24\0"
	/*  64 */ "\\25\0"
	/*  65 */ "\\26\0"
	/*  66 */ "\\27\0"
	/*  67 */ "\\30\0"
	/*  68 */ "\\31\0"
	/*  69 */ "\\32\0"
	/*  70 */ "\\33\0"
	/*  71 */ "\\34\0"
	/*  72 */ "\\35\0"
	/*  73 */ "\\36\0"
	/*  74 */ "\\37\0"
	/*  75 */ "\\40\0"
	/*  76 */ "\\42\0"
	/*  77 */ "\\50\0"
	/*  78 */ "\\51\0"
	/*  79 */ "\\73\0"
	/*  80 */ "\\133\0"
	/*  81 */ "\\134\0"
	/*  82 */ "\\134\\42\0"
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
	/* 222 */ "Bracel\0"
	/* 223 */ "bracel\0"
	/* 224 */ "BRAN<d9-d122>\0"
	/* 225 */ "BRAN<d14-d122>\0"
	/* 226 */ "BRAN<d32-d122>\0"
	/* 227 */ "C\0"
	/* 228 */ "c\0"
	/* 229 */ "CL\0"
	/* 230 */ "COMMAND\0"
	/* 231 */ "COMMENT\0"
	/* 232 */ "comment\0"
	/* 233 */ "CONTINUATION\0"
	/* 234 */ "CR\0"
	/* 235 */ "D\0"
	/* 236 */ "d\0"
	/* 237 */ "E\0"
	/* 238 */ "e\0"
	/* 239 */ "ESCAPED\0"
	/* 240 */ "Escaped\0"
	/* 241 */ "escaped\0"
	/* 242 */ "F\0"
	/* 243 */ "f\0"
	/* 244 */ "form\0"
	/* 245 */ "G\0"
	/* 246 */ "g\0"
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
	/* 270 */ "Include\0"
	/* 271 */ "include\0"
	/* 272 */ "J\0"
	/* 273 */ "j\0"
	/* 274 */ "K\0"
	/* 275 */ "k\0"
	/* 276 */ "L\0"
	/* 277 */ "l\0"
	/* 278 */ "M\0"
	/* 279 */ "m\0"
	/* 280 */ "N\0"
	/* 281 */ "n\0"
	/* 282 */ "NEWLINE\0"
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
	/* 307 */ "SIMPLE_CHAR\0"
	/* 308 */ "SPACE\0"
	/* 309 */ "Space\0"
	/* 310 */ "space\0"
	/* 311 */ "SPACE0\0"
	/* 312 */ "SPACE1\0"
	/* 313 */ "Start\0"
	/* 314 */ "Stop\0"
	/* 315 */ "T\0"
	/* 316 */ "t\0"
	/* 317 */ "U\0"
	/* 318 */ "u\0"
	/* 319 */ "unquot\0"
	/* 320 */ "UNQUOTED\0"
	/* 321 */ "UNQUOTED_ELEM\0"
	/* 322 */ "UNQUOTED_ELEMS\0"
	/* 323 */ "UNQUOTED_LEAD\0"
	/* 324 */ "uq_elem\0"
	/* 325 */ "uq_lead\0"
	/* 326 */ "uq_list\0"
	/* 327 */ "V\0"
	/* 328 */ "v\0"
	/* 329 */ "value\0"
	/* 330 */ "var_def\0"
	/* 331 */ "var_ref\0"
	/* 332 */ "varname\0"
	/* 333 */ "vars\0"
	/* 334 */ "VSET\0"
	/* 335 */ "Vset\0"
	/* 336 */ "vset\0"
	/* 337 */ "W\0"
	/* 338 */ "w\0"
	/* 339 */ "WHITE\0"
	/* 340 */ "White\0"
	/* 341 */ "WHITE0\0"
	/* 342 */ "WHITE1\0"
	/* 343 */ "WORD\0"
	/* 344 */ "Word\0"
	/* 345 */ "WORDS1\0"
	/* 346 */ "X\0"
	/* 347 */ "x\0"
	/* 348 */ "Y\0"
	/* 349 */ "y\0"
	/* 350 */ "Z\0"
	/* 351 */ "z\0"
	/* 352 */ "|\0"
	/* 353 */ "~\0"
    };

    /*
    ** Map lexeme strings to parser symbol id (`match alternate` support).
    */

    static marpatcl_rtc_sym_lmap doctools_parser_sf_c_lmap [12] = {
	{ 218, 0  }, // Braced
	{ 222, 1  }, // Bracel
	{ 240, 2  }, // Escaped
	{ 270, 3  }, // Include
	{ 293, 4  }, // Quote
	{ 305, 5  }, // Simple
	{ 309, 6  }, // Space
	{ 313, 7  }, // Start
	{ 314, 8  }, // Stop
	{ 335, 9  }, // Vset
	{ 340, 10 }, // White
	{ 344, 11 }, // Word
    };

    /*
    ** L0 structures
    */

    static marpatcl_rtc_sym doctools_parser_sf_c_l0_sym_name [345] = { /* 690 bytes */
	/* --- (256) --- --- --- Characters
	 */
	251,  47,  48,  49,  50,  51,  52,  53,  54, 205, 202,  55,  56, 203,  57,  58,
	 59,  60,  61,  62,  63,  64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,
	 75,   0,  76,   1,   2,   3,   4,   5,  77,  78,   6,   7,   8,   9,  10,  11,
	 12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  79,  23,  24,  25,  26,
	 27, 209, 212, 227, 235, 237, 242, 245, 247, 249, 272, 274, 276, 278, 280, 283,
	285, 288, 299, 302, 315, 317, 327, 337, 346, 348, 350,  80,  81,  87, 206, 207,
	208, 210, 213, 228, 236, 238, 243, 246, 248, 250, 273, 275, 277, 279, 281, 284,
	286, 289, 300, 303, 316, 318, 328, 338, 347, 349, 351,  88, 352,  89, 353,  90,
	 91,  92,  93,  94,  95,  96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106,
	107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122,
	123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138,
	139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154,
	155, 252, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169,
	170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185,
	186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201,
	253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268,

	/* --- (12) --- --- --- ACS: Lexeme
	 */
	218, 222, 240, 270, 293, 305, 309, 313, 314, 335, 340, 344,

	/* --- (12) --- --- --- Lexeme
	 */
	218, 222, 240, 270, 293, 305, 309, 313, 314, 335, 340, 344,

	/* --- (65) --- --- --- Internal
	 */
	 33,  41,  31,  36,  40,  42,  82,  83,  84,  85,  86, 204, 232, 271, 336, 211,
	214, 215, 216, 217, 220, 221, 224, 225, 229, 230, 231, 233, 234, 239, 269, 282,
	292, 295, 297, 298, 304, 307, 308, 311, 312, 320, 321, 322, 323, 334, 339, 341,
	342, 343, 345,  29,  30,  32,  34,  35,  37,  38,  39,  43,  44,  45,  46, 226,
	 28
    };

    static marpatcl_rtc_sym doctools_parser_sf_c_l0_rule_definitions [393] = { /* 786 bytes */
	MARPATCL_RCMD_SETUP (7),
	MARPATCL_RCMD_PRIO  (1), 268, 299,                               /* <Braced>                           ::= <BRACED> */
	MARPATCL_RCMD_PRIO  (1), 269, 296,                               /* <Bracel>                           ::= <BL> */
	MARPATCL_RCMD_PRIO  (1), 270, 309,                               /* <Escaped>                          ::= <ESCAPED> */
	MARPATCL_RCMD_PRIO  (1), 271, 310,                               /* <Include>                          ::= <INCLUDE> */
	MARPATCL_RCMD_PRIO  (1), 272, 312,                               /* <Quote>                            ::= <QUOTE> */
	MARPATCL_RCMD_PRIO  (1), 273, 316,                               /* <Simple>                           ::= <SIMPLE> */
	MARPATCL_RCMD_PRIO  (1), 274, 320,                               /* <Space>                            ::= <SPACE1> */
	MARPATCL_RCMD_PRIO  (1), 275, 304,                               /* <Start>                            ::= <CL> */
	MARPATCL_RCMD_PRIO  (1), 276, 308,                               /* <Stop>                             ::= <CR> */
	MARPATCL_RCMD_PRIO  (1), 277, 325,                               /* <Vset>                             ::= <VSET> */
	MARPATCL_RCMD_PRIO  (1), 278, 328,                               /* <White>                            ::= <WHITE1> */
	MARPATCL_RCMD_PRIO  (1), 279, 329,                               /* <Word>                             ::= <WORD> */
	MARPATCL_RCMD_PRIO  (2), 280, 192, 128,                          /* <@^CLS:<\173\175>>                 ::= <@BYTE:<\300>> <@BYTE:<\200>> */
	MARPATCL_RCMD_PRIS  (1)     , 282,                               /*                                    |   <@BRAN:<\1z>> */
	MARPATCL_RCMD_PRIS  (1)     , 124,                               /*                                    |   <@BYTE:<|>> */
	MARPATCL_RCMD_PRIS  (1)     , 342,                               /*                                    |   <@BRAN:<~\177>> */
	MARPATCL_RCMD_PRIS  (2)     , 337, 334,                          /*                                    |   <@BRAN:<\302\337>> <@BRAN:<\200\277>> */
	MARPATCL_RCMD_PRIS  (3)     , 224, 283, 334,                     /*                                    |   <@BYTE:<\340>> <@BRAN:<\240\277>> <@BRAN:<\200\277>> */
	MARPATCL_RCMD_PRIS  (3)     , 338, 334, 334,                     /*                                    |   <@BRAN:<\341\357>> <@BRAN:<\200\277>> <@BRAN:<\200\277>> */
	MARPATCL_RCMD_PRIS  (6)     , 237, 335, 334, 237, 336, 334,      /*                                    |   <@BYTE:<\355>> <@BRAN:<\240\257>> <@BRAN:<\200\277>> <@BYTE:<\355>> <@BRAN:<\260\277>> <@BRAN:<\200\277>> */
	MARPATCL_RCMD_PRIO  (2), 281, 192, 128,                          /* <@^CLS:<\t-\r\40\42\133-\135\173>> ::= <@BYTE:<\300>> <@BYTE:<\200>> */
	MARPATCL_RCMD_PRIS  (1)     , 332,                               /*                                    |   <@BRAN:<\1\10>> */
	MARPATCL_RCMD_PRIS  (1)     , 333,                               /*                                    |   <@BRAN:<\16\37>> */
	MARPATCL_RCMD_PRIS  (1)     , 33,                                /*                                    |   <@BYTE:<!>> */
	MARPATCL_RCMD_PRIS  (1)     , 331,                               /*                                    |   <@BRAN:<#Z>> */
	MARPATCL_RCMD_PRIS  (1)     , 340,                               /*                                    |   <@BRAN:<^z>> */
	MARPATCL_RCMD_PRIS  (1)     , 341,                               /*                                    |   <@BRAN:<|\177>> */
	MARPATCL_RCMD_PRIS  (2)     , 337, 334,                          /*                                    |   <@BRAN:<\302\337>> <@BRAN:<\200\277>> */
	MARPATCL_RCMD_PRIS  (3)     , 224, 283, 334,                     /*                                    |   <@BYTE:<\340>> <@BRAN:<\240\277>> <@BRAN:<\200\277>> */
	MARPATCL_RCMD_PRIS  (3)     , 338, 334, 334,                     /*                                    |   <@BRAN:<\341\357>> <@BRAN:<\200\277>> <@BRAN:<\200\277>> */
	MARPATCL_RCMD_PRIS  (6)     , 237, 335, 334, 237, 336, 334,      /*                                    |   <@BYTE:<\355>> <@BRAN:<\240\257>> <@BRAN:<\200\277>> <@BYTE:<\355>> <@BRAN:<\260\277>> <@BRAN:<\200\277>> */
	MARPATCL_RCMD_PRIO  (1), 282, 332,                               /* <@BRAN:<\1z>>                      ::= <@BRAN:<\1\10>> */
	MARPATCL_RCMD_PRIS  (1)     , 302,                               /*                                    |   <BRAN<d9-d122>> */
	MARPATCL_RCMD_PRIO  (1), 283, 335,                               /* <@BRAN:<\240\277>>                 ::= <@BRAN:<\240\257>> */
	MARPATCL_RCMD_PRIS  (1)     , 336,                               /*                                    |   <@BRAN:<\260\277>> */
	MARPATCL_RCMD_PRIO  (1), 284, 10,                                /* <@CLS:<\n\r>>                      ::= <@BYTE:<\n>> */
	MARPATCL_RCMD_PRIS  (1)     , 13,                                /*                                    |   <@BYTE:<\r>> */
	MARPATCL_RCMD_PRIO  (1), 285, 339,                               /* <@CLS:<\t-\r\40>>                  ::= <@BRAN:<\t\r>> */
	MARPATCL_RCMD_PRIS  (1)     , 32,                                /*                                    |   <@BYTE:<\40>> */
	MARPATCL_RCMD_PRIO  (2), 286, 92, 34,                            /* <@STR:<\134\42>>                   ::= <@BYTE:<\134>> <@BYTE:<\42>> */
	MARPATCL_RCMD_PRIO  (2), 287, 92, 91,                            /* <@STR:<\134\133>>                  ::= <@BYTE:<\134>> <@BYTE:<\133>> */
	MARPATCL_RCMD_PRIO  (2), 288, 92, 93,                            /* <@STR:<\134\135>>                  ::= <@BYTE:<\134>> <@BYTE:<\135>> */
	MARPATCL_RCMD_PRIO  (2), 289, 92, 123,                           /* <@STR:<\134\173>>                  ::= <@BYTE:<\134>> <@BYTE:<\173>> */
	MARPATCL_RCMD_PRIO  (2), 290, 92, 125,                           /* <@STR:<\134\175>>                  ::= <@BYTE:<\134>> <@BYTE:<\175>> */
	MARPATCL_RCMD_PRIO  (2), 291, 13, 10,                            /* <@STR:<\r\n>>                      ::= <@BYTE:<\r>> <@BYTE:<\n>> */
	MARPATCL_RCMD_PRIO  (7), 292, 99, 111, 109, 109, 101, 110, 116,  /* <@STR:<comment>>                   ::= <@BYTE:<c>> <@BYTE:<o>> <@BYTE:<m>> <@BYTE:<m>> <@BYTE:<e>> <@BYTE:<n>> <@BYTE:<t>> */
	MARPATCL_RCMD_PRIO  (7), 293, 105, 110, 99, 108, 117, 100, 101,  /* <@STR:<include>>                   ::= <@BYTE:<i>> <@BYTE:<n>> <@BYTE:<c>> <@BYTE:<l>> <@BYTE:<u>> <@BYTE:<d>> <@BYTE:<e>> */
	MARPATCL_RCMD_PRIO  (4), 294, 118, 115, 101, 116,                /* <@STR:<vset>>                      ::= <@BYTE:<v>> <@BYTE:<s>> <@BYTE:<e>> <@BYTE:<t>> */
	MARPATCL_RCMD_PRIO  (1), 295, 280,                               /* <ANY_UNBRACED>                     ::= <@^CLS:<\173\175>> */
	MARPATCL_RCMD_PRIO  (1), 296, 123,                               /* <BL>                               ::= <@BYTE:<\173>> */
	MARPATCL_RCMD_PRIO  (1), 297, 125,                               /* <BR>                               ::= <@BYTE:<\175>> */
	MARPATCL_RCMD_PRIO  (1), 298, 289,                               /* <BRACE_ESCAPED>                    ::= <@STR:<\134\173>> */
	MARPATCL_RCMD_PRIS  (1)     , 290,                               /*                                    |   <@STR:<\134\175>> */
	MARPATCL_RCMD_PRIO  (3), 299, 296, 301, 297,                     /* <BRACED>                           ::= <BL> <BRACED_ELEMS> <BR> */
	MARPATCL_RCMD_PRIO  (1), 300, 295,                               /* <BRACED_ELEM>                      ::= <ANY_UNBRACED> */
	MARPATCL_RCMD_PRIS  (1)     , 299,                               /*                                    |   <BRACED> */
	MARPATCL_RCMD_PRIS  (1)     , 298,                               /*                                    |   <BRACE_ESCAPED> */
	MARPATCL_RCMD_QUN   (301), 300,                                  /* <BRACED_ELEMS>                     ::= <BRACED_ELEM> * */
	MARPATCL_RCMD_PRIO  (1), 302, 339,                               /* <BRAN<d9-d122>>                    ::= <@BRAN:<\t\r>> */
	MARPATCL_RCMD_PRIS  (1)     , 303,                               /*                                    |   <BRAN<d14-d122>> */
	MARPATCL_RCMD_PRIO  (1), 303, 333,                               /* <BRAN<d14-d122>>                   ::= <@BRAN:<\16\37>> */
	MARPATCL_RCMD_PRIS  (1)     , 343,                               /*                                    |   <BRAN<d32-d122>> */
	MARPATCL_RCMD_PRIO  (1), 304, 91,                                /* <CL>                               ::= <@BYTE:<\133>> */
	MARPATCL_RCMD_PRIO  (5), 305, 304, 327, 330, 327, 308,           /* <COMMAND>                          ::= <CL> <WHITE0> <WORDS1> <WHITE0> <CR> */
	MARPATCL_RCMD_PRIO  (7), 306, 304, 327, 292, 328, 329, 327, 308, /* <COMMENT>                          ::= <CL> <WHITE0> <@STR:<comment>> <WHITE1> <WORD> <WHITE0> <CR> */
	MARPATCL_RCMD_PRIO  (4), 307, 319, 92, 311, 319,                 /* <CONTINUATION>                     ::= <SPACE0> <@BYTE:<\134>> <NEWLINE> <SPACE0> */
	MARPATCL_RCMD_PRIO  (1), 308, 93,                                /* <CR>                               ::= <@BYTE:<\135>> */
	MARPATCL_RCMD_PRIO  (1), 309, 92,                                /* <ESCAPED>                          ::= <@BYTE:<\134>> */
	MARPATCL_RCMD_PRIS  (1)     , 287,                               /*                                    |   <@STR:<\134\133>> */
	MARPATCL_RCMD_PRIS  (1)     , 286,                               /*                                    |   <@STR:<\134\42>> */
	MARPATCL_RCMD_PRIS  (1)     , 288,                               /*                                    |   <@STR:<\134\135>> */
	MARPATCL_RCMD_PRIO  (1), 310, 293,                               /* <INCLUDE>                          ::= <@STR:<include>> */
	MARPATCL_RCMD_PRIO  (1), 311, 284,                               /* <NEWLINE>                          ::= <@CLS:<\n\r>> */
	MARPATCL_RCMD_PRIS  (1)     , 291,                               /*                                    |   <@STR:<\r\n>> */
	MARPATCL_RCMD_PRIO  (1), 312, 34,                                /* <QUOTE>                            ::= <@BYTE:<\42>> */
	MARPATCL_RCMD_PRIO  (3), 313, 312, 315, 312,                     /* <QUOTED>                           ::= <QUOTE> <QUOTED_ELEMS> <QUOTE> */
	MARPATCL_RCMD_PRIO  (1), 314, 317,                               /* <QUOTED_ELEM>                      ::= <SIMPLE_CHAR> */
	MARPATCL_RCMD_PRIS  (1)     , 318,                               /*                                    |   <SPACE> */
	MARPATCL_RCMD_PRIS  (1)     , 305,                               /*                                    |   <COMMAND> */
	MARPATCL_RCMD_PRIS  (1)     , 309,                               /*                                    |   <ESCAPED> */
	MARPATCL_RCMD_PRIS  (1)     , 296,                               /*                                    |   <BL> */
	MARPATCL_RCMD_QUN   (315), 314,                                  /* <QUOTED_ELEMS>                     ::= <QUOTED_ELEM> * */
	MARPATCL_RCMD_QUP   (316), 317,                                  /* <SIMPLE>                           ::= <SIMPLE_CHAR> + */
	MARPATCL_RCMD_PRIO  (1), 317, 281,                               /* <SIMPLE_CHAR>                      ::= <@^CLS:<\t-\r\40\42\133-\135\173>> */
	MARPATCL_RCMD_PRIO  (1), 318, 285,                               /* <SPACE>                            ::= <@CLS:<\t-\r\40>> */
	MARPATCL_RCMD_QUN   (319), 318,                                  /* <SPACE0>                           ::= <SPACE> * */
	MARPATCL_RCMD_QUP   (320), 318,                                  /* <SPACE1>                           ::= <SPACE> + */
	MARPATCL_RCMD_PRIO  (1), 321, 324,                               /* <UNQUOTED>                         ::= <UNQUOTED_LEAD> */
	MARPATCL_RCMD_PRIS  (2)     , 324, 323,                          /*                                    |   <UNQUOTED_LEAD> <UNQUOTED_ELEMS> */
	MARPATCL_RCMD_PRIO  (1), 322, 324,                               /* <UNQUOTED_ELEM>                    ::= <UNQUOTED_LEAD> */
	MARPATCL_RCMD_PRIS  (1)     , 312,                               /*                                    |   <QUOTE> */
	MARPATCL_RCMD_PRIS  (1)     , 296,                               /*                                    |   <BL> */
	MARPATCL_RCMD_QUP   (323), 322,                                  /* <UNQUOTED_ELEMS>                   ::= <UNQUOTED_ELEM> + */
	MARPATCL_RCMD_PRIO  (1), 324, 317,                               /* <UNQUOTED_LEAD>                    ::= <SIMPLE_CHAR> */
	MARPATCL_RCMD_PRIS  (1)     , 305,                               /*                                    |   <COMMAND> */
	MARPATCL_RCMD_PRIS  (1)     , 309,                               /*                                    |   <ESCAPED> */
	MARPATCL_RCMD_PRIO  (1), 325, 294,                               /* <VSET>                             ::= <@STR:<vset>> */
	MARPATCL_RCMD_PRIO  (1), 326, 318,                               /* <WHITE>                            ::= <SPACE> */
	MARPATCL_RCMD_PRIS  (1)     , 306,                               /*                                    |   <COMMENT> */
	MARPATCL_RCMD_PRIS  (1)     , 307,                               /*                                    |   <CONTINUATION> */
	MARPATCL_RCMD_QUN   (327), 326,                                  /* <WHITE0>                           ::= <WHITE> * */
	MARPATCL_RCMD_QUP   (328), 326,                                  /* <WHITE1>                           ::= <WHITE> + */
	MARPATCL_RCMD_PRIO  (1), 329, 299,                               /* <WORD>                             ::= <BRACED> */
	MARPATCL_RCMD_PRIS  (1)     , 313,                               /*                                    |   <QUOTED> */
	MARPATCL_RCMD_PRIS  (1)     , 321,                               /*                                    |   <UNQUOTED> */
	MARPATCL_RCMD_QUPS  (330), 329, MARPATCL_RCMD_SEP (328),         /* <WORDS1>                           ::= <WORD> + (<WHITE1>) */
	MARPATCL_RCMD_BRAN  (331), MARPATCL_RCMD_BOXR ( 35, 90),         /* <@BRAN:<#Z>>                       brange (35 - 90) */
	MARPATCL_RCMD_BRAN  (332), MARPATCL_RCMD_BOXR (  1,  8),         /* <@BRAN:<\1\10>>                    brange (1 - 8) */
	MARPATCL_RCMD_BRAN  (333), MARPATCL_RCMD_BOXR ( 14, 31),         /* <@BRAN:<\16\37>>                   brange (14 - 31) */
	MARPATCL_RCMD_BRAN  (334), MARPATCL_RCMD_BOXR (128,191),         /* <@BRAN:<\200\277>>                 brange (128 - 191) */
	MARPATCL_RCMD_BRAN  (335), MARPATCL_RCMD_BOXR (160,175),         /* <@BRAN:<\240\257>>                 brange (160 - 175) */
	MARPATCL_RCMD_BRAN  (336), MARPATCL_RCMD_BOXR (176,191),         /* <@BRAN:<\260\277>>                 brange (176 - 191) */
	MARPATCL_RCMD_BRAN  (337), MARPATCL_RCMD_BOXR (194,223),         /* <@BRAN:<\302\337>>                 brange (194 - 223) */
	MARPATCL_RCMD_BRAN  (338), MARPATCL_RCMD_BOXR (225,239),         /* <@BRAN:<\341\357>>                 brange (225 - 239) */
	MARPATCL_RCMD_BRAN  (339), MARPATCL_RCMD_BOXR (  9, 13),         /* <@BRAN:<\t\r>>                     brange (9 - 13) */
	MARPATCL_RCMD_BRAN  (340), MARPATCL_RCMD_BOXR ( 94,122),         /* <@BRAN:<^z>>                       brange (94 - 122) */
	MARPATCL_RCMD_BRAN  (341), MARPATCL_RCMD_BOXR (124,127),         /* <@BRAN:<|\177>>                    brange (124 - 127) */
	MARPATCL_RCMD_BRAN  (342), MARPATCL_RCMD_BOXR (126,127),         /* <@BRAN:<~\177>>                    brange (126 - 127) */
	MARPATCL_RCMD_BRAN  (343), MARPATCL_RCMD_BOXR ( 32,122),         /* <BRAN<d32-d122>>                   brange (32 - 122) */
	MARPATCL_RCMD_PRIO  (2), 344, 256, 268,                          /* <@L0:START>                        ::= <@ACS:Braced> <Braced> */
	MARPATCL_RCMD_PRIS  (2)     , 257, 269,                          /*                                    |   <@ACS:Bracel> <Bracel> */
	MARPATCL_RCMD_PRIS  (2)     , 258, 270,                          /*                                    |   <@ACS:Escaped> <Escaped> */
	MARPATCL_RCMD_PRIS  (2)     , 259, 271,                          /*                                    |   <@ACS:Include> <Include> */
	MARPATCL_RCMD_PRIS  (2)     , 260, 272,                          /*                                    |   <@ACS:Quote> <Quote> */
	MARPATCL_RCMD_PRIS  (2)     , 261, 273,                          /*                                    |   <@ACS:Simple> <Simple> */
	MARPATCL_RCMD_PRIS  (2)     , 262, 274,                          /*                                    |   <@ACS:Space> <Space> */
	MARPATCL_RCMD_PRIS  (2)     , 263, 275,                          /*                                    |   <@ACS:Start> <Start> */
	MARPATCL_RCMD_PRIS  (2)     , 264, 276,                          /*                                    |   <@ACS:Stop> <Stop> */
	MARPATCL_RCMD_PRIS  (2)     , 265, 277,                          /*                                    |   <@ACS:Vset> <Vset> */
	MARPATCL_RCMD_PRIS  (2)     , 266, 278,                          /*                                    |   <@ACS:White> <White> */
	MARPATCL_RCMD_PRIS  (2)     , 267, 279,                          /*                                    |   <@ACS:Word> <Word> */
	MARPATCL_RCMD_DONE  (344)
    };

    static marpatcl_rtc_rules doctools_parser_sf_c_l0 = { /* 48 */
	/* .sname   */  &doctools_parser_sf_c_pool,
	/* .symbols */  { 345, doctools_parser_sf_c_l0_sym_name },
	/* .lmap    */  { 12, doctools_parser_sf_c_lmap },
	/* .rules   */  { 0, NULL },
	/* .lhs     */  { 0, NULL },
	/* .rcode   */  doctools_parser_sf_c_l0_rule_definitions,
	/* .events  */  0,
	/* .trigger */  0
    };

    static marpatcl_rtc_sym doctools_parser_sf_c_l0semantics [3] = { /* 6 bytes */
	 MARPATCL_SV_START, MARPATCL_SV_LENGTH,  MARPATCL_SV_VALUE
    };

    /*
    ** G1 structures
    */

    static marpatcl_rtc_sym doctools_parser_sf_c_g1_sym_name [34] = { /* 68 bytes */
	/* --- (12) --- --- --- Terminals
	 */
	218, 222, 240, 270, 293, 305, 309, 313, 314, 335, 340, 344,

	/* --- (22) --- --- --- Structure
	 */
	244, 333, 330, 331, 271, 332, 287, 329, 301, 296, 291, 290, 319, 325, 326, 324,
	219, 223, 306, 294, 310, 241
    };

    static marpatcl_rtc_sym doctools_parser_sf_c_g1_rule_name [42] = { /* 84 bytes */
	244, 244, 333, 333, 330, 330, 330, 330, 331, 331, 331, 331, 271, 271, 271, 271,
	332, 287, 329, 301, 301, 301, 296, 291, 290, 290, 290, 290, 319, 325, 325, 325,
	326, 324, 324, 324, 219, 223, 306, 294, 310, 241
    };

    static marpatcl_rtc_sym doctools_parser_sf_c_g1_rule_lhs [42] = { /* 84 bytes */
	12, 12, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16,
	17, 18, 19, 20, 20, 20, 21, 22, 23, 23, 23, 23, 24, 25, 25, 25,
	26, 27, 27, 27, 28, 29, 30, 31, 32, 33
    };

    static marpatcl_rtc_sym doctools_parser_sf_c_g1_rule_definitions [177] = { /* 354 bytes */
	MARPATCL_RCMD_SETUP (9),
	MARPATCL_RCMD_PRIO  (1), 12, 13,                              /* <form>    ::= <vars> */
	MARPATCL_RCMD_PRIS  (1)    , 16,                              /*           |   <include> */
	MARPATCL_RCMD_PRIO  (1), 13, 14,                              /* <vars>    ::= <var_def> */
	MARPATCL_RCMD_PRIS  (1)    , 15,                              /*           |   <var_ref> */
	MARPATCL_RCMD_PRIO  (9), 14, 7, 10, 9, 10, 17, 10, 19, 10, 8, /* <var_def> ::= <Start> <White> <Vset> <White> <varname> <White> <value> <White> <Stop> */
	MARPATCL_RCMD_PRIS  (8)    , 7, 10, 9, 10, 17, 10, 19, 8,     /*           |   <Start> <White> <Vset> <White> <varname> <White> <value> <Stop> */
	MARPATCL_RCMD_PRIS  (8)    , 7, 9, 10, 17, 10, 19, 10, 8,     /*           |   <Start> <Vset> <White> <varname> <White> <value> <White> <Stop> */
	MARPATCL_RCMD_PRIS  (7)    , 7, 9, 10, 17, 10, 19, 8,         /*           |   <Start> <Vset> <White> <varname> <White> <value> <Stop> */
	MARPATCL_RCMD_PRIO  (7), 15, 7, 10, 9, 10, 17, 10, 8,         /* <var_ref> ::= <Start> <White> <Vset> <White> <varname> <White> <Stop> */
	MARPATCL_RCMD_PRIS  (6)    , 7, 10, 9, 10, 17, 8,             /*           |   <Start> <White> <Vset> <White> <varname> <Stop> */
	MARPATCL_RCMD_PRIS  (6)    , 7, 9, 10, 17, 10, 8,             /*           |   <Start> <Vset> <White> <varname> <White> <Stop> */
	MARPATCL_RCMD_PRIS  (5)    , 7, 9, 10, 17, 8,                 /*           |   <Start> <Vset> <White> <varname> <Stop> */
	MARPATCL_RCMD_PRIO  (7), 16, 7, 10, 3, 10, 18, 10, 8,         /* <include> ::= <Start> <White> <Include> <White> <path> <White> <Stop> */
	MARPATCL_RCMD_PRIS  (6)    , 7, 10, 3, 10, 18, 8,             /*           |   <Start> <White> <Include> <White> <path> <Stop> */
	MARPATCL_RCMD_PRIS  (6)    , 7, 3, 10, 18, 10, 8,             /*           |   <Start> <Include> <White> <path> <White> <Stop> */
	MARPATCL_RCMD_PRIS  (5)    , 7, 3, 10, 18, 8,                 /*           |   <Start> <Include> <White> <path> <Stop> */
	MARPATCL_RCMD_PRIO  (1), 17, 20,                              /* <varname> ::= <recurse> */
	MARPATCL_RCMD_PRIO  (1), 18, 20,                              /* <path>    ::= <recurse> */
	MARPATCL_RCMD_PRIO  (1), 19, 11,                              /* <value>   ::= <Word> */
	MARPATCL_RCMD_PRIO  (1), 20, 28,                              /* <recurse> ::= <braced> */
	MARPATCL_RCMD_PRIS  (1)    , 21,                              /*           |   <quoted> */
	MARPATCL_RCMD_PRIS  (1)    , 24,                              /*           |   <unquot> */
	MARPATCL_RCMD_PRIO  (3), 21, 4, 22, 4,                        /* <quoted>  ::= <Quote> <q_list> <Quote> */
	MARPATCL_RCMD_QUN   (22), 23,                                 /* <q_list>  ::= <q_elem> * */
	MARPATCL_RCMD_PRIO  (1), 23, 30,                              /* <q_elem>  ::= <simple> */
	MARPATCL_RCMD_PRIS  (1)    , 32,                              /*           |   <space> */
	MARPATCL_RCMD_PRIS  (1)    , 13,                              /*           |   <vars> */
	MARPATCL_RCMD_PRIS  (1)    , 33,                              /*           |   <escaped> */
	MARPATCL_RCMD_PRIO  (2), 24, 25, 26,                          /* <unquot>  ::= <uq_lead> <uq_list> */
	MARPATCL_RCMD_PRIO  (1), 25, 30,                              /* <uq_lead> ::= <simple> */
	MARPATCL_RCMD_PRIS  (1)    , 13,                              /*           |   <vars> */
	MARPATCL_RCMD_PRIS  (1)    , 33,                              /*           |   <escaped> */
	MARPATCL_RCMD_QUN   (26), 27,                                 /* <uq_list> ::= <uq_elem> * */
	MARPATCL_RCMD_PRIO  (1), 27, 25,                              /* <uq_elem> ::= <uq_lead> */
	MARPATCL_RCMD_PRIS  (1)    , 31,                              /*           |   <quote> */
	MARPATCL_RCMD_PRIS  (1)    , 29,                              /*           |   <bracel> */
	MARPATCL_RCMD_PRIO  (1), 28, 0,                               /* <braced>  ::= <Braced> */
	MARPATCL_RCMD_PRIO  (1), 29, 1,                               /* <bracel>  ::= <Bracel> */
	MARPATCL_RCMD_PRIO  (1), 30, 5,                               /* <simple>  ::= <Simple> */
	MARPATCL_RCMD_PRIO  (1), 31, 4,                               /* <quote>   ::= <Quote> */
	MARPATCL_RCMD_PRIO  (1), 32, 6,                               /* <space>   ::= <Space> */
	MARPATCL_RCMD_PRIO  (1), 33, 2,                               /* <escaped> ::= <Escaped> */
	MARPATCL_RCMD_DONE  (12)
    };

    static marpatcl_rtc_rules doctools_parser_sf_c_g1 = { /* 48 */
	/* .sname   */  &doctools_parser_sf_c_pool,
	/* .symbols */  { 34, doctools_parser_sf_c_g1_sym_name },
	/* .lmap    */  { 0, 0 },
	/* .rules   */  { 42, doctools_parser_sf_c_g1_rule_name },
	/* .lhs     */  { 42, doctools_parser_sf_c_g1_rule_lhs },
	/* .rcode   */  doctools_parser_sf_c_g1_rule_definitions,
	/* .events  */  0,
	/* .trigger */  0
    };

    static marpatcl_rtc_sym doctools_parser_sf_c_g1semantics [48] = { /* 96 bytes */
	/* --- (1) --- --- --- Tag
	 */
	MARPATCL_S_PER,

	/* --- (42) --- --- --- Semantics Offsets
	 */
	42, 42, 42, 42, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44,
	42, 42, 42, 42, 42, 42, 42, 44, 42, 42, 42, 42, 44, 42, 42, 42,
	44, 42, 42, 42, 44, 44, 44, 44, 44, 44,

	/* --- (2) --- --- --- Semantics Data
	 */
	/* 42 */ 1, MARPATCL_SV_A_FIRST,
	/* 44 */ 2, MARPATCL_SV_RULE_NAME, MARPATCL_SV_VALUE
    };

    static marpatcl_rtc_sym doctools_parser_sf_c_g1masking [98] = { /* 196 bytes */
	/* --- (1) --- --- --- Tag
	 */
	MARPATCL_S_PER,

	/* --- (42) --- --- --- Mask Offsets
	 */
	 0,  0,  0,  0, 89, 75, 82, 62, 68, 50, 56, 45, 68, 50, 56, 45,
	 0,  0,  0,  0,  0,  0, 42,  0,  0,  0,  0,  0,  0,  0,  0,  0,
	 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,

	/* --- (3) --- --- --- Mask Data
	 */
	/* 42 */ 2, 0, 2,
	/* 45 */ 4, 0, 1, 2, 4,
	/* 50 */ 5, 0, 1, 2, 3, 5,
	/* 56 */ 5, 0, 1, 2, 4, 5,
	/* 62 */ 5, 0, 1, 2, 4, 6,
	/* 68 */ 6, 0, 1, 2, 3, 5, 6,
	/* 75 */ 6, 0, 1, 2, 3, 5, 7,
	/* 82 */ 6, 0, 1, 2, 4, 6, 7,
	/* 89 */ 7, 0, 1, 2, 3, 5, 7, 8
    };

    /*
    ** Parser definition
    */

    static marpatcl_rtc_sym doctools_parser_sf_c_always [0] = { /* 0 bytes */

    };

    static marpatcl_rtc_spec doctools_parser_sf_c_spec = { /* 72 */
	/* .lexemes    */  12,
	/* .discards   */  0,
	/* .l_symbols  */  345,
	/* .g_symbols  */  34,
	/* .always     */  { 0, doctools_parser_sf_c_always },
	/* .l0         */  &doctools_parser_sf_c_l0,
	/* .g1         */  &doctools_parser_sf_c_g1,
	/* .l0semantic */  { 3, doctools_parser_sf_c_l0semantics },
	/* .g1semantic */  { 48, doctools_parser_sf_c_g1semantics },
	/* .g1mask     */  { 98, doctools_parser_sf_c_g1masking }
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