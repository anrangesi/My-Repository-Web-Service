<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>细水长流</title>
<link rel="shortcut icon" href="${pageContext.request.contextPath}/img/20140925100559_RviGZ.jpeg" type="image/x-icon"/>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/table_Style.css" type="text/css">
<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery-3.3.1.min.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/js/table_Style.js"></script>

</head>
<body>
<h1>Login</h1>
  <table cellpadding="0" cellspacing="0" border="0" width="400" class="tableStyle">
	<tr height="45">
		<td align="right" width="70px">登录名：</td>
		<td width="90px">
		<input type="text" id="userName" name="userName">
		</td>
		<td align="left" width="170px"><span id="nameMsg" style="color:red;font-size: 12px"></span></td>
	</tr>
	<tr height="45">
		<td align="right" width="70px">密码：</td>
		<td width="90px">
		<input type="password" id="password" name="password">
		</td>
		<td align="left" width="170px"><span id="pwdMsg" style="color:red;font-size: 12px"></span></td>
	</tr>
	<tr>
		<td align="center" colspan="2">
		<input type="button" id="sub" value="登录">&nbsp;
		<input type="reset" id="res" value="清空">
		</td>
    </tr>
  </table>

</body>
</html>