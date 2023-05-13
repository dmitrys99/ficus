/*
    This file is a part of ficus language project.
    See ficus/LICENSE for the licensing terms
*/

#ifndef __FICUS_STRING_IMPL_H__
#define __FICUS_STRING_IMPL_H__

#ifdef __cplusplus
extern "C" {
#endif

int_ fx_strlen(const char_* rawstr)
{
    int_ len = 0;
    while(rawstr[len] != 0)
        len++;
    return len;
}

bool fx_streq(const fx_str_t* a, const fx_str_t* b)
{
    return (bool)(a->length == b->length &&
            (a->length == 0 ||
            memcmp(a->data, b->data, a->length*sizeof(a->data[0])) == 0));
}

void fx_free_str(fx_str_t* str)
{
    if( str->rc )
    {
        if(FX_DECREF(*str->rc) == 1)
            fx_free(str->rc);
        str->data = 0;
        str->length = 0;
        str->rc = 0;
    }
}

void fx_copy_str(const fx_str_t* src, fx_str_t* dst)
{
    FX_COPY_STR(src, dst);
}

int fx_make_str(const char_* strdata, int_ length, fx_str_t* str)
{
    if (length <= 0) {
        if (length == 0) {
            fx_str_t temp = {0, 0, 0};
            *str = temp;
            return FX_OK;
        }
        FX_FAST_THROW_RET(FX_EXN_SizeError);
    } else {
        size_t total = sizeof(*str->rc) + length*sizeof(strdata[0]);
        str->rc = (int_*)fx_malloc(total);
        if(!str->rc) FX_FAST_THROW_RET(FX_EXN_OutOfMemError);

        *str->rc = 1;
        str->data = (char_*)(str->rc + 1);
        str->length = length;
        if(strdata)
            memcpy(str->data, strdata, length*sizeof(strdata[0]));
        return FX_OK;
    }
}

int fx_make_cstr(const char* strdata, int_ length, fx_cstr_t* str)
{
    size_t total = sizeof(*str->rc) + length*sizeof(strdata[0]);
    str->rc = (int_*)fx_malloc(total);
    if(!str->rc) FX_FAST_THROW_RET(FX_EXN_OutOfMemError);

    *str->rc = 1;
    str->data = (char*)(str->rc + 1);
    str->length = length;
    if(strdata)
        memcpy(str->data, strdata, length*sizeof(strdata[0]));
    return FX_OK;
}

void fx_free_cstr(fx_cstr_t* str)
{
    if( str->rc )
    {
        if(FX_DECREF(*str->rc) == 1)
            fx_free(str->rc);
        str->rc = 0;
    }
}

static size_t fx_str2cstr_size(const fx_str_t* str)
{
    size_t sz = 1;
    int_ i, len = str->length;
    const char_* src = str->data;
    for( i = 0; i < len; i++ )
    {
        char_ ch = src[i];
        sz++;
        sz += ch > 127;
        sz += ch > 2047;
        sz += (ch > 65535) & (ch <= 1114111);
    }
    return sz;
}

size_t fx_str2cstr_slice(const fx_str_t* str, int_ start, int_ maxcount, char* buf)
{
    const char_* src = str->data + start;
    int_ i, count = str->length - start;
    char* dst = buf;
    if( count > maxcount ) count = maxcount;

    for( i = 0; i < count; i++ )
    {
        char_ ch = src[i];
        if( ch <= 127 )
            *dst++ = (char)ch;
        else if( ch <= 2047 ) {
            *dst++ = (char)(192 | (ch >> 6));
            *dst++ = (char)(128 | (ch & 63));
        }
        else if( ch <= 65535 ) {
            *dst++ = (char)(224 | (ch >> 12));
            *dst++ = (char)(128 | ((ch >> 6) & 63));
            *dst++ = (char)(128 | (ch & 63));
        }
        else if( ch <= 1114111 ) {
            *dst++ = (char)(240 | (ch >> 18));
            *dst++ = (char)(128 | ((ch >> 12) & 63));
            *dst++ = (char)(128 | ((ch >> 6) & 63));
            *dst++ = (char)(128 | (ch & 63));
        }
        else { // <?>
            *dst++ = (char)239;
            *dst++ = (char)191;
            *dst++ = (char)189;
        }
    }
    *dst++ = '\0';
    return (size_t)(dst - buf);
}

int fx_str2cstr(const fx_str_t* str, fx_cstr_t* cstr, char* buf, size_t bufsz)
{
    size_t sz = fx_str2cstr_size(str);
    if( buf && sz <= bufsz )
    {
        cstr->rc = 0;
        cstr->data = buf;
    }
    else
    {
        size_t total = sizeof(*cstr->rc) + sz*sizeof(cstr->data[0]);
        cstr->rc = (int_*)fx_malloc(total);
        if( !cstr->rc )
            FX_FAST_THROW_RET(FX_EXN_OutOfMemError);
        cstr->data = (char*)(cstr->rc + 1);
        *cstr->rc = 1;
    }
    cstr->length = sz-1;
    fx_str2cstr_slice(str, 0, str->length, cstr->data);
    return FX_OK;
}

static int_ fx_cstr2str_len(const char* src, int_ srclen)
{
    int_ i, dstlen = 0;
    for( i = 0; i < srclen; i++ )
    {
        unsigned char ch = (unsigned char)src[i];
        dstlen++;
        if( ch <= 127 )
            ;
        else
        {
            while(i+1 < srclen && (src[i+1] & 0xc0) == 0x80)
                i++;
        }
    }
    return dstlen;
}

int fx_cstr2str(const char* src, int_ srclen, fx_str_t* str)
{
    int_ dstlen;
    size_t total;
    if(!src)
        return fx_make_str(0, 0, str);
    if(srclen < 0)
        srclen = (int_)strlen(src);
    dstlen = fx_cstr2str_len(src, srclen);
    total = sizeof(*str->rc) + dstlen*sizeof(str->data[0]);
    str->rc = (int_*)fx_malloc(total);
    if( !str->rc )
        FX_FAST_THROW_RET(FX_EXN_OutOfMemError);

    *str->rc = 1;
    str->data = (char_*)(str->rc + 1);
    str->length = dstlen;
    char_* dst = str->data;

    for( int_ i = 0; i < srclen; i++ )
    {
        unsigned char ch = (unsigned char)src[i];
        if( ch <= 127 )
            *dst++ = ch;
        else if( ch <= 223 && i+1 < srclen && (src[i+1] & 0xc0) == 0x80) {
            *dst++ = ((ch & 31) << 6) | (src[i+1] & 63);
            i++;
        }
        else if( ch <= 239 && i+2 < srclen && (src[i+1] & 0xc0) == 0x80 && (src[i+2] & 0xc0) == 0x80) {
            *dst++ = ((ch & 15) << 12) | ((src[i+1] & 63) << 6) | (src[i+2] & 63);
            i += 2;
        }
        else if( ch <= 247 && i+3 < srclen && (src[i+1] & 0xc0) == 0x80 && (src[i+2] & 0xc0) == 0x80 && (src[i+3] & 0xc0) == 0x80) {
            char_ val = (char_)(((ch & 15) << 18) | ((src[i+1] & 63) << 12) | ((src[i+2] & 63) << 6) | (src[i+3] & 63));
            if( val > 1114111 ) val = (char_)65533;
            *dst++ = val;
            i += 3;
        }
        else {
            *dst++ = (char_)65533;
            while(i+1 < srclen && (src[i+1] & 0xc0) == 0x80)
                i++;
        }
    }
    assert(dst - str->data == dstlen);
    return FX_OK;
}

int fx_ascii2str(const char* src, int_ srclen, fx_str_t* str)
{
    if(srclen < 0)
        srclen = (int_)strlen(src);

    size_t total = sizeof(*str->rc) + srclen*sizeof(str->data[0]);
    int_* rcptr = (int_*)fx_malloc(total);
    if( !rcptr )
        FX_FAST_THROW_RET(FX_EXN_OutOfMemError);

    char_* dst = (char_*)(rcptr + 1);
    for( int_ i = 0; i < srclen; i++ )
    {
        unsigned char ch = (unsigned char)src[i];
        if( ch > 127 ) {
            fx_free(rcptr);
            FX_FAST_THROW_RET(FX_EXN_ASCIIError);
        }
        dst[i] = ch;
    }

    *rcptr = 1;
    str->rc = rcptr;
    str->data = dst;
    str->length = srclen;
    return FX_OK;
}

#include "_fx_unicode_data.gen.h"

static int _fx_char_category(char_ ch)
{
    return _fx_uni_getdata(ch) & FX_UNICODE_CAT_Mask;
}

bool fx_isalpha(char_ ch)
{
    return _fx_char_category(ch) <= FX_UNICODE_CAT_Lo;
}

bool fx_isdigit(char_ ch)
{
    return (((1 << FX_UNICODE_CAT_Nd) |
            (1 << FX_UNICODE_CAT_No)) & (1 << _fx_char_category(ch))) != 0;
}

bool fx_isalnum(char_ ch)
{
    return (((1 << FX_UNICODE_CAT_Lu) |
            (1 << FX_UNICODE_CAT_Ll) |
            (1 << FX_UNICODE_CAT_Lt) |
            (1 << FX_UNICODE_CAT_Lm) |
            (1 << FX_UNICODE_CAT_Lo) |
            (1 << FX_UNICODE_CAT_Nd) |
            (1 << FX_UNICODE_CAT_Nl) |
            (1 << FX_UNICODE_CAT_No)) & (1 << _fx_char_category(ch))) != 0;
}

bool fx_ispunct(char_ ch)
{
    return (((1 << FX_UNICODE_CAT_Pd) |
            (1 << FX_UNICODE_CAT_Ps) |
            (1 << FX_UNICODE_CAT_Pe) |
            (1 << FX_UNICODE_CAT_Pc) |
            (1 << FX_UNICODE_CAT_Po) |
            (1 << FX_UNICODE_CAT_Pi) |
            (1 << FX_UNICODE_CAT_Pf)) & (1 << _fx_char_category(ch))) != 0;
}

bool fx_isdecimal(char_ ch)
{
    return _fx_char_category(ch) == FX_UNICODE_CAT_Nd;
}

bool fx_isspace(char_ ch)
{
    return (((1 << FX_UNICODE_CAT_Zs) |
            (1 << FX_UNICODE_CAT_Zl) |
            (1 << FX_UNICODE_CAT_Zp) |
            (1 << FX_UNICODE_CAT_Zextra)) & (1 << _fx_char_category(ch))) != 0;
}

char_ fx_tolower(char_ ch)
{
    int cdata = _fx_uni_getdata(ch);
    int cat = cdata & FX_UNICODE_CAT_Mask;
    int ofs = cat == FX_UNICODE_CAT_Lu ? (cdata >> (FX_UNICODE_CAT_Shift + FX_UNICODE_BIDIR_Shift)) : 0;
    return (char_)(ch + ofs);
}

char_ fx_toupper(char_ ch)
{
    int cdata = _fx_uni_getdata(ch);
    int cat = cdata & FX_UNICODE_CAT_Mask;
    int ofs = cat == FX_UNICODE_CAT_Ll ? (cdata >> (FX_UNICODE_CAT_Shift + FX_UNICODE_BIDIR_Shift)) : 0;
    return (char_)(ch + ofs);
}

int fx_todigit(char_ ch)
{
    int cdata = _fx_uni_getdata(ch);
    int cat = cdata & FX_UNICODE_CAT_Mask;
    return cat == FX_UNICODE_CAT_Nd ? (cdata >> (FX_UNICODE_CAT_Shift + FX_UNICODE_BIDIR_Shift)) : -1;
}

int fx_bidirectional(char_ ch)
{
    int cdata = _fx_uni_getdata(ch);
    return (cdata >> FX_UNICODE_CAT_Shift) & FX_UNICODE_BIDIR_Mask;
}

bool fx_atoi(const fx_str_t* str, int_* result, int base)
{
    int_ i, len = str->length;
    int_ s = 1, r = 0;
    const char_ *ptr = str->data;
    bool ok = false;
    *result = 0;
    if(len == 0)
        return false;
    if(*ptr == '-') {
        s = -1;
        ptr++;
        if(--len == 0)
            return false;
    }
    if( base == 0 ) {
        if( ptr[0] == '0' ) {
            if(len > 2 && (ptr[1] == 'x' || ptr[1] == 'X')) {
                base = 16;
                ptr += 2;
                len -= 2;
            }
            else if(len > 2 && (ptr[1] == 'b' || ptr[1] == 'B')) {
                base = 2;
                ptr += 2;
                len -= 2;
            }
            else base = 8;
        }
        else if( fx_isdecimal(ptr[0]))
            base = 10;
        else
            return false;
    }
    else if( base < 2 || base > 36 )
        return false;

    if( base == 10 ) {
        for( i = 0; i < len; i++ ) {
            int digit = fx_todigit(ptr[i]);
            if(digit < 0)
                break;
            r = r*10 + digit;
        }
    }
    else {
        for( i = 0; i < len; i++ ) {
            char_ c = ptr[i];
            int digit = 0;
            if('0' <= c && c <= '9')
                digit = (int)(c - '0');
            else if('a' <= c && c <= 'z')
                digit = (int)(c - 'a' + 10);
            else if('A' <= c && c <= 'Z')
                digit = (int)(c - 'A' + 10);
            else
                break;
            if(digit >= base)
                break;
            r = r*base + digit;
        }
    }
    *result = r*s;
    return i == len;
}

enum {FX_MAX_ATOF=128};

bool fx_atof(const fx_str_t* str, double* result)
{
    int_ i = 0, len = str->length;
    const char_ *ptr = str->data;
    char buf[FX_MAX_ATOF+16];
    char* endptr;
    bool ok = len <= FX_MAX_ATOF;
    if (ok) {
        for(; i < len; i++) {
            char_ c = ptr[i];
            if(!(('0' <= c && c <= '9') || c == '+' || c == '-' || c == 'e' || c == 'E' || c == '.'))
                break;
            buf[i] = (char)c;
        }
        buf[i] = '\0';
    }
    ok = ok && i == len;
    if (ok) {
        *result = strtod(buf, &endptr);
        ok = ok && endptr == buf + len;
    }
    return ok;
}

int fx_itoa(int64_t n, bool nosign, fx_str_t* str)
{
    static const char* tab =
        "0001020304050607080910111213141516171819202122232425262728293031323334353637383940414243444546474849"
        "5051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899";
    int_ len = 1;
    int_ neg = nosign ? 0 : -(n < 0);

    n = (n ^ neg) - neg;
    uint64_t a = (uint64_t)n;
    if(a >= 100000000) {
        if(a >= 10000000000000000ULL) {
            a = (size_t)(a/10000000000000000ULL);
            len += 16;
            // at most 3-4 digits left, so we skip the second check for >=10**8
        }
        else {
            a /= 100000000;
            len += 8;
        }
    }
    if(a >= 10000) {
        a /= 10000;
        len += 4;
    }
    if(a >= 100) {
        a /= 100;
        len += 2;
    }
    len += a >= 10;

    int status = fx_make_str(0, len-neg, str);
    if(status < 0) return status;

    char_* buf = str->data;
    *buf = '-';
    buf -= neg;
    char_* ptr = buf + len;

    a = (uint64_t)n;
    while((ptr -= 2) >= buf) {
        uint64_t q = a / 100;
        uint64_t r = a - q*100;
        ptr[0] = (char_)tab[r*2];
        ptr[1] = (char_)tab[r*2+1];
        a = q;
    }
    if(ptr+1 == buf) buf[0] = (char_)(a + '0');
    return FX_OK;
}

int fx_substr(const fx_str_t* str, int_ start, int_ end, int_ delta, int mask, fx_str_t* substr)
{
    int_ len = FX_STR_LENGTH(*str);
    start = !(mask & 1) ? start : delta > 0 ? 0 : len-1;
    end = !(mask & 2) ? end : delta > 0 ? len : -1;
    //printf("fx_substr: start=%zd, end=%zd, delta=%zd, mask=%d, len=%zd\n", start, end, delta, mask, len);
    if (delta == 0)
        FX_FAST_THROW_RET(FX_EXN_ZeroStepError);
    if ((delta > 0 && (start < 0 || start > end || end > len)) ||
        (delta < 0 && (end < -1 || start < end || start >= len)))
        FX_FAST_THROW_RET(FX_EXN_OutOfRangeError);
    if (delta != 1)
    {
        int_ dstlen = FX_LOOP_COUNT(start, end, delta);
        if(dstlen == 0)
            return FX_OK;
        int status = fx_make_str(0, dstlen, substr);
        if(status < 0) return status;
        const char_* src = str->data;
        char_* dst = substr->data;
        for(int_ i = 0; i < dstlen; i++)
            dst[i] = src[start + i*delta];
    }
    else
    {
        if (start == end)
            return FX_OK;
        substr->rc = str->rc;
        if(str->rc) FX_INCREF(*str->rc);
        substr->data = str->data + start;
        substr->length = end - start;
    }
    return FX_OK;
}

int fx_strjoin(const fx_str_t* begin, const fx_str_t* end, const fx_str_t* sep,
               const fx_str_t* s, int_ count, fx_str_t* result)
{
    int_ seplen = sep ? sep->length : 0;
    int_ beginlen = begin ? begin->length : 0;
    int_ endlen = end ? end->length : 0;

    if(beginlen == 0 && endlen == 0) {
        if(count == 0) {
            // result should already be initialized with empty string
            return FX_OK;
        }
        if(count == 1) {
            fx_copy_str(&s[0], result);
            return FX_OK;
        }
    }
    int_ i, total = seplen*(count > 1 ? count-1 : 0);
    for( i = 0; i < count; i++ )
        total += s[i].length;
    if(begin)
        total += begin->length;
    if(end)
        total += end->length;
    int status = fx_make_str(0, total, result);
    if(status < 0) return status;

    size_t szch = sizeof(result->data[0]);
    int_ ofs = 0;
    if (beginlen) {
        memcpy(result->data, begin->data, beginlen*szch);
        ofs = beginlen;
    }
    for( i = 0; i < count; i++ ) {
        if (i > 0 && seplen > 0) {
            memcpy(result->data + ofs, sep->data, seplen*szch);
            ofs += seplen;
        }
        int_ len_i = s[i].length;
        memcpy(result->data + ofs, s[i].data, len_i*szch);
        ofs += len_i;
    }
    if (endlen) {
        memcpy(result->data + ofs, end->data, endlen*szch);
    }
    return FX_OK;
}

int fx_parse_format(const fx_str_t* str, int_ start, fx_format_t* fmt, int_* end)
{
    int_ len = str->length;
    char_* data = str->data;
    int_ pos = start;
    char_ fill = ' ', align = ' ', sign = '-';
    bool num_alt = false;
    int_ width = 0, precision = -1;
    char_ grouping = ' ', typespec = ' ';
    char_ c0 = pos < len ? data[pos] : '\0';
    char_ c1 = pos+1 < len ? data[pos+1] : '\0';
    if (c1 == '<' || c1 == '^' || c1 == '>' || c1 == '=') {
        fill = c0;
        align = c1;
        pos += 2;
    } else if (c0 == '<' || c0 == '^' || c0 == '>' || c0 == '=') {
        align = c0;
        pos++;
    }
    c0 = pos < len ? data[pos] : '\0';
    if (c0 == '+' || c0 == '-' || c0 == ' ') {
        sign = c0;
        pos++;
        c0 = pos < len ? data[pos] : '\0';
    }
    if (c0 == '#') {
        num_alt = true;
        pos++;
        c0 = pos < len ? data[pos] : '\0';
    }
    if (c0 == '0') {
        fill = '0';
        pos++;
        c0 = pos < len ? data[pos] : '\0';
    }
    while ('0' <= c0 && c0 <= '9') {
        width = width*10 + c0 - '0';
        pos++;
        c0 = pos < len ? data[pos] : '\0';
    }
    if (c0 == ',' || c0 == '_') {
        grouping = c0;
        pos++;
        c0 = pos < len ? data[pos] : '\0';
    }
    if (c0 == '.') {
        pos++;
        c0 = pos < len ? data[pos] : '\0';
        if (c0 < '0' || c0 > '9')
            return FX_SET_EXN_FAST(FX_EXN_BadArgError);
        precision = 0;
        while ('0' <= c0 && c0 <= '9') {
            precision = precision*10 + c0 - '0';
            pos++;
            c0 = pos < len ? data[pos] : '\0';
        }
    }

    if (c0 == 'd' || c0 == 'u' || c0 == 'o' || c0 == 'x' || c0 == 'X' ||
        c0 == 'f' || c0 == 'F' || c0 == 'e' || c0 == 'E' || c0 == 'g' ||
        c0 == 'G' || c0 == 's' || c0 == 'c') {
        typespec = c0;
        pos++;
    }
    fmt->fill = fill;
    fmt->align = align;
    fmt->sign = sign;
    fmt->num_alt = num_alt;
    fmt->width = width;
    fmt->precision = precision;
    fmt->grouping = grouping;
    fmt->typ = typespec;
    *end = pos;
    return FX_OK;
}

int fx_format_int(int64_t x, bool u, const fx_format_t* fmt, fx_str_t* fx_result)
{
    enum {MAX_STATIC_WIDTH=64};
    char fmtstr[16], buf[MAX_STATIC_WIDTH+16], *ptr = fmtstr, *ptr0;
    char default_typespec = u ? 'u' : 'd';
    char typespec = fmt->typ == default_typespec || fmt->typ == 'o' ||
                    fmt->typ == 'x' || fmt->typ == 'X' ? (char)fmt->typ : default_typespec;
    bool num_alt = fmt->num_alt && typespec != default_typespec;
    char_ fill = fmt->fill, align = fmt->align, sign = fmt->sign, grouping = fmt->grouping;
    int_ i, j, k, min_width, width = fmt->width, offset;
    int prefix_radix_len = typespec != default_typespec && num_alt ? 2 : 0;
    int prefix_sign_len = !u && (x < 0 || sign == '+' || sign == ' ');
    int prefix_len = prefix_radix_len + prefix_sign_len;
    int n, status;
    char_* data;
    *ptr++ = '%';
    if (grouping != ' ' && typespec != default_typespec)
        return FX_SET_EXN_FAST(FX_EXN_BadArgError);
    *ptr++ = 'l';
    *ptr++ = 'l';
    *ptr++ = (char)typespec;
    *ptr = '\0';
    if (u)
        sprintf(buf, fmtstr, (unsigned long long)x);
    else
        sprintf(buf, fmtstr, (long long)(x >= 0 ? x : -x));
    n = (int)strlen(buf);
    ptr0 = buf;
    if (*ptr0 == '-') {
        // handle +/-(1 << 63)
        ptr0++;
        n--;
    }
    ptr = ptr0;
    min_width = n + prefix_len;
    if (grouping != ' ') {
        int ngroups = (n - 1)/3;
        min_width += ngroups;
        //printf("ngroups=%d\n", ngroups);
    }
    width = width >= min_width ? width : min_width;
    status = fx_make_str(0, width, fx_result);
    if (status < 0)
        return status;

    data = fx_result->data;
    for (i = 0; i < width; i++)
        data[i] = fill;

    offset = align == '<' ? 0 : align == '^' ? (width - min_width)/2 : width - min_width;
    data += offset;
    if (prefix_sign_len > 0) {
        char s = x < 0 ? '-' : (char)sign;
        if (align == '=' || fill == '0') {
            fx_result->data[0] = s;
            data++;
        }
        else
            *data++ = s;
    }
    if (prefix_radix_len > 0) {
        *data++ = '0';
        *data++ = (char)typespec;
    }

    if (grouping == ' ') {
        if (align == ' ' && align == '>')
            data = fx_result->data + (width - n);
        for (i = 0; i < n; i++)
            data[i] = ptr[i];
    } else {
        int_ left = data - fx_result->data;
        //printf("min_width-prefix_len=%d\n", (int)(min_width - prefix_len));
        int_ i = align == ' ' || align == '>' || align == '=' ? width-1 : left + min_width - prefix_len - 1;
        int_ j = n - 1, rest;
        data = fx_result->data;
        left++;
        for (; i > left && j >= 3; i -= 4, j -= 3) {
            data[i] = ptr0[j];
            data[i-1] = ptr0[j-1];
            data[i-2] = ptr0[j-2];
            data[i-3] = (char)grouping;
        }
        rest = j+1;
        for (; j >= 0; j--, i--)
            data[i] = ptr0[j];
        if ((align == ' ' || align == '=') && fill == '0') {
            i -= 3 - rest;
            for (; i > left; i -= 4)
                data[i] = (char)grouping;
        }
    }
    return FX_OK;
}

int fx_format_flt(double x, int_ default_precision, const fx_format_t* fmt, fx_str_t* fx_result)
{
    enum {MAX_STATIC_WIDTH=1024};
    char fmtstr[32], buf[MAX_STATIC_WIDTH+16], *ptr = fmtstr;
    char typespec = fmt->typ == 'f' || fmt->typ == 'F' ||
                    fmt->typ == 'e' || fmt->typ == 'E' ||
                    fmt->typ == 'g' || fmt->typ == 'G' ? (char)fmt->typ : 'g';
    bool num_alt = fmt->num_alt && typespec != 'd';
    char_ fill = fmt->fill, align = fmt->align, sign = fmt->sign, grouping = fmt->grouping;
    int_ i, j, k, min_width, width = fmt->width, offset;
    int prefix_sign_len = x < 0 || sign == '+' || sign == ' ';
    int prefix_len = prefix_sign_len;
    int precision = fmt->precision >= 0 ? fmt->precision :
                    default_precision >= 0 ? default_precision : 8;
    int n = 0, status;
    char_* data;
    *ptr++ = '%';
    if (precision >= 0) {
        if (precision > MAX_STATIC_WIDTH/2) {
            return FX_SET_EXN_FAST(FX_EXN_SizeError);
        }
        *ptr++ = '.';
        sprintf(ptr, "%d%n", precision, &n);
        ptr += n;
        n = 0;
    }
    *ptr++ = (char)typespec;
    *ptr = '\0';
    {
    fx_bits64_t u;
    u.f = x;
    if ((u.i & 0x7FF0000000000000LL) != 0x7FF0000000000000LL)
        sprintf(buf, fmtstr, x >= 0 ? x : -x);
    else
        strcpy(buf, (u.i & 0xfffffffffffffLL) != 0 ? "nan" : "inf");
    }
    n = strlen(buf);
    ptr = buf;
    min_width = n + prefix_len;
    if (grouping != ' ') {
        int ngroups = (n - 1)/3;
        min_width += ngroups;
        //printf("ngroups=%d\n", ngroups);
    }
    width = width >= min_width ? width : min_width;
    status = fx_make_str(0, width, fx_result);
    if (status < 0)
        return status;

    data = fx_result->data;
    for (i = 0; i < width; i++)
        data[i] = fill;

    offset = align == '<' ? 0 : align == '^' ? (width - min_width)/2 : fill == '0' ? 0 : width - min_width;
    data = data + offset;
    if (prefix_sign_len > 0) {
        char s = *ptr == 'n' ? ' ' : x < 0 ? '-' : (char)sign;
        *data++ = s;
    }

    if (align == ' ' && align == '>')
        data = fx_result->data + (width - n);
    for (i = 0; i < n; i++)
        data[i] = ptr[i];
    return FX_OK;
}

int fx_format_str(const fx_str_t* x, const fx_format_t* fmt, fx_str_t* fx_result)
{
    int_ n = x->length;
    int_ i, width = fmt->width, offset;
    width = width > n ? width : n;
    int status = fx_make_str(0, width, fx_result);
    char_ fill = fmt->fill, align = fmt->align;
    char_ *x_data = x->data, *data;
    if (status < 0)
        return status;
    data = fx_result->data;
    offset = align == '>' ? width - n : align == '^' ? (width - n)/2 : 0;
    for (i = 0; i < offset; i++)
        data[i] = fill;
    for (i = 0; i < n; i++)
        data[offset + i] = x_data[i];
    for (i = offset + n; i < width; i++)
        data[i] = fill;
    return FX_OK;
}

#ifdef __cplusplus
}
#endif

#endif
