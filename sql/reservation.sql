/**********************************************************/
/* FILE NAME : reservation.sql                                   */
/* FILE DESC : 예약 관련 SQL                              */
/**********************************************************/

<% if ( sql_id === 'COUNT_RESERVATION' ) {%>
/**
 * SQL ID  : COUNT_RESERVATION
 * DESC.   : 오늘 전체 예약 건수
 * COMMENT :
 * HISTORY : 2021.07.13 / 쿼리 정의
 * WRITER  : tyoh
 */
SELECT 
      COUNT(r.reserv_id) AS tot_reserv_cnt
 FROM reservation r 
INNER JOIN shop_svc_type sst USING (shop_id, svc_type)
WHERE r.shop_id = :shop_id
  AND r.reserv_dt = CURRENT_DATE();
<% } %>

<% if ( sql_id === 'COUNT_RESERVATION_BY_TYPE' ) {%>
/**
 * SQL ID  : COUNT_RESERVATION_BY_TYPE
 * DESC.   : 서비스 타입별 오늘 예약 건수
 * COMMENT :
 * HISTORY : 2021.07.13 / 쿼리 정의
 * WRITER  : tyoh
 */
SELECT sst.svc_type           AS svc_type
     , CodeName(sst.svc_type) AS svc_type_nm
     , COUNT(r.reserv_id)     AS reserv_cnt
 FROM shop_svc_type sst 
      LEFT JOIN reservation r 
             ON sst.shop_id = r.shop_id
            AND sst.svc_type = r.svc_type 
            AND r.reserv_dt = CURRENT_DATE()
WHERE sst.use_yn = 'Y'
  AND sst.shop_id = :shop_id
GROUP BY sst.svc_type
<% } %>

<% if ( sql_id === 'LIST_RESERVATION_USER_DAYOFF' ) {%>
/**
 * SQL ID  : LIST_RESERVATION_USER_DAYOFF
 * DESC.   : 오늘 휴무 직원
 * COMMENT :
 * HISTORY : 2021.07.14 / 쿼리 정의
 * WRITER  : tyoh
 */

/* 오늘 휴무 직원 수 카운트 */
SELECT COUNT(*) AS total_data
  FROM user_dayoff ud
       INNER JOIN `user` u     USING (user_id)
       INNER JOIN user_shop us USING (user_id)
WHERE us.shop_id = :shop_id
  AND ud.dayoff_start <= CURDATE()
  AND ud.dayoff_end >= CURDATE();

/* 오늘 휴무 직원 목록 */
SELECT Z.*
  FROM (
            SELECT @rownum := @rownum + 1                          AS rownum, list.*
              FROM (
                  SELECT ud.shop_id
                       , ud.user_id
                       , UserName(ud.user_id)     AS user_nm
                       , u.email
                       , us.user_level
                       , CodeName(us.user_level)  AS user_level_nm
                       , u.mobile
                       , us.hire_type 
                       , CodeName(us.hire_type)   AS hire_type_nm
                       , IFNULL(us.join_dt, "")   AS join_dt
                       , ud.dayoff_type
                       , codeName(ud.dayoff_type) AS dayoff_type_nm
                       , ud.dayoff_start
                       , ud.dayoff_end
                       , ud.comment
                       , ud.reg_dt
                    FROM user_dayoff ud
                         INNER JOIN `user` u     USING (user_id)
                         INNER JOIN user_shop us USING (user_id)
                   WHERE us.shop_id = :shop_id
                     AND ud.dayoff_start <= CURDATE()
                     AND ud.dayoff_end >= CURDATE()
                   ORDER BY reg_dt DESC
                )                      AS list
            , (SELECT @rownum := 0)    AS rownum
        ) Z
ORDER BY Z.@order_key :order_type
LIMIT :start_no, :list_size;
<% } %>

<% if ( sql_id === 'REGISTER_RESERVATION' ) {%>
/**
 * SQL ID  : REGISTER_RESERVATION
 * DESC.   : 예약 등록
 * COMMENT :
 * HISTORY : 2021.07.12 / 쿼리 정의
 * WRITER  : tyoh
 */
INSERT INTO reservation
            (reserv_id,
             svc_id,
             shop_id,
             member_id,
             svc_type,
             order_num,
             pet_id,
             user_id,
             reserv_dt,
             reserv_edt,
             reserv_stm,
             reserv_etm,
             reserv_status,
             tot_price,
             deposit,
             pay_price,
             reserv_memo,
             commission,
             reg_dt,
             mod_dt)
SELECT       :reserv_id,
             :svc_id,
             :shop_id,
             :member_id,
             :svc_type,
             :order_num,
             :pet_id,
             :user_id,
             :reserv_dt,
             :reserv_edt,
             :reserv_stm,
             :reserv_etm,
             :reserv_status,
             :tot_price,
             :deposit,
             :pay_price,
             :reserv_memo,
             :commission,
             CURRENT_TIMESTAMP,
             CURRENT_TIMESTAMP
FROM DUAL
WHERE NOT EXISTS(SELECT * FROM reservation WHERE reserv_id = :reserv_id); 
<% } %>


<% if ( sql_id === 'DELETE_RESERVATION_OPTION' ) {%>
/**
 * SQL ID  : DELETE_RESERVATION_OPTION
 * DESC.   : 기존 등록된 예약옵션 전체 삭제
 * COMMENT :
 * HISTORY : 2021.07.30 / 쿼리 정의
 * WRITER  : tyoh
 */
DELETE FROM reserv_option 
 WHERE reserv_id = :reserv_id
   AND shop_id = :shop_id;
<% } %>

<% if ( sql_id === 'REGISTER_RESERVATION_OPTION' ) {%>
/**
 * SQL ID  : REGISTER_RESERVATION_OPTION
 * DESC.   : 예약 옵션 등록
 * COMMENT :
 * HISTORY : 2021.07.30 / 쿼리 정의
 * WRITER  : tyoh
 */

/* 예약옵션 저장 */
INSERT INTO reserv_option
            (reserv_option_id,
             reserv_id,
             svc_id,
             shop_id,
             member_id,
             option_nm,
             option_price,
             reg_dt)
VALUES      (:reserv_option_id,
             :reserv_id,
             :svc_id,
             :shop_id,
             :member_id,
             :option_nm,
             :option_price,
             CURRENT_TIMESTAMP); 
<% } %>

<% if ( sql_id === 'LIST_RESERVATION_DAY' ) {%>
/**
 * SQL ID  : LIST_RESERVATION_DAY
 * DESC.   : 예약 목록 (일별)
 * COMMENT :
 * HISTORY : 2021.07.16 / 쿼리 정의
 * WRITER  : tyoh
 */
SELECT Z.*
  FROM (
      SELECT @rownum := @rownum + 1                                                                              AS rownum, list.*
        FROM (
                SELECT r.shop_id
                     , r.svc_type
                     , CodeName(r.svc_type)                                             AS svc_type_nm
                     , r.order_num
                     , r.reserv_id 
                     , r.reserv_dt 
                     , r.reserv_status
                     , CodeName(r.reserv_status)                                        AS reserv_status_nm
                     , TIME_FORMAT(r.reserv_stm, '%H:%i')                               AS reserv_stm
                     , TIME_FORMAT(r.reserv_etm, '%H:%i')                               AS reserv_etm
                     , r.member_id 
                     , MemberName(r.member_id)                                          AS member_nm
                     , r.pet_id 
                     , IFNULL(PetName(r.pet_id), "")                                    AS pet_nm
                     , p.breed_id
                     , BreedName(p.breed_id)                                            AS breed_nm
                     , r.user_id
                     , UserName(r.user_id)                                              AS user_nm
                     , r.svc_id
                     , IFNULL((SELECT svc_nm FROM service WHERE svc_id = r.svc_id), '') AS svc_nm
                     , IFNULL(r.reserv_memo, "")                                        AS reserv_memo
                     , r.confirm_dt
                     , r.cancel_dt
                     , r.cancel_memo
                     , r.reserv_channel
                     , r.reg_dt
                     , r.mod_dt
                  FROM reservation r 
                       LEFT JOIN pet p USING (pet_id)
                 WHERE r.shop_id = :shop_id
                   AND r.reserv_dt = :reserv_dt
                   <% if (svc_type)      { %>AND r.svc_type = :svc_type                <% } %>
                   <% if (reserv_status) { %>AND r.reserv_status IN ( :reserv_status ) <% } %>
                   <% if (sch_user_id)   { %>AND r.user_id IN ( :sch_user_id )         <% } %>
             )                                                                         AS list
            , (SELECT @rownum := 0)                                                    AS rownum
      ) Z
ORDER BY Z.reg_dt DESC;
<% } %>

<% if ( sql_id === 'LIST_RESERVATION_DAY_BY_USER' ) {%>
/**
 * SQL ID  : LIST_RESERVATION_DAY_BY_USER
 * DESC.   : 예약 목록 (일별) 직원별 건수
 * COMMENT :
 * HISTORY : 2021.08.20 / 쿼리 정의
 * WRITER  : tyoh
 */
SELECT Z.user_id
     , Z.user_nm
     , Z.is_dayoff 
     , Z.dayoff_nm
     , Z.comment
     , Z.user_reserv_cnt
     , CONCAT(CAST(Z.user_nm AS CHAR), ' (', Z.user_reserv_cnt, '건)') user_nm_reserv_cnt
  FROM (
            (   SELECT us.user_id
                     , UserName(us.user_id)                                        AS user_nm
                     , IF(ud.user_id is NULL, 'N', 'Y')                            AS is_dayoff
                     , (SELECT COUNT(user_id)
                         FROM reservation 
                         WHERE shop_id = r.shop_id
                         AND reserv_dt = r.reserv_dt
                         AND svc_type = r.svc_type
                         AND r.reserv_status = r.reserv_status
                         AND user_id = r.user_id)                                  AS user_reserv_cnt
                     , IFNULL(CodeName(ud.dayoff_type), '')                        AS dayoff_nm
                     , IFNULL(ud.comment, '')                                      AS comment
                 FROM user_shop us 
                      LEFT JOIN user_dayoff ud 
                             ON us.shop_id = ud.shop_id
                            AND us.user_id = ud.user_id
                            AND ud.dayoff_start <= :reserv_dt
                            AND ud.dayoff_end >= :reserv_dt
                      LEFT JOIN reservation r 
                             ON us.user_id = r.user_id
                            AND r.shop_id = us.shop_id
                            AND r.reserv_dt = :reserv_dt
                            AND r.svc_type = :svc_type
                            <% if (reserv_status) { %>AND r.reserv_status IN ( :reserv_status ) <% } %>
                            <% if (sch_user_id)   { %>AND r.user_id IN ( :sch_user_id )         <% } %>
                 WHERE us.shop_id = :shop_id
                   AND us.retire_dt >= :reserv_dt
            ) UNION	(
                SELECT r.user_id 
                     , UserName(r.user_id)                                          AS user_nm
                     , 'N'                                                          AS is_dayoff
                     , (SELECT COUNT(user_id)
                          FROM reservation 
                         WHERE shop_id = r.shop_id
                           AND reserv_dt = r.reserv_dt
                           AND svc_type = r.svc_type
                           AND reserv_status = r.reserv_status
                           AND user_id = 'pending')                                 AS user_reserv_cnt
                     , ''                                                           AS dayoff_nm
                     , ''                                                           AS comment
                  FROM reservation r 
                 WHERE shop_id = :shop_id
                   AND reserv_dt = :reserv_dt
                   AND r.svc_type = :svc_type
                   <% if (reserv_status) { %>AND r.reserv_status IN ( :reserv_status ) <% } %>
                   <% if (sch_user_id)   { %>AND r.user_id IN ( :sch_user_id )         <% } %>
            )
        ) Z
ORDER BY user_nm;
<% } %>

<% if ( sql_id === 'SUMM_RESERVATION_COUNT_BY_WEEK' ) {%>
/**
 * SQL ID  : SUMM_RESERVATION_COUNT_BY_WEEK
 * DESC.   : 주간 일자별 예약건수 (미용)
 * COMMENT :
 * HISTORY : 2021.08.20 / 쿼리 정의
 * WRITER  : tyoh
 */
SELECT stdDate.reserv_dt
     , IFNULL(reservCnt.reserv_cnt, 0) AS reserv_cnt
  FROM (
    select std.reserv_dt as reserv_dt from (
        select :reserv_dt + INTERVAL (a.a + (10 * b.a) + (100 * c.a) + (1000 * d.a) ) DAY as reserv_dt
        from (select 0 as a union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9)           as a
            cross join (select 0 as a union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) as b
            cross join (select 0 as a union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) as c
            cross join (select 0 as a union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) as d
        ) std
    where std.reserv_dt BETWEEN :reserv_dt AND (select :reserv_dt + interval 6 day)
    ) stdDate 
       LEFT JOIN (
           SELECT r.reserv_dt
                , COUNT(r.reserv_id) AS reserv_cnt
             FROM reservation r 
            WHERE shop_id = :shop_id
              AND r.reserv_dt BETWEEN :reserv_dt AND (SELECT :reserv_dt + interval 6 day)
              <% if (svc_type)      { %>AND r.svc_type = :svc_type                <% } %>
              <% if (reserv_status) { %>AND r.reserv_status IN ( :reserv_status ) <% } %>
            GROUP BY r.reserv_dt
            ORDER BY r.reserv_dt
       ) reservCnt 
              ON stdDate.reserv_dt = reservCnt.reserv_dt
 ORDER BY stdDate.reserv_dt;
<% } %>

<% if ( sql_id === 'LIST_RESERVATION_WEEK' ) {%>
/**
 * SQL ID  : LIST_RESERVATION_WEEK
 * DESC.   : 예약 목록 (주별)
 * COMMENT :
 * HISTORY : 2021.07.27 / 쿼리 정의
 * WRITER  : tyoh
 */
/* 예약 목록 (주별) */
SELECT Z.*
  FROM (
         SELECT @rownum := @rownum + 1                                                                      AS rownum, list.*
           FROM (
                  SELECT r.shop_id
                       , r.svc_type
                       , CodeName(r.svc_type)                                             AS svc_type_nm
                       , r.order_num
                       , r.reserv_id
                       , (SELECT COUNT(*)
                           FROM shop_dayoff sd
                           WHERE (sd.dayoff_sdt <= r.reserv_dt AND sd.dayoff_edt >= r.reserv_dt)
                           AND sd.shop_id = r.shop_id
                           AND sd.svc_type = r.svc_type)                                  AS shop_dayoff_cnt
                       , r.reserv_dt
                       , r.reserv_edt
                       , r.reserv_status
                       , CodeName(r.reserv_status)                                        AS reserv_status_nm
                       , TIME_FORMAT(r.reserv_stm, '%H:%i')                               AS reserv_stm
                       , TIME_FORMAT(r.reserv_etm, '%H:%i')                               AS reserv_etm
                       , r.member_id
                       , MemberName(r.member_id)                                          AS member_nm
                       , CONCAT(r.reserv_id, '-', r.member_id)                            AS reserv_key
                       , r.pet_id
                       , PetName(r.pet_id)                                                AS pet_nm
                       , p.breed_id
                       , BreedName(p.breed_id)                                            AS breed_nm
                       , r.user_id
                       , UserName(r.user_id)                                              AS user_nm
                       , r.svc_id
                       , IFNULL((SELECT svc_nm FROM service WHERE svc_id = r.svc_id), '') AS svc_nm
                       , IFNULL(r.reserv_memo, "")                                        AS reserv_memo
                       , r.confirm_dt
                       , r.cancel_dt
                       , r.cancel_memo
                       , r.reserv_channel
                       , r.reg_dt
                       , r.mod_dt
                    FROM reservation r
                         LEFT JOIN pet p USING (pet_id)
                   WHERE r.shop_id = :shop_id
                     AND r.reserv_dt BETWEEN :reserv_dt AND (SELECT :reserv_dt + interval 6 day)
                     <% if (svc_type)      { %>AND r.svc_type = :svc_type                <% } %>
                     <% if (reserv_status) { %>AND r.reserv_status IN ( :reserv_status ) <% } %>
                     <% if (sch_user_id)   { %>AND r.user_id IN ( :sch_user_id )         <% } %>
                   ORDER BY r.reserv_dt ASC
                   )                                                                     AS list
                   , (SELECT @rownum := 0)                                               AS rownum
        ) Z
 ORDER BY Z.reg_dt DESC;
<% } %>

<% if ( sql_id === 'LIST_RESERVATION_MONTH' ) {%>
/**
 * SQL ID  : LIST_RESERVATION_MONTH
 * DESC.   : 예약 목록 (월별)
 * COMMENT :
 * HISTORY : 2021.08.03 / 쿼리 정의
 * WRITER  : tyoh
 */
SELECT r.reserv_dt
     <% if (!svc_type || svc_type === 'st01' || svc_type === 'st02') { %>
     , r.user_id 
     , UserName(r.user_id)                           AS user_nm
     , COUNT(r.user_id)                              AS tot_reserv_cnt_per_day
     <% } else { %>
     , r.svc_id
     , IFNULL(ServiceName(r.svc_id), '')             AS svc_nm
     , COUNT(r.svc_id)                               AS tot_reserv_cnt_per_day
     <% } %>
  FROM reservation r 
 WHERE r.shop_id = :shop_id
   AND r.reserv_dt >= :reserv_dt
   AND r.reserv_dt <= LAST_DAY(:reserv_dt)
   <% if (svc_type)      { %>AND r.svc_type = :svc_type                <% } %>
   <% if (reserv_status) { %>AND r.reserv_status IN ( :reserv_status ) <% } %>
   <% if (sch_user_id)   { %>AND r.user_id IN ( :sch_user_id )         <% } %>
<% if (!svc_type || svc_type === 'st01' || svc_type === 'st02') { %>
 GROUP BY r.reserv_dt, r.user_id
 ORDER BY r.reserv_dt, r.user_id
<% } else { %>
 GROUP BY r.reserv_dt, r.svc_id
 ORDER BY r.reserv_dt, r.svc_id
<% } %>
 ;
<% } %>

<% if ( sql_id === 'LIST_RESERVATION_PET' ) {%>
/**
 * SQL ID  : LIST_RESERVATION_PET
 * DESC.   : 반려동물 목록
 * COMMENT :
 * HISTORY : 2021.07.19 / 쿼리 정의
 * WRITER  : tyoh
 */
SELECT member_id 
     , MemberName(member_id)       AS member_nm
     , pet_id 
     , pet_nm 
     , pet_type
     , CodeName(pet_type)          AS pet_type_nm
     , breed_id 
     , BreedName(p.breed_id)       AS breed_nm
     , sex 
     , birthday 
     , IFNULL(weight, 0)           AS weight
     , profile_asset_id 
     , neutralization_yn 
     , old_yn 
     , memo 
     , reg_dt 
     , mod_dt 
  FROM pet p 
 WHERE member_id = :member_id
 <% if (pet_type) { %>
   AND pet_type = :pet_type
 <% } %>
;
<% } %>

<% if ( sql_id === 'SCH_RESERVATION_SHOP_MEMBER' ) {%>
/**
 * SQL ID  : SCH_RESERVATION_SHOP_MEMBER
 * DESC.   : 예약 등록용 고객 조회 매칭, 고객 아이디 조회
 * COMMENT :
 * HISTORY : 2021.08.23 / 쿼리 정의
 * WRITER  : tyoh
 */
SELECT DISTINCT m.member_id                    AS member_id
     , m.member_nm                             AS member_nm
     , PhoneNumber(m.mobile)                   AS mobile
     , p.pet_id
     , p.pet_nm                                AS pet_nm
  FROM pet p 
       JOIN member_shop ms ON p.member_id = ms.member_id
       JOIN member m       ON p.member_id = m.member_id
 WHERE ms.shop_id = :shop_id
 <% if (sch_type === 'member_nm' ) { %>
   AND m.member_nm like CONCAT('%', :sch_text, '%')
 <% } %>
 <% if (sch_type === 'pet_nm' ) { %>
   AND p.pet_nm like CONCAT('%', :sch_text, '%')
 <% } %>
 ;
<% } %>

<% if ( sql_id === 'SCH_RESERVATION_SHOP_PET_LIST' ) {%>
/**
 * SQL ID  : SCH_RESERVATION_SHOP_PET_LIST
 * DESC.   : 예약 등록용 고객 조회 매칭, 고객별 반려동물 목록
 * COMMENT :
 * HISTORY : 2021.08.23 / 쿼리 정의
 * WRITER  : tyoh
 */
SELECT p.member_id 
     , p.pet_id 
     , p.pet_nm 
     , p.pet_type
     , CodeName(p.pet_type)          AS pet_type_nm
     , p.breed_id 
     , BreedName(p.breed_id)         AS breed_nm
     , p.sex 
     , p.birthday 
     , IFNULL(p.weight, 0)           AS weight
     , p.profile_asset_id 
     , p.neutralization_yn 
     , p.old_yn 
     , p.memo 
     , p.reg_dt 
     , p.mod_dt 
  FROM pet p 
 WHERE p.member_id = :member_id
 ; 
<% } %>

<% if ( sql_id === 'RESERVATION_DETAIL' ) {%>
/**
 * SQL ID  : RESERVATION_DETAIL
 * DESC.   : 예약 상세정보 조회
 * COMMENT :
 * HISTORY : 2021.07.21 / 쿼리 정의
 * WRITER  : tyoh
 */
SELECT r.reserv_id
     , r.order_num
     , r.member_id
     , MemberName(r.member_id)                                                  AS member_nm
     , PhoneNumber(m.mobile)                                                    AS mobile
     , r.pet_id
     , CONCAT(
           (SELECT pet_nm FROM pet WHERE pet_id = r.pet_id), ' / '
         , (SELECT breed_nm FROM breed WHERE breed_id = (SELECT breed_id FROM pet WHERE pet_id = r.pet_id)), ' / '
         , IFNULL((SELECT weight FROM pet WHERE pet_id = r.pet_id), "0") , 'Kg' 
       )                                                                        AS pet_info
     , r.user_id
     , UserName(r.user_id)                                                      AS user_nm
     , r.reserv_dt
     , r.reserv_edt
     , IFNULL(DATEDIFF(r.reserv_edt, r.reserv_dt), 0)                           AS num_of_nights
     , TIME_FORMAT(r.reserv_stm, '%H:%i')                                       AS reserv_stm
     , TIME_FORMAT(r.reserv_etm, '%H:%i')                                       AS reserv_etm
     , r.reserv_status
     , CodeName(r.reserv_status)                                                AS reserv_status_nm
     , r.svc_type 
     , CodeName(r.svc_type)                                                     AS svc_type_nm
     , r.svc_id
     , (SELECT svc_nm FROM service WHERE svc_id = r.svc_id)                     AS svc_nm
     , r.reserv_memo
     , r.tot_price
     , r.deposit
     , r.pay_price
     , IFNULL((SELECT SUM(balance) 
          FROM prepayment p 
         WHERE p.member_id = r.member_id
           AND p.shop_id = r.shop_id), 0)                                       AS tot_balance
     , r.commission 
     , r.confirm_dt
     , r.cancel_dt
     , r.cancel_memo
     , r.reserv_channel
     , r.reg_dt
     , r.mod_dt
  FROM reservation r
       LEFT JOIN pet p    USING (pet_id) 
       LEFT JOIN member m    ON r.member_id = m.member_id
 WHERE r.shop_id = :shop_id
   AND r.reserv_id = :reserv_id;

/* 결제정보 */
SELECT r.reserv_id
     , (SELECT SUM(pay_amt) 
          FROM payment 
         WHERE reserv_id = r.reserv_id 
           AND order_num = r.order_num )                                                             AS tot_pay_amt
     , p2.pay_method
     , CodeName(p2.pay_method)                                                                       AS pay_method_nm
     , p2.pay_amt
     , p2.approval_num 
  FROM reservation r 
       LEFT JOIN payment p2 USING (reserv_id, order_num)
 WHERE r.shop_id = :shop_id
   AND r.reserv_id = :reserv_id;
<% } %>

<% if ( sql_id === 'RESERVATION_DETAIL_OPTION' ) {%>
/**
 * SQL ID  : RESERVATION_DETAIL_OPTION
 * DESC.   : 예약 상세정보, 옵션별 금액 조회
 * COMMENT :
 * HISTORY : 2021.08.12 / 쿼리 정의
 * WRITER  : tyoh
 */
SELECT ro.reserv_option_id
     , ro.reserv_id
     , ro.svc_id
     , ro.member_id
     , ro.option_nm
     , ro.option_price
  FROM reserv_option ro
 WHERE ro.shop_id = :shop_id
   AND ro.reserv_id = :reserv_id;
<% } %>

<% if ( sql_id === 'UPDATE_RESERVATION' ) {%>
/**
 * SQL ID  : UPDATE_RESERVATION
 * DESC.   : 예약 정보 수정
 * COMMENT :
 * HISTORY : 2021.07.20 / 쿼리 정의
 * WRITER  : tyoh
 */
UPDATE reservation r
   SET mod_dt = CURRENT_TIMESTAMP
     <% if (svc_id)        { %>, svc_id = :svc_id                <% } %>
     <% if (member_id)     { %>, member_id = :member_id          <% } %>
     <% if (svc_type)      { %>, svc_type = :svc_type            <% } %>
     <% if (order_num)     { %>, order_num = :order_num          <% } %>
     <% if (pet_id)        { %>, pet_id = :pet_id                <% } %>
     <% if (user_id)       { %>, user_id = :user_id              <% } %>
     <% if (reserv_dt)     { %>, reserv_dt = :reserv_dt          <% } %>
     <% if (reserv_edt)    { %>, reserv_edt = :reserv_edt        <% } %>
     <% if (reserv_stm)    { %>, reserv_stm = :reserv_stm        <% } %>
     <% if (reserv_etm)    { %>, reserv_etm = :reserv_etm        <% } %>
     <% if (reserv_status) { %>, reserv_status = :reserv_status  <% } %>
     <% if (tot_price)     { %>, tot_price = :tot_price          <% } %>
     <% if (deposit)       { %>, deposit = :deposit              <% } %>
     <% if (discount_amt)  { %>, discount_amt = :discount_amt    <% } %>
     <% if (pay_price)     { %>, pay_price = :pay_price          <% } %>
     <% if (commission)    { %>, commission = :commission        <% } %>
     <% if (reserv_memo)   { %>, reserv_memo = :reserv_memo      <% } %>
     <% if (confirm_dt)    { %>, confirm_dt = :confirm_dt        <% } %>
     <% if (cancel_dt)     { %>, cancel_dt = :cancel_dt          <% } %>
     <% if (cancel_memo)   { %>, cancel_memo = :cancel_memo      <% } %>
     <% if (reserv_channel){ %>, reserv_channel = :reserv_channel<% } %>
 WHERE r.reserv_id = :reserv_id
   AND r.shop_id = :shop_id;
<% } %>

<% if ( sql_id === 'CHECK_ORDER_NUM' ) {%>
/**
 * SQL ID  : CHECK_ORDER_NUM
 * DESC.   : 주문번호 중복 체크
 * COMMENT :
 * HISTORY : 2021.07.23 / 쿼리 정의
 * WRITER  : tyoh
 */
SELECT order_num 
  FROM reservation
 WHERE shop_id = :shop_id
   AND order_num = :order_num;
<% } %>

<% if ( sql_id === 'LIST_RESERV_PET_HISTORY' ) {%>
/**
 * SQL ID  : LIST_RESERV_PET_HISTORY
 * DESC.   : 반려동물 이용 목록
 * COMMENT :
 * HISTORY : 2021.08.05 / 쿼리 정의
 * WRITER  : tyoh
 */
SELECT r.reserv_dt
     , IFNULL(r.reserv_edt, "")                                                                 AS reserv_edt
     , r.svc_type
     , CodeName(r.svc_type)                                                                     AS svc_type_nm
     , r.svc_id 
     , IFNULL((SELECT svc_nm FROM service WHERE svc_id = r.svc_id AND shop_id = r.shop_id), "") AS svc_nm
     , r.pet_id
     , PetName(r.pet_id)                                                                        AS pet_nm
     , r.member_id 
     , MemberName(r.member_id)                                                                  AS member_nm
     , r.reserv_status
     , CodeName(r.reserv_status)                                                                AS reserv_status_nm
     , r.reserv_memo
  FROM reservation r 
 WHERE shop_id = :shop_id
   AND pet_id = :pet_id
 ORDER BY reserv_dt DESC;
<% } %>

<% if ( sql_id === 'LIST_RESERVATION_DETAIL_INFO' ) {%>
/**
 * SQL ID  : LIST_RESERVATION_DETAIL_INFO
 * DESC.   : 예약 리스트 상세내용 조회(팝업/목록보기)
 * COMMENT :
 * HISTORY : 2021.08.06 / 쿼리 정의
 * WRITER  : tyoh
 */

/* 예약 목록 총 건수 */
 SELECT COUNT(r.reserv_id) AS tot_reserv_cnt
   FROM reservation r 
        LEFT JOIN member m ON r.member_id = m.member_id
        LEFT JOIN payment p2 ON r.reserv_id = p2.reserv_id
  WHERE r.shop_id = :shop_id
    AND r.svc_type = :svc_type
    <% if (user_id)              { %>AND r.user_id = :user_id                                                                                  <% } %>
    <% if (reserv_dt) { %>
      <% if (!reserv_edt) { %>
    AND reserv_dt = :reserv_dt
      <% } else { %>
    AND reserv_dt >= :reserv_dt
    AND reserv_dt <= :reserv_edt
      <% } %>
    <% } %>
    <% if (reserv_status)        { %>AND r.reserv_status IN ( :reserv_status )                                                                 <% } %>
    <% if (pay_method)           { %>AND p2.pay_method   IN ( :pay_method )                                                                    <% } %>
    <% if (sch_user_id)          { %>AND r.user_id       IN ( :sch_user_id )                                                                   <% } %>
    <% if (sch_type === 'NAME')  { %>AND r.member_id     IN ( SELECT member_id FROM member WHERE member_nm LIKE CONCAT('%', :sch_text, '%') )  <% } %>
    <% if (sch_type === 'TEL')   { %>AND m.mobile        IN ( (SELECT mobile FROM member WHERE mobile LIKE CONCAT('%', :sch_text, '%')) )      <% } %>
    <% if (sch_type === 'EMAIL') { %>AND m.email         IN ( SELECT email FROM member WHERE email LIKE CONCAT('%', :sch_text, '%') )          <% } %>
;

/* 예약 목록 */
SELECT Z.*
FROM (
    SELECT @rownum := @rownum + 1                                                                                                    AS rownum, list.*
      FROM (
             SELECT r.reserv_id
                  , r.order_num
                  , r.member_id
                  , MemberName(r.member_id)                                                                       AS member_nm
                  , m.email 
                  , PhoneNumber(m.mobile)                                                                         AS mobile
                  , r.pet_id
                  , PetName(r.pet_id)                                                                             AS pet_nm
                  , CONCAT(
                      (SELECT pet_nm FROM pet WHERE pet_id = r.pet_id), ' / '
                      , (SELECT breed_nm FROM breed WHERE breed_id = (SELECT breed_id FROM pet WHERE pet_id = r.pet_id)), ' / '
                      , IFNULL((SELECT weight FROM pet WHERE pet_id = r.pet_id), "0") , 'Kg'
                  )                                                                                               AS pet_info
                  , r.user_id
                  , UserName(r.user_id)                                                                           AS user_nm
                  , us.user_status 
                  , CodeName(us.user_status)                                                                      AS user_status_nm
                  , r.reserv_dt
                  , r.reserv_edt
                  , IFNULL(DATEDIFF(r.reserv_edt, r.reserv_dt), 0)                                                AS num_of_nights
                  , TIME_FORMAT(r.reserv_stm, '%H:%i')                                                            AS reserv_stm
                  , TIME_FORMAT(r.reserv_etm, '%H:%i')                                                            AS reserv_etm
                  , r.reserv_status
                  , CodeName(r.reserv_status)                                                                     AS reserv_status_nm
                  , p2.pay_id 
                  , p2.pay_method 
                  , CodeName(p2.pay_method)                                                                       AS pay_method_nm
                  , r.svc_type 
                  , CodeName(r.svc_type)                                                                          AS svc_type_nm
                  , r.svc_id
                  , (SELECT svc_nm FROM service WHERE svc_id = r.svc_id)                                          AS svc_nm
                  , (SELECT ro.option_nm FROM reserv_option ro WHERE ro.reserv_id = r.reserv_id LIMIT 1)          AS svc_option_nm
                  , (SELECT COUNT(ro2.reserv_option_id) FROM reserv_option ro2 WHERE ro2.reserv_id = r.reserv_id) AS svc_option_cnt
                  , r.reserv_memo
                  , r.tot_price
                  , r.deposit
                  , r.pay_price
                  , r.commission 
                  , IFNULL((SELECT SUM(balance) 
                       FROM prepayment p 
                      WHERE p.member_id = r.member_id
                        AND p.shop_id = r.shop_id), 0)                                                              AS tot_balance
                  , r.confirm_dt
                  , r.cancel_dt
                  , r.cancel_memo
                  , r.reserv_channel
                  , r.reg_dt
                  , r.mod_dt
               FROM reservation r
                    LEFT JOIN pet p USING (pet_id) 
                    LEFT JOIN member m        ON r.member_id = m.member_id
                    LEFT JOIN payment p2      ON r.reserv_id = p2.reserv_id
                    LEFT JOIN user_shop us    ON r.shop_id = us.shop_id AND r.user_id = us.user_id
              WHERE r.shop_id = :shop_id
                AND r.svc_type = :svc_type
                <% if (user_id)              { %>AND r.user_id = :user_id                                                                                  <% } %>
                <% if (reserv_dt) { %>
                    <% if (!reserv_edt) { %>
                AND reserv_dt = :reserv_dt
                    <% } else { %>
                AND reserv_dt >= :reserv_dt
                AND reserv_dt <= :reserv_edt
                    <% } %>
                <% } %>
                <% if (reserv_status)        { %>AND r.reserv_status IN ( :reserv_status )                                                                 <% } %>
                <% if (pay_method)           { %>AND p2.pay_method   IN ( :pay_method )                                                                    <% } %>
                <% if (sch_user_id)          { %>AND r.user_id       IN ( :sch_user_id )                                                                   <% } %>
                <% if (sch_type === 'NAME')  { %>AND r.member_id     IN ( SELECT member_id FROM member WHERE member_nm LIKE CONCAT('%', :sch_text, '%') )  <% } %>
                <% if (sch_type === 'TEL')   { %>AND m.mobile        IN ( (SELECT mobile FROM member WHERE mobile LIKE CONCAT('%', :sch_text, '%')) )      <% } %>
                <% if (sch_type === 'EMAIL') { %>AND m.email         IN ( SELECT email FROM member WHERE email LIKE CONCAT('%', :sch_text, '%') )          <% } %>
              ORDER BY @order_key :order_type
            )                                                        AS list
            , (SELECT @rownum := 0)                                  AS rownum
      ) Z
  ORDER BY Z.rownum DESC
  LIMIT :start_no, :list_size;
<% } %>

<% if ( sql_id === 'INSERT_PAYMENT_DEPOSIT' ) {%>
/**
 * SQL ID  : INSERT_PAYMENT_DEPOSIT
 * DESC.   : 선 예약금 및 결제방법 입력(기존 예약금이 있으면 삭제하고 새로 등록)
 * COMMENT :
 * HISTORY : 2021.08.10 / 쿼리 정의
 * WRITER  : tyoh
 */
DELETE FROM payment 
 WHERE shop_id = :shop_id 
   AND reserv_id = :reserv_id 
   AND pay_memo = '선예약금';

INSERT INTO payment
            (pay_id,
             reserv_id,
             svc_id,
             shop_id,
             member_id,
             order_num,
             pay_method,
             pay_amt,
             pay_dt,
             pay_memo,
             reg_dt,
             mod_dt)
VALUES      ( :pay_id,
              :reserv_id,
              :svc_id,
              :shop_id,
              :member_id,
              :order_num,
              :deposit_method,
              :deposit,
              CURRENT_TIMESTAMP,
              '선예약금',
              CURRENT_TIMESTAMP,
              CURRENT_TIMESTAMP );  
 <% } %>

<% if ( sql_id === 'SUMM_HOTEL_SERVICE_TYPE' ) { %>
/**
 * SQL ID  : SUMM_HOTEL_SERVICE_TYPE
 * DESC.   : 사용중인 샵별 호텔 객실명
 * COMMENT :
 * HISTORY : 2021.08.17 / 쿼리 정의
 * WRITER  : tyoh
 */
SELECT s.svc_id
     , s.svc_nm
  FROM service s 
       JOIN svc_category sc 
         ON s.svc_cate_id = sc.svc_cate_id 
        AND sc.svc_type = :svc_type
 WHERE s.shop_id = :shop_id
 ;
<% } %>

<% if ( sql_id === 'SUMM_HOTEL_RESERVATION_WEEK' ) { %>
/**
 * SQL ID  : SUMM_HOTEL_RESERVATION_WEEK
 * DESC.   : 객실별 호텔 예약 건수 (주별)
 * COMMENT :
 * HISTORY : 2021.08.17 / 쿼리 정의
 * WRITER  : tyoh
 */
SELECT r.reserv_dt
      , r.svc_id
      , ServiceName(r.svc_id) AS svc_nm
      , COUNT(r.reserv_id)    AS reserv_cnt
   FROM reservation r 
  WHERE shop_id = :shop_id
    AND r.reserv_dt BETWEEN :reserv_dt AND (SELECT :reserv_dt + interval 6 day)
    <% if (svc_type)      { %>AND r.svc_type = :svc_type                <% } %>
    <% if (reserv_status) { %>AND r.reserv_status IN ( :reserv_status ) <% } %>
  GROUP BY r.svc_id, r.reserv_dt
  ORDER BY r.reserv_dt;
<% } %>

<% if ( sql_id === 'SUMM_SHOP_DAYOFF' ) { %>
/**
 * SQL ID  : SUMM_SHOP_DAYOFF
 * DESC.   : 예약 캘린더용 상점 휴무일 정보
 * COMMENT :
 * HISTORY : 2021.08.19 / 쿼리 정의
 * WRITER  : tyoh
 */
SELECT stdDate.reserv_dt                                                                    AS reserv_dt
     , CONCAT('shopoff_', reserv_dt)                                                        AS dayoff_id
     , (SELECT dayoff_nm 
          FROM shop_dayoff sd
         WHERE sd.use_yn = 'Y'
           AND sd.shop_id = :shop_id
           AND sd.svc_type = :svc_type
           AND (sd.dayoff_sdt <= stdDate.reserv_dt AND sd.dayoff_edt >= stdDate.reserv_dt)) AS dayoff_nm 
  FROM (
    select std.reserv_dt as reserv_dt from (
        select :reserv_dt + INTERVAL (a.a + (10 * b.a) + (100 * c.a) + (1000 * d.a) ) DAY as reserv_dt
        from (select 0 as a union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9)           as a
            cross join (select 0 as a union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) as b
            cross join (select 0 as a union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) as c
            cross join (select 0 as a union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) as d
        ) std
    where std.reserv_dt BETWEEN :reserv_dt AND :sch_edt
    ) stdDate
 ORDER BY stdDate.reserv_dt ASC;
<% } %>

<% if ( sql_id === 'LIST_HOTEL_RESERVATION_WEEK' ) {%>
/**
 * SQL ID  : LIST_HOTEL_RESERVATION_WEEK
 * DESC.   : 고객별 호텔 예약 목록
 * COMMENT :
 * HISTORY : 2021.08.17 / 쿼리 정의
 * WRITER  : tyoh
 */
SELECT Z.*
  FROM (
         SELECT @rownum := @rownum + 1                                                                      AS rownum, list.*
           FROM (
                  SELECT r.shop_id
                       , r.svc_type
                       , CodeName(r.svc_type)                                             AS svc_type_nm
                       , r.order_num
                       , r.reserv_id
                       , (SELECT COUNT(*)
                           FROM shop_dayoff sd
                           WHERE (sd.dayoff_sdt <= r.reserv_dt AND sd.dayoff_edt >= r.reserv_dt)
                           AND sd.shop_id = r.shop_id
                           AND sd.svc_type = r.svc_type)                                  AS shop_dayoff_cnt
                       , r.reserv_dt                                                      AS reserv_dt
                       , r.reserv_edt                                                     AS reserv_edt
                       , r.reserv_status                                                  AS reserv_status
                       , CodeName(r.reserv_status)                                        AS reserv_status_nm
                       , TIME_FORMAT(r.reserv_stm, '%H:%i')                               AS reserv_stm
                       , TIME_FORMAT(r.reserv_etm, '%H:%i')                               AS reserv_etm
                       , r.member_id                                                      AS member_id
                       , MemberName(r.member_id)                                          AS member_nm
                       , CONCAT(r.svc_id, '_', r.pet_id)                                  AS reserv_key
                       , r.pet_id                                                         AS pet_id
                       , PetName(r.pet_id)                                                AS pet_nm
                       , p.breed_id                                                       AS breed_id
                       , BreedName(p.breed_id)                                            AS breed_nm
                       , r.user_id                                                        AS user_id
                       , UserName(r.user_id)                                              AS user_nm
                       , r.svc_id                                                         AS svc_id
                       , IFNULL((SELECT svc_nm FROM service WHERE svc_id = r.svc_id), '') AS svc_nm
                       , IFNULL(r.reserv_memo, "")                                        AS reserv_memo
                       , r.confirm_dt                                                     AS confirm_dt
                       , r.cancel_dt                                                      AS cancel_dt
                       , r.cancel_memo                                                    AS cancel_memo
                       , r.reserv_channel
                       , r.reg_dt
                       , r.mod_dt
                    FROM reservation r
                         LEFT JOIN pet p USING (pet_id)
                   WHERE r.shop_id = :shop_id
                     AND r.reserv_dt BETWEEN :reserv_dt AND (SELECT :reserv_dt + interval 6 day)
                     <% if (svc_type)      { %>AND r.svc_type = :svc_type                <% } %>
                     <% if (reserv_status) { %>AND r.reserv_status IN ( :reserv_status ) <% } %>
                   ORDER BY r.reserv_dt ASC
                   )                                                                     AS list
                   , (SELECT @rownum := 0)                                               AS rownum
        ) Z
 ORDER BY Z.rownum DESC;
<% } %>

<% if ( sql_id === 'INSERT_PAYMENT' ) {%>
INSERT 
    INTO payment
       ( pay_id
       , reserv_id
       , svc_id
       , shop_id
       , member_id
       , order_num
       , pay_method
       , pay_amt
       <% if (fee_amt)          { %>, fee_amt          <% } %>
       <% if (approval_num)     { %>, approval_num     <% } %>
       <% if (org_approval_num) { %>, org_approval_num <% } %>
       <% if (prepay_id)        { %>, prepay_id        <% } %>
       , pay_dt
       <% if (pay_memo)         { %>, pay_memo         <% } %>
       , reg_dt
       , mod_dt)
VALUES (:pay_id
       , :reserv_id
       , :svc_id
       , :shop_id
       , :member_id
       , :order_num
       , :pay_method
       , :pay_amt
       <% if (fee_amt)          { %>, :fee_amt          <% } %>
       <% if (approval_num)     { %>, :approval_num     <% } %>
       <% if (org_approval_num) { %>, :org_approval_num <% } %>
       <% if (prepay_id)        { %>, :prepay_id        <% } %>
       , CURRENT_TIMESTAMP
       <% if (pay_memo)         { %>, :pay_memo         <% } %>
       , CURRENT_TIMESTAMP
       , CURRENT_TIMESTAMP);  
<% } %>


<% if ( sql_id === 'INQUIRE_PORTFOLIO_CNT' ) { %>
/**
 * SQL ID  : INQUIRE_PORTFOLIO_CNT
 * DESC.   : 포트폴리오(서비스후기) 페이징용 총 데이터 개수
 * COMMENT :
 * HISTORY : 2021.08.25 / 쿼리 정의
 * WRITER  : tyoh
 */
 SELECT COUNT(*)          AS total_data
  FROM portfolio p
       JOIN reservation r USING (reserv_id)
 WHERE p.shop_id = :shop_id
   <% if (pet_id) { %>AND p.pet_id = :pet_id <% } %>
<% } %>

<% if ( sql_id === 'INQUIRE_PORTFOLIO' ) { %>
/**
 * SQL ID  : INQUIRE_PORTFOLIO
 * DESC.   : 포트폴리오(서비스후기) 조회
 * COMMENT :
 * HISTORY : 2021.08.24 / 쿼리 정의
 * WRITER  : tyoh
 */
SELECT p.port_id 
     , p.reg_dt
     , p.reserv_id 
     , r.reserv_dt
     , p.pet_id
     , PetName(p.pet_id)                 AS pet_nm
     , r.svc_type
     , CodeName(r.svc_type)              AS svc_type_nm
     , p.svc_id 
     , ServiceName(p.svc_id)             AS svc_nm
     , (
       SELECT option_nm
         FROM reserv_option ro
        WHERE ro.reserv_id = r.reserv_id
        LIMIT 1
       )                                 AS option_nm 
     , (
       SELECT COUNT(*)
         FROM reserv_option ro
        WHERE ro.reserv_id = r.reserv_id
       )                                 AS option_cnt
     , p.user_id 
     , UserName(p.user_id)               AS user_nm
     , p.port_post
  FROM portfolio p
       JOIN reservation r USING (reserv_id)
 WHERE p.shop_id = :shop_id
   <% if (pet_id) { %>AND p.pet_id = :pet_id <% } %>
 ORDER BY reserv_dt DESC
 LIMIT :start_no, :list_size
;
<% } %>

<% if ( sql_id === 'INQUIRE_PORT_ASSET' ) { %>
/**
 * SQL ID  : INQUIRE_PORT_ASSET
 * DESC.   : 포트폴리오(서비스후기) 이미지 조회
 * COMMENT :
 * HISTORY : 2021.08.24 / 쿼리 정의
 * WRITER  : tyoh
 */
SELECT GROUP_CONCAT(port_asset_id SEPARATOR ',') AS port_asset_id 
  FROM port_asset pa 
      --  JOIN asset a ON pa.port_asset_id = a.asset_id 
 WHERE pa.port_id = :port_id 
 GROUP BY port_id
<% } %>

<% if ( sql_id === 'REGISTER_PORTFOLIO' ) {%>
/**
 * SQL ID  : REGISTER_PORTFOLIO
 * DESC.   : 포트폴리오(서비스후기) 등록
 * COMMENT :
 * HISTORY : 2021.08.24 / 쿼리 정의
 * WRITER  : tyoh
 */
INSERT 
    INTO portfolio
       ( port_id
       , reserv_id
       , svc_id
       , shop_id
       , user_id
       , member_id
       , pet_id
       , port_post
       , reg_dt)
VALUES ( :port_id
       , :reserv_id
       , :svc_id
       , :shop_id
       , :user_id
       , :member_id
       , :pet_id
       , :port_post
       , CURRENT_TIMESTAMP);  
<% } %>

<% if ( sql_id === 'REGISTER_PORTFOLIO_ASSET' ) {%>
/**
 * SQL ID  : REGISTER_PORTFOLIO_ASSET
 * DESC.   : 포트폴리오(서비스후기) 이미지 등록
 * COMMENT :
 * HISTORY : 2021.08.24 / 쿼리 정의
 * WRITER  : tyoh
 */
INSERT 
    INTO port_asset
       ( port_id
       , port_asset_id
       , user_id
       , reg_dt)
VALUES ( :port_id
       , :port_asset_id
       , :user_id
       , CURRENT_TIMESTAMP);  
<% } %>

<% if ( sql_id === 'DELETE_PORTFOLIO' ) {%>
/**
 * SQL ID  : DELETE_PORTFOLIO
 * DESC.   : 포트폴리오(서비스후기) 삭제
 * COMMENT :
 * HISTORY : 2021.08.26 / 쿼리 정의
 * WRITER  : tyoh
 */
DELETE 
  FROM portfolio 
 WHERE port_id = :port_id;
<% } %>

<% if ( sql_id === 'DELETE_PORT_ASSET' ) {%>
/**
 * SQL ID  : DELETE_PORT_ASSET
 * DESC.   : 포트폴리오(서비스후기) 이미지 삭제
 * COMMENT :
 * HISTORY : 2021.08.26 / 쿼리 정의
 * WRITER  : tyoh
 */
DELETE 
  FROM port_asset
 WHERE port_id = :port_id;
<% } %>

<% if ( sql_id === 'UPDATE_PORTFOLIO' ) {%>
/**
 * SQL ID  : UPDATE_PORTFOLIO
 * DESC.   : 포트폴리오(서비스후기) 수정
 * COMMENT :
 * HISTORY : 2021.08.26 / 쿼리 정의
 * WRITER  : tyoh
 */
UPDATE portfolio
   SET reg_dt = CURRENT_TIMESTAMP
     <% if (user_id)       { %>, user_id = :user_id              <% } %>
     <% if (port_post)     { %>, port_post = :port_post          <% } %>
 WHERE port_id = :port_id
   AND shop_id = :shop_id;
<% } %>