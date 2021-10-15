package main

import (
	"fmt"
	"time"
)

type spinner struct {
	done chan bool
	msg  string
}

func new_spinner(msg string) *spinner {
	done := make(chan bool, 1)
	return &spinner{done, msg}
}

func (s *spinner) start() {

	go func() {
		i := 0

		state := []string{"   ", ".  ", ".. ", "..."}

		for {
			select {
			case <-s.done:
				fmt.Printf("\r%s... %s\n", s.msg, "Done")
				return
			default:

				fmt.Printf("\r%s%s", s.msg, state[i])
				i++
				if i == 4 {
					i = 0
				}

			}
			time.Sleep(time.Millisecond * 200)
		}
	}()

}

func (s *spinner) stop() {
	s.done <- true
	time.Sleep(time.Millisecond * 250)
}

func (s *spinner) self_destruct() {
	close(s.done)
}
