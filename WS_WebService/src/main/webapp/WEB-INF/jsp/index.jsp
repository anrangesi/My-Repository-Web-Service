<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>    

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
<link href="${pageContext.request.contextPath}/css/table_Style.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery-3.3.1.min.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/js/table_Style.js"></script>
</head>
<body>
  <table class="tableStyle" cellpadding="0" cellspacing="0" border="1" width="700">
	<tr>
		<th>序号</th><th>姓名</th><th>年龄</th>
	</tr>
	<c:forEach items="${user}" var="u" varStatus="stat">
	<tr>
		<td>${stat.index+1}</td><td>${u.userName}</td><td>${u.age}</td>
	</tr>
	</c:forEach>
  </table>
</body>
</html>