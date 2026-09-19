"""Build a fresh synthetic SQLite database and export the SQL query results."""
import argparse
import csv
from pathlib import Path
import sqlite3

ROOT = Path(__file__).resolve().parent


def build_database():
    db = sqlite3.connect(':memory:')
    db.row_factory = sqlite3.Row
    db.executescript((ROOT / 'sql/schema.sql').read_text())
    db.executescript((ROOT / 'sql/seed.sql').read_text())
    return db


def query(db, name):
    return [dict(row) for row in db.execute((ROOT / 'sql/queries' / f'{name}.sql').read_text())]


def validate(db):
    if db.execute('PRAGMA foreign_key_check').fetchall():
        raise ValueError('Foreign key violations')
    failures = [row for row in query(db, 'data_quality') if row['violations']]
    if failures:
        raise ValueError(f'Data quality checks failed: {failures}')


def run(output):
    output = Path(output)
    db = build_database()
    try:
        validate(db)
        output.mkdir(parents=True, exist_ok=True)
        for path in sorted((ROOT / 'sql/queries').glob('*.sql')):
            rows = query(db, path.stem)
            with (output / f'{path.stem}.csv').open('w', newline='') as handle:
                writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
                writer.writeheader()
                writer.writerows(rows)
        with sqlite3.connect(output / 'sports.sqlite') as destination:
            db.backup(destination)
    finally:
        db.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=Path('build'))
    args = parser.parse_args()
    run(args.output)
    print(f'Validated synthetic dataset; exported CSV reports and SQLite database to {args.output}')
