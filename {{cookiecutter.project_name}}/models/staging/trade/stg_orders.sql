MODEL (
  name staging.stg_orders,
  kind EMBEDDED,
  description 'Staging: 订单信息，过滤已删除订单'
);

SELECT
    order_id,       -- 订单ID
    user_id,        -- 用户ID
    order_amount,   -- 订单金额（元）
    order_status,   -- 订单状态: 1=待付款 2=已付款 3=已发货 4=已完成 5=已取消
    created_at      -- 下单时间
FROM trade.ods_order_df
WHERE
    dt = @dt
    AND is_deleted = 0
