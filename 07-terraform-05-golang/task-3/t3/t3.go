package main

import (
	"fmt"
)

func main() {

	var arr []int

	for i := 1; i < 101; i++ {
		if DivisibleByThree(i) {
			arr = append(arr, i)
		}

	}
	fmt.Println(arr)
}

func DivisibleByThree(i int) bool {
	var result bool
		if i%3 == 0 {
			result = true
		} else {
			result = false
		}

	return result
}

