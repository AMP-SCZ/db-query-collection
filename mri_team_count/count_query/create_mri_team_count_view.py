import sqlalchemy


with open('.tmp_pw2', 'r') as fp:
    pw = fp.read().strip()
    engine = sqlalchemy.create_engine(
            f'postgresql+psycopg2://pipeline:{pw}'
            '@pnl-postgres-1.partners.org:5432/ampscz_db')


with open('mri_team_count.sql', 'r') as f:
    query = f.read()

# create view
create_view_query = f"""
DROP VIEW IF EXISTS mri.mri_team_count;
CREATE VIEW mri.mri_team_count AS {query};
"""

with engine.connect() as conn:
    conn.execute(sqlalchemy.text(create_view_query))
    conn.commit()
