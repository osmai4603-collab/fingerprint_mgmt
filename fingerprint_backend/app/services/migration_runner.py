import os
import logging
from sqlalchemy import create_engine, text, MetaData, Table, Column, String, DateTime, func
from sqlalchemy.orm import Session

logger = logging.getLogger("fingerprint_backend.migrations")


def ensure_migrations_table(engine):
    metadata = MetaData()
    table = Table(
        "_migrations", metadata,
        Column("filename", String, primary_key=True),
        Column("applied_at", DateTime, server_default=func.now()),
    )
    try:
        metadata.create_all(engine)
    except Exception:
        pass
    return table


def run_migrations(engine, migrations_dir: str, skip_init_schema: bool = False):
    if not os.path.isdir(migrations_dir):
        logger.warning("Migrations directory not found: %s", migrations_dir)
        return

    migration_table = ensure_migrations_table(engine)
    sql_files = sorted([
        f for f in os.listdir(migrations_dir)
        if f.endswith(".sql") and f != "setup_database.sh"
    ])

    if skip_init_schema:
        sql_files = [f for f in sql_files if f != "init_tables.sql"]

    if not sql_files:
        logger.info("No migration files found in %s", migrations_dir)
        return

    with Session(engine) as session:
        applied = set()
        try:
            result = session.execute(migration_table.select())
            applied = {row[0] for row in result}
        except Exception:
            session.rollback()

        for filename in sql_files:
            if filename in applied:
                logger.info("Migration already applied: %s", filename)
                continue

            filepath = os.path.join(migrations_dir, filename)
            logger.info("Applying migration: %s", filename)

            try:
                with open(filepath, "r") as f:
                    sql = f.read()

                statements = [s.strip() for s in sql.split(";") if s.strip()]
                for statement in statements:
                    if not statement:
                        continue
                    try:
                        with session.begin_nested():
                            session.execute(text(statement))
                    except Exception as e:
                        logger.warning(
                            "Statement in %s failed (may be expected): %s",
                            filename, e,
                        )

                session.execute(
                    migration_table.insert().values(filename=filename)
                )
                session.commit()
                logger.info("Migration applied: %s", filename)

            except Exception as e:
                session.rollback()
                logger.error("Migration failed: %s - %s", filename, e)
                raise
