package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"time"
)

func main() {
	london, err := time.LoadLocation("Europe/London")
	if err != nil {
		log.Fatalf("Failed reading location: %v\n", err)
	}
	t := time.Now()
	fmt.Printf("Time in London now: %v\n", t.In(london))
	fiveMin, err := time.ParseDuration("5m")
	if err != nil {
		log.Fatalf("Failed to parse duration: %v\n", err)
	}
	fiveMinLater := t.Add(fiveMin)
	fiveMinLaterInLndn := fiveMinLater.In(london)
	fmt.Printf("Will be setting the new cron expression to %v\n", fiveMinLaterInLndn)

	// using %d formatter for the month value gives the numeric value of the month needed for cron expression
	c := fmt.Sprintf("%v %v %v %d *", fiveMinLaterInLndn.Minute(), fiveMinLaterInLndn.Hour(), fiveMinLaterInLndn.Day(), fiveMinLaterInLndn.Month())
	b := []byte(c)
	ioutil.WriteFile("cron.txt", b, 0644)
}
