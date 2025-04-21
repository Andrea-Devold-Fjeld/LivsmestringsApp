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
)

//TIP <p>To run your code, right-click the code and select <b>Run</b>.</p> <p>Alternatively, click
// the <icon src="AllIcons.Actions.Execute"/> icon in the gutter and select the <b>Run</b> menu item from here.</p>
/*
//go:embed carrer.json
var carrerFile []byte

//go:embed health.json
var healthFile []byte
*/
//go:embed viedos.json
var videos []byte

func main() {
	ctx := context.Background()
	ctx, ccl := signal.NotifyContext(ctx, syscall.SIGINT, syscall.SIGTERM)
	defer ccl()

	r := chi.NewRouter()
	//r.Get("/{category}", DataHandler)
	r.Get("/video", VideoHandler)

	fmt.Println("Server is running at http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", r))
}

func VideoHandler(w http.ResponseWriter, r *http.Request) {
	var payload VideoUrls

	err := json.Unmarshal(videos, &payload)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
	}
	res, err := json.Marshal(payload)
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if _, err = w.Write(res); err != nil {
		log.Printf("Error writing response: %v", err)
	}

}

/*
func DataHandler(w http.ResponseWriter, r *http.Request) {
	category := chi.URLParam(r, "category")
	var payload Data

	switch category {
	case "career":
		err := json.Unmarshal(carrerFile, &payload)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			log.Fatal("Error during Unmarshal(): ", err)
		}

	case "health":
		err := json.Unmarshal(healthFile, &payload)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			log.Fatal("Error during Unmarshal(): ", err)
		}
	default:
		w.WriteHeader(http.StatusNotFound)
		return
	}

	res, err := json.Marshal(payload)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		log.Printf("Error during Marshal(): %v", err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if _, err = w.Write(res); err != nil {
		log.Printf("Error writing response: %v", err)
	}
}

*/

type Data struct {
	Chapters []struct {
		Title  string `json:"Title"`
		Videos []struct {
			Title string `json:"Title"`
			URL   string `json:"Url"`
			Tasks []struct {
				Title string `json:"Title"`
				URL   string `json:"Url"`
			}
		}
	}
}

// VideoResponse is the top-level structure for the JSON response
// Struct to represent the video URL data for each video
type Task struct {
	Title string            `json:"Title"`
	Url   map[string]string `json:"Url"`
}

type Video struct {
	Title string            `json:"Title"`
	Url   map[string]string `json:"Url"`
	Tasks *Task             `json:"Tasks,omitempty"` // Use pointer to allow null/missing
}

type VideoUrls struct {
	VideoUrls []Video `json:"VideoUrls"`
}

// LanguageURL represents a single language option for a video
type LanguageURL struct {
	Language string `json:"Language"`
	URL      string `json:"Url"`
}

type Comb struct {
	Category string `json:"Category"`
	Chapters []struct {
		Title  string `json:"Title"`
		Videos []struct {
			Title        string            `json:"Title"`
			LanguageUrls map[string]string `json:"LanguageUrls"`
		}
		Tasks []struct {
			Title        string            `json:"Title"`
			LanguageUrls map[string]string `json:"LanguageUrls"`
		}
	}
}
