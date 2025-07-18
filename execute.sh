#!/usr/bin/bash

# Check if an argument was provided
if [ $# -eq 0 ]; then
    echo "Error: No test specified"
    echo "Usage: $0 [tensors|views|intlist|shapes|all]"
    exit 1
fi

# Determine which test to run based on the argument
case $1 in
    tensors)
        mojo -I . tests/test_tensors.mojo
        ;;
    views)
        echo "Running view test cases"
        mojo -I . tests/test_views.mojo
        ;;
    shapes)
        echo "Running shape test cases"
        mojo -I . tests/test_shapes.mojo
        ;;

    intlist)
        mojo -I . tests/test_intlist.mojo
        ;;
    all)
        mojo -I . tests/test_tensors.mojo
        echo "Running view test cases"
        mojo -I . tests/test_views.mojo
        echo "Running shape test cases"
        mojo -I . tests/test_shapes.mojo
        mojo -I . tests/test_intlist.mojo
        ;;
    *)
        echo "Error: Unknown test '$1'"
        echo "Available tests: tensors, views, shapes, intlists, all"
        exit 1
        ;;
esac
