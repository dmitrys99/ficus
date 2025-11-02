// compile:ok
// params:-no-preamble

exception Fail: string

fun foo() = throw Fail("foo")
fun bar() {
  throw Fail("bar")
}

fun foo1(): void = throw Fail("foo1")
fun bar1(): void {
  throw Fail("bar1")
}
