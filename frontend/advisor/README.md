# Architecture Advisor Frontend

This directory contains the browser-based frontend for the AWS Architecture Advisor service.

The frontend collects structured workload requirements, submits them to the Advisor API, and renders the resulting AWS architecture recommendation, including recommended services, architecture design guidance, Well-Architected considerations, tradeoffs, and next steps.

## Runtime Configuration

The frontend reads the Advisor API endpoint from `config.js`:

```javascript
window.ADVISOR_CONFIG = {
  apiUrl: "http://localhost:8002",
};
```

`config.js` is intentionally excluded from Git because the API endpoint is environment-specific.

A tracked `config.example.js` file documents the required configuration structure. For local development, create the runtime configuration with:

```bash
cp frontend/advisor/config.example.js frontend/advisor/config.js
```

Then update `frontend/advisor/config.js` to use the local Advisor API:

```javascript
window.ADVISOR_CONFIG = {
  apiUrl: "http://localhost:8002",
};
```

Do not put environment-specific API URLs directly in `app.js`.

For deployed environments, `config.js` should be generated with the Advisor URL for that environment. Terraform already exposes service URLs through the environment-level `service_urls` output.

## Running Locally

The Advisor API can be run locally in Docker on port `8002`. From the repository root:

```bash
docker build \
  -t aws-container-platform-advisor:local \
  services/advisor

docker run --rm \
  --name aws-container-platform-advisor-local \
  -p 8002:8000 \
  aws-container-platform-advisor:local
```

In a separate terminal, serve the frontend from the repository root:

```bash
python -m http.server 8080 --directory frontend/advisor
```

Then open `http://localhost:8080` in a browser.

The local Advisor API allows requests from this origin through its CORS configuration.