package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var env string
var env_set bool
var body string

func index(w http.ResponseWriter, req *http.Request) {
	fmt.Fprint(w, body)
}

func health(w http.ResponseWriter, req *http.Request) {
	if env_set {
		fmt.Fprintf(w, "{\"status\": \"ok\"}")
	} else {
		http.Error(w, "{\"status\": \"unhealthy\"}", http.StatusInternalServerError)
	}
}

func liveness(w http.ResponseWriter, req *http.Request) {
	fmt.Fprintf(w, "{\"status\": \"ok\"}")
}

func main() {
	port, port_set := os.LookupEnv("LISTEN_PORT")
	if !port_set {
		port = "8080"
	}

	address := os.Getenv("LISTEN_ADDRESS")
	listen_on := fmt.Sprintf("%s:%s", address, port)

	env, env_set = os.LookupEnv("ENVIRONMENT")
	if !env_set {
		log.Println("WARN: 'ENVIRONMENT' is not set")
		body = "Error: environment is not set. Please set the 'ENVIRONMENT' environment variable with the environment name"
	} else {
		log.Println("'ENVIRONMENT' is set to", env)
		body = fmt.Sprintf("<html><head><title>SIGHUP Kubernetes Engineer Test</title></head><body><p>running on <strong>%s</strong> environment</p></body></html>\n", env)
	}

	log.Println("registering endpoint: /")
	http.HandleFunc("/", index)
	log.Println("registering endpoint: /metrics")
	http.Handle("/metrics", promhttp.Handler())
	log.Println("registering endpoint: /health")
	http.HandleFunc("/health", health)
	log.Println("registering endpoint: /liveness")
	http.HandleFunc("/liveness", liveness)

	log.Printf("server listening on: '%s'", listen_on)
	log.Fatal(http.ListenAndServe(listen_on, nil))
}
