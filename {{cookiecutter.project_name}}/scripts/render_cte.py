"""Render a sqlmesh model as CTE format (WITH ... AS).

Usage:
    python scripts/render_cte.py <model_name> [--dialect <dialect>]

Examples:
    python scripts/render_cte.py marts.mart_user_order_summary
    python scripts/render_cte.py marts.mart_user_order_summary --dialect duckdb
"""

import argparse
import sys
import warnings

warnings.filterwarnings("ignore", category=DeprecationWarning)

from sqlmesh import Context
from sqlglot.optimizer.eliminate_subqueries import eliminate_subqueries


def main():
    parser = argparse.ArgumentParser(description="Render a sqlmesh model with CTE output format")
    parser.add_argument("model", help="Model name (e.g. marts.mart_user_order_summary)")
    parser.add_argument("--dialect", default="{{ cookiecutter.sql_dialect }}", help="SQL dialect (default: {{ cookiecutter.sql_dialect }})")
    args = parser.parse_args()

    ctx = Context(paths=["."])
    rendered = ctx.render(args.model, expand=True)
    result = eliminate_subqueries(rendered)
    print(result.sql(pretty=True, dialect=args.dialect))


if __name__ == "__main__":
    main()
