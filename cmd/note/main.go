package main

import (
	"fmt"
	"os"
)

func Run(args []string) int {
	if len(args) == 0 {
		fmt.Print(usageText)
		return 0
	}
	var err error
	switch args[0] {
	case "-h", "--help", "help":
		fmt.Print(usageText)
		return 0
	case "context":
		notes, readErr := openNotes()
		err = readErr
		if err == nil {
			fmt.Print(renderOpen(notes))
		}
	case "add":
		err = cmdAdd(args[1:])
	case "answer":
		err = cmdAnswer(args[1:])
	case "list":
		err = cmdList(args[1:])
	case "clear":
		err = cmdClear(args[1:])
	case "path":
		err = cmdPath(args[1:])
	default:
		err = die("unknown subcommand '%s'", args[0])
	}
	if err != nil {
		fmt.Fprintf(os.Stderr, "note: %s\n", err)
		return 1
	}
	return 0
}

func main() { os.Exit(Run(os.Args[1:])) }
