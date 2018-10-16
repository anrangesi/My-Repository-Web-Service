//键盘事件有3：keydown，keypress，keyup，分别是按下，按着没上抬，上抬键盘
$(document).keyup(function(event){
	//enter键的值为13
	if(event.keyCode == 13){
		$('#sub').click();
		}
});
	
	
$(function(){
	$("#sub").click(function(){
		$("#pwdMsg").empty();
		$("#nameMsg").empty();
			var userName=$("#userName").val();
			var password=$("#password").val();
			if($("#userName").val() == "" || $.trim($("#userName").val()).length == 0){
				$("#nameMsg").append("<p>用户名不能为空</p>");
				return;
			}
			if($("#password").val() == "" || $.trim($("#password").val()).length == 0){
				$("#pwdMsg").append("<p>请填写密码</p>");
				return;
			}
			$.ajax({
				type:'post',
				dataType:'json',  
				url:'./loginUser',
				async: true,
				data:{
				userName:$("#userName").val(),
				password:$("#password").val()
				},
				success:function(data){
				if(data=='1'){
					window.location.href='./test';
				}else if(data=='0'){
					$("#pwdMsg").append("<p>密码错误</p>");
				}else if(data=='2'){
					$("#nameMsg").append("<p>用户不存在</p>");
				}
				}
			});
		});
	
	$("#res").click(function(){
		$("#userName").val("");
		$("#password").val("");
		$("#pwdMsg").empty();
		$("#nameMsg").empty();
	});
	
});


