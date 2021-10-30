package main

import (
	"fmt"
)

func main() {
	x := []int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17}
	fmt.Println(FindLess(x))
}

func FindLess(input []int) int {
	var result int
	result = input[0]
	for _, x := range input {
		if result > x {
			result = x
		}
	}
	return result
}
