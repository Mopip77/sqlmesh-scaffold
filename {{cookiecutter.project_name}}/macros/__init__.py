from sqlmesh import macro


@macro()
def yuan_to_fen(evaluator, col):
    """Convert amount from yuan to fen (x100), with NULL handling.

    Usage in SQL:
        @yuan_to_fen(pay_amount)

    Renders to:
        CAST(COALESCE(pay_amount, 0) * 100 AS BIGINT)
    """
    return f"CAST(COALESCE({col}, 0) * 100 AS BIGINT)"
