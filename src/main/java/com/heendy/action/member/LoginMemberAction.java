package com.heendy.action.member;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.heendy.action.Action;
import com.heendy.action.ActionFactory;
import com.heendy.dao.MemberDAO;
import com.heendy.dto.MemberDTO;
import com.heendy.utils.SessionUserService;
import com.heendy.utils.UserService;

public class LoginMemberAction implements Action{
	private final MemberDAO memberDAO = MemberDAO.getInstance();
	
	private final UserService<MemberDTO, HttpSession> userService = SessionUserService.getInstance();

	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String url = "";
		String member_name = request.getParameter("id");
		String member_password = request.getParameter("pwd");
		String saveId = request.getParameter("idSaveYn");	//아이디 저장 여부를 확인하기 위한 변수

		MemberDTO memberVO = new MemberDTO();
		memberVO.setMemberName(member_name);
		memberVO.setMemberPassword(member_password);
		boolean result = memberDAO.isExisted(memberVO);
		if(result) {	//로그인 성공시
			System.out.println("로그인 성공!");
			if(saveId != null) {	//아이디 저장을 체크했을 경우
				Cookie c = new Cookie("saveId", member_name);
				c.setMaxAge(60*60*24*3);	//3일간 쿠키에 저장
				response.addCookie(c);	//사용자 이름(id) 정보를 쿠키에 저장한다.
			}else {	//아이디 저장을 체크하지 않은 경우
				Cookie c = new Cookie("saveId", member_name);
				c.setMaxAge(0);
                response.addCookie(c);
			}
			memberVO = memberDAO.getMember(member_name); //성공했으면 멤버를 조회해서 속성들을 가져온다

			HttpSession session = request.getSession();
		
			userService.saveUser(memberVO, session);
			url="/member/index.do";
			request.getRequestDispatcher(url).forward(request, response);
		}else {		//로그인 실패시
			System.out.println("로그인 실패");
			url="/pages/login/loginFail.jsp";
			request.setAttribute("msg", "아이디와 비밀번호를 다시 확인하세요.");
			request.getRequestDispatcher(url).forward(request, response);
		}
	}
}
