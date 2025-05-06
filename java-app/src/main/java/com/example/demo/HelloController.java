package com.example.demo;

import io.opentelemetry.api.GlobalOpenTelemetry;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.Tracer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import java.util.HashMap;
import java.util.Map;

@RestController
public class HelloController {



    Tracer tracer = GlobalOpenTelemetry.getTracer("hello");

    @Autowired
    private HelloService service;


    @GetMapping("/")
    public String home() {
        return "Hello World!";
    }

    @GetMapping("/hello/{name}")
    public Map<String, Object> hello(@PathVariable String name) {
        Span span = tracer.spanBuilder("controller").setAttribute("name", name).startSpan();
        Map<String, Object> response = new HashMap<>();
        String dbResult = service.callDb();
        response.put("message", "Hello " + name + "!");
        response.put("dbResult", dbResult);
        response.put("timestamp", System.currentTimeMillis());
        span.end();
        return response;
    }

    @GetMapping("/health")
    public Map<String, String> health() {
        Map<String, String> status = new HashMap<>();
        status.put("status", "UP");
        return status;
    }
}
