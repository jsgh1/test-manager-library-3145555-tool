# Manager Library — API-only demonstration generator (T-21)

Run with **Node.js 18+**, no third-party packages.

## Usage

Start the Laravel API with a migrated PostgreSQL database and admin provisioned by deployment. Then supply environment variables `API_URL`, `ADMIN_USERNAME`, `ADMIN_PASSWORD`, and run `npm run seed`.

For example, in PowerShell:
- `$env:API_URL = "http://localhost:8000/api/v1"`
- `$env:ADMIN_USERNAME = "admin"`
- `$env:ADMIN_PASSWORD = Read-Host "Admin password"`
- `npm run seed`

The script creates **40 books, 10 members and 15 loans**, and queries the report/overdue API. It uses **HTTP only**, never direct SQL or privileged endpoints. Each run creates new unique demonstration identifiers. The sample categories are the five server-seeded canonical records.

## Acceptance constraint

**T-21 is only partially satisfiable as written.** It also requires three overdue loans, while the reference API creates loans from server time and assigns due time 14 days later. No endpoint exists for backdating, adjusting the clock, or creating aged demo fixtures. As recorded in the SDD adaptation, do **not** claim three overdue lines were generated or bypass the API with SQL. Instructor clarification is required for this particular acceptance item.

No secrets are embedded in this source.
