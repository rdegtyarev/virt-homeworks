package main

import "testing"

func TestDivisibleByThree(t *testing.T) {
	x := []int{3, 1, 9, 2, 12}
	y := []int{3, 9, 12}
	var arr []int

	for _, i := range x {
		if DivisibleByThree(i) {
			arr = append(arr, i)
		}

	}

	if arr[0]!=y[0] || arr[1]!=y[1] || arr[2]!=y[2] {
		t.Error("Expected 3 9 12, got ", arr)
	}
}
