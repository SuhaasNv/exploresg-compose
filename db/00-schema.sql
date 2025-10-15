-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- This file runs before 01-fleet-data.sql to ensure extensions are available
