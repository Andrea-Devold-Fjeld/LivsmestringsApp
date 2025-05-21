package main

import (
	"context"
	_ "embed"
	"encoding/json"
	"fmt"
	"github.com/go-chi/chi/v5"
	"log"
	"net/http"
	"os/signal"
	"syscall"
	"time"
)

//go:embed career.json
var career []byte

//go:embed health.json
var health []byte

func main() {
	ctx := context.Background()
	ctx, ccl := signal.NotifyContext(ctx, syscall.SIGINT, syscall.SIGTERM)
	defer ccl()

	var categories = []string{"career", "health"}
	var categoryVideoMap = map[string][]byte{categories[0]: career, categories[1]: health}

	r := chi.NewRouter()
	r.Get("/categories", CategoryListHandler(categories))
	r.Get("/{categoryName}", VideoListHandler(categoryVideoMap))

	srv := http.Server{
		Addr:    ":8080",
		Handler: r,
	}

	go func() {
		fmt.Println("Server is running at http://localhost:8080")
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("listen: %s\n", err)
		}
	}()

	<-ctx.Done()
	shutdownCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	fmt.Println("Server is shutting down at http://localhost:8080")

	if err := srv.Shutdown(shutdownCtx); err != nil {
		log.Fatalf("Server shutdown failed: %s", err)
	}
	fmt.Println("Server exiting")
}

func CategoryListHandler(categories []string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		res, err := json.Marshal(categories)
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		if _, err = w.Write(res); err != nil {
			log.Printf("Error writing response: %v", err)
		}
	}
}

func VideoListHandler(categories map[string][]byte) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var payload Comb
		category := chi.URLParam(r, "categoryName")

		data, ok := categories[category]
		fmt.Printf("ok %v\n", ok)
		if ok {
			if err := json.Unmarshal(data, &payload); err != nil {
				fmt.Printf("Error unmarshalling payload: %v\n", err)
				w.WriteHeader(http.StatusBadRequest)
				return
			}

			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusOK)

			if err := json.NewEncoder(w).Encode(payload); err != nil {
				log.Printf("Error writing response: %v", err)
			}
			return
		}

		w.WriteHeader(http.StatusNotFound)
		return
	}
}

type Comb struct {
	Category string    `json:"Category"`
	Chapters []Chapter `json:"Chapters"`
}

type Chapter struct {
	Title  string  `json:"Title"`
	Videos []Video `json:"Videos"`
}

type Video struct {
	Title        string            `json:"Title"`
	LanguageUrls map[string]string `json:"LanguageUrls"`
	Tasks        []Task            `json:"Tasks,omitempty"`
}

type Task struct {
	Title        string            `json:"Title"`
	LanguageUrls map[string]string `json:"LanguageUrls"`
}
