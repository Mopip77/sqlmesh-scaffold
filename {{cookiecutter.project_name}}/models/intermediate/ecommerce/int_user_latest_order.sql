MODEL (
  name intermediate.int_user_latest_order,
  kind EMBEDDED,
  description '中间层: 每个用户最近一笔订单（按下单时间倒序取第一条）'
);

SELECT
    user_id,       -- 用户ID
    order_id,      -- 最近订单ID
    order_status,  -- 最近订单状态
    created_at     -- 最近下单时间
FROM (
    SELECT
        user_id,
        order_id,
        order_status,
        created_at,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at DESC) AS rn
    FROM staging.stg_orders
) t
WHERE rn = 1
