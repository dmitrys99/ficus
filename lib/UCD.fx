//
// Этот файл является частью проекта
// "Язык программирования Фикус"
//
// Лицензионное соглашение находится в файле LICENSE
//
// ==================================================

import UCDCaseMapping
import UCDCaseMappingData
from UCDPropertyData import *

fun lower(c: char): string {
    UCDCaseMappingData.LOWER.case_convert(c)
}

fun upper(c: char): string {
    UCDCaseMappingData.UPPER.case_convert(c)
}

fun title(c: char): string {
    UCDCaseMappingData.TITLE.case_convert(c)
}

fun ucd_init() {
    UCDCaseMappingData.LOWER.init()
    UCDCaseMappingData.UPPER.init()
    UCDCaseMappingData.TITLE.init()
}

fun ucd_is_ascii_hex_digit(c: char)                    = IS_ASCII_HEX_DIGIT(c)
fun ucd_is_alphabetic(c: char)                         = IS_ALPHABETIC(c)
fun ucd_is_bidi_control(c: char)                       = IS_BIDI_CONTROL(c)
fun ucd_is_bidi_mirrored(c: char)                      = IS_BIDI_MIRRORED(c)
fun ucd_is_case_ignorable(c: char)                     = IS_CASE_IGNORABLE(c)
fun ucd_is_cased(c: char)                              = IS_CASED(c)
fun ucd_is_changes_when_casefolded(c: char)            = IS_CHANGES_WHEN_CASEFOLDED(c)
fun ucd_is_changes_when_casemapped(c: char)            = IS_CHANGES_WHEN_CASEMAPPED(c)
fun ucd_is_changes_when_lowercased(c: char)            = IS_CHANGES_WHEN_LOWERCASED(c)
fun ucd_is_changes_when_titlecased(c: char)            = IS_CHANGES_WHEN_TITLECASED(c)
fun ucd_is_changes_when_uppercased(c: char)            = IS_CHANGES_WHEN_UPPERCASED(c)
fun ucd_is_dash(c: char)                               = IS_DASH(c)
fun ucd_is_default_ignorable_code_point(c: char)       = IS_DEFAULT_IGNORABLE_CODE_POINT(c)
fun ucd_is_deprecated(c: char)                         = IS_DEPRECATED(c)
fun ucd_is_diacritic(c: char)                          = IS_DIACRITIC(c)
fun ucd_is_emoji(c: char)                              = IS_EMOJI(c)
fun ucd_is_emoji_component(c: char)                    = IS_EMOJI_COMPONENT(c)
fun ucd_is_emoji_modifier(c: char)                     = IS_EMOJI_MODIFIER(c)
fun ucd_is_emoji_modifier_base(c: char)                = IS_EMOJI_MODIFIER_BASE(c)
fun ucd_is_emoji_presentation(c: char)                 = IS_EMOJI_PRESENTATION(c)
fun ucd_is_extended_pictographic(c: char)              = IS_EXTENDED_PICTOGRAPHIC(c)
fun ucd_is_extender(c: char)                           = IS_EXTENDER(c)
fun ucd_is_grapheme_base(c: char)                      = IS_GRAPHEME_BASE(c)
fun ucd_is_grapheme_extend(c: char)                    = IS_GRAPHEME_EXTEND(c)
fun ucd_is_grapheme_link(c: char)                      = IS_GRAPHEME_LINK(c)
fun ucd_is_hex_digit(c: char)                          = IS_HEX_DIGIT(c)
fun ucd_is_hyphen(c: char)                             = IS_HYPHEN(c)
fun ucd_is_ids_binary_operator(c: char)                = IS_IDS_BINARY_OPERATOR(c)
fun ucd_is_ids_trinary_operator(c: char)               = IS_IDS_TRINARY_OPERATOR(c)
fun ucd_is_ids_unary_operator(c: char)                 = IS_IDS_UNARY_OPERATOR(c)
fun ucd_is_id_compat_math_continue(c: char)            = IS_ID_COMPAT_MATH_CONTINUE(c)
fun ucd_is_id_compat_math_start(c: char)               = IS_ID_COMPAT_MATH_START(c)
fun ucd_is_id_continue(c: char)                        = IS_ID_CONTINUE(c)
fun ucd_is_id_start(c: char)                           = IS_ID_START(c)
fun ucd_is_ideographic(c: char)                        = IS_IDEOGRAPHIC(c)
fun ucd_is_incb(c: char)                               = IS_INCB(c)
fun ucd_is_join_control(c: char)                       = IS_JOIN_CONTROL(c)
fun ucd_is_logical_order_exception(c: char)            = IS_LOGICAL_ORDER_EXCEPTION(c)
fun ucd_is_lowercase(c: char)                          = IS_LOWERCASE(c)
fun ucd_is_math(c: char)                               = IS_MATH(c)
fun ucd_is_modifier_combining_mark(c: char)            = IS_MODIFIER_COMBINING_MARK(c)
fun ucd_is_noncharacter_code_point(c: char)            = IS_NONCHARACTER_CODE_POINT(c)
fun ucd_is_other_alphabetic(c: char)                   = IS_OTHER_ALPHABETIC(c)
fun ucd_is_other_default_ignorable_code_point(c: char) = IS_OTHER_DEFAULT_IGNORABLE_CODE_POINT(c)
fun ucd_is_other_grapheme_extend(c: char)              = IS_OTHER_GRAPHEME_EXTEND(c)
fun ucd_is_other_id_continue(c: char)                  = IS_OTHER_ID_CONTINUE(c)
fun ucd_is_other_id_start(c: char)                     = IS_OTHER_ID_START(c)
fun ucd_is_other_lowercase(c: char)                    = IS_OTHER_LOWERCASE(c)
fun ucd_is_other_math(c: char)                         = IS_OTHER_MATH(c)
fun ucd_is_other_uppercase(c: char)                    = IS_OTHER_UPPERCASE(c)
fun ucd_is_pattern_syntax(c: char)                     = IS_PATTERN_SYNTAX(c)
fun ucd_is_pattern_white_space(c: char)                = IS_PATTERN_WHITE_SPACE(c)
fun ucd_is_prepended_concatenation_mark(c: char)       = IS_PREPENDED_CONCATENATION_MARK(c)
fun ucd_is_quotation_mark(c: char)                     = IS_QUOTATION_MARK(c)
fun ucd_is_radical(c: char)                            = IS_RADICAL(c)
fun ucd_is_regional_indicator(c: char)                 = IS_REGIONAL_INDICATOR(c)
fun ucd_is_sentence_terminal(c: char)                  = IS_SENTENCE_TERMINAL(c)
fun ucd_is_soft_dotted(c: char)                        = IS_SOFT_DOTTED(c)
fun ucd_is_terminal_punctuation(c: char)               = IS_TERMINAL_PUNCTUATION(c)
fun ucd_is_unified_ideograph(c: char)                  = IS_UNIFIED_IDEOGRAPH(c)
fun ucd_is_uppercase(c: char)                          = IS_UPPERCASE(c)
fun ucd_is_variation_selector(c: char)                 = IS_VARIATION_SELECTOR(c)
fun ucd_is_white_space(c: char)                        = IS_WHITE_SPACE(c)
fun ucd_is_xid_continue(c: char)                       = IS_XID_CONTINUE(c)
fun ucd_is_xid_start(c: char)                          = IS_XID_START(c)
