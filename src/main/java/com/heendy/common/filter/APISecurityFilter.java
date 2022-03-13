package com.heendy.common.filter;

import java.io.IOException;
import java.util.Optional;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.Gson;
import com.heendy.common.ErrorCode;
import com.heendy.common.ErrorResponse;
import com.heendy.dto.MemberDTO;
import com.heendy.utils.SessionUserService;
import com.heendy.utils.UserService;


/***
 * 
 * @author 이승준
 *
 * API 검증필터로, 인증되지 않은 사용자를 검증하는 필터이다.
 */

@WebFilter(
		urlPatterns = {
				"/cart/create.do",
				"/cart/addCount.do",
				"/cart/minusCount.do",
				"/cart/delete.do",
				"/wish/*",
				"/order/*"
		}
)
public class APISecurityFilter implements Filter {

	private UserService<MemberDTO, HttpSession> userService = SessionUserService.getInstance();
	
	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
			throws IOException, ServletException {
		
		HttpServletResponse res = (HttpServletResponse) response;
		
		res.setContentType("application/json");
		res.setCharacterEncoding("utf-8");
		
		HttpServletRequest req = (HttpServletRequest)request;
		HttpSession session = req.getSession();
		
		Optional<MemberDTO> member =  userService.loadUser(session);
		
		if(member.isPresent()) {
			chain.doFilter(request, response);
		} else {
			ErrorResponse errorResponse = ErrorResponse.of(ErrorCode.UNATHORIZED_USER);
			String json = new Gson().toJson(errorResponse);
			res.setStatus(errorResponse.getStatus());
			res.getWriter().write(json);
		}
		
	}
	
	

}
