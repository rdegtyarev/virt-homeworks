package main

import "testing"

func TestFindLess(t *testing.T) {
	x := []int{3, 1, 2, 2, 4}
	v := FindLess(x)
	if v != 1 {
		t.Error("Expected 1, got ", v)
	}
}
