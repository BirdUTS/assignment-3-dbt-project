# Assignment 3: dbt Cloud Project

## 📊 Project Overview
This dbt project implements a complete ELT pipeline for Airbnb and Census data analysis following the Medallion Architecture (Bronze, Silver, Gold).

## 🏗️ Architecture

### **Bronze Layer**
- Raw data loaded by Airflow
- Source definitions in `models/bronze/sources.yml`

### **Silver Layer**
- Cleaned and standardized data
- Models: `silver_listings`, `silver_census_g01`, `silver_census_g02`, `silver_lga`
- Snapshots for SCD Type 2 tracking

### **Gold Layer**
**Dimensions (SCD2):**
- `dim_host` - Host information with historical tracking
- `dim_property` - Property characteristics with historical tracking
- `dim_suburb` - Suburb and LGA mapping
- `dim_lga` - Local Government Areas
- `dim_date` - Date dimension (May 2020 - April 2021)
- `dim_census_g01` - Census demographics (reference)
- `dim_census_g02` - Census economics (reference)

**Facts:**
- `fact_listings` - Airbnb listings with metrics (price, availability, revenue)

### **Datamart Layer**
Three business-focused views:
1. `dm_listing_neighbourhood` - Insights by neighbourhood and month
2. `dm_property_type` - Insights by property type, room type, accommodates
3. `dm_host_neighbourhood` - Revenue analysis by host LGA

## 📁 Project Structure
```
dbt_project/
├── dbt_project.yml          # Main configuration
├── packages.yml              # dbt packages (dbt_utils)
├── models/
│   ├── bronze/               # Source definitions
│   ├── silver/               # Cleaned data models
│   ├── gold/
│   │   ├── dimensions/       # Dimension tables
│   │   └── facts/            # Fact tables
│   └── datamart/             # Business views
├── snapshots/                # SCD2 snapshot configs
├── tests/                    # Data quality tests
└── macros/                   # Reusable SQL functions
```

## 🚀 Setup Instructions

### 1. **dbt Cloud Setup**
1. Create new project in dbt Cloud
2. Connect to PostgreSQL database
3. Link to GitHub repository
4. Install dependencies: `dbt deps`

### 2. **Run Models**
```bash
# Run all models
dbt run

# Run snapshots first (for SCD2)
dbt snapshot

# Run models with snapshots
dbt run

# Run specific layers
dbt run --select silver
dbt run --select gold
dbt run --select datamart
```

### 3. **Test Data Quality**
```bash
dbt test
```

## 📊 Key Metrics

### Datamart Metrics:
- **Active Listings Rate**: % of listings with availability
- **Superhost Rate**: % of superhosts
- **Estimated Revenue**: number_of_stays * price
- **Number of Stays**: 30 - availability_30
- **Percentage Changes**: Month-over-month comparisons

## 🔑 Important Notes

1. **SCD2 Implementation**: 
   - Snapshots track historical changes using `scraped_date`
   - Fact table joins use `valid_from`/`valid_to` for time-travel queries

2. **Data Quality**:
   - All prices cleaned and converted to DECIMAL
   - Null handling for review scores
   - Standardized text fields (TRIM, INITCAP)

3. **Performance**:
   - Silver/Gold layers materialized as TABLES
   - Datamart as VIEWS for real-time querying

## 📝 Assignment Compliance

✅ Medallion Architecture (Bronze, Silver, Gold)  
✅ SCD Type 2 with timestamp strategy  
✅ Star schema with dimensions and facts  
✅ 3 datamart views as specified  
✅ All metrics calculated correctly  

## 🎯 Next Steps

1. Load remaining months via Airflow (Part 3)
2. Trigger dbt runs after each month
3. Perform ad-hoc analysis (Part 4)
4. Document findings in report

---

**Author**: [Your Name]  
**Assignment**: Big Data Engineering - Assignment 3  
**Institution**: UTS

