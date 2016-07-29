package main

import (
	"fmt"
	"time"
)

var c chan int

func main() {
	c = make(chan int)

	go func() {
		for {
			/* Note that
			Execution of a "select" statement proceeds in several steps:

			For all the cases in the statement, the channel operands of receive operations and the channel and right-hand-side expressions of send statements are evaluated exactly once, in source order, upon entering the "select" statement. The result is a set of channels to receive from or send to, and the corresponding values to send. Any side effects in that evaluation will occur irrespective of which (if any) communication operation is selected to proceed. Expressions on the left-hand side of a RecvStmt with a short variable declaration or assignment are not yet evaluated.
			If one or more of the communications can proceed, a single one that can proceed is chosen via a uniform pseudo-random selection. Otherwise, if there is a default case, that case is chosen. If there is no default case, the "select" statement blocks until at least one of the communications can proceed.
			Unless the selected case is the default case, the respective communication operation is executed.
			If the selected case is a RecvStmt with a short variable declaration or an assignment, the left-hand side expressions are evaluated and the received value (or values) are assigned.
			The statement list of the selected case is executed.
			*/
			select {
			case c <- 0:
			case c <- 1:
			case c <- 2:
			case c <- 3:
			case c <- 4:
			case c <- 5:
			}
		}
	}()

	for {
		rc := <-c
		fmt.Print(rc)
		time.Sleep(1 * time.Millisecond)
	}
}
