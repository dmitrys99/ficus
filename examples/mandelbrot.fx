import Args
import File

val N = match Args.arguments() {
    | n_str :: [] => getOpt(atoi(n_str), 16000)
    | _ => 16000
    }

val w = N, h = N, MAX_ITER = 50
val inv = 2.0 / w

type vec8d = (8 * double)
operator + (a: vec8d, b: vec8d) = (a.0+b.0, a.1+b.1, a.2+b.2, a.3+b.3, a.4+b.4, a.5+b.5, a.6+b.6, a.7+b.7)
operator - (a: vec8d, b: vec8d) = (a.0-b.0, a.1-b.1, a.2-b.2, a.3-b.3, a.4-b.4, a.5-b.5, a.6-b.6, a.7-b.7)
operator .* (a: vec8d, b: vec8d) = (a.0*b.0, a.1*b.1, a.2*b.2, a.3*b.3, a.4*b.4, a.5*b.5, a.6*b.6, a.7*b.7)
type bool8 = (bool * 8)
operator .> (a: vec8d, d: double) = (a.0 > d, a.1 > d, a.2 > d, a.3 > d, a.4 > d, a.5 > d, a.6 > d, a.7 > d)
operator | (a: bool8, b: bool8) = (a.0 | b.0, a.1 | b.1, a.2 | b.2, a.3 | b.3,
                              a.4 | b.4, a.5 | b.5, a.6 | b.6, a.7 | b.7)
fun all(a: bool8) = a.0 & a.1 & a.2 & a.3 & a.4 & a.5 & a.6 & a.7

val x_ = [parallel for x <- 0:w {(x :> double) * inv - 1.5}]
val result: int8 [,] = [
    parallel
        for y <- 0:h
            for x8 <- 0:(w/8)
    {
        val y_ = (y :> double) * inv - 1.0
        val x = x8*8
        val cr = (x_[x + 0], x_[x + 1], x_[x + 2], x_[x + 3], x_[x + 4], x_[x + 5], x_[x + 6], x_[x + 7])
        val ci = (y_, y_, y_, y_, y_, y_, y_, y_)
        var zr = cr, zi = ci
        var bits = (false, false, false, false, false, false, false, false)

        for iter <- 0:MAX_ITER
        {
            val rr = zr .* zr
            val ii = zi .* zi

            val mag = rr + ii
            bits |= mag .> 4.0

            val ir = zr .* zi
            zr = (rr - ii) + cr
            zi = (ir + ir) + ci

            if all(bits) {break}
        }
        val mask = (bits.0 << 7) + (bits.1 << 6) + (bits.2 << 5) + (bits.3 << 4) +
            (bits.4 << 3) + (bits.5 << 2) + (bits.6 << 1) + (bits.7 << 0)

        ((mask ^ 255) :> int8)
    }
]

val f: File.file_t = File.open("result.pgm", "wb")
File.print(f, f"P4\n{w} {h}\n")
File.write(f, result)
File.close(f)