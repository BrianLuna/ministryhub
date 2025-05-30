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
- **PostgreSQL** running locally via Docker
- **Redis** for caching and event queues (running locally via Docker)

### 🔐 Authentication

- **Clerk** for user and session management (free tier)

### ⚙️ Development Environment

- **Docker** for containerization
- **Docker Compose** for local service orchestration
- **Kubernetes** for local development and learning
  - Minikube for local K8s cluster
  - kubectl for cluster management
  - Helm for package management
  - Kustomize for configuration management
- **Local Development**:
  - Frontend: `localhost:3000`
  - Backend: `localhost:4000`
  - PostgreSQL: `localhost:5432`
  - Redis: `localhost:6379`

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
├── apps/                    # Application code
│   ├── web/                # Next.js frontend
│   │   ├── src/           # Source code
│   │   ├── public/        # Static assets
│   │   └── package.json   # Frontend dependencies
│   └── api/               # Fastify backend
│       ├── src/           # Source code
│       └── package.json   # Backend dependencies
│
├── packages/               # Shared packages
│   ├── db/                # Database package
│   │   ├── src/          # Database code
│   │   ├── migrations/   # Drizzle migrations
│   │   └── package.json  # DB package dependencies
│   └── config/           # Shared configurations
│       ├── eslint/       # ESLint configs
│       ├── typescript/   # TS configs
│       └── package.json  # Config package dependencies
│
├── k8s/                   # Kubernetes configurations
│   ├── base/             # Base K8s manifests
│   │   ├── web/         # Frontend K8s configs
│   │   ├── api/         # Backend K8s configs
│   │   └── db/          # Database K8s configs
│   ├── overlays/         # Environment-specific configs
│   │   ├── dev/         # Development environment
│   │   └── prod/        # Production environment
│   └── helm/            # Helm charts
│
├── scripts/              # Development and deployment scripts
│   ├── setup.sh         # Project setup script
│   ├── deploy.sh        # Deployment script
│   └── k8s/            # K8s-specific scripts
│
├── docker/              # Docker-related files
│   ├── web/            # Frontend Dockerfile
│   ├── api/            # Backend Dockerfile
│   └── db/             # Database Dockerfile
│
├── .github/            # GitHub configurations
│   ├── workflows/      # GitHub Actions
│   └── templates/      # PR and issue templates
│
├── docs/              # Project documentation
│   ├── architecture/  # Architecture diagrams
│   ├── api/          # API documentation
│   └── k8s/          # Kubernetes documentation
│
├── .vscode/          # VS Code settings
├── docker-compose.yml # Local development compose file
├── pnpm-workspace.yaml # PNPM workspace config
├── turbo.json        # Turborepo config
├── tsconfig.json     # TypeScript config
├── drizzle.config.ts # Database config
├── eslint.config.mjs # ESLint config
├── prettier.config.js # Prettier config
└── package.json      # Root package.json
```

### Key Directories Explained

1. **`apps/`**: Contains the main applications
   - `web/`: Next.js frontend application
   - `api/`: Fastify backend application

2. **`packages/`**: Shared code and configurations
   - `db/`: Database package with migrations
   - `config/`: Shared configurations for TypeScript, ESLint, etc.

3. **`k8s/`**: Kubernetes configurations
   - `base/`: Base Kubernetes manifests
   - `overlays/`: Environment-specific configurations
   - `helm/`: Helm charts for deployment

4. **`scripts/`**: Development and deployment scripts
   - Setup scripts
   - Deployment scripts
   - Kubernetes-specific scripts

5. **`docker/`**: Docker-related files
   - Separate Dockerfiles for each service
   - Docker-specific configurations

6. **`docs/`**: Project documentation
   - Architecture documentation
   - API documentation
   - Kubernetes setup guides

7. **`.github/`**: GitHub-specific configurations
   - GitHub Actions workflows
   - PR and issue templates

This structure provides:
- Clear separation of concerns
- Easy navigation
- Scalability for future additions
- Support for both local and Kubernetes development
- Comprehensive documentation
- Automated workflows

## 🚀 Getting Started

1. **Prerequisites**:
   - Node.js (LTS version)
   - pnpm
   - Docker and Docker Compose
   - Git
   - kubectl
   - Minikube
   - Helm

2. **Local Development Setup**:
   - Clone the repository
   - Install dependencies: `pnpm install`
   - Choose your development environment:
     
     **Option 1: Docker Compose (Simpler)**
     - Start local services: `docker-compose up -d`
     - Run development servers:
       - Frontend: `pnpm dev:web`
       - Backend: `pnpm dev:api`
     
     **Option 2: Kubernetes (Learning)**
     - Start Minikube: `minikube start`
     - Deploy to K8s: `kubectl apply -k k8s/overlays/dev`
     - Access services:
       - Frontend: `minikube service web`
       - Backend: `minikube service api`

3. **Environment Variables**:
   - Copy `.env.example` to `.env`
   - Configure Clerk credentials
   - Set up database connection details

4. **Database**:
   - PostgreSQL runs locally via Docker or K8s
   - Use Drizzle migrations for schema management
   - Access via `localhost:5432`

5. **Authentication**:
   - Uses Clerk's free tier
   - Configure in your Clerk dashboard
   - Set up environment variables

## 📚 Learning Resources

### Kubernetes
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kustomize Documentation](https://kustomize.io/)

### Project-Specific K8s Learning
- Basic concepts: Pods, Services, Deployments
- Configuration: ConfigMaps, Secrets
- Storage: PersistentVolumes, PersistentVolumeClaims
- Networking: Services, Ingress
- Scaling: HorizontalPodAutoscaler
- Monitoring: Metrics Server, Prometheus
