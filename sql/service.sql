/**********************************************************/
/* FILE NAME : service.sql                                   */
/* FILE DESC : 상품 관련 SQL                              */
/**********************************************************/

<% if ( sql_id === 'SERVICE_LIST' ) {%>
/**
 * SQL ID  : SERVICE_LIST
 * DESC.   : 기본 상품 리스트
 * COMMENT :
 * HISTORY : 2021.08.03 / 쿼리 정의
 * WRITER  : minho
 */
SELECT vsc.svc_cate_id
	  ,vsc.svc_cate_nm
	  ,sst.svc_type 
FROM v_svc_category vsc 
INNER JOIN shop_svc_type sst ON vsc.svc_type = sst.svc_type 
AND sst.shop_id = :shop_id
AND sst.svc_type = :svc_type
ORDER BY vsc.seq ASC
<% } %>

<% if ( sql_id === 'COMPARE_SERVICE' ) {%>
/**
 * SQL ID  : COMPARE_SERVICE
 * DESC.   : 기본 상품 - 등록중인 상품 비교
 * COMMENT :
 * HISTORY : 2021.08.09 / 쿼리 정의
 * WRITER  : minho
 */

SELECT vsc.svc_cate_id 
	  ,vsc.svc_type 
	  ,vsc.svc_cate_nm 
	  ,sst.use_yn 
	  ,s.svc_id 
	  ,s.svc_nm 
	  ,s.svc_desc 
	  ,s.svc_time 
FROM v_svc_category vsc 
INNER JOIN shop_svc_type sst ON vsc.svc_type = sst.svc_type 
AND sst.shop_id = :shop_id
AND sst.svc_type = :svc_type
AND sst.use_yn = 'Y'
LEFT JOIN service s ON vsc.svc_cate_id = s.svc_cate_id 
AND s.shop_id = :shop_id
ORDER BY vsc.seq ASC
<% } %>

<% if ( sql_id === 'SERVICE_OPTION_LIST' ) {%>
/**
 * SQL ID  : SERVICE_OPTION_LIST
 * DESC.   : 기본 상품 옵션 리스트
 * COMMENT :
 * HISTORY : 2021.08.03 / 쿼리 정의
 * WRITER  : minho
 */
-- SELECT vsco.svc_type
--       ,vsco.svc_cate_level 
-- 	  ,vsco.svc_cate_id
-- 	  ,vsco.svc_cate_nm
-- 	  ,vsco.svc_cate_id2
-- 	  ,vsco.svc_cate_nm2
-- 	  ,vsco.full_path
-- FROM v_svc_category_opt vsco 
-- INNER JOIN shop_svc_type sst ON vsco.svc_type = sst.svc_type 
-- AND sst.shop_id = :shop_id
-- AND sst.svc_type = :svc_type
-- ORDER BY vsco.seq ASC


SELECT vsco.svc_type
      ,vsco.svc_cate_level 
	  ,vsco.svc_cate_id
	  ,vsco.svc_cate_nm
	  ,vsco.svc_cate_id2
	  ,vsco.svc_cate_nm2
	  ,vsco.full_path
	  ,so.option_id 
	  ,so.option_nm 
	  ,so.option_price  
      ,so.use_yn 
	  ,(CASE
         WHEN so.use_yn = 'Y'
          THEN 1
         ELSE 0
      END) as boolean_yn
FROM v_svc_category_opt vsco 
INNER JOIN shop_svc_type sst ON vsco.svc_type = sst.svc_type 
AND sst.shop_id = :shop_id
AND sst.svc_type = :svc_type
<% if ( svc_type === 'st01' ) {%>
LEFT JOIN svc_option so ON vsco.svc_cate_id2 = so.svc_cate_id 
AND so.shop_id = :shop_id
AND so.svc_id = :svc_id
<% } %>
<% if ( svc_type === 'st02' || svc_type === 'st03' || svc_type === 'st04' ) {%>
LEFT JOIN svc_option so ON vsco.svc_cate_id = so.svc_cate_id 
AND so.shop_id = :shop_id
AND so.svc_id = :svc_id
<% } %>
ORDER BY vsco.seq ASC

<% } %>

<% if ( sql_id === 'DEFAULT_REG_SERVICE' ) {%>
/**
 * SQL ID  : DEFAULT_REG_SERVICE
 * DESC.   : 상점 기본 서비스 등록
 * COMMENT :
 * HISTORY : 2021.08.05 / 쿼리 정의
 * WRITER  : minho
 */
INSERT INTO service( 
    svc_id
    ,svc_cate_id
    ,svc_nm
    ,shop_id
    ,exposure_yn
    )
VALUES :default_svc
<% } %>

<% if ( sql_id === 'UPDATE_SERVICE_STAT' ) {%>
/**
 * SQL ID  : UPDATE_SERVICE_STAT
 * DESC.   : 상점 서비스 업데이트
 * COMMENT :
 * HISTORY : 2021.08.05 / 쿼리 정의
 * WRITER  : minho
 */
UPDATE service as s
SET
s.reg_dt = s.reg_dt
<% if (svc_desc) { %>
    ,s.svc_desc = :svc_desc
<% } %>
<% if (base_price) { %>
    ,s.base_price = :base_price
<% } %>
<% if (svc_time) { %>
    ,s.svc_time = :svc_time
<% } %>
<% if (exposure_yn) { %>
    ,s.exposure_yn = :exposure_yn
<% } %>
WHERE svc_id = :svc_id
AND shop_id = :shop_id
AND svc_cate_id = :svc_cate_id
<% } %>

<% if ( sql_id === 'REG_SERVICE_OPT' ) {%>
/**
 * SQL ID  : REG_SERVICE_OPT
 * DESC.   : 등록된 서비스에 옵션 추가
 * COMMENT :
 * HISTORY : 2021.08.09 / 쿼리 정의
 * WRITER  : minho
 */
INSERT INTO svc_option( 
    option_id
    ,shop_id
    ,svc_id
-- 옵션의 svc_cate_id
    ,svc_cate_id
    ,option_nm
    ,option_price
    ,use_yn
    )
VALUES( :option_id
       ,:shop_id
       ,:svc_id
       <% if ( svc_cate_id ) {%>
       ,:svc_cate_id
       <% } else {%>
    ,(SELECT svc_cate_id from v_svc_category_opt 
    WHERE svc_type = (SELECT svc_type FROM v_svc_category vsc 
        WHERE svc_cate_id = (SELECT svc_cate_id FROM service WHERE svc_id = :svc_id))
    AND svc_cate_nm = '기타')
       <% } %>
    --    ,:svc_cate_id
       ,:option_nm
       ,:option_price
       ,:use_yn )
-- FROM dual
-- WHERE NOT EXISTS(
--     SELECT * FROM svc_option 
--     WHERE shop_id = :shop_id 
--     <% if ( svc_cate_id ) {%>
--     AND svc_cate_id = :svc_cate_id
--     <% } else {%>
--     AND svc_cate_id = svc_cate_id
--     <% } %>
--     AND svc_id = :svc_id
--     )

<% } %>

<% if ( sql_id === 'UPDATE_SERVICE_OPT' ) {%>
/**
 * SQL ID  : UPDATE_SERVICE_OPT
 * DESC.   : 서비스 옵션 수정
 * COMMENT :
 * HISTORY : 2021.08.09 / 쿼리 정의
 * WRITER  : minho
 */
UPDATE svc_option as so
SET
so.reg_dt = so.reg_dt
<% if (option_nm) { %>
,so.option_nm = :option_nm
<% } %>
<% if (option_price) { %>
,so.option_price = :option_price
<% } %>
<% if (use_yn) { %>
,so.use_yn = :use_yn
<% } %>
WHERE 
so.option_id = :option_id
AND so.shop_id = :shop_id
<% if (svc_cate_id) { %>
AND so.svc_cate_id = :svc_cate_id
<% } %>

<% } %>

<% if ( sql_id === 'SHOP_SERVICE_LIST' ) {%>
/**
 * SQL ID  : SHOP_SERVICE_LIST
 * DESC.   : 해당 상점 판매중인 서비스 목록
 * COMMENT :
 * HISTORY : 2021.08.04 / 쿼리 정의
 * WRITER  : minho
 */

SELECT s.svc_id 
	  ,s.shop_id 
	  ,s.svc_nm 
	  ,s.svc_time 
	  ,s.svc_desc 
	  ,s.svc_cate_id 
	  ,s.exposure_yn 
	  ,sst.svc_type 
	  ,so.option_id
      ,so.svc_cate_id as svc_opt_cate_id 
	  ,so.option_nm 
	  ,so.use_yn 
      ,so.option_price
      ,(SELECT svc_cate_nm FROM v_svc_category_opt WHERE svc_cate_id2=svc_opt_cate_id ) as svc_cate_nm
FROM service s 
INNER JOIN shop_svc_type sst ON s.shop_id = sst.shop_id 
AND (SELECT svc_type FROM v_svc_category WHERE svc_cate_id =s.svc_cate_id ) = sst.svc_type 
AND sst.use_yn = 'Y'
AND sst.svc_type = :svc_type
AND s.shop_id = :shop_id
LEFT JOIN svc_option so ON so.svc_id = s.svc_id 


<% } %>

<% if ( sql_id === 'INQUIRE_BREED_LIST' ) {%>
/**
 * SQL ID  : INQUIRE_BREED_LIST
 * DESC.   : 해당 상점 품종 목록
 * COMMENT :
 * HISTORY : 2021.08.17 / 쿼리 정의
 * WRITER  : minho
 */

SELECT vb.pet_type,
	   vb.breed_id as breed_id1,
	   sb.breed_id as breed_id2,
	   vb.breed_level,
	   sb.breed_nm,
       (CASE
         WHEN (sb.shop_id != null && sb.breed_id != null)
          THEN 1
         ELSE 0
      END) as boolean_yn
FROM v_breed vb 
LEFT JOIN shop_breed sb ON vb.breed_id2 = sb.breed_id 
AND sb.shop_id = :shop_id
WHERE vb.pet_type = :pet_type
ORDER BY vb.seq

<% } %>


<% if ( sql_id === 'REG_BREED_GRP' ) {%>
/**
 * SQL ID  : REG_BREED_GRP
 * DESC.   : 해당 상점 품종 그룹 설정(추가/변경)
 * COMMENT :
 * HISTORY : 2021.08.18 / 쿼리 정의
 * WRITER  : minho
 */

INSERT INTO shop_breed(shop_id,breed_id,pet_type,breed_level,breed_nm)
SELECT :shop_id, :breed_id, :pet_type, :breed_level, :breed_nm
FROM dual
WHERE NOT EXISTS(SELECT * FROM shop_breed where breed_id = :breed_id)
<% } %>

<% if ( sql_id === 'INQUIRE_BREED_GROUP' ) {%>
/**
 * SQL ID  : INQUIRE_BREED_GROUP
 * DESC.   : 해당 상점 품종 그룹 조회
 * COMMENT :
 * HISTORY : 2021.08.18 / 쿼리 정의
 * WRITER  : minho
 */

SELECT breed_id
      ,pet_type
      ,breed_level
      ,breed_nm
      ,up_breed_id
FROM shop_breed sb 
WHERE shop_id = :shop_id
AND pet_type = :pet_type
<% } %>


