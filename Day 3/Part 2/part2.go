package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

func main() {
	file, _ := os.Open("input.txt")
	defer file.Close()

	myList := []string{}
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		myList = append(myList, scanner.Text())
	}

	// part 1
	oxygen := oxygen(myList)
	oxygenDec, _ := strconv.ParseInt(oxygen, 2, 16)

	// part 2
	scrubber := co2Scrubber(myList)
	scrubberDec, _ := strconv.ParseInt(scrubber, 2, 16)

	fmt.Printf("oxygen %v (%v)", oxygen, oxygenDec)
	fmt.Println()
	fmt.Printf("co2scrubber %v (%v)", scrubber, scrubberDec)
	fmt.Println()
	fmt.Printf("result: %v", scrubberDec*oxygenDec)
}

func oxygen(listToRazor []string) string {
	return razorStrategy(listToRazor, true, true)
}

func co2Scrubber(listToRazor []string) string {
	return razorStrategy(listToRazor, false, false)
}

func razorStrategy(listToRazor []string, keepMajority bool, useOneIfEqual bool) string {
	position := 0

	for len(listToRazor) > 1 {
		countOfOnes := getCountOfMatches(position, true, listToRazor)
		countOfZeroes := len(listToRazor) - countOfOnes

		listToRazor = filter(listToRazor, countOfOnes, countOfZeroes, position, keepMajority, useOneIfEqual)

		position++
	}

	return listToRazor[0]
}

func filter(listToFilter []string, countOfOnes int, countOfZeroes int, position int, keepMajority bool, useOneIfEqual bool) []string {
	if countOfOnes > countOfZeroes {
		if keepMajority {
			return filterList(listToFilter, true, position)
		} else {
			return filterList(listToFilter, false, position)
		}
	}

	if countOfZeroes > countOfOnes {
		if keepMajority {
			return filterList(listToFilter, false, position)
		} else {
			return filterList(listToFilter, true, position)
		}
	}

	//countOfOnes == countOfZeroes
	if useOneIfEqual {
		return filterList(listToFilter, true, position)
	} else {
		return filterList(listToFilter, false, position)
	}
}

func filterList(listToFilter []string, valToFilter bool, position int) []string {
	filteredList := []string{}

	for _, element := range listToFilter {
		if valToFilter && getCharAtPosition(element, position) == "1" {
			filteredList = append(filteredList, element)
			continue
		}
		if !valToFilter && getCharAtPosition(element, position) == "0" {
			filteredList = append(filteredList, element)
		}
	}

	return filteredList
}

func getCountOfMatches(position int, val bool, listToSearch []string) int {
	count := 0
	for _, element := range listToSearch {
		subString := getCharAtPosition(element, position)
		if val == true && subString == "1" {
			count++
			continue
		}
		if val == false && subString == "0" {
			count++
		}
	}
	return count
}

func getCharAtPosition(text string, position int) string {
	chars := []rune(fmt.Sprintf("%v", text))
	subString := string(chars[position : position+1])
	return subString
}
