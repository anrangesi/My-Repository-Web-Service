package com.javen.dao;

import java.util.ArrayList;
import java.util.Map;

import com.javen.model.User;

public interface UserMapper{

	public ArrayList<User> selectAll();
	
	public Integer selectLogin(Map map);
	
	public User selectNameLogin(String name);
	
	public User selectById(int id);
	
	public void updateById(int id);
	
	public void deleteById(int id);
}
