package main

import "testing"

func TestFeetToMeters(t *testing.T) {
	var v float64
	v = FeetToMeters(1.0)
	if v != 0.3048 {
		t.Error("Expected 0.3048, got ", v)
	}
}
