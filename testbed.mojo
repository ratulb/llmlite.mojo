from tensors import Tensor
from intlist import IntList
from shapes import Shape
from os import abort

fn main() raises:
    tensor = Tensor.rand(2, 3, 4, 5, 6, init_seed=Optional(42))
    tensor.print()
    print()
    summed = sum(tensor, axes=[1, 3], keepdim=True)
    summed.print()


fn sum[
    dtype: DType = DType.float32
](tensor: Tensor[dtype], axes: List[Int], keepdim: Bool = False) -> Tensor[
    dtype
]:
    input_shape = tensor.shape
    input_rank = input_shape.rank()
    sorted_axes = IntList.new(axes).sorted()
    for ax in sorted_axes:
        if ax < 0 or ax >= input_rank:
            abort("Invalid axis in sum: " + String(ax))

    spans = IntList.with_capacity(input_rank)
    for i in range(input_rank):
        if i in sorted_axes:
            if keepdim:
                spans.append(1)
            else:
                continue
        else:
            spans.append(input_shape[i])

    out_shape = Shape(spans)

    var out = Tensor[dtype].zeros(out_shape, requires_grad=tensor.requires_grad)

    red_shape = Shape(input_shape.axes_spans.select(sorted_axes))

    for out_idx in out.shape:
        var sum_val = Scalar[dtype](0)

        for red_idx in red_shape:
            if keepdim:
                full_idx = out_idx.replace(sorted_axes, red_idx)
            else:
                full_idx = out_idx.insert(sorted_axes, red_idx)

            sum_val += tensor[full_idx]

        out[out_idx] = sum_val

    return out
