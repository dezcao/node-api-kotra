/**********************************************************/
/* FILE NAME : user.sql                                   */
/* FILE DESC : 사용자 관련 SQL                            */
/**********************************************************/

<% if ( sql_id === 'SIGNUP_USER' ) {%>
/**
 * SQL ID  : SIGNUP_USER
 * DESC.   : ERP 사용자 신규 등록
 * COMMENT :
 * HISTORY : 2021.06.21 / 쿼리 정의
 * WRITER  : asdaisy
 */
INSERT INTO user(user_id, email, user_pw, user_nm, mobile, address, address_detail)
SELECT :user_id, :email, :user_pw, :user_nm, :mobile, :address, :address_detail
FROM dual
WHERE NOT EXISTS(SELECT * FROM user WHERE email = :email);
<% } %>

<% if ( sql_id === 'LOGIN_USER' ) {%>
/**
 * SQL ID  : LOGIN_USER
 * DESC.   : 사용자 로그인
 * COMMENT :
 * HISTORY : 2021.06.21 / 쿼리 정의
 * WRITER  : asdaisy
 */
SELECT a.user_id
      ,a.email
      ,a.user_nm
      ,a.address
      ,a.address_detail
      ,a.profile_asset_id
      ,b.user_status
      ,CodeName(b.user_status) as user_status_nm
      ,b.user_level
      ,CodeName(b.user_level) as user_level_nm
      ,c.shop_id
      ,c.shop_nm
      ,c.ceo_nm
      ,PhoneNumber(c.phone) as phone
      ,b.reg_dt
      ,b.default_yn
FROM user a
     LEFT JOIN user_shop b using(user_id)
     LEFT JOIN shop c using(shop_id)
WHERE a.email = :email
  AND a.user_pw = :user_pw
ORDER BY b.default_yn, b.reg_dt ;

<% } %>

<% if( sql_id == 'INSERT_LOGIN_HISTORY') {%>
/*
 * SQL ID  : INSERT_LOGIN_HISTORY
 * DESC.   : 사용자 로그인 기록
 * COMMENT :
 * HISTORY : 2019.09.27 / 쿼리 정의
 * WRITER  : asdaisy
 */
INSERT INTO user_login_history
(
    user_id
  , model_nm
  , os
  , browser
  , version
  , ip
  , nation_id
)
VALUES
(
    :user_id
  , :model_nm
  , :os
  , :browser
  , :version
  , :ip
  , :nation_id) ;

UPDATE user
   SET last_login_dt = now()
 WHERE user_id = :user_id ;
<% } %>

<% if ( sql_id === 'FIND_USER_EMAIL' ) {%>
/**
 * SQL ID  : FIND_USER_EMAIL
 * DESC.   : 사용자 이름 및 폰번호를 이용하여 이메일 찾기
 * COMMENT :
 * HISTORY : 2021.07.02 / 쿼리 정의
 * WRITER  : asdaisy
 */
SELECT
  email, user_nm, mobile
FROM user
WHERE user_nm = :user_nm AND mobile = :mobile
LIMIT 1
<% } %>

<% if ( sql_id === 'USER_SHOP_LIST' ) {%>
/**
 * SQL ID  : USER_SHOP_LIST
 * DESC.   : 사용자의 상점 리스트 조회
 * COMMENT :
 * HISTORY : 2021.07.15 / 쿼리 정의
 * WRITER  : asdaisy
 */
SELECT b.user_level
      ,CodeName(b.user_level) as user_level_nm
      ,c.shop_id
      ,c.shop_nm
      ,c.ceo_nm,
      b.default_yn,
      (select shop_asset_id from shop_asset where shop_id = b.shop_id order by main_yn limit 1) as shop_asset_id
FROM user a
     JOIN user_shop b on a.user_id = b.user_id 
      AND b.user_status = 'us01'
     LEFT JOIN shop c using(shop_id)
WHERE a.user_id = :user_id
ORDER BY b.reg_dt
<% } %>

<% if ( sql_id === 'USER_LIST' ) {%>
/**
 * SQL ID  : USER_LIST
 * DESC.   : 해당 상점의 사용자 리스트 조회
 * COMMENT :
 * HISTORY : 2021.07.19 / 쿼리 정의 
 * WRITER  : asdaisy
 *
 * HISTORY  : 2021.08.06 / 쿼리 수정
 * UPDATER : minho
 */
SELECT a.user_id
      ,a.user_nm
      ,a.profile_asset_id 
      ,a.email 
      ,a.mobile
      ,a.birthday 
      ,a.bank_cd 
      ,a.bank_num 
      ,a.address
      ,a.address_detail 
      ,b.join_dt
      ,b.user_level
      ,CodeName(b.user_level) as user_level_nm
      ,b.user_status
      ,CodeName(b.user_status) as user_status_nm
      ,b.hire_type
      ,CodeName(b.hire_type) as hire_type_nm
FROM user a
     JOIN user_shop b using(user_id)
WHERE b.shop_id = :shop_id
ORDER BY b.reg_dt
<% } %>


<% if ( sql_id === 'CHANGE_USER_PASSWORD' ) {%>
/**
 * SQL ID  : CHANGE_USER_PASSWORD
 * DESC.   : 사용자의 비밀 번호 변경
 * COMMENT :
 * HISTORY : 2021.07.22 / 쿼리 정의
 * WRITER  : asdaisy
 */
UPDATE user
   SET user_pw = :new_user_pw
 WHERE email = :email ;
<% } %>

<% if ( sql_id === 'INQUIRE_USER' ) {%>
/**
 * SQL ID  : INQUIRE_USER
 * DESC.   : 사용자 로그인
 * COMMENT :
 * HISTORY : 2021.08.19 / 쿼리 정의
 * WRITER  : minho
 */
SELECT u.user_id
      ,u.email
      ,u.user_nm
      ,u.address
      ,u.address_detail
      ,u.profile_asset_id
      ,us.user_status
      ,CodeName(us.user_status) as user_status_nm
      ,us.user_level
      ,CodeName(us.user_level) as user_level_nm
      ,s.shop_id
      ,s.shop_nm
      ,s.ceo_nm
      ,PhoneNumber(s.phone) as phone
      ,us.reg_dt
      ,us.default_yn
FROM user u
     INNER JOIN user_shop us ON u.user_id = us.user_id
     AND us.shop_id = :shop_id
     AND u.user_id = :user_id
     LEFT JOIN shop s ON us.shop_id = s.shop_id 

<% } %>
