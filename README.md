# Financial KPI Dashboard — Market Fundamentals Analysis

End-to-end analytics project: **SQL-style analytical queries**, **Python (Pandas + Matplotlib)** for cleaning, EDA, and KPI logic (including a **weighted Performance Index**), and a **Power BI** layer for interactive reporting. Structured for GitHub and recruiter review: clear story, reproducible steps, and business-facing insights.

## Business problem

Organizations often struggle to:

- Track **revenue growth** and momentum (MoM / YoY) with confidence.
- See **which segments** truly drive results versus dilute margin.
- Balance **growth vs profitability** across regions and categories.

## Solution

- **Data pipeline**: Raw synthetic sales data → documented cleaning → analysis-ready dataset.
- **Analysis**: KPIs, segment contribution, concentration (HHI-style), region profitability, composite **Performance Index Score** (40% normalized revenue growth, 30% normalized margin, 30% normalized volume—by region).
- **Visualization**: Matplotlib charts in Jupyter (exportable to `images/`); Power BI dashboard instructions for interactive filters and executive views.
- **SQL**: Reusable patterns for aggregation, top segments, and monthly growth (`sql/queries.sql`).

## Repository layout

```
Financial-KPI-Dashboard/
├── data/
│   ├── raw_data.csv
│   └── cleaned_data.csv
├── notebooks/
│   ├── data_cleaning.ipynb
│   ├── eda_analysis.ipynb
│   └── kpi_analysis.ipynb
├── dashboard/
│   └── README.md          # Build powerbi.pbix locally (see below)
├── sql/
│   └── queries.sql
├── scripts/
│   └── generate_raw_data.py
├── images/                # KPI figures (generated; see How to run)
└── README.md
```

## Key insights (examples — re-run notebooks for your numbers)

After running the notebooks on the bundled data, you can narrate findings such as:

- **Concentration**: A subset of categories accounts for a large share of revenue (see contribution % and HHI in `kpi_analysis.ipynb`).
- **Trade-offs**: A region can show strong revenue growth but weaker margin—candidates for pricing or mix improvements.
- **Performance Index**: Top regions by composite score vs bottom segments by margin highlight where to investigate costs or discounting.

Replace these bullets with your actual printed outputs when presenting to employers.

## Tools used

| Area        | Stack |
|------------|--------|
| Data prep  | Python, Pandas |
| EDA / KPIs | Jupyter, Matplotlib (no Seaborn) |
| SQL        | Analytical queries in `sql/queries.sql` |
| BI         | Power BI Desktop (see `dashboard/README.md`) |
| Optional   | Excel for ad-hoc checks |

## Dashboard preview

Place exported screenshots here (or run `kpi_analysis.ipynb` to generate matplotlib assets):

- `images/dashboard_preview.png` — composite layout from the notebook.
- `images/kpi_trends.png` — revenue trend.
- `images/performance_top5_regions.png` — top regions by Performance Index.

Build the interactive **Power BI** file as `dashboard/powerbi.pbix` following `dashboard/README.md`; binary files are created on your machine, not by this repository.

## How to run

1. **Environment**

   ```bash
   cd Financial-KPI-Dashboard
   pip install -r requirements.txt
   ```

2. **(Optional) Regenerate raw data** — produces 15,000+ rows (default 16,220):

   ```bash
   python scripts/generate_raw_data.py
   ```

   To write elsewhere (e.g. test run without overwriting `data/raw_data.csv`):

   ```bash
   python scripts/generate_raw_data.py --output ./data/raw_regenerated.csv
   ```

3. **Clean data** — open and run `notebooks/data_cleaning.ipynb` (writes `data/cleaned_data.csv`).

4. **EDA** — run `notebooks/eda_analysis.ipynb` (correlation heatmap, trends, segment bars).

5. **KPIs & Performance Index** — run `notebooks/kpi_analysis.ipynb` (saves figures under `images/`).

6. **Power BI** — import `data/cleaned_data.csv` per `dashboard/README.md`.

7. **SQL** — load `cleaned_data` into your database as table `cleaned_sales` (column names must match), then run `sql/queries.sql` (adjust date functions for your dialect; comments note SQLite/SQL Server variants).

## KPIs implemented

**Core:** Total Revenue, Profit Margin %, MoM / YoY growth (monthly series), Average Order Value (revenue per transaction row).

**Advanced:** CLV-style proxy by segment, segment contribution %, revenue concentration index (category HHI), profitability by region.

**Composite:** Performance Index Score — weighted combination of min–max normalized revenue growth, profit margin, and sales volume (by region); surfaces top 5 regions and weakest segments by margin.

## License

Use freely for portfolio and learning; synthetic data is for demonstration only.
