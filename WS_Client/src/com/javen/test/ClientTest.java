package com.javen.test;

import java.util.List;

import org.junit.Test;

import com.javen.service.IUserService;
import com.javen.service.ObjectFactory;
import com.javen.service.SelectAll;
import com.javen.service.SelectNameLoginResponse;
import com.javen.service.User;
import com.javen.service.UserServiceImplService;

/**
 * @author  Administrator
 * @version 创建时间：2018-8-27 下午02:54:02
 */
public class ClientTest {

	@Test
	public void selectNameAll(){
		try {
			IUserService iUserService = new UserServiceImplService().getUserServiceImplPort();
			List<User> user = iUserService.selectAll();
			for (User user2 : user) {
				System.out.println("name:"+user2.getUserName());
			}
		} catch (Exception e) {
			System.err.println(e.getMessage());
			System.err.println("连接被拒绝：查看服务端是否启动或连接是否正确");
		}
		
	}
	
}
