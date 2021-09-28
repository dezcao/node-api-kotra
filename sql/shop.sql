/**********************************************************/
/* FILE NAME : shop.sql                                   */
/* FILE DESC : 상점 관련 SQL                              */
/**********************************************************/

<% if ( sql_id === 'REGISTER_SHOP' ) {%>
/**
 * SQL ID  : REGISTER_SHOP
 * DESC.   : 상점 기본정보 신규 등록
 * COMMENT :
 * HISTORY : 2021.06.22 / 쿼리 정의
 * WRITER  : asdaisy
 */
INSERT INTO shop(shop_id, shop_nm, biz_num, ceo_nm, phone, address, address_detail, shop_summery, homepage, longitude, latitude, biz_type)
SELECT :shop_id, :shop_nm, :biz_num, :ceo_nm, :phone, :address, :address_detail, :shop_summery, :homepage, :longitude, :latitude, :biz_type
FROM dual
WHERE NOT EXISTS(SELECT * FROM shop WHERE biz_num = :biz_num);
<% } %>

<% if ( sql_id === 'REGISTER_USER_SHOP' ) {%>
/**
 * SQL ID  : REGISTER_USER_SHOP
 * DESC.   : 사용자-상점 연결 정보 등록
 * COMMENT :
 * HISTORY : 2021.06.22 / 쿼리 정의
 * WRITER  : asdaisy
 * HISTORY : 2021.08.12 / 쿼리 수정
 * WRITER  : minho
 */
INSERT INTO user_shop(user_id, shop_id, user_status, user_level)
SELECT :user_id, :shop_id, :user_status, :user_level
FROM dual
WHERE NOT EXISTS(SELECT * FROM user_shop WHERE user_id = :user_id AND shop_id = :shop_id);

<% } %>

<% if ( sql_id === 'INQUIRE_SHOP' ) {%>
/**
 * SQL ID  : REGISTER_SHOP
 * DESC.   : 상점 기본정보 조회
 * COMMENT :
 * HISTORY : 2021.06.22 / 쿼리 정의
 * WRITER  : asdaisy
 */
SELECT shop_id
      ,shop_nm
      ,biz_num
      ,address
      ,address_detail
      ,phone
      ,ceo_nm
      ,longitude
      ,latitude
      ,homepage
      ,shop_desc
      ,shop_summery
      ,bank_cd
      ,bank_num
      ,biz_type
      ,CodeName(biz_type) as biz_type_nm
      ,GROUP_CONCAT(distinct c.svc_type separator ',') as svc_type
      ,GROUP_CONCAT(distinct d.add_svc_id separator ',') as add_svc_id
FROM shop a
  INNER JOIN user_shop b using(shop_id)
  LEFT JOIN shop_svc_type c using(shop_id)
  LEFT JOIN shop_add_svc d using(shop_id)
WHERE a.shop_id = :shop_id
  AND b.user_id = :user_id
GROUP BY shop_id ;
<% } %>

<% if ( sql_id === 'SEARCH_SHOP' ) {%>
/**
 * SQL ID  : REGISTER_SHOP
 * DESC.   : 상점 검색
 * COMMENT :
 * HISTORY : 2021.06.22 / 쿼리 정의
 * WRITER  : asdaisy
 */
SELECT shop_id
      ,shop_nm
      ,biz_num
      ,address
      ,address_detail
      ,phone
      ,ceo_nm
      ,homepage
      ,shop_desc
      ,shop_summery
FROM shop
WHERE exposure_yn = 'Y' AND shop_nm LIKE :shop_nm;
<% } %>

<% if ( sql_id === 'UPDATE_SHOP' ) {%>
/**
 * SQL ID  : UPDATE_SHOP
 * DESC.   : 상점 정보 수정
 * COMMENT :
 * HISTORY : 2021.07.02 / 쿼리 정의
 * WRITER  : asdaisy
 * HISTORY : 2021.08.26 / 쿼리 수정
 * WRITER  : minho
 */
UPDATE shop
  INNER JOIN user_shop
          ON shop.shop_id = user_shop.shop_id
          AND user_shop.user_id = :user_id
          AND user_shop.shop_id = :shop_id
SET
  shop.reg_dt = shop.reg_dt
  <% if ( shop_nm ) {%>
  ,shop_nm = :shop_nm
  <% } %>
  <% if ( ceo_nm ) {%>
  ,ceo_nm = :ceo_nm
  <% } %>
  <% if ( phone ) {%>
  ,phone = :phone
  <% } %>
  <% if ( address ) {%>
  ,address = :address
  <% } %>
  <% if ( address_detail ) {%>
  ,address_detail = :address_detail
  <% } %>
  <% if ( shop_summery ) {%>
  ,shop_summery = :shop_summery
  <% } %>
  <% if ( shop_desc ) {%>
  ,shop_desc = :shop_desc
  <% } %>
  <% if ( homepage ) {%>
  ,homepage = :homepage
  <% } %>
  <% if ( longitude ) {%>
  ,longitude = :longitude
  <% } %>
  <% if ( latitude ) {%>
  ,latitude = :latitude
  <% } %>
  <% if ( biz_type ) {%>
  ,biz_type = :biz_type
  <% } %>
  <% if ( bank_cd ) {%>
  ,bank_cd = :bank_cd
  <% } %>
  <% if ( bank_num ) {%>
  ,bank_num = :bank_num 
  <% } %>
<% } %>


<% if ( sql_id === 'REGISTER_SHOP_SVC_TYPE' ) {%>
/**
 * SQL ID  : REGISTER_SHOP_SVC_TYPE
 * DESC.   : 상점 서비스타입 및 부가 서비스  등록
 * COMMENT :
 * HISTORY : 2021.07.05 / 쿼리 정의
 * WRITER  : asdaisy
 */
DELETE FROM shop_svc_type WHERE shop_id = :shop_id;
REPLACE INTO shop_svc_type(shop_id, svc_type)
VALUES :svc_type ;

  <% if (typeof add_svc_id !== 'undefined' && add_svc_id) { %>
    DELETE FROM shop_add_svc WHERE shop_id = :shop_id;
    REPLACE INTO shop_add_svc(shop_id, add_svc_id)
    VALUES :add_svc_id ;
  <% } %>

<% } %>

<% if ( sql_id === 'REGISTER_SHOP_ASSET' ) {%>
/**
 * SQL ID  : REGISTER_SHOP_ASSET
 * DESC.   : 상점 이미지 정보 등록
 * COMMENT :
 * HISTORY : 2021.07.07 / 쿼리 정의
 * WRITER  : asdaisy
 */
DELETE FROM shop_asset WHERE shop_id = :shop_id AND svc_type = :svc_type;
<% if (shop_asset_id[0][1].length>0) {%>
REPLACE INTO shop_asset(shop_id, shop_asset_id, svc_type)
VALUES :shop_asset_id ;
<% } %>
  <% if (typeof main_asset_id !== 'undefined' && main_asset_id) { %>
    UPDATE shop_asset SET main_yn = 'Y'
    WHERE shop_id = :shop_id
    AND shop_asset_id = :main_asset_id
  <% } %>
<% } %>

<% if ( sql_id === 'INQUIRE_SHOP_ASSET' ) {%>
/**
 * SQL ID  : INQUIRE_SHOP_ASSET
 * DESC.   : 상점 이미지정보 조회
 * COMMENT :
 * HISTORY : 2021.07.07 / 쿼리 정의
 * WRITER  : asdaisy
 */
SELECT shop_id
      ,svc_type
      ,shop_asset_id
      ,main_yn
FROM shop_asset
WHERE shop_id = :shop_id
<% if ( svc_type ) {%>
AND svc_type = :svc_type
<% } %>
ORDER BY exposure_ord, reg_dt ;
<% } %>

<% if ( sql_id === 'REGISTER_SHOP_OPENING_HOURS' ) {%>
/**
 * SQL ID  : REGISTER_SHOP_OPENING_HOURS
 * DESC.   : 상점 영업 시간 정보 등록
 * COMMENT :
 * HISTORY : 2021.07.09 / 쿼리 정의
 * WRITER  : minho
 */
DELETE FROM shop_hours WHERE shop_id = :shop_id AND svc_type = :svc_type;
REPLACE INTO shop_hours(shop_id,
                        svc_type,
                        dow,
                        open_tm,
                        close_tm,
                        today_reserv_yn,
                        lunch_stm,
                        lunch_ctm)
VALUES :open_hours_data ;
<% } %>

<% if ( sql_id === 'INQUIRE_OPENING_HOURS' ) {%>
/**
 * SQL ID  : INQUIRE_OPENING_HOURS
 * DESC.   : 상점 영업 시간 정보 조회
 * COMMENT :
 * HISTORY : 2021.07.12 / 쿼리 정의
 * WRITER  : minho
 */

SELECT sh.svc_type
      ,sh.dow
      ,sh.open_tm
      ,sh.close_tm
      ,sh.lunch_stm
      ,sh.lunch_ctm
      ,sh.today_reserv_yn
FROM shop_hours as sh
INNER JOIN shop as s ON sh.shop_id = s.shop_id AND sh.shop_id = :shop_id
WHERE svc_type = :svc_type

<% } %>

<% if ( sql_id === 'REGISTER_SHOP_DAYOFF' ) {%>
/**
 * SQL ID  : REGISTER_SHOP_DAYOFF
 * DESC.   : 상점 휴뮤일 정보 등록
 * COMMENT :
 * HISTORY : 2021.07.12 / 쿼리 정의
 * WRITER  : minho
*/

INSERT INTO shop_dayoff(shop_id, svc_type, dayoff_nm, dayoff_sdt, dayoff_edt, use_yn)
VALUES(:shop_id, :svc_type, :dayoff_nm, :dayoff_sdt, :dayoff_edt, :use_yn)
<% } %>

<% if ( sql_id === 'INQUIRE_SHOP_DAYOFF' ) {%>
/**
 * SQL ID  : INQUIRE_SHOP_DAYOFF
 * DESC.   : 상점 휴뮤일 정보 조회 (지나간 휴무 제외)
 * COMMENT :
 * HISTORY : 2021.07.12 / 쿼리 정의
 * WRITER  : minho
*/

SELECT sd.seq
	  ,sd.shop_id
	  ,sd.svc_type
	  ,sd.dayoff_nm
	  ,sd.dayoff_sdt
    ,sd.dayoff_edt
	  ,sd.use_yn
    ,(SELECT COUNT(*) FROM shop_dayoff 
      WHERE shop_id = :shop_id 
      AND dayoff_edt >= DATE_FORMAT(now(),'%Y-%m-%d') 
      <% if (svc_type && svc_type !== 'st00') {%>
      AND svc_type = :svc_type
      <% } %>
      ) as total_data
FROM shop_dayoff sd
INNER JOIN shop as s ON sd.shop_id = s.shop_id AND sd.shop_id = :shop_id
WHERE sd.dayoff_edt >= DATE_FORMAT(now(),'%Y-%m-%d')
<% if (svc_type && svc_type !== 'st00') {%>
AND svc_type = :svc_type
<% } %>
ORDER BY sd.dayoff_sdt
LIMIT :start_no, :list_size
<% } %>

<% if ( sql_id === 'UPDATE_SHOP_DAYOFF' ) {%>
/**
 * SQL ID  : UPDATE_SHOP_DAYOFF
 * DESC.   : 상점 휴뮤일 정보 수정
 * COMMENT :
 * HISTORY : 2021.07.19 / 쿼리 정의
 * WRITER  : minho
*/

UPDATE shop_dayoff as sd
INNER JOIN shop as s ON sd.shop_id = s.shop_id AND sd.shop_id = :shop_id
SET
sd.reg_dt = sd.reg_dt
<% if (svc_type) { %>
    ,sd.svc_type = :svc_type
<% } %>
<% if (dayoff_nm) { %>
    ,sd.dayoff_nm = :dayoff_nm
<% } %>
<% if (dayoff_sdt) { %>
    ,sd.dayoff_sdt = :dayoff_sdt
<% } %>
<% if (dayoff_edt) { %>
    ,sd.dayoff_edt = :dayoff_edt
<% } %>
<% if (use_yn) { %>
    ,sd.use_yn = :use_yn
<% } %>
WHERE sd.seq = :seq
<% } %>

<% if ( sql_id === 'DELETE_SHOP_DAYOFF' ) {%>
/**
 * SQL ID  : DELETE_SHOP_DAYOFF
 * DESC.   : 상점 휴뮤일 정보 삭제
 * COMMENT :
 * HISTORY : 2021.07.19 / 쿼리 정의
 * WRITER  : minho
*/
DELETE sd.* FROM shop_dayoff as sd
INNER JOIN shop as s ON sd.shop_id = s.shop_id AND sd.shop_id = :shop_id
WHERE sd.seq = :seq
<% } %>

<% if ( sql_id === 'REGISTER_VIRTUAL_USER' ) {%>
/**
 * SQL ID  : REGISTER_VIRTUAL_USER
 * DESC.   : 상점 가상직원 등록
 * COMMENT :
 * HISTORY : 2021.07.13 / 쿼리 정의
 * WRITER  : minho
*/

INSERT INTO user(
      user_id
      ,email
      ,user_pw
      ,user_nm
      ,mobile)
VALUES :vir_user
<% } %>


<% if ( sql_id === 'REGISTER_VIR_USER_SHOP' ) {%>
/**
 * SQL ID  : REGISTER_VIR_USER_SHOP
 * DESC.   : 가상직원 - 사용자 연결 정보 등록
 * COMMENT :
 * HISTORY : 2021.07.13 / 쿼리 정의
 * WRITER  : minho
*/

INSERT INTO user_shop(
      user_id
      ,shop_id
      ,user_status
      ,user_level
      ,hire_type)
VALUES :vir_user_shop
<% } %>

<% if ( sql_id === 'DELETE_VIR_USER_SHOP' ) {%>
/**
 * SQL ID  : DELETE_VIR_USER_SHOP
 * DESC.   : 가상직원 퇴사 처리
 * COMMENT :
 * HISTORY : 2021.08.02 / 쿼리 정의
 * WRITER  : minho
*/

UPDATE user_shop as us
SET
user_status = :user_status,
retire_dt = CURRENT_TIMESTAMP()
WHERE user_id = :user_id
<% } %>

<% if ( sql_id === 'REGISTER_ADDITIONAL_SHOP' ) {%>
/**
 * SQL ID  : REGISTER_ADDITIONAL_SHOP
 * DESC.   : 해당 유저 상점 추가
 * COMMENT :
 * HISTORY : 2021.07.13 / 쿼리 정의
 * WRITER  : minho
*/

INSERT INTO shop(
      shop_id,
      shop_nm,
      biz_num,
      ceo_nm,
      phone,
      address,
      address_detail,
      shop_summery,
      shop_desc,
      homepage,
      longitude,
      latitude)
SELECT :shop_id, :shop_nm, :biz_num, :ceo_nm, :phone, :address, :address_detail, :shop_summery, :shop_desc, :homepage, :longitude, :latitude
FROM dual
WHERE NOT EXISTS(SELECT * FROM shop WHERE biz_num = :biz_num);
<% } %>

<% if ( sql_id === 'INQUIRE_SHOP_LIST' ) {%>
/**
 * SQL ID  : INQUIRE_SHOP_LIST
 * DESC.   : 유저 샵 리스트 조회
 * COMMENT :
 * HISTORY : 2021.07.20 / 쿼리 정의
 * WRITER  : minho
*/

SELECT * FROM shop AS s
INNER JOIN user_shop us ON s.shop_id = us.shop_id AND us.user_id = :user_id
ORDER BY s.reg_dt DESC
<% } %>


<% if ( sql_id === 'INQUIRE_SHOP_FEE' ) {%>
/**
 * SQL ID  : INQUIRE_SHOP_FEE
 * DESC.   : 상점 노쇼/취소 수수료 조회
 * COMMENT :
 * HISTORY : 2021.07.29 / 쿼리 정의
 * WRITER  : minho
*/
SELECT * FROM shop_fee WHERE shop_id = :shop_id
<% if (svc_type) {%>
AND svc_type = :svc_type
<% } %>
<% } %>

<% if ( sql_id === 'SHOP_FEE_SET' ) {%>
/**
 * SQL ID  : SHOP_FEE_SET
 * DESC.   : 상점 노쇼/취소 수수료 설정
 * COMMENT :
 * HISTORY : 2021.07.26 / 쿼리 정의
 * WRITER  : minho
*/

DELETE FROM shop_fee WHERE shop_id = :shop_id AND svc_type =:svc_type;
REPLACE INTO shop_fee(
    shop_id
    ,svc_type
    ,fee_type
    ,fee_tm
    ,fee_rate
    ,fee_amt
    ,use_yn
    )
VALUES :data ;
<% } %>

<% if ( sql_id === 'SHOP_USER_LIST' ) {%>
/**
 * SQL ID  : SHOP_USER_LIST
 * DESC.   : 상점 직원 리스트
 * COMMENT :
 * HISTORY : 2021.07.26 / 쿼리 정의
 * WRITER  : minho
*/

SELECT u.user_id
      ,u.user_nm
      ,u.profile_asset_id 
      ,u.email 
      ,u.mobile
      ,u.birthday 
      ,u.bank_cd 
      ,u.bank_num 
      ,u.address
      ,u.address_detail 
      ,us.join_dt
      ,us.user_level
      ,CodeName(us.user_level) as user_level_nm
      ,us.user_status
      ,CodeName(us.user_status) as user_status_nm
      ,us.hire_type
      ,CodeName(us.hire_type) as hire_type_nm
FROM user u
INNER JOIN user_shop us ON u.user_id = us.user_id 
AND us.shop_id =:shop_id
AND us.user_status != 'us04'
WHERE 1=1 
<% if ( user_level ) {%>
AND user_level = :user_level
<% } %>
<% if ( user_status ) {%>
AND user_status = :user_status
<% } %>
<% if ( hire_type ) {%>
AND hire_type = :hire_type
<% } %>
ORDER BY u.reg_dt DESC 
<% if ( start_no !==null && list_size ) {%>
LIMIT :start_no, :list_size
<% } %>
<% } %>

<% if ( sql_id === 'TOTAL_SHOP_USER_LIST' ) {%>
/**
 * SQL ID  : TOTAL_SHOP_USER_LIST
 * DESC.   : 상점 직원 총 숫자
 * COMMENT :
 * HISTORY : 2021.07.26 / 쿼리 정의
 * WRITER  : minho
*/
SELECT count(u.user_id) AS total_data
FROM user u
INNER JOIN user_shop us ON u.user_id = us.user_id 
AND us.shop_id =:shop_id
AND us.user_status != 'us04'
WHERE 1=1 
<% if (user_level) {%>
AND user_level = :user_level
<% } %>
<% if (user_status) {%>
AND user_status = :user_status
<% } %>
<% if (hire_type) {%>
AND hire_type = :hire_type
<% } %>
<% } %>


<% if ( sql_id === 'REGISTER_USER_DAYOFF' ) {%>
/**
 * SQL ID  : REGISTER_USER_DAYOFF
 * DESC.   : 직원 휴무일 설정
 * COMMENT :
 * HISTORY : 2021.07.27 / 쿼리 정의
 * WRITER  : minho
*/
INSERT INTO user_dayoff(user_id
                       ,shop_id
                       ,dayoff_type
                       ,dayoff_start
                       ,dayoff_end
                       ,comment
                       )
            VALUES(
              :user_id
              ,:shop_id
              ,:dayoff_type
              ,:dayoff_start
              ,:dayoff_end
              ,:comment
            )
<% } %>


<% if ( sql_id === 'INQUIRE_USER_DAYOFF' ) {%>
/**
 * SQL ID  : INQUIRE_USER_DAYOFF
 * DESC.   : 직원 휴무일 설정
 * COMMENT :
 * HISTORY : 2021.08.05 / 쿼리 정의
 * WRITER  : minho
*/
SET @rownum:=0; 
SELECT
	a.*
FROM (
	SELECT
		@rownum:=@rownum+1 rownum
	      ,ud.seq
	      ,u.user_id
	      ,u.user_nm
	      ,u.email
	      ,ud.dayoff_type
	      ,(SELECT code_name FROM common_code WHERE common_code = ud.dayoff_type ) as dayoff_nm
	      ,ud.dayoff_start
	      ,ud.dayoff_end
	      ,ud.comment
	FROM user_dayoff ud
	INNER JOIN user u ON ud.user_id = u.user_id AND shop_id = :shop_id
      <% if (search_start && search_end){%>
      WHERE 
      (:search_start BETWEEN dayoff_start AND dayoff_end)
      OR (:search_end BETWEEN dayoff_start AND dayoff_end)
      OR
      (dayoff_start  BETWEEN :search_start AND :search_end)
      OR (dayoff_end  BETWEEN :search_start AND :search_end)
      <%}%>
	ORDER BY dayoff_start	
) a
ORDER BY rownum DESC
LIMIT :start_no, :list_size
<% } %>


<% if ( sql_id === 'UPDATE_USER_DAYOFF' ) {%>
/**
 * SQL ID  : UPDATE_USER_DAYOFF
 * DESC.   : 직원 휴무정보 변경
 * COMMENT :
 * HISTORY : 2021.08.05 / 쿼리 정의
 * WRITER  : minho
*/
UPDATE user_dayoff ud SET  
ud.reg_dt=ud.reg_dt
<% if (dayoff_type){%>
,ud.dayoff_type = :dayoff_type
<%}%>
<% if (dayoff_start){%>
,ud.dayoff_start = :dayoff_start
<%}%>
<% if (dayoff_end){%>
,ud.dayoff_end = :dayoff_end
<%}%>
<% if (comment){%>
,ud.comment = :comment
<%}%>
WHERE ud.user_id = :user_id
AND ud.seq = :seq
<% } %>

<% if ( sql_id === 'DELETE_USER_DAYOFF' ) {%>
/**
 * SQL ID  : DELETE_USER_DAYOFF
 * DESC.   : 직원 휴무정보 삭제
 * COMMENT :
 * HISTORY : 2021.08.06 / 쿼리 정의
 * WRITER  : minho
*/
DELETE FROM user_dayoff 
WHERE shop_id = :shop_id
AND user_id = :user_id 
AND seq = :seq
<% } %>

<% if ( sql_id === 'UPDATE_USER_STATUS' ) {%>
/**
 * SQL ID  : UPDATE_USER_STATUS
 * DESC.   : 직원 레벨,상태 변경
 * COMMENT :
 * HISTORY : 2021.07.29 / 쿼리 정의
 * WRITER  : minho
*/
UPDATE user_shop us SET  
us.reg_dt=us.reg_dt
<% if (user_level){%>
,us.user_level = :user_level
<%}%>
<% if (user_status){%>
,us.user_status = :user_status
<%}%>
<% if (hire_type){%>
,us.hire_type = :hire_type
<%}%>
<% if (join_dt){%>
,us.join_dt = :join_dt
<%}%>
<% if (retire_dt){%>
,us.retire_dt = :retire_dt
<%}%>
<% if (!join_dt && user_status === 'us01'){%>
,us.join_dt = CURRENT_TIMESTAMP()
<%}%>
<% if (!retire_dt && user_status === 'us03'){%>
,us.retire_dt = CURRENT_TIMESTAMP()
<%}%>
WHERE us.shop_id = :shop_id
AND us.user_id = :user_id
<% } %>


<% if ( sql_id === 'MENU_PERM_LIST' ) {%>
/**
 * SQL ID  : MENU_PERM_LIST
 * DESC.   : 메뉴 권한 설정 리스트
 * COMMENT :
 * HISTORY : 2021.07.29 / 쿼리 정의
 * WRITER  : minho
*/
SELECT seq
      ,menu_level
      ,menu_id
      ,menu_nm
      ,menu_enm
      ,menu_id2
      ,menu_nm2
      ,menu_enm2
FROM v_erpmenu
ORDER BY seq ASC
<% } %>

<% if ( sql_id === 'INQUIRE_SHOP_MENU_PERM' ) {%>
/**
 * SQL ID  : INQUIRE_SHOP_MENU_PERM
 * DESC.   : 샵 메뉴 권한 설정 조회
 * COMMENT :
 * HISTORY : 2021.07.30 / 쿼리 정의
 * WRITER  : minho
*/
-- SELECT sep.perm_id
--       ,sep.shop_id
--       ,sep.menu_id
--       ,sep.user_level
--       ,sep.acc_perm
--       ,e2.seq 
-- FROM shop_erpmenu_perm sep
-- INNER JOIN erpmenu e2 ON sep.menu_id = e2.menu_id 
-- AND sep.shop_id =:shop_id
-- ORDER BY e2.seq ASC

SELECT    ve.seq
	   ,ve.menu_level 
	   ,ve.menu_id
	   ,ve.menu_nm 
	   ,ve.menu_enm
	   ,ve.menu_id2
	   ,ve.menu_nm2
	   ,ve.menu_enm2
	   ,sep.perm_id
	   ,sep.user_level 
	   ,sep.acc_perm 
FROM v_erpmenu ve 
LEFT JOIN shop_erpmenu_perm sep ON ve.menu_id2 = sep.menu_id 
AND sep.shop_id = :shop_id
<% if (user_level) {%>
AND sep.user_level = :user_level
<% } %>
ORDER BY ve.seq ASC
<% } %>

<% if ( sql_id === 'INIT_MENU_PERM_SET' ) {%>
/**
 * SQL ID  : INIT_MENU_PERM_SET
 * DESC.   : 초기 메뉴 권한 설정 
 * COMMENT :
 * HISTORY : 2021.07.30 / 쿼리 정의
 * WRITER  : minho
*/
INSERT INTO shop_erpmenu_perm(perm_id,shop_id,menu_id,user_level,acc_perm)
VALUES :init_menuSet ;
<% } %>

<% if ( sql_id === 'UPDATE_MENU_PERM' ) {%>
/**
 * SQL ID  : UPDATE_MENU_PERM
 * DESC.   : 메뉴 권한 설정변경
 * COMMENT :
 * HISTORY : 2021.08.02 / 쿼리 정의
 * WRITER  : minho
*/
DELETE FROM shop_erpmenu_perm WHERE shop_id = :shop_id;
REPLACE INTO shop_erpmenu_perm(perm_id, shop_id, menu_id,user_level,acc_perm)
VALUES :menu_perm ;

<% } %>


<% if ( sql_id === 'SHOP_DASHBOARD' ) {%>
/**
 * SQL ID  : SHOP_DASHBOARD
 * DESC.   : 샵 관리 페이지 대시보드
 * COMMENT :
 * HISTORY : 2021.08.02 / 쿼리 정의
 * WRITER  : minho
*/

SELECT 
      count(*) as total_user,
      (count(*) - (SELECT count(*) from user_dayoff ud 
      where shop_id =:shop_id
      AND CURRENT_DATE() BETWEEN dayoff_start and dayoff_end) ) as working_user,
      (SELECT count(*) from user_dayoff ud 
      where shop_id = :shop_id
      AND CURRENT_DATE() BETWEEN dayoff_start and dayoff_end) as dayoff_user,
      (SELECT count(*) FROM user u
      INNER JOIN user_shop us ON u.user_id = us.user_id 
      AND us.shop_id = :shop_id
      AND us.user_status = 'us00') as waiting_user
FROM user u
INNER JOIN user_shop us ON u.user_id = us.user_id 
AND shop_id = :shop_id

<% } %>


<% if ( sql_id === 'UPDATE_DEFAULT_SHOP' ) {%>
/**
 * SQL ID  : UPDATE_DEFAULT_SHOP
 * DESC.   : 기본 상점 등록/변경
 * COMMENT :
 * HISTORY : 2021.08.20 / 쿼리 정의
 * WRITER  : minho
 */

UPDATE user_shop SET 
default_yn = 'N'
WHERE user_id = :user_id;
  <% if (shop_id) { %>
    UPDATE user_shop SET 
    default_yn = 'Y'
    WHERE shop_id = :shop_id
    AND user_id = :user_id;
  <% } %>
<% } %>