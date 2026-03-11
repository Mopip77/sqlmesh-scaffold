MODEL (
  name staging.stg_payments,
  kind EMBEDDED,
  description 'Staging: 支付明细，仅保留支付成功的记录'
);

SELECT
    payment_id,     -- 支付流水号
    order_id,       -- 订单ID
    pay_amount,     -- 实际支付金额（元）
    pay_channel,    -- 支付渠道: alipay/wechat/card
    paid_at         -- 支付时间
FROM payment.ods_payment_detail_df
WHERE
    dt = @dt
    AND pay_status = 'success'
