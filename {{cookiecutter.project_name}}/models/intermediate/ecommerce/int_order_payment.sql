MODEL (
  name intermediate.int_order_payment,
  kind EMBEDDED,
  description '中间层: 订单维度的支付汇总，金额从元转换为分'
);

SELECT
    o.order_id,                             -- 订单ID
    o.user_id,                              -- 用户ID
    o.order_status,                         -- 订单状态
    o.created_at,                           -- 下单时间
    @yuan_to_fen(o.order_amount) AS order_amount_fen,  -- 订单金额（分）
    @yuan_to_fen(SUM(p.pay_amount)) AS paid_amount_fen -- 实付金额（分）
FROM staging.stg_orders AS o
LEFT JOIN staging.stg_payments AS p
    ON o.order_id = p.order_id
GROUP BY
    o.order_id,
    o.user_id,
    o.order_amount,
    o.order_status,
    o.created_at
