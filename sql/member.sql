/**********************************************************/
/* FILE NAME : member.sql                                   */
/* FILE DESC : 회원 관련 SQL                              */
/**********************************************************/

<% if ( sql_id === 'REGISTER_MEMBER' ) {%>
/**
 * SQL ID  : REGISTER_MEMBER
 * DESC.   : 회원 기본정보 신규 등록
 * COMMENT :
 * HISTORY : 2021.06.28 / 쿼리 정의
 * WRITER  : minho
 */
INSERT INTO member(member_id, email, member_nm, mobile, phone, address, address_detail, sex, birthday, join_channel, push_yn, email_noti_yn)
SELECT :member_id, :email, :member_nm, :mobile, :phone, :address, :address_detail, :sex, :birthday, :join_channel, :push_yn, :email_noti_yn
FROM dual
WHERE NOT EXISTS(SELECT * FROM member WHERE email = :email);
<% } %>


<% if ( sql_id === 'REGISTER_MEMBER_SHOP' ) {%>
/**
 * SQL ID  : REGISTER_MEMBER_SHOP
 * DESC.   : 회원-상점 연결 정보 등록
 * COMMENT :
 * HISTORY : 2021.06.28 / 쿼리 정의
 * WRITER  : minho
 */
INSERT INTO member_shop(member_id, shop_id, member_num)
SELECT :member_id, :shop_id, :member_num
FROM dual
WHERE NOT EXISTS(SELECT * FROM member_shop WHERE member_id = :member_id AND shop_id = :shop_id);
<% } %>

<% if ( sql_id === 'LIST_MEMBER' ) {%>
/**
 * SQL ID  : LIST_MEMBER
 * DESC.   : 화원 리스트 조회
 * COMMENT :
 * HISTORY : 2021.06.28 / 쿼리 정의
 * WRITER  : minho
 */
SELECT m.member_id
      ,m.email
      ,m.reg_dt as reg_dt
      ,m.member_nm as member_nm
      ,m.sex
      ,m.birthday
      ,m.mobile as mobile
      ,m.phone
      ,m.address
      ,m.address_detail
	  ,m.join_channel
      ,GROUP_CONCAT(p.pet_nm separator ',') as pet_nm
      ,GROUP_CONCAT(TRUNCATE((SELECT Age(p.birthday)),1) separator ',') as pet_birthday
      ,(SELECT count(*) FROM reservation
	    WHERE member_id = m.member_id
	   	AND shop_id = :shop_id
		AND reserv_status ='rs04' ) as reserv_cnt
   	  ,(SELECT reserv_dt FROM reservation
		WHERE member_id = m.member_id
		AND shop_id =:shop_id
		AND reserv_status ='rs04'
		ORDER BY reserv_dt DESC, reserv_stm DESC LIMIT 1) as recent_visit
	  ,(SELECT sum(tot_price) FROM reservation
		WHERE shop_id = :shop_id
		AND member_id = m.member_id
		AND reserv_status ='rs04') as tot_price
	  ,(SELECT vsc.svc_cate_nm FROM v_svc_category vsc
    	INNER JOIN service s2 ON vsc.svc_cate_id = s2.svc_cate_id
    	WHERE s2.svc_id = ( SELECT svc_id FROM reservation r2
							WHERE shop_id = :shop_id
							AND reserv_status = 'rs04'
							AND member_id = m.member_id
							ORDER BY reserv_dt DESC,reserv_stm DESC LIMIT 1)
						) as recent_svc_nm
	  ,(SELECT user_nm from user
	  	WHERE user_id =(SELECT user_id FROM reservation r2
						WHERE shop_id = :shop_id
						AND member_id = m.member_id
						AND reserv_status ='rs04'
						ORDER BY reserv_dt DESC,reserv_stm DESC LIMIT 1)
						) as user_nm
FROM member m INNER JOIN member_shop ms ON m.member_id = ms.member_id AND ms.shop_id = :shop_id
LEFT JOIN pet p ON m.member_id = p.member_id
-- LEFT JOIN reservation r1 ON m.member_id = (SELECT member_id FROM reservation
-- 										   WHERE shop_id = :shop_id
-- 										   ORDER BY reserv_dt DESC LIMIT 1)
GROUP BY m.member_id
ORDER BY @order_key :order_type
LIMIT :start_no, :list_size
<% } %>

<% if ( sql_id === 'TOTAL_MEMBER' ) {%>
/**
 * SQL ID  : TOTAL_MEMBER
 * DESC.   : 해당 상점 총 회원수 조회
 * COMMENT :
 * HISTORY : 2021.06.29 / 쿼리 정의
 * WRITER  : minho
 */
SELECT COUNT(*) as total_data
FROM member m INNER JOIN member_shop ms ON m.member_id  = ms.member_id AND ms.shop_id=:shop_id
<% } %>

<% if ( sql_id === 'SHOP_USER_LIST' ) {%>
/**
 * SQL ID  : SHOP_USER_LIST
 * DESC.   : 해당 상점 총 회원(담당자) 조회
 * COMMENT :
 * HISTORY : 2021.07.05 / 쿼리 정의
 * WRITER  : minho
 */
SELECT u.user_id
	  ,u.user_nm
from user u INNER JOIN user_shop us ON u.user_id = us.user_id AND us.shop_id =:shop_id
<% } %>


<% if ( sql_id === 'SEARCH_MEMBER' ) {%>
/**
 * SQL ID  : SEARCH_MEMBER
 * DESC.   : 해당 상점 회원 검색
 * COMMENT :
 * HISTORY : 2021.06.29 / 쿼리 정의
 * WRITER  : minho
 */
SELECT m.member_id
      ,m.email
      ,ms.reg_dt as reg_dt
      ,m.member_nm as member_nm
      ,m.sex
      ,m.birthday
      ,m.mobile as mobile
      ,m.phone
      ,m.address
      ,m.address_detail
	  ,m.join_channel
	  <% if (search_type ==='search00' || search_type ==='search02') { %>
	  ,r.reserv_dt
	  <% } %>
      ,GROUP_CONCAT(p.pet_nm separator ',') as pet_nm
      ,GROUP_CONCAT(TRUNCATE((SELECT Age(p.birthday)),1) separator ',') as pet_birthday
      ,(SELECT count(*) FROM reservation
	    WHERE member_id = m.member_id
	   	AND shop_id = :shop_id
		AND reserv_status ='rs04' ) as reserv_cnt
   	  ,(SELECT reserv_dt FROM reservation
		WHERE member_id = m.member_id
		AND shop_id =:shop_id
		AND reserv_status ='rs04'
		ORDER BY reserv_dt DESC, reserv_stm DESC LIMIT 1) as recent_visit
	  ,(SELECT sum(tot_price) FROM reservation
		WHERE shop_id = :shop_id
		AND member_id = m.member_id
		AND reserv_status ='rs04') as tot_price
	  ,(SELECT vsc.svc_cate_nm FROM v_svc_category vsc
    	INNER JOIN service s2 ON vsc.svc_cate_id = s2.svc_cate_id
    	WHERE s2.svc_id = ( SELECT svc_id FROM reservation r2
							WHERE shop_id = :shop_id
							AND reserv_status = 'rs04'
							AND member_id = m.member_id
							ORDER BY reserv_dt DESC,reserv_stm DESC LIMIT 1)
						) as recent_svc_nm
	  ,(SELECT user_nm from user
	  	WHERE user_id =(SELECT user_id FROM reservation r2
						WHERE shop_id = :shop_id
						AND member_id = m.member_id
						AND reserv_status ='rs04'
						ORDER BY reserv_dt DESC,reserv_stm DESC LIMIT 1)
						) as user_nm
FROM member m INNER JOIN member_shop ms ON m.member_id = ms.member_id AND ms.shop_id = :shop_id
LEFT JOIN pet p ON m.member_id = p.member_id
<% if (search_type ==='search00' || search_type ==='search02') { %>
LEFT JOIN (SELECT * FROM reservation
		   WHERE (member_id,reserv_dt,reg_dt ) in(SELECT
												member_id
												,max(reserv_dt) as reserv_dt
												,max(reg_dt) as reg_dt
												FROM reservation
												WHERE shop_id =:shop_id
												AND (reserv_status ='rs04')
												GROUP BY member_id  )
			AND shop_id =:shop_id
			AND reserv_status ='rs04'
			ORDER BY reserv_dt DESC) r ON m.member_id = r.member_id
<% } %>
WHERE 1=1 
<% if (search_content) { %>
AND(
	m.member_nm LIKE concat('%', TRIM(:search_content), '%')
    OR m.mobile LIKE concat('%', TRIM(:search_content), '%')
    OR m.phone LIKE concat('%', TRIM(:search_content), '%')
	OR p.pet_nm LIKE concat('%', TRIM(:search_content), '%')
	)
<% } %>
-- 전체
<% if (search_type ==='search00') { %>

	<% if ((!svc_type || svc_type==='st00' )&& !user_id) { %>
	GROUP BY m.member_id, r.reserv_id
	<% } %>

	<% if (svc_type && !user_id) { %>
		<%if (svc_type==='st01'|| svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
	AND r.reserv_id IS NOT NULL
	AND r.svc_type= :svc_type
	GROUP BY m.member_id,r.reserv_id
		<% }  %>
	<% } %>

	<% if (!svc_type && user_id) { %>
	AND r.reserv_id IS NOT NULL
	AND r.user_id = :user_id
	GROUP BY m.member_id,r.reserv_id
	<% } %>
	
	<% if (svc_type && user_id) { %>
	AND r.reserv_id IS NOT NULL
		<%if (svc_type==='st01'|| svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
	AND r.svc_type= :svc_type
		<% }  %>
	AND r.user_id = :user_id
	GROUP BY m.member_id,r.reserv_id
	<% } %>

<% } %>
-- 등록일
<% if (search_type ==='search01') { %>
	<% if (!start_date || !end_date) { %>
	GROUP BY m.member_id 
	<% } else {%>
	AND ms.reg_dt BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
	GROUP BY m.member_id
	<% } %>
<% } %>
-- 이용일
<% if (search_type ==='search02') { %>
	<% if (!start_date && !end_date && !svc_type && !user_id) { %>	
	AND r.reserv_id IS NOT NULL
	GROUP BY m.member_id,r.reserv_id
	<% } %>
	<% if (!start_date && !end_date && svc_type && !user_id) { %>	
	AND r.reserv_id IS NOT NULL
	<%if (svc_type==='st01'||svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
		AND r.svc_type= :svc_type
		<% }  %>
	GROUP BY m.member_id ,r.reserv_id
	<% } %>
	<% if (!start_date && !end_date && !svc_type && user_id) { %>	
	AND r.reserv_id IS NOT NULL
	AND r.user_id = :user_id
	GROUP BY m.member_id ,r.reserv_id
	<% } %>
	<% if (start_date && end_date && !svc_type && !user_id) { %>
	AND r.reserv_id IS NOT NULL
	AND r.reserv_dt BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
	GROUP BY m.member_id ,r.reserv_id
	<% } %>
	<% if (start_date && end_date && !svc_type && user_id) { %>
	AND r.reserv_id IS NOT NULL
	AND r.reserv_dt BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
	AND r.user_id = :user_id
	GROUP BY m.member_id ,r.reserv_id
	<% } %>
	<% if (start_date && end_date && svc_type && !user_id) { %>
	AND r.reserv_id IS NOT NULL
	AND r.reserv_dt BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
		<%if (svc_type==='st01'||svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
		AND r.svc_type= :svc_type
		<% }  %>
	GROUP BY m.member_id ,r.reserv_id
	<% } %>
	<% if (start_date && end_date && svc_type && user_id) { %>
	AND r.reserv_id IS NOT NULL
	AND r.reserv_dt BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
		<%if (svc_type==='st01'||svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
		AND r.svc_type= :svc_type
		<% }  %>
	AND r.user_id = :user_id
	GROUP BY m.member_id ,r.reserv_id
	<% } %>
<% } %>
-- 대시보드 신규 회원
<% if (search_type ==='dash01') { %>
AND DATE_FORMAT( m.reg_dt,'%m-%d') BETWEEN DATE_FORMAT(DATE_SUB(CURRENT_DATE() ,INTERVAL 7 Day),'%m-%d') AND DATE_FORMAT(CURRENT_DATE(),'%m-%d')
GROUP BY m.member_id
<% } %>
-- 대시보드 이용권 보유
<% if (search_type ==='dash02') { %>
AND m.member_id ='지금 기능 안됨'
GROUP BY m.member_id
<% } %>
-- 대시보드 생일 회원
<% if (search_type ==='dash03') { %>
AND DATE_FORMAT(m.birthday,'%m-%d') = DATE_FORMAT(CURRENT_DATE(),'%m-%d')  
GROUP BY m.member_id
<% } %>

<% if (order_key === 'reg_dt') { %>
ORDER BY ms.reg_dt :order_type
<% } else{ %>
ORDER BY @order_key :order_type
<% } %>
LIMIT :start_no, :list_size
<% } %>

<% if ( sql_id === 'SEARCH_TOTAL_MEMBER' ) {%>
/**
 * SQL ID  : SEARCH_TOTAL_MEMBER
 * DESC.   : 해당 상점 총 회원수 조회
 * COMMENT :
 * HISTORY : 2021.06.29 / 쿼리 정의
 * WRITER  : minho
 */
SELECT COUNT(DISTINCT(m.member_id)) as total_data
FROM member m INNER JOIN member_shop ms ON m.member_id  = ms.member_id AND ms.shop_id=:shop_id
LEFT JOIN pet p on m.member_id =p.member_id 
LEFT JOIN (SELECT * FROM reservation
		   WHERE (member_id,reserv_dt,reg_dt ) in(SELECT
												member_id
												,max(reserv_dt) as reserv_dt
												,max(reg_dt) as reg_dt
												FROM reservation
												WHERE shop_id =:shop_id
												AND (reserv_status ='rs04')
												GROUP BY member_id  )
			AND shop_id =:shop_id
			AND reserv_status ='rs04'
			ORDER BY reserv_dt DESC) r ON m.member_id = r.member_id
WHERE 1=1 
<% if (search_content) { %>
AND (
     m.member_nm LIKE concat('%', TRIM(:search_content), '%')
    OR m.mobile LIKE concat('%', TRIM(:search_content), '%')
    OR m.phone LIKE concat('%', TRIM(:search_content), '%')
	OR p.pet_nm LIKE concat('%', TRIM(:search_content), '%')
)
<% } %>
-- 전체
<% if (search_type === 'search00') { %>
	<% if (svc_type && !user_id) { %>
		<%if (svc_type==='st01'|| svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
			AND r.reserv_id IS NOT NULL
			AND r.svc_type= :svc_type
		<% }  %>
	<% } %>
	<% if (!svc_type && user_id) { %>
			AND r.reserv_id IS NOT NULL
			AND r.user_id = :user_id
	<% } %>
	<% if (svc_type && user_id) { %>
			AND r.reserv_id IS NOT NULL
		<%if (svc_type==='st01'|| svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
			AND r.svc_type= :svc_type
		<% }  %>
			AND r.user_id = :user_id
	<% } %>
<% } %>
-- 등록일
<% if (search_type === 'search01') { %>
	<% if (start_date && end_date) { %>
		AND m.reg_dt BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
	<% } %>
<% } %>
-- 이용일
<% if (search_type === 'search02') { %>
	<% if (!start_date && !end_date && !svc_type && !user_id) { %>	
		AND r.reserv_id IS NOT NULL
	<% } %>
	<% if (!start_date && !end_date && svc_type && !user_id) { %>	
		AND r.reserv_id IS NOT NULL
		<%if (svc_type==='st01'|| svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
		AND r.svc_type= :svc_type
		<% }  %>
		<% } %>
	<% if (!start_date && !end_date && !svc_type && user_id) { %>
		AND r.reserv_id IS NOT NULL	
		AND r.user_id = :user_id
	<% } %>
	<% if (start_date && end_date && !svc_type && !user_id) { %>
		AND r.reserv_id IS NOT NULL
		AND r.reserv_dt BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
	<% } %>
	<% if (start_date && end_date && !svc_type && user_id) { %>
		AND r.reserv_id IS NOT NULL
		AND r.reserv_dt BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
		AND r.user_id = :user_id
	<% } %>
	<% if (start_date && end_date && svc_type && !user_id) { %>
		AND r.reserv_id IS NOT NULL
		AND r.reserv_dt BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
		<%if (svc_type==='st01'||svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
		AND r.svc_type= :svc_type
		<% }  %>
	<% } %>
	<% if (start_date && end_date && svc_type && user_id) { %>
		AND r.reserv_id IS NOT NULL
		AND r.reserv_dt BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
		<%if (svc_type==='st01'||svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
		AND r.svc_type= :svc_type
		<% }  %>
		AND r.user_id = :user_id
	<% } %>
<% } %>
-- 신규 회원
<% if (search_type ==='dash01') { %>
AND DATE_FORMAT( m.reg_dt,'%m-%d') BETWEEN DATE_FORMAT(DATE_SUB(CURRENT_DATE() ,INTERVAL 7 Day),'%m-%d') AND DATE_FORMAT(CURRENT_DATE(),'%m-%d')
GROUP BY m.member_id
<% } %>
-- 이용권 보유
<% if (search_type ==='dash02') { %>
AND m.member_id ='지금 기능 안됨'
<% } %>
-- 생일 회원
<% if (search_type ==='dash03') { %>
AND DATE_FORMAT(m.birthday,'%m-%d') = DATE_FORMAT(CURRENT_DATE(),'%m-%d')  
GROUP BY m.member_id
<% } %>

<% } %>

<% if ( sql_id === 'REGISTER_PET' ) {%>
/**
 * SQL ID  : REGISTER_PET
 * DESC.   : 회원 반려동물 신규 등록
 * COMMENT :
 * HISTORY : 2021.07.01 / 쿼리 정의
 * WRITER  : minho
 */
INSERT INTO pet(pet_id, member_id, pet_nm, profile_asset_id, pet_type, breed_id, sex, birthday, weight, neutralization_yn, old_yn, memo)
SELECT :pet_id, :member_id, :pet_nm, :profile_asset_id, :pet_type, :breed_id, :sex, :birthday, :weight, :neutralization_yn, :old_yn, :memo
FROM dual
WHERE NOT EXISTS(SELECT * FROM pet WHERE pet_id = :pet_id);
<% } %>

<% if ( sql_id === 'MEMBER_DETAIL' ) {%>
/**
 * SQL ID  : MEMBER_DETAIL
 * DESC.   : 회원 상세정보 조회
 * COMMENT :
 * HISTORY : 2021.07.01 / 쿼리 정의
 * WRITER  : minho
 */
SELECT m.member_id
	  ,ms.member_num
	  ,m.email
	  ,m.member_nm
	  ,m.sex as sex
	  ,m.mobile
	  ,m.phone
	  ,m.address
	  ,m.address_detail
	  ,m.birthday
	  ,m.join_channel
	  ,m.reg_dt
	  ,m.push_yn
	  ,m.email_noti_yn
	  ,p.pet_id
	  ,p.pet_nm
	  ,p.profile_asset_id
	  ,p.pet_type
	  ,(select up_breed_id from breed b where b.breed_id =p.breed_id) as breed_id
	  ,p.breed_id as breed_id2
	  ,p.sex as pet_sex
	  ,p.birthday as pet_birthday
	  ,TRUNCATE((SELECT Age(p.birthday)),1) as pet_age
	  ,p.weight
	  ,p.neutralization_yn
	  ,p.old_yn
	  ,p.memo
	  ,p.profile_asset_id
FROM member m INNER JOIN member_shop ms ON m.member_id  = ms.member_id
AND ms.shop_id =:shop_id
AND m.member_id =:member_id
LEFT JOIN pet p ON m.member_id =p.member_id
ORDER BY p.reg_dt
<% } %>

<% if ( sql_id === 'MEMBER_DETAIL_RESERV' ) {%>
/**
 * SQL ID  : MEMBER_DETAIL
 * DESC.   : 회원 상세정보 조회
 * COMMENT :
 * HISTORY : 2021.07.01 / 쿼리 정의
 * WRITER  : minho
 */
SELECT r.reserv_id
	  ,r.svc_id
	  ,r.shop_id
	  ,r.member_id
	  ,r.svc_price_id
	  ,r.pet_id
	  ,r.user_id
	  ,r.reserv_dt
	  ,r.reserv_stm
	  ,r.reserv_etm
	  ,r.reserv_status
	  ,r.tot_price
	  ,r.deposit
	  ,r.pay_price
	  ,r.reserv_memo
	  ,p.pay_id
	  ,p.pay_method
	  ,p.fee_amt
	  ,p.pay_amt
	  ,p.pay_dt
	  ,p.reg_dt
FROM reservation r LEFT JOIN payment p ON r.reserv_id = p.reserv_id
WHERE r.member_id =:member_id
AND r.reserv_status ='rs04'
AND r.shop_id = :shop_id
ORDER BY r.reg_dt
<% } %>



<% if ( sql_id === 'UPDATE_MEMBER_DETAIL' ) {%>
/**
 * SQL ID  : UPDATE_MEMBER_DETAIL
 * DESC.   : 회원 상세정보 수정
 * COMMENT :
 * HISTORY : 2021.07.02 / 쿼리 정의
 * WRITER  : minho
 */

UPDATE member as m
	INNER JOIN member_shop as ms
			ON m.member_id = ms.member_id
			AND ms.shop_id = :shop_id
			AND ms.member_id = :member_id
SET
m.reg_dt = m.reg_dt
<% if (member_nm) { %>
    ,m.member_nm = :member_nm
 <% } %>
 <% if (mobile) { %>
    ,m.mobile = :mobile
 <% } %>
 <% if (phone) { %>
   ,m.phone = :phone
 <% } %>
 <% if (sex) { %>
   ,m.sex = :sex
 <% } %>
 <% if (address) { %>
   ,m.address = :address
 <% } %>
 <% if (address_detail) { %>
   ,m.address_detail = :address_detail
 <% } %>
 <% if (birthday) { %>
   ,m.birthday = :birthday
 <% } %>
 <% if (join_channel) { %>
   ,m.join_channel = :join_channel
 <% } %>
 <% if (push_yn) { %>
   ,m.push_yn = :push_yn
 <% } %>
 <% if (email_noti_yn) { %>
   ,m.email_noti_yn = :email_noti_yn
 <% } %>
WHERE m.member_id = :member_id
-- WHERE NOT EXISTS(SELECT * FROM (SELECT email from member where email = :email) as t);
<% } %>

<% if ( sql_id === 'UPDATE_PET_DETAIL' ) {%>
/**
 * SQL ID  : UPDATE_PET_DETAIL
 * DESC.   : 반려동물 상세정보 수정
 * COMMENT :
 * HISTORY : 2021.07.07 / 쿼리 정의
 * WRITER  : minho
 */

UPDATE pet as p
	INNER JOIN member as m
			ON p.member_id = m.member_id
			AND p.pet_id = :pet_id
SET
p.reg_dt = p.reg_dt
 <% if (pet_nm) { %>
    ,p.pet_nm = :pet_nm
 <% } %>
  <% if (pet_type) { %>
    ,p.pet_type = :pet_type
 <% } %>
 <% if (breed_id) { %>
    ,p.breed_id = :breed_id
 <% } %>
 <% if (birthday) { %>
   ,p.birthday = :birthday
 <% } %>
 <% if (weight) { %>
   ,p.weight = :weight
 <% } %>
 <% if (profile_asset_id) { %>
   ,p.profile_asset_id = :profile_asset_id
 <% } %>
 <% if (sex) { %>
   ,p.sex = :sex
 <% } %>
 <% if (neutralization_yn) { %>
   ,p.neutralization_yn = :neutralization_yn
 <% } %>
 <% if (old_yn) { %>
   ,p.old_yn = :old_yn
 <% } %>
 <% if (memo) { %>
   ,p.memo = :memo
 <% } %>
<% } %>


<% if ( sql_id === 'DELETE_PET' ) {%>
/**
 * SQL ID  : DELETE_PET
 * DESC.   : 반려동물 삭제
 * COMMENT :
 * HISTORY : 2021.07.27 / 쿼리 정의
 * WRITER  : minho
 */

DELETE FROM pet WHERE pet_id = :pet_id;

<% } %>

<% if ( sql_id === 'INQUIRE_PET_DETAIL' ) {%>
/**
 * SQL ID  : INQUIRE_PET_DETAIL
 * DESC.   : 반려동물 상세정보 조회
 * COMMENT :
 * HISTORY : 2021.07.21 / 쿼리 정의
 * WRITER  : minho
 */

SELECT
	p.pet_id
	,p.member_id
	,p.pet_type
	,(select up_breed_id from breed b where b.breed_id =p.breed_id) as breed_id
	,p.breed_id as breed_id2
	,p.pet_nm
	,p.sex as pet_sex
	,p.weight
	,p.birthday
	,p.neutralization_yn
	,p.profile_asset_id
	,p.memo
	,ms.member_num
	,m.member_nm
	,m.sex
	,m.mobile
FROM pet p
INNER JOIN member m ON p.member_id = m.member_id
AND p.pet_id = :pet_id
LEFT JOIN member_shop ms ON p.member_id = ms.member_id
<% } %>


<% if ( sql_id === 'PET_DETAIL_RESERV' ) {%>
/**
 * SQL ID  : PET_DETAIL_RESERV
 * DESC.   : 반려동물 예약 내역 조회
 * COMMENT :
 * HISTORY : 2021.08.26 / 쿼리 정의
 * WRITER  : minho
 */
SELECT r.reserv_id
	  ,r.svc_id
	  ,r.shop_id
	  ,r.member_id
	  ,r.svc_price_id
	  ,r.pet_id
	  ,r.user_id
	  ,r.reserv_dt
	  ,r.reserv_stm
	  ,r.reserv_etm
	  ,r.reserv_status
	  ,r.tot_price
	  ,r.deposit
	  ,r.pay_price
	  ,r.reserv_memo
	  ,p.pay_id
	  ,p.pay_method
	  ,p.fee_amt
	  ,p.pay_amt
	  ,p.pay_dt
	  ,p.reg_dt
FROM reservation r LEFT JOIN payment p ON r.reserv_id = p.reserv_id
WHERE r.pet_id = :pet_id
AND r.reserv_status ='rs04'
AND r.shop_id = :shop_id
ORDER BY r.reg_dt
<% } %>

<% if ( sql_id === 'INQUIRE_PET_PORTFOLIO' ) {%>
/**
 * SQL ID  : INQUIRE_PET_PORTFOLIO
 * DESC.   : 반려동물 포트폴리오 조회
 * COMMENT :
 * HISTORY : 2021.08.24 / 쿼리 정의
 * WRITER  : minho
 */

-- SELECT p.port_id
-- 	   ,p.reserv_id
-- 	   ,p.svc_id
-- 	   ,p.user_id
-- 	   ,p.port_post
-- 	   ,GROUP_CONCAT(pa.port_asset_id separator '|') as port_asset_id
-- FROM portfolio p 
-- LEFT JOIN port_asset pa ON p.port_id = pa.port_id 
-- WHERE p.pet_id = :pet_id
-- GROUP BY p.port_id 

SELECT p.port_id
	   ,p.reserv_id
	   ,p.svc_id
	   ,p.user_id
	   ,(SELECT user_nm FROM user WHERE user_id = p.user_id ) as user_nm
	   ,(SELECT reserv_dt FROM reservation WHERE reserv_id = p.reserv_id AND pet_id =:pet_id) as reserv_dt
	   ,p.port_post
	   ,p.reg_dt
	   ,GROUP_CONCAT(pa.port_asset_id separator '|') as port_asset_id
FROM portfolio p 
LEFT JOIN port_asset pa ON p.port_id = pa.port_id 
WHERE p.pet_id = :pet_id
GROUP BY p.port_id
ORDER BY p.reg_dt DESC
LIMIT :start_no, :list_size

<% } %>


<% if ( sql_id === 'UPDATE_PORTFOLIO_ASSET' ) {%>
/**
 * SQL ID  : UPDATE_PORTFOLIO_ASSET
 * DESC.   : 반려동물 포트폴리오 에셋 수정
 * COMMENT :
 * HISTORY : 2021.08.24 / 쿼리 정의
 * WRITER  : minho
 */

UPDATE port_asset SET port_asset_id =:after_port_asset_id 
WHERE port_id = :port_id AND port_asset_id = :before_port_asset_id

<% } %>

<% if ( sql_id === 'DELETE_PORTFOLIO_ASSET' ) {%>
/**
 * SQL ID  : DELETE_PORTFOLIO_ASSET
 * DESC.   : 반려동물 포트폴리오 에셋 삭제
 * COMMENT :
 * HISTORY : 2021.08.24 / 쿼리 정의
 * WRITER  : minho
 */


DELETE FROM port_asset 
WHERE port_id = :port_id
AND port_asset_id = :port_asset_id

<% } %>


<% if ( sql_id === 'INQUIRE_BREED' ) {%>
/**
 * SQL ID  : INQUIRE_BREED
 * DESC.   : 반려동물 품종 조회
 * COMMENT :
 * HISTORY : 2021.07.21 / 쿼리 정의
 * WRITER  : minho
 */

SELECT * FROM v_breed
<% } %>

<% if ( sql_id === 'TOTAL_PET' ) {%>
/**
 * SQL ID  : TOTAL_PET
 * DESC.   : 해당 상점 총 반려동물 수
 * COMMENT :
 * HISTORY : 2021.07.22 / 쿼리 정의
 * WRITER  : minho
 */

select COUNT(DISTINCT (p.member_id)) as total_data from pet p
INNER JOIN member_shop ms ON p.member_id = ms.member_id AND ms.shop_id =:shop_id

<% } %>

<% if ( sql_id === 'LIST_PET' ) {%>
/**
 * SQL ID  : LIST_PET
 * DESC.   : 해당 상점 반러동물 리스트 조회
 * COMMENT :
 * HISTORY : 2021.07.22 / 쿼리 정의
 * WRITER  : minho
 * HISTORY : 2021.08.19 / 쿼리 수정 => 기준 테이블 member->pet으로 변경(기획 변경)
 * WRITER  : minho
 */

-- SELECT m.member_id
--       ,m.member_nm as member_nm
--       ,m.birthday
--       ,m.mobile as mobile
--       ,m.phone
--       ,m.address
--       ,m.address_detail
--       ,GROUP_CONCAT(DATE_FORMAT(p.reg_dt,"%Y.%m.%d") separator ',') as reg_dt
-- 	  ,GROUP_CONCAT(p.pet_id separator ',') as pet_id
--       ,GROUP_CONCAT(p.pet_nm separator ',') as pet_nm
-- 	  ,GROUP_CONCAT(IFNULL(p.memo,'') separator '|') as pet_memo
--       ,GROUP_CONCAT(IFNULL(TRUNCATE((SELECT Age(p.birthday)),1),'') separator ',') as pet_birthday
--       ,(SELECT count(*) FROM reservation
-- 	    WHERE member_id = m.member_id
-- 	   	AND shop_id = :shop_id
-- 		AND reserv_status ='rs04' ) as reserv_cnt
--    	  ,(SELECT reserv_dt FROM reservation
-- 		WHERE member_id = m.member_id
-- 		AND shop_id =:shop_id
-- 		AND reserv_status ='rs04'
-- 		ORDER BY reserv_dt DESC, reserv_stm DESC LIMIT 1) as recent_visit
-- 	  ,(SELECT vsc.svc_cate_nm FROM v_svc_category vsc
--     	INNER JOIN service s2 ON vsc.svc_cate_id = s2.svc_cate_id
--     	WHERE s2.svc_id = ( SELECT svc_id FROM reservation r2
-- 							WHERE shop_id = :shop_id
-- 							AND reserv_status = 'rs04'
-- 							AND member_id = m.member_id
-- 							ORDER BY reserv_dt DESC,reserv_stm DESC LIMIT 1)
-- 						) as recent_svc_nm
-- 	  ,(SELECT user_nm from user
-- 	  	WHERE user_id =(SELECT user_id FROM reservation r2
-- 						WHERE shop_id = :shop_id
-- 						AND member_id = m.member_id
-- 						AND reserv_status ='rs04'
-- 						ORDER BY reserv_dt DESC,reserv_stm DESC LIMIT 1)
-- 						) as user_nm
-- FROM member m INNER JOIN member_shop ms ON m.member_id = ms.member_id AND ms.shop_id = :shop_id
-- LEFT JOIN pet p ON m.member_id = p.member_id
-- WHERE p.pet_id IS NOT NULL
-- GROUP BY m.member_id
-- ORDER BY @order_key :order_type
-- LIMIT :start_no, :list_size

SELECT p.pet_id
	  ,p.pet_nm
	  ,p.birthday as pet_birthday
	  ,p.memo
	  ,p.reg_dt
	  ,m.member_id
	  ,m.member_nm as member_nm
	  ,m.birthday
      ,m.mobile as mobile
      ,m.phone
      ,m.address
      ,m.address_detail
      ,(SELECT count(*) FROM reservation
	    WHERE shop_id = :shop_id
	    AND pet_id = p.pet_id
		AND reserv_status ='rs04') as reserv_cnt
	  ,(SELECT reserv_dt FROM reservation
		WHERE shop_id = :shop_id
		AND pet_id = p.pet_id
		AND reserv_status = 'rs04'
		ORDER BY reserv_dt DESC, reserv_stm DESC LIMIT 1) as recent_visit
	  ,(SELECT svc_nm FROM service s WHERE 
				  svc_id =( SELECT svc_id FROM reservation r2
							WHERE shop_id = :shop_id
							AND reserv_status = 'rs04'
							AND pet_id = p.pet_id
							ORDER BY reserv_dt DESC,reserv_stm DESC LIMIT 1)) as recent_svc_nm
	  ,(SELECT user_nm from user
	  	WHERE user_id =(SELECT user_id FROM reservation r2
						WHERE shop_id = :shop_id
						AND pet_id = p.pet_id
						AND reserv_status ='rs04'
						ORDER BY reserv_dt DESC,reserv_stm DESC LIMIT 1)
						) as user_nm
FROM pet p 
	INNER JOIN (SELECT m2.* from member m2
	INNER JOIN  member_shop ms ON m2.member_id = ms.member_id 
	AND shop_id = :shop_id) as m
	ON p.member_id = m.member_id
WHERE p.pet_id IS NOT NULL
ORDER BY @order_key :order_type
LIMIT :start_no, :list_size
<% } %>



<% if ( sql_id === 'SEARCH_PET' ) {%>
/**
 * SQL ID  : SEARCH_PET
 * DESC.   : 해당 상점 반러동물 검색
 * COMMENT :
 * HISTORY : 2021.07.22 / 쿼리 정의
 * WRITER  : minho
 * HISTORY : 2021.08.19 / 쿼리 수정 => 기준 테이블 member->pet으로 변경(기획 변경)
 * WRITER  : minho
 */

-- SELECT m.member_id
--       ,m.member_nm as member_nm
--       ,m.birthday
--       ,m.mobile as mobile
--       ,m.phone
--       ,m.address
--       ,m.address_detail
--       ,GROUP_CONCAT(DATE_FORMAT(p.reg_dt,"%Y.%m.%d") separator ',') as reg_dt
-- 	  ,GROUP_CONCAT(p.pet_id separator ',') as pet_id
--       ,GROUP_CONCAT(p.pet_nm separator ',') as pet_nm
-- 	  ,GROUP_CONCAT(IFNULL(p.memo,'') separator '|') as pet_memo
--       ,GROUP_CONCAT(IFNULL(TRUNCATE((SELECT Age(p.birthday)),1),'') separator ',') as pet_birthday
--       ,(SELECT count(*) FROM reservation
-- 	    WHERE member_id = m.member_id
-- 	   	AND shop_id = :shop_id
-- 		AND reserv_status ='rs04' ) as reserv_cnt
--    	  ,(SELECT reserv_dt FROM reservation
-- 		WHERE member_id = m.member_id
-- 		AND shop_id =:shop_id
-- 		AND reserv_status ='rs04'
-- 		ORDER BY reserv_dt DESC, reserv_stm DESC LIMIT 1) as recent_visit
-- 	  ,(SELECT vsc.svc_cate_nm FROM v_svc_category vsc
--     	INNER JOIN service s2 ON vsc.svc_cate_id = s2.svc_cate_id
--     	WHERE s2.svc_id = ( SELECT svc_id FROM reservation r2
-- 							WHERE shop_id = :shop_id
-- 							AND reserv_status = 'rs04'
-- 							AND member_id = m.member_id
-- 							ORDER BY reserv_dt DESC,reserv_stm DESC LIMIT 1)
-- 						) as recent_svc_nm
-- 	  ,(SELECT user_nm from user
-- 	  	WHERE user_id =(SELECT user_id FROM reservation r2
-- 						WHERE shop_id = :shop_id
-- 						AND member_id = m.member_id
-- 						AND reserv_status ='rs04'
-- 						ORDER BY reserv_dt DESC,reserv_stm DESC LIMIT 1)
-- 						) as user_nm
-- FROM member m INNER JOIN member_shop ms ON m.member_id = ms.member_id AND ms.shop_id = :shop_id
-- LEFT JOIN pet p ON m.member_id = p.member_id
-- <% if (search_type ==='search02') { %>
-- LEFT JOIN (SELECT * FROM reservation
-- 		   WHERE (member_id,reserv_dt,reg_dt ) in(SELECT
-- 												member_id
-- 												,max(reserv_dt) as reserv_dt
-- 												,max(reg_dt) as reg_dt
-- 												FROM reservation
-- 												WHERE shop_id =:shop_id
-- 												AND (reserv_status ='rs04')
-- 												GROUP BY member_id  )
-- 			AND shop_id =:shop_id
-- 			AND reserv_status ='rs04'
-- 			ORDER BY reserv_dt DESC) r ON m.member_id = r.member_id
-- <% } %>
-- WHERE p.pet_id IS NOT NULL
-- <% if (search_content) { %>
-- AND (
--      m.member_nm LIKE concat('%', TRIM(:search_content), '%')
--     OR m.mobile LIKE concat('%', TRIM(:search_content), '%')
--     OR m.phone LIKE concat('%', TRIM(:search_content), '%')
-- 	OR p.pet_nm LIKE concat('%', TRIM(:search_content), '%')
-- )
-- <% } %>

-- -- 전체
-- <% if (search_type ==='search00') { %>
-- GROUP BY m.member_id 
-- <% } %>
-- -- 등록일
-- <% if (search_type ==='search01') { %>
-- 	<% if (!start_date || !end_date) { %>
-- 	GROUP BY m.member_id 
-- 	<% } else {%>
-- 	AND m.reg_dt BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
-- 	GROUP BY m.member_id
-- 	<% } %>
-- <% } %>
-- 이용일
-- <% if (search_type ==='search02') { %>
	-- <% if (!start_date && !end_date && !svc_type && !user_id) { %>	
	-- AND r.reserv_id IS NOT NULL
	-- GROUP BY m.member_id,r.reserv_id
	-- <% } %>

-- 	<% if (!start_date && !end_date && svc_type && !user_id) { %>	
-- 	AND r.reserv_id IS NOT NULL
-- 	<%if (svc_type==='st01'||svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
-- 		AND r.svc_type= :svc_type
-- 		<% }  %>
-- 	GROUP BY m.member_id ,r.reserv_id
-- 	<% } %>

-- 	<% if (!start_date && !end_date && !svc_type && user_id) { %>	
-- 	AND r.reserv_id IS NOT NULL
-- 	AND r.user_id = :user_id
-- 	GROUP BY m.member_id ,r.reserv_id
-- 	<% } %>

-- 	<% if (start_date && end_date && !svc_type && !user_id) { %>
-- 	AND r.reserv_id IS NOT NULL
-- 	AND r.reserv_dt BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
-- 	GROUP BY m.member_id ,r.reserv_id
-- 	<% } %>

-- 	<% if (start_date && end_date && !svc_type && user_id) { %>
-- 	AND r.reserv_id IS NOT NULL
-- 	AND r.reserv_dt BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
-- 	AND r.user_id = :user_id
-- 	GROUP BY m.member_id ,r.reserv_id
-- 	<% } %>

-- 	<% if (start_date && end_date && svc_type && !user_id) { %>
-- 	AND r.reserv_id IS NOT NULL
-- 	AND r.reserv_dt BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
-- 		<%if (svc_type==='st01'||svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
-- 		AND r.svc_type= :svc_type
-- 		<% }  %>
-- 	GROUP BY m.member_id ,r.reserv_id
-- 	<% } %>

-- 	<% if (start_date && end_date && svc_type && user_id) { %>
-- 	AND r.reserv_id IS NOT NULL
-- 	AND r.reserv_dt BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
-- 		<%if (svc_type==='st01'||svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
-- 		AND r.svc_type= :svc_type
-- 		<% }  %>
-- 	AND r.user_id = :user_id
-- 	GROUP BY m.member_id ,r.reserv_id
-- 	<% } %>
-- <% } %>
-- ORDER BY @order_key :order_type
-- LIMIT :start_no, :list_size

SELECT p.pet_id
	  ,p.pet_nm
	  ,p.birthday as pet_birthday
	  ,p.memo
	  ,p.reg_dt
	  ,m.member_id
	  ,m.member_nm as member_nm
	  ,m.birthday
      ,m.mobile as mobile
      ,m.phone
      ,m.address
      ,m.address_detail
	  ,MAX(r.reserv_dt) as rescent_visit
	  ,COUNT(r.pet_id) as reserv_cnt
	  ,(SELECT svc_nm FROM service s WHERE 
				  svc_id =( SELECT svc_id FROM reservation r2
							WHERE shop_id = :shop_id
							AND reserv_status = 'rs04'
							AND pet_id = p.pet_id
							ORDER BY reserv_dt DESC,reserv_stm DESC LIMIT 1)) as recent_svc_nm
	  ,(SELECT user_nm from user
	  	WHERE user_id =(SELECT user_id FROM reservation r2
						WHERE shop_id = :shop_id
						AND pet_id = p.pet_id
						AND reserv_status ='rs04'
						ORDER BY reserv_dt DESC,reserv_stm DESC LIMIT 1)
						) as user_nm
FROM pet p 
INNER JOIN (SELECT m2.* from member m2
INNER JOIN  member_shop ms ON m2.member_id = ms.member_id 
AND shop_id = :shop_id) as m
ON p.member_id = m.member_id
LEFT JOIN (SELECT * FROM reservation
		   WHERE (pet_id,reserv_dt,reg_dt ) in( SELECT
 												pet_id
 												,max(reserv_dt) as reserv_dt
 												,max(reg_dt) as reg_dt
 												FROM reservation
 												WHERE shop_id = :shop_id
 												AND reserv_status ='rs04'
 												GROUP BY pet_id  )
 			AND shop_id = :shop_id
 			AND reserv_status ='rs04'
 			ORDER BY reserv_dt DESC) r ON r.pet_id = p.pet_id
WHERE p.pet_id IS NOT NULL
-- 검색 문자열 
<% if (search_content) { %>
AND (
     m.member_nm LIKE concat('%', TRIM(:search_content), '%')
    OR m.mobile LIKE concat('%', TRIM(:search_content), '%')
    OR m.phone LIKE concat('%', TRIM(:search_content), '%')
	OR p.pet_nm LIKE concat('%', TRIM(:search_content), '%')
)
<% } %>
-- 전체
<% if (search_type ==='search00') { %>
	<% if ((!svc_type|| svc_type==='st00' )&& !user_id) { %>
	<% } %>

	<% if (svc_type && !user_id) { %>
		<%if (svc_type==='st01'|| svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
	AND r.reserv_id IS NOT NULL
	AND r.svc_type= :svc_type
		<% }  %>
	<% } %>

	<% if (!svc_type && user_id) { %>
	AND r.reserv_id IS NOT NULL
	AND r.user_id = :user_id
	<% } %>
	
	<% if (svc_type && user_id) { %>
	AND r.reserv_id IS NOT NULL
		<%if (svc_type==='st01'|| svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
	AND r.svc_type= :svc_type
		<% }  %>
	AND r.user_id = :user_id
	<% } %>
<% } %>
-- 등록일 기준
<% if (search_type ==='search01') { %>
AND p.reg_dt BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
<% } %>
-- 최근 이용일 기준
<% if (search_type ==='search02') { %>

	<% if (!start_date && !end_date && svc_type && !user_id) { %>	
	AND r.reserv_id IS NOT NULL
	<%if (svc_type==='st01'||svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
		AND r.svc_type= :svc_type
		<% }  %>
	<% } %>

	<% if (!start_date && !end_date && !svc_type && user_id) { %>	
	AND r.user_id = :user_id
	<% } %>

	<% if (start_date && end_date && !svc_type && !user_id) { %>
	AND (SELECT reserv_dt FROM reservation
		WHERE shop_id = :shop_id
		AND pet_id = p.pet_id
		AND reserv_status = 'rs04'
		ORDER BY reserv_dt DESC, reserv_stm DESC LIMIT 1) 
	BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
	<% } %>

	<% if (start_date && end_date && !svc_type && user_id) { %>
	AND (SELECT reserv_dt FROM reservation
		WHERE shop_id = :shop_id
		AND pet_id = p.pet_id
		AND reserv_status = 'rs04'
		ORDER BY reserv_dt DESC, reserv_stm DESC LIMIT 1) 
	BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
	AND r.user_id = :user_id
	<% } %>

	<% if (start_date && end_date && svc_type && !user_id) { %>
	AND (SELECT reserv_dt FROM reservation
		WHERE shop_id = :shop_id
		AND pet_id = p.pet_id
		AND reserv_status = 'rs04'
		ORDER BY reserv_dt DESC, reserv_stm DESC LIMIT 1) 
	BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
		<%if (svc_type==='st01'||svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
	AND r.svc_type= :svc_type
		<% }  %>
	<% } %>

	<% if (start_date && end_date && svc_type && user_id) { %>
	AND (SELECT reserv_dt FROM reservation
		WHERE shop_id = :shop_id
		AND pet_id = p.pet_id
		AND reserv_status = 'rs04'
		ORDER BY reserv_dt DESC, reserv_stm DESC LIMIT 1) 
	BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
		<%if (svc_type==='st01'||svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
	AND r.svc_type= :svc_type
		<% }  %>
	AND r.user_id = :user_id
	<% } %>

<% } %>
-- 대시보드 강아지 리스트
<% if (search_type ==='dash01') { %>
AND p.pet_type = 'pt01'
<% } %>
-- 대시보드 고양이 리스트
<% if (search_type ==='dash02') { %>
AND p.pet_type = 'pt02'
<% } %>
-- 대시보드 반려동물 생일 회원
<% if (search_type ==='dash03') { %>
AND DATE_FORMAT(p.birthday,'%m-%d') = DATE_FORMAT(CURRENT_DATE(),'%m-%d')
<% } %>
GROUP BY p.pet_id
ORDER BY @order_key :order_type
LIMIT :start_no, :list_size

<% } %>

<% if ( sql_id === 'SEARCH_TOTAL_PET' ) {%>
/**
 * SQL ID  : SEARCH_TOTAL_PET
 * DESC.   : 해당 상점 총 회원-펫 조회
 * COMMENT :
 * HISTORY : 2021.07.27 / 쿼리 정의
 * WRITER  : minho
   HISTORY : 2021.08.19 / 쿼리 수정 => 기준 테이블 member->pet으로 변경(기획 변경)
 * WRITER  : minho
 */

SELECT COUNT(DISTINCT(p.pet_id)) as total_data
FROM pet p 
INNER JOIN (SELECT m2.* from member m2
INNER JOIN  member_shop ms ON m2.member_id = ms.member_id 
AND shop_id = :shop_id) as m
ON p.member_id = m.member_id
LEFT JOIN (SELECT * FROM reservation
		   WHERE (pet_id,reserv_dt,reg_dt ) in( SELECT
 												pet_id
 												,max(reserv_dt) as reserv_dt
 												,max(reg_dt) as reg_dt
 												FROM reservation
 												WHERE shop_id = :shop_id
 												AND reserv_status ='rs04'
 												GROUP BY pet_id  )
 			AND shop_id = :shop_id
 			AND reserv_status ='rs04'
 			ORDER BY reserv_dt DESC) r ON r.pet_id = p.pet_id
WHERE p.pet_id IS NOT NULL
-- 검색 문자열 
<% if (search_content) { %>
AND (
     m.member_nm LIKE concat('%', TRIM(:search_content), '%')
    OR m.mobile LIKE concat('%', TRIM(:search_content), '%')
    OR m.phone LIKE concat('%', TRIM(:search_content), '%')
	OR p.pet_nm LIKE concat('%', TRIM(:search_content), '%')
)
<% } %>
-- 전체
<% if (search_type ==='search00') { %>
	<% if ((!svc_type|| svc_type==='st00' )&& !user_id) { %>
	<% } %>

	<% if (svc_type && !user_id) { %>
		<%if (svc_type==='st01'|| svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
	AND r.reserv_id IS NOT NULL
	AND r.svc_type= :svc_type
		<% }  %>
	<% } %>

	<% if (!svc_type && user_id) { %>
	AND r.reserv_id IS NOT NULL
	AND r.user_id = :user_id
	<% } %>
	
	<% if (svc_type && user_id) { %>
	AND r.reserv_id IS NOT NULL
		<%if (svc_type==='st01'|| svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
	AND r.svc_type= :svc_type
		<% }  %>
	AND r.user_id = :user_id
	<% } %>
<% } %>

-- 등록일 기준
<% if (search_type ==='search01') { %>
AND p.reg_dt BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
<% } %>
-- 최근 이용일 기준
<% if (search_type ==='search02') { %>

	<% if (!start_date && !end_date && svc_type && !user_id) { %>	
	AND r.reserv_id IS NOT NULL
	<%if (svc_type==='st01'||svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
		AND r.svc_type= :svc_type
		<% }  %>
	<% } %>

	<% if (!start_date && !end_date && !svc_type && user_id) { %>	
	AND r.user_id = :user_id
	<% } %>

	<% if (start_date && end_date && !svc_type && !user_id) { %>
	AND (SELECT reserv_dt FROM reservation
		WHERE shop_id = :shop_id
		AND pet_id = p.pet_id
		AND reserv_status = 'rs04'
		ORDER BY reserv_dt DESC, reserv_stm DESC LIMIT 1) 
	BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
	<% } %>

	<% if (start_date && end_date && !svc_type && user_id) { %>
	AND (SELECT reserv_dt FROM reservation
		WHERE shop_id = :shop_id
		AND pet_id = p.pet_id
		AND reserv_status = 'rs04'
		ORDER BY reserv_dt DESC, reserv_stm DESC LIMIT 1) 
	BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
	AND r.user_id = :user_id
	<% } %>

	<% if (start_date && end_date && svc_type && !user_id) { %>
	AND (SELECT reserv_dt FROM reservation
		WHERE shop_id = :shop_id
		AND pet_id = p.pet_id
		AND reserv_status = 'rs04'
		ORDER BY reserv_dt DESC, reserv_stm DESC LIMIT 1) 
	BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
		<%if (svc_type==='st01'||svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
	AND r.svc_type= :svc_type
		<% }  %>
	<% } %>

	<% if (start_date && end_date && svc_type && user_id) { %>
	AND (SELECT reserv_dt FROM reservation
		WHERE shop_id = :shop_id
		AND pet_id = p.pet_id
		AND reserv_status = 'rs04'
		ORDER BY reserv_dt DESC, reserv_stm DESC LIMIT 1) 
	BETWEEN :start_date AND DATE_ADD(:end_date,INTERVAL 1 DAY)
		<%if (svc_type==='st01'||svc_type==='st02' || svc_type==='st03' ||svc_type==='st04'){%>
	AND r.svc_type= :svc_type
		<% }  %>
	AND r.user_id = :user_id
	<% } %>
<% } %>
-- 대시보드 강아지 리스트
<% if (search_type ==='dash01') { %>
AND p.pet_type = 'pt01'
<% } %>
-- 대시보드 고양이 리스트
<% if (search_type ==='dash02') { %>
AND p.pet_type = 'pt02'
<% } %>
-- 대시보드 반려동물 생일 회원
<% if (search_type ==='dash03') { %>
AND DATE_FORMAT(p.birthday,'%m-%d') = DATE_FORMAT(CURRENT_DATE(),'%m-%d')
<% } %>
<% } %>

<% if ( sql_id === 'MEMBER_DASHBOARD' ) {%>
/**
 * SQL ID  : MEMBER_DASHBOARD
 * DESC.   : 회원관리 회원 리스트 대시보드
 * COMMENT :
 * HISTORY : 2021.08.17 / 쿼리 정의
 * WRITER  : minho
 */

SELECT 
	count(*) as total_member,
	(SELECT count(*) FROM member m
	INNER JOIN member_shop ms ON m.member_id = ms.member_id 
	AND ms.shop_id = :shop_id
	WHERE DATE_FORMAT(m.birthday,'%m-%d') = DATE_FORMAT(CURRENT_DATE(),'%m-%d') ) as birthday_member,
	(SELECT count(*)
	FROM member m
	INNER JOIN member_shop ms ON m.member_id = ms.member_id 
	AND ms.shop_id = :shop_id
	WHERE DATE_FORMAT( m.reg_dt,'%m-%d') BETWEEN DATE_FORMAT(DATE_SUB(CURRENT_DATE() ,INTERVAL 7 Day),'%m-%d') AND DATE_FORMAT(CURRENT_DATE(),'%m-%d')) as recent_reg_member
FROM member m 
INNER JOIN member_shop ms ON m.member_id = ms.member_id 
AND ms.shop_id = :shop_id

<% } %>


<% if ( sql_id === 'PET_DASHBOARD' ) {%>
/**
 * SQL ID  : PET_DASHBOARD
 * DESC.   : 회원관리 동물 리스트 대시보드
 * COMMENT :
 * HISTORY : 2021.08.17 / 쿼리 정의
 * WRITER  : minho
 */
 

SELECT 
	count(*) as total_pet,
	(SELECT 
	count(*)
	FROM pet p 
	INNER JOIN 
	(SELECT m.member_id FROM member m 
	INNER JOIN member_shop ms ON m.member_id = ms.member_id 
	AND shop_id = :shop_id) as temp
	ON p.member_id = temp.member_id
	AND p.pet_type ='pt01') as total_dog,
	(SELECT 
	count(*)
	FROM pet p 
	INNER JOIN 
	(SELECT m.member_id FROM member m 
	INNER JOIN member_shop ms ON m.member_id = ms.member_id 
	AND shop_id = :shop_id) as temp
	ON p.member_id = temp.member_id
	AND p.pet_type ='pt02') as total_cat,
	(SELECT 
	COUNT(*)
	FROM pet p 
	INNER JOIN 
	(SELECT m.member_id FROM member m 
	INNER JOIN member_shop ms ON m.member_id = ms.member_id 
	AND shop_id = :shop_id) as temp
	ON p.member_id = temp.member_id
	WHERE DATE_FORMAT(p.birthday,'%m-%d') = DATE_FORMAT(CURRENT_DATE(),'%m-%d')) as birthday_pet
FROM pet p 
INNER JOIN 
(SELECT m.member_id FROM member m 
INNER JOIN member_shop ms ON m.member_id = ms.member_id 
AND shop_id = :shop_id) as temp
ON p.member_id = temp.member_id

<% } %>


<% if ( sql_id === 'PET_DETAIL_SEARCH_MEMBER' ) {%>
/**
 * SQL ID  : PET_DETAIL_SEARCH_MEMBER
 * DESC.   : 회원관리 동물 상세정보 ->회원 조회
 * COMMENT :
 * HISTORY : 2021.08.24 / 쿼리 정의
 * WRITER  : minho
 */


SELECT m.member_id ,m.email, m.member_nm, m.phone, m.mobile from member m 
INNER JOIN member_shop ms ON m.member_id = ms.member_id 
AND ms.shop_id = :shop_id
WHERE (m.member_nm LIKE concat('%', TRIM(:search_content), '%')
OR m.email LIKE concat('%', TRIM(:search_content), '%')
OR m.member_nm LIKE concat('%', TRIM(:search_content), '%')
OR m.phone LIKE concat('%', TRIM(:search_content), '%')
OR m.mobile LIKE concat('%', TRIM(:search_content), '%'))
<% } %>

<% if ( sql_id === 'REG_MEM_SEARCH_EMAIL' ) {%>
/**
 * SQL ID  : REG_MEM_SEARCH_EMAIL
 * DESC.   : 회원 등록 -> 이메일 중복체크
 * COMMENT :
 * HISTORY : 2021.08.26 / 쿼리 정의
 * WRITER  : minho
 */

SELECT m.member_id ,m.email,
	CASE WHEN CHAR_LENGTH(m.member_nm) > 2 THEN 
        CONCAT(
            SUBSTRING(m.member_nm , 1, 1)
            ,LPAD('*', CHAR_LENGTH(m.member_nm) - 2, '*')
            ,SUBSTRING(m.member_nm , CHAR_LENGTH(m.member_nm), CHAR_LENGTH(m.member_nm))
        )
        ELSE CONCAT(
            SUBSTRING(m.member_nm , 1, 1)
            ,LPAD('*', CHAR_LENGTH(m.member_nm) - 1, '*')
        )
    END AS masking_nm
FROM member m 
WHERE m.email = :search_content
<% } %>
