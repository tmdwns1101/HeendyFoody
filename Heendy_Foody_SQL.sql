--------------------------------------------------------
--  파일이 생성됨 - 수요일-3월-16-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Type CARTIDSARRAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE CARTIDSARRAY AS VARRAY(100) OF NUMBER(20,0)

/
--------------------------------------------------------
--  DDL for Type CATEGORY_ARRAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE CATEGORY_ARRAY as table of varchar2(30);

/
--------------------------------------------------------
--  DDL for Type RECENTVIEWPRODUCTIDSARRAY
--  @Author 이지민
--  최근 본 상품 아이디를 인자로 받을 array 타입 생성
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE RECENTVIEWPRODUCTIDSARRAY as varray (100) of number;

/
--------------------------------------------------------
--  DDL for Sequence MEMBER_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  MEMBER_SEQ  MINVALUE 1 MAXVALUE 9999999999999999999 INCREMENT BY 1 START WITH 121 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
   
--------------------------------------------------------
--  DDL for Sequence CART_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  CART_SEQ  MINVALUE 1 MAXVALUE 9999999999999999999 INCREMENT BY 1 START WITH 121 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
--------------------------------------------------------
--  DDL for Sequence CATEGORY_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  CATEGORY_SEQ  MINVALUE 1 MAXVALUE 9999999999999999999 INCREMENT BY 1 START WITH 81 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
--------------------------------------------------------
--  DDL for Sequence COMPANY_MEMBER_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  COMPANY_MEMBER_SEQ  MINVALUE 1 MAXVALUE 9999999999999999999 INCREMENT BY 1 START WITH 41 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
--------------------------------------------------------
--  DDL for Sequence LOGIN_ROLE_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  LOGIN_ROLE_SEQ  MINVALUE 1 MAXVALUE 9999999999999999999 INCREMENT BY 1 START WITH 21 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
--------------------------------------------------------
--  DDL for Sequence PRODUCT_ORDER_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  PRODUCT_ORDER_SEQ  MINVALUE 1 MAXVALUE 9999999999999999999 INCREMENT BY 1 START WITH 181 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
--------------------------------------------------------
--  DDL for Sequence PRODUCT_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  PRODUCT_SEQ  MINVALUE 1 MAXVALUE 9999999999999999999 INCREMENT BY 1 START WITH 201 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
--------------------------------------------------------
--  DDL for Sequence REVIEW_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  REVIEW_SEQ  MINVALUE 1 MAXVALUE 9999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
--------------------------------------------------------
--  DDL for Table CART
--------------------------------------------------------

  CREATE TABLE CART 
   (	CART_ID NUMBER(10,0) DEFAULT CART_SEQ.NEXTVAL, 
	CART_COUNT NUMBER(10,0), 
	PRODUCT_ID NUMBER(10,0), 
	COMPANY_ID NUMBER(10,0), 
	MEMBER_ID NUMBER(10,0)
   );
--------------------------------------------------------
--  DDL for Table CATEGORY
--------------------------------------------------------

  CREATE TABLE CATEGORY 
  (	CATEGORY_ID NUMBER(10,0) DEFAULT CATEGORY_SEQ.NEXTVAL, 
	CATEGORY_NAME NVARCHAR2(30),
	PARENT_CATEGORY_ID NUMBER(10,0)
   );
--------------------------------------------------------
--  DDL for Table COMPANY_MEMBER
--------------------------------------------------------

  CREATE TABLE COMPANY_MEMBER 
   (	COMPANY_ID NUMBER(10,0) DEFAULT COMPANY_MEMBER_SEQ.NEXTVAL, 
	COMPANY_NAME NVARCHAR2(30),
	COMPANY_PASSWORD NVARCHAR2(30), 
	COMPANY_TEL NVARCHAR2(30), 
	COMPANY_EMAIL NVARCHAR2(50), 
	ROLE_ID NUMBER(10,0)
   );
--------------------------------------------------------
--  DDL for Table LOGIN_ROLE
--------------------------------------------------------

  CREATE TABLE LOGIN_ROLE 
   (	ROLE_ID NUMBER(10,0) DEFAULT LOGIN_ROLE_SEQ.NEXTVAL, 
	ROLE_NAME NVARCHAR2(30)
   );
--------------------------------------------------------
--  DDL for Table MEMBER
--------------------------------------------------------

  CREATE TABLE MEMBER 
   (	MEMBER_ID NUMBER(10,0) DEFAULT MEMBER_SEQ.NEXTVAL, 
	MEMBER_NAME NVARCHAR2(30), 
	MEMBER_PASSWORD NVARCHAR2(30), 
	MEMBER_EMAIL NVARCHAR2(50), 
	ADDRESS NVARCHAR2(50), 
	POINT NUMBER(10,0) DEFAULT 300, 
	MEMBER_REG_DATE DATE DEFAULT SYSDATE, 
	ROLE_ID NUMBER(10,0), 
	BIRTH_DATE NVARCHAR2(30)
   );
--------------------------------------------------------
--  DDL for Table MEMBER_LIKE_PRODUCT
--------------------------------------------------------

  CREATE TABLE MEMBER_LIKE_PRODUCT 
   (	MEMBER_ID NUMBER(10,0), 
	PRODUCT_ID NUMBER(10,0), 
	COMPANY_ID NUMBER(10,0)
   );
--------------------------------------------------------
--  DDL for Table PRODUCT
--------------------------------------------------------

  CREATE TABLE PRODUCT 
   (	PRODUCT_ID NUMBER(10,0) DEFAULT PRODUCT_SEQ.NEXTVAL, 
	COMPANY_ID NUMBER(10,0), 
	PRODUCT_PRICE NUMBER(10,0), 
	PRODUCT_NAME NVARCHAR2(30), 
	IMAGE_URL NVARCHAR2(100), 
	PRODUCT_COUNT NUMBER(5,0), 
	PRODUCT_REG_DATE DATE DEFAULT SYSDATE, 
	DISCOUNT_RATE NUMBER(3,0) DEFAULT 0, 
	DELETED NUMBER(1,0) DEFAULT 0, 
	CATEGORY_ID NUMBER(10,0), 
	DISCOUNT_PRICE NUMBER(10,0) GENERATED ALWAYS AS ("PRODUCT_PRICE"-"PRODUCT_PRICE"*("DISCOUNT_RATE"/100)) VIRTUAL 
   );
--------------------------------------------------------
--  DDL for Table PRODUCT_ORDER
--------------------------------------------------------

  CREATE TABLE PRODUCT_ORDER 
   (	ORDER_ID NUMBER(10,0) DEFAULT PRODUCT_ORDER_SEQ.NEXTVAL, 
	MEMBER_ID NUMBER(10,0), 
	ORDER_TIME DATE DEFAULT SYSDATE, 
	ORDER_COUNT NUMBER(10,0), 
	ORDER_PRICE NUMBER(10,0), 
	PRODUCT_ID NUMBER(10,0), 
	COMPANY_ID NUMBER(10,0)
   );
--------------------------------------------------------
--  DDL for View V_PRODUCT
--------------------------------------------------------
--------------------------------------------------------
--  @Author 김시은
--  상품 정보를 담은 View
--------------------------------------------------------
create or replace view v_product 
as
select p.product_id, p.company_id, company_name, product_price, discount_price, product_name, 
image_url, product_count, product_reg_date, discount_rate, deleted, c.* , nvl(l.like_count,0) like_count
from product p 
left join 
(select mlp.product_id, count(*) as like_count from member_like_product mlp group by mlp.product_id) l 
on p.product_id = l.product_id, 
company_member cm, 
(select c2.*, c1.category_name as parent_category_name from category c1, category c2 where c1.category_id = c2.parent_category_id) c 
where p.company_id = cm.company_id and p.category_id = c.category_id;

--------------------------------------------------------
--  DDL for Index CART_MEID_IDX
--------------------------------------------------------

  CREATE INDEX CART_MEID_IDX ON CART (MEMBER_ID);
--------------------------------------------------------
--  DDL for Index MLP_PID
--------------------------------------------------------

  CREATE INDEX MLP_PID ON MEMBER_LIKE_PRODUCT (PRODUCT_ID);
--------------------------------------------------------
--  DDL for Index PK_CART
--------------------------------------------------------

  CREATE UNIQUE INDEX PK_CART ON CART (CART_ID);
--------------------------------------------------------
--  DDL for Index PK_CATEGORY
--------------------------------------------------------

  CREATE UNIQUE INDEX PK_CATEGORY ON CATEGORY (CATEGORY_ID);
--------------------------------------------------------
--  DDL for Index PK_COMPANY_MEMBER
--------------------------------------------------------

  CREATE UNIQUE INDEX PK_COMPANY_MEMBER ON COMPANY_MEMBER (COMPANY_ID);
--------------------------------------------------------
--  DDL for Index PK_LIKE
--------------------------------------------------------

  CREATE UNIQUE INDEX PK_LIKE ON MEMBER_LIKE_PRODUCT (MEMBER_ID, PRODUCT_ID, COMPANY_ID);
--------------------------------------------------------
--  DDL for Index PK_LOGIN_ROLE
--------------------------------------------------------

  CREATE UNIQUE INDEX PK_LOGIN_ROLE ON LOGIN_ROLE (ROLE_ID);
--------------------------------------------------------
--  DDL for Index PK_MEMBER
--------------------------------------------------------

  CREATE UNIQUE INDEX PK_MEMBER ON MEMBER (MEMBER_ID);
--------------------------------------------------------
--  DDL for Index PK_ORDER
--------------------------------------------------------

  CREATE UNIQUE INDEX PK_ORDER ON PRODUCT_ORDER (ORDER_ID, MEMBER_ID);
--------------------------------------------------------
--  DDL for Index PK_PRODUCT
--------------------------------------------------------

  CREATE UNIQUE INDEX PK_PRODUCT ON PRODUCT (PRODUCT_ID, COMPANY_ID);
--------------------------------------------------------
--  DDL for Index PRODUCT_CATEID_IDX
--------------------------------------------------------

  CREATE INDEX PRODUCT_CATEID_IDX ON PRODUCT (CATEGORY_ID);
--------------------------------------------------------
--  DDL for Index UK_MEMBER_EMAIL
--------------------------------------------------------

  CREATE UNIQUE INDEX UK_MEMBER_EMAIL ON MEMBER (MEMBER_EMAIL);
--------------------------------------------------------
--  DDL for Index UK_MEMBER_NAME
--------------------------------------------------------

  CREATE UNIQUE INDEX UK_MEMBER_NAME ON MEMBER (MEMBER_NAME);
--------------------------------------------------------
--  DDL for Index CART_MEID_IDX
--------------------------------------------------------

  CREATE INDEX CART_MEID_IDX ON CART (MEMBER_ID);
--------------------------------------------------------
--  DDL for Index PK_CART
--------------------------------------------------------

  CREATE UNIQUE INDEX PK_CART ON CART (CART_ID);
--------------------------------------------------------
--  DDL for Index PK_CATEGORY
--------------------------------------------------------

  CREATE UNIQUE INDEX PK_CATEGORY ON CATEGORY (CATEGORY_ID);
--------------------------------------------------------
--  DDL for Index PK_COMPANY_MEMBER
--------------------------------------------------------

  CREATE UNIQUE INDEX PK_COMPANY_MEMBER ON COMPANY_MEMBER (COMPANY_ID) ;
--------------------------------------------------------
--  DDL for Index PK_LOGIN_ROLE
--------------------------------------------------------

  CREATE UNIQUE INDEX PK_LOGIN_ROLE ON LOGIN_ROLE (ROLE_ID);
--------------------------------------------------------
--  DDL for Index UK_MEMBER_NAME
--------------------------------------------------------

  CREATE UNIQUE INDEX UK_MEMBER_NAME ON MEMBER (MEMBER_NAME);
--------------------------------------------------------
--  DDL for Index UK_MEMBER_EMAIL
--------------------------------------------------------

  CREATE UNIQUE INDEX UK_MEMBER_EMAIL ON MEMBER (MEMBER_EMAIL) ;
--------------------------------------------------------
--  DDL for Index PK_MEMBER
--------------------------------------------------------

  CREATE UNIQUE INDEX PK_MEMBER ON MEMBER (MEMBER_ID);
--------------------------------------------------------
--  DDL for Index MLP_PID
--------------------------------------------------------

  CREATE INDEX MLP_PID ON MEMBER_LIKE_PRODUCT (PRODUCT_ID);
--------------------------------------------------------
--  DDL for Index PK_LIKE
--------------------------------------------------------

  CREATE UNIQUE INDEX PK_LIKE ON MEMBER_LIKE_PRODUCT (MEMBER_ID, PRODUCT_ID, COMPANY_ID);
--------------------------------------------------------
--  DDL for Index PRODUCT_CATEID_IDX
--------------------------------------------------------

  CREATE INDEX PRODUCT_CATEID_IDX ON PRODUCT (CATEGORY_ID);
--------------------------------------------------------
--  DDL for Index PK_PRODUCT
--------------------------------------------------------

  CREATE UNIQUE INDEX PK_PRODUCT ON PRODUCT (PRODUCT_ID, COMPANY_ID);
--------------------------------------------------------
--  DDL for Index PK_ORDER
--------------------------------------------------------

  CREATE UNIQUE INDEX PK_ORDER ON PRODUCT_ORDER (ORDER_ID, MEMBER_ID);

--------------------------------------------------------
--  DDL for Trigger TR_CHECK_PRODUCT_INSERT_TIME
--  @Author 이지민
--  상품 등록 전 시간을 체크하는 Trigger
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER TR_CHECK_PRODUCT_INSERT_TIME 
before insert or update on product 
declare
    server_check_time exception;
    pragma exception_init(server_check_time, -20013);
begin
    /* 해당 시간대에 작업이 시행되면 에러를 발생시킨다 */
    if(to_char(sysdate, 'day') in ('월요일') and
    to_char(sysdate, 'hh24') >= 9 and to_char(sysdate, 'hh24') <= 10) then 
    raise server_check_time;
    end if;
    
    exception
		when server_check_time then
			dbms_output.put_line('ora'||sqlcode||': 서버 점검 시간입니다.' );
            raise_application_error(sqlcode,'서버 점검 시간입니다.');
		when others then 
			raise;
end;
/
ALTER TRIGGER TR_CHECK_PRODUCT_INSERT_TIME ENABLE;

--------------------------------------------------------
--  DDL for Procedure SP_LIST_CATEGORY
-- @Author 김시은, 문석호
-- 카테고리 전체 목록 조회
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE SP_LIST_CATEGORY 
(p_category_id category.category_id%type,
 p_parent_category_id category.parent_category_id%type,
 p_category_name out varchar2,
 p_category_info out SYS_REFCURSOR)
is
begin

    /* 전체 카테고리 조회  (부모 카테고리 ID먼저 오름차순 정렬 후 자식 카테고리 ID를 오름차순 정렬한다.) */
    if p_category_id = 0 and p_parent_category_id = 0 then
        open p_category_info for
            select *
            from category
            order by parent_category_id asc, category_id asc;
    else
        /* 현재 카테고리 명 조회 */
        select category_name into p_category_name
        from category
        where parent_category_id = p_parent_category_id and category_id = p_category_id;
        
        /* 카테고리 정보 조회  */
        open p_category_info for
            select *
            from category
            where parent_category_id = p_parent_category_id 
            order by category_id asc;
    end if;
end;

/
--------------------------------------------------------
--  DDL for Package PACK_ENCRYPTION_DECRYPTION
--  @Author 문석호
--  비밀번호 암호화 패키지
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE PACK_ENCRYPTION_DECRYPTION 
IS
    FUNCTION FUNC_ENCRYPT --암호화
    (INPUT_STRING IN VARCHAR2)
    RETURN RAW;
    FUNCTION FUNC_DECRYPT -- 복호화
    (INPUT_STRING IN VARCHAR2)
    RETURN VARCHAR2;
END PACK_ENCRYPTION_DECRYPTION;

/
--------------------------------------------------------
--  DDL for Package PKG_CART
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE PKG_CART 
is
    /* 장바구니 리스트 */
    PROCEDURE sp_select_cart_list (
    p_member_id member.member_id%TYPE,
    p_result OUT sys_refcursor
    );
    
    /* 장바구니 생성 */
    PROCEDURE sp_create_cart (
    p_productId cart.PRODUCT_ID%TYPE, 
    p_companyId cart.COMPANY_ID%TYPE, 
    p_memberID cart.MEMBER_ID%TYPE, 
    p_count cart.CART_COUNT%TYPE
    ); 
    
    /* 장바구니 삭제 */
    PROCEDURE sp_delete_cart (
    p_cart_id CART.CART_ID%TYPE,
    p_member_id MEMBER.MEMBER_ID%TYPE
    );
    
    /* 장바구니 수량 추가 */
    PROCEDURE sp_add_cart (
    p_cart_id CART.CART_ID%TYPE, 
    p_cart_count CART.CART_COUNT%TYPE,
    p_member_id MEMBER.MEMBER_ID%TYPE 
    );
    
    /* 장바구니 수량 감소 */
    PROCEDURE sp_minus_cart (
    p_cart_id CART.CART_ID%TYPE,
    p_cart_count CART.CART_COUNT%TYPE,
    p_member_id  MEMBER.MEMBER_ID%TYPE
    );
end;

/
--------------------------------------------------------
--  DDL for Package PKG_COMPANY
--  @Author 김시은
--  업체회원 페이지 차트 그리기 위한 데이터 : 구매자 연령층, 날짜별 상품 판매량
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE PKG_COMPANY 
is
    /* 구매자 연령층 */
    PROCEDURE SP_MEMBER_AGEINFO (
     p_company_id product_order.company_id%type,
     p_member_ageinfo out sys_refcursor
     );

     /* 상품 판매량 */
     PROCEDURE SP_PRODUCT_ORDERINFO (
     p_company_id product_order.company_id%type,
     p_product_id product_order.product_id%type,
     p_date_sort varchar2,
     p_product_orderinfo out sys_refcursor
     );
end;

/
--------------------------------------------------------
--  DDL for Package PKG_MEMBER
--  @Author 문석호, 이지민
--  회원 관련 패키지
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE PKG_MEMBER 
is
--일반 회원 가입
    PROCEDURE sp_add_member
    (p_member_name MEMBER.MEMBER_NAME%TYPE, 
    p_member_password MEMBER.member_password%TYPE, 
    p_member_email MEMBER.member_email%TYPE, 
    p_address MEMBER.address%TYPE, 
    p_role_id MEMBER.role_id%TYPE,
    p_birth_date MEMBER.birth_date%TYPE);
-- 일반 회원 로그인
    PROCEDURE sp_member_IsExisted
    (p_member_name MEMBER.MEMBER_NAME%TYPE, 
    p_member_password MEMBER.member_password%TYPE,
    v_member_out out integer
    );
--일반 회원 비밀번호 찾기
    PROCEDURE sp_member_findPw
    (p_member_name MEMBER.MEMBER_NAME%TYPE, 
    p_member_email MEMBER.member_email%TYPE,
    v_member_pw_out out varchar2
    );
--일반 회원 아이디 찾기
    PROCEDURE sp_member_findId
    (p_member_email MEMBER.member_email%TYPE,
    v_member_id_out out varchar2
    );
--일반 회원 아이디 중복체크
    PROCEDURE sp_member_duplicatedId
    (p_member_name MEMBER.member_name%TYPE,
    v_member_idCheck out integer
    );
-- 일반 회원 정보 불러오기
    PROCEDURE sp_member_getmember
    (p_member_name MEMBER.member_name%TYPE,
    v_member_info_out out SYS_REFCURSOR
    );
--------------------------------------------------------
--  @Author 이지민
--  회원 포인트를 조회하는 Procedure
--------------------------------------------------------
-- 일반 회원 포인트 조회 
    procedure sp_select_member_point (
    p_memberId member.member_id%type,
    p_point out Number
    );

--업체 회원 회원가입
 procedure sp_add_company_member
(p_company_name company_member.company_name%type,
p_company_password company_member.company_password%type,
p_company_tel company_member.company_tel%type,
p_company_email company_member.company_email%type,
p_role_id company_member.role_id%type);
-- 업체 회원 아이디 중복 확인
PROCEDURE sp_company_duplicatedId
(p_company_name company_member.company_name%TYPE,
v_company_idCheck out Integer
);
--업체 회원 로그인
PROCEDURE sp_company_isExisted
(p_company_name company_member.company_name%TYPE,
p_company_password company_member.company_password%type,
v_company_out out Integer
);
--업체 회원 정보 가져오기
PROCEDURE sp_company_getcompany
(p_company_name company_member.company_name%TYPE,
v_company_info_out out sys_refcursor
);
end;

/
--------------------------------------------------------
--  DDL for Package PKG_ORDER
-- @Author 이승준, 이지민
-- 주문 내역 관련 패키지
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE PKG_ORDER 
is
--------------------------------------------------------
--  @Author 이지민
--  주문내역 리스트를 불러오는 Procedure
--------------------------------------------------------
    /* 주문내역 리스트 */
    procedure sp_list_order (
    p_beginRow Number,
    p_endRow Number,
    p_memberId product_order.member_id%type,
    p_list_order out sys_refcursor
    );
    
    /* 주문내역 생성(바로주문) */
    procedure sp_create_order (
    p_product_id product.product_id%TYPE,
    p_company_id product.company_id%TYPE,
    p_member_id MEMBER.MEMBER_ID%TYPE,
    p_order_count PRODUCT_ORDER.ORDER_COUNT%TYPE
    );
    
    /* 주문내역 생성(장바구니 주문) */
    procedure sp_create_order_from_cart (
	p_member_id member.member_id%TYPE,
	p_cart_array cartIdsArray 
    );
        
--------------------------------------------------------
--  @Author 이지민
--  총 주문내역 개수를 가져오는 Procedure
--------------------------------------------------------
    /* 총 주문내역 개수 */
    procedure sp_totalcount_order (
    p_memberId product_order.member_id%type,
    p_totalCount out Number
    );        
end;

/
--------------------------------------------------------
--  DDL for Package PKG_PRODUCT
--  @Author 김시은, 이승준, 이지민
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE PKG_PRODUCT 
is

--------------------------------------------------------
--  @Author 김시은
--  상품 리스트를 불러오는 Procedure
--------------------------------------------------------
    /* 상품 리스트 */
    procedure sp_list_product
        (p_beginRow Number,
         p_endRow Number,
         p_sort varchar2,
         p_menu VARCHAR2,
         p_cate v_product.category_id%type,
         p_parent_cate v_product.parent_category_id%type,
         p_list_product out sys_refcursor);


--------------------------------------------------------
--  @Author 김시은
--  업체별 상품 목록을 불러오는 Procedure
--------------------------------------------------------
    /* 업체별 상품 목록 */
    PROCEDURE SP_COMPANY_PRODUCT (
     p_company_id product_order.company_id%type,
     p_company_product out sys_refcursor
     );


--------------------------------------------------------
--  @Author 김시은
--  상품 상세 페이지의 상품 정보를 불러오는 Procedure
--------------------------------------------------------
    /* 상품 정보 */
    procedure sp_select_product
        (p_product_id v_product.product_id%type,
         p_company_id v_product.company_id%type,
         p_result out sys_refcursor);


--------------------------------------------------------
--  @Author 김시은
--  상품 전체 개수를 불러오는 Procedure
--------------------------------------------------------
    /* 상품 전체 개수 */
    PROCEDURE SP_TOTALCOUNT_PRODUCT (
         p_menu VARCHAR2,
         p_cate v_product.category_id%type,
         p_parent_cate v_product.parent_category_id%type,
         p_totalcount out Number);

    /* 상품 등록 */
    PROCEDURE sp_create_product(
        p_companyId company_member.company_id%TYPE,
        p_product_name product.product_name%TYPE,
        p_product_price product.product_price%TYPE,
        p_discount_rate product.discount_rate%TYPE,
        p_product_count product.product_count%TYPE,
        p_image_url product.image_url%TYPE,
        p_category_id category.category_id%TYPE
        );
 
--------------------------------------------------------
--  @Author 이지민
--  최근 본 상품 리스트를 불러오는 Procedure
--------------------------------------------------------       
    /* 최근 본 상품 목록 */
    procedure sp_list_recent_view_product (
        p_recent_view_array recentViewProductIdsArray,
        p_list_recent_view_product out sys_refcursor
        );
end;

/
--------------------------------------------------------
--  DDL for Package PKG_WISH
--  @Author 김시은, 이지민
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE PKG_WISH 
is

--------------------------------------------------------
--  @Author 김시은
--  좋아요 여부를 불러오는 Procedure
--------------------------------------------------------
    /* 좋아요 여부 */
    procedure sp_check_wish(
         p_member_id member_like_product.member_id%type,
         p_product_id member_like_product.product_id%type,
         p_company_id member_like_product.company_id%type,
         p_count out number
         );


--------------------------------------------------------
--  @Author 김시은
--  상품정보와 사용자 정보를 가지고 좋아요를 삽입하는 Procedure
--------------------------------------------------------
    /* 좋아요 삽입 */
    procedure sp_insert_wish(
         p_member_id member_like_product.member_id%type,
         p_product_id member_like_product.product_id%type,
         p_company_id member_like_product.company_id%type
         );


--------------------------------------------------------
--  @Author 김시은
--  상품정보와 사용자 정보를 가지고 좋아요를 삭제하는 Procedure
--------------------------------------------------------
    /* 좋아요 삭제 */
    procedure sp_delete_wish(
         p_member_id member_like_product.member_id%type,
         p_product_id member_like_product.product_id%type,
         p_company_id member_like_product.company_id%type
         );

--------------------------------------------------------
--  @Author 이지민
--  좋아요한 상품 내역을 불러오는 Procedure
--------------------------------------------------------
    /* 좋아요 리스트 */
    procedure sp_list_wish (
        p_beginRow Number,
        p_endRow Number,
        p_memberId member_like_product.member_id%type,
        p_list_wish out sys_refcursor
        );

--------------------------------------------------------
--  @Author 이지민
--  좋아요한 상품의 총 개수를 불러오는 Procedure
--------------------------------------------------------
        
    /* 좋아요 총 개수 */
    procedure sp_totalcount_wish (
        p_memberId member_like_product.member_id%type,
        p_totalCount out Number
        );
end;

/
--------------------------------------------------------
--  DDL for Package Body PACK_ENCRYPTION_DECRYPTION
--  @Author 문석호
--  DBMS_CRYPTO의 비밀번호 암호화/복호화 함수
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY PACK_ENCRYPTION_DECRYPTION 
IS
    FUNCTION FUNC_ENCRYPT -- 암호화 (암호화할 스트링을 인자로 받음)
    (INPUT_STRING IN VARCHAR2)
    RETURN RAW
    IS
    ORIGNAL_RAW RAW(64); -- RAW타입 변수 선언: 원본을 담을 변수(암호화할 데이터)
    KEY_DATA_RAW RAW(64); -- 암호화키를 담을 변수
    ENCRYTED_RAW RAW(64); -- 암호화된 데이터
    BEGIN
    -- INPUT_STRING을 아래와 같이 RAW 타입으로 변경.
    ORIGNAL_RAW := UTL_I18N.STRING_TO_RAW(INPUT_STRING, 'AL32UTF8'); -- UTL_I18N :국가, 언어들 간의 다양한 호환 기능 제공 패키지
    KEY_DATA_RAW := UTL_I18N.STRING_TO_RAW('HeendyUser01$', 'AL32UTF8');

    -- 암호화해서 encrypted_raw에 저장
    ENCRYTED_RAW := DBMS_CRYPTO.ENCRYPT(SRC => ORIGNAL_RAW,
    TYP => DBMS_CRYPTO.DES_CBC_PKCS5,
    KEY => KEY_DATA_RAW,
    IV => NULL);
    -- =>는 := 과 같은 의미로 본다.
    RETURN ENCRYTED_RAW; -- 암호화 결과를 리턴.
    END FUNC_ENCRYPT;

    FUNCTION FUNC_DECRYPT -- 복호화 하는 함수
    (INPUT_STRING IN VARCHAR2)
    RETURN VARCHAR2
    IS
    KEY_DATA_RAW RAW(64);
    DECRYPTED_RAW RAW(64);
    CONVERTED_STRING VARCHAR2(64);
    BEGIN
    KEY_DATA_RAW := UTL_I18N.STRING_TO_RAW('HeendyUser01$', 'AL32UTF8');
    DECRYPTED_RAW := DBMS_CRYPTO.DECRYPT(SRC => INPUT_STRING,
    TYP => DBMS_CRYPTO.DES_CBC_PKCS5,
    KEY => KEY_DATA_RAW,
    IV => NULL);
    -- RAW 타입을 STRING 타입으로 변경( 복호화한 결과를 varchar2로 변환해서 converted_string에 넣음)
    CONVERTED_STRING := UTL_I18N.RAW_TO_CHAR(DECRYPTED_RAW, 'AL32UTF8');
    RETURN CONVERTED_STRING; -- 복호화된 결과를 리턴
    END FUNC_DECRYPT; -- 복호화 함수 종료
END PACK_ENCRYPTION_DECRYPTION;

/
--------------------------------------------------------
--  DDL for Package Body PKG_CART
--  @Author 이승준
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY PKG_CART 
is
    /* 장바구니 리스트 */
    --------------------------------------------------------
    --  @Author 이승준
    --  장바구니 리스트 조회
    -------------------------------------------------------- 
    PROCEDURE sp_select_cart_list (
    p_member_id member.member_id%TYPE,
    p_result OUT sys_refcursor)
    IS 
    BEGIN
        OPEN p_result FOR
        SELECT 
            c.cart_id cart_id, 
            c.product_id product_id, 
            c.company_id company_id, 
            c.cart_count cart_count,
            p.product_count product_count,
            p.product_name product_name,
            p.image_url image_url,
            p.product_price product_price,
            p.discount_price discount_price,
            p.deleted deleted 
        FROM cart c, product p
        WHERE  
            c.member_id = p_member_id AND
            c.product_id = p.product_id AND
            c.company_id = p.company_id;
    END;	
    
    /* 장바구니 생성 */
    --------------------------------------------------------
    --  @Author 이승준
    --  장바구니 생성
    -------------------------------------------------------- 
    PROCEDURE sp_create_cart 
    (p_productId cart.PRODUCT_ID%TYPE, p_companyId cart.COMPANY_ID%TYPE, p_memberID cart.MEMBER_ID%TYPE, p_count cart.CART_COUNT%TYPE)
    IS 
        v_count NUMBER := 0;
        v_product_count product.product_count%TYPE;
        
        ALREADY_CART_EXIST EXCEPTION;
        PRAGMA EXCEPTION_INIT(ALREADY_CART_EXIST,-20000);
    
        LACK_OF_STOCK EXCEPTION;
        PRAGMA EXCEPTION_INIT(LACK_OF_STOCK,-20001);	
    BEGIN 
        
        
        /*해당 사용자가 담을려는 상품이 이미 장바구니에 있는지 확인*/
        SELECT count(*) INTO v_count FROM cart 
            WHERE MEMBER_ID = p_memberID  AND PRODUCT_ID = p_productId  AND COMPANY_ID = p_companyId;
        
        /*이미 장바구니에 상품이 있으면 예외 발생*/
        IF v_count >= 1 THEN
            RAISE ALREADY_CART_EXIST;
        END IF;
    
        /*상품 재고 조회*/
        SELECT PRODUCT_COUNT INTO v_product_count 
        FROM PRODUCT 
        WHERE 
            PRODUCT_ID = p_productId AND COMPANY_ID = p_companyId;
        
        IF p_count > v_product_count THEN 
            RAISE LACK_OF_STOCK;
        END IF;
        
        /*장바구니에 상품이 없을시 상품 추가*/
        INSERT INTO CART(PRODUCT_ID, COMPANY_ID, MEMBER_ID, CART_COUNT) VALUES(p_productId,p_companyId,p_memberID,p_count); 
    
        COMMIT;
    
        EXCEPTION 
            WHEN ALREADY_CART_EXIST THEN
                DBMS_OUTPUT.PUT_LINE('ORA'||SQLCODE||': 이미 장바구니에 같은 물품이 존재합니다.' );
                RAISE_APPLICATION_ERROR(SQLCODE,'이미 장바구니에 같은 물품이 존재합니다.');
                ROLLBACK;
            WHEN LACK_OF_STOCK THEN 
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE('ORA'||SQLCODE||': 상품 재고가 부족합니다.' );
                RAISE_APPLICATION_ERROR(SQLCODE,'상품 재고가 부족합니다.');
            WHEN OTHERS THEN
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE('ORA'||SQLCODE||': '||SQLERRM);
                RAISE;            
    END;
    
    /* 장바구니 삭제 */
    --------------------------------------------------------
    --  @Author 이승준
    --  장바구니 삭제
    -------------------------------------------------------- 
    PROCEDURE sp_delete_cart (
    p_cart_id CART.CART_ID%TYPE,
    p_member_id MEMBER.MEMBER_ID%TYPE)
    IS 
        v_cart_member_id CART.MEMBER_ID%TYPE;
    
        NOT_RESOURCE_OWNER EXCEPTION;
        PRAGMA EXCEPTION_INIT(NOT_RESOURCE_OWNER,-20090);
    BEGIN
        
        SELECT MEMBER_ID INTO v_cart_member_id 
        FROM CART 
        WHERE CART_ID = p_cart_id FOR UPDATE;
    
        /*삭제하려는 장바구니가 요청한 사용자와 생성한 사용자와 일치하는지 확인*/
        IF v_cart_member_id != p_member_id THEN 
            RAISE NOT_RESOURCE_OWNER;
        END IF;
        
        DELETE FROM CART WHERE CART_ID = p_cart_id;
        COMMIT;
    
        EXCEPTION 
            WHEN NOT_RESOURCE_OWNER THEN
                ROLLBACK ;
                DBMS_OUTPUT.PUT_LINE('ORA'||SQLCODE||': 해당 리소스의 소유자가 아닙니다.' );
                RAISE_APPLICATION_ERROR(SQLCODE,'해당 리소스의 소유자가 아닙니다.');
            WHEN OTHERS THEN 
                ROLLBACK;
                RAISE;		
    END;
    
    /* 장바구니 수량 추가 */
    --------------------------------------------------------
    --  @Author 이승준
    --  장바구니 수량 증가
    -------------------------------------------------------- 
    PROCEDURE sp_add_cart
    (p_cart_id CART.CART_ID%TYPE, 
    p_cart_count CART.CART_COUNT%TYPE,
    p_member_id MEMBER.MEMBER_ID%TYPE 
    )
    IS
        TYPE cart_info_type IS RECORD (
            cart_id cart.CART_ID%TYPE,
            product_id cart.PRODUCT_ID%TYPE,
            company_id cart.COMPANY_ID%TYPE,
            cart_count cart.CART_COUNT%TYPE,
            member_id cart.MEMBER_ID%TYPE
        ); 
    
        v_cart_info cart_info_type;
        v_product_count PRODUCT.PRODUCT_ID%TYPE := 0;
        v_cart_count CART.CART_COUNT%TYPE := 0;
    
        LACK_OF_STOCK EXCEPTION;
        PRAGMA EXCEPTION_INIT(LACK_OF_STOCK,-20001);	
    
        NOT_RESOURCE_OWNER EXCEPTION;
        PRAGMA EXCEPTION_INIT(NOT_RESOURCE_OWNER,-20090);	
    BEGIN 
    
        SELECT CART_ID, PRODUCT_ID, COMPANY_ID, CART_COUNT, MEMBER_ID INTO v_cart_info 
        FROM CART WHERE CART_ID = p_cart_id FOR UPDATE;
    
        /*장바구니 소유자와 변경을 요청한 사용자와 같은지 확인*/
        IF v_cart_info.member_id != p_member_id THEN 
            RAISE NOT_RESOURCE_OWNER;
        END IF;
    
        v_cart_count := v_cart_info.cart_count;
        
        /*상품 재고 조회*/
        SELECT PRODUCT_COUNT INTO v_product_count 
        FROM PRODUCT 
        WHERE 
            PRODUCT_ID = v_cart_info.product_id AND COMPANY_ID = v_cart_info.company_id;
        
        v_cart_count := v_cart_count + p_cart_count;
        
        /*
         * 1. 현재 상품재고와 장바구니에 담을려는 수량 비교
         * 2. 현재 상품재고보다 장바구니에 담을려는 수량이 많을 시 예외 발생
         * */
        IF v_cart_count > v_product_count THEN 
            RAISE LACK_OF_STOCK;
        END IF;
        
        UPDATE CART SET CART_COUNT = v_cart_count WHERE CART_ID = p_cart_id;
        
        COMMIT;
    
        EXCEPTION 
            WHEN NOT_RESOURCE_OWNER THEN 
                ROLLBACK ;
                DBMS_OUTPUT.PUT_LINE('ORA'||SQLCODE||': 해당 리소스의 소유자가 아닙니다.' );
                RAISE_APPLICATION_ERROR(SQLCODE,'해당 리소스의 소유자가 아닙니다.');
            WHEN LACK_OF_STOCK THEN 
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE('ORA'||SQLCODE||': 상품 재고가 부족합니다.' );
                RAISE_APPLICATION_ERROR(SQLCODE,'상품 재고가 부족합니다.');
            WHEN OTHERS THEN
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE('ORA'||SQLCODE||': '||SQLERRM);
                RAISE;
    END;
    
    /* 장바구니 수량 감소 */
    --------------------------------------------------------
    --  @Author 이승준
    --  장바구니 수량 감소
    -------------------------------------------------------- 
    PROCEDURE sp_minus_cart (
    p_cart_id CART.CART_ID%TYPE,
    p_cart_count CART.CART_COUNT%TYPE,
    p_member_id  MEMBER.MEMBER_ID%TYPE)
    IS 
        TYPE cart_info_type IS RECORD (
            cart_count CART.CART_COUNT%TYPE,
            member_id CART.MEMBER_ID%TYPE
        );
        
        v_cart_info cart_info_type;
        v_cart_count CART.CART_COUNT%TYPE := 0;
    
        OUT_BOUND_RANGE EXCEPTION;
        PRAGMA EXCEPTION_INIT(OUT_BOUND_RANGE,-20002);	
    
        NOT_RESOURCE_OWNER EXCEPTION;
        PRAGMA EXCEPTION_INIT(NOT_RESOURCE_OWNER,-20090);	
    BEGIN 
        SELECT CART_COUNT, MEMBER_ID  INTO v_cart_info 
        FROM CART 
        WHERE CART_ID = p_cart_id FOR UPDATE;
    
        IF v_cart_info.member_id != p_member_id THEN
            RAISE NOT_RESOURCE_OWNER;
        END IF;
        
        v_cart_count := v_cart_info.cart_count - p_cart_count;
    
        IF v_cart_count < 1 THEN 
            RAISE OUT_BOUND_RANGE;
        END IF;
    
        UPDATE CART SET CART_COUNT = v_cart_count WHERE CART_ID = p_cart_id;
    
        COMMIT;
        EXCEPTION 
            WHEN NOT_RESOURCE_OWNER THEN 
                ROLLBACK ;
                DBMS_OUTPUT.PUT_LINE('ORA'||SQLCODE||': 해당 리소스의 소유자가 아닙니다.' );
                RAISE_APPLICATION_ERROR(SQLCODE,'해당 리소스의 소유자가 아닙니다.');
            WHEN OUT_BOUND_RANGE THEN 
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE('ORA'||SQLCODE||': 최소 1개 이상 장바구니에 담아야 합니다.' );
                RAISE_APPLICATION_ERROR(SQLCODE,'최소 1개 이상 장바구니에 담아야 합니다.');
            WHEN OTHERS THEN 
                ROLLBACK;
                RAISE;
    END; 
end;

/
--------------------------------------------------------
--  DDL for Package Body PKG_COMPANY
--  @Author 김시은
--  업체 회원 페이지의 차트를 구현하기위한 데이터를 불러옴
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY PKG_COMPANY 
is
    /* 구매자 연령층 */
    PROCEDURE SP_MEMBER_AGEINFO (
     p_company_id product_order.company_id%type,
     p_member_ageinfo out sys_refcursor
     )
     is
     begin
        /* 업체 상품 구매자의 회원 연령 */
        open p_member_ageinfo for
            select sorting, count(*) as count
            from(select member_id, age, case when age < 20 then '10대'
            when age < 30 then '20대'
            when age < 40 then '30대'
            when age < 50 then '40대'
            when age < 60 then '50대'
            else '60대 이상'
            end sorting
            from (select member_id, TRUNC(MONTHS_BETWEEN(SYSDATE, TO_DATE(BIRTH_DATE, 'YYYY-MM-DD'))/12)+1 as age /* 나이구하기 : 두 날짜 사이의 년수 계산 */
            /* 주문내역 중 company_id가 cid인 것의 member_id의 birth_date를 조인*/
            from (select o.member_id, company_id, birth_date from product_order o left join member m on o.member_id = m.member_id where company_id = p_company_id)))
            group by sorting order by count desc;
    END;

    /* 상품 판매량 */
    PROCEDURE SP_PRODUCT_ORDERINFO (
     p_company_id product_order.company_id%type,
     p_product_id product_order.product_id%type,
     p_date_sort varchar2,
     p_product_orderinfo out sys_refcursor
     )
     is
     begin
        /* product_id가 0이면 전체 상품으로 */
        if p_product_id = 0 then        
            /* 날짜별 구매 개수 */ 
            open p_product_orderinfo for
                select order_time as sorting, count(*) count
                from (select to_char(order_time, p_date_sort) as order_time from product_order where company_id = p_company_id) 
                group by order_time 
                order by order_time;
        else
            /* 상품별로 조회할 경우 */
            /* 날짜별 구매 개수 */ 
            open p_product_orderinfo for
                select order_time as sorting, count(*) count
                from (select to_char(order_time, p_date_sort) as order_time from product_order where company_id = p_company_id and product_id = p_product_id) 
                group by order_time 
                order by order_time;
        end if;
    END;
end;

/
--------------------------------------------------------
--  DDL for Package Body PKG_MEMBER
--  @Author 문석호, 이지민
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY PKG_MEMBER 
is
    --일반 회원 가입
    PROCEDURE sp_add_member
    (p_member_name MEMBER.MEMBER_NAME%TYPE, 
    p_member_password MEMBER.member_password%TYPE, 
    p_member_email MEMBER.member_email%TYPE, 
    p_address MEMBER.address%TYPE, 
    p_role_id MEMBER.role_id%TYPE,
    p_birth_date MEMBER.birth_date%TYPE)
    IS
    BEGIN
        INSERT INTO MEMBER(
            MEMBER_NAME, 
            member_password, 
            member_email, 
            address, 
            role_id, 
            birth_date)
        VALUES(
        p_member_name, 
        pack_crypto.func_encrypt(p_member_password), 
        p_member_email, 
        p_address, 
        p_role_id,
        p_birth_date);
        commit;
    END;

    -- 일반 회원 로그인
    PROCEDURE sp_member_IsExisted
    (p_member_name MEMBER.MEMBER_NAME%TYPE, 
    p_member_password MEMBER.member_password%TYPE,
    v_member_out out integer
    )
    IS
    BEGIN
        select decode(count(*), 1, 1, 0) as result into v_member_out
        from member
        where member_name=p_member_name 
        and 
        member_password=pack_crypto.func_encrypt(p_member_password);
    END;

    --일반 회원 비밀번호 찾기
    PROCEDURE sp_member_findPw
    (p_member_name MEMBER.MEMBER_NAME%TYPE, 
    p_member_email MEMBER.member_email%TYPE,
    v_member_pw_out out varchar2
    )
    IS
    BEGIN
        select pack_crypto.func_decrypt(member_password) into v_member_pw_out
        from member
        where member_name=p_member_name 
        and 
        member_email=p_member_email;
        
    END;

    --일반 회원 아이디 찾기
    PROCEDURE sp_member_findId
    (p_member_email MEMBER.member_email%TYPE,
    v_member_id_out out varchar2
    )
    IS
    BEGIN
        select member_name into v_member_id_out
        from member
        where member_email=p_member_email;
    END;

    --일반 회원 아이디 중복체크
    PROCEDURE sp_member_duplicatedId
    (p_member_name MEMBER.member_name%TYPE,
    v_member_idCheck out integer
    )
    IS
    BEGIN
        select count(*) into v_member_idCheck 
        from member
        where member_name=p_member_name;
    END;

    -- 일반 회원 정보 불러오기
    PROCEDURE sp_member_getmember
    (p_member_name MEMBER.member_name%TYPE,
    v_member_info_out out SYS_REFCURSOR
    )
    IS
    BEGIN
        /*회원 정보 조회*/
        open v_member_info_out for
            select *
            from member
            where member_name=p_member_name;
    END;


--------------------------------------------------------
--  @Author 이지민
--  회원의 포인트를 불러오는 Procedure
--------------------------------------------------------

    -- 일반 회원 포인트 조회
    procedure sp_select_member_point (
    p_memberId member.member_id%type,
    p_point out Number
    )
    is
    begin
        select point into p_point
        from member
        where member_id = p_memberId;
    end;


    --업체 회원 회원가입
     procedure sp_add_company_member
    (p_company_name company_member.company_name%type,
    p_company_password company_member.company_password%type,
    p_company_tel company_member.company_tel%type,
    p_company_email company_member.company_email%type,
    p_role_id company_member.role_id%type)
    is

    begin 
    insert into company_member(company_name, company_password, company_tel, company_email, role_id)
    values(p_company_name, pack_crypto.func_encrypt(p_company_password), p_company_tel, p_company_email, p_role_id);
    commit;
    end;
    -- 업체 회원 아이디 중복 확인
    PROCEDURE sp_company_duplicatedId
    (p_company_name company_member.company_name%TYPE,
    v_company_idCheck out Integer
    )
    IS
    BEGIN
        select count(*) into v_company_idCheck 
        from company_member
        where company_name=p_company_name;
    END;  
    --업체 회원 로그인
    PROCEDURE sp_company_isExisted
    (p_company_name company_member.company_name%TYPE,
    p_company_password company_member.company_password%type,
    v_company_out out Integer
    )
    IS
    BEGIN
        select decode(count(*), 1, 1, 0) as result into v_company_out
        from company_member
        where company_name=p_company_name 
        and 
        company_password=pack_crypto.func_encrypt(p_company_password);
    END;  
    --업체 회원 정보 가져오기
    PROCEDURE sp_company_getcompany
    (p_company_name company_member.company_name%TYPE,
    v_company_info_out out sys_refcursor
    )
    IS
    BEGIN

        open v_company_info_out for
            select *
            from company_member
            where company_name=p_company_name;
    END;
end;

/
--------------------------------------------------------
--  DDL for Package Body PKG_ORDER
-- @Author 이승준, 이지민
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY PKG_ORDER 
is
   
--------------------------------------------------------
--  @Author 이지민
--  멤버 아이디를 받아 주문내역 목록 조회하기
-------------------------------------------------------- 
    /* 주문내역 리스트 */
    procedure sp_list_order (
    p_beginRow Number,
    p_endRow Number,
    p_memberId product_order.member_id%type,
    p_list_order out sys_refcursor
    )
    is
    
    begin 
	/* 업체, 상품, 멤버 테이블 조인 */   
        open p_list_order for 
        select S.*
        from
        (select rownum as rn, p.product_name, p.image_url, p.product_price, po.*, cm.company_name 
        from product p, product_order po, company_member cm 
        where po.product_id = p.product_id and po.company_id = cm.company_id and po.member_id = p_memberId 
        order by po.order_time desc) S 
        where S.rn between p_beginRow and p_endRow;   
    end;
    
    /* 주문내역 생성(바로주문) */
    --------------------------------------------------------
    --  @Author 이승준
    --  상품 주문내역 생성
    -------------------------------------------------------- 
    PROCEDURE sp_create_order (
    p_product_id product.product_id%TYPE,
    p_company_id product.company_id%TYPE,
    p_member_id MEMBER.MEMBER_ID%TYPE,
    p_order_count PRODUCT_ORDER.ORDER_COUNT%TYPE)
    IS 
        TYPE prouduct_info_type IS RECORD (
            product_id PRODUCT.PRODUCT_ID%TYPE,
            company_id PRODUCT.COMPANY_ID%TYPE,
            product_price PRODUCT.PRODUCT_PRICE%TYPE, /*할인 된 가격으로*/
            product_count PRODUCT.PRODUCT_COUNT%TYPE
        );
        
        v_product_info prouduct_info_type;
        v_member_point member.point%TYPE;
        v_point_percent NUMBER := 0.05; /*패키지에서 패키지 변수로 추후 변경할것*/
    
        LACK_OF_STOCK EXCEPTION;
        PRAGMA EXCEPTION_INIT(LACK_OF_STOCK,-20001);	
    BEGIN 
        SELECT point INTO v_member_point
        FROM member WHERE member_id = p_member_id FOR UPDATE;
        
        SELECT product_id, company_id, discount_price, product_count INTO v_product_info
        FROM product
        WHERE product_id = p_product_id AND company_id = p_company_id AND deleted = 0 FOR UPDATE;
         
        /*상품 재고보다 주문 수량이 많을 경우 예외 발생*/
        IF v_product_info.product_count < p_order_count THEN
            RAISE LACK_OF_STOCK;
        END IF;
    
        /*상품 재고 수정*/
        UPDATE product SET product_count = (v_product_info.product_count - p_order_count)
        WHERE product_id = p_product_id AND company_id = p_company_id;
    
        /*주문 내역 생성*/
        INSERT INTO product_order(member_id, order_count, order_price, product_id, company_id)
        values(
            p_member_id, 
            p_order_count, 
            v_product_info.product_price, 
            v_product_info.product_id, 
            v_product_info.company_id);
        
        /*멤버 포인트 증가*/
        UPDATE member 
        SET point = (v_member_point + v_product_info.product_price * v_point_percent) 
        WHERE member_id = p_member_id;
    
        COMMIT;
        
        EXCEPTION 
        WHEN LACK_OF_STOCK THEN 
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('ORA'||SQLCODE||': 상품 재고가 부족합니다.' );
            RAISE_APPLICATION_ERROR(SQLCODE,'상품 재고가 부족합니다.');
        WHEN OTHERS THEN 
            ROLLBACK;
            RAISE;
    END;
    
    /* 주문내역 생성(장바구니 주문) */
    --------------------------------------------------------
    --  @Author 이승준
    --  선택된 장바구니 리스트 전체 주문 내역 생성
    -------------------------------------------------------- 
    PROCEDURE sp_create_order_from_cart (
	p_member_id member.member_id%TYPE,
	p_cart_array cartIdsArray 
    )
    IS
        TYPE prouduct_info_type IS RECORD (
            product_id PRODUCT.PRODUCT_ID%TYPE,
            company_id PRODUCT.COMPANY_ID%TYPE,
            product_price PRODUCT.PRODUCT_PRICE%TYPE, /*할인 된 가격으로*/
            product_count PRODUCT.PRODUCT_COUNT%TYPE
        );
    
        TYPE cart_info_type IS RECORD (
            cart_id cart.cart_id%TYPE,
            member_id cart.member_id%TYPE,
            product_id cart.product_id%TYPE,
            company_id cart.company_id%TYPE,
            cart_count cart.cart_count%TYPE 
        );
                
        v_product_info prouduct_info_type;
        v_cart_info cart_info_type;
        v_member_point member.point%TYPE;
        v_point_percent NUMBER := 0.05; /*패키지에서 패키지 변수로 추후 변경할것*/
        
        v_product_id product.product_id%TYPE;
        v_company_id product.company_id%TYPE;
        v_order_count cart.cart_count%TYPE;
    
        LACK_OF_STOCK EXCEPTION;
        PRAGMA EXCEPTION_INIT(LACK_OF_STOCK,-20001);	
    
        NOT_RESOURCE_OWNER EXCEPTION;
        PRAGMA EXCEPTION_INIT(NOT_RESOURCE_OWNER,-20090);
    BEGIN 
        SELECT point INTO v_member_point
        FROM member WHERE member_id = p_member_id FOR UPDATE;
     
        FOR i IN 1 .. p_cart_array.count LOOP
            SELECT cart_id, member_id, product_id, company_id, cart_count INTO v_cart_info 
            FROM cart WHERE cart_id = p_cart_array(i) FOR UPDATE;
            
            /*장바구니 소유자와 요청한 유저와 다를시 예외 발생*/
            IF p_member_id != v_cart_info.member_id THEN 
                RAISE NOT_RESOURCE_OWNER;
            END IF;
        
            v_product_id := v_cart_info.product_id;
            v_company_id := v_cart_info.company_id;
            v_order_count := v_cart_info.cart_count;
            
            /*상품 정보 조회*/
            SELECT product_id, company_id, discount_price, product_count INTO v_product_info
            FROM product
            WHERE product_id = v_product_id AND company_id = v_company_id AND deleted = 0 FOR UPDATE;
         
            /*상품 재고보다 주문 수량이 많을 경우 예외 발생*/
            IF v_product_info.product_count < v_order_count THEN
                RAISE LACK_OF_STOCK;
            END IF;
    
            /*상품 재고 수정*/
            UPDATE product SET product_count = (v_product_info.product_count - v_order_count)
            WHERE product_id = v_product_id AND company_id = v_company_id;
    
            /*주문 내역 생성*/
            INSERT INTO product_order(member_id, order_count, order_price, product_id, company_id)
            values(
                p_member_id, 
                v_order_count, 
                v_product_info.product_price, 
                v_product_info.product_id, 
                v_product_info.company_id);
        
            /*멤버 포인트 증가*/
            UPDATE member 
            SET point = (v_member_point + v_product_info.product_price * v_point_percent) 
            WHERE member_id = p_member_id;
            
            DELETE FROM cart WHERE cart_id = v_cart_info.cart_id;
        END LOOP;
        
        COMMIT;
    
        EXCEPTION 
            WHEN NOT_RESOURCE_OWNER THEN
                ROLLBACK ;
                DBMS_OUTPUT.PUT_LINE('ORA'||SQLCODE||': 해당 리소스의 소유자가 아닙니다.' );
                RAISE_APPLICATION_ERROR(SQLCODE,'해당 리소스의 소유자가 아닙니다.');
            WHEN LACK_OF_STOCK THEN 
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE(v_cart_info.cart_id);
                DBMS_OUTPUT.PUT_LINE('ORA'||SQLCODE||': 상품 재고가 부족합니다.' );
                RAISE_APPLICATION_ERROR(SQLCODE,'상품 재고가 부족합니다.');
            WHEN OTHERS THEN 
                ROLLBACK;
                RAISE;
    END;


    --------------------------------------------------------
    --  @Author 이지민
    --  페이지네이션을 위한 총 주문내역 개수 가져오기
    --------------------------------------------------------  
    /* 총 주문내역 개수 */
    procedure sp_totalcount_order (
    p_memberId product_order.member_id%type,
    p_totalCount out Number
    )
    is
    begin
        select count(*) into p_totalCount
        from product_order 
        where member_id = p_memberId;
    end;
end;

/
--------------------------------------------------------
--  DDL for Package Body PKG_PRODUCT
--  @Author 김시은, 이지민, 이승준
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY PKG_PRODUCT 
is

--------------------------------------------------------
--  @Author 김시은
--  메뉴별로 정렬기준을 가져와 화면에 보여줄 상품 리스트를 가져옴
--------------------------------------------------------
    /* 상품 리스트 */
    procedure sp_list_product
    (p_beginRow Number,
     p_endRow Number,
     p_sort varchar2,
     p_menu VARCHAR2,
     p_cate v_product.category_id%type,
     p_parent_cate v_product.parent_category_id%type,
     p_list_product out sys_refcursor)
    is
        sqlNewprod varchar2(10000);
        sqlSale varchar2(10000);
        sqlCategory1 varchar2(10000);
        sqlCategory2 varchar2(10000);
    begin
        /* 신상품 => 전체 상품 출력 */
        if p_menu = 'newprod' then
            sqlNewprod := 'select *
                from (select row_number() over(order by ' || p_sort || ') as rnum, p.* from v_product p where deleted = 0) 
                where rnum between ' || p_beginRow || ' and ' || p_endRow;
            open p_list_product for
                sqlNewprod;
        /* sale => 할인 상품만 출력 */
        elsif p_menu = 'sale' then
             sqlSale := 'select *
                from (select row_number() over(order by ' || p_sort || ') as rnum, p.* from v_product p where discount_rate > 0 and deleted = 0) 
                where rnum between ' || p_beginRow || ' and ' || p_endRow;
            open p_list_product for
                sqlSale;
        /* best => 상위 30개 상품 출력 */
        elsif p_menu = 'best' then
            open p_list_product for
                select *
                from (select row_number() over(order by like_count desc) as rnum, p.* from v_product p where deleted = 0) 
                where rnum between p_beginRow and p_endRow;
        /* category => 카테고리별로 출력 */
        elsif p_menu = 'category' then
            if p_cate = p_parent_cate then
            sqlCategory1 := 'select *
                    from (select row_number() over(order by ' || p_sort || ') as rnum, p.* from v_product p where deleted = 0 and parent_category_id = ' || p_parent_cate||') 
                    where rnum between ' || p_beginRow || ' and ' || p_endRow;
                open p_list_product for
                    sqlCategory1;
            else
            sqlCategory2 := 'select *
                    from (select row_number() over(order by ' || p_sort || ') as rnum, p.* from v_product p where deleted = 0 and category_id = '||p_cate||' and parent_category_id = '||p_parent_cate||') 
                    where rnum between ' || p_beginRow || ' and ' || p_endRow;
                open p_list_product for
                    sqlCategory2;
            end if;
        end if;
    end;
    
    
--------------------------------------------------------
--  @Author 김시은
--  업체회원의 아이디로 업체별 상품 목록을 가져옴
--------------------------------------------------------
     /* 업체별 상품 목록 */
    PROCEDURE SP_COMPANY_PRODUCT (
     p_company_id product_order.company_id%type,
     p_company_product out sys_refcursor
     )
     is
     begin
        /* 업체별 상품 목록 */ 
        open p_company_product for
            select *
            from v_product
            where company_id = p_company_id
            order by product_id;
    END;


--------------------------------------------------------
--  @Author 김시은
--  상품 상세보기 페이지의 상품 정보를 보여주기 위해 v_product에서 상품 정보를 가져옴
--------------------------------------------------------
    /* 상품 정보 */
    procedure sp_select_product
    (p_product_id v_product.product_id%type,
     p_company_id v_product.company_id%type,
     p_result out sys_refcursor)
    is
        v_deleted product.deleted%type := 0;

        ALREADY_DELETED_PRODUCT EXCEPTION;
        PRAGMA EXCEPTION_INIT(ALREADY_DELETED_PRODUCT,-20200);
    begin
        /* 상품이 삭제되었는지 조회 */
        select deleted into v_deleted
        from v_product 
        where product_id = p_product_id and company_id = p_company_id;

        if v_deleted = 1 then 
            raise ALREADY_DELETED_PRODUCT;
        end if;

        /* 상품 상세 조회 */
        open p_result for
            select *
            from v_product 
            where product_id = p_product_id and company_id = p_company_id and deleted = 0;

        EXCEPTION 
            WHEN ALREADY_DELETED_PRODUCT THEN
                ROLLBACK ;
                DBMS_OUTPUT.PUT_LINE('ORA'||SQLCODE||': 존재하지 않는 상품입니다.' );
                RAISE_APPLICATION_ERROR(SQLCODE,'존재하지 않는 상품입니다.');
            WHEN OTHERS THEN 
                ROLLBACK;
                RAISE;
    end;

--------------------------------------------------------
--  @Author 김시은
--  pagination을 위한 상품 전체 개수 가져오기
--------------------------------------------------------
    /* 상품 전체 개수 */
    PROCEDURE SP_TOTALCOUNT_PRODUCT 
    (p_menu VARCHAR2,
     p_cate v_product.category_id%type,
     p_parent_cate v_product.parent_category_id%type,
     p_totalcount out Number)
    is
    begin
        /* 신상품 => 전체 상품 개수 출력 */
        if p_menu = 'newprod' then
            select count(*) into p_totalcount
            from v_product
            where deleted = 0;
        /* sale => 할인 상품 개수 출력 */
        elsif p_menu = 'sale' then
            select count(*) into p_totalcount
            from v_product
            where discount_rate > 0 and deleted = 0;
        /* best => 상위 30개 상품 출력 */
        elsif p_menu = 'best' then
            p_totalcount := 30;
        elsif p_menu = 'category' then
            if p_cate = p_parent_cate then
                select count(*) into p_totalcount
                from v_product
                where parent_category_id = p_parent_cate;
            else
                select count(*) into p_totalcount
                from v_product
                where category_id = p_cate and parent_category_id = p_parent_cate;
            end if;
        end if;
    end;

    /* 상품 등록 */
    --------------------------------------------------------
    --  @Author 이승준
    --  상품 생성 
    -------------------------------------------------------- 
    PROCEDURE sp_create_product(
    p_companyId company_member.company_id%TYPE,
    p_product_name product.product_name%TYPE,
    p_product_price product.product_price%TYPE,
    p_discount_rate product.discount_rate%TYPE,
    p_product_count product.product_count%TYPE,
    p_image_url product.image_url%TYPE,
    p_category_id category.category_id%TYPE
    )
    IS 
    BEGIN 
        INSERT INTO product(
            company_id, 
            product_name, 
            product_price,
            discount_rate,
            product_count,
            image_url,
            category_id)
        values(
            p_companyId,
            p_product_name,
            p_product_price,
            p_discount_rate,
            p_product_count,
            p_image_url,
            p_category_id);
    END;

--------------------------------------------------------
--  @Author 이지민
--  최근 본 상품 아이디 배열을 받아 해당 상품들 데이터 반환하기 
--------------------------------------------------------
    
    /* 최근 본 상품 목록 */
    procedure sp_list_recent_view_product (
    p_recent_view_array recentViewProductIdsArray,
    p_list_recent_view_product out sys_refcursor)
    is    
    begin
        /* 커스텀 타입 사용 recentViewProductIdsArray */
        open p_list_recent_view_product for
     
        select product_id, company_id, product_name, image_url, product_price, discount_price, product_count, deleted
        from product
        where product_id in
        (select * from table(p_recent_view_array));
    
    end;
end;

/
--------------------------------------------------------
--  DDL for Package Body PKG_WISH
--  @Author 김시은, 이지민
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY PKG_WISH 
is

--------------------------------------------------------
--  @Author 김시은
--------------------------------------------------------
    /* 좋아요 여부 */
    procedure sp_check_wish(
     p_member_id member_like_product.member_id%type,
     p_product_id member_like_product.product_id%type,
     p_company_id member_like_product.company_id%type,
     p_count out number
     )
     is
     begin
        /* 사용자가 좋아요 눌렀는지 여부 */
        select count(*) into p_count
        from member_like_product 
        where member_id = p_member_id and product_id = p_product_id and company_id = p_company_id;
    end;

--------------------------------------------------------
--  @Author 김시은
--------------------------------------------------------
    /* 좋아요 삽입 */
    procedure sp_insert_wish(
     p_member_id member_like_product.member_id%type,
     p_product_id member_like_product.product_id%type,
     p_company_id member_like_product.company_id%type
     )
     is
        v_count NUMBER := 0;

        ALREADY_LIKE_EXIST EXCEPTION;
        PRAGMA EXCEPTION_INIT(ALREADY_LIKE_EXIST,-20100);
     begin
        /* 이미 좋아요가 되어 있는지 확인 */
        select count(*) into v_count
        from member_like_product
        where member_id = p_member_id and product_id = p_product_id and company_id = p_company_id;

        if v_count >= 1 then 
            raise ALREADY_LIKE_EXIST;
        end if;

        /* 좋아요 정보 삽입 */
        insert into member_like_product(member_id, product_id, company_id) 
        values(p_member_id, p_product_id, p_company_id);
        commit;

        EXCEPTION 
            WHEN ALREADY_LIKE_EXIST THEN
                ROLLBACK ;
                DBMS_OUTPUT.PUT_LINE('ORA'||SQLCODE||': 이미 좋아요 된 상품입니다.' );
                RAISE_APPLICATION_ERROR(SQLCODE,'이미 좋아요 된 상품입니다.');
            WHEN OTHERS THEN 
                ROLLBACK;
                RAISE;
    end;

--------------------------------------------------------
--  @Author 김시은
--------------------------------------------------------
    /* 좋아요 삭제 */
    procedure sp_delete_wish(
     p_member_id member_like_product.member_id%type,
     p_product_id member_like_product.product_id%type,
     p_company_id member_like_product.company_id%type
     )
     is
     begin
        /* 좋아요 삭제 */
        delete from member_like_product 
        where member_id = p_member_id and product_id = p_product_id and company_id = p_company_id;
        commit;

         EXCEPTION 
            WHEN OTHERS THEN 
                ROLLBACK;
                RAISE;
    end;

--------------------------------------------------------
--  @Author 이지민
--------------------------------------------------------

    /* 좋아요 리스트 */
    procedure sp_list_wish (
    p_beginRow Number,
    p_endRow Number,
    p_memberId member_like_product.member_id%type,
    p_list_wish out sys_refcursor
    )
    is
    begin
	/* 페이징을 처리하기 위해 rownum 사용 */
        open p_list_wish for
        select S.*
        from 
        (select rownum as rn, p.product_id, p.company_id, p.product_name, p.image_url, p.product_price, p.discount_price, p.product_count, p.deleted 
        from member_like_product mlp, product p 
        where mlp.product_id = p.product_id and mlp.member_id = p_memberId 
        order by rn desc) S 
        where S.rn between p_beginRow and p_endRow;

    end;

--------------------------------------------------------
--  @Author 이지민
--------------------------------------------------------
    
    /* 좋아요 총 개수 */
    procedure sp_totalcount_wish (
    p_memberId member_like_product.member_id%type,
    p_totalCount out Number
    )
    is
    begin
        select count(*) into p_totalCount
        from member_like_product 
        where member_id = p_memberId;
    end;
end;

/
--------------------------------------------------------
--  DDL for Synonymn PACK_CRYPTO
--  Author 문석호
--  패키지이름 길이를 줄이기 위한 시노님
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE SYNONYM PACK_CRYPTO FOR PACK_ENCRYPTION_DECRYPTION;
--------------------------------------------------------
--  Constraints for Table CART
--------------------------------------------------------

  ALTER TABLE CART MODIFY (CART_ID NOT NULL ENABLE);
  ALTER TABLE CART MODIFY (CART_COUNT NOT NULL ENABLE);
  ALTER TABLE CART MODIFY (PRODUCT_ID NOT NULL ENABLE);
  ALTER TABLE CART MODIFY (COMPANY_ID NOT NULL ENABLE);
  ALTER TABLE CART MODIFY (MEMBER_ID NOT NULL ENABLE);
  ALTER TABLE CART ADD CONSTRAINT PK_CART PRIMARY KEY (CART_ID);
--------------------------------------------------------
--  Constraints for Table CATEGORY
--------------------------------------------------------

  ALTER TABLE CATEGORY MODIFY (CATEGORY_ID NOT NULL ENABLE);
  ALTER TABLE CATEGORY ADD CONSTRAINT PK_CATEGORY PRIMARY KEY (CATEGORY_ID);
--------------------------------------------------------
--  Constraints for Table COMPANY_MEMBER
--------------------------------------------------------

  ALTER TABLE COMPANY_MEMBER MODIFY (COMPANY_ID NOT NULL ENABLE);
  ALTER TABLE COMPANY_MEMBER MODIFY (COMPANY_NAME NOT NULL ENABLE);
  ALTER TABLE COMPANY_MEMBER MODIFY (ROLE_ID NOT NULL ENABLE);
  ALTER TABLE COMPANY_MEMBER ADD CONSTRAINT PK_COMPANY_MEMBER PRIMARY KEY (COMPANY_ID);
  ALTER TABLE COMPANY_MEMBER MODIFY (COMPANY_TEL NOT NULL ENABLE);
  ALTER TABLE COMPANY_MEMBER MODIFY (COMPANY_EMAIL NOT NULL ENABLE);
  ALTER TABLE COMPANY_MEMBER MODIFY (COMPANY_PASSWORD NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table LOGIN_ROLE
--------------------------------------------------------

  ALTER TABLE LOGIN_ROLE MODIFY (ROLE_ID NOT NULL ENABLE);
  ALTER TABLE LOGIN_ROLE MODIFY (ROLE_NAME NOT NULL ENABLE);
  ALTER TABLE LOGIN_ROLE ADD CONSTRAINT PK_LOGIN_ROLE PRIMARY KEY (ROLE_ID);
--------------------------------------------------------
--  Constraints for Table MEMBER
--------------------------------------------------------

  ALTER TABLE MEMBER MODIFY (MEMBER_NAME NOT NULL ENABLE);
  ALTER TABLE MEMBER MODIFY (MEMBER_PASSWORD NOT NULL ENABLE);
  ALTER TABLE MEMBER MODIFY (MEMBER_EMAIL NOT NULL ENABLE);
  ALTER TABLE MEMBER MODIFY (ROLE_ID NOT NULL ENABLE);
  ALTER TABLE MEMBER ADD CONSTRAINT PK_MEMBER PRIMARY KEY (MEMBER_ID);
  ALTER TABLE MEMBER MODIFY (MEMBER_ID NOT NULL ENABLE);
  ALTER TABLE MEMBER MODIFY (BIRTH_DATE NOT NULL ENABLE);
  ALTER TABLE MEMBER ADD CONSTRAINT UK_MEMBER_NAME UNIQUE (MEMBER_NAME);
  ALTER TABLE MEMBER ADD CONSTRAINT UK_MEMBER_EMAIL UNIQUE (MEMBER_EMAIL);
--------------------------------------------------------
--  Constraints for Table MEMBER_LIKE_PRODUCT
--------------------------------------------------------

  ALTER TABLE MEMBER_LIKE_PRODUCT MODIFY (PRODUCT_ID NOT NULL ENABLE);
  ALTER TABLE MEMBER_LIKE_PRODUCT MODIFY (COMPANY_ID NOT NULL ENABLE);
  ALTER TABLE MEMBER_LIKE_PRODUCT ADD CONSTRAINT PK_LIKE PRIMARY KEY (MEMBER_ID, PRODUCT_ID, COMPANY_ID);
  ALTER TABLE MEMBER_LIKE_PRODUCT MODIFY (MEMBER_ID NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table PRODUCT
--------------------------------------------------------

  ALTER TABLE PRODUCT MODIFY (COMPANY_ID NOT NULL ENABLE);
  ALTER TABLE PRODUCT MODIFY (PRODUCT_PRICE NOT NULL ENABLE);
  ALTER TABLE PRODUCT MODIFY (PRODUCT_NAME NOT NULL ENABLE);
  ALTER TABLE PRODUCT MODIFY (IMAGE_URL NOT NULL ENABLE);
  ALTER TABLE PRODUCT MODIFY (PRODUCT_COUNT NOT NULL ENABLE);
  ALTER TABLE PRODUCT MODIFY (DISCOUNT_RATE NOT NULL ENABLE);
  ALTER TABLE PRODUCT MODIFY (DELETED NOT NULL ENABLE);
  ALTER TABLE PRODUCT MODIFY (CATEGORY_ID NOT NULL ENABLE);
  ALTER TABLE PRODUCT ADD CONSTRAINT PK_PRODUCT PRIMARY KEY (PRODUCT_ID, COMPANY_ID);
  ALTER TABLE PRODUCT MODIFY (PRODUCT_ID NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table PRODUCT_ORDER
--------------------------------------------------------

  ALTER TABLE PRODUCT_ORDER MODIFY (ORDER_ID NOT NULL ENABLE);
  ALTER TABLE PRODUCT_ORDER MODIFY (MEMBER_ID NOT NULL ENABLE);
  ALTER TABLE PRODUCT_ORDER MODIFY (ORDER_COUNT NOT NULL ENABLE);
  ALTER TABLE PRODUCT_ORDER MODIFY (ORDER_PRICE NOT NULL ENABLE);
  ALTER TABLE PRODUCT_ORDER MODIFY (PRODUCT_ID NOT NULL ENABLE);
  ALTER TABLE PRODUCT_ORDER MODIFY (COMPANY_ID NOT NULL ENABLE);
  ALTER TABLE PRODUCT_ORDER ADD CONSTRAINT PK_ORDER PRIMARY KEY (ORDER_ID, MEMBER_ID);
--------------------------------------------------------
--  Ref Constraints for Table CART
--------------------------------------------------------

  ALTER TABLE CART ADD CONSTRAINT FK_MEMBER_TO_CART_1 FOREIGN KEY (MEMBER_ID)
	  REFERENCES MEMBER(MEMBER_ID) ENABLE;
  ALTER TABLE CART ADD CONSTRAINT FK_PRODUCT_TO_CART FOREIGN KEY (PRODUCT_ID, COMPANY_ID)
	  REFERENCES PRODUCT (PRODUCT_ID, COMPANY_ID) ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table CATEGORY
--------------------------------------------------------

  ALTER TABLE CATEGORY ADD CONSTRAINT FK_CATEGORY_TO_CATEGORY_1 FOREIGN KEY (PARENT_CATEGORY_ID)
	  REFERENCES CATEGORY (CATEGORY_ID) ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table COMPANY_MEMBER
--------------------------------------------------------

  ALTER TABLE COMPANY_MEMBER ADD CONSTRAINT FK_ROLE_TO_COMPANY_MEMBER_1 FOREIGN KEY (ROLE_ID)
	  REFERENCES LOGIN_ROLE (ROLE_ID) ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table MEMBER
--------------------------------------------------------

  ALTER TABLE MEMBER ADD CONSTRAINT FK_ROLE_TO_MEMBER FOREIGN KEY (ROLE_ID)
	  REFERENCES LOGIN_ROLE (ROLE_ID) ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table MEMBER_LIKE_PRODUCT
--------------------------------------------------------

  ALTER TABLE MEMBER_LIKE_PRODUCT ADD CONSTRAINT FK_MEMBER_TO_LIKE_1 FOREIGN KEY (MEMBER_ID)
	  REFERENCES MEMBER (MEMBER_ID) ENABLE;
  ALTER TABLE MEMBER_LIKE_PRODUCT ADD CONSTRAINT FK_PRODUCT_TO_LIKE_1 FOREIGN KEY (PRODUCT_ID, COMPANY_ID)
	  REFERENCES PRODUCT (PRODUCT_ID, COMPANY_ID) ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table PRODUCT
--------------------------------------------------------

  ALTER TABLE PRODUCT ADD CONSTRAINT FK_COMPANY_MEMBER_TO_PRODUCT FOREIGN KEY (COMPANY_ID)
	  REFERENCES COMPANY_MEMBER (COMPANY_ID) ENABLE;
  ALTER TABLE PRODUCT ADD CONSTRAINT FK_CATEGORY_TO_PRODUCT_1 FOREIGN KEY (CATEGORY_ID)
	  REFERENCES CATEGORY (CATEGORY_ID) ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table PRODUCT_ORDER
--------------------------------------------------------

  ALTER TABLE PRODUCT_ORDER ADD CONSTRAINT FK_MEMBER_TO_ORDER_1 FOREIGN KEY (MEMBER_ID)
	  REFERENCES MEMBER (MEMBER_ID) ENABLE;
  ALTER TABLE PRODUCT_ORDER ADD CONSTRAINT FK_PRODUCT_TO_ORDER_1 FOREIGN KEY (PRODUCT_ID, COMPANY_ID)
	  REFERENCES PRODUCT (PRODUCT_ID, COMPANY_ID) ENABLE;


