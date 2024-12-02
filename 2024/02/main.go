package main

import (
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
)

type input [][]int

func parseInput(filename string) (in input, err error) {
	lines, err := readLines(filename)
	if err != nil {
		return
	}

	for _, line := range lines {
		in = append(in, parseLine(line))
	}

	return
}

func readLines(filename string) ([]string, error) {
	c, err := os.ReadFile(filename)
	if err != nil {
		return nil, err
	}
	return strings.Split(strings.TrimSpace(string(c)), "\n"), nil
}

func parseLine(line string) (p []int) {
	l := strings.Fields(line)
	for _, s := range l {
		n, _ := strconv.Atoi(s)
		p = append(p, n)

	}
	return
}

func parseLines(lines []string) (inp input) {
	for _, l := range lines {
		inp = append(inp, parseLine(l))
	}
	return inp
}

func between(diff, min, max int) bool {
	return min <= diff && diff <= max
}

func isSafe(report []int) bool {
	isGrowing := report[0] < report[1]

	for i := 1; i < len(report); i++ {
		diff := report[i] - report[i-1]
		switch {
		case diff == 0:
			return false
		case isGrowing && !between(diff, 1, 3):
			return false
		case !isGrowing && !between(diff, -3, -1):
			return false
		}
	}

	return true
}

func remove(s []int, pos int) []int {
	s2 := make([]int, len(s)-1)
	copy(s2, s[0:pos])
	copy(s2[pos:], s[pos+1:])
	return s2
}

func part1(in input) (out int, err error) {
	for _, report := range in {
		if isSafe(report) {
			out++
		}
	}

	return
}

func part2(in input) (out int, err error) {
	for _, report := range in {
		safe := isSafe(report)
		if safe {
			out++
			continue
		}

		for i := 0; i < len(report); i++ {
			if isSafe(remove(report, i)) {
				out++
				break
			}
		}
	}

	return
}

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintf(os.Stderr, "Usage main INPUT\n")
		os.Exit(1)
	}

	input, err := parseInput(os.Args[1])
	if err != nil {
		return
	}

	n1, err := part1(input)
	if err != nil {
		log.Fatalln(err)
	}

	fmt.Printf("Part 1: %d\n", n1)

	n2, err := part2(input)
	if err != nil {
		log.Fatalln(err)
	}

	fmt.Printf("Part 2: %d\n", n2)
}
