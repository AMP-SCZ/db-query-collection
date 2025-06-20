import pandas as pd
import sqlalchemy


with open('mri_team_count/.tmp_pw2', 'r') as fp:
    pw = fp.read().strip()
    engine = sqlalchemy.create_engine(
            f'postgresql+psycopg2://pipeline:{pw}'
            '@pnl-postgres-1.partners.org:5432/ampscz_db')


with open('mri_team_count/count_query/mri_team_count.sql', 'r') as f:
    query = f.read()


with open('mri_team_count/count_query/mri_team_count_series.sql', 'r') as f:
    query_series = f.read()
# create view
create_view_query = f"""
DROP MATERIALIZED VIEW IF EXISTS mri.mri_team_count CASCADE;
CREATE MATERIALIZED VIEW mri.mri_team_count AS {query};
CREATE MATERIALIZED VIEW mri.mri_team_count_series AS {query_series};
"""

with engine.connect() as conn:
    conn.execute(sqlalchemy.text(create_view_query))
    conn.commit()


query = "SELECT * FROM mri.mri_team_count"
key_df = pd.read_sql(query, engine)
key_df.to_csv('mri_team_count.csv')

query = "SELECT * FROM mri.mri_team_count_series"
key_df = pd.read_sql(query, engine)
key_df.to_csv('mri_team_count_series.csv')
