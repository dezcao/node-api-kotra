/**********************************************************/
/* FILE NAME : asset.sql                                  */
/* FILE DESC : 파일 업로드 및 자산 관련 sql               */
/**********************************************************/

<% if ( sql_id === 'CREATE_ASSET' ) {%>
/**
 * SQL ID  : CREATE_ASSET
 * DESC.   : 파일 업로드 처리
 * COMMENT :
 * HISTORY : 2021.06.22 / 쿼리 정의  
 * WRITER  : asdaisy 
 */
INSERT
	INTO asset (
		asset_id,
		originalname,
		encoding,
		mimetype,
		url,
		destination,
		filename,
		`path`,
		`size`,
		reg_dttm)
	VALUES(
	  :asset_id,
	  :originalname,
	  :encoding,
	  :mimetype,
	  :url,
	  :destination,
	  :filename,
	  :path,
	  :size,
	CURRENT_TIMESTAMP);
<% } %>

<% if ( sql_id === 'COMCODE' ) {%>
/**
 * SQL ID  : COMCODE
 * DESC.   : 공통코드 조회
 * COMMENT :
 * HISTORY : 2021.06.22 / 쿼리 정의  
 * WRITER  : asdaisy 
 */
SELECT 
   common_code
  ,code_type
  ,code_name
  ,ifnull(extra,'') as extra
FROM common_code 
WHERE use_yn = 'Y'
  <% if ( typeof code_type !== 'undefined' && code_type) { %>
  AND code_type = :code_type
  <%}%>
ORDER BY common_code ;
<% } %>

<% if ( sql_id == 'GET_ASSET' ) {%>
/*
 * SQL ID  : GET_ASSET
 * DESC.   : asset 파일 정보 조회
 * COMMENT :
 * HISTORY : 2019.11.16 / 쿼리 정의
 * WRITER  : asdaisy 
 */
SELECT * from asset WHERE asset_id = :asset_id;
<% } %>

<% if ( sql_id === 'ADDSERVICE' ) {%>
/**
 * SQL ID  : ADDSERVICE
 * DESC.   : 부가 서비스 리스트 조회
 * COMMENT :
 * HISTORY : 2021.07.05 / 쿼리 정의  
 * WRITER  : asdaisy 
 */
SELECT 
  add_svc_id,
  add_svc_nm,
  add_svc_asset_id
FROM add_service WHERE base_yn = 'Y'; 
<% } %>

