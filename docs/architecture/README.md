# MinistryHub Architecture

## Overview

MinistryHub is a modern web application built with a microservices architecture. This document outlines the high-level architecture and design decisions.

## System Components

### Frontend (Next.js)
- Built with Next.js 14
- Uses App Router and React Server Components
- Styled with TailwindCSS and shadcn/ui
- State management with Zustand and TanStack Query

### Backend (Fastify)
- Fastify-based API server
- tRPC for type-safe API communication
- Drizzle ORM for database access
- Redis for caching and event queues

### Database
- PostgreSQL for primary data storage
- Redis for caching and queues

### Authentication
- Clerk for user management and authentication

## Development Environment

### Local Development
- Docker Compose for local services
- Minikube for local Kubernetes development
- pnpm for package management
- Turborepo for build system

### Deployment
- Kubernetes for container orchestration
- Docker for containerization
- GitHub Actions for CI/CD

## Directory Structure

See the main README.md for the complete directory structure.

## Development Workflow

1. Local Development
   - Use `pnpm dev:web` for frontend development
   - Use `pnpm dev:api` for backend development
   - Use Docker Compose for local services

2. Testing
   - Jest for unit tests
   - Playwright for E2E tests

3. Deployment
   - GitHub Actions for CI/CD
   - Kubernetes for orchestration 