package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/robfig/cron/v3"
)

func main() {
	c := cron.New()

	// Add a cron job to run every minute
	_, err := c.AddFunc("@every 3s", func() {
		// Call the API endpoint
		err := callSimpleAPI()
		if err != nil {
			log.Printf("API monitoring failed: %s", err)
		} else {
			log.Println("API monitoring successful")
		}
	})
	if err != nil {
		log.Fatalf("Failed to add cron job: %s", err)
	}

	// Start the cron scheduler
	c.Start()

	// Keep the program running
	select {}
}

func callSimpleAPI() error {
	// Make an HTTP GET request to the API endpoint
	resp, err := http.Get("https://www.google.com/")
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	// Check the response status code
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("API returned a non-200 status code: %d", resp.StatusCode)
	}

	return nil
}
