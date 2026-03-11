MODEL (
  name marts.mart_user_order_summary,
  kind FULL,
  description '业务层: 用户消费汇总宽表，包含累计消费、订单数、最近一笔订单信息'
);

SELECT
    u.user_id,                                                -- 用户ID
    u.username,                                               -- 用户名
    u.user_level,                                             -- 用户等级
    u.register_time,                                          -- 注册时间
    COUNT(op.order_id) AS total_orders,                       -- 累计订单数
    COALESCE(SUM(op.paid_amount_fen), 0) AS total_paid_fen,   -- 累计实付金额（分）
    latest.order_id AS latest_order_id,                       -- 最近订单ID
    latest.order_status AS latest_order_status,               -- 最近订单状态
    latest.created_at AS latest_order_time                    -- 最近下单时间
FROM staging.stg_users AS u
LEFT JOIN intermediate.int_order_payment AS op
    ON u.user_id = op.user_id
LEFT JOIN intermediate.int_user_latest_order AS latest
    ON u.user_id = latest.user_id
GROUP BY
    u.user_id,
    u.username,
    u.user_level,
    u.register_time,
    latest.order_id,
    latest.order_status,
    latest.created_at
