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
from UCDGeneralCategory import *

fun ucd_tolower(c: char): string {
    UCDCaseMappingData.LOWER.case_convert(c)
}

fun ucd_tolower(s: string): string {
  val a = [for c <- s {ucd_tolower(c)}]
  join("", a)
}

fun ucd_toupper(c: char): string {
    UCDCaseMappingData.UPPER.case_convert(c)
}

fun ucd_toupper(s: string): string {
  val a = [for c <- s { ucd_toupper(c) }]
  join("", a)
}

fun ucd_totitle(c: char): string {
    UCDCaseMappingData.TITLE.case_convert(c)
}

fun ucd_totitle(s: string): string {
  val a = [for c <- s {ucd_totitle(c)}]
  join("", a)
}

fun ucd_init() {
    UCDCaseMappingData.LOWER.init()
    UCDCaseMappingData.UPPER.init()
    UCDCaseMappingData.TITLE.init()
}

// General category
fun ucd_is_cased_letter(c: char)           = IS_CASED_LETTER(c)
fun ucd_is_close_punctuation(c: char)      = IS_CLOSE_PUNCTUATION(c)
fun ucd_is_connector_punctuation(c: char)  = IS_CONNECTOR_PUNCTUATION(c)
fun ucd_is_control(c: char)                = IS_CONTROL(c)
fun ucd_is_currency_symbol(c: char)        = IS_CURRENCY_SYMBOL(c)
fun ucd_is_dash_punctuation(c: char)       = IS_DASH_PUNCTUATION(c)
fun ucd_is_decimal_number(c: char)         = IS_DECIMAL_NUMBER(c)
fun ucd_is_enclosing_mark(c: char)         = IS_ENCLOSING_MARK(c)
fun ucd_is_final_punctuation(c: char)      = IS_FINAL_PUNCTUATION(c)
fun ucd_is_format(c: char)                 = IS_FORMAT(c)
fun ucd_is_initial_punctuation(c: char)    = IS_INITIAL_PUNCTUATION(c)
fun ucd_is_letter(c: char)                 = IS_LETTER(c)
fun ucd_is_letter_number(c: char)          = IS_LETTER_NUMBER(c)
fun ucd_is_line_separator(c: char)         = IS_LINE_SEPARATOR(c)
fun ucd_is_lowercase_letter(c: char)       = IS_LOWERCASE_LETTER(c)
fun ucd_is_mark(c: char)                   = IS_MARK(c)
fun ucd_is_math_symbol(c: char)            = IS_MATH_SYMBOL(c)
fun ucd_is_modifier_letter(c: char)        = IS_MODIFIER_LETTER(c)
fun ucd_is_modifier_symbol(c: char)        = IS_MODIFIER_SYMBOL(c)
fun ucd_is_nonspacing_mark(c: char)        = IS_NONSPACING_MARK(c)
fun ucd_is_number(c: char)                 = IS_NUMBER(c)
fun ucd_is_open_punctuation(c: char)       = IS_OPEN_PUNCTUATION(c)
fun ucd_is_other(c: char)                  = IS_OTHER(c)
fun ucd_is_other_letter(c: char)           = IS_OTHER_LETTER(c)
fun ucd_is_other_number(c: char)           = IS_OTHER_NUMBER(c)
fun ucd_is_other_punctuation(c: char)      = IS_OTHER_PUNCTUATION(c)
fun ucd_is_other_symbol(c: char)           = IS_OTHER_SYMBOL(c)
fun ucd_is_paragraph_separator(c: char)    = IS_PARAGRAPH_SEPARATOR(c)
fun ucd_is_private_use(c: char)            = IS_PRIVATE_USE(c)
fun ucd_is_punctuation(c: char)            = IS_PUNCTUATION(c)
fun ucd_is_separator(c: char)              = IS_SEPARATOR(c)
fun ucd_is_space_separator(c: char)        = IS_SPACE_SEPARATOR(c)
fun ucd_is_spacing_mark(c: char)           = IS_SPACING_MARK(c)
fun ucd_is_surrogate(c: char)              = IS_SURROGATE(c)
fun ucd_is_symbol(c: char)                 = IS_SYMBOL(c)
fun ucd_is_titlecase_letter(c: char)       = IS_TITLECASE_LETTER(c)
fun ucd_is_unassigned(c: char)             = IS_UNASSIGNED(c)
fun ucd_is_uppercase_letter(c: char)       = IS_UPPERCASE_LETTER(c)

// Property bool
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

