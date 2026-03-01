package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.http.MediaType;

@SpringBootApplication
@RestController
public class HelloApplication {

    @RequestMapping(value = "/", produces = MediaType.TEXT_HTML_VALUE)
    public String home() {
        return """
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Lurch Quote</title>
            </head>
            <body>
                <p>You rang? -- <cite>Lurch (<a href="https://www.youtube.com/watch?v=sPMKlEwrIs8">source</a>), Ted Cassidy</cite></p>
                
                <iframe 
                    width="560" 
                    height="315" 
                    src="https://www.youtube.com/embed/F3jnymeJof4?si=eTTH7TXZO6pTN6zX" 
                    title="YouTube video player" 
                    frameborder="0" 
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" 
                    referrerpolicy="strict-origin-when-cross-origin" 
                    allowfullscreen>
                </iframe>
            </body>
            </html>
            """;
    }

    public static void main(String[] args) {
        SpringApplication.run(HelloApplication.class, args);
    }
}