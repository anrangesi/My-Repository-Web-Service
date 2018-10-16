package com.javen.service.impl;

import java.util.ArrayList;
import java.util.Map;

import javax.jws.WebService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.javen.dao.UserMapper;
import com.javen.model.User;
import com.javen.service.IUserService;
//这是接口的实现类。 endpointInterface属性，格式：包名.接口名
@Service
@WebService(endpointInterface="com.javen.service.IUserService")
public class UserServiceImpl implements IUserService{
	
	@Autowired
	UserMapper userDao;
//	@Autowired
	User user;
	

	public void deleteById(int id) {
		// TODO Auto-generated method stub
		
	}

	public ArrayList<User> selectAll() {
			ArrayList<User> user=userDao.selectAll();
			return user;
		
	}
	
	public Integer selectLogin(Map map) {
		return userDao.selectLogin(map);
	}

	public User selectById(int id) {
		// TODO Auto-generated method stub
		return null;
	}

	public void updateById(int id) {
		// TODO Auto-generated method stub
		
	}

	public User selectNameLogin(String name) {
		User user = userDao.selectNameLogin(name);
		return user;
	}



}
