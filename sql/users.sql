/**********************************************************/
/* FILE NAME : user.sql                                   */
/* FILE DESC : 사용자 관련 SQL                            */
/**********************************************************/

<% if ( sql_id === 'USER_INFO' ) {%>
/**
 * SQL ID  : USER_INFO
 * DESC.   : 사용자 조회 액션
 * COMMENT :
 * HISTORY : 2019.04.16 / 쿼리 정의  
 */
SELECT *
FROM user
WHERE user_id = :user_id;
<% } %>

<% if ( sql_id === 'USER_LIST' ) {%>
/**
 * SQL ID  : USER_LIST
 * DESC.   : 사용자 리스트 조회 액션
 * COMMENT :
 * HISTORY : 2019.04.16 / 쿼리 정의  
 */
SELECT *
FROM user
WHERE 1 = 1
  <% if ( search_field && search_value ) { %>
  AND @search_field = :search_value;
  <% } %>
<% } %>
