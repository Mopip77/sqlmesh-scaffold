# {{ cookiecutter.project_name }}

{{ cookiecutter.description }}

本项目使用 [SQLMesh](https://sqlmesh.readthedocs.io/) 作为 SQL 编译与组装框架，**不需要连接真实数据库后端**，所有编译和测试均在本地通过内置的 DuckDB 引擎离线完成。

## 快速开始

```bash
# 安装（uv 会自动创建虚拟环境并安装所有依赖）
make install

# 离线测试（验证 SQL 逻辑是否正确）
make test

# 编译（生成子查询格式的纯 SQL）
make render model=marts.mart_user_order_summary

# 编译（生成 CTE 格式，推荐用于复制到查数平台执行）
make render-cte model=marts.mart_user_order_summary
```

> 前置依赖：需要安装 [uv](https://docs.astral.sh/uv/getting-started/installation/)（Python 包管理器）

## 项目结构

```
{{ cookiecutter.project_name }}/
├── config.yaml                              # 项目配置
├── Makefile                                 # 统一命令入口
│
├── scripts/
│   └── render_cte.py                        # CTE 格式渲染脚本
│
├── models/
│   ├── staging/                             # 基础层：1:1 映射源表，只做过滤和字段筛选
│   │   ├── user_center/                     #   ── 按数据源系统分组 ──
│   │   │   └── stg_users.sql                #   用户基础信息
│   │   ├── trade/
│   │   │   └── stg_orders.sql               #   订单信息
│   │   └── payment/
│   │       └── stg_payments.sql             #   支付明细
│   │
│   ├── intermediate/                        # 中间层：聚合、窗口函数、多表关联
│   │   └── ecommerce/                       #   ── 按业务域分组 ──
│   │       ├── int_order_payment.sql        #   订单支付汇总（元转分）
│   │       └── int_user_latest_order.sql    #   每个用户最近一笔订单
│   │
│   └── marts/                               # 业务层：最终输出的宽表
│       └── ecommerce/
│           └── mart_user_order_summary.sql  #   用户消费汇总宽表
│
├── macros/                                  # 可复用的 SQL 宏（Python 实现）
│   └── __init__.py                          #   元转分宏 yuan_to_fen
│
├── tests/                                   # 单元测试
│   └── test_int_order_payment.yaml          #   订单支付汇总测试
│
└── README.md
```

## 分层设计原则

| 层级 | 目录 | 二级分组依据 | 职责 | 文件前缀 | Model Kind |
|------|------|-------------|------|---------|------------|
| Staging | `models/staging/` | 数据源系统 | 1:1 映射源表，只做 WHERE 过滤、字段筛选、字段重命名 | `stg_` | EMBEDDED |
| Intermediate | `models/intermediate/` | 业务域 | 处理复杂逻辑：聚合、窗口函数、多表 JOIN | `int_` | EMBEDDED |
| Marts | `models/marts/` | 业务域 | 组装最终宽表，直接供报表/分析消费 | `mart_` | FULL |

**为什么 Staging 按数据源分，Marts 按业务域分？**

- Staging 层关心的是"数据从哪来"——当上游源表变更时，能快速定位到受影响的文件
- Marts 层关心的是"数据给谁用"——按业务域组织方便业务方找到自己需要的表

**为什么 Staging/Intermediate 用 EMBEDDED？**

本项目的使用场景是**编译生成最终 SQL 语句**，不直连真实数据引擎。EMBEDDED 模型不会在数据库中创建任何对象（视图或表），render 时自动将 SQL 内联展开到下游查询中，确保编译输出的是一条完整的、可直接执行的 SQL。

## 核心配置说明

`config.yaml` 中的关键配置：

```yaml
model_defaults:
  dialect: {{ cookiecutter.sql_dialect }}    # SQL 方言

variables:
  dt: '{{ cookiecutter.dt }}'               # 全局日期变量，SQL 中用 @dt 引用
```

- **dialect** — 你正常写对应方言的 SQL，SQLMesh 在本地测试时自动翻译为 DuckDB 能执行的语法
- **variables** — 在 SQL 中用 `@dt` 引用，编译时自动替换为实际值

## SQL 宏

本项目包含一个示例宏 `yuan_to_fen`，定义在 `macros/__init__.py`：

```python
from sqlmesh import macro

@macro()
def yuan_to_fen(evaluator, col):
    return f"CAST(COALESCE({col}, 0) * 100 AS BIGINT)"
```

在 SQL 中使用：

```sql
-- 使用前
CAST(COALESCE(pay_amount, 0) * 100 AS BIGINT) AS pay_amount_fen

-- 使用后
@yuan_to_fen(pay_amount) AS pay_amount_fen
```

当你发现多个 SQL 文件中有重复的 SQL 片段时，可以在 `macros/__init__.py` 中用 `@macro()` 装饰器定义新的 Python 宏来复用。

## 常用命令

### `make test` — 离线单元测试

```bash
make test
```

在本地 DuckDB 中运行 `tests/` 目录下的所有测试用例。工作原理：读取 YAML 中定义的假数据（inputs），灌入对应的模型 SQL 执行，将实际输出与预期输出（outputs）逐行比对。

### `make render` — 编译输出纯 SQL（子查询格式）

```bash
make render model=marts.mart_user_order_summary   # 编译最终宽表
make render model=intermediate.int_order_payment   # 编译某个中间模块（用于 debug）
```

### `make render-cte` — 编译输出纯 SQL（CTE 格式，推荐）

```bash
make render-cte model=marts.mart_user_order_summary
```

输出 `WITH ... AS` 的 CTE 格式 SQL。**日常用法：** 复制输出的 SQL，粘贴到查数平台执行。

### `make dag` — 生成依赖关系图

```bash
make dag
```

生成 `dag.html`，用浏览器打开可以看到所有模型的依赖关系（DAG）。

## Debug 流程

### 1. 逻辑验证（离线完成）

编写单元测试，用假数据验证 SQL 逻辑：

```yaml
# tests/test_int_order_payment.yaml
test_order_payment_aggregation:
  model: intermediate.int_order_payment
  inputs:
    staging.stg_orders:
      - order_id: "ORD_001"
        user_id: "U001"
        order_amount: 99.90
        ...
  outputs:
    query:
      rows:
        - order_id: "ORD_001"
          order_amount_fen: 9990        # 99.90 元 = 9990 分
          ...
```

运行 `make test`，如果实际输出与预期不符，终端直接报错并显示差异。

### 2. 数据排查（配合查数平台）

当线上数据异常时，不需要在大 SQL 中大海捞针：

```bash
# 只编译你怀疑有问题的那个中间模块
make render-cte model=intermediate.int_order_payment
```

复制输出的 SQL 到查数平台执行，查看中间结果是否符合预期。逐层排查，快速定位问题出在哪一层。

## 如何添加新的业务表

1. 在 `models/staging/` 下对应的数据源目录中添加基础模型（`stg_` 前缀，`EMBEDDED`）
2. 在 `models/intermediate/<业务域>/` 中添加中间层处理逻辑（`int_` 前缀，`EMBEDDED`）
3. 在 `models/marts/<业务域>/` 中添加最终输出模型（`mart_` 前缀，`FULL`）
4. 在 `tests/` 中添加单元测试
5. 运行 `make test` 验证，`make render-cte` 编译
