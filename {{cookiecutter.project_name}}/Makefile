.PHONY: render render-cte test dag install

# 安装依赖
install:
	@uv sync

# SQL 校验（字段引用、SELECT * 等）
lint:
	@uv run sqlmesh lint

# 默认渲染（子查询格式）
# 用法: make render model=marts.mart_user_order_summary
render: lint
	@uv run sqlmesh render $(model)

# CTE 格式渲染（推荐，可直接复制到查数平台执行）
# 用法: make render-cte model=marts.mart_user_order_summary
render-cte: lint
	@uv run python scripts/render_cte.py $(model)

# 运行单元测试
test:
	@uv run sqlmesh test

# 生成依赖关系图
dag:
	@uv run sqlmesh dag dag.html
