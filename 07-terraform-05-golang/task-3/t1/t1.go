package main

import "fmt"

func main() {
	fmt.Print("Enter a number: ")
	var input float64
	fmt.Scanf("%f", &input)

	fmt.Println(FeetToMeters(input))

}

func FeetToMeters(input float64) float64 {
	return input * 0.3048
}
