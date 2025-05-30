# MinistryHub

**MinistryHub** is a platform designed to help organize ministries composed of churches, enabling the management of volunteers, roles, leaders, deacons, people, small groups, calendars, locations, and more.

---

## 🚀 Core Technologies

### 🔧 Project Base

- **TypeScript**
- **Monorepo with Turborepo**
- **pnpm** as the package manager
- **Turbopack** as the bundler for `web`

### 🌐 Frontend

- **React**
- **Next.js (App Router + RSC)**
- **TailwindCSS**
- **shadcn/ui**
- **Zustand** for local state management
- **TanStack Query** for remote state and backend synchronization

### 🧠 Backend

- **Node.js**
- **Fastify** as the HTTP framework
- **tRPC** for fullstack type-safe communication (no REST or GraphQL needed)
- **Drizzle ORM** for database access
- **Firebase Data Connect** as the PostgreSQL database
- **Redis** for caching, microservices state sync, and event queues

### 🔐 Authentication

- **Clerk** + **Firebase** for user and session management

### ⚙️ Infrastructure

- **Docker**
- **Kubernetes** (local via WSL + K8s)
- **Google Cloud Platform (free tier)** for deployments and services

### 🧪 Testing

- **Jest** for unit testing
- **Playwright** for end-to-end testing

### 🧹 Validation

- **Zod** for schema validation on both frontend and backend

### 📦 Version Control

- **Git + Gitflow**
- **GitHub** as the code hosting platform

---

## 📁 Monorepo Structure (Turbo)

```plaintext
ministryhub/
├── apps/
│   ├── web/       # Web client (Next.js)
│   └── api/       # Fastify server (API)
├── packages/
│   ├── db/        # Drizzle ORM config + migrations
│   └── config/    # Shared configs, types, utilities
