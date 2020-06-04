package com.example.easynotes.controller;


import jdk.nashorn.internal.objects.annotations.Property;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sound.midi.SysexMessage;

@RestController
@RequestMapping("/")
public class IndexController {

    @Value("${spring.datasource.password:notfound}")
    private String APP_KEY;

    @Value("${app.key:notfound}")
    private String APP_KEY0;

    @Value("${env.DB_PWD:notfound}")
    private String APP_KEY_2;

    @GetMapping
    public String sayHello() {
        return "spring.datasource.password : " + APP_KEY + " / app.key"+ APP_KEY0 + " / env.DB_PWD : "+ APP_KEY_2;
        //return "Hello and Welcome to the EasyNotes application. You can create a new Note by making a POST request to /api/notes endpoint.";
    }
}
