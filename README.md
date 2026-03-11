# SQLMesh Scaffold

一个用于快速创建 SQLMesh SQL 工程化项目的 Cookiecutter 模板。

## 特性

- 📐 **三层分层架构**: Staging → Intermediate → Marts 标准分层
- 🧪 **离线测试**: 基于 DuckDB 的本地单元测试，不连接真实数据库
- 🔧 **SQL 宏复用**: 内置 `yuan_to_fen` 宏示例，消除重复 SQL
- 📦 **编译输出**: 生成可直接在查数平台执行的纯 SQL（CTE 格式）
- 🗺️ **DAG 可视化**: 一键生成模型依赖关系图

## 快速使用

### 1. 安装 Cookiecutter

```bash
pip install cookiecutter
```

### 2. 创建新项目

```bash
# 使用本地模板
cookiecutter ./sqlmesh-scaffold

# 或使用 Git 仓库
# cookiecutter https://github.com/your-org/sqlmesh-scaffold
```

### 3. 按提示配置项目

```
project_name [my-sqlmesh-project]: order-analysis
description [SQL 工程化项目]: 订单分析项目
sql_dialect [presto]: presto
dt [2026-01-01]: 2026-03-11
```

### 4. 进入项目

```bash
cd order-analysis
make install
make test        # 运行单元测试
make render-cte model=marts.mart_user_order_summary  # 编译输出 SQL
```

## 生成的项目结构

```
your-project/
├── config.yaml                          # SQLMesh 配置
├── pyproject.toml                       # Python 依赖
├── Makefile                             # 统一命令入口
├── models/
│   ├── staging/                         # 基础层：1:1 映射源表
│   │   ├── user_center/
│   │   │   └── stg_users.sql
│   │   ├── trade/
│   │   │   └── stg_orders.sql
│   │   └── payment/
│   │       └── stg_payments.sql
│   ├── intermediate/                    # 中间层：聚合、窗口函数
│   │   └── ecommerce/
│   │       ├── int_order_payment.sql
│   │       └── int_user_latest_order.sql
│   └── marts/                           # 业务层：最终宽表输出
│       └── ecommerce/
│           └── mart_user_order_summary.sql
├── macros/                              # Python 宏
│   └── __init__.py                      #   yuan_to_fen 元转分宏
├── scripts/
│   └── render_cte.py                    # CTE 格式渲染脚本
├── tests/
│   └── test_int_order_payment.yaml      # 单元测试
└── README.md                            # 项目使用文档
```

## 许可证

MIT License
