package main

import (
	"encoding/json"
	"fmt"
	"github.com/robfig/cron/v3"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/exec"
)

type Agent struct {
	ID            string `json:"id"`
	InstallScript string `json:"installScript"`
}

type Data struct {
	Agents []Agent `json:"agents"`
}

type APIResponse struct {
	AgentsList []AgentsToBeUpdated `json:"agents_to_be_updated"`
}

type AgentsToBeUpdated struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

func main() {
	c := cron.New()

	// Add a cron job to run every minute
	_, err := c.AddFunc("@every 60s", func() {
		// Call the API endpoint
		err := callAPI()
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

func callAPI() []byte {
	// Make an HTTP GET request to the API endpoint
	response, err := http.Get("http://54.152.4.189:8000/agents-to-update/MzE0MDA4fEFQTXxBUFBMSUNBVElPTnwzNjAyNjk1MQ")
	if err != nil {
		return nil
	}
	defer response.Body.Close()

	body, err := ioutil.ReadAll(response.Body)
	if err != nil {
		return nil
	}

	var resp APIResponse
	err = json.Unmarshal(body, &resp)
	if err != nil {
		log.Fatal(err)
	}

	// Load the custom JSON file
	file, err := os.Open("agent-info.json")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	// Decode the JSON data from the custom file
	var data Data
	decoder := json.NewDecoder(file)
	err = decoder.Decode(&data)
	if err != nil {
		log.Fatal(err)
	}

	// Compare the ID from the API response with the custom JSON file
	found := false
	for _, agent := range data.Agents {
		for _, agentTobeUpdated := range resp.AgentsList {

			if agentTobeUpdated.ID == agent.ID {
				fmt.Printf("Agent Information %s available, Ready to Install ! \n", agentTobeUpdated.ID)
				found = true
				fmt.Printf("Installing updates ... \n")

				cmd := exec.Command("bash", "-c", agent.InstallScript)
				err := cmd.Run()
				if err != nil {
					log.Fatal(err)
				}
				fmt.Printf("Install Script Ran successfully \n")
				break
			}
		}
	}

	if !found {
		fmt.Printf("No match found for Agent ID")
	}

	return nil
}
