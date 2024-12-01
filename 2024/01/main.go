package main

import (
	"fmt"
	"log"
	"os"
	"slices"
	"strconv"
	"strings"
)

type input [][]int

func readLines(filename string) ([]string, error) {
    c, err := os.ReadFile(filename)
    if err != nil {
        return nil, err
    }
    return strings.Split(strings.TrimSpace(string(c)), "\n"), nil
}

func parseLine(line string) []int {
    l := strings.Fields(line)
    n1, _ := strconv.Atoi(l[0])
    n2, _ := strconv.Atoi(l[1])
    return []int{n1, n2}
}

func parseLines(lines []string) (inp input) {
    for _, l := range lines {
        inp = append(inp, parseLine(l))
    }
    return inp
}

func part1(in input) (out int, err error) {
    l1 := make([]int, len(in))
    l2 := make([]int, len(in))

    for i, p := range in {
        l1[i] = p[0]
        l2[i] = p[1]
    }

    slices.Sort(l1)
    slices.Sort(l2)

    for i := range l1 {
        diff := l2[i] - l1[i]
        if diff < 0 {
            diff = -diff
        }
        out += diff
    }
    
    return
}

func part2(in input) (out int, err error) {
    m2 := make(map[int]int)

    for _, p := range in {
        m2[p[1]] = m2[p[1]] + 1
    }

    for _, p := range in {
        out += p[0] * m2[p[0]]
    }

    return
}

func main() {
    if len(os.Args) < 2 {
        fmt.Fprintf(os.Stderr, "Usage main INPUT\n")
        os.Exit(1)
    }

    lines, err := readLines(os.Args[1])
    if err != nil {
        return
    }

    input := parseLines(lines)

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


