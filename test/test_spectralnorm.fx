/*
    This file is a part of ficus language project.
    See ficus/LICENSE for the licensing terms
*/

// spectralnorm.fx example converted into a test

from UTest import *
import Math

TEST("spectralnorm.N=100", fun() {

fun A(i: int, j: int)
{
    val i = double(i), j = double(j)
    1. / ((i + j) * (i + j + 1) / 2. + i + 1)
}

fun Au(u: double[])
{
    val N = size(u)

    [for i <- 0:N {
        fold t = 0. for j <- 0:N {
            t + A(i, j) * u[j]
        }
    }]
}

fun Atu(u: double[])
{
    val N = size(u)

    [for i <- 0:N {
        fold t = 0. for j <- 0:N {
            t + A(j, i) * u[j]
        }
    }]
}

fun AtAu(u: double[]) = Atu(Au(u))

fun spectralnorm(n: int)
{
    val fold (u, v) = (array(n, 1.), array(0, 0.))
        for i <- 0:10 { val v = AtAu(u); (AtAu(v), v) }
    val fold (vBv, vv) = (0., 0.)
        for ui <- u, vi <- v { (vBv + ui*vi, vv + vi*vi) }
    sqrt(vBv/vv)
}

var N = 100
EXPECT_NEAR(`spectralnorm(N)`, 1.274219991234931, 1e-6)
})
