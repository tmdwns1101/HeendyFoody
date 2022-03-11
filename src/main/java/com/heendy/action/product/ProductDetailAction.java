package com.heendy.action.product;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import com.heendy.action.Action;
import com.heendy.dao.ProductDAO;
import com.heendy.dto.ProductDTO;

/**
 * @author 김시은
 * 
 * 상품 상세 정보를 가져오는 Action 클래스
 * 
 * */
public class ProductDetailAction implements Action {

	private final ProductDAO productDAO = ProductDAO.getInstance();
	
	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		int pid = Integer.parseInt(request.getParameter("pid"));
		int cid = Integer.parseInt(request.getParameter("cid"));


		// detailProduct() : 상품 상세정보 가져오기
		ProductDTO product = productDAO.detailProduct(pid, cid);
		request.setAttribute("product", product);
		
		// 상품 상세보기 페이지로 이동
		String url = "/pages/product/productDetail.jsp";
		
	    RequestDispatcher dispatcher = request.getRequestDispatcher(url);
	    dispatcher.forward(request, response);
		
	}

}
