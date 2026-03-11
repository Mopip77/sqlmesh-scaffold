MODEL (
  name staging.stg_users,
  kind EMBEDDED,
  description 'Staging: 用户基础信息，1:1 映射源表'
);

SELECT
    user_id,        -- 用户ID
    username,       -- 用户名
    register_time,  -- 注册时间
    user_level      -- 用户等级: 1=普通 2=VIP 3=SVIP
FROM user_center.ods_user_info_df
WHERE
    dt = @dt
