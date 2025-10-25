#!/bin/bash
# Commands to push your dbt project to GitHub

cd "/Users/waiwingtang/Library/CloudStorage/OneDrive-VolTra/VolTra Doc (Bird)/Personal/Migration/UTS Data Science/Big Data Engineering/Assignment/AT3/dbt_project"

# Initialize git repository
git init

# Add all files
git add .

# Commit with message
git commit -m "Initial dbt project setup for Assignment 3 - Complete medallion architecture with SCD2"

# Connect to your GitHub repo
git remote add origin https://github.com/BirdUTS/assignment-3-dbt-project.git

# Push to main branch
git branch -M main
git push -u origin main

echo "✅ Done! Your dbt project is now on GitHub!"

