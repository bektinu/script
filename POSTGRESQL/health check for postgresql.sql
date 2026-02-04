POSTGRESQL SQL HUB

Database health monitoring solution with 60+ queries across 16 sections in 2,515 lines of code.

Here's what's inside:
━━━━━━━━━━━━━━━━━━━━━━━━
SECTION 1: Database Metadata (1 query)
→ Environment info, version, uptime, size, connections

SECTION 2: Critical Alerts (6 queries)
→ Bloat >30%
→ Never analyzed tables
→ Stale stats >20%
→ Foreign keys without indexes
→ XID wraparound risk (DB + table level)

SECTION 3: Connection Pool (5 queries)
→ Pool utilization status
→ Connection states breakdown
→ Idle connections >5 min
→ Aborted transactions
→ Long-running transactions holding locks

SECTION 4: Lock Contention (2 queries)
→ Blocking locks detection
→ Lock types summary

SECTION 5: Query Performance (5 queries)
→ pg_stat_statements status
→ Slow queries >100ms
→ Active long queries
→ Prepared statement leaks

SECTION 5B: Wait Events (5 queries)
→ Wait events summary
→ Bottleneck breakdown
→ I/O timing analysis

SECTION 6: Buffer Cache (2 queries)
→ Overall cache hit ratio
→ Per-table cache (worst performers)

SECTION 7: Table Bloat (1 query)
→ Most bloated tables with dead tuple %

SECTION 8: Vacuum Health (4 queries)
→ Vacuum health score
→ Active maintenance ops
→ Hot tables overwhelming autovacuum

SECTION 9: Index Health (7 queries)
→ Unused indexes
→ Low-usage indexes
→ Tables needing indexes
→ Seq vs Index scan analysis
→ Index efficiency (scan vs return ratio)
→ Duplicate indexes detection

SECTION 9B: Partitioning (4 queries)
→ Partition summary
→ Size imbalance detection
→ Missing partition indexes

SECTION 10: Disk Usage (2 queries)
→ Largest tables
→ JSONB columns missing GIN indexes

SECTION 11: Replication Health (4 queries)
→ Replication status & lag
→ Replication slots
→ WAL archive status

SECTION 12: Transaction Stats (1 query)
→ Commit/rollback/deadlock rates

SECTION 13: Checkpoint Stats (1 query)
→ Checkpoint & background writer metrics

SECTION 14: Database Summary (1 query)
→ Overall health rollup

SECTION 15: Recommended Actions (1 query)
→ Priority-based P1-P4 fix commands

SECTION 16: Security Audit (7 queries)
→ Superuser accounts
→ Excessive privileges
→ Public schema grants
→ Password policy violations
→ Unused roles
→ SSL connection status
━━━━━━━━━━━━━━━━━━━━━━━━
4 Convenience Views
• health_summary → Executive overview
• health_critical → Action items only
• health_score → Single 0-100 score
• health_alerts → JSON output for monitoring

2 Helper Functions
• health_report_version() → Version tracking
• has_critical_alerts() → Quick check for scripts
━━━━━━━━━━━━━━━━━━━━━━━━

Usage:
SELECT * FROM run_health_report();
SELECT * FROM health_score;

━━━━━━━━━━━━━━━━━━━━━━━━
$29 - Price

✓ Complete SQL function (ready to deploy)
✓ Works with PostgreSQL 12+
✓ Free updates
✓ No subscriptions. No dependencies.
