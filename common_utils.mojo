from shapes import Shape
from tensors import Tensor
from testing import assert_true
from sys.param_env import env_get_string
from logger import Level, Logger
from intlist import IntList


alias log = Logger[Level._from_str(env_get_string["LOGGING_LEVEL", "INFO"]())]()


fn log_debug(msg: String):
    log.debug(msg)


fn log_info(msg: String):
    log.info(msg)


fn log_warning(msg: String):
    log.warning(msg)


# Helper
def do_assert[
    dtype: DType, //
](a: Tensor[dtype], b: Tensor[dtype], msg: String):
    shape_mismatch = String("{0}: shape mismatch {1} vs {2}")
    tensors_not_equal = String("{}: values mismatch")
    assert_true(
        a.shape == b.shape, shape_mismatch.format(msg, a.shape, b.shape)
    )
    assert_true((a == b).all_true(), tensors_not_equal.format(msg))


# Helper
def assert_grad[
    dtype: DType, //
](t: Tensor[dtype], expected: Tensor[dtype], label: String):
    assert_true(
        (t.grad[] == expected).all_true(),
        String("grad assertion failed for {0}").format(label),
    )


fn variadiclist_as_str(list: VariadicList[Int]) -> String:
    s = String("[")
    for idx in range(len(list)):
        s += list[idx].__str__()
        if idx != len(list) - 1:
            s += ", "
    s += "]"
    return s


# Convert a VariadicList to List
fn variadiclist_as_intlist(vlist: VariadicList[Int]) -> IntList:
    list = IntList.with_capacity(capacity=len(vlist))
    for each in vlist:
        list.append(each)
    return list^


# Create a single element VariadicList
fn piped(m: Int, n: Int = -1) -> VariadicList[Int]:
    fn create_variadic_list(*elems: Int) -> VariadicList[Int]:
        return elems

    if n == -1:
        return create_variadic_list(m)
    return create_variadic_list(m, n)


# Get next power of 2 for n
fn next_power_of_2(n: Int) raises -> Int:
    assert_true(n > 0, "Next power of 2 is supported for >= 1")
    if n.is_power_of_two():
        return n
    if n == 1:
        return 1
    var power = 1
    while power < n:
        power *= 2
    return power


from os import Atomic
from memory import UnsafePointer


@fieldwise_init
struct IdGen:
    var tensor_ids: UnsafePointer[UInt64]

    fn __init__(out self):
        self.tensor_ids = UnsafePointer[UInt64].alloc(1)

    fn __copyinit__(out self, existing: Self):
        self.tensor_ids = existing.tensor_ids

    fn __enter__(mut self) -> Self:
        self.tensor_ids[] = 0
        return self

    fn __exit__(mut self):
        print("Exiting IdGen")

    fn next(self) -> UInt64:
        return Atomic.fetch_add(self.tensor_ids, 1)


fn main() raises:
    a = Tensor.of(1, 2, 3)
    b = Tensor.of(2)
    do_assert(a, b, "boom")
