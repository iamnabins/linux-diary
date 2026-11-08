#!/bin/bash

func() {
    local n=$1 result=1
    for ((k=1; k<=n; k++))
    do
        result=$((result*k))
    done
    echo $result
}
echo $(func 5)