#!/bin/bash
# Deploy 42 LaunchPad components to GCP.
#
# Usage:
#   ./scripts/deploy.sh              # Deploy all (backend + frontend)
#   ./scripts/deploy.sh backend      # Deploy backend only (Cloud Run)
#   ./scripts/deploy.sh frontend     # Deploy frontend only (Firebase Hosting)
#   ./scripts/deploy.sh all          # Deploy all
#
# Requirements:
#   - gcloud CLI authenticated and configured
#   - firebase CLI authenticated
#   - npm installed (for frontend build)
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

PROJECT_ID="launchpad42-prod"
REGION="europe-west1"
SERVICE_NAME="launchpad-api"
MEMORY="256Mi"
CPU="1"
MIN_INSTANCES="0"
MAX_INSTANCES="1"

# Resolve project root relative to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ---------------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; }

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------

preflight_check() {
    info "Running pre-flight checks..."

    if ! command -v gcloud &>/dev/null; then
        error "gcloud CLI not found. Install: https://cloud.google.com/sdk/docs/install"
        exit 1
    fi

    if ! command -v firebase &>/dev/null; then
        error "firebase CLI not found. Install: npm install -g firebase-tools"
        exit 1
    fi

    if ! command -v npm &>/dev/null; then
        error "npm not found. Install Node.js: https://nodejs.org"
        exit 1
    fi

    # Verify gcloud project
    local current_project
    current_project="$(gcloud config get-value project 2>/dev/null)"
    if [ "$current_project" != "$PROJECT_ID" ]; then
        warn "gcloud project is '$current_project', expected '$PROJECT_ID'"
        info "Switching to $PROJECT_ID..."
        gcloud config set project "$PROJECT_ID"
    fi

    success "Pre-flight checks passed"
}

# ---------------------------------------------------------------------------
# Backend deployment (Cloud Run)
# ---------------------------------------------------------------------------

deploy_backend() {
    info "============================================================"
    info "Deploying backend to Cloud Run..."
    info "============================================================"

    local start_time
    start_time=$(date +%s)

    cd "$PROJECT_ROOT"

    info "Building and deploying $SERVICE_NAME from backend/..."
    gcloud run deploy "$SERVICE_NAME" \
        --source backend/ \
        --region "$REGION" \
        --memory "$MEMORY" \
        --cpu "$CPU" \
        --min-instances "$MIN_INSTANCES" \
        --max-instances "$MAX_INSTANCES" \
        --allow-unauthenticated \
        --set-env-vars "ENVIRONMENT=production,PROJECT_ID=$PROJECT_ID"

    # Get the service URL
    local service_url
    service_url="$(gcloud run services describe "$SERVICE_NAME" \
        --region "$REGION" \
        --format='value(status.url)' 2>/dev/null)"

    if [ -z "$service_url" ]; then
        error "Could not retrieve Cloud Run service URL"
        return 1
    fi

    info "Service URL: $service_url"

    # Health check with retries (cold start can take 5-10s)
    info "Running health check (waiting for cold start)..."
    local max_retries=5
    local retry=0
    local health_ok=false

    while [ $retry -lt $max_retries ]; do
        if curl -sf --max-time 15 "${service_url}/health" >/dev/null 2>&1; then
            health_ok=true
            break
        fi
        retry=$((retry + 1))
        info "Health check attempt $retry/$max_retries failed, retrying in 5s..."
        sleep 5
    done

    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))

    if [ "$health_ok" = true ]; then
        success "Backend deployed successfully (${duration}s)"
        success "Health endpoint: ${service_url}/health"
    else
        error "Backend deployed but health check failed after $max_retries attempts"
        warn "Service URL: ${service_url}/health"
        warn "The service may still be starting up. Check logs:"
        warn "  gcloud run services logs read $SERVICE_NAME --region $REGION"
        return 1
    fi

    echo "$service_url"
}

# ---------------------------------------------------------------------------
# Frontend deployment (Firebase Hosting)
# ---------------------------------------------------------------------------

deploy_frontend() {
    info "============================================================"
    info "Deploying frontend to Firebase Hosting..."
    info "============================================================"

    local start_time
    start_time=$(date +%s)

    cd "$PROJECT_ROOT/frontend"

    # Install dependencies
    info "Installing npm dependencies..."
    npm ci --silent

    # Build
    info "Building React SPA..."
    npm run build

    # Verify build output exists
    if [ ! -d "dist" ]; then
        error "Build failed: frontend/dist/ directory not found"
        return 1
    fi

    local dist_size
    dist_size="$(du -sh dist 2>/dev/null | cut -f1)"
    info "Build output size: $dist_size"

    # Deploy to Firebase Hosting
    cd "$PROJECT_ROOT"
    info "Deploying to Firebase Hosting..."
    firebase deploy --only hosting

    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # Get hosting URL
    local hosting_url="https://${PROJECT_ID}.web.app"

    success "Frontend deployed successfully (${duration}s)"
    success "Hosting URL: $hosting_url"

    echo "$hosting_url"
}

# ---------------------------------------------------------------------------
# Deploy all
# ---------------------------------------------------------------------------

deploy_all() {
    info "============================================================"
    info "  42 LaunchPad — Full Deployment"
    info "  Project: $PROJECT_ID"
    info "  Region:  $REGION"
    info "============================================================"
    echo

    local total_start
    total_start=$(date +%s)

    local backend_url=""
    local frontend_url=""
    local backend_ok=true
    local frontend_ok=true

    # Deploy backend first
    backend_url="$(deploy_backend)" || backend_ok=false
    echo

    # Deploy frontend
    frontend_url="$(deploy_frontend)" || frontend_ok=false
    echo

    local total_end
    total_end=$(date +%s)
    local total_duration=$((total_end - total_start))

    # Summary
    info "============================================================"
    info "  DEPLOYMENT SUMMARY"
    info "============================================================"

    if [ "$backend_ok" = true ]; then
        success "Backend:  $backend_url"
    else
        error "Backend:  FAILED"
    fi

    if [ "$frontend_ok" = true ]; then
        success "Frontend: $frontend_url"
    else
        error "Frontend: FAILED"
    fi

    info "Total time: ${total_duration}s"
    info "============================================================"

    if [ "$backend_ok" = false ] || [ "$frontend_ok" = false ]; then
        return 1
    fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
    local target="${1:-all}"

    case "$target" in
        backend)
            preflight_check
            deploy_backend
            ;;
        frontend)
            preflight_check
            deploy_frontend
            ;;
        all)
            preflight_check
            deploy_all
            ;;
        -h|--help)
            echo "Usage: $0 [backend|frontend|all]"
            echo ""
            echo "Deploy 42 LaunchPad components to GCP."
            echo ""
            echo "  backend   Deploy FastAPI backend to Cloud Run"
            echo "  frontend  Deploy React SPA to Firebase Hosting"
            echo "  all       Deploy everything (default)"
            exit 0
            ;;
        *)
            error "Unknown target: $target"
            echo "Usage: $0 [backend|frontend|all]"
            exit 1
            ;;
    esac
}

main "$@"
