package com.example.demo;

import io.opentelemetry.instrumentation.annotations.WithSpan;
import org.springframework.stereotype.Service;

@Service
public class HelloService {
    @WithSpan("callDb")
    public String callDb() {
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
        return "fake result from db";
    }
}
