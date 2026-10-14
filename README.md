# Manager Library — API-only demonstration generator (T-21)

Run with **Node.js 18+**, no third-party packages.

## Windows PowerShell with the running Docker stack (recommended)

From the cloned `test-manager-library-3145555-tool` folder, run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\\Iniciar-Semillero.ps1"
```

This helper reads `../test-manager-library-3145555-infra/.env`, copies `seed.mjs` into the **already running** React/Node container, and calls the Laravel HTTP API at `http://api:8000/api/v1`. It needs no Node installation on the Windows host and does **not** write directly to PostgreSQL. The Docker stack must already be running. Do not paste or commit the local `.env`.

**Expected:** 40 new books, 10 members, 15 loans. Due to the documented API date conflict, the three overdue fixtures cannot be generated legitimately in the assessment time window.

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
