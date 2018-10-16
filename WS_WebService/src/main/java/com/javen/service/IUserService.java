package com.javen.service;
import java.util.ArrayList;
import java.util.Map;
import javax.jws.WebMethod;
import javax.jws.WebService;
import com.javen.model.User;
//表示这是一个@WebService服务接口
@WebService
public interface IUserService {
	//@WebMethod注解，表示服务发布时被注解的方法也会随之发布
	@WebMethod
	public ArrayList<User> selectAll();
	@WebMethod
	public Integer selectLogin(Map map);
	@WebMethod
	public User selectNameLogin(String name);
	@WebMethod
	public User selectById(int id);
	@WebMethod
	public void updateById(int id);
	@WebMethod
	public void deleteById(int id);
	
}
