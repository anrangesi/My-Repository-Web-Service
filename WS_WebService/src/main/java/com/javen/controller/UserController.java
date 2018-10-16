package com.javen.controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

//import org.slf4j.Logger;
//import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpRequest;
import org.springframework.stereotype.Controller;  
import org.springframework.ui.Model;  
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;  
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.javen.model.User;
import com.javen.service.IUserService;
  
  
@Controller  
@RequestMapping("/")  
public class UserController {  
      @Autowired
      IUserService iUserService;
    
    @RequestMapping("/")  
    public String login(){
    	return "login";
    } 
    
    @RequestMapping(value="loginUser",method={RequestMethod.POST})
    @ResponseBody
    public String loginUser(HttpServletRequest request,Model model){
    	String userName=request.getParameter("userName");
    	String password=request.getParameter("password");
    	
    	String flag="0";
    	try {
    		User user=iUserService.selectNameLogin(userName);
    		System.out.println("password:"+password+"\ngetpassword："+user.getPassword());
    	    	if (null!=password && password.equals(user.getPassword())) {
    	    		flag="1";
    			} else {
    				flag="0";
    			}
		} catch (Exception e) {
			flag="2";
			System.err.println(e.getMessage());
		}
		return flag;
    }
   
    
    @RequestMapping("/test")  
    public String test(HttpServletRequest request,Model model){   
    	System.out.println("test");
    	ArrayList<User> user=iUserService.selectAll();
        model.addAttribute("user", user);  
        return "index";  
    }  
}  