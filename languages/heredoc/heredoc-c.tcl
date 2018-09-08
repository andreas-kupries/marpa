# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017-present Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                             http://core.tcl.tk/akupries/
##
# (c) 2018 Grammar heredoc::parser::c 0 By Andreas Kupries
##
##	`marpa::runtime::c`-derived Parser for grammar "heredoc::parser::c".
##	Generated On Sat Sep 08 15:04:28 PDT 2018
##		  By aku@hephaistos
##		 Via remeta
##
#* Space taken: 5704 bytes
##
#* Statistics
#* L0
#* - #Symbols:   276
#* - #Lexemes:   5
#* - #Discards:  1
#* - #Always:    1
#* - #Rule Insn: 22 (+2: setup, start-sym)
#* - #Rules:     73 (>= insn, brange)
#* G1
#* - #Symbols:   11
#* - #Rule Insn: 7 (+2: setup, start-sym)
#* - #Rules:     7 (match insn)

package provide heredoc::parser::c 0

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
    error "Unable to build heredoc::parser::c, no compiler found."
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
    ** Shared string pool (550 bytes lengths over 275 entries)
    **                    (550 bytes offsets -----^)
    **                    (3572 bytes character content)
    */

    static marpatcl_rtc_size heredoc_parser_c_pool_length [275] = { /* 550 bytes */
	 1,  1,  2,  9, 12,  7,  5,  5,  8,  3,  3,  2,  2,  2,  1,  1,
	 1,  1,  1,  1,  5,  1,  1,  1,  1, 10, 11,  1,  1,  1,  1,  1,
	 1,  7, 12, 13,  1,  1, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15,
	15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
	15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
	15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
	15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
	16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
	16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
	16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
	16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
	16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
	16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
	16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
	16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,  1,  1,  1,  1,  1,
	 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  3,
	 5,  9,  9, 10,  1,  1,  1,  1,  1,  1,  1,  1, 10,  1,  1,  1,
	 1,  1,  1
    };

    static marpatcl_rtc_size heredoc_parser_c_pool_offset [275] = { /* 550 bytes */
	   0,    2,    4,    7,   17,   30,   38,   44,   50,   59,   63,   67,   70,   73,   76,   78,
	  80,   82,   84,   86,   88,   94,   96,   98,  100,  102,  113,  125,  127,  129,  131,  133,
	 135,  137,  145,  158,  172,  174,  176,  191,  206,  221,  236,  251,  266,  281,  296,  311,
	 327,  343,  359,  375,  391,  407,  423,  439,  455,  471,  487,  503,  519,  535,  551,  567,
	 583,  599,  615,  631,  647,  663,  679,  695,  711,  727,  743,  759,  775,  791,  807,  823,
	 839,  855,  871,  887,  903,  919,  935,  951,  967,  983,  999, 1015, 1031, 1047, 1063, 1079,
	1095, 1111, 1127, 1143, 1159, 1175, 1191, 1208, 1225, 1242, 1259, 1276, 1293, 1310, 1327, 1344,
	1361, 1378, 1395, 1412, 1429, 1446, 1463, 1480, 1497, 1514, 1531, 1548, 1565, 1582, 1599, 1616,
	1633, 1650, 1667, 1684, 1701, 1718, 1735, 1752, 1769, 1786, 1803, 1820, 1837, 1854, 1871, 1888,
	1905, 1922, 1939, 1956, 1973, 1990, 2007, 2024, 2041, 2058, 2075, 2092, 2109, 2126, 2143, 2160,
	2177, 2194, 2211, 2228, 2245, 2262, 2279, 2296, 2313, 2330, 2347, 2364, 2381, 2398, 2415, 2432,
	2449, 2466, 2483, 2500, 2517, 2534, 2551, 2568, 2585, 2602, 2619, 2636, 2653, 2670, 2687, 2704,
	2721, 2738, 2755, 2772, 2789, 2806, 2823, 2840, 2857, 2874, 2891, 2908, 2925, 2942, 2959, 2976,
	2993, 3010, 3027, 3044, 3061, 3078, 3095, 3112, 3129, 3146, 3163, 3180, 3197, 3214, 3231, 3248,
	3265, 3282, 3299, 3316, 3333, 3350, 3367, 3384, 3401, 3418, 3435, 3452, 3454, 3456, 3458, 3460,
	3462, 3464, 3466, 3468, 3470, 3472, 3474, 3476, 3478, 3480, 3482, 3484, 3486, 3488, 3490, 3492,
	3496, 3502, 3512, 3522, 3533, 3535, 3537, 3539, 3541, 3543, 3545, 3547, 3549, 3560, 3562, 3564,
	3566, 3568, 3570
    };

    static marpatcl_rtc_string heredoc_parser_c_pool = { /* 24 + 3572 bytes */
	heredoc_parser_c_pool_length,
	heredoc_parser_c_pool_offset,
	/*   0 */ ",\0"
	/*   1 */ "<\0"
	/*   2 */ "<<\0"
	/*   3 */ "@L0:START\0"
	/*   4 */ "[\\t-\\n\\r\\40]\0"
	/*   5 */ "[\\t-\\n]\0"
	/*   6 */ "[A-Z]\0"
	/*   7 */ "[a-z]\0"
	/*   8 */ "[A-Za-z]\0"
	/*   9 */ "\\40\0"
	/*  10 */ "\\73\0"
	/*  11 */ "\\n\0"
	/*  12 */ "\\r\0"
	/*  13 */ "\\t\0"
	/*  14 */ "A\0"
	/*  15 */ "a\0"
	/*  16 */ "B\0"
	/*  17 */ "b\0"
	/*  18 */ "C\0"
	/*  19 */ "c\0"
	/*  20 */ "comma\0"
	/*  21 */ "D\0"
	/*  22 */ "d\0"
	/*  23 */ "E\0"
	/*  24 */ "e\0"
	/*  25 */ "expression\0"
	/*  26 */ "expressions\0"
	/*  27 */ "F\0"
	/*  28 */ "f\0"
	/*  29 */ "G\0"
	/*  30 */ "g\0"
	/*  31 */ "H\0"
	/*  32 */ "h\0"
	/*  33 */ "heredoc\0"
	/*  34 */ "heredoc decl\0"
	/*  35 */ "heredoc start\0"
	/*  36 */ "I\0"
	/*  37 */ "i\0"
	/*  38 */ "ILLEGAL_BYTE_0\0"
	/*  39 */ "ILLEGAL_BYTE_1\0"
	/*  40 */ "ILLEGAL_BYTE_2\0"
	/*  41 */ "ILLEGAL_BYTE_3\0"
	/*  42 */ "ILLEGAL_BYTE_4\0"
	/*  43 */ "ILLEGAL_BYTE_5\0"
	/*  44 */ "ILLEGAL_BYTE_6\0"
	/*  45 */ "ILLEGAL_BYTE_7\0"
	/*  46 */ "ILLEGAL_BYTE_8\0"
	/*  47 */ "ILLEGAL_BYTE_11\0"
	/*  48 */ "ILLEGAL_BYTE_12\0"
	/*  49 */ "ILLEGAL_BYTE_14\0"
	/*  50 */ "ILLEGAL_BYTE_15\0"
	/*  51 */ "ILLEGAL_BYTE_16\0"
	/*  52 */ "ILLEGAL_BYTE_17\0"
	/*  53 */ "ILLEGAL_BYTE_18\0"
	/*  54 */ "ILLEGAL_BYTE_19\0"
	/*  55 */ "ILLEGAL_BYTE_20\0"
	/*  56 */ "ILLEGAL_BYTE_21\0"
	/*  57 */ "ILLEGAL_BYTE_22\0"
	/*  58 */ "ILLEGAL_BYTE_23\0"
	/*  59 */ "ILLEGAL_BYTE_24\0"
	/*  60 */ "ILLEGAL_BYTE_25\0"
	/*  61 */ "ILLEGAL_BYTE_26\0"
	/*  62 */ "ILLEGAL_BYTE_27\0"
	/*  63 */ "ILLEGAL_BYTE_28\0"
	/*  64 */ "ILLEGAL_BYTE_29\0"
	/*  65 */ "ILLEGAL_BYTE_30\0"
	/*  66 */ "ILLEGAL_BYTE_31\0"
	/*  67 */ "ILLEGAL_BYTE_33\0"
	/*  68 */ "ILLEGAL_BYTE_34\0"
	/*  69 */ "ILLEGAL_BYTE_35\0"
	/*  70 */ "ILLEGAL_BYTE_36\0"
	/*  71 */ "ILLEGAL_BYTE_37\0"
	/*  72 */ "ILLEGAL_BYTE_38\0"
	/*  73 */ "ILLEGAL_BYTE_39\0"
	/*  74 */ "ILLEGAL_BYTE_40\0"
	/*  75 */ "ILLEGAL_BYTE_41\0"
	/*  76 */ "ILLEGAL_BYTE_42\0"
	/*  77 */ "ILLEGAL_BYTE_43\0"
	/*  78 */ "ILLEGAL_BYTE_45\0"
	/*  79 */ "ILLEGAL_BYTE_46\0"
	/*  80 */ "ILLEGAL_BYTE_47\0"
	/*  81 */ "ILLEGAL_BYTE_48\0"
	/*  82 */ "ILLEGAL_BYTE_49\0"
	/*  83 */ "ILLEGAL_BYTE_50\0"
	/*  84 */ "ILLEGAL_BYTE_51\0"
	/*  85 */ "ILLEGAL_BYTE_52\0"
	/*  86 */ "ILLEGAL_BYTE_53\0"
	/*  87 */ "ILLEGAL_BYTE_54\0"
	/*  88 */ "ILLEGAL_BYTE_55\0"
	/*  89 */ "ILLEGAL_BYTE_56\0"
	/*  90 */ "ILLEGAL_BYTE_57\0"
	/*  91 */ "ILLEGAL_BYTE_58\0"
	/*  92 */ "ILLEGAL_BYTE_61\0"
	/*  93 */ "ILLEGAL_BYTE_62\0"
	/*  94 */ "ILLEGAL_BYTE_63\0"
	/*  95 */ "ILLEGAL_BYTE_64\0"
	/*  96 */ "ILLEGAL_BYTE_91\0"
	/*  97 */ "ILLEGAL_BYTE_92\0"
	/*  98 */ "ILLEGAL_BYTE_93\0"
	/*  99 */ "ILLEGAL_BYTE_94\0"
	/* 100 */ "ILLEGAL_BYTE_95\0"
	/* 101 */ "ILLEGAL_BYTE_96\0"
	/* 102 */ "ILLEGAL_BYTE_123\0"
	/* 103 */ "ILLEGAL_BYTE_124\0"
	/* 104 */ "ILLEGAL_BYTE_125\0"
	/* 105 */ "ILLEGAL_BYTE_126\0"
	/* 106 */ "ILLEGAL_BYTE_127\0"
	/* 107 */ "ILLEGAL_BYTE_128\0"
	/* 108 */ "ILLEGAL_BYTE_129\0"
	/* 109 */ "ILLEGAL_BYTE_130\0"
	/* 110 */ "ILLEGAL_BYTE_131\0"
	/* 111 */ "ILLEGAL_BYTE_132\0"
	/* 112 */ "ILLEGAL_BYTE_133\0"
	/* 113 */ "ILLEGAL_BYTE_134\0"
	/* 114 */ "ILLEGAL_BYTE_135\0"
	/* 115 */ "ILLEGAL_BYTE_136\0"
	/* 116 */ "ILLEGAL_BYTE_137\0"
	/* 117 */ "ILLEGAL_BYTE_138\0"
	/* 118 */ "ILLEGAL_BYTE_139\0"
	/* 119 */ "ILLEGAL_BYTE_140\0"
	/* 120 */ "ILLEGAL_BYTE_141\0"
	/* 121 */ "ILLEGAL_BYTE_142\0"
	/* 122 */ "ILLEGAL_BYTE_143\0"
	/* 123 */ "ILLEGAL_BYTE_144\0"
	/* 124 */ "ILLEGAL_BYTE_145\0"
	/* 125 */ "ILLEGAL_BYTE_146\0"
	/* 126 */ "ILLEGAL_BYTE_147\0"
	/* 127 */ "ILLEGAL_BYTE_148\0"
	/* 128 */ "ILLEGAL_BYTE_149\0"
	/* 129 */ "ILLEGAL_BYTE_150\0"
	/* 130 */ "ILLEGAL_BYTE_151\0"
	/* 131 */ "ILLEGAL_BYTE_152\0"
	/* 132 */ "ILLEGAL_BYTE_153\0"
	/* 133 */ "ILLEGAL_BYTE_154\0"
	/* 134 */ "ILLEGAL_BYTE_155\0"
	/* 135 */ "ILLEGAL_BYTE_156\0"
	/* 136 */ "ILLEGAL_BYTE_157\0"
	/* 137 */ "ILLEGAL_BYTE_158\0"
	/* 138 */ "ILLEGAL_BYTE_159\0"
	/* 139 */ "ILLEGAL_BYTE_160\0"
	/* 140 */ "ILLEGAL_BYTE_161\0"
	/* 141 */ "ILLEGAL_BYTE_162\0"
	/* 142 */ "ILLEGAL_BYTE_163\0"
	/* 143 */ "ILLEGAL_BYTE_164\0"
	/* 144 */ "ILLEGAL_BYTE_165\0"
	/* 145 */ "ILLEGAL_BYTE_166\0"
	/* 146 */ "ILLEGAL_BYTE_167\0"
	/* 147 */ "ILLEGAL_BYTE_168\0"
	/* 148 */ "ILLEGAL_BYTE_169\0"
	/* 149 */ "ILLEGAL_BYTE_170\0"
	/* 150 */ "ILLEGAL_BYTE_171\0"
	/* 151 */ "ILLEGAL_BYTE_172\0"
	/* 152 */ "ILLEGAL_BYTE_173\0"
	/* 153 */ "ILLEGAL_BYTE_174\0"
	/* 154 */ "ILLEGAL_BYTE_175\0"
	/* 155 */ "ILLEGAL_BYTE_176\0"
	/* 156 */ "ILLEGAL_BYTE_177\0"
	/* 157 */ "ILLEGAL_BYTE_178\0"
	/* 158 */ "ILLEGAL_BYTE_179\0"
	/* 159 */ "ILLEGAL_BYTE_180\0"
	/* 160 */ "ILLEGAL_BYTE_181\0"
	/* 161 */ "ILLEGAL_BYTE_182\0"
	/* 162 */ "ILLEGAL_BYTE_183\0"
	/* 163 */ "ILLEGAL_BYTE_184\0"
	/* 164 */ "ILLEGAL_BYTE_185\0"
	/* 165 */ "ILLEGAL_BYTE_186\0"
	/* 166 */ "ILLEGAL_BYTE_187\0"
	/* 167 */ "ILLEGAL_BYTE_188\0"
	/* 168 */ "ILLEGAL_BYTE_189\0"
	/* 169 */ "ILLEGAL_BYTE_190\0"
	/* 170 */ "ILLEGAL_BYTE_191\0"
	/* 171 */ "ILLEGAL_BYTE_192\0"
	/* 172 */ "ILLEGAL_BYTE_193\0"
	/* 173 */ "ILLEGAL_BYTE_194\0"
	/* 174 */ "ILLEGAL_BYTE_195\0"
	/* 175 */ "ILLEGAL_BYTE_196\0"
	/* 176 */ "ILLEGAL_BYTE_197\0"
	/* 177 */ "ILLEGAL_BYTE_198\0"
	/* 178 */ "ILLEGAL_BYTE_199\0"
	/* 179 */ "ILLEGAL_BYTE_200\0"
	/* 180 */ "ILLEGAL_BYTE_201\0"
	/* 181 */ "ILLEGAL_BYTE_202\0"
	/* 182 */ "ILLEGAL_BYTE_203\0"
	/* 183 */ "ILLEGAL_BYTE_204\0"
	/* 184 */ "ILLEGAL_BYTE_205\0"
	/* 185 */ "ILLEGAL_BYTE_206\0"
	/* 186 */ "ILLEGAL_BYTE_207\0"
	/* 187 */ "ILLEGAL_BYTE_208\0"
	/* 188 */ "ILLEGAL_BYTE_209\0"
	/* 189 */ "ILLEGAL_BYTE_210\0"
	/* 190 */ "ILLEGAL_BYTE_211\0"
	/* 191 */ "ILLEGAL_BYTE_212\0"
	/* 192 */ "ILLEGAL_BYTE_213\0"
	/* 193 */ "ILLEGAL_BYTE_214\0"
	/* 194 */ "ILLEGAL_BYTE_215\0"
	/* 195 */ "ILLEGAL_BYTE_216\0"
	/* 196 */ "ILLEGAL_BYTE_217\0"
	/* 197 */ "ILLEGAL_BYTE_218\0"
	/* 198 */ "ILLEGAL_BYTE_219\0"
	/* 199 */ "ILLEGAL_BYTE_220\0"
	/* 200 */ "ILLEGAL_BYTE_221\0"
	/* 201 */ "ILLEGAL_BYTE_222\0"
	/* 202 */ "ILLEGAL_BYTE_223\0"
	/* 203 */ "ILLEGAL_BYTE_224\0"
	/* 204 */ "ILLEGAL_BYTE_225\0"
	/* 205 */ "ILLEGAL_BYTE_226\0"
	/* 206 */ "ILLEGAL_BYTE_227\0"
	/* 207 */ "ILLEGAL_BYTE_228\0"
	/* 208 */ "ILLEGAL_BYTE_229\0"
	/* 209 */ "ILLEGAL_BYTE_230\0"
	/* 210 */ "ILLEGAL_BYTE_231\0"
	/* 211 */ "ILLEGAL_BYTE_232\0"
	/* 212 */ "ILLEGAL_BYTE_233\0"
	/* 213 */ "ILLEGAL_BYTE_234\0"
	/* 214 */ "ILLEGAL_BYTE_235\0"
	/* 215 */ "ILLEGAL_BYTE_236\0"
	/* 216 */ "ILLEGAL_BYTE_237\0"
	/* 217 */ "ILLEGAL_BYTE_238\0"
	/* 218 */ "ILLEGAL_BYTE_239\0"
	/* 219 */ "ILLEGAL_BYTE_240\0"
	/* 220 */ "ILLEGAL_BYTE_241\0"
	/* 221 */ "ILLEGAL_BYTE_242\0"
	/* 222 */ "ILLEGAL_BYTE_243\0"
	/* 223 */ "ILLEGAL_BYTE_244\0"
	/* 224 */ "ILLEGAL_BYTE_245\0"
	/* 225 */ "ILLEGAL_BYTE_246\0"
	/* 226 */ "ILLEGAL_BYTE_247\0"
	/* 227 */ "ILLEGAL_BYTE_248\0"
	/* 228 */ "ILLEGAL_BYTE_249\0"
	/* 229 */ "ILLEGAL_BYTE_250\0"
	/* 230 */ "ILLEGAL_BYTE_251\0"
	/* 231 */ "ILLEGAL_BYTE_252\0"
	/* 232 */ "ILLEGAL_BYTE_253\0"
	/* 233 */ "ILLEGAL_BYTE_254\0"
	/* 234 */ "ILLEGAL_BYTE_255\0"
	/* 235 */ "J\0"
	/* 236 */ "j\0"
	/* 237 */ "K\0"
	/* 238 */ "k\0"
	/* 239 */ "L\0"
	/* 240 */ "l\0"
	/* 241 */ "M\0"
	/* 242 */ "m\0"
	/* 243 */ "N\0"
	/* 244 */ "n\0"
	/* 245 */ "O\0"
	/* 246 */ "o\0"
	/* 247 */ "P\0"
	/* 248 */ "p\0"
	/* 249 */ "Q\0"
	/* 250 */ "q\0"
	/* 251 */ "R\0"
	/* 252 */ "r\0"
	/* 253 */ "S\0"
	/* 254 */ "s\0"
	/* 255 */ "say\0"
	/* 256 */ "sayer\0"
	/* 257 */ "semicolon\0"
	/* 258 */ "statement\0"
	/* 259 */ "statements\0"
	/* 260 */ "T\0"
	/* 261 */ "t\0"
	/* 262 */ "U\0"
	/* 263 */ "u\0"
	/* 264 */ "V\0"
	/* 265 */ "v\0"
	/* 266 */ "W\0"
	/* 267 */ "w\0"
	/* 268 */ "whitespace\0"
	/* 269 */ "X\0"
	/* 270 */ "x\0"
	/* 271 */ "Y\0"
	/* 272 */ "y\0"
	/* 273 */ "Z\0"
	/* 274 */ "z\0"
    };

    /*
    ** Map lexeme strings to parser symbol id (`match alternate` support).
    */

    static marpatcl_rtc_sym_lmap heredoc_parser_c_lmap [5] = {
	{ 20 , 0 }, // comma
	{ 33 , 1 }, // heredoc
	{ 35 , 2 }, // heredoc start
	{ 255, 3 }, // say
	{ 257, 4 }, // semicolon
    };

    /*
    ** Declared events, initial stati
    */

    static unsigned char heredoc_parser_c_evstatus [1] = {
	1, // heredoc = on
    };

    static marpatcl_rtc_event heredoc_parser_c_evspec = {
	/* .size */ 1,
	/* .data */ heredoc_parser_c_evstatus
    };

    /*
    ** L0 structures
    */

    static marpatcl_rtc_sym heredoc_parser_c_l0_sym_name [276] = { /* 552 bytes */
	/* --- (256) --- --- --- Characters
	 */
	 38,  39,  40,  41,  42,  43,  44,  45,  46,  13,  11,  47,  48,  12,  49,  50,
	 51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  62,  63,  64,  65,  66,
	  9,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,   0,  78,  79,  80,
	 81,  82,  83,  84,  85,  86,  87,  88,  89,  90,  91,  10,   1,  92,  93,  94,
	 95,  14,  16,  18,  21,  23,  27,  29,  31,  36, 235, 237, 239, 241, 243, 245,
	247, 249, 251, 253, 260, 262, 264, 266, 269, 271, 273,  96,  97,  98,  99, 100,
	101,  15,  17,  19,  22,  24,  28,  30,  32,  37, 236, 238, 240, 242, 244, 246,
	248, 250, 252, 254, 261, 263, 265, 267, 270, 272, 274, 102, 103, 104, 105, 106,
	107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122,
	123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138,
	139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154,
	155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170,
	171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186,
	187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202,
	203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218,
	219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234,

	/* --- (5) --- --- --- ACS: Lexeme
	 */
	 20,  33,  35, 255, 257,

	/* --- (1) --- --- --- ACS: Discard
	 */
	268,

	/* --- (5) --- --- --- Lexeme
	 */
	 20,  33,  35, 255, 257,

	/* --- (1) --- --- --- Discard
	 */
	268,

	/* --- (8) --- --- --- Internal
	 */
	  4,   8,   2, 255,   5,   6,   7,   3
    };

    static marpatcl_rtc_sym heredoc_parser_c_l0_rule_definitions [64] = { /* 128 bytes */
	MARPATCL_RCMD_SETUP (3),
	MARPATCL_RCMD_PRIO  (1), 262, 44,                        /* <comma>             ::= <@CHR:<,>> */
	MARPATCL_RCMD_QUP   (263), 269,                          /* <heredoc>           ::= <@CLS:<A-Za-z>> + */
	MARPATCL_RCMD_PRIO  (1), 264, 270,                       /* <heredoc start>     ::= <@STR:<<<>> */
	MARPATCL_RCMD_PRIO  (1), 265, 271,                       /* <say>               ::= <@STR:<say>> */
	MARPATCL_RCMD_PRIO  (1), 266, 59,                        /* <semicolon>         ::= <@CHR:<\73>> */
	MARPATCL_RCMD_QUP   (267), 268,                          /* <whitespace>        ::= <@CLS:<\t-\n\r\40>> + */
	MARPATCL_RCMD_PRIO  (1), 268, 272,                       /* <@CLS:<\t-\n\r\40>> ::= <@BRAN:<\t\n>> */
	MARPATCL_RCMD_PRIS  (1)     , 13,                        /*                     |   <@BYTE:<\r>> */
	MARPATCL_RCMD_PRIS  (1)     , 32,                        /*                     |   <@BYTE:<\40>> */
	MARPATCL_RCMD_PRIO  (1), 269, 273,                       /* <@CLS:<A-Za-z>>     ::= <@BRAN:<AZ>> */
	MARPATCL_RCMD_PRIS  (1)     , 274,                       /*                     |   <@BRAN:<az>> */
	MARPATCL_RCMD_PRIO  (2), 270, 60, 60,                    /* <@STR:<<<>>         ::= <@BYTE:<<>> <@BYTE:<<>> */
	MARPATCL_RCMD_PRIO  (3), 271, 115, 97, 121,              /* <@STR:<say>>        ::= <@BYTE:<s>> <@BYTE:<a>> <@BYTE:<y>> */
	MARPATCL_RCMD_BRAN  (272), MARPATCL_RCMD_BOXR (  9, 10), /* <@BRAN:<\t\n>>      brange (9 - 10) */
	MARPATCL_RCMD_BRAN  (273), MARPATCL_RCMD_BOXR ( 65, 90), /* <@BRAN:<AZ>>        brange (65 - 90) */
	MARPATCL_RCMD_BRAN  (274), MARPATCL_RCMD_BOXR ( 97,122), /* <@BRAN:<az>>        brange (97 - 122) */
	MARPATCL_RCMD_PRIO  (2), 275, 256, 262,                  /* <@L0:START>         ::= <@ACS:comma> <comma> */
	MARPATCL_RCMD_PRIS  (2)     , 257, 263,                  /*                     |   <@ACS:heredoc> <heredoc> */
	MARPATCL_RCMD_PRIS  (2)     , 258, 264,                  /*                     |   <@ACS:heredoc start> <heredoc start> */
	MARPATCL_RCMD_PRIS  (2)     , 259, 265,                  /*                     |   <@ACS:say> <say> */
	MARPATCL_RCMD_PRIS  (2)     , 260, 266,                  /*                     |   <@ACS:semicolon> <semicolon> */
	MARPATCL_RCMD_PRIS  (2)     , 261, 267,                  /*                     |   <@ACS:whitespace> <whitespace> */
	MARPATCL_RCMD_DONE  (275)
    };

    marpatcl_rtc_trigger_entry heredoc_parser_c_l0trigger_entry [1] = {
	{ 1, marpatcl_rtc_event_after, 0 }, // heredoc => heredoc
    };

    marpatcl_rtc_trigger heredoc_parser_c_l0trigger = {
	/* .size */ 1,
	/* .data */ heredoc_parser_c_l0trigger_entry
    };

    static marpatcl_rtc_rules heredoc_parser_c_l0 = { /* 48 */
	/* .sname   */  &heredoc_parser_c_pool,
	/* .symbols */  { 276, heredoc_parser_c_l0_sym_name },
	/* .lmap    */  { 5, heredoc_parser_c_lmap },
	/* .rules   */  { 0, NULL },
	/* .lhs     */  { 0, NULL },
	/* .rcode   */  heredoc_parser_c_l0_rule_definitions,
	/* .events  */  &heredoc_parser_c_evspec,
	/* .trigger */  &heredoc_parser_c_l0trigger
    };

    static marpatcl_rtc_sym heredoc_parser_c_l0semantics [3] = { /* 6 bytes */
	 MARPATCL_SV_START, MARPATCL_SV_LENGTH,  MARPATCL_SV_VALUE
    };

    /*
    ** G1 structures
    */

    static marpatcl_rtc_sym heredoc_parser_c_g1_sym_name [11] = { /* 22 bytes */
	/* --- (5) --- --- --- Terminals
	 */
	 20,  33,  35, 255, 257,

	/* --- (6) --- --- --- Structure
	 */
	259, 258,  26,  25, 256,  34
    };

    static marpatcl_rtc_sym heredoc_parser_c_g1_rule_name [7] = { /* 14 bytes */
	259, 258,  26,  25,  25, 256,  34
    };

    static marpatcl_rtc_sym heredoc_parser_c_g1_rule_lhs [7] = { /* 14 bytes */
	 5,  6,  7,  8,  8,  9, 10
    };

    static marpatcl_rtc_sym heredoc_parser_c_g1_rule_definitions [24] = { /* 48 bytes */
	MARPATCL_RCMD_SETUP (2),
	MARPATCL_RCMD_QUP   (5), 6,                        /* <statements>   ::= <statement> + */
	MARPATCL_RCMD_PRIO  (2), 6, 7, 4,                  /* <statement>    ::= <expressions> <semicolon> */
	MARPATCL_RCMD_QUPS  (7), 8, MARPATCL_RCMD_SEP (0), /* <expressions>  ::= <expression> + (<comma>) */
	MARPATCL_RCMD_PRIO  (1), 8, 10,                    /* <expression>   ::= <heredoc decl> */
	MARPATCL_RCMD_PRIS  (1)   , 9,                     /*                |   <sayer> */
	MARPATCL_RCMD_PRIO  (2), 9, 3, 7,                  /* <sayer>        ::= <say> <expressions> */
	MARPATCL_RCMD_PRIO  (2), 10, 2, 1,                 /* <heredoc decl> ::= <heredoc start> <heredoc> */
	MARPATCL_RCMD_DONE  (5)
    };

    static marpatcl_rtc_rules heredoc_parser_c_g1 = { /* 48 */
	/* .sname   */  &heredoc_parser_c_pool,
	/* .symbols */  { 11, heredoc_parser_c_g1_sym_name },
	/* .lmap    */  { 0, 0 },
	/* .rules   */  { 7, heredoc_parser_c_g1_rule_name },
	/* .lhs     */  { 7, heredoc_parser_c_g1_rule_lhs },
	/* .rcode   */  heredoc_parser_c_g1_rule_definitions,
	/* .events  */  &heredoc_parser_c_evspec,
	/* .trigger */  0
    };

    static marpatcl_rtc_sym heredoc_parser_c_g1semantics [13] = { /* 26 bytes */
	/* --- (1) --- --- --- Tag
	 */
	MARPATCL_S_PER,

	/* --- (7) --- --- --- Semantics Offsets
	 */
	9, 7, 9, 7, 9, 9, 9,

	/* --- (2) --- --- --- Semantics Data
	 */
	         /*  7 */ 1, MARPATCL_SV_A_FIRST,
	           /*  9 */ 2, MARPATCL_SV_RULE_NAME,     MARPATCL_SV_VALUE
    };

    static marpatcl_rtc_sym heredoc_parser_c_g1masking [12] = { /* 24 bytes */
	/* --- (1) --- --- --- Tag
	 */
	MARPATCL_S_PER,

	/* --- (7) --- --- --- Mask Offsets
	 */
	0, 9, 0, 0, 0, 7, 7,

	/* --- (2) --- --- --- Mask Data
	 */
	/*  7 */ 1, 0,
	/*  9 */ 1, 1
    };

    /*
    ** Parser definition
    */

    static marpatcl_rtc_sym heredoc_parser_c_always [1] = { /* 2 bytes */
	5
    };

    static marpatcl_rtc_spec heredoc_parser_c_spec = { /* 72 */
	/* .lexemes    */  5,
	/* .discards   */  1,
	/* .l_symbols  */  276,
	/* .g_symbols  */  11,
	/* .always     */  { 1, heredoc_parser_c_always },
	/* .l0         */  &heredoc_parser_c_l0,
	/* .g1         */  &heredoc_parser_c_g1,
	/* .l0semantic */  { 3, heredoc_parser_c_l0semantics },
	/* .g1semantic */  { 13, heredoc_parser_c_g1semantics },
	/* .g1mask     */  { 12, heredoc_parser_c_g1masking }
    };
    /* --- end of generated data structures --- */
}

# # ## ### ##### ######## ############# #####################
## Class exposing the grammar engine.

critcl::literals::def heredoc_parser_c_event {
    u0       "heredoc"
} +list

critcl::class def heredoc::parser::c {

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
	instance->state = marpatcl_rtc_cons (&heredoc_parser_c_spec,
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
			      (marpatcl_events_to_names) heredoc_parser_c_event_list);
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